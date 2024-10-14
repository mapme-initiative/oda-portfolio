simplify_names <- function(names) {
  stopifnot(inherits(names, "character"))
  names <- gsub("\\.|\\(|\\)|/", "", tolower(names))
  names <-  gsub(" |\n|-", "_", names)
}
