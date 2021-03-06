timestamp <- Sys.time()
library(caret)
library(plyr)
library(recipes)
library(dplyr)

model <- "plsRglm"

## In case the package or one of its dependencies uses random numbers
## on startup so we'll pre-load the required libraries: 

for(i in getModelInfo(model)[[1]]$library)
  do.call("require", list(package = i))

#########################################################################

set.seed(2)
training <- twoClassSim(50, linearVars = 2)
testing <- twoClassSim(500, linearVars = 2)
trainX <- training[, -ncol(training)]
trainY <- training$Class

rec_cls <- recipe(Class ~ ., data = training) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors())

seeds <- vector(mode = "list", length = nrow(training) + 1)
seeds <- lapply(seeds, function(x) 1:20)

cctrl1 <- trainControl(method = "cv", number = 3, returnResamp = "all",
                       classProbs = TRUE, 
                       summaryFunction = twoClassSummary,
                       seeds = seeds)
cctrl2 <- trainControl(method = "LOOCV",
                       classProbs = TRUE, 
                       summaryFunction = twoClassSummary,
                       seeds = seeds)
cctrl3 <- trainControl(method = "none",
                       classProbs = TRUE, summaryFunction = twoClassSummary,
                       seeds = seeds)
cctrlR <- trainControl(method = "cv", number = 3, 
                       returnResamp = "all", search = "random",
                       seeds = seeds)

set.seed(849)
test_class_cv_model <- train(trainX, trainY, 
                             method = "plsRglm", 
                             trControl = cctrl1,
                             metric = "ROC",
                             preProc = c("center", "scale"),
                             verbose = FALSE)

set.seed(849)
test_class_cv_form <- train(Class ~ ., data = training, 
                            method = "plsRglm", 
                            trControl = cctrl1,
                            metric = "ROC", 
                            preProc = c("center", "scale"),
                            verbose = FALSE)

test_class_pred <- predict(test_class_cv_model, testing[, -ncol(testing)])
test_class_prob <- predict(test_class_cv_model, testing[, -ncol(testing)], type = "prob")
test_class_pred_form <- predict(test_class_cv_form, testing[, -ncol(testing)])
test_class_prob_form <- predict(test_class_cv_form, testing[, -ncol(testing)], type = "prob")

set.seed(849)
test_class_rand <- train(trainX, trainY, 
                         method = "plsRglm", 
                         trControl = cctrlR,
                         tuneLength = 4, 
                         preProc = c("center", "scale"),
                         verbose = FALSE)

set.seed(849)
test_class_loo_model <- train(trainX, trainY, 
                              method = "plsRglm", 
                              trControl = cctrl2,
                              metric = "ROC", 
                              preProc = c("center", "scale"),
                              verbose = FALSE)

set.seed(849)
test_class_none_model <- train(trainX, trainY, 
                               method = "plsRglm", 
                               trControl = cctrl3,
                               tuneGrid = data.frame(nt = 1, alpha.pvals.expli = 1),
                               metric = "ROC", 
                               preProc = c("center", "scale"),
                               verbose = FALSE)

test_class_none_pred <- predict(test_class_none_model, testing[, -ncol(testing)])
test_class_none_prob <- predict(test_class_none_model, testing[, -ncol(testing)], type = "prob")

set.seed(849)
test_class_rec <- train(recipe = rec_cls,
                        data = training,
                        method = "plsRglm", 
                        trControl = cctrl1,
                        metric = "ROC",
                        verbose = FALSE)


if(
  !isTRUE(
    all.equal(test_class_cv_model$results, 
              test_class_rec$results))
)
  stop("CV weights not giving the same results")


test_class_pred_rec <- predict(test_class_rec, testing[, -ncol(testing)])
test_class_prob_rec <- predict(test_class_rec, testing[, -ncol(testing)], 
                               type = "prob")

test_levels <- levels(test_class_cv_model)

#########################################################################

library(caret)
library(plyr)
library(recipes)
library(dplyr)
set.seed(1)
training <- SLC14_1(30)
testing <- SLC14_1(100)
trainX <- training[, -ncol(training)]
trainY <- training$y

rec_reg <- recipe(y ~ ., data = training) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) 
testX <- trainX[, -ncol(training)]
testY <- trainX$y 

rctrl1 <- trainControl(method = "cv", number = 3, returnResamp = "all")
rctrl2 <- trainControl(method = "LOOCV")
rctrl3 <- trainControl(method = "none")
rctrlR <- trainControl(method = "cv", number = 3, returnResamp = "all", search = "random")

set.seed(849)
test_reg_cv_model <- train(trainX, trainY, 
                           method = "plsRglm", 
                           trControl = rctrl1, 
                           preProc = c("center", "scale"),
                           verbose = FALSE)
test_reg_pred <- predict(test_reg_cv_model, testX)

set.seed(849)
test_reg_cv_form <- train(y ~ ., data = training, 
                          method = "plsRglm", 
                          trControl = rctrl1, 
                          preProc = c("center", "scale"),
                          verbose = FALSE)
test_reg_pred_form <- predict(test_reg_cv_form, testX)

set.seed(849)
test_reg_rand <- train(trainX, trainY, 
                       method = "plsRglm", 
                       trControl = rctrlR,
                       tuneLength = 4, 
                       preProc = c("center", "scale"),
                       verbose = FALSE)

set.seed(849)
test_reg_loo_model <- train(trainX, trainY, 
                            method = "plsRglm",
                            trControl = rctrl2, 
                            preProc = c("center", "scale"),
                            verbose = FALSE)

set.seed(849)
test_reg_none_model <- train(trainX, trainY, 
                             method = "plsRglm", 
                             trControl = rctrl3, 
                             tuneGrid = data.frame(nt = 1, alpha.pvals.expli = 1),
                             preProc = c("center", "scale"),
                             verbose = FALSE)
test_reg_none_pred <- predict(test_reg_none_model, testX)

set.seed(849)
test_reg_rec <- train(recipe = rec_reg,
                      data = training,
                      method = "plsRglm", 
                      trControl = rctrl1,
                      verbose = FALSE)

if(
  !isTRUE(
    all.equal(test_reg_cv_model$results, 
              test_reg_rec$results))
)
  stop("CV weights not giving the same results")


test_reg_pred_rec <- predict(test_reg_rec, testing[, -ncol(testing)])

#########################################################################

test_class_predictors1 <- predictors(test_class_cv_model)
test_reg_predictors1 <- predictors(test_reg_cv_model)

#########################################################################

tests <- grep("test_", ls(), fixed = TRUE, value = TRUE)

sInfo <- sessionInfo()
timestamp_end <- Sys.time()

save(list = c(tests, "sInfo", "timestamp", "timestamp_end"),
     file = file.path(getwd(), paste(model, ".RData", sep = "")))

q("no")


