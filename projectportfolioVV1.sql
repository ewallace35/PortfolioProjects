select*
from portfolioproject..covidDeaths
where continent is not null
order by 3,4

--select*
--from portfolioproject..covidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..covidDeaths
where continent is not null
order by 1,2

--Total cases vs Total deaths
--Shows the likelyhood if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from portfolioproject..covidDeaths
where location like '%states%'
order by 1,2


--Total cases vs Population
--Shows the likelyhood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from portfolioproject..covidDeaths
where location like '%states%'
order by 1,2
--Total cases vs Population
--Shows percentage of population contacted covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationinfected
from portfolioproject..covidDeaths
--where location like '%states%'
order by 1,2

--Looking at countries with highest infection rates compared to population

select location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from portfolioproject..covidDeaths
--where location like '%states%'
Group by population, location
order by PercentPopulationInfected desc

--Countries with highest death count per population

select location, Max(cast (Total_deaths as int)) as TotalDeathCount
from portfolioproject..covidDeaths
where continent is not null
--where location like '%states%'
Group by  location
order by TotalDeathCount desc

--Broken Down By continent

select continent, Max(cast (Total_deaths as int)) as TotalDeathCount
from portfolioproject..covidDeaths
where continent is not null
--where location like '%states%'
Group by  continent
order by TotalDeathCount desc

-- Continents with Highest Death Count

select continent, Max(cast (Total_deaths as int)) as TotalDeathCount
from portfolioproject..covidDeaths
where continent is not null
--where location like '%states%'
Group by  continent
order by TotalDeathCount desc

--Global Numbers


Select  sum(new_cases),sum (cast(new_deaths as int)),sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
From PortfolioProject..covidDeaths 
--where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..covidDeaths dea
join portfolioproject..covidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3



--Use CT 

with PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..covidDeaths dea
join portfolioproject..covidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255), 
Location nvarchar (255), 
Date datetime, 
Population numeric,
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..covidDeaths dea
join portfolioproject..covidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select*, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated