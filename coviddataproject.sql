select * 
from SQLProject..covidDeaths

order by 3,4

select * 
from SQLProject..covidVaccinations
order by 3,4


--Initially going to work on Covid death data so selecting that with required columns only.

select Location, date, total_cases, total_deaths,population
from SQLProject..covidDeaths
order by 1,2



--Checking total case v/s total deaths by respective country
-- shows percentage of death in India.
select Location, date, total_cases, cast(total_deaths as float) as total_death, (cast(total_deaths as float)/total_cases)*100 as percentage_death
from SQLProject..covidDeaths
where location like 'India'
order by 1,2

--looking at total cases vs polpulation
--in India pecentage of population got covid
select Location, date, total_cases, population, (total_cases/population)*100 as percentage_death
from SQLProject..covidDeaths
where location like 'India'
order by 1,2

--looking at contries with highest infection rates infection rates to covid
select Location, MAX(total_cases) as Infectioncount, population, (MAX(total_cases)/population)*100 as percentage_infection 
from SQLProject..covidDeaths
--where location like 'India'
Group by location, population
order by percentage_infection desc

--countries with highest death count 
select Location, MAX(cast(total_deaths as int)) as deathcount 
from SQLProject..covidDeaths
--where location like 'India'
where continent is not null
Group by location
order by deathcount desc  

--Define the things by continent
select location, MAX(cast(total_deaths as int)) as deathcount 
from SQLProject..covidDeaths
--where location like 'India'
where continent is null AND location not like '%income%'
Group by location
order by deathcount desc

--deathcount by income group
select location, MAX(cast(total_deaths as int)) as deathcount 
from SQLProject..covidDeaths
--where location like 'India'
where location like '%income%'
Group by location
order by deathcount desc


--Finding the global numbers

select date, sum(new_cases), sum(cast(new_deaths as int)),
sum(cast(new_deaths as int))/sum(new_cases)*100 as percentage_death
from SQLProject..covidDeaths
where continent is not null AND sum(new_cases) not like '0'
Group by date
order by 1,2


select *
from SQLProject..covidVaccinations

select * 
from SQLProject..covidDeaths


--joining Two tables
Select *
from SQLProject..covidDeaths deth
Join SQLProject..covidVaccinations vac
on deth.location = vac.location
and deth.date = vac.date

--Looking at total population vs Vaccination In India 
Select deth.continent, deth.location, deth.date, deth.population, vac.new_vaccinations
from SQLProject..covidDeaths deth
Join SQLProject..covidVaccinations vac
	on deth.location = vac.location
	and deth.date = vac.date
where deth.continent is not null and deth.location like '%India%'
order by 2,3

--Looking at total population vs Vaccination In India 
Select deth.continent, deth.location, deth.date, deth.population, vac.new_vaccinations, 
SUM(convert(float, vac.new_vaccinations)) OVER 
(Partition by deth.Location Order by deth.location, deth.date)
from SQLProject..covidDeaths deth
Join SQLProject..covidVaccinations vac
	on deth.location = vac.location
	and deth.date = vac.date
where deth.continent is not null 
order by 2,3


--Creating CTE in SQL
With PopvsVac(Continent, location, date, Population, new_Vaccination, Rollingpeoplevaccinated)
as
(
Select deth.continent, deth.location, deth.date, deth.population, vac.new_vaccinations, SUM(convert(float, vac.new_vaccinations)) OVER 
(Partition by deth.Location Order by deth.location, deth.date) as Rollingpeoplevaccinated
from SQLProject..covidDeaths deth
Join SQLProject..covidVaccinations vac
	on deth.location = vac.location
	and deth.date = vac.date
where deth.continent is not null 
--order by 2,3
)
select *, (Rollingpeoplevaccinated/Population)*100
from PopvsVac




--trying out temp table

DROP table if exists #PercentagePeopleVaccinated
Create Table #PercentagePeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_caccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePeopleVaccinated
Select deth.continent, deth.location, deth.date, deth.population, vac.new_vaccinations, SUM(convert(float, vac.new_vaccinations)) OVER 
(Partition by deth.Location Order by deth.location, deth.date) as Rollingpeoplevaccinated
from SQLProject..covidDeaths deth
Join SQLProject..covidVaccinations vac
	on deth.location = vac.location
	and deth.date = vac.date
--where deth.continent is not null 
--order by 2,3

select *, (Rollingpeoplevaccinated/Population)*100
from #PercentagePeopleVaccinated


--creating view for store data for later viz

Create View PercentPopVacc as
Select deth.continent, deth.location, deth.date, deth.population, vac.new_vaccinations, SUM(convert(float, vac.new_vaccinations)) OVER 
(Partition by deth.Location Order by deth.location, deth.date) as Rollingpeoplevaccinated
from SQLProject..covidDeaths deth
Join SQLProject..covidVaccinations vac
	on deth.location = vac.location
	and deth.date = vac.date
where deth.continent is not null 
--order by 2,3

