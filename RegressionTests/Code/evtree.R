timestamp <- Sys.time()
library(caret)
library(plyr)
library(recipes)
library(dplyr)
library(evtree)

model <- "evtree"

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

cctrl1 <- trainControl(method = "cv", number = 3, returnResamp = "all")
cctrl2 <- trainControl(method = "LOOCV")
cctrl3 <- trainControl(method = "none")
cctrlR <- trainControl(method = "cv", number = 3, returnResamp = "all", search = "random")

evc <- evtree.control(maxdepth = 5, niterations = 50)

set.seed(849)
test_class_cv_model <- train(trainX, trainY, 
                             method = "evtree", 
                             trControl = cctrl1,
                             control = evc,
                             preProc = c("center", "scale"))

set.seed(849)
test_class_cv_form <- train(Class ~ ., data = training, 
                            method = "evtree", 
                            trControl = cctrl1,
                            control = evc,
                            preProc = c("center", "scale"))

test_class_pred <- predict(test_class_cv_model, testing[, -ncol(testing)])
test_class_prob <- predict(test_class_cv_model, testing[, -ncol(testing)], type = "prob")
test_class_pred_form <- predict(test_class_cv_form, testing[, -ncol(testing)])
test_class_prob_form <- predict(test_class_cv_form, testing[, -ncol(testing)], type = "prob")

set.seed(849)
test_class_rand <- train(trainX, trainY, 
                         method = "evtree", 
                         trControl = cctrlR,
                         tuneLength = 4)

set.seed(849)
test_class_loo_model <- train(trainX, trainY, 
                              method = "evtree", 
                              trControl = cctrl2,
                              control = evc,
                              preProc = c("center", "scale"))

set.seed(849)
test_class_none_model <- train(trainX, trainY, 
                               method = "evtree", 
                               trControl = cctrl3,
                               control = evc,
                               tuneLength = 1,
                               preProc = c("center", "scale"))

test_class_none_pred <- predict(test_class_none_model, testing[, -ncol(testing)])

set.seed(849)
test_class_rec <- train(recipe = rec_cls,
                        data = training,
                        method = "evtree", 
                        trControl = cctrl1,
                        control = evc)


if(
  !isTRUE(
    all.equal(test_class_cv_model$results, 
              test_class_rec$results))
)
  stop("CV weights not giving the same results")


test_class_pred_rec <- predict(test_class_rec, testing[, -ncol(testing)])

test_levels <- levels(test_class_cv_model)
if(!all(levels(trainY) %in% test_levels))
  cat("wrong levels")

#########################################################################

library(caret)
library(plyr)
library(recipes)
library(dplyr)


airq <- subset(airquality, !is.na(Ozone) & complete.cases(airquality))
trainX <- airq[, -1]
trainY <- airq$Ozone
testX <- airq[, -1]
testY <- airq$Ozone

rec_reg <- recipe(Ozone ~ ., data = airq) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) 

rctrl1 <- trainControl(method = "cv", number = 3, returnResamp = "all")
rctrl2 <- trainControl(method = "LOOCV")
rctrl3 <- trainControl(method = "none")
rctrlR <- trainControl(method = "cv", number = 3, returnResamp = "all", search = "random")

set.seed(849)
test_reg_cv_model <- train(trainX, trainY, 
                           method = "evtree", 
                           trControl = rctrl1,
                           control = evc,
                           preProc = c("center", "scale"))
test_reg_pred <- predict(test_reg_cv_model, testX)

set.seed(849)
test_reg_cv_form <- train(Ozone ~ ., data = airq, 
                          method = "evtree", 
                          trControl = rctrl1,
                          control = evc,
                          preProc = c("center", "scale"))
test_reg_pred_form <- predict(test_reg_cv_form, testX)

set.seed(849)
test_reg_rand <- train(trainX, trainY, 
                       method = "evtree", 
                       trControl = rctrlR,
                       tuneLength = 4)

set.seed(849)
test_reg_loo_model <- train(trainX, trainY, 
                            method = "evtree",
                            trControl = rctrl2,
                            control = evc,
                            preProc = c("center", "scale"))

set.seed(849)
test_reg_none_model <- train(trainX, trainY, 
                             method = "evtree", 
                             trControl = rctrl3,
                             control = evc,
                             tuneLength = 1,
                             preProc = c("center", "scale"))
test_reg_none_pred <- predict(test_reg_none_model, testX)

set.seed(849)
test_reg_rec <- train(recipe = rec_reg,
                      data = airq,
                      method = "evtree", 
                      control = evc,
                      trControl = rctrl1)

test_reg_pred_rec <- predict(test_reg_rec, airq[, names(airq) != "Ozone"])

#########################################################################

tests <- grep("test_", ls(), fixed = TRUE, value = TRUE)

sInfo <- sessionInfo()
timestamp_end <- Sys.time()

save(list = c(tests, "sInfo", "timestamp", "timestamp_end"),
     file = file.path(getwd(), paste(model, ".RData", sep = "")))

q("no")


