setwd("D:/competition kaggle/NBA_GAMES")
library(tidyverse)
library(plyr)
library(mice)
library(data.table)

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
fwrite(games, "new_data/games.csv")

view(games)


