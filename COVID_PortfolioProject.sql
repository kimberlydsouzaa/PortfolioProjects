SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid
SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS float)/total_cases * 100 AS death_percentage 
FROM covid_deaths
WHERE location = 'India' AND
	continent IS NOT NULL

-- Looking at total cases vs population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, CAST(total_cases AS float)/population * 100 AS percentpopulationinfected
FROM covid_deaths
WHERE location = 'India' AND
	continent IS NOT NULL

-- Looking at countries with highest number of infections compared to population
SELECT location, population, MAX(total_cases) AS highest_infect_count, MAX(CAST(total_cases AS float)/population * 100) AS percentpopulationinfected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percentpopulationinfected DESC
--India being ranked 188th place with 3.2% being infected

-- Looking at countries with highest death count per population
SELECT location, MAX(total_deaths) AS highest_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC

--Breaking things down by continent
-- Looking at continents with highest death count
SELECT continent, MAX(total_deaths) AS highest_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC

--Global Numbers
SELECT date, SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, SUM(CAST(new_deaths AS FLOAT)/NULLIF(new_cases,0))*100 AS death_percentage 
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

--Looking at total population vs vaccinations --Using CTE
WITH pop_vs_vac(date, continent, location, population, new_vaccinations, rolling_people_vacc)
AS
(SELECT dea.date, dea.continent, dea.location, population, new_vaccinations,
		SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacc
FROM covid_deaths dea
INNER JOIN covid_vaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--ORDER BY 3,1
)
SELECT *, (rolling_people_vacc/population) * 100
FROM pop_vs_vac

--TEMP Table
-- DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
continent varchar(250),
location varchar(250),
date date,
population bigint,
new_vaccinations numeric,
rolling_people_vacc numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations,
		SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacc
FROM covid_deaths dea
INNER JOIN covid_vaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 3,1

SELECT *, (rolling_people_vacc/population) * 100
FROM PercentPopulationVaccinated

-- Creating View to store data for later visualizations
CREATE VIEW PercentPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations,
		SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacc
FROM covid_deaths dea
INNER JOIN covid_vaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--ORDER BY 3,1

SELECT *
FROM PercentPeopleVaccinated