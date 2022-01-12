# NBA_GAMES

***
# Problem statement 

The National Basketball Association (NBA) league, founded in 1946, is the world's most popular basketball league. Since gambling companies have financial assets at stake, fans and potential bidders are all interested in estimating the odds of a game in advance. Many participants place their chances subjectively based on their personal team preferences without any scientific basis, resulting in extremely poor predictions. Thus, accurately predicting the outcome of NBA games based on the statistics of sports competition (games, teams, players, etc) is a difficult problem that both researchers and the general public are interested in tackling. Any team has a good chance of winning each game because of the high degree of uncertainty involved.

NBA league consists of 30 teams divided into the Eastern and Western conferences. Except in 2020, when the season was cut short by the Covid pandemic, it has always had 82 regular-season games, each team will play 41 away games, and 41 home games. The top eight teams from each conference (Eastern and Western) are chosen to compete for the championship during the playoffs. The rankings are determined by the number of teams winning games in the regular season. The teams then compete against each other, with the first-place team facing the eighth-place team, the second-place team facing the seventh place, etc. Each game will be a best-of-seven series, with teams rotating between home and away. The project aims to predict the winner of a basketball game, the ranking of the NBA Playoffs, the winner of each conference, as well as the winner of the NBA. Predicting basketball games makes it easier for bettors to make informed decisions. It is also interesting to see which factors are closely related to team success. Teams can gain an advantage in winning games through this type of analysis.

**

# Propose solution

## Logistic Regression Algorithm 

Logistic regression is a type of supervised learning method that predicts class membership. A model is trained to predict the probability (p) of new data falling into each class. Typically, new data are assigned to the class to which they are most likely to belong. Data are converted into log-odds (logits), which are then converted into odds and probabilities of belonging to the "positive" class. Cases are assigned to the positive class if their probability exceeds a predetermined threshold (0.5 by default).

## Decision Trees Algorithm




***
# Data description 

The dataset we used is from [Kaggle's](https://www.kaggle.com/nathanlauga/nba-games) datasets include five data frames

games.csv: all games from the 2004 season to the last update with the date, teams, and some details like a number of points, etc.

games_details.csv: details of games dataset, all statistics of players for a given game

players.csv: players details (name)

ranking.csv: ranking of NBA given a day (split into west and east on CONFERENCE column

teams.csv: all teams of NBA.

We used the games.csv data frame containing all NBA games statistics from 2004 through December 2021, for our ML prediction. The selected dataset contains the following variables:

Games_date: the date of the games

PTS home and away: Percent of Team's Points

AST home and away: Percent of Team's Assists

FT PCT home and away: Free Throw Percentage

REB home and away: Rebounds 

FG PCT home and away: field goal percentage 

FG3 PCT home and away:  3 Point Field Goal Percentage

HOME TEAMS_wing information:  win or lose. 

SEASON of the games

HOME and Visitor Teams names 


This dataset contains 25024 rows, 44 duplicated games, and 99 missing values for the following variables: PTS_home, FG_PCT_home, FT_PCT_home, FG3_PCT_home,REB_home , PTS_away, FG_PCT_away, FT_PCT_away, FG3_PCT_home,AST_away, REB_away. 

***
# Data cleaning (Remove duplicated games and Handle missing values) 

Duplicates games that can affect ranking predictions were removed. Two options are available for handling missing values: 
 
1- simply exclude cases with missing data from the analysis, this will end up with droping games
which will be a problem when predicted the season winner

2- apply an imputation mechanism to fill in the gaps

 Each game is important for ranking because we are attempting to predict a winning team for the season. Missing values will have an effect on the final ranking prediction from the regular season to the playoffs. As a result, locating the correct missing value is critical. I used the imputation method in this case because each game is important.
  I got the data in the folder [new_data](https://github.com/B23579/NBA_GAMES/tree/main/new_data).
  I then split the dataset into two-part, one to predict the winner of a game and the second for the playoff ranking predictions starting from 2016 to 2020. Using the caret R package, the first set was divided into 85 % training sets and 15 % testing sets. 
  
 # Implementation 
 All methods in this study were implemented in R. The mlr package was used to create a task, learner (specifying "classif.logreg" for logistic regression, "classif.rpart" for the decision tree, and "classif.svm" for SVM), and model. I then train and cross-validate the Logistic Regression model to predict how it will perform. I first define a resampling method with makeResampleDesc(), then apply stratified, 5-fold cross-validation to the wrapped learner 50 times. The cross-validation is then performed using resample().

I tuned the algorithm's hyperparameters for the decision tree using the following hyperparameter space: kernel (values = kernels), degree (lower = 1, upper = 3), cost (lower = 0.1, upper = 10), and gamma (lower = 0.1, upper = 10). Because the hyperparameter space is so large, I chose a random search over a grid search with 5 iterations. I also define a cross-validation strategy for tuning that uses 5-fold cross-validation. To accelerate things by using parallelMap and the parallel R library, I begin parallelization by calling parallelStartSocket() and setting the number of CPUs to the number of CPUs I have available (16). The tuneParams() function is then used to begin the tuning process. When it's finished, I stop parallelization and use the setHyperPars() function to create a learner with the tuned hyperparameters, after which I train a model. The tree is then cross-validated with hyperparameter tuning. The SVM model was created using the same method.

 

***
# Website refences to understand how NBA works

[1] How many games in an NBA season? (https://docs.google.com/document/d/1p8aflcoVM8KqBZnG_zpFXn0Ruds1RVIA-l32SuOVuBE/edit) 


[2] Playoffs NBA 2017 (https://fr.wikipedia.org/wiki/Playoffs_NBA_2017)

[3] [Using Machine Learning to Predict NBA Games] (https://community.wolfram.com/groups/-/m/t/1730466)

***
# Reference dataset

https://www.kaggle.com/nathanlauga/nba-games
***
# References articles

***
# References book 

[1] Machine Learning with R, the tidyverse, and mlr by Hefin I. Rhys (https://www.manning.com/books/machine-learning-with-r-the-tidyverse-and-mlr?query=machine%20learning%20with%20r)
 
