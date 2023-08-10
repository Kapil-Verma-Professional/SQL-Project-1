-- 1 got basic data to about covid around the world --
SELECT location,continent,date,population,total_cases,new_cases,total_deaths
from CovidDeaths$
order by location,date;


--1.1 get totalcases, population, totalcases/population 
SELECT sum(total_cases) as sum_cases,sum(population) as sum_population, (sum(total_cases)/sum(population))*100 as percent_covid
from CovidDeaths$


-- 2 got percentage of deaths in each country
SELECT location,continent,date,total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as percent_death
from CovidDeaths$
order by 1,6;


--3 find population vs the deaths for each country with highest death rate .
SELECT	location,continent,date,total_cases,new_cases,total_deaths, (total_cases/POPULATION)*100 as population_death
from CovidDeaths$
order by population_death desc;


-- 4 SEARCHING COUNTRY WITH HIGHEST CASES COMPARED TO THE POPULATIO

SELECT location,population,
MAX(total_cases)  as max_cases , 
MAX((total_cases/population))*100 as percent_death
FROM CovidDeaths$
GROUP BY  location,population
order by percent_death desc ;


--5 countries with highest total deaths
SELECT location,max(cast(total_deaths as int)) as max_deaths
from CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY max_deaths desc;


--6 search continent with highest infection rate
SELECT location,max(cast(total_deaths as int)) as max_deaths
from CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY max_deaths desc;


-- 7 global number of deaths per date

SELECT date,
sum(total_cases) as total_cases,
sum(cast (total_deaths as int)) as total_deaths,
sum(total_deaths/total_cases)*100 as percent_death_date
FROM CovidDeaths$
GROUP BY date
ORDER BY date desc;


--8 get data from covidvaccination table
SELECT * FROM portfolioproject.dbo.CovidVaccinations$;


-- 9 lets join two tables
SELECT * FROM CovidDeaths$ CD  JOIN CovidVaccinations$ CV 
ON CD.location = CV.location 
AND CD.date = cv.date;


--10  POPULATION VS VACCINATION
SELECT cv.location,CD.continent,CV.date,cd.population,cv.people_vaccinated , (cv.people_vaccinated/cd.population)*100 as totalpercent_vaccinated
FROM CovidDeaths$ CD  JOIN CovidVaccinations$ CV 
ON CD.location = CV.location 
AND CD.date = cv.date
WHERE CD.continent IS NOT NULL
ORDER BY totalpercent_vaccinated DESC;


--11  POPULATION VS VACCINATION along with sum of people vaccinated each day
SELECT cv.location,CD.continent,CV.date,cd.population,cv.people_vaccinated , SUM((cv.people_vaccinated/cd.population))*100 as totalpopulation_vaccinated,
SUM(CAST(CV.people_vaccinated AS INT)) AS SUM_VACCINATED
FROM CovidDeaths$ CD  JOIN CovidVaccinations$ CV 
ON CD.location = CV.location 
AND CD.date = cv.date
WHERE CD.continent IS NOT NULL
and cv. location like '%states%'
GROUP BY cv.location,CD.continent,CV.date,cd.population,cv.people_vaccinated 
ORDER BY totalpopulation_vaccinated DESC;


--11  POPULATION VS VACCINATION along with sum of people vaccinated each day
SELECT cv.location,CD.continent,CV.date,cd.population,cv.people_vaccinated , 
SUM(CAST(CV.people_vaccinated AS int)) Over ( partition BY cd.location, cd.date ORDER BY cd.location desc)AS SUM_VACCINATED 
FROM CovidDeaths$ CD  JOIN CovidVaccinations$ CV 
ON CD.location = CV.location 
AND CD.date = cv.date
WHERE CD.continent IS NOT NULL
and cv. location like '%states%'
ORDER BY SUM_VACCINATED DESC;


--12 POPULATION VS VACCINATION FOR EACH CONTINENT along with sum of people vaccinated each day
SELECT cv.location,CD.continent,CV.date,cd.population,cv.people_vaccinated ,
SUM((cv.people_vaccinated/cd.population))*100 as totalpopulation_vaccinated,
SUM(CAST(CV.people_vaccinated AS INT)) AS SUM_VACCINATED
FROM CovidDeaths$ CD  JOIN CovidVaccinations$ CV 
ON CD.location = CV.location 
AND CD.date = cv.date
WHERE CD.continent IS  NULL
GROUP BY cv.location,CD.continent,CV.date,cd.population,cv.people_vaccinated 
ORDER BY totalpopulation_vaccinated DESC;


-- 13 using cte
with pop_vac
(location ,continent ,date ,population ,people_vaccinated,SUM_VACCINATED) as 
(
SELECT cd.location ,cd.continent ,cd.date ,cd.population ,cv.people_vaccinated , 
SUM(CAST(CV.people_vaccinated AS int)) Over ( partition BY cd.date, cd.location ORDER BY cd.location, cd.date )AS SUM_VACCINATED
FROM CovidDeaths$ CD  JOIN CovidVaccinations$ CV 
ON CD.location = CV.location 
AND CD.date = cv.date
WHERE CD.continent IS not  NULL
)
SELECT *, (SUM_VACCINATED/population)*100 as totalpopulation_vaccinated 
FROM pop_vac
WHERE location LIKE '%states%'
ORDER BY totalpopulation_vaccinated DESC;



-- 14 using temp table
DROP TABLE IF EXISTS #PERCENT_PEOPLE_VACCINATED
CREATE TABLE #PERCENT_PEOPLE_VACCINATED(
location VARCHAR(255),
continent VARCHAR(255),
date DATETIME,
population NUMERIC,
people_vaccinated NUMERIC,
SUM_VACCINATED NUMERIC);

INSERT INTO #PERCENT_PEOPLE_VACCINATED
SELECT cd.location ,cd.continent ,cd.date ,cd.population ,cv.people_vaccinated , 
SUM(CAST(CV.people_vaccinated AS int)) Over ( partition BY cd.date, cd.location ORDER BY cd.location, cd.date )AS SUM_VACCINATED
FROM CovidDeaths$ CD  JOIN CovidVaccinations$ CV 
ON CD.location = CV.location 
AND CD.date = cv.date
WHERE CD.continent IS not  NULL;

SELECT *, (SUM_VACCINATED/population)*100 as totalpopulation_vaccinated 
FROM #PERCENT_PEOPLE_VACCINATED
WHERE location LIKE '%states%'
ORDER BY totalpopulation_vaccinated DESC;


-- 15 CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PERCENTPEOPLEVACCINATED  as
SELECT cd.location ,cd.continent ,cd.date ,cd.population ,cv.people_vaccinated , 
SUM(CAST(CV.people_vaccinated AS int)) Over ( partition BY cd.date, cd.location ORDER BY cd.location, cd.date )AS SUM_VACCINATED
FROM CovidDeaths$ CD  JOIN CovidVaccinations$ CV 
ON CD.location = CV.location 
AND CD.date = cv.date
WHERE CD.continent IS not  NULL

select* from PERCENTPEOPLEVACCINATED;
