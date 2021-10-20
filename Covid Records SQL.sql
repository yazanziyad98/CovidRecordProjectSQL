SELECT *
FROM PortfolioProject..CovidDeaths

SELECT *
FROM PortfolioProject..CovidVaccinations
 
-- SELECT	Count(*)
--FROM CovidDeaths
 


  
-- SELECT	location, population, date, total_cases, new_cases,total_deaths,new_deaths
--FROM CovidDeaths
--WHERE location='Jordan'
--ORDER BY date


-- SELECT	location, population, date, total_cases, new_cases,total_deaths,new_deaths, (total_cases/population) as PopPercentageInfected, (total_deaths/total_cases) as InfectedDeathes
--FROM CovidDeaths
--WHERE location='Jordan'
--ORDER BY date



--Maximum New Cases In One Day in Jordan


--SELECT TOP 1 location, date, new_cases
--FROM CovidDeaths
--WHERE location='Jordan'
--ORDER BY 3 DESC
 
 
----Maximum New Deathes In One Day in Jordan


--SELECT TOP 1 location, date, new_deaths
--FROM CovidDeaths
--WHERE location='Jordan'
--ORDER BY 3 DESC


 --Maximum New Cases In One Day


SELECT TOP 1 location, date, new_cases
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3 DESC
 

 --Maximum New Deathes In One Day

SELECT TOP 1 location, date, new_deaths
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3 DESC




SELECT location,date,population,new_cases,total_cases, SUM(new_cases) OVER (
      PARTITION BY location 
      ORDER BY date,location
    ) 
FROM CovidDeaths
WHERE continent is not null


-- Join the CovidDeath and CovidVaccinations Tables
 

SELECT CovV.date,CovD.location,total_cases,new_cases,total_deaths,new_deaths,total_vaccinations,new_vaccinations
FROM CovidDeaths CovD
JOIN CovidVaccinations CovV
ON CovD.location = CovV.location
AND  CovD.date = CovV.date


-- The Country With The Highest Number of Vaccinations
 
SELECT TOP 1 CovD.location, MAX(CAST(people_fully_vaccinated AS float)) as MaxPeopleVaccinated
FROM CovidDeaths CovD
JOIN CovidVaccinations CovV
ON CovD.location = CovV.location
AND  CovD.date = CovV.date
WHERE CovD.continent is not null
GROUP BY CovD.location 
ORDER BY 2 desc
 

 -- The Countries Vaccinations Percentage

SELECT CovD.date,CovD.population,people_fully_vaccinated, CovD.location, (people_fully_vaccinated/CovD.population)*100 VaccinatedPercentage
FROM CovidDeaths CovD
JOIN CovidVaccinations CovV
ON CovD.location = CovV.location
AND  CovD.date = CovV.date
WHERE CovD.continent is not null and people_fully_vaccinated is not null 
ORDER BY 4,5 

 -- The Country With The Highest Percentage of Vaccinations

SELECT TOP 1 CovD.location, (MAX(people_fully_vaccinated/CovD.population))*100 VaccinatedPercentage
FROM CovidDeaths CovD
JOIN CovidVaccinations CovV
ON CovD.location = CovV.location
AND  CovD.date = CovV.date
WHERE CovD.continent is not null and people_fully_vaccinated is not null 
GROUP BY CovD.location
ORDER BY 2 DESC

-- Gibraltor is the territory with the most vaccinated percentage,
--it has more than 100% because Several thousand cross-border workers from Spain got vaccinated, too



-- First Vaccination Data in Canada

SELECT TOP 1 CovV.date,CovD.location,total_vaccinations
FROM CovidDeaths CovD
JOIN CovidVaccinations CovV
ON CovD.location = CovV.location
AND  CovD.date = CovV.date
WHERE CovV.location='Canada'  AND total_vaccinations is not null
ORDER BY CovD.location,CovV.date 





Select   CovD.continent, CovD.location, CovD.date, CovD.population, new_vaccinations
, SUM(CONVERT(float,new_vaccinations)) OVER (Partition by CovD.location Order by CovD.location, CovD.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths CovD
Join PortfolioProject..CovidVaccinations CovV 
	On CovD.location = CovV.location
	and CovD.date = CovV.date
order by 2,3


WITH VaccRecord as
(Select  CovD.location, CovD.date, CovD.population, new_vaccinations
, SUM(CONVERT(float,new_vaccinations)) OVER (Partition by CovD.location Order by CovD.location, CovD.date) as TotalPeopleVaccinated
From  CovidDeaths CovD
Join  CovidVaccinations CovV 
	On CovD.location = CovV.location
	and CovD.date = CovV.date
WHERE CovD.continent is not null
)
SELECT population,location,date, (TotalPeopleVaccinated/Population)*100 AS PopVaccPerc
FROM VaccRecord
WHERE  TotalPeopleVaccinated is not null and Population is not null 
ORDER BY 1,2



-- Create Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)




Insert into #PercentPopulationVaccinated
Select CovD.continent, CovD.location, CovD.date, CovD.population, CovV.new_vaccinations
, SUM(CONVERT(float,CovV.new_vaccinations)) OVER (Partition by CovD.Location Order by CovD.location, CovD.Date) as TotalPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths CovD
Join PortfolioProject..CovidVaccinations CovV
	On CovD.location = CovV.location
	and CovD.date = CovV.date
Select *, (TotalPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated