read_activity_data <- function(filename) {
  data <- read_sf(filename)
  print(sprintf("Reading dataa: %s rows", nrow(data)))
  data <- data [!st_is_empty(data), ]
  print(sprintf("After removing empty geometries: %s rows", nrow(data)))
  data <- st_make_valid(data, split_crossing_edges = TRUE)
  data <- data [st_is_valid(data), ]
  print(sprintf("After removing invalid geometries: %s rows", nrow(data)))
  centroids_org <- st_geometry(st_centroid(data))
  centroids_unique <- st_sfc(unique(centroids_org), crs=st_crs(centroids_org))
  location_ids <- unlist(st_equals(centroids_org, centroids_unique))
  data$location_id <- location_ids
  print(sprintf("With number of unique locations: %s", length(unique(data$location_id))))
  data
}

split_location_data <- function(data, dsn) {
  
  stopifnot("location_id" %in% names(data))
  data <- data[!duplicated(data$location_id, incomparables = NA), "location_id"]
  write_sf(data, dsn)
  dsn
}

run_mapme_indicators <- function(
    input,
    config_file,
    opts) {
  
  config <- readLines(config_file)
  output <- gsub(".gpkg", "_indicators.gpkg", input)
  config <- gsub("\\$input", input, config)
  config <- gsub("\\$output", output, config)
  config <- gsub("\\$batch_size", opts$batch_size, config)
  config <- gsub("\\$max_cores", opts$max_cores, config)
  config <- gsub("\\$datadir", opts$outdir, config)
  config <- gsub("\\$raw", opts$raw, config)
  path <- tempfile(fileext = ".yaml")
  writeLines(config, path)
  
  mapme.pipelines::run_config(path)
}


summarise_indicators <- function(filename) {
  data <- read_portfolio(filename)
  data$treecover_area <- lapply(data$treecover_area, summarise_treeccover)
  data$mangroves_area <- lapply(data$mangroves_area, summarise_mangroves)
  data$ipbes_biomes <- lapply(data$ipbes_biomes, summarise_biomes)
  data$man_carbon <- lapply(data$man_carbon, summarise_carbon)
  data$humanfootprint <- lapply(data$humanfootprint, summarise_hfp)
  data$species_richness <- lapply(data$species_richness, summarise_sr)
  data$key_biodiversity_areas <- lapply(data$key_biodiversity_areas, summarise_kba)
  cols <- mapme.biodiversity:::.indicators_col(data)
  data <- tidyr::unnest(data, cols = names(cols))
  data
}

enrich_wpdas <- function(org_data, sum_data) {
  
  data <- dplyr::left_join(
    org_data,
    st_drop_geometry(sum_data),
    by = "location_id"
  )
  
  drop_vars <- c("assetid")
  data <- dplyr::select(data, -!!drop_vars)
  data
  
}

output_gpkg <- function(data, org_gpkg) {
  dsn <- gsub(".gpkg$", "_enriched.gpkg", org_gpkg)
  org_data <- read_sf(org_gpkg)
  org_empty <- org_data[st_is_empty(org_data), ]
  data <- st_as_sf(bind_rows(data, org_empty))
  st_write(data, dsn, delete_dsn = TRUE, append = FALSE)
  dsn
}

output_xlsx <- function(data, org_gpkg) {
  dsn <- gsub(".gpkg$", "_enriched.xlsx", org_gpkg)
  org_data <- read_sf(org_gpkg)
  org_empty <- org_data[st_is_empty(org_data), ]
  data <- st_as_sf(bind_rows(data, org_empty))
  data <- st_drop_geometry(data)
  openxlsx2::write_xlsx(data, dsn, overwrite = TRUE)
  dsn
}