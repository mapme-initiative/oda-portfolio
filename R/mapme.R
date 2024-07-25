run_mapme_indicators <- function(
    input,
    opts) {

  config <- readLines(opts$mapme_config)
  output <- gsub(".parquet", "_indicators.gpkg", input)
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
