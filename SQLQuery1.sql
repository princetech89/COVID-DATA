select * 
FROM PortfolioProject..CovidDeaths

--select * 
--FROM PortfolioProject..[COVID VACCINATIONS(CovidDeaths)]
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths

-- Looking at total cases
--shows Likelihood 

--looking totel cases vs population

Select Location, date, total_cases, new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where Location like '%states%'

Select Location, date, total_cases, Population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'

-- looking at countries with highest rate of Infaction Rate Compared to population.

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- total vacc vs total population

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..[COVID VACCINATIONS(CovidDeaths)] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

WITH PopvsVac
(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT))
            OVER (
                PARTITION BY dea.location
                ORDER BY dea.date
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..[COVID VACCINATIONS(CovidDeaths)] vac
        ON dea.location = vac.location
       AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *,
       (RollingPeopleVaccinated * 1.0 / Population) AS VaccinationRate
FROM PopvsVac;

--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT))
        OVER (
            PARTITION BY dea.location
            ORDER BY dea.date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..[COVID VACCINATIONS(CovidDeaths)] vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *,
       (RollingPeopleVaccinated * 1.0 / Population) AS VaccinationRate
FROM #PercentPopulationVaccinated;

