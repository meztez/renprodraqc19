#' @export
predict_model_api <- function(input) {
  transform(input)
  predict_model(input)
}

#' @importFrom ...
#' @export
predict_model <- function(input) {

  validate(input)
  model_data <- prepare(copy(src))
  model_revision <- list("model revision" = as.character(packageVersion("rprodraqc19")))
  model_predictions <- predict(object = trained_model, newdata = xgb.DMatrix(model_data))

  return(list("model revision" = model_revision, "model predictions" = model_predictions))
}
