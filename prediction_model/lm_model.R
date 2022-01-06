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


##########lm###################



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



