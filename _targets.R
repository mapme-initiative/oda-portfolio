# Load packages required to define the pipeline:
library(targets)
readRenviron(".env")
options(timeout = 600)
options(future.globals.maxSize = 1.0 * 1e9)

# adjust these variables to your local setup
mapme_opts <- list(
  outdir = "/home/rstudio/mapme/data",
  rawdir = "/home/rstudio/mapme/raw",
  batch_size = 2500,
  max_cores = 10
)

#----------- do not change below this line -------------#

# Set target options:
tar_option_set(
  packages = c(
    "mapme.biodiversity",
    "mapme.pipelines",
    "openxlsx2",
    "tidyr",
    "dplyr",
    "sf"
  )
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source("./R")

# Replace the target list below with your own:
list(
  tar_target(
    name = config_file,
    command = "config.yaml",
    format = "file"
  ),
  tar_target(
    name = input_file,
    command = "data/bmz_pa_portfolio_2023.gpkg",
    format = "file"
  ),
  tar_target(
    name = activity_data,
    command = read_activity_data(input_file)
  ),
  tar_target(
    name = unique_locations,
    command = split_location_data(activity_data, gsub(".gpkg$", "_unique_locations.gpkg", input_file)),
    format = "file"
  ),
  tar_target(
    name = indicators_locations,
    command = run_mapme_indicators(unique_locations, config_file, mapme_opts),
    format = "file"
  ),
  tar_target(
    name = summarised_indicators,
    command = summarise_indicators(indicators_locations)
  ),
  tar_target(
    name = activites_enriched,
    command = enrich_wpdas(activity_data, summarised_indicators, input_file)
  ),
  tar_target(
    name = excel_output, 
    command = output_xlsx(activites_enriched, input_file),
    format = "file"
  ),
  tar_target(
    name = gpkg_output, 
    command = output_gpkg(activites_enriched, input_file),
    format = "file"
  ),
  tar_target(
    name = pa_data,
    command = analyse_pas(activites_enriched)
  ),
  tar_target(
    name = pa_output_excel,
    command = pa_xlsx(pa_data, input_file),
    format = "file"
  ),
  tar_target(
    name = pa_output_word,
    command = pa_word(pa_data, input_file),
    format = "file"
  ),
  tar_target(
    name = pa_table,
    command = subset_locs(activites_enriched),
    format = "file"
  )
)
