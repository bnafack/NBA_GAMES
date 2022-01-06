# NBA_GAMES
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
# Website refence to understand how NBA works

[1] How many games in an NBA season?  https://docs.google.com/document/d/1p8aflcoVM8KqBZnG_zpFXn0Ruds1RVIA-l32SuOVuBE/edit


[2] Playoffs NBA 2017 https://fr.wikipedia.org/wiki/Playoffs_NBA_2017

***
#References book 

[1] Machine Learning with R, the tidyverse, and mlr by Hefin I. Rhys [https://www.manning.com/books/machine-learning-with-r-the-tidyverse-and-mlr?query=machine%20learning%20with%20r]
 
