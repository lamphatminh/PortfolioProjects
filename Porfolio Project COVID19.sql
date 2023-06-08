SELECT * 
FROM [Porfolio Project COVID19]..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT * 
FROM [Porfolio Project COVID19]..Covid_Vaccination
WHERE continent IS NOT NULL
ORDER BY 3, 4

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Porfolio Project COVID19]..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at the total cases and total deaths
--Show the likelihood of dying in a specific country

SELECT location, date, total_cases, total_deaths, 
	(CAST(total_deaths AS float) / CAST(total_cases AS float)*100) AS Death_rate
FROM [Porfolio Project COVID19]..Covid_Deaths
WHERE location = 'Vietnam'
ORDER BY 1,2

--Looking at the total cases and population

SELECT location, date, population, total_cases,
	(CAST(total_cases AS float) / CAST(population AS float)*100) AS Infection_rate
FROM [Porfolio Project COVID19]..Covid_Deaths
WHERE location = 'Vietnam'
ORDER BY 1,2

--Looking at country with highest infection rate

WITH Infection_rate_table AS (
SELECT location, population, total_cases,
	(total_cases / population)*100 AS Infection_rate
FROM [Porfolio Project COVID19]..Covid_Deaths
)
SELECT TOP 1 location, Infection_rate 
FROM Infection_rate_table
WHERE Infection_rate IN (
		SELECT MAX(Infection_rate) 
		FROM Infection_rate_table
		)

--Looking at the list of countries order by Infection rate DESC
/*Important note: when data type of a column is not numeric data type (varchar, nvarchar, text...), 
use CAST to convert data type before using any calculation (MAX, MIN, AVG, Multiply, Divide...)*/

SELECT location, population,
		MAX(CAST(total_cases AS float)) AS highest_infection_count,
		MAX(total_cases / population)*100 AS highest_infection_rate
FROM [Porfolio Project COVID19]..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Highest_Infection_rate DESC

--Showing countries with highest Death count per Population

SELECT	location, population, 
		MAX(CAST(total_deaths AS float)) AS highest_death_count,
		MAX(total_deaths / population)*100 AS highest_death_rate
FROM [Porfolio Project COVID19]..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Highest_death_rate DESC

--Let's break things down by continent

SELECT	location, 
		MAX(CAST(total_deaths AS float)) AS highest_death_count
FROM [Porfolio Project COVID19]..Covid_Deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY highest_death_count DESC

--Global Death_Percentage

SELECT 
	SUM(CAST(new_cases AS float)) AS Total_Cases,
	SUM(new_deaths) AS Total_Deaths,
	SUM(new_deaths) / SUM(CAST(new_cases AS float)) * 100 AS Death_Percentage
FROM [Porfolio Project COVID19]..Covid_Deaths
WHERE continent IS NOT NULL


--Looking at Total Population and Vaccination

SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.date) AS cummulative_vaccinations
	/*
	(cummulative_vaccinations/population)*100, 
	we can not perform this calculation because the column: cummulative_vaccinations is invalid.
	So we have to use CTE or Temp Table
	*/
FROM [Porfolio Project COVID19]..Covid_Deaths dea
JOIN [Porfolio Project COVID19]..Covid_Vaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

	--CTE (Looking at Total Population and Vaccination)

WITH Total_Population_Vaccinations (Continent, Location, Date, Population, New_Vaccinations, Cummulative_Vaccinations)
AS 
(
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.date) AS cummulative_vaccinations
FROM [Porfolio Project COVID19]..Covid_Deaths dea
JOIN [Porfolio Project COVID19]..Covid_Vaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT
	location, population, 
	MAX(cummulative_vaccinations) AS Total_Vaccinations,
	CAST(MAX(cummulative_vaccinations) / population * 100 AS DECIMAL(10, 2)) AS Vaccination_Rate
FROM Total_Population_Vaccinations
GROUP BY  location, population
ORDER BY 1,2
	
	--Temp Table (Looking at Total Population and Vaccination)

DROP TABLE IF EXISTS #Total_Population_Vaccinations --USE DROP TABLE TO DELETE THE OLD TEMP TABLE
CREATE TABLE #Total_Population_Vaccinations --CREATE TEMP TABLE
(
	Continent nvarchar(255), 
	Location nvarchar(255), 
	Date date, 
	Population float, 
	New_Vaccinations int, 
	Cummulative_Vaccinations float
)
INSERT INTO #Total_Population_Vaccinations --INSERT VALUE INTO TEMP TABLE
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.date) AS cummulative_vaccinations
FROM [Porfolio Project COVID19]..Covid_Deaths dea
JOIN [Porfolio Project COVID19]..Covid_Vaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT --SELECT Population, Total_Vaccinations and Vaccination_Rate FROM TEMP TABLE
	Location, Population, 
	MAX(cummulative_vaccinations) AS Total_Vaccinations,
	CAST(MAX(cummulative_vaccinations) / population * 100 AS DECIMAL(10, 2)) AS Vaccination_Rate
FROM #Total_Population_Vaccinations 
GROUP BY  location, population
ORDER BY 1,2


--Creating View to store date for later visualizations

	--Create View Total_Population_Vaccinations
CREATE VIEW Total_Population_Vaccinations AS
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.date) AS cummulative_vaccinations
FROM [Porfolio Project COVID19]..Covid_Deaths dea
JOIN [Porfolio Project COVID19]..Covid_Vaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

	--Create View Percentage_Vaccination
CREATE VIEW Percentage_Vaccination AS
WITH Total_Population_Vaccinations (Continent, Location, Date, Population, New_Vaccinations, Cummulative_Vaccinations)
AS 
(
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.date) AS cummulative_vaccinations
FROM [Porfolio Project COVID19]..Covid_Deaths dea
JOIN [Porfolio Project COVID19]..Covid_Vaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT
	location, population, 
	MAX(cummulative_vaccinations) AS Total_Vaccinations,
	CAST(MAX(cummulative_vaccinations) / population * 100 AS DECIMAL(10, 2)) AS Vaccination_Rate
FROM Total_Population_Vaccinations
GROUP BY  location, population