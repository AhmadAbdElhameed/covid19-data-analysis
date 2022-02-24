SELECT continent,location,date,total_cases,new_cases,total_cases,population 
FROM New_Project..covid_death
WHERE continent is not null
ORDER BY 5


-- Find the total cases vs total death
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM New_Project..covid_death
WHERE location like '%States%'
order by DeathPercentage DESC


-- Locking at Total Cases VS Population
-- Shows what percentage of population got Covid
select location,date,population,total_cases,(total_deaths/population)*100 as DeathPercentage
FROM New_Project..covid_death
WHERE location like '%States%'
order by DeathPercentage DESC

-- Looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentagePopulationInfected
FROM New_Project..covid_death
--WHERE location like '%States%'
GROUP BY population,location
order by PercentagePopulationInfected DESC


--Showing Countries with highest death count
select location,max(cast(total_deaths as int)) as TotalDeathCount
FROM New_Project..covid_death
--WHERE location like '%States%'
WHERE location is not null
GROUP BY location
order by TotalDeathCount DESC

-- continent with high death count
select continent,max(cast(total_deaths as int)) as TotalDeathCount
FROM New_Project..covid_death
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC


-- GLOBAL Numbers
select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM New_Project..covid_death
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Total cases in the world
-- GLOBAL Numbers
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM New_Project..covid_death
WHERE continent is not null
ORDER BY 1,2

-- show the increasing of infection in countries ( Vaccine VS Population)
SELECT dea.continent , dea.location ,dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM New_Project..[owid-covid-data] vac
JOIN New_Project..covid_death dea
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



-- Using CTE
-- show the increasing of infection in countries ( Vaccine VS Population)
with PopvsVac(continent , location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent , dea.location ,dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM New_Project..[owid-covid-data] vac
JOIN New_Project..covid_death dea
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(RollingPeopleVaccinated/population) * 100 as VacPercentage
FROM PopvsVac


-- Create Table
DROP TABLE IF exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentagePopulationVaccinated
SELECT dea.continent , dea.location ,dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM New_Project..[owid-covid-data] vac
JOIN New_Project..covid_death dea
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null

SELECT *,(RollingPeopleVaccinated/population) * 100 
FROM #PercentagePopulationVaccinated


--Create view for Visualization
CREATE VIEW PercentagePopulationVaccinated as 
SELECT dea.continent , dea.location ,dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM New_Project..[owid-covid-data] vac
JOIN New_Project..covid_death dea
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null



SELECT * FROM PercentagePopulationVaccinated