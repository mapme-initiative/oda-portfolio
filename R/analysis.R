

analyse_pas <- function(data, input_file) {
  
  data_empty <- data[st_is_empty(data), ]
  data <- data[!st_is_empty(data), ]
  
  pa_data <- data |>
    st_drop_geometry() |>
    select(location_id, donor, area_ha, designation, iplc_status, country) |>
    mutate(
      iplc = case_when(
        grepl("^Yes", iplc_status) ~ 1,
        grepl("^No", iplc_status) ~ 0,
        .default = 0
      ),
      ramsar = case_when(
        grepl("ramsar", tolower(designation)) ~1,
        .default = 0
      ),
      mab = case_when(
        grepl("mab", tolower(designation)) ~1,
        .default = 0
      ),
      wh =  case_when(
        grepl("wh|world heritage", tolower(designation)) ~1,
        .default = 0
      )
    ) |>
    select(-c(designation, iplc_status)) |>
    distinct() |>
    group_by(location_id) |>
    summarise(
      donor = ifelse(length(unique(donor)) > 1, "both", donor),
      area_ha = ifelse(n()>1, area_ha[1], area_ha),
      iplc = max(iplc),
      ramsar = max(ramsar),
      mab = max(mab),
      wh = max(wh),
      country = country[1]
    ) |>
    ungroup()
  
  is_kfw <- pa_data$donor %in% c("KFW", "both")
  is_giz <- pa_data$donor %in% c("GIZ", "both")
  is_both <- pa_data$donor == "both"
  
  ########################## Counts
  counts <- tibble(
    var = "pa_counts",
    kfw = sum(is_kfw),
    giz = sum(is_giz),
    both =  sum(is_both),
    total = nrow(pa_data)
  )
  
  ########################## Areas
  areas <- tibble(
    var = "pa_area",
    kfw = sum(pa_data$area_ha[is_kfw]),
    giz = sum(pa_data$area_ha[is_giz]),
    both =  sum(pa_data$area_ha[is_both]),
    total = sum(pa_data$area_ha)
  )
  
  ########################## Countries
  countries <- tibble(
    var = "countries",
    kfw = length(unique(sapply(strsplit(pa_data$country[is_kfw], ";"), \(x) x[[1]]))),
    giz = length(unique(sapply(strsplit(pa_data$country[is_giz], ";"), \(x) x[[1]]))),
    both = length(unique(sapply(strsplit(pa_data$country[is_both], ";"), \(x) x[[1]]))),
    total = length(unique(sapply(strsplit(pa_data$country, ";"), \(x) x[[1]])))
  )
  
  ########################## count RAMSAR
  ramsar_count <- tibble(
    var = "ramsar_count",
    kfw = sum(pa_data$ramsar[is_kfw]),
    giz = sum(pa_data$ramsar[is_giz]),
    both = sum(pa_data$ramsar[is_both]),
    total = sum(pa_data$ramsar)
  )
  
  
  ########################## area RAMSAR
  ramsar_area <- tibble(
    var = "ramsar_area",
    kfw = sum(pa_data$area_ha[pa_data$ramsar == 1 & is_kfw]),
    giz = sum(pa_data$area_ha[pa_data$ramsar == 1 & is_giz]),
    both = sum(pa_data$area_ha[pa_data$ramsar == 1 & is_both]),
    total =sum(pa_data$area_ha[pa_data$ramsar == 1])
  )
  
  ########################## count MAB
  mab_count <- tibble(
    var = "mab_count",
    kfw = sum(pa_data$mab[is_kfw]),
    giz = sum(pa_data$mab[is_giz]),
    both = sum(pa_data$mab[is_both]),
    total = sum(pa_data$mab)
  )
  
  
  ########################## area MAB
  mab_area <- tibble(
    var = "mab_area",
    kfw = sum(pa_data$area_ha[pa_data$mab == 1 & is_kfw]),
    giz = sum(pa_data$area_ha[pa_data$mab == 1 & is_giz]),
    both = sum(pa_data$area_ha[pa_data$mab == 1 & is_both]),
    total =sum(pa_data$area_ha[pa_data$mab == 1])
  )
  
  ########################## count WHS
  whs_count <- tibble(
    var = "whs_count",
    kfw = sum(pa_data$wh[is_kfw]),
    giz = sum(pa_data$wh[is_giz]),
    both = sum(pa_data$wh[is_both]),
    total = sum(pa_data$wh)
  )
  
  
  ########################## area WHS
  whs_area <- tibble(
    var = "whs_area",
    kfw = sum(pa_data$area_ha[pa_data$wh == 1 & is_kfw]),
    giz = sum(pa_data$area_ha[pa_data$wh == 1 & is_giz]),
    both = sum(pa_data$area_ha[pa_data$wh == 1 & is_both]),
    total =sum(pa_data$area_ha[pa_data$wh == 1])
  )
  
  
  ########################## count IPLC
  iplc_count <- tibble(
    var = "iplc_count",
    kfw = sum(pa_data$iplc[is_kfw]),
    giz = sum(pa_data$iplc[is_giz]),
    both = sum(pa_data$iplc[is_both]),
    total = sum(pa_data$iplc)
  )
  
  
  ########################## area IPLC
  iplc_area <- tibble(
    var = "iplc_area",
    kfw = sum(pa_data$area_ha[pa_data$iplc == 1 & is_kfw]),
    giz = sum(pa_data$area_ha[pa_data$iplc == 1 & is_giz]),
    both = sum(pa_data$area_ha[pa_data$iplc == 1 & is_both]),
    total =sum(pa_data$area_ha[pa_data$iplc == 1])
  )
  
  ###################### emtpy counts
  unmatched <- tibble(
    var = "unmatched_activities",
    kfw = sum(data_empty$donor == "KFW"),
    giz = sum(data_empty$donor == "GIZ"),
    both = NA,
    total = nrow(data_empty)
  )
  
  results <- do.call(rbind, list(
    counts, areas, countries,
    ramsar_count, ramsar_area,
    mab_count, mab_area,
    whs_count, whs_area,
    iplc_count, iplc_area,
    unmatched
  ))
  
  dsn <- gsub(".gpkg", "_pa_analysis.xlsx", input_file)
  openxlsx2::write_xlsx(results, dsn)
  dsn
}
