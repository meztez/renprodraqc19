#' @export
validate <- function(input) {
  selected <-  c("MODVAR1", "DATE",  ...)
  stopifnot(all(selected %in% names(input)))
  removed <- names(input)[!names(input) %in% selected]
  input[, removed := NULL]
  invisible(x)
}
