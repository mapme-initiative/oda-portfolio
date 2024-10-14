lcos <- c(
  "-lco", "ROW_GROUP_SIZE=10000",
  "-lco", "WRITE_COVERING_BBOX=YES",
  "-lco", "SORT_BY_BBOX=YES"
)

fetch_wdpa <- function(path, version) {
  
  dir.create(path, showWarnings = FALSE)
  
  baseurl <- "https://pp-import-production.s3-eu-west-1.amazonaws.com/WDPA_WDOECM_%s_Public.zip"
  latest_ver <- basename(httr::HEAD("http://wcmc.io/wdpa_current_release")$url)[[1]]
  latest_ver <- strsplit(latest_ver, "_")[[1]][3]
  
  if (version == "latest") {
    version <- latest_ver
  }
  
  url <- file.path("/vsizip", "/vsicurl", sprintf(baseurl, version))
  filename <- sprintf("WDPA_WDOECM_%s_Public.gdb", version)
  url <- file.path(url, filename)
  dsn <- file.path(path, gsub("gdb", "parquet", basename(url)))
  if(!file.exists(dsn)) {
    if (!spds_exists(url)) {
      stop(paste(
        sprintf("WDAP version '%s' does not seem to exist.\n", version),
        sprintf("Latest version is: '%s'", latest_ver)
      ))
    }
    
    layers <- sf::st_layers(url)
    layer <- grep("poly", layers$name, value = TRUE)
  
    sf::gdal_utils("vectortranslate",
                   source = url,
                   destination = dsn,
                   options = c(
                     layer,
                     "-progress", "-makevalid", "-wrapdateline",
                     lcos),
                   quiet = TRUE)
  }
  
  dsn
  
}

make_valid <- function(path) {
  
  dsn <- gsub(".parquet", "_valid.parquet", path)
  if(!file.exists(dsn)) {
    data <- read_sf(path, check_ring_dir = TRUE)
    is_valid <- st_is_valid(data)
    invalid <- which(!is_valid)
    data[invalid, ] <- st_make_valid(data[invalid, ], split_crossing_edges = TRUE)
    invalid <- which(!st_is_valid(data[invalid, ]))
    
    message(sprintf("From total %s geometries, %s were invalid.\nCould not repair %s geometries.",
                    nrow(data), sum(!is_valid), length(invalid)))
    
    if (length(invalid) > 0 ) data <- data[-invalid, ]
    write_sf(data, dsn, layer_options = lcos[c(FALSE, TRUE)],
             driver = "Parquet", delete_dsn = TRUE)
  }
  dsn
}

coalesce_with_wdpa <- function(activities, wdpa_src) {
  
  # required for matching
  st_geometry(activities) <- "geometry"
  
  cols <- c(
    wdpa_id = "WDPAID", 
    location_name = "NAME", 
    designation = "DESIG_ENG", 
    country = "ISO3",
    iucn_type = "IUCN_CAT", 
    governance_status = "GOV_TYPE")
  
  wdpa_ids <- unique(activities$wdpa_id)
  wdpa_ids <- wdpa_ids[!is.na(wdpa_ids)]
  layer <- st_layers(wdpa_src)[["name"]]
  
  qry <- sprintf(
    "SELECT %s FROM %s WHERE WDPAID IN ('%s')",
    paste0(cols, collapse =","),
    layer, 
    paste0(wdpa_ids, collapse = "', '")
  )
  
  wdpa_locs <- read_sf(wdpa_src, query = qry)
  wdpa_locs <- rename(wdpa_locs, all_of(cols))
  
  missing_ids <- setdiff(wdpa_ids, unique(wdpa_locs$wdpa_id))
  if (length(missing_ids)) {
    msg <- "The following IDs could not be matched with WDPA:\n%s"
    msg <- sprintf(msg, paste0(missing_ids, collapse = " "))
    warning(msg)
  }
  
  wdpa_locs <- group_split(wdpa_locs, wdpa_id)
  wdpa_locs <- lapply(wdpa_locs, \(x) {
    if (nrow(x) == 1) return(x)
    geom <- st_union(x)
    x <- x[1, ] # first observation only
    st_geometry(x) <- geom
    x
  })  
  
  wdpa_locs <- bind_rows(wdpa_locs)
  
  # repeat WDPA vars for each row of activities and use an all NA row for non-matches
  wdpa_locs <- prepare_coalesce(activities, wdpa_locs, "wdpa_id")
  wdpa_locs <- st_cast(wdpa_locs, "MULTIPOLYGON")
  
  is_missing <- which(!names(wdpa_locs) %in% names(activities))
  if (length(missing)) for (i in is_missing) activities[names(wdpa_locs)[i]] <- st_drop_geometry(wdpa_locs[ ,i])

  # now we fill with variables from WDPA
  # sf has no coalesce method yet, so we use our own coalesce function
  filled_cols <- mapply(\(x,y) coalesce2(x,y), 
                        activities[ ,names(cols)], 
                        wdpa_locs,
                        SIMPLIFY = FALSE)
  
  st_geometry(activities) <- filled_cols$geometry
  filled_cols$geometry <- NULL
  activities[ ,names(cols)] <- filled_cols
  
  activities
  
}