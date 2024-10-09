subset_locs <- function(data) {
  
  data_empty <- data[st_is_empty(data), ]
  data <- data[!st_is_empty(data), ]
  
  formats <- c("%Y", "%Y-%m-%d", "%B %Y", "%d.%m.%Y")
  data$activity_end_date <-  lubridate::parse_date_time(data$activity_end_date, formats)
  
  locs <- select(data, location_id) |>
    group_by(location_id) |>
    summarise(geom = geom[1])
  
  
  data2 <- st_drop_geometry(data) |>
    select(-c(team, abbreviation_project, location_name, activity_start_date,
              activity_status, collection_date, kml_file, kml_key))
  vars <- names(data2)
  vars <- setdiff(vars, c("location_id", "bmz_nr", "donor", "activity_end_date"))
  
  data2 <- data2 |>
    distinct() |>
    group_by(location_id) |>
    summarise(
      bmz_nrs = paste0(bmz_nr, collapse = ";"),
      donor_kfw = any(grepl("KFW", donor)),
      donor_giz = any(grepl("KFW", donor)),
      post_2023 = any(as.Date(activity_end_date) >= as.Date("2023-12-31")),
      across(all_of(vars), ~.x[1], .names = "{.col}") # first match
    )
  
  data2 <- st_as_sf(left_join(data2, locs, by = "location_id"))
  st_write(data2, dsn = "data/bmz_pas_2023.gpkg", delete_dsn = TRUE)
  openxlsx2::write_xlsx(st_drop_geometry(data2), file = "data/bmz_pas_2023.xlsx")
  "data/bmz_pas_2023.xlsx"
}