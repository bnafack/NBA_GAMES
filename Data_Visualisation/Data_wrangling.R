setwd("D:/competition kaggle/NBA_GAMES")
library(tidyverse)
library(plyr)
library(caret) # this library will be used to split the data
library(mlr3) # this library will be use to build a model 
library(rpart)

Team<-as_tibble(read.csv("data/teams.csv"))
games<-as_tibble(read.csv("data/games.csv"))
str(Team)

# to change the id team with the names, we are going to use the factors criterions

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


games<-select(games,-GAME_STATUS_TEXT,-TEAM_ID_home,-TEAM_ID_away,-PTS_away,
  -FG_PCT_away,-FT_PCT_away,-FG3_PCT_away,-AST_away,-REB_away )
#view(games)



# number of missing value
sum(is.na(games$PTS_home))
sum(is.na(games$FG_PCT_home))
sum(is.na(games$FT_PCT_home))
sum(is.na(games$FG3_PCT_home))
sum(is.na(games$REB_home))
sum(is.na(games$HOME_TEAM_WINS))


# Let's handle missing value 
# we have two possibility 
# 1- simply exclude cases with missing data from the analysis
# 2- apply an imputation mechanism to fill in the gaps

# since we are predicted the winner teams, the missing value will affect the prediction, however, for 
# prediction of the team which will will win the season, it is important to find the right missing value to be accurate

#in this case we are going to use 1
games<-na.omit(games)


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

# let's design a model 


# logistic regression from mlr package 

winner<- makeClassifTask(data=Train, target="HOME_TEAM_WINS")
logreg<-makeLearner("classif.logreg")
logregModel<-train(logreg,winner)


# cross-validating our logistic regression model
logRegWropper<-makeImputeWrapper("classif.logreg",cols=list(Age=imputeMean()))


# the following step will be use to predicted the winner teams on the season 

# extract data for games in different conference 

east_conference<- filter(games,HOME_TEAM_ID==c("Celtics","Nets","Knicks","76ers","Raptors","Bulls",
                                              "Cavaliers" ,"Pistons","Pacers","Bucks","Hawks",
                                              "Heat" ,"Magic","Wizards","Hornets" ))

west_conference<- filter(games,HOME_TEAM_ID==c("Pelicans","Mavericks","Nuggets","Warriors",
                                               "Rockets","Clippers","Lakers","Timberwolves",
                                                "Suns","Trail Blazers", "Kings","Spurs","Thunder",  
                                               "Jazz","Grizzlies"))
view(west_conference)

# extract games in the same conference
west_games_sames_conference<- filter(games,VISITOR_TEAM_ID==c("Pelicans","Mavericks","Nuggets","Warriors",
                                               "Rockets","Clippers","Lakers","Timberwolves",
                                               "Suns","Trail Blazers", "Kings","Spurs","Thunder",  
                                               "Jazz","Grizzlies"))
view(west_games_sames_conference)

east_games_sames_conference<- filter(games,VISITOR_TEAM_ID==c("Celtics","Nets","Knicks","76ers","Raptors","Bulls",
                                               "Cavaliers" ,"Pistons","Pacers","Bucks","Hawks",
                                               "Heat" ,"Magic","Wizards","Hornets" ))
view(east_games_sames_conference)


