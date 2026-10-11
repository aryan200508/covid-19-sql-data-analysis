select * from 
[Portfolio_Project ].dbo.CovidDeaths
order by 3,4


select * from 
[Portfolio_Project ].dbo.[CovidVaccinations.csv]
order by 3,4;

--  Death cases in covid19 

select location, date , total_cases  , new_cases , total_deaths , population
from [Portfolio_Project ].dbo.CovidDeaths
order by 1,2;

-- Death cases persantage in INDIA

select location, date , total_cases   , total_deaths ,	(total_deaths/total_cases)*100 as Death_percentage
from [Portfolio_Project ].dbo.CovidDeaths
where location like '%India%'
order by 1,2; 

-- Percantage of population got covid19

select location, date , population   , total_cases ,	(total_cases/population)*100 as infected_cases_percentage
from [Portfolio_Project ].dbo.CovidDeaths
where location like '%India%'
order by 1,2;

--  Maximum death cases in India

select * from [Portfolio_Project ].dbo.CovidDeaths
where total_deaths = (select max(total_deaths) from [Portfolio_Project ].dbo.CovidDeaths where location like '%India%')

-- Country With Maximum Infacted Cases per population

SELECT
    location,
    population,
    MAX(total_cases) AS total_cases,
    MAX((total_cases/population))*100
        AS max_cases_percentage_country
FROM [Portfolio_Project ].dbo.CovidDeaths
GROUP BY location, population
ORDER BY
    max_cases_percentage_country DESC;

    --countries with higest death count

SELECT
    location,
    MAX(total_deaths) AS total_death
FROM [Portfolio_Project ].dbo.CovidDeaths
GROUP BY location
ORDER BY
   total_death DESC;


    -- Country With Maximum Death_count per population


    SELECT
    location,
    population,
    MAX(total_deaths) AS total_deaths,
    MAX((total_deaths / population)) * 100
        AS max_death_percentage_country
FROM [Portfolio_Project ].dbo.CovidDeaths
GROUP BY location, population
ORDER BY
    max_death_percentage_country DESC;


    -- Total death  by continent

SELECT
    location,
    sum(cast(total_deaths as int)) AS total_death
FROM [Portfolio_Project ].dbo.CovidDeaths
where continent is  null
GROUP BY location
ORDER BY
   total_death DESC;

   -- Death Percentage accros the world 

   SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM [Portfolio_Project ].dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


---                      NOW WE ARE USING COVID VACCINATIONS
 
 select *  FROM [Portfolio_Project ].dbo.CovidDeaths dea
JOIN [Portfolio_Project ].dbo.[CovidVaccinations.csv] vac
    ON dea.location = vac.location

-- Looking at Total Population vs Vaccinations

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
FROM[Portfolio_Project ].dbo.CovidDeaths dea
JOIN [Portfolio_Project ].dbo.[CovidVaccinations.csv] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3




-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
        dea.Date) as RollingPeopleVaccinated
    -- (RollingPeopleVaccinated/population)*100
   FROM[Portfolio_Project ].dbo.CovidDeaths dea
JOIN [Portfolio_Project ].dbo.[CovidVaccinations.csv] vac
        On dea.location = vac.location
        and dea.date = vac.date
    where dea.continent is not null
    --order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
  FROM[Portfolio_Project ].dbo.CovidDeaths dea
JOIN [Portfolio_Project ].dbo.[CovidVaccinations.csv] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as percent_pop_vaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
 FROM[Portfolio_Project ].dbo.CovidDeaths dea
JOIN [Portfolio_Project ].dbo.[CovidVaccinations.csv] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from  PercentPopulationVaccinated