select * from profolioproject..coviddeath
order by 3,4

--select * from profolioproject..CovidVaccinations
--order by 3,4

--select data that we are going to be using
select location,date,total_cases, new_cases,total_deaths,population
from ProfolioProject..CovidDeath
order by 1,2

--looking at total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage, population
from ProfolioProject..CovidDeath
where location like '%states%' 
order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage, population
from ProfolioProject..CovidDeath
where location = 'china'
order by 1,2

--Shows what percentage of population got covid
select location,date,population, total_cases,(total_cases/population)*100 as CovidPercentage 
from ProfolioProject..CovidDeath
where location like '%states%' 
order by 1,2

select location,date,population, total_cases,(total_cases/population)*100 as CovidPercentage 
from ProfolioProject..CovidDeath
where location = 'china'
order by 1,2

--Looking at countries with highest infection rate compared to population
select location,population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected 
from ProfolioProject..CovidDeath
group by location,population
order by PercentPopulationInfected desc

--Showing the country with highest death count 
--total_deaths has a data type of varchar, need to cast into int
--remove group of countries by filter ones with continent value null
select location, max(cast(total_deaths as int)) as TotalDeathCount
from ProfolioProject..CovidDeath
where continent is not null
group by location
order by TotalDeathCount desc

--Let's break things down by continent
--Notice when continent is null, the location is actually "continent" in the table
select location, max(cast(total_deaths as int)) as TotalDeathCount
from ProfolioProject..CovidDeath
where continent is null
group by location
order by TotalDeathCount desc

--For the purpose of graph
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from ProfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc




--Showing continent with highest death count
select location, max(cast(total_deaths as int)) as TotalDeathCount
from ProfolioProject..CovidDeath
where continent is null
group by location
order by TotalDeathCount desc

--Global numbers

--Global Death Percent per day
select date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ProfolioProject..CovidDeath
where continent is not null 
--we want only the contries, not the one of continent
group by date
order by 1,2

--Global Death Percent total
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ProfolioProject..CovidDeath
where continent is not null 
--we want only the contries, not the one of continent
order by 1,2


--Covid Vaccination Table

--Looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--rolling sum of each country
from ProfolioProject..CovidDeath dea
join ProfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--Use CTE 

with population_vaccination (continent, location, date, population, new_vaccination, RollingPeopleVaccinated) --number of columns in CTE has to be the same as below
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--rolling sum of each country
from ProfolioProject..CovidDeath dea
join ProfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/population)*100
from population_vaccination

--Could also do temptable (skipped for now)

--Creating View to store data for later visualizations
create view population_vaccination as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--rolling sum of each country
from ProfolioProject..CovidDeath dea
join ProfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from population_vaccination