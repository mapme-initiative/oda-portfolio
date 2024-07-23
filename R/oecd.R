get_oda_iso_codes <- function() {
  dac_codebook <- "https://webfs.oecd.org/oda/DataCollection/Resources/DAC-CRS-CODES.xls"
  dac_codebook_tmp <- tempfile(fileext = ".xls")
  download.file(dac_codebook, dac_codebook_tmp)
  
  dir.create("./data", showWarnings = FALSE)
  dsn <- file.path("./data", "oda_iso_codes.csv")
  codes <- readxl::read_excel(dac_codebook_tmp, sheet = "Recipient")[, c(1,4)]
  names(codes) <- c("code", "iso")
  write.csv(codes, dsn, row.names = FALSE)
  dsn
}

get_oda_recipients <- function() {
  
  oda_recipients_csv <- "https://webfs.oecd.org/oda/DAClists/DAC-List-of-ODA-Recipients-for-reporting-2024-25-flows.csv"
  oda_recipients <- read.csv(oda_recipients_csv)
  dir.create("./data", showWarnings = FALSE)
  dsn <- file.path("./data", "oda_recipients.csv")
  write.csv(oda_recipients, dsn, row.names = FALSE)
  dsn
  
}

match_isos <- function(oda_iso_codes, oda_recipients, additional_isos) {
  
  oda_iso_codes <- read.csv(oda_iso_codes)
  oda_recipients <- read.csv(oda_recipients)
  additional_isos <- readLines(additional_isos)
  
  codes <- oda_iso_codes$iso[oda_iso_codes$code %in% oda_recipients$RecipientCode]
  
  codes <- sort(unique(c(codes, additional_isos)))
  print(codes)
  codes
  
}

subset_wdpa <- function(path, isos) {
  isos <-  paste(sprintf("'%s'", isos), collapse = ",")
  layer <- st_layers(path)[["name"]]
  data <- read_sf(path, query =
                    sprintf(
                      "select * from %s where ISO3 in(%s)",
                      layer, isos),
                  check_ring_dir = TRUE)
  
  is_valid <- st_is_valid(data)
  
  if (sum(!is_valid) > 0) {
    data <- data[is_valid, ]
  }
  
  dsn <- gsub("valid.parquet", "oecd.parquet", path)
  write_sf(data, dsn, layer_options = lcos[c(FALSE, TRUE)], 
           driver = "Parquet", delete_dsn = TRUE)
  dsn
}