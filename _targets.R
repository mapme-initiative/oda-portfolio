# Load packages required to define the pipeline:
library(targets)
options(timeout = 600)
options(future.globals.maxSize = 3.0 * 1e9)

# adjust these variables to your local setup
wdpa_opts <- list(
  path = "./raw/wdpa",
  version = "Sep2024"
)

mapme_opts <- list(
  outdir = "/vsiaz/mapme-data",
  rawdir = "./raw",
  mapme_config = "./config.yaml",
  batch_size = 50000,
  max_cores = 10
)

#----------- do not change below this line -------------#

# Set target options:
tar_option_set(
  packages = c(
    "mapme.biodiversity",
    "mapme.pipelines",
    "readxl",
    "sf"
  )
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source("./R")

# Replace the target list below with your own:
list(
  tar_target(
    name = raw_wdpa,
    command = fetch_wdpa(wdpa_opts$path, wdpa_opts$version),
    format = "file"
  ),
  tar_target(
    name = valid_wdpa,
    command = make_valid(raw_wdpa),
    format = "file"
  ),
  tar_target(
    name = oda_iso_codes,
    command = get_oda_iso_codes(),
  ),
  tar_target(
    name = oda_recipients,
    command = get_oda_recipients(),
  ),
  tar_target(
    name = additional_isos,
    command = "additional_isos",
    format = "file"
  ),
  tar_target(
    name = target_isos,
    command = match_isos(oda_iso_codes, oda_recipients, additional_isos)
  ),
  tar_target(
    name = oecd_wdpas,
    command = subset_wdpa(valid_wdpa, target_isos),
    format = "file"
  ),
  tar_target(
    name = indicators_wdpa,
    command = run_mapme_indicators(oecd_wdpas, mapme_opts),
    format = "file"
  )
)
