select *
from COVID..CovidDeaths$
ORDER by 3, 4
--select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths,population
from COVID..CovidDeaths$
ORDER by 1, 2

select *
from COVID..CovidVaccinations$
ORDER by 3, 4

--select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths,population
from COVID..CovidDeaths$
ORDER by 1, 2



-- looking at Total Cases vs Total Death
-- shows likelihood of dying if you
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from COVID..CovidDeaths$
where location like '%states%'
ORDER by 1, 2

-- looking at Total Cases vs Population
-- shows what percentage of population got covid
select location, date, population, total_deaths, (total_cases/population)*100 as DeathPercentage
from COVID..CovidDeaths$
--where location like '%states%'
ORDER by 1, 2



-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount,  max(total_cases/population)*100 as PercentPopulationInfected
from COVID..CovidDeaths$
--where location like '%states%'
Group by location, population
ORDER by PercentPopulationInfected desc

-- Showing Countries with Highest Deathcount per Population
select location, max(total_deaths) as TotalDeathCount
from COVID..CovidDeaths$
where continent is not null
Group by location, population
ORDER by TotalDeathCount desc

-- LET'S Break THINGS DOWN BY CONTINENT
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from COVID..CovidDeaths$
where continent is not null
Group by continent
ORDER by TotalDeathCount desc



select location, max(cast(total_deaths as int)) as TotalDeathCount
from COVID..CovidDeaths$
Group by location
ORDER by TotalDeathCount desc

Select *
from COVID..CovidDeaths$ dea
Join COVID..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORDER by 1, 2, 3

--Looking at Total POpulation vs VAccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from COVID..CovidDeaths$ dea
Join COVID..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- USE CTE
with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from COVID..CovidDeaths$ dea
Join COVID..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


TEMP TABLE
Drop Table if exists  # PercentPopulationVaccinated
Create Table  # PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from COVID..CovidDeaths$ dea
Join COVID..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from # PercentPopulationVaccinated