setwd("D:/competition kaggle/NBA_GAMES")
library(tidyverse)
library(caret) # this library will be used to split the data
library(mlr3) # this library will be use to build a model 
library(plyr)
library(mice)

Team<-as_tibble(read.csv("data/teams.csv"))
games<-as_tibble(read.csv("data/games.csv"))
str(Team)

# to change the id team with the names, we are going to use the factors criterion

games$HOME_TEAM_ID<-as_factor(games$HOME_TEAM_ID)
games$TEAM_ID_away<-as_factor(games$TEAM_ID_away)
games$VISITOR_TEAM_ID<-as_factor(games$VISITOR_TEAM_ID)
games$TEAM_ID_home<-as_factor(games$TEAM_ID_home)
games$GAME_STATUS_TEXT<-as_factor(games$GAME_STATUS_TEXT)
games$GAME_DATE_EST<-as.Date(games$GAME_DATE_EST)

fact<-c()


for (i in 1:30){
  l = as.numeric(levels(games$HOME_TEAM_ID)[i])
  l = which(Team$TEAM_ID==l)
  
  fact<-append(fact,Team$NICKNAME[l])
  
}

#Let's change the id team to the teams nickname

games$HOME_TEAM_ID <- mapvalues(games$HOME_TEAM_ID, from = levels(games$HOME_TEAM_ID), to=fact)
games$TEAM_ID_away <- mapvalues(games$TEAM_ID_away, from = levels(games$TEAM_ID_away), to=fact)
games$VISITOR_TEAM_ID <- mapvalues(games$VISITOR_TEAM_ID, from = levels(games$VISITOR_TEAM_ID), to=fact)
games$TEAM_ID_home <- mapvalues(games$TEAM_ID_home, from = levels(games$TEAM_ID_home), to=fact)

# count the number of duplicate number 
sum(duplicated(games$GAME_ID))

#remove duplicated number 
games<- games[!duplicated(games$GAME_ID),]

# Let's check whether we still have duplicate row
sum(duplicated(games$GAME_ID))

# Let's select home statistic for prediction

games<-select(games,-GAME_STATUS_TEXT,-TEAM_ID_home,-TEAM_ID_away,-PTS_away,
  -FG_PCT_away,-FT_PCT_away,-FG3_PCT_away,-AST_away,-REB_away )

#view(games)



# number of missing values
sum(is.na(games$PTS_home))
sum(is.na(games$FG_PCT_home))
sum(is.na(games$FT_PCT_home))
sum(is.na(games$FG3_PCT_home))
sum(is.na(games$REB_home))
sum(is.na(games$HOME_TEAM_WINS))


# Let's handle missing value 
# we have two possibility 
# 1- simply exclude cases with missing data from the analysis, this will end up with droping games
#which will be a problem when predicted the season winner

# 2- apply an imputation mechanism to fill in the gaps

# since we are predicted the winner teams, the missing value will affect the prediction, however, for 
# prediction of the team which will will win the season, it is important to find the right missing value to be accurate

# in this case we used imputation method because each games is important 

t <- mice(games, m=3, maxit = 4, method = 'cart', seed = 500)
games<-complete(t)

#if we want to use 1, we shall apply the following syntax
#games<-na.omit(games)

view(games)

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



# lm model 
model<-lm(HOME_TEAM_WINS~.,Train)
model
predicted<-predict(model, newdata = test_data)
predicted[predicted>=0.5]=1
predicted[predicted<0.5]=0

predicted

example <- confusionMatrix(data=as_factor(predicted), reference = as_factor(test$HOME_TEAM_WINS))

#Display results 
example



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

#############################################

###### Let's extract data to predict the winner seasons starting to "2016-10-24"

view(test)

seasaon1<-filter(test, test$GAME_DATE_EST>="2016-10-24",test$GAME_DATE_EST<="2017-04-14")
view(seasaon1)


# the following step will be used to predicted the 8 winners teams of each conference for play-off   

# extract data for games in different conference 

east_conference<- filter(seasaon1,HOME_TEAM_ID==c("Celtics","Nets","Knicks","76ers","Raptors","Bulls",
                                              "Cavaliers" ,"Pistons","Pacers","Bucks",
                                              "Heat" ,"Magic","Wizards","Hornets","Hawks" ))

view(east_conference)

west_conference<- filter(seasaon1,HOME_TEAM_ID==c("Pelicans","Mavericks","Nuggets","Warriors",
                                              "Rockets","Clippers","Lakers","Timberwolves",
                                              "Suns","Trail Blazers", "Kings","Spurs","Thunder",  
                                              "Jazz","Grizzlies"))
levels(east_conference$HOME_TEAM_ID)

t<-levels(droplevels(west_conference$HOME_TEAM_ID))
number_of_win_games<-c()

for(i in t){
  west_conference%>% filter(west_conference$HOME_TEAM_ID==i)->a
  number_of_win_games<-append(number_of_win_games,sum(a$HOME_TEAM_WINS))
  }

weast_season<-data.frame(HOME_TEAM_ID= t,number_of_win_games=number_of_win_games)

view(weast_season)

## east conference

t<-levels(droplevels(east_conference$HOME_TEAM_ID))
number_of_win_games<-c()

for(i in t){
  east_conference%>% filter(east_conference$HOME_TEAM_ID==i)->a
  number_of_win_games<-append(number_of_win_games,sum(a$HOME_TEAM_WINS))
}

east_season<-data.frame(HOME_TEAM_ID= t,number_of_win_games=number_of_win_games)

view(east_season)




# Let's count the number of winning games of each team.



l# the following step will be use to predicted the winner teams on the season 

# extract data for games in different conference 

east_conference<- filter(test,HOME_TEAM_ID==c("Celtics","Nets","Knicks","76ers","Raptors","Bulls",
                                              "Cavaliers" ,"Pistons","Pacers","Bucks","Hawks",
                                              "Heat" ,"Magic","Wizards","Hornets" ))

west_conference<- filter(test,HOME_TEAM_ID==c("Pelicans","Mavericks","Nuggets","Warriors",
                                               "Rockets","Clippers","Lakers","Timberwolves",
                                                "Suns","Trail Blazers", "Kings","Spurs","Thunder",  
                                               "Jazz","Grizzlies"))


view(west_conference)

# extract games in the same conference
west_games_sames_conference<- filter(test,VISITOR_TEAM_ID==c("Pelicans","Mavericks","Nuggets","Warriors",
                                               "Rockets","Clippers","Lakers","Timberwolves",
                                               "Suns","Trail Blazers", "Kings","Spurs","Thunder",  
                                               "Jazz","Grizzlies"))
view(west_games_sames_conference)

east_games_sames_conference<- filter(test,VISITOR_TEAM_ID==c("Celtics","Nets","Knicks","76ers","Raptors","Bulls",
                                               "Cavaliers" ,"Pistons","Pacers","Bucks","Hawks",
                                               "Heat" ,"Magic","Wizards","Hornets" ))
view(east_games_sames_conference)


