
setwd("D:/competition kaggle/NBA_GAMES")
library(tidyverse)

library(caret) # this library will be used to split the data
library(mlr3) # this library will be use to build a model 

games<-read.csv("new_data/games_with_all_stat.csv")


# Let's split our data in train data, which will be used to train the network to predict the outcome 
# of a single the games

# we will chose 5 seasons games to construct the winner season. 

test<- filter(games,games$GAME_DATE_EST>="2016-10-24")

train_data<- filter(games,games$GAME_DATE_EST<"2016-10-24")

view(train_data)

# in this stage we have to predict whether a specific teams will win or not, so
# we will used home statistic for prediction 

# feature extraction,
names(train_data)

train_data<-select(train_data,-GAME_DATE_EST,-VISITOR_TEAM_ID, -SEASON,-HOME_TEAM_ID)
view(train_data)

# let's split the data in test and training set 
# we shall used the seed function to make our work reproducible 

set.seed(3456)
trainIndex <- createDataPartition(train_data$HOME_TEAM_WINS, p = .85,
                                  list = FALSE,
                                  times = 1)
Train <- train_data[ trainIndex,]
test_data <- train_data[-trainIndex,] # this data will be use to test the model 


# let's visualize the distribution of data 
sum(Train$HOME_TEAM_WINS==1)
sum(Train$HOME_TEAM_WINS==0)
sum(Train$HOME_TEAM_WINS==0)-sum(Train$HOME_TEAM_WINS==1)

# let's design a model 



#################Decision tree##############################
winner<- makeClassifTask(data=Train, target="HOME_TEAM_WINS")
svm <- makeLearner("classif.svm")
getParamSet(svm)

## hyperparameter space for tuning

kernels <- c("polynomial", "radial", "sigmoid")
svmParamSpace <- makeParamSet(
  makeDiscreteParam("kernel", values = kernels),
  makeIntegerParam("degree", lower = 1, upper = 3),
  makeNumericParam("cost", lower = 0.1, upper = 10),
  makeNumericParam("gamma", lower = 0.1, 10))

### Defining the random search
randSearch <- makeTuneControlRandom(maxit = 5)
cvForTuning <- makeResampleDesc("Holdout", split = 2/3)
### Performing hyperparameter tuning

library(parallelMap)
library(parallel)
parallelStartSocket(cpus = detectCores())
tunedSvmPars <- tuneParams("classif.svm", task = winner,
                           resampling = cvForTuning,
                           par.set = svmParamSpace,
                           control = randSearch)
parallelStop()

#Extracting the winning hyperparameter values from tuning

tunedSvmPars
tunedSvmPars$x

## Training the model with the tuned hyperparameters
tunedSvm <- setHyperPars(makeLearner("classif.svm"),
                         par.vals = tunedSvmPars$x)
tunedSvmModel <- train(tunedSvm, winner)

## prediction 
predicted<-predict(tunedSvmModel, newdata = test_data)
truth<-predicted$data$truth
response<-predicted$data$response


#Creating confusion matrix   https://www.journaldev.com/46732/confusion-matrix-in-r
example <- confusionMatrix(data=as_factor(response), reference = as_factor(truth))

#Display results 
example

test_precit<-mutate(test_data,predict_HOME_WIN_SCORE=response)

view(test_precit)


### play-off###

To_predict<-train_data<-select(test,-GAME_DATE_EST,-VISITOR_TEAM_ID, -SEASON,-HOME_TEAM_ID)

## prediction 
predicted<-predict(tunedSvmModel, newdata = To_predict)
truth<-predicted$data$truth
response<-predicted$data$response

#Creating confusion matrix   https://www.journaldev.com/46732/confusion-matrix-in-r
example <- confusionMatrix(data=as_factor(response), reference = as_factor(truth))

#Display results 
example

predictDat<-mutate(test,HOME_WIN_PRED=response)

# Teams that will play play-off
fwrite(predictDat, "new_data/svm_prediction.csv")

### cross validation###

outer <- makeResampleDesc("CV", iters = 3)
svmWrapper <- makeTuneWrapper("classif.svm", resampling = cvForTuning,
                              par.set = svmParamSpace,
                              control = randSearch)
parallelStartSocket(cpus = detectCores())
cvWithTuning <- resample(svmWrapper, winner, resampling = outer)
parallelStop()


###Extracting the cross-validation result###
cvWithTuning
