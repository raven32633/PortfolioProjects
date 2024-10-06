SELECT *
FROM `portfolioproject-437501.CovidDeaths.CovidDeaths2024`
Where continent is not null
order by 3,4

-- SELECT *
-- FROM `portfolioproject-437501.CovidDeaths.CovidVaccinations2024`
-- order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
From `portfolioproject-437501.CovidDeaths.CovidDeaths2024`
Where continent is not null
order by 1,2

--Looking at Total Cases vs. Total Deaths
--Shows likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From `portfolioproject-437501.CovidDeaths.CovidDeaths2024`
Where location like '%States%' and continent is not null
--Where continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population contracted Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From `portfolioproject-437501.CovidDeaths.CovidDeaths2024`
Where location like '%States%'
And continent is not null
order by 1,2

--Looking at coutries with highest infection rate compared to population

SELECT location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From `portfolioproject-437501.CovidDeaths.CovidDeaths2024`
--Where location like '%States%'
Where continent is not null
GROUP BY location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population

SELECT location, Max(total_deaths) as TotalDeathCount
From `portfolioproject-437501.CovidDeaths.CovidDeaths2024`
--Where location like '%States%'
Where continent is not null
GROUP BY location
order by TotalDeathCount desc

--Breaking Things Down By Continent
--Showing Continents with Highest Death Count per Population

SELECT continent, Max(total_deaths) as TotalDeathCount
From `portfolioproject-437501.CovidDeaths.CovidDeaths2024`
--Where location like '%States%'
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
From `portfolioproject-437501.CovidDeaths.CovidDeaths2024`
--Where location like '%States%'
Where continent is not null
Group by date
order by 1,2

SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
From `portfolioproject-437501.CovidDeaths.CovidDeaths2024`
--Where location like '%States%'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) Over (Partition By dea.location order by dea.location, dea.date) as CumulativePeopleVaccinated
--, (CumulativePeopleVaccinated/population)*100
From `portfolioproject-437501.CovidDeaths.CovidDeaths2024` dea
Join `portfolioproject-437501.CovidDeaths.CovidVaccinations2024` vac
  On  dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  order by 2,3


--USE CTE

With PopVsVac 
AS 
(
SELECT 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  sum(vac.new_vaccinations) Over (Partition By dea.location order by dea.location, dea.date) as CumulativePeopleVaccinated
--, (CumulativePeopleVaccinated/population)*100
From `portfolioproject-437501.CovidDeaths.CovidDeaths2024` dea
Join `portfolioproject-437501.CovidDeaths.CovidVaccinations2024` vac
  On  dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
 -- order by 2,3
  )
  Select *, (CumulativePeopleVaccinated/population)*100
  From 
  PopVsVac


--Temp Table

Create or Replace Table `portfolioproject-437501.CovidDeaths.PercentPopulationVaccinated`
(
Continent string,
location string,
date datetime,
population float64, 
new_vaccinations float64,
CumulativePeopleVaccinated float64
);

Insert Into `portfolioproject-437501.CovidDeaths.PercentPopulationVaccinated`
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as INT) 
) Over (Partition By dea.location order by dea.location, dea.date) as CumulativePeopleVaccinated
--, (CumulativePeopleVaccinated/population)*100
From `portfolioproject-437501.CovidDeaths.CovidDeaths2024` dea
Join `portfolioproject-437501.CovidDeaths.CovidVaccinations2024` vac
  On  dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null;
 -- order by 2,3

 Select *, (CumulativePeopleVaccinated/population)*100
  From 
  `portfolioproject-437501.CovidDeaths.PercentPopulationVaccinated`

  --Creating View to Store Data For Later Visualizations

Create View `portfolioproject-437501.CovidDeaths.PercentagePopulationVaccinated`as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as INT) 
) Over (Partition By dea.location order by dea.location, dea.date) as CumulativePeopleVaccinated
--, (CumulativePeopleVaccinated/population)*100
From `portfolioproject-437501.CovidDeaths.CovidDeaths2024` dea
Join `portfolioproject-437501.CovidDeaths.CovidVaccinations2024` vac
  On  dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  --order by 2,3

  Select *
  From portfolioproject-437501.CovidDeaths.PercentagePopulationVaccinated