-- showing the data from the covid deaths file
SELECT * FROM Covid..CovidDeaths
WHERE continent is not null
order by 3,4

-- showing the data from the covid vaccinations
--SELECT * FROM Covid..CovidVaccinations
--order by 3,4

-- select the data that we are going to be using 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid..CovidDeaths
order by 1,2

-- looking at total cases vs total deahs
-- shows the likelyhood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeaths
FROM Covid..CovidDeaths
WHERE location like '%India%'
order by 1,2

-- looking at Total Cases vs Population
-- shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentageCases
FROM Covid..CovidDeaths
WHERE location like '%India%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentageHighestCount
FROM Covid..CovidDeaths
--WHERE location like '%India%'
GROUP BY location, population
order by 4 desc



-- looking at countries with highest death rate compared to population
SELECT location,  MAX(cast(total_deaths as int)) as HighestDeathsCount
FROM Covid..CovidDeaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY location
order by HighestDeathsCount desc

-- lets break thing down by continent


-- showing continent with the highest death count per population

SELECT continent,  MAX(cast(total_deaths as int)) as HighestDeathsCount
FROM Covid..CovidDeaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY continent
order by HighestDeathsCount desc

-- Global numbers 
-- sheet 1 for tablaues

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases) * 100   as PercentageDeaths
FROM Covid..CovidDeaths
--WHERE location like '%India%'
WHERE continent is not null
--group by date
order by 1,2

-- sheet 2 for tab
-- looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- creating view to store data for later visualizations

Create View PercentedPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *
FROM PercentedPopulationVaccinated