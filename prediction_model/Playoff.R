
setwd("D:/competition kaggle/NBA_GAMES")
library(tidyverse)
library(caret) # this library will be used to split the data
library(mlr3) # this library will be use to build a model 
library(plyr)
library(data.table)
test<-read.csv("new_data/svm_prediction.csv")


# Let's split our data in train data, which will be used to train the network to predict the outcome 
# of a single the games

# we will chose 5 seasons games to construct the winner season. 


test$HOME_TEAM_ID<-as.factor(test$HOME_TEAM_ID)
#############################################

###### Let's extract data to predict the winner seasons starting to "2016-10-24"

view(test)

seasaon1<-filter(test, test$GAME_DATE_EST>="2016-10-24",test$GAME_DATE_EST<="2017-04-14")
#view(seasaon1)


########### singular saison ########

# Let's count the number of winning games of each team.

l<-levels(droplevels(seasaon1$HOME_TEAM_ID))
number_of_win_games<-c()
number_games_play<-c()
pred_numb_win<-c()

for(i in l){
  seasaon1%>% filter(seasaon1$HOME_TEAM_ID==i)->a
  seasaon1%>% filter(seasaon1$VISITOR_TEAM_ID==i)->c
  
  
  number_games_play<-append(number_games_play,nrow(c)+nrow(a))
  
  number_of_win_games<-append(number_of_win_games,sum(a$HOME_TEAM_WINS==1)+ sum(c$HOME_TEAM_WINS==0))
  pred_numb_win<-append(pred_numb_win,sum(a$HOME_WIN_PRED==1)+ sum(c$HOME_WIN_PRED==0))
}

seasaon1<-data.frame(HOME_TEAM_ID= l,number_games_play=number_games_play,number_of_win_games=number_of_win_games, pred_numb_win= pred_numb_win,ratio=number_of_win_games/number_games_play)

seasaon1$HOME_TEAM_ID<-as.factor(as.character(seasaon1$HOME_TEAM_ID))
view(seasaon1)

######## prediction ######


# the following step will be used to predicted the 8 winners teams of each conference for play-off   

# extract data for games in different conference 


east_conference<- filter(seasaon1,seasaon1$HOME_TEAM_ID %in%c("Celtics","Nets","Knicks","76ers","Raptors","Bulls",
                                                              "Cavaliers" ,"Pistons","Pacers","Bucks",
                                                              "Heat" ,"Magic","Wizards","Hornets","Hawks" ))


west_conference<- filter(seasaon1,HOME_TEAM_ID %in% c('Pelicans',"Mavericks","Nuggets","Warriors",
                                                      "Rockets","Clippers","Lakers","Timberwolves",
                                                      "Suns","Trail Blazers", "Kings","Spurs","Thunder",  
                                                      "Jazz","Grizzlies"))


west_conference <-west_conference[order(-west_conference$number_of_win_games),]


view(west_conference)

# from the up view, we cant see that each teams plays 82 games which confirm our previous analysis

east_conference <-east_conference[order(-east_conference$number_of_win_games),]
view(east_conference)

###### play-off ######

# Let's extract the teams that will go to the paly-off

west_conference<- west_conference[1:8,]
view(west_conference)

east_conference<- east_conference[1:8,]
view(east_conference)
## we check with the origanal classification in 2016, it confirm our analysis https://fr.wikipedia.org/wiki/Playoffs_NBA_2017


## Let's arrange the bool for play-off  

PlayOff<-filter(test, test$GAME_DATE_EST>"2017-04-14",test$GAME_DATE_EST<="2017-06-12")
PlayOff$GAME_DATE_EST<-as.Date(PlayOff$GAME_DATE_EST)

########### play-off ########

view(PlayOff)

PlayOff<-PlayOff[order(PlayOff$GAME_DATE_EST),]
view(PlayOff)


west_conference$HOME_TEAM_ID <-as.character(west_conference$HOME_TEAM_ID)
PlayOff$HOME_TEAM_ID <-as.character(PlayOff$HOME_TEAM_ID)
PlayOff$VISITOR_TEAM_ID<-as.character(PlayOff$VISITOR_TEAM_ID)
west_conference$HOME_TEAM_ID[3]

# find the winner teams for the first turn of play-off

firstturn<-data.frame(Teams1=as.character(), teams2=as.character(), wining_teams=as.character())

view(firstturn)
n<-8

for(i in 1:4){
  
  compt1<-0
  compt2<-0
  Next<-1 
  
  n<-n+1- as.integer(i)
  
  teams<-filter(PlayOff,HOME_TEAM_ID %in%c(west_conference$HOME_TEAM_ID[i],west_conference$HOME_TEAM_ID[n]), VISITOR_TEAM_ID%in%c(west_conference$HOME_TEAM_ID[i],west_conference$HOME_TEAM_ID[n]))
  
  view(teams)
  
  while(compt1<=4|compt2<=4){
    
    if(teams$HOME_TEAM_ID[Next]==west_conference$HOME_TEAM_ID[i]){
      compt1<-compt1 + teams$HOME_TEAM_WINS[Next]
      compt2<-compt2 + 1- teams$HOME_TEAM_WINS[Next] # if the first teams win , we will have 1-1 for the second teams 
      
    }
    
    if(teams$HOME_TEAM_ID[Next]==west_conference$HOME_TEAM_ID[n]){
      compt2<-compt2 + teams$HOME_TEAM_WINS[Next]
      compt1<-compt1 + 1- teams$HOME_TEAM_WINS[Next] # if the first teams win , we will have 1-1 for the second teams 
      
    }
    Next<-Next+1
  }
  
  if(compt1==4){
    l<-c(west_conference$HOME_TEAM_ID[i],west_conference$HOME_TEAM_ID[n], west_conference$HOME_TEAM_ID[i])
  }
  
  if(compt2==4){
    l<-c(west_conference$HOME_TEAM_ID[i],west_conference$HOME_TEAM_ID[n], west_conference$HOME_TEAM_ID[n])
  }
  
  firstturn<-rbind(firstturn,l)
  
}

i<-2
n<-n+1- as.integer(i)

teams<-filter(PlayOff,HOME_TEAM_ID %in%c(west_conference$HOME_TEAM_ID[i],west_conference$HOME_TEAM_ID[n]), VISITOR_TEAM_ID%in%c(west_conference$HOME_TEAM_ID[i],west_conference$HOME_TEAM_ID[n]))

view(teams)



# Let's count the number of winning games of each teams in his pool 



# Let's count the number of winning games of each team.

l<-levels(droplevels(PlayOff$HOME_TEAM_ID))
number_of_win_games<-c()
number_games_play<-c()
l

for(i in l){
  PlayOff%>% filter(HOME_TEAM_ID==i)->a
  PlayOff%>% filter(VISITOR_TEAM_ID==i)->c
  
  number_games_play<-append(number_games_play,nrow(c)+nrow(a))
  
  number_of_win_games<-append(number_of_win_games,sum(a$HOME_TEAM_WINS==1)+ sum(c$HOME_TEAM_WINS==0))
}

PlayOff<-data.frame(HOME_TEAM_ID= l,number_games_play=number_games_play,number_of_win_games=number_of_win_games,ratio=number_of_win_games/number_games_play)

PlayOff$HOME_TEAM_ID<-as.factor(as.character(PlayOff$HOME_TEAM_ID))
view(PlayOff)

######## prediction ######


# the following step will be used to predicted the 8 winners teams of each conference for play-off   

# extract data for games in different conference 

east_conference<- filter(PlayOff,HOME_TEAM_ID %in%c("Celtics","Nets","Knicks","76ers","Raptors","Bulls",
                                                    "Cavaliers" ,"Pistons","Pacers","Bucks",
                                                    "Heat" ,"Magic","Wizards","Hornets","Hawks" ))


west_conference<- filter(PlayOff,HOME_TEAM_ID %in% c('Pelicans',"Mavericks","Nuggets","Warriors",
                                                     "Rockets","Clippers","Lakers","Timberwolves",
                                                     "Suns","Trail Blazers", "Kings","Spurs","Thunder",  
                                                     "Jazz","Grizzlies"))


west_conference <-west_conference[order(-west_conference$number_of_win_games),]
east_conference <-east_conference[order(-east_conference$number_of_win_games),]

view(west_conference)
view(east_conference)



###### play-off ######

# Let's extract the teams that will go to the paly-off

west_conference<- west_conference[1:8,]
view(west_conference)

east_conference<- east_conference[1:8,]

