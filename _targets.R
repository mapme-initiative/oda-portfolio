# Load packages required to define the pipeline:
library(targets)

# adjust these variables to your local setup
cores <- 10

wdpa_opts <- list(
  path = "./data",
  version = "Jul2024"
)

mapme_opts <- list(
  outdir = "~/mapme/data",
  rawdir = "~/mapme/raw",
  batch_size = 50000,
  max_cores = cores
)


#----------- do not change below this line -------------#

# Set target options:
tar_option_set(
  packages = c(
    "mapme.biodiversity",
    "mapme.pipelines",
    "mapme.indicators",
    "future",
    "furrr",
    "sf",
    "readxl"
  )
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source("./R")

# Replace the target list below with your own:
list(
  # -------------------------------------------------------------------------- #
  # input files - watches for changes
  tar_target(
    name = config_pas,
    command = "config_pas.yaml",
    format = "file"
  ),
  tar_target(
    name = config_buffers,
    command = "config_buffers.yaml",
    format = "file"
  ),
  tar_target(
    name = additional_isos,
    command = "additional_isos",
    format = "file"
  ),
  # -------------------------------------------------------------------------- #
  # dac recipients iso codes matching
  tar_target(
    name = oda_iso_codes,
    command = get_oda_iso_codes(),
  ),
  tar_target(
    name = oda_recipients,
    command = get_oda_recipients(),
  ),
  tar_target(
    name = target_isos,
    command = match_isos(oda_iso_codes, oda_recipients, additional_isos)
  ),
  # -------------------------------------------------------------------------- #
  # wdpa pre-processing
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
    name = oecd_wdpas,
    command = subset_wdpa(valid_wdpa, target_isos),
    format = "file"
  ),
  tar_target(
    name = buffer_10km,
    command = buffer_wdpa(oecd_wdpas, units::set_units(10, "km"), cores),
    format = "file"
  ),
  # -------------------------------------------------------------------------- #
  # indicator calculations
  tar_target(
    name = indicators_pas,
    command = run_mapme_indicators(oecd_wdpas, config_pas, mapme_opts),
    format = "file"
  ),
  tar_target(
    name = indicators_buffer10km,
    command = run_mapme_indicators(buffer_10km, config_buffers, mapme_opts),
    format = "file"
  )
)
