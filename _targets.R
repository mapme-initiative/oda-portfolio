# Load packages required to define the pipeline:
library(targets)

# Set target options:
tar_option_set(
  packages = c("mapme.biodiversity", "mapme.pipelines", "mapme.indicators", "sf",
               "readxl")
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source("./R")
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  tar_target(
    name = raw_wdpa,
    command = fetch_wdpa(version = "Jul2024", out_path = "./data"),
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
    format = "file"
  ),
  tar_target(
    name = oda_recipients,
    command = get_oda_recipients(),
    format = "file"
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
  )
)
