
setwd("D:/competition kaggle/NBA_GAMES")
library(tidyverse)
library(caret) # this library will be used to split the data
library(mlr3) # this library will be use to build a model 
library(plyr)
games<-read.csv("new_data/games.csv")


# Let's split our data in train data, which will be used to train the network to predict the outcome 
# of a single the games

# we will chose 5 seasons games to construct the winner season. 

test<- filter(games,games$GAME_DATE_EST>="2016-10-24")
test$HOME_TEAM_ID<-as.factor(test$HOME_TEAM_ID)
#############################################

###### Let's extract data to predict the winner seasons starting to "2016-10-24"

#view(test)

seasaon1<-filter(test, test$GAME_DATE_EST>="2016-10-24",test$GAME_DATE_EST<="2017-04-14")
#view(seasaon1)


########### singular saison ########

# Let's count the number of winning games of each team.

l<-levels(droplevels(seasaon1$HOME_TEAM_ID))
number_of_win_games<-c()
number_games_play<-c()

for(i in l){
  seasaon1%>% filter(seasaon1$HOME_TEAM_ID==i)->a
  seasaon1%>% filter(seasaon1$VISITOR_TEAM_ID==i)->c
  
  number_games_play<-append(number_games_play,nrow(c)+nrow(a))
  
  number_of_win_games<-append(number_of_win_games,sum(a$HOME_TEAM_WINS==1)+ sum(c$HOME_TEAM_WINS==0))
}

seasaon1<-data.frame(HOME_TEAM_ID= l,number_games_play=number_games_play,number_of_win_games=number_of_win_games,ratio=number_of_win_games/number_games_play)

seasaon1$HOME_TEAM_ID<-as.factor(as.character(seasaon1$HOME_TEAM_ID))
view(seasaon1)

######## prediction ######


# the following step will be used to predicted the 8 winners teams of each conference for play-off   

# extract data for games in different conference 
levels(seasaon1$HOME_TEAM_ID)[1]

east_conference<- filter(seasaon1,seasaon1$HOME_TEAM_ID %in%c("Celtics","Nets","Knicks","76ers","Raptors","Bulls",
                                                  "Cavaliers" ,"Pistons","Pacers","Bucks",
                                                  "Heat" ,"Magic","Wizards","Hornets","Hawks" ))


west_conference<- filter(seasaon1,HOME_TEAM_ID %in% c('Pelicans',"Mavericks","Nuggets","Warriors",
                                                  "Rockets","Clippers","Lakers","Timberwolves",
                                                  "Suns","Trail Blazers", "Kings","Spurs","Thunder",  
                                                  "Jazz","Grizzlies"))


west_conference <-west_conference[order(-west_conference$number_of_win_games),]


view(west_conference)

east_conference <-east_conference[order(-east_conference$number_of_win_games),]
view(east_conference)

###### play-off ######

# Let's extract the teams that will go to the paly-off

west_conference<- west_conference[1:8,]
view(west_conference)

east_conference<- east_conference[1:8,]
view(east_conference)

