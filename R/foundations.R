read_foundation_data <- function(xlsx) {
  data <- as_tibble(openxlsx2::read_xlsx(xlsx, start_row = 8))
  names(data) <- simplify_names(names(data))
  
  cols <- c(
    name = "stiftungsname",
    inpro_nr = "nummer_stiftung:_gp_nummer_zusagen:_inpro_nummer",
    bmz_nr = "bmz_nummer",
    commitment = "zusagebetrag_komplett",
    payment_2023 = "auszahlungsbetrag_in_eur_summe_aller_auszahlungen_zum_31122023"
  )
  
  rename(data[ ,cols], all_of(cols))
}

analyse_foundations <- function(activites_enriched, foundation_data, donor = "KFW") {
  
  target_bmz_nums <- na.omit(unique(foundation_data$bmz_nr))
  
  activites <- activites_enriched |>
    st_drop_geometry() |>
    filter(!is.na(location_id) & donor == {{donor}} & bmz_nr %in% target_bmz_nums)
  
  
  locs_count <- length(unique(activites$location_id))
  bmznr_count <- length(unique(activites$bmz_nr))
  area_ha <- select(activites, location_id, area_ha) |>
    distinct() |>
    pull(area_ha) |>
    sum()
  
  tibble(
    unique_pas = locs_count,
    unique_projects = bmznr_count,
    total_area = area_ha
  )
}