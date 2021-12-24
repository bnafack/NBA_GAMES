library(tidyverse)
library(plyr)

Team<-as_tibble(read.csv("data/teams.csv"))
games<-as_tibble(read.csv("data/games.csv"))
str(Team)

# to change the id team with the names, we are going to use the factors criterions

games$HOME_TEAM_ID<-as_factor(games$HOME_TEAM_ID)
games$TEAM_ID_away<-as_factor(games$TEAM_ID_away)
games$VISITOR_TEAM_ID<-as_factor(games$VISITOR_TEAM_ID)
games$TEAM_ID_home<-as_factor(games$TEAM_ID_home)
games$GAME_STATUS_TEXT<-as_factor(games$GAME_STATUS_TEXT)


fact<-c()


for (i in 1:30){
  l = as.numeric(levels(games$HOME_TEAM_ID)[i])
  l = which(Team$TEAM_ID==l)
  
  fact<-append(fact,Team$NICKNAME[l])
  
}
fact

#Let's change the id team to the teams nickname

games$HOME_TEAM_ID <- mapvalues(games$HOME_TEAM_ID, from = levels(games$HOME_TEAM_ID), to=fact)
games$TEAM_ID_away <- mapvalues(games$TEAM_ID_away, from = levels(games$TEAM_ID_away), to=fact)
games$VISITOR_TEAM_ID <- mapvalues(games$VISITOR_TEAM_ID, from = levels(games$VISITOR_TEAM_ID), to=fact)
games$TEAM_ID_home <- mapvalues(games$TEAM_ID_home, from = levels(games$TEAM_ID_home), to=fact)

view(games)

str(games)

games<-select(games,-GAME_STATUS_TEXT,-TEAM_ID_home,-TEAM_ID_away)
view(games)
