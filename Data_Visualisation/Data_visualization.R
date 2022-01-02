library(tidyverse)
Team_ranking<-as_tibble(read.csv("data/ranking.csv"))
a<-nrow(Team_ranking)
names(Team_ranking)

Home_record<- str_split(Team_ranking$HOME_RECORD, "-")
road_record<- str_split(Team_ranking$ROAD_RECORD, "-")
Home_score<-vector()
Adverse_Home_score<-vector()
abroad_score<-vector()
Adverse_Road<-vector()

for(i in 1:a){
  Home_score <-append(Home_score,Home_record[[i]][1])
  Adverse_Home_score <-append(Adverse_Home_score,Home_record[[i]][2])
  abroad_score <-append(abroad_score,road_record[[i]][1])
  Adverse_Road <-append(Adverse_Road,road_record[[i]][2])
}

Home_score<-as.numeric(Home_score)
Adverse_Home_score<-as.numeric(Adverse_Home_score)
abroad_score<-as.numeric(abroad_score)
Adverse_Road<-as.numeric(Adverse_Road)

Team_ranking$TEAM <-as_factor(Team_ranking$TEAM)
levels(Team_ranking$TEAM)

team <-select(Team_ranking,G,W,L,W_PCT)
team$G <-as.numeric(team$G)
team$W <-as.numeric(team$W)
team$L <-as.numeric(team$L)
team$W_PCT <-as.numeric(team$W_PCT)

team<-mutate(team,SEASON_ID=Team_ranking$SEASON_ID,TEAM_names=Team_ranking$TEAM,Home_score,abroad_score,abroad_score,Adverse_Home_score,Adverse_Road)
names(team)
str(team)

# Let's filter the data for training and test 

train_data<- filter(team,!(SEASON_ID==22021 | SEASON_ID == 12021 ))
test_data <- filter(team,SEASON_ID==22021 | SEASON_ID == 12021)

view(test_data)
## save wraggling data as csv file 
write.csv2(team, "new_data/team.csv")
team<-data.frame(team)


