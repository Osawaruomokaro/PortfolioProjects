

SELECT *
FROM PortfolioProject..CovidDeath
WHERE continent is not Null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases, total_deaths, population
FROM PortfolioProject..CovidDeath
WHERE continent is not Null
ORDER BY 1,2


--Total cases vs Total Deaths in Italy
--Showing the likelihood of dying if you contact Covid-19 in Italy
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE location LIKE '%italy%'
and continent is not Null
ORDER BY 1,2


--Showing population that got infected with covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeath
WHERE location LIKE '%italy%'
and continent is not Null
ORDER BY 1,2


--Countries with the highest population cases

SELECT location, population, MAX(total_cases) AS HighestCases, (MAX(total_cases)/population)*100 AS PercentageHighestInfectedCountries
FROM PortfolioProject..CovidDeath
WHERE continent is not Null
GROUP BY location, population
ORDER BY PercentageHighestInfectedCountries desc


--Countries with the highests

SELECT location, MAX(cast(total_deaths AS INT)) AS HighestDeaths
FROM PortfolioProject..CovidDeath
WHERE continent is not Null
GROUP BY location
ORDER BY HighestDeaths desc


--Continent with the highest deaths

SELECT location, MAX(cast(total_deaths AS INT)) AS HighestDeaths
FROM PortfolioProject..CovidDeath
WHERE continent is not Null
GROUP BY location
ORDER BY HighestDeaths desc


--Global cases and deaths

SELECT date, SUM(new_cases) AS TotalNewCases, SUM(cast(new_deaths AS INT)) AS TotalNewDeath
,(SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS PercentageGlobalCases
FROM PortfolioProject..CovidDeath
WHERE continent is not Null
GROUP BY date
ORDER BY 1,2

--Looking at TotalPopulation vs Vaccinations


SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CONVERT(INT,vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS
RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath death
INNER JOIN PortfolioProject..CovidVaccination vacc
    ON death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not NULL
ORDER BY 2,3



WITH PopvsVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CONVERT(INT,vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS
RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath death
INNER JOIN PortfolioProject..CovidVaccination vacc
    ON death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageVaccinatedPopulation
FROM PopvsVacc


----Temp table
--DROP table if exists #percentagepopulations
--create table #percentagepopulations
--(
--continent nvarchar(255),
--location nvarchar(255),
--date datetime,
--population numeric,
--new_vaccinations numeric,
--RollingPeopleVaccinated numeric
--)
--insert into #percentagepopulations 
--SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
--SUM(CONVERT(INT,vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS
--RollingPeopleVaccinated
--FROM PortfolioProject..CovidDeath death
--INNER JOIN PortfolioProject..CovidVaccination vacc
--    ON death.location = vacc.location
--	and death.date = vacc.date
----WHERE death.continent is not NULL

--select *, (RollingPeopleVaccinated/population)*100
--from #percentagepopulations

--Create View

CREATE VIEW PopvsVacc 
AS
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CONVERT(INT,vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS
RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath death
INNER JOIN PortfolioProject..CovidVaccination vacc
    ON death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not NULL

select *
from PopvsVacc





