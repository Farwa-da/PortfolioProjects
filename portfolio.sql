select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4


--data that we are going to use
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths and show percentage
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage, population
from CovidDeaths
where location = 'Pakistan' and continent is not null
order by 1,2

--looking at total cases vs population
--and showing percentage of population who got covid
select location, date, total_cases, population, (total_cases /population)*100 AS InfectedPercentage
from CovidDeaths
where location = 'Pakistan' and continent is not null
order by 1,2

--looking at countries with highest infection rate
--and highest infection rate compared to population (percentage)
select location, population, MAX(total_cases) AS HighestInfectionRate, MAX(total_cases/population)*100 AS HighestInfectePercentage
from CovidDeaths
where continent is not null
group by location, population
order by HighestInfectePercentage DESC

--looking at countries with highest death count
select location, MAX(cast(total_deaths as int)) AS HighestDeathCount
from CovidDeaths
where location = 'Africa'
group by location
order by HighestDeathCount desc

--looking at CONTINENTS with highest death count
--this is correct method according to data given in this excel file
select location, MAX(cast(total_deaths as int)) AS HighestDeathCount
from CovidDeaths
where continent is null
group by location
order by HighestDeathCount desc

--but here how we write for continent if the data given was in correct columns
select continent, MAX(cast(total_deaths as int)) AS HighestDeathCount
from CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc

--`total number of cases per day in whole world
select date, SUM(total_cases) AS totalcases, SUM(cast(total_deaths as int)) AS totaldeaths, SUM(new_cases) as newcases, SUM(cast(new_deaths as int)) as newdeaths,SUM(cast(total_deaths as int))/SUM(total_cases)*100 AS DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1

--total number of cases in whole world
select SUM(total_cases) AS totalcases, SUM(cast(total_deaths as int)) AS totaldeaths, SUM(new_cases) as newcases, SUM(cast(new_deaths as int)) as newdeaths,SUM(cast(total_deaths as int))/SUM(total_cases)*100 AS DeathPercentage
from CovidDeaths
where continent is not null


--total population vs new vaccinations
 select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, population, CovidVaccinations.new_vaccinations
 from CovidDeaths
 JOIN CovidVaccinations
 ON CovidDeaths.location = CovidVaccinations.location
 AND
 CovidDeaths.date = CovidVaccinations.date
 where CovidDeaths.continent is not null
 --where CovidDeaths.location = 'Canada'
 order by 2,3

 --total population vs new vaccinations and adding new vaccinations using SUM ie rolling total 
 select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, population, CovidVaccinations.new_vaccinations, 
	SUM(CAST(CovidVaccinations.new_vaccinations as int)) OVER (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingTotalOfNewVaccinations
	--(RollingTotalOfNewVaccinations/population)*100
 from CovidDeaths
	JOIN CovidVaccinations
		ON CovidDeaths.location = CovidVaccinations.location
			AND
			CovidDeaths.date = CovidVaccinations.date
 where CovidDeaths.continent is not null
 --where CovidDeaths.location = 'Pakistan'
 order by 2,3

 --now we want to find (RollingTotalOfNewVaccinations/population)*100
 --as it is not possible to use (RollingTotalOfNewVaccinations/population)*100 directly 
 --we will use CTEs
 WITH PopVsVac (Continent, Location, Date, Population, NewVaccinations, RollingTotalofNewVaccinations)
 AS
 (
  select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, population, CovidVaccinations.new_vaccinations, 
	SUM(CAST(CovidVaccinations.new_vaccinations as int)) OVER (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingTotalOfNewVaccinations
	--(RollingTotalOfNewVaccinations/population)*100
 from CovidDeaths
	JOIN CovidVaccinations
		ON CovidDeaths.location = CovidVaccinations.location
			AND
			CovidDeaths.date = CovidVaccinations.date
 where CovidDeaths.continent is not null
 --where CovidDeaths.location = 'Albania'
 --order by 2,3
 )
 select *, (RollingTotalOfNewVaccinations/population)*100
 from PopVsVac
 order by 2,3




 --TEMP TABLE
 drop table if exists #PercentPeopleVaccinated
 create table #PercentPeopleVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar (255),
 Date datetime,
 Population numeric,
 NewVaccinations numeric,
 RollingTotalofNewVaccinations numeric
 )

 insert into #PercentPeopleVaccinated
  select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, population, CovidVaccinations.new_vaccinations, 
	SUM(CAST(CovidVaccinations.new_vaccinations as int)) OVER (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingTotalOfNewVaccinations
	--(RollingTotalOfNewVaccinations/population)*100
 from CovidDeaths
	JOIN CovidVaccinations
		ON CovidDeaths.location = CovidVaccinations.location
			AND
			CovidDeaths.date = CovidVaccinations.date
 where CovidDeaths.continent is not null
 --where CovidDeaths.location = 'Albania'
 --order by 2,3

  select *, (RollingTotalOfNewVaccinations/population)*100
 from #PercentPeopleVaccinated
 order by 2,3


 --creating view to store data for later visualizations

 create view PercentPeopleVaccinated as
 select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, population, CovidVaccinations.new_vaccinations, 
	SUM(CAST(CovidVaccinations.new_vaccinations as int)) OVER (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingTotalOfNewVaccinations
	--(RollingTotalOfNewVaccinations/population)*100
 from PortfolioProject..CovidDeaths
	JOIN CovidVaccinations
		ON CovidDeaths.location = CovidVaccinations.location
			AND
			CovidDeaths.date = CovidVaccinations.date
 where CovidDeaths.continent is not null
 --where CovidDeaths.location = 'Albania'
 --order by 2,3

 select *
 from PercentPeopleVaccinated
