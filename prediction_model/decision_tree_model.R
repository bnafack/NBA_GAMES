
setwd("D:/competition kaggle/NBA_GAMES")
library(tidyverse)
library(data.table)
library(caret) # this library will be used to split the data
library(mlr) # this library will be use to build a model 

games<-read.csv("new_data/games_with_all_stat.csv")


# Let's split our data in train data, which will be used to train the network to predict the outcome 
# of a single the games

# we will chose 5 seasons games to construct the winner season. 

test<- filter(games,games$GAME_DATE_EST>="2016-10-24")

train_data<- filter(games,games$GAME_DATE_EST<"2016-10-24")

#view(train_data)

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

test_precit<-mutate(test_data,predict_HOME_WIN_SCORE=response)

view(test_precit)
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


#### model with feature selection ####


#################Decision tree##############################
tet<-select(Train,PTS_home,PTS_away,HOME_TEAM_WINS )

tr<- makeClassifTask(data=tet, target="HOME_TEAM_WINS")
treet <- makeLearner("classif.rpart")
getParamSet(treet)

## hyperparameter space for tuning

treeParamSpacet <- makeParamSet(
  makeIntegerParam("minsplit", lower = 5, upper = 20),
  makeIntegerParam("minbucket", lower = 3, upper = 10),
  makeNumericParam("cp", lower = 0.01, upper = 0.1),
  makeIntegerParam("maxdepth", lower = 3, upper = 10))

### Defining the random search
randSearcht <- makeTuneControlRandom(maxit = 200)
cvForTuningt <- makeResampleDesc("CV", iters = 5)

### Performing hyperparameter tuning

library(parallel)
library(parallelMap)
parallelStartSocket(cpus = detectCores())
tunedTreeParst <- tuneParams(treet, task = tr,
                            resampling = cvForTuning,
                            par.set = treeParamSpace,
                            control = randSearch)
parallelStop()
tunedTreeParst

## Training the model with the tuned hyperparameters
tunedTreet <- setHyperPars(treet, par.vals = tunedTreeParst$x)
tunedTreeModelt <- train(tunedTreet, tr)

testt<-select(test_data,PTS_home,PTS_away,HOME_TEAM_WINS)
## prediction 
predictedt<-predict(tunedTreeModelt, newdata = testt)
trutht<-predictedt$data$truth
responset<-predictedt$data$response


#Creating confusion matrix   https://www.journaldev.com/46732/confusion-matrix-in-r
examplet <- confusionMatrix(data=as_factor(responset), reference = as_factor(trutht))

#Display results 
examplet

test_precitt<-mutate(testt,predict_HOME_WIN_SCORE=responset)

view(test_precitt)
#### Plotting the decision tree


#install.packages("rpart.plot")
library(rpart.plot)
treeModelDatat <- getLearnerModel(tunedTreeModelt)
rpart.plot(treeModelDatat, roundint = FALSE,
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




### play-off###

To_predict_1<-train_data<-select(test,-GAME_DATE_EST,-VISITOR_TEAM_ID, -SEASON,-HOME_TEAM_ID)

## prediction 
predicted<-predict(tunedTreeModel, newdata = To_predict_1)
truth<-predicted$data$truth
response<-predicted$data$response

#Creating confusion matrix   https://www.journaldev.com/46732/confusion-matrix-in-r
example <- confusionMatrix(data=as_factor(response), reference = as_factor(truth))

#Display results 
example

predictDat<-mutate(test,HOME_WIN_PRED=response)

# Teams that will play play-off
fwrite(predictDat, "new_data/decision_tree_2016_prediction.csv")



### visualization of number of point 

ggplot(data = games, mapping = aes(x =PTS_home , y = ..density..)) + 
  geom_freqpoly( binwidth = 500)


ggplot(games) + 
  geom_bar(mapping = aes(x = PTS_home))

p<-ggplot(games) +
  geom_density(mapping = aes(x = PTS_home,fill='PTS home'),alpha = .3)+
  geom_density(mapping = aes(x = PTS_away, fill='PTS away'),alpha = .3)+
  labs(x="Number of point", y= "Density", title = "Density of points score home and away")+
  theme(plot.title = element_text(hjust = 0.5))+
  scale_color_manual(name = "Fill",
                   breaks = c( "PTS home","PTS away"),
                   values = c( "PTS home"="Blue","PTS away"="red"),drop=F )

ggsave(p, filename = "density_of_point.png")



games1<-filter(games,games$GAME_DATE_EST>="2016-10-24",HOME_TEAM_ID %in%c("Clippers","Jazz","Rockets","Thunder"))

ggplot(games1) +
  geom_density(mapping = aes(x = PTS_away,fill=HOME_TEAM_ID),alpha = .3)
  



library(ROSE)
prop.table(table(Train$HOME_TEAM_WINS))
n<-sum(Train$HOME_TEAM_WINS==1)
data_balanced_under <- ovun.sample( HOME_TEAM_WINS~ ., data = Train, method = "over", N = 2*n, seed = 1)$data
table(data_balanced_under$HOME_TEAM_WINS)
Train<-data_balanced_under

# prediction on unview data, 

view(test)

To_predict<-train_data<-select(test,-GAME_DATE_EST,-VISITOR_TEAM_ID, -SEASON,-HOME_TEAM_ID)

## prediction 
predicted<-predict(tunedTreeModel, newdata = To_predict)
truth<-predicted$data$truth
response<-predicted$data$response

#Creating confusion matrix   https://www.journaldev.com/46732/confusion-matrix-in-r
example <- confusionMatrix(data=as_factor(response), reference = as_factor(truth))

#Display results 
example

predictDat<-mutate(test,HOME_WIN_PRED=response)

# Teams that will play play-off
fwrite(predictDat, "new_data/decison_tree_prediction.csv")

