-- Checking if each dataset has 30 unique users 
SELECT COUNT(DISTINCT Id)
FROM dbo.dailyActivity_merged$

SELECT COUNT(DISTINCT Id)
FROM dbo.sleepDay_merged$

SELECT COUNT(DISTINCT Id)
FROM dbo.weightLogInfo_merged$

-- The weightLogInfo dataset has information about only 8 unique users
-- The sleepDay dataset has information about only 24 unique users

-- Aggregate Info About Steps, Weight And Minutes Asleep of All IDs

SELECT A.Id, SUM(A.TotalSteps) AS TotalSteps, MAX(W.WeightKg) AS WeightKG, SUM(S.TotalMinutesAsleep) AS MinutesAsleep
FROM dbo.dailyActivity_merged$ AS A
FULL OUTER JOIN dbo.weightLogInfo_merged$ AS W
ON A.Id=W.Id
FULL OUTER JOIN dbo.sleepDay_merged$ AS S
ON A.Id=S.Id
GROUP BY A.Id

--Standartize Date Format in dailyActivity database

SELECT 
	Id, CAST(ActivityDate AS date) AS ActivityDateNew
FROM dbo.dailyActivity_merged$
GROUP BY Id, ActivityDate

ALTER TABLE dbo.dailyActivity_merged$
ADD ActivityDateNew date

UPDATE dbo.dailyActivity_merged$
SET ActivityDateNew = CAST(ActivityDate AS date)

SELECT *
FROM dbo.dailyActivity_merged$

-- User's Activity

SELECT 
	ActivityDateNew,
	SUM(SedentaryMinutes) AS SedentaryMinutes,
	SUM(FairlyActiveMinutes) AS FairlyActiveMinutes,
	SUM(LightlyActiveMinutes) AS LightlyActiveMinutes,
	SUM(VeryActiveMinutes) AS VeryActiveMinutes,
	SUM(FairlyActiveMinutes) + SUM(LightlyActiveMinutes) + SUM(VeryActiveMinutes) AS ActiveMinutes
FROM dbo.dailyActivity_merged$
GROUP BY ActivityDateNew

-- Finding Total Amounf of Acvive Days, Active Minutes, Total Steps, Calories, Burnt Calories Pro Day 
SELECT 
	Id, 
	COUNT(DISTINCT ActivityDate) AS ActiveDays, 
	SUM(TotalSteps) AS TotalStepsSum, 
	SUM(FairlyActiveMinutes) + SUM(LightlyActiveMinutes) + SUM(VeryActiveMinutes) AS ActiveMinutes,
	SUM (Calories) AS TotalCalories,
	ROUND((SUM (Calories) / (COUNT(DISTINCT ActivityDate))),2) AS BurntCaloriesProDay
FROM dbo.dailyActivity_merged$
GROUP BY Id

--Standartize Date Format in WeightLogInfo database
SELECT 
	Id, 
	MAX(Date), 
	MAX(WeightKg), 
	MAX(BMI)
FROM dbo.weightLogInfo_merged$
GROUP BY Id

SELECT 
	CAST(Date AS date) AS WeighingDate
FROM dbo.weightLogInfo_merged$

ALTER TABLE dbo.weightLogInfo_merged$
ADD WeighingDate date

UPDATE dbo.weightLogInfo_merged$
SET WeighingDate = CAST(Date AS date)

-- As the data about weight and BMI was collected in short period of time (one month), it is useless to find a difference between first and last weighing
-- Finding Average Weight and BMI 
SELECT 
	Id, 
	MAX(WeighingDate) AS WeighingDate, 
	ROUND(AVG(WeightKg),1) AS WeightKg, 
	ROUND(AVG(BMI),1) AS BMI
FROM dbo.weightLogInfo_merged$
GROUP BY Id

-- Finding Relationship Between Activity and Weight/BMI
SELECT 
	activity.Id, 
	COUNT(DISTINCT ActivityDate) AS ActiveDays, 
	SUM(TotalSteps) AS TotalStepsSum, 
	SUM(FairlyActiveMinutes) + SUM(LightlyActiveMinutes) + SUM(VeryActiveMinutes) AS ActiveMinutes,
	SUM (Calories) AS TotalCalories, 
	ROUND(AVG(WeightKg),1) AS WeightKg, 
	ROUND(AVG(BMI),1) AS BMI
FROM dbo.dailyActivity_merged$ AS activity
INNER JOIN dbo.weightLogInfo_merged$ AS weight
ON activity.Id = weight.Id
GROUP BY activity.Id

--Standartize Date Format in sleepDay database
SELECT 
	Id, CAST(SleepDay AS date) AS SleepDate
FROM dbo.sleepDay_merged$
GROUP BY Id, SleepDay

ALTER TABLE dbo.sleepDay_merged$
ADD SleepDate date

UPDATE dbo.sleepDay_merged$
SET SleepDate = CAST(SleepDay AS date)

-- Finding The Amount Of Days When The Data About Sleeping Was Collected, And Total Amount Of Asleep Minutes
SELECT 
	Id, 
	COUNT(DISTINCT SleepDay) AS SleepDays, 
	SUM(TotalMinutesAsleep) AS MinutesAsleepSum
FROM dbo.sleepDay_merged$
GROUP BY Id

-- Finding Relationship Between Activity And Sleeping
SELECT 
	activity.ActivityDate,
	SUM(TotalSteps) AS TotalStepsSum, 
	SUM(FairlyActiveMinutes+LightlyActiveMinutes+VeryActiveMinutes) AS ActiveMinutes,
	SUM (Calories) AS TotalCalories, 
	SUM(TotalMinutesAsleep) AS MinutesAsleepSum
FROM dbo.dailyActivity_merged$ AS activity
INNER JOIN dbo.sleepDay_merged$ AS sleep
ON activity.Id = sleep.Id AND activity.ActivityDate = sleep.SleepDate
GROUP BY  activity.ActivityDate
