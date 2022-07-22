Select *
From CovidExploration..CovidDeaths
Where continent is not null
order by 3,4

Select *
From CovidExploration..CovidVaccinations
order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidExploration..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at total cases vs total deaths.
-- Shows likelihood of dying if you contract covid in the United States

Select Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
From CovidExploration..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at total cases vs population.
-- Shows the percentage of the population that got covid in the United States

Select Location, date, population, total_cases, (total_cases / population) * 100 as InfectedPercentageUSA
From CovidExploration..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at countries with the highest infection quantity compared to population.

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as CountryHighestInfection
From CovidExploration..CovidDeaths
Where continent is not null
Group by Location, population
order by CountryHighestInfection desc

-- Showing countries with the highest death quantity per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidExploration..CovidDeaths
Where continent is not null
Group by Location, population
order by TotalDeathCount desc

-- Showing continents with the highest death quantity per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidExploration..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers through time

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_cases) * 100 as DeathPercentage
From CovidExploration..CovidDeaths
where continent is not null
Group By date
order by 1,2

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_cases) * 100 as DeathPercentage
From CovidExploration..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total population vs number of people vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidExploration..CovidDeaths dea
Join CovidExploration..CovidVaccinations vac On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Use CTE

With PopvsVac(Continent, Location, Date, population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	From CovidExploration..CovidDeaths dea
	Join CovidExploration..CovidVaccinations vac On dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
)

Select *, (RollingPeopleVaccinated / Population) * 100
From PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidExploration..CovidDeaths dea
Join CovidExploration..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date

Select *, (RollingPeopleVaccinated / Population) * 100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidExploration..CovidDeaths dea
Join CovidExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated
