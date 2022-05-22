# Install packages
install.packages("tidyverse")
install.packages("dplyr")
install.packages("here")
install.packages("janitor")
install.packages("skimr")
install.packages("lubridate")
install.packages("RColorBrewer")
install.packages("plotly", repos = "http://cran.us.r-project.org")


library(tidyverse)
library(dplyr)
library(here)
library(janitor)
library(skimr)
library(ggplot2)
library(lubridate)
library(RColorBrewer)
library(plotly)

#Import datasets for analysis
dailyActivity <- read.csv("C:\sources\R_project\dailyActivity.csv")
View(dailyActivity_merged)
sleepDay_merged <- read.csv("C:\sources\R_project\sleepDay_merged.csv")
View(sleepDay_merged)
weightLogInfo_merged <- read.csv("C:\sources\R_project\weightLogInfo_merged.csv")
View(weightLogInfo_merged)

#Viewing the data frames
head(dailyActivity)
glimpse(dailyActivity)
colnames(dailyActivity)

head(sleepDay_merged)
glimpse(sleepDay_merged)
colnames(sleepDay_merged)

head(weightLogInfo_merged)
glimpse(weightLogInfo_merged)
colnames(weightLogInfo_merged)

#Converting data type from character to date time

dailyActivity$ActivityDateNew <- strptime(dailyActivity$ActivityDate, '%m/%d/%Y')
class(ActivityDate)

sleepDay_merged$SleepDayNew <- strptime(sleepDay_merged$SleepDay, '%m/%d/%Y %I:%M:%S %p')
class(SleepDay)

weightLogInfo_merged$DateNew <- strptime(weightLogInfo_merged$Date, '%m/%d/%Y %I:%M:%S %p')
class(Date)
View(weightLogInfo_merged)

#Add a column for the day of the week

dailyActivity$day_of_week <- format(as.Date(dailyActivity$ActivityDateNew), "%A")
dailyActivity$day_of_week <- ordered(dailyActivity$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
View(dailyActivity)

sleepDay_merged$day_of_week <- format(as.Date(sleepDay_merged$SleepDayNew), "%A")
sleepDay_merged$day_of_week <- ordered(sleepDay_merged$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

weightLogInfo_merged$day_of_week <- format(as.Date(weightLogInfo_merged$DateNew), "%A")
weightLogInfo_merged$day_of_week <- ordered(weightLogInfo_merged$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))


#ANALYZE
#Summarizing the data

n_distinct(dailyActivity$Id)
n_distinct(sleepDay_merged$Id)
n_distinct(weightLogInfo_merged$Id)

dailyActivity%>%
  select(TotalSteps,TotalDistance,VeryActiveMinutes,FairlyActiveMinutes,LightlyActiveMinutes,SedentaryMinutes,Calories)%>%
  summary()
  
sleepDay_merged%>%
  select(TotalMinutesAsleep,TotalTimeInBed)%>%
  summary()

weightLogInfo_merged%>%
  select(WeightKg,BMI)%>%
  summary()


#SHARE

#1
ggplot(data = dailyActivity, aes(x = VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes, y = Calories)) +
  geom_point(color = 'skyblue') + geom_smooth(method = lm, color = 'red')+ labs(title = "Daily Activity and Calories Burned")
#2
ggplot(data = dailyActivity, aes(x = TotalSteps, y = Calories)) + geom_point(color = 'skyblue') +
  geom_smooth(color = 'red') + labs(title = "Daily Steps and Calories Burned")
#3
ggplot(data = dailyActivity, aes(x = day_of_week, y = TotalSteps, fill = day_of_week)) +
  geom_bar(stat = 'summary', fun = max) + labs(title = "Daily Steps Per Day Of Week")

#4
dailyActivity$TotalMinutes <- sum(dailyActivity$VeryActiveMinutes,dailyActivity$FairlyActiveMinutes,dailyActivity$LightlyActiveMinutes,dailyActivity$SedentaryMinutes)
dailyActivity$TotalActiveMinutes <- sum(dailyActivity$VeryActiveMinutes)
dailyActivity$TotalFairlyActiveMinutes <- sum(dailyActivity$FairlyActiveMinutes)
dailyActivity$TotalLightlyActiveMinutes <- sum(dailyActivity$LightlyActiveMinutes)
dailyActivity$TotalSedentaryMinutes <- sum(dailyActivity$SedentaryMinutes)

dailyActivity$SedentaryPercentage <- dailyActivity$TotalSedentaryMinutes/dailyActivity$TotalMinutes*100
dailyActivity$ActivePercentage <- dailyActivity$TotalActiveMinutes/dailyActivity$TotalMinutes*100
dailyActivity$FairlyPercentage <- dailyActivity$TotalFairlyActiveMinutes/dailyActivity$TotalMinutes*100
dailyActivity$LightlyPercentage <- dailyActivity$TotalLightlyActiveMinutes/dailyActivity$TotalMinutes*100

#Creating a new Dataframe for percentage

ActiveMinutes <- c("Sedentary", "Lightly", "Fairly", "Very Active")
#Percent <- c(dailyActivity$SedentaryPercentage, dailyActivity$LightlyPercentage, dailyActivity$FairlyPercentage, dailyActivity$ActivePercentage)
Percent <- c(81.33, 15.82, 1.11, 1.73)
percentage_data <- data.frame(ActiveMinutes,Percent)
View(percentage_data)

plot_ly(data = percentage_data, labels = ~ActiveMinutes, values = ~Percent, type = "pie", color = I("black"), textposition = 'outside', textinfo = 'label+percent',
             marker = list(colors=colors, line= list(color= "black", width=1 )))%>%
               layout(title = "Percentage of Active Minutes")


pie(x=Percent, labels=Percent, col=brewer.pal(4,"Blues"), main="Percentage of Active Minutes")
legend("bottomleft", legend = ActiveMinutes, fill = brewer.pal(4,"Blues"))

#5
daily_activity_merged <- merge(dailyActivity, sleepDay_merged, by = 'Id')
View(daily_activity_merged)

ggsave(Sleep_Calories, file = "Daily_Minutes_Slept_And_Calories_Burned.png" )


install.packages("rmarkdown")