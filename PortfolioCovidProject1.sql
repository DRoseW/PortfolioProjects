SELECT Location, Date, Total_cases, New_cases, Total_deaths, Population
FROM PortfolioProject1..CovidDeaths
Order By 1, 2;


--Процент смертности среди зараженных в Казахстане
SELECT Location, Date, Total_cases, Total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%Kazakhstan%'
Order By 1, 2;

--Соотношение числа зараженных к численности населения в Казахстане
SELECT Location, Date, Population, Total_cases, (Total_cases/population)*100 AS Got_Covid
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%Kazakhstan%'
Order By 1, 2;

--Cтраны с самым высоким уровнем заражения относительно населения
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
Group By location, population
Order By PercentPopulationInfected desc;

--Страны с самым высоким уровнем смертности
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
Group By location
Order By TotalDeathCount desc;

--Континенты с самым высоким уровнем смертности
SELECT Continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE Continent is not null
Group By Continent
Order By TotalDeathCount desc;

SELECT *
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
Order By 3,4;

-- Мировая статистика
SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE Continent is not null
--Group by date
Order By 1, 2;

-- Общее Население / Вакцинированные
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
Order By 1,2,3

--CTE
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order By 1,2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

-- TEMP TABLE

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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--Order By 1,2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Создание представления для дальнейшей визуализации
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order By 1,2,3

SELECT *
FROM PercentPopulationVaccinated