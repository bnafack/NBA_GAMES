These data are those we get after data cleaning and wrangling. This will be used for model prediction. 

#  handle missing value 
 we had two possibilities
 
1- simply exclude cases with missing data from the analysis, this will end up with droping games
which will be a problem when predicted the season winner

2- apply an imputation mechanism to fill in the gaps

 Since we are predicted the winner teams, the missing value will affect the prediction, however, for 
 prediction of the team which will win the season, it is important to find the right missing value to be accurate

# in this case we used imputation method because each games is important 
