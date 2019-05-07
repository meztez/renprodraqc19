.onLoad <- function(lib, pkg){
  utils::data(trained_model,
              data_template,
              reference_object,
              package = pkg, envir = parent.env(environment()))
}
