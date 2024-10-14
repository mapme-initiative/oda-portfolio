# Load packages required to define the pipeline:
library(targets)

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
    name = input_file,
    command = "data/bmz_pa_portfolio_2023_enriched.gpkg",
    format = "file"
  ),
  tar_target(
    name = foundation_xlsx,
    command = "data/stiftungsstruktur_kfw_131024.xlsx",
    format = "file"
  ),
  tar_target(
    name = activites_enriched,
    command = read_sf(input_file)
  ),
  tar_target(
    name = foundation_data,
    command = read_foundation_data(foundation_xlsx)
  ),
  tar_target(
    name = pa_data,
    command = analyse_pas(activites_enriched)
  ),
  tar_target(
    name = pa_table,
    command = subset_locs(activites_enriched)
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
    name = foundation_analysis,
    command = analyse_foundations(activites_enriched, foundation_data, donor = "KFW")
  )
)
