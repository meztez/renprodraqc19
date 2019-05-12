library(rprodraqc19)
warmup()

#* @apiTitle R en Production
#* @api

#* Predict total loss cgen
#* @param input Input for our model
#* @post /predict_model_api
#* @get /predict_model_api
#* @json
function(input) {
    return(predict_model_api(input))
}
