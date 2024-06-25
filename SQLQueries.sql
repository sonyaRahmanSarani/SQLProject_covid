CREATE database portfolioProject

SELECT * 
FROM CovidDeaths

SELECT * 
FROM CovidVaccines
order by 3,4

--select the data we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1,2


--looking at total cases vs total deaths
-- likelihood of dying if you get covid in bangladesh
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
where location like '%desh%'
order by 1,2


--looking at total cases vs the population
-- what percentage of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM CovidDeaths
where location like '%desh%'
order by 1,2


-- looking at countries with highest infection rate compared to population
SELECT Location, MAX(total_cases) as HighestInfectionCount, population, max((total_cases/population)*100) as PercentagePopulation
FROM CovidDeaths
--where location like '%desh%'
group by location, population
order by PercentagePopulation desc


-- showing countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM CovidDeaths
--where continent is null
--group by location
--order by TotalDeathCount desc



-- BREAK THINGS DOWN BY CONTINENTS
-- showing the continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
--Group By date 
order by 1,2


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac





Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.New_vaccinations
, SUM(CONVERT(int,vac.New_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select *
from PercentPopulationVaccinated