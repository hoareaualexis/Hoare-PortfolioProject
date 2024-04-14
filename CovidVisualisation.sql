
SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
--Where continent is not null
Order By 1,2

--Looking at Total Cases vs Total Deaths
--Montre le nombre  de décès par rapport au nombre de cas 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentOfDEath
From CovidDeaths
Where total_cases is not null and total_deaths is not null and Location like '%states%'
Order By PercentOfDEath desc


--Regard sur le nombre de décès par rapport à la population totale

Select Location, date, Population, total_deaths, (total_deaths/Population)*100 as PercentOfDEath
From CovidDeaths
Where total_cases is not null and total_deaths is not null and Location like '%states%'
Order By PercentOfDEath desc

--Regard sur le nombre d'infection par pays

Select Location, Population, MAX(total_cases) as HighestInfection,
MAX((total_cases/Population)*100) as PercentPopulationInfected
From CovidDeaths
Where total_cases is not null and population is not null
Group By Location, Population
Order By PercentPopulationInfected desc


--Afficher le nombre de décès maximale ar continent

Select continent,
MAX(total_deaths) as PercentageDeathPerPopulation
From CovidDeaths
Where continent is not null
Group By continent
Order By PercentageDeathPerPopulation desc

--Affichons le nombre de cas d'infection le plus élévé pour les pays d'Afrique

Select Location, MAX(cast(total_cases as int)) as HighestRecordedInfection, 
MAX(convert(int, total_deaths)) as HighestRecordedDeath
From CovidDeaths
Where continent = 'Africa'
Group By Location
Order By 3 desc

--Just a checker

Select location, date, total_cases, new_cases, SUM(new_cases) as NewCasesSUM,
new_deaths, SUM(convert(int, new_deaths)) over(Partition By location order By date) as NewDeathSUM
From CovidDeaths
Where location = 'Cameroon'
Group by location, date, total_cases, new_cases, new_deaths
order by date desc

-- Operation de jointure

Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(convert(int, dea.new_vaccinations)) 
over (Partition By dea.location order by dea.location, dea.date desc) as VacSUM
--(vacSUM/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.location = 'cameroon'
Order By 1,2,3

-- Cas d'utilisation des CTEs

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, VacSUM )
as
(
	Select dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations, SUM(convert(int, dea.new_vaccinations)) 
	over (Partition By dea.location order by dea.location, dea.date desc) as VacSUM
	--(vacSUM/population)*100
	From CovidDeaths dea
	Join CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null and dea.location = 'cameroon'
	--Order By 1,2,3
)

--Create View SecondVisualisation
Select *, (vacSUM/population)*100 as PercentVacvsPop 
From PopvsVac

-- Temp Table

Create Table #PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date DATETIME,
	Population Numeric,
	New_vaccinations integer,
	VacSUM integer,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(convert(int, dea.new_vaccinations)) 
over (Partition By dea.location order by dea.location, dea.date desc) as VacSUM
--(vacSUM/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.location = 'cameroon'
--Order By 1,2,3


Select *, (vacSUM/population)*100 as PercentVacPop From #PercentPopulationVaccinated

-- Create view to store data for later vizualisation

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(convert(int, dea.new_vaccinations)) 
over (Partition By dea.location order by dea.location, dea.date desc) as VacSUM
--(vacSUM/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.location = 'cameroon'
--Order By 1,2,3

Select * From PercentPopulationVaccinated
