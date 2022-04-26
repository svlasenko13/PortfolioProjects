Select *
From PortfolioProject..['CovidDeaths (2)$']
Where continent <> ' '
order by 3,4

--Select *
--From PortfolioProject..['CovidVaccinations (2)$']
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['CovidDeaths (2)$']
Where continent <> ' '
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in Germany
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..['CovidDeaths (2)$']
Where Location like 'Germany'
and continent <> ' '
order by 1,2

--Looking at Total Cases vs Population
Select Location, date, Population,	total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..['CovidDeaths (2)$']
Where Location like 'Germany'
and continent <> ' '
order by 1,2

-- Looking at Countries with Highest Infection Rate compare to Population 
Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..['CovidDeaths (2)$']
--Where Location like 'Germany'
Where continent <> ' '
Group by Population, Location
order by PercentPopulationInfected desc

--Showing the countries with the highest Death Count per Population
Select Location, MAX(cast(total_deaths As int)) AS TotalDeathCount
From PortfolioProject..['CovidDeaths (2)$']
--Where Location like 'Germany'
Where continent <> ' '
Group by Location
order by TotalDeathCount desc

--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths As int)) AS TotalDeathCount
From PortfolioProject..['CovidDeaths (2)$']
--Where Location like 'Germany'
Where continent <> ' '
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS
Select date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS int)) AS Total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..['CovidDeaths (2)$']
--Where Location like 'Germany'
Where continent <> ' '
Group by date
order by 1,2

Select SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS int)) AS Total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..['CovidDeaths (2)$']
--Where Location like 'Germany'
Where continent <> ' '
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccination
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100 
From PortfolioProject..['CovidDeaths (2)$'] dea 
Join PortfolioProject..['CovidVaccinations (2)$'] vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent <> ' '
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentOfPopulationVaccinated
Create Table #PercentOfPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations float,
RollingPeopleVaccinated float
)
Insert into #PercentOfPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100 
From PortfolioProject..['CovidDeaths (2)$'] dea 
Join PortfolioProject..['CovidVaccinations (2)$'] vac
On dea.location = vac.location
and dea.date = vac.date
--Where dea.continent <> ' '
--order by 2,3
Select*, (RollingPeopleVaccinated/Population)*100
From #PercentOfPopulationVaccinated


--Creating View to store data for later visualizations

Create View Percent_PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100 
From PortfolioProject..['CovidDeaths (2)$'] dea 
Join PortfolioProject..['CovidVaccinations (2)$'] vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent <> ' '
--order by 2,3

SELECT* FROM Percent_PopulationVaccinated