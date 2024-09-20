# Load packages required to define the pipeline:
library(targets)
library(yaml)

# adjust these variables to your local setup
mapme_opts <- read_yaml("mapme_opts.yaml")
expected_mapme_opts <- c("outdir", "rawdir", "input_data", "mapme_config",
                         "batch_size", "max_cores")
stopifnot(all(expected_mapme_opts %in% names(mapme_opts)))
Sys.setenv("delete_dsn" = TRUE)


#----------- do not change below this line -------------#

# Set target options:
tar_option_set(
  packages = c(
    "mapme.biodiversity",
    "mapme.pipelines",
    "dplyr",
    "sf"
  )
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source("./R")

# Replace the target list below with your own:
list(
  tar_target(
    name = fz_portfolio,
    command = read_portfolio_data(mapme_opts$input_data),
    format = "file"
  ),
  tar_target(
    name = indicators_wdpa,
    command = run_mapme_indicators(fz_portfolio, mapme_opts),
    format = "file"
  )
)
