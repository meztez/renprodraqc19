library(odbc)
library(data.table)
library(xgboost)
library(Matrix)
library(rprodraqc19)
library(usethis)

con <- dbConnect(odbc(), "DSN", encoding = "latin1", bigint = "integer")
src <- dbGetQuery(con, "SELECT ... FROM ... WHERE ...")

setDT(src)
validate(src)
model_data <- prepare(copy(src))

n <- nrow(model_data)
set.seed(90210)
train_indices <- sort(sample(1:n,0.8*n))
valid_indices  <- (1:n)[-train_indices]

mtrx_train <- xgb.DMatrix(model_data[train_indices, ], label = ifelse(src[train_indices]$TARGET == "O", 1, 0))
mtrx_valid <- xgb.DMatrix(model_data[valid_indices, ], label = ifelse(src[valid_indices]$TARGET == "O", 1, 0))

set.seed(1234)
xgb.tree <- xgb.train(data = mtrx_train,
                      watchlist = list(eval = mtrx_valid, train = mtrx_train),
                      nrounds = 500,
                      objective = "binary:logistic",
                      booster = "gbtree",
                      print_every_n = 50,
                      max_depth = 8,
                      subsample = 0.7,
                      colsample_bytree = 1,
                      eta = 0.03)

xgb.tree$evaluation_log[which.min(xgb.tree$evaluation_log$eval_error)]

trained_model <- xgb.tree
data_template <- rprodraqc2019:::data_template
reference_object <- rprodraqc2019:::reference_object
use_data(trained_model, data_template, reference_object, internal = FALSE, overwrite = TRUE)
