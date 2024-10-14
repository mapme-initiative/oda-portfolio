select_years <- function(x, years) {
  if (is.null(x)) return(NULL)
  x |>
    dplyr::mutate(
      year = as.character(format(datetime, "%Y")),
      variable = paste(variable, unit, year, sep = "_")
    ) |>
    dplyr::filter(
      year %in% years
    ) |>
    dplyr::select(
      variable, value
    ) |>
    tidyr::pivot_wider(
      names_from = variable
    )
}

summarise_treeccover <- function(x, years = c(2000, 2023)) {
  select_years(x, years)
}

summarise_mangroves <- function(x, years = c(2015, 2020)) {
  select_years(x, years)
}

summarise_biomes <- function(x) {
  if (is.null(x)) return(NULL)
  tibble::tibble(
    dominant_ipbes_biome = x$variable[which.max(x$value)]
  )
}

summarise_carbon <- function(x){
  if (is.null(x)) return(NULL)
  x |>
    dplyr::mutate(
      year = as.character(format(datetime, "%Y")),
      variable = paste(gsub("_sum", "", variable), unit, year, sep = "_")
    ) |>
    dplyr::filter(
      !grepl("*_total*", variable)
    ) |>
    dplyr::select(
      variable, value
    ) |>
    tidyr::pivot_wider(
      names_from = variable
    )
}

summarise_hfp <- function(x, years = c(2000,2020)) {
  if (is.null(x)) return(NULL)
  tmp <- select_years(x, years = c(2000, 2020))
  names(tmp) <- gsub("_unitless", "", names(tmp))
  tmp
}

summarise_sr <- function(x) {
  if (is.null(x)) return(NULL)
  x |>
    dplyr::filter(
      grepl("_thr_", variable)
    ) |>
    dplyr::mutate(
      variable = gsub("_max", "", variable)
    ) |>
    dplyr::select(
      variable, value
    ) |>
    tidyr::pivot_wider(
      names_from = variable
    )
}

summarise_kba <- function(x) {
  if (is.null(x)) return(NULL)
  x |>
    dplyr::mutate(
      variable = paste0(variable, "_ha")
    ) |>
    dplyr::select(
      variable, value
    ) |>
    tidyr::pivot_wider(
      names_from = variable
    )
}

simplify_names <- function(names) {
  stopifnot(inherits(names, "character"))
  names <- gsub("\\.|\\(|\\)|/", "", tolower(names))
  names <-  gsub(" |\n|-", "_", names)
}
