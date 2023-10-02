SELECT *
FROM [Portfolio Project]. [dbo].CovidDeaths$
Where continent is not NULL
ORder BY 3, 4


SELECT *
FROM [Portfolio Project]. [dbo].CovidVaccinations$
ORder BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].[dbo].CovidDeaths$
Order by 1, 2

 
--total deaths vs total cases

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM [Portfolio Project].[dbo].CovidDeaths$
Where location like 'Nigeria'
Order by 1, 2



--total cases vs population

SELECT location, date, population, total_cases, (total_cases/population) * 100 as PopulationPercentage
FROM [Portfolio Project].[dbo].CovidDeaths$
Where location like 'Nigeria'
Order by 1, 2



--countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  max (total_cases/population) * 100 as PopulationPercentageInfected
FROM [Portfolio Project].[dbo].CovidDeaths$
Where location like 'Nigeria'
Group by location, population
Order by PopulationPercentageInfected DEsc


--Coutries with highest death count per population
 
SELECT location, MAX (CAST (total_deaths as INT))  as TotalDeathCount
FROM [Portfolio Project].[dbo].CovidDeaths$
Where location like 'Nigeria'
Where continent is not NULL
Group by location
Order by TotalDeathCount DEsc


--Breaking down by Continent

SELECT location, MAX (CAST (total_deaths as INT))  as TotalDeathCount
FROM [Portfolio Project].[dbo].CovidDeaths$
Where location like 'Nigeria'
Where continent is NULL
Group by location
Order by TotalDeathCount DEsc


--Continent with the highest death count per population

SELECT location, MAX (CAST (total_deaths as INT))  as TotalDeathCount
FROM [Portfolio Project].[dbo].CovidDeaths$
Where location like 'Nigeria'
Where continent is not NULL
Group by location
Order by TotalDeathCount DEsc



--Global numbers

SELECT SUM (new_cases) as TotalCases, SUM ( CAST (new_deaths as int)) as TotalDeaths, SUM (CAST (new_deaths as int)) / sum (new_cases) *100 as DeathPercentage
FROM [Portfolio Project]. [dbo].CovidDeaths$
where continent is not null
group by date
order by 1,2 


--looking at total population vs vaccination

SElect Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM (CAST (Vac.new_vaccinations as int)) OVER (Partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population) *100
from [Portfolio Project]. [dbo].CovidDeaths$ Dea
JOIN [Portfolio Project].[dbo].CovidVaccinations$ Vac
   ON Dea.location = Vac.location
   and Dea.date = Vac.date
where Dea.continent is not null
order by 1,2


--using CTE

with Popvervac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SElect Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM (CAST (Vac.new_vaccinations as int)) OVER (Partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population) *100
from [Portfolio Project]. [dbo].CovidDeaths$ Dea
JOIN [Portfolio Project].[dbo].CovidVaccinations$ Vac
   ON Dea.location = Vac.location
   and Dea.date = Vac.date
where Dea.continent is not null
--order by 1,2
)
Select *, RollingPeopleVaccinated/population * 100
from Popvervac


--Temp table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent varchar (255),
location varchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SElect Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM (CAST (Vac.new_vaccinations as int)) OVER (Partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population) *100
from [Portfolio Project]. [dbo].CovidDeaths$ Dea
JOIN [Portfolio Project].[dbo].CovidVaccinations$ Vac
   ON Dea.location = Vac.location
   and Dea.date = Vac.date
where Dea.continent is not null
--order by 1,2

SELECT *, RollingPeopleVaccinated/population *100
from #PercentPopulationVaccinated



--Creating view to store data for later visualization

use [Portfolio Project]
go
Create view PercentPopulationVaccinated AS
SElect Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM (CAST (Vac.new_vaccinations as int)) OVER (Partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population) *100
from [Portfolio Project]. [dbo].CovidDeaths$ Dea
JOIN [Portfolio Project].[dbo].CovidVaccinations$ Vac
   ON Dea.location = Vac.location
   and Dea.date = Vac.date
where Dea.continent is not null
--order by 1,2


select *
from PercentPopulationVaccinated
