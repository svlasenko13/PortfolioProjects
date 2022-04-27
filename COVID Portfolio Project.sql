SELECT *
FROM PortfolioProject..['CovidDeaths (2)$']
WHERE continent <> ' '
ORDER BY location, date

SELECT *
FROM PortfolioProject..['CovidVaccinations (2)$']
ORDER BY location, date

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['CovidDeaths (2)$']
WHERE continent <> ' '
ORDER BY location, date

-- Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in Germany
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..['CovidDeaths (2)$']
WHERE Location LIKE 'Germany'
AND continent <> ' '
ORDER BY location, date

--Looking at Total Cases vs Population
SELECT Location, date, Population,	total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..['CovidDeaths (2)$']
WHERE Location LIKE 'Germany'
AND continent <> ' '
ORDER BY location, date

-- Looking at Countries with Highest Infection Rate compare to Population 
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..['CovidDeaths (2)$']
WHERE continent <> ' '
GROUP BY Population, Location
ORDER BY PercentPopulationInfected DESC

--Showing the countries with the highest Death Count per Population
SELECT Location, MAX(cast(total_deaths As int)) AS TotalDeathCount
FROM PortfolioProject..['CovidDeaths (2)$']
WHERE continent <> ' '
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths As int)) AS TotalDeathCount
FROM PortfolioProject..['CovidDeaths (2)$']
WHERE continent <> ' '
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS int)) AS Total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..['CovidDeaths (2)$']
WHERE continent <> ' '
GROUP BY date
ORDER BY date, Total_cases

SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS int)) AS Total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..['CovidDeaths (2)$']
WHERE continent <> ' '
ORDER BY Total_cases, Total_deaths

-- Looking at Total Population vs Vaccination
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..['CovidDeaths (2)$'] dea 
JOIN PortfolioProject..['CovidVaccinations (2)$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent <> ' '
)
SELECT*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
CREATE TABLE #PercentOfPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations float,
RollingPeopleVaccinated float
)
INSERT INTO #PercentOfPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..['CovidDeaths (2)$'] dea 
JOIN PortfolioProject..['CovidVaccinations (2)$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent <> ' '
SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentOfPopulationVaccinated


--Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..['CovidDeaths (2)$'] dea 
JOIN PortfolioProject..['CovidVaccinations (2)$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent <> ' '

SELECT* FROM PercentPopulationVaccinated