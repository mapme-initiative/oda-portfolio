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

  if (!spds_exists(url)) {
    stop(paste(
      sprintf("WDAP version '%s' does not seem to exist.\n", version),
      sprintf("Latest version is: '%s'", latest_ver)
    ))
  }

  layers <- sf::st_layers(url)
  layer <- grep("poly", layers$name, value = TRUE)
  dsn <- file.path(path, gsub("gdb", "parquet", basename(url)))

  sf::gdal_utils("vectortranslate",
                 source = url,
                 destination = dsn,
                 options = c(
                   layer,
                   "-progress", "-makevalid", "-wrapdateline",
                   lcos),
                 quiet = TRUE)

  dsn

}

make_valid <- function(path) {

  dsn <- gsub(".parquet", "_valid.parquet", path)
  data <- read_sf(path, check_ring_dir = TRUE)
  is_valid <- st_is_valid(data)
  invalid <- which(!is_valid)
  data[invalid, ] <- st_make_valid(data[invalid, ])
  invalid <- which(!st_is_valid(data[invalid, ]))

  message(sprintf("From total %s geometries, %s were invalid.\nCould not repair %s geometries.",
                  nrow(data), sum(!is_valid), length(invalid)))

  if (length(invalid) > 0 ) data <- data[-invalid, ]
  write_sf(data, dsn, layer_options = lcos[c(FALSE, TRUE)],
           driver = "Parquet", delete_dsn = TRUE)
  dsn

}


buffer_wdpa <- function(path, buffer_size = units::set_units(10, "km"), cores = 10) {

  sf::sf_use_s2(TRUE)
  dsn <- gsub(".parquet", sprintf("_buffer_%skm.parquet", as.character(buffer_size)), path)

  data <- read_sf(path)
  geoms <- st_geometry(data)
  geoms <- split(geoms, ceiling(seq_along(geoms)/(length(geoms)/cores)))

  method <- if(interactive()) future::multisession else future::multicore

  future::plan(method, workers = cores)
  buffers <- furrr::future_map(geoms, function(x){
    hull <- st_convex_hull(x)
    buffer <- st_buffer(hull, dist = buffer_size)
    buffer <- sapply(1:length(x), function(i) st_difference(buffer[i], hull[i]))
    st_as_sfc(buffer)
  })
  future::plan(future::sequential)

  buffers <- do.call(c, buffers)
  st_geometry(data) <- st_sfc(buffers, crs = st_crs(data))
  write_sf(data, dsn, driver = "Parquet", delete_dsn = TRUE,
           layer_options = lcos[c(FALSE, TRUE)])
  dsn

}
