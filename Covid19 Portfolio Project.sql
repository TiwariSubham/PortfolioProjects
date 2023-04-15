-- Selecting data from where we are getting started

select * 
FROM CovidVaccinations
ORDER BY 3,4


--1.write a query to select location,date,total cases,new cases,total death and population from covid death table

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location,date;

--2.write a query to get percentage of death per location.

SELECT location,date,total_cases,total_deaths,round((cast(total_deaths as float)/total_cases)*100,2)as death_percentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location,date;	

-- 3. write a query to get total cases out of population who were infected by Covid

SELECT location,date,total_cases,population,round((total_cases/population)*100,1) as population_case
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY population_case DESC;

-- 4.write a query to get country having highest infection rate comparing to population due to covid

SELECT location,population,max(total_cases) as higest_infection_count,max((total_cases/population)*100) as HighestInfection_case
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
group BY location,population
ORDER BY HighestInfection_case DESC;

-- 5.write a query to get country with highest death count per population

SELECT location,max(cast(total_deaths as int)) as maximum_death
FROM dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY maximum_death DESC;

-- 6.write a query to get continent with highest death count 

SELECT continent,max(cast(total_deaths as int)) as maximum_death
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL OR continent IS NULL
GROUP BY continent
ORDER BY maximum_death DESC;

--7. write a query to get total new cases received on a single day during covid

SELECT date,max(new_cases) as "maximum cases"
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date 

-- 8.write a query to show continent with highest death count per population 

SELECT continent,max(cast(total_deaths as int)) as maximum_death,MAX(cast(total_deaths as int))/population*100 as death_per_population
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent,population
ORDER BY maximum_death DESC;

--9.write a query to show death percentage across globe based on new cases

SELECT continent,SUM(new_cases)as new_case,SUM(CAST(new_deaths as int))as new_death,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY death_percentage;

--10.write a query to display total vacination per population
--Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CAST(v.new_vaccinations as int)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) as rolling_vaccinated
FROM dbo.CovidDeaths d INNER JOIN dbo.CovidVaccinations v
ON d.location = v.location
AND d.date = v.date 
WHERE d.continent IS NOT NULL
ORDER BY location,date;

-- 11.write a query to find sum of rolling vaccination from new vaccinations.Order by location and then date.
--Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac(continent,location,date,population,new_vaccinations,rolling_people_vaccination)
as
(
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
,SUM(CONVERT(int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) as rolling_people_vaccination
--,(rolling_people_vaccination/population)*100 
FROM dbo.CovidDeaths d INNER JOIN dbo.CovidVaccinations v
ON d.location=v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3 
)
SELECT *,(rolling_people_vaccination/population)*100 as rolling_vaccination_Percentage
FROM PopvsVac
