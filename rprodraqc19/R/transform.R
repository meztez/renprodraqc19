#' @importFrom data.table setDT setnames
transform <- function(input) {

  setDT(input)

  old = c("VAR1", ...)
  new = c("MODVAR1", ...)
  setnames(input, old, new, skip_absent = TRUE)

  input[, VAR4 := "*"]
  input[, VAR5 := as.numeric(VAR5)]
  input[, DATE := as.POSIXct(DATE, tz = "UTC")]

  invisible(input)
}
