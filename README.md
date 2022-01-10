# NBA_GAMES

***
# Problem statement 

The National Basketball Association (NBA), founded in $1946$, is the highest level basketball league popular worldwide. Bookmakers, fans, and potential bidders are all interested in approximating the odds of a game in advance because of the financial assets involved. A wide variety of gambling companies are offering a vast amount of money on the conflict of one team beating another. It is common for participants to place their chances subjectively based on their personal team preferences without any scientific basis, resulting in extremely poor prediction accuracy. As a result, accurately predicting the outcome of NBA games based on the statistics of sports competition is a difficult problem that both the research community and the general public are interested in. Currently, analysts keep a massive amount of data on each team, player, coach, game, and matchup. Because of the amount of uncertainty in each game, any team has a good chance of winning.\\

NBA league consists of $30$ teams divided into the Eastern and Western conferences. Except in $2020$, when the season was cut short by the Covid pandemic, it has always had $82$ regular-season games, each team will play $41$ away games, and $41$ home games . The top eight teams from each conference (Eastern and Western) are chosen to compete for the championship during the playoffs. The rankings are determined by the number of teams winning games in the regular season. The teams then compete against each other, with the first-place team facing the eighth-place team, the second-place team facing the seventh place, etc. Each game will be a best-of-seven series, with teams rotating between home and away. This project aims to predict the winner of a basketball game, the ranking of NBA Play-off, the winner of each conference and the winner of the NBA. This prediction is a useful tool for placing confident bets. It's also interesting to learn which factors are most closely linked to team success. This kind of analysis can assist teams in winning more games.

***
##  handle missing value 
These data are those we get after data cleaning and wrangling. This will be used for model prediction. 


 we had two possibilities
 
1- simply exclude cases with missing data from the analysis, this will end up with droping games
which will be a problem when predicted the season winner

2- apply an imputation mechanism to fill in the gaps

 Since we want to predict a winner team, the missing value will affect the prediction, however, for 
 prediction of the team which will win the season, it is important to find the right missing value to be accurate

 in this case we used imputation method because each games is important, we got the data in the folder [new_data](https://github.com/B23579/NBA_GAMES/tree/main/new_data)
***
# Website refences to understand how NBA works

[1] How many games in an NBA season? (https://docs.google.com/document/d/1p8aflcoVM8KqBZnG_zpFXn0Ruds1RVIA-l32SuOVuBE/edit) 


[2] Playoffs NBA 2017 (https://fr.wikipedia.org/wiki/Playoffs_NBA_2017)

***

***
# References articles

***
# References book 

[1] Machine Learning with R, the tidyverse, and mlr by Hefin I. Rhys (ttps://www.manning.com/books/machine-learning-with-r-the-tidyverse-and-mlr?query=machine%20learning%20with%20r)
 
