run_mapme_indicators <- function(
    input,
    opts) {

  config <- readLines(opts$mapme_config)
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

read_portfolio_data <- function(filename) {
  dat <- read_sf(filename)
  dat$uuid <- seq_len(nrow(dat))
  print(sprintf("Reading data: %s rows", nrow(dat)))
  dat <- dat [!st_is_empty(dat), ]
  print(sprintf("After removing empty geometries: %s rows", nrow(dat)))
  dat <- dat [!duplicated(dat$wdpa_id, incomparables = NA), ]
  print(sprintf("After removing duplicate WDPAs: %s rows", nrow(dat)))
  dat <- st_make_valid(dat)
  dat <- dat [st_is_valid(dat), ]
  print(sprintf("After removing invalid geometries: %s rows", nrow(dat)))

  dsn <- gsub(".gpkg", "_input.gpkg", basename(filename))
  write_sf(dat, dsn, delete_dsn = TRUE)

  return(dsn)
}
