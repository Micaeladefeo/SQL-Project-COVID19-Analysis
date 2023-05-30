Select * 
From CovidProject..CovidDeaths
Where continent is not null
Order by 3,4

--Data that I'm going to use
Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Order by 1,2

-- Total Cases VS Total Deaths (rate death cases per country)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location like '%Argentina%'
Order by 1,2

-- Total Cases VS Population (Percentage of Population that contracted Covid)
Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From CovidProject..CovidDeaths
Where location like '%Argentina%'
Order by 1,2

--Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected
From CovidProject..CovidDeaths
--Where location like '%Argentina%'
Group by population, location
Order by PercentagePopulationInfected desc

--Countries with Highest Death Count per Population
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Continents with Highest Death Count per population 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Total Population and Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as NumPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, NumPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as NumPeopleVaccinated
--, (NumPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (NumPeopleVaccinated/Population)*100
From PopvsVac


--View to store data for visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as NumPeopleVaccinated
--, (NumPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated