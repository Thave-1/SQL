SELECT *
FROM CovidDeaths$
WHERE continent is not null
order by 3,4


--SELECT *
--FROM CovidVaccinations$
--order by 3,4

-- Useful Data

SELECT location, date, total_cases, new_cases, total_deaths, new_deaths, Population
FROM CovidDeaths$
order by 1,2
 
 -- Total Cases vs Total Deaths
 -- This shows the likelihood of dying if your contract covid in your country
SELECT location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE Location like '%States'
order by 2

--Total Cases vs Population
SELECT location, date, total_cases,Population,(total_cases/Population)*100 AS CasesPercentage
FROM CovidDeaths$
WHERE Location like '%States'
ORDER BY 2

-- The Highest Infection Rate compared to Population
SELECT location ,Population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population)* 100) as 
PercentagePopulationInfected
FROM CovidDeaths$
GROUP BY location, Population
ORDER BY PercentagePopulationInfected desc


-- Highest Death Count
SELECT location ,MAX(total_deaths) AS HighestDeathCount,MAX((total_cases/population)* 100) as PercentagePopulationInfected
FROM CovidDeaths$
GROUP BY location, Population
ORDER BY PercentagePopulationInfected desc

-- Countries with the highest death count per population
SELECT location ,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Continent with the highest death count per population
SELECT location ,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Global Numbers
SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent is not null
GROUP BY date
order by 1,2

--Now let's look at the COVID Vaccinations data and COVID Deaths data
-- What is the total amount of people that have been vaccinated?
-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopVSVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopVSVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
CREATE VIEW HighestDeathCount as
SELECT location ,MAX(total_deaths) AS HighestDeathCount,MAX((total_cases/population)* 100) as PercentagePopulationInfected
FROM CovidDeaths$
GROUP BY location, Population
--ORDER BY PercentagePopulationInfected desc











