
setwd("D:/competition kaggle/NBA_GAMES")
library(tidyverse)
library(caret) # this library will be used to split the data
library(mlr3) # this library will be use to build a model 

games<-read.csv("new_data/games.csv")


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

train_data<-select(train_data,-GAME_DATE_EST,-GAME_ID,-VISITOR_TEAM_ID, -SEASON,-HOME_TEAM_ID)
view(train_data)

# let's split the data in test and training set 
# we shall used the seed function to make our work reproducible 

set.seed(3456)
trainIndex <- createDataPartition(train_data$HOME_TEAM_WINS, p = .85,
                                  list = FALSE,
                                  times = 1)
Train <- train_data[ trainIndex,]
test_data <- train_data[-trainIndex,] # this data will be use to test the model 

set.seed(3486)
trainIndex <- createDataPartition(Train$HOME_TEAM_WINS, p = .80,
                                  list = FALSE,
                                  times = 1)
Train <- train_data[ trainIndex,]
valid<- train_data[-trainIndex,]

view(valid)
view(Train)

# let's visualize the distribution of data 
sum(Train$HOME_TEAM_WINS==1)
sum(Train$HOME_TEAM_WINS==0)
sum(Train$HOME_TEAM_WINS==0)-sum(Train$HOME_TEAM_WINS==1)
# let's design a model 



#################Decision tree##############################
winner<- makeClassifTask(data=Train, target="HOME_TEAM_WINS")
tree <- makeLearner("classif.rpart")
getParamSet(tree)

## hyperparameter space for tuning

treeParamSpace <- makeParamSet(
  makeIntegerParam("minsplit", lower = 5, upper = 20),
  makeIntegerParam("minbucket", lower = 3, upper = 10),
  makeNumericParam("cp", lower = 0.01, upper = 0.1),
  makeIntegerParam("maxdepth", lower = 3, upper = 10))

### Defining the random search
randSearch <- makeTuneControlRandom(maxit = 200)
cvForTuning <- makeResampleDesc("CV", iters = 5)

### Performing hyperparameter tuning

library(parallel)
library(parallelMap)
parallelStartSocket(cpus = detectCores())
tunedTreePars <- tuneParams(tree, task = winner,
                            resampling = cvForTuning,
                            par.set = treeParamSpace,
                            control = randSearch)
parallelStop()
tunedTreePars

## Training the model with the tuned hyperparameters
tunedTree <- setHyperPars(tree, par.vals = tunedTreePars$x)
tunedTreeModel <- train(tunedTree, winner)

## prediction 
predicted<-predict(tunedTreeModel, newdata = test_data)
truth<-predicted$data$truth
response<-predicted$data$response


#Creating confusion matrix   https://www.journaldev.com/46732/confusion-matrix-in-r
example <- confusionMatrix(data=as_factor(response), reference = as_factor(truth))

#Display results 
example


#### Plotting the decision tree


#install.packages("rpart.plot")
library(rpart.plot)
treeModelData <- getLearnerModel(tunedTreeModel)
rpart.plot(treeModelData, roundint = FALSE,
           box.palette = "BuBn",
           type = 5)

#### Cross-validating our decision tree model

outer <- makeResampleDesc("CV", iters = 5)
treeWrapper <- makeTuneWrapper("classif.rpart", resampling = cvForTuning,
                               par.set = treeParamSpace,
                               control = randSearch)
parallelStartSocket(cpus = detectCores())
cvWithTuning <- resample(treeWrapper, winner, resampling = outer)
parallelStop()
cvWithTuning 



