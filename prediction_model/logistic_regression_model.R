setwd("D:/competition kaggle/NBA_GAMES")
library(tidyverse)
library(caret) # this library will be used to split the data
library(mlr)
library(data.table)
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
nrow(test_data)
nrow(Train)

# let's visualize the distribution of data 
sum(Train$HOME_TEAM_WINS==1)
sum(Train$HOME_TEAM_WINS==0)
sum(Train$HOME_TEAM_WINS==0)-sum(Train$HOME_TEAM_WINS==1)
# let's design a model 


# logistic regression from mlr package


winner<- makeClassifTask(data=Train, target="HOME_TEAM_WINS")
logreg<-makeLearner("classif.logreg")
logregModel<-train(logreg,winner)

print(logregModel)
# cross-validating our logistic regression model
logRegWrapper<-makeImputeWrapper("classif.logreg")
Kfold <-makeResampleDesc(method = "RepCV",folds=5,reps=50,stratify = TRUE)
Kfold


logRegwithImpute<-resample(logRegWrapper,winner,resampling = Kfold, measures = list(acc, fpr, fnr))
logRegwithImpute

# extracting model parameters 

logRegModelData<-getLearnerModel(logregModel)

coef(logRegModelData)

#prediction of the model 

predicted<-predict(logregModel, newdata = test_data,type="class")
truth<-predicted$data$truth
response<-predicted$data$response

#Now we can compute the classification error rate by comparing `predicted.y` against the expected $y$:

length(which(truth!=response))/length(predicted$data)


#Creating confusion matrix   https://www.journaldev.com/46732/confusion-matrix-in-r
example <- confusionMatrix(data=as_factor(response), reference = as_factor(truth))

#Display results 
example
view(Train)
# features selection

library(Boruta)
library(mlbench)

library(randomForest)
set.seed(111)
boruto<-Boruta(HOME_TEAM_WINS~.,data = Train,doTrace=2, maxRuns=100)
print(boruto)
plot(boruto,las=2,cex.axis=0.5)
plotImpHistory(boruto)
bor<-TentativeRoughFix(boruto)
bor
getNonRejectedFormula(boruto)



tet<-select(Train,PTS_home,PTS_away,HOME_TEAM_WINS )

mdl<- makeClassifTask(data=tet, target="HOME_TEAM_WINS")
lr<-makeLearner("classif.logreg")
logr<-train(lr,mdl)
#prediction of the model 

testt<-select(test_data,PTS_home,PTS_away,HOME_TEAM_WINS)
predictedt<-predict(logr, newdata = testt,type="class")
trutht<-predictedt$data$truth
responset<-predictedt$data$response

#Now we can compute the classification error rate by comparing `predicted.y` against the expected $y$:

length(which(trutht!=responset))/length(predictedt$data)


#Creating confusion matrix   https://www.journaldev.com/46732/confusion-matrix-in-r
examplet <- confusionMatrix(data=as_factor(responset), reference = as_factor(trutht))

#Display results 
examplet

# cross-validating our logistic regression model
logRWrapper<-makeImputeWrapper("classif.logreg")
Kfoldt <-makeResampleDesc(method = "RepCV",folds=5,reps=50,stratify = TRUE)
Kfoldt

logRwithImpute<-resample(logRWrapper,mdl,resampling = Kfoldt, measures = list(acc, fpr, fnr))
logRwithImpute

## prediction of test data set##

### play-off###

To_predict<-train_data<-select(test,PTS_home,PTS_away,HOME_TEAM_WINS)

## prediction 
predicted<-predict(logr, newdata = To_predict)
truth<-predicted$data$truth
response<-predicted$data$response

#Creating confusion matrix   https://www.journaldev.com/46732/confusion-matrix-in-r
example <- confusionMatrix(data=as_factor(response), reference = as_factor(truth))

#Display results 
example

predictDat<-mutate(test,HOME_WIN_PRED=response)

# Teams that will play play-off
fwrite(predictDat, "new_data/logreg_prediction.csv")
