
--Displaying the data
select *
From DA_Portfolio_Projects..CovidDeaths
order by 3,4

--select *
--From DA_Portfolio_Projects..CovidVaccinations
--order by 3,4



--Selecting specific columns from the data
select location, date, total_cases, new_cases, total_deaths, population
From DA_Portfolio_Projects..CovidDeaths
order by 1,2



--Selecting India's Data
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From DA_Portfolio_Projects..CovidDeaths
where location = 'India'
order by 1,2


--Country's Day wise Infection Percentage
select location, date, population,total_cases, (total_cases/population)*100 as InfectPercentage
From DA_Portfolio_Projects..CovidDeaths
order by 1,2


--Country's Infection Percentage (Population vs Cases)
select location, population, MAX(total_cases) as HighestCase, Max((total_cases/population)*100) as InfectPercentage
From DA_Portfolio_Projects..CovidDeaths
Group by location, population
order by InfectPercentage desc


--India's Day wise Death Percentage (total death vs population)
select location, date, population, Max(total_deaths) as TotalDeaths, (Max(total_deaths)/population)*100 as DeathPercentage
From DA_Portfolio_Projects..CovidDeaths
where location = 'India'
Group by location,population, date
order by 1,2


--India's Day wise Deaths
select location,date, population, total_deaths
From DA_Portfolio_Projects..CovidDeaths
where location = 'India'
order by 1,2


--Total deaths in each location/country
select location, population, Max(Cast (total_deaths as int)) as Total_Deaths
From DA_Portfolio_Projects..CovidDeaths
where continent is not null
Group by location, population


--Total deaths in each location/country in decreasing order
select location, population, Max(Cast (total_deaths as int)) as Total_Deaths
From DA_Portfolio_Projects..CovidDeaths
where continent is not null
Group by location, population
order by Total_Deaths desc


--Total deaths in India
select location, Max(Cast (total_deaths as int))
From DA_Portfolio_Projects..CovidDeaths
where continent = 'Asia' and location = 'India'
Group by location


--Deaths in each continent
select location, Max(Cast (total_deaths as int)) as Deaths
From DA_Portfolio_Projects..CovidDeaths
where continent is null
Group by location


--Total cases, total deaths and Death Percentage of the world
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From DA_Portfolio_Projects..CovidDeaths
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations

--Rolling vaccination count
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as VaccinationCount
From DA_Portfolio_Projects..CovidDeaths dea
JOIN DA_Portfolio_Projects..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use of CTE
with PopvsVac (continent,location, date, population, new_vaccinations, VaccinationCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as VaccinationCount
From DA_Portfolio_Projects..CovidDeaths dea
JOIN DA_Portfolio_Projects..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (VaccinationCount/population)*100
from PopvsVac


--For Finding total vaccination percentage of India till date

--select Max((VaccinationCount/population)*100)
--from PopvsVac
--where location = 'India'


--Another way - Using Temp Table
--It can work even if we run the querry multiple times
Drop Table if exists PopulationVaccinatedPercentage
Create Table PopulationVaccinatedPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationCount numeric
)

insert into PopulationVaccinatedPercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as VaccinationCount
From DA_Portfolio_Projects..CovidDeaths dea
JOIN DA_Portfolio_Projects..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (VaccinationCount/population)*100
from PopulationVaccinatedPercentage



--Creating a view for future visualizations
Create view PopVaccinatedPercentageView as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as VaccinationCount
From DA_Portfolio_Projects..CovidDeaths dea
JOIN DA_Portfolio_Projects..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


--For looking at the data in the view
select * from PopVaccinatedPercentageView