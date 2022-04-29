--SQL DATA EXPLORATION
-- using select and orderby
select *
from dbo.CovidDeaths
order by 3,4

select *
from dbo.CovidVaccinations
order by 3,4

--select required data

select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2

--Total cases vs total deaths
--using where and like

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from dbo.CovidDeaths
where location like 'india'
order by 1,2

--maximum values,null and group by

select location, max(total_cases) as highinfection, population, max((total_cases/population))*100 as totalcasepercentage
from dbo.CovidDeaths
group by location, population
order by totalcasepercentage desc

select location, max(cast(total_deaths as int)) as highdeathcount
from dbo.CovidDeaths
where continent is null
group by location
order by highdeathcount desc

select location, max(cast(total_deaths as int)) as highdeathcount
from dbo.CovidDeaths
where continent is not null
group by location
order by highdeathcount asc


select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
where continent is not null
order by 1,2

select location, date, total_cases, new_cases, total_deaths, population 
from dbo.CovidDeaths

--using Join

select *
from dbo.CovidDeaths
join dbo.CovidVaccinations
on dbo.CovidDeaths.location = dbo.CovidVaccinations.location
and dbo.CovidDeaths.date = dbo.CovidVaccinations.date
order by 1

select dbo.CovidDeaths.location, dbo.CovidDeaths.date, dbo.CovidDeaths.population, dbo.CovidVaccinations.people_vaccinated,
sum(cast(dbo.CovidVaccinations.people_vaccinated as bigint)) over (partition by dbo.CovidDeaths.location) as vaccinatedcounts
from dbo.CovidDeaths
join dbo.CovidVaccinations
on dbo.CovidDeaths.location = dbo.CovidVaccinations.location
and dbo.CovidDeaths.date = dbo.CovidVaccinations.date
order by 1

--Using CTE

with vacandpop (continent, location, date, population, people_vaccinated, vaccinatedcounts)
as
(
select dbo.CovidDeaths.continent, dbo.CovidDeaths.location, dbo.CovidDeaths.date, dbo.CovidDeaths.population, dbo.CovidVaccinations.people_vaccinated,
sum(cast(dbo.CovidVaccinations.people_vaccinated as bigint)) over (partition by dbo.CovidDeaths.location) as vaccinatedcounts
from dbo.CovidDeaths
join dbo.CovidVaccinations
on dbo.CovidDeaths.location = dbo.CovidVaccinations.location
and dbo.CovidDeaths.date = dbo.CovidVaccinations.date
--order by 1
)
select *, (vaccinatedcounts/population)*100 as vacpercentage
from vacandpop

--Temp table
drop table if exists #vaccinationpercent
create table #vaccinationpercent
(
continent nvarchar(255), location nvarchar(255), date datetime, population numeric, people_vaccinated numeric, vaccinatedcounts numeric)

insert into #vaccinationpercent
select dbo.CovidDeaths.continent, CovidDeaths.location, dbo.CovidDeaths.date, dbo.CovidDeaths.population, dbo.CovidVaccinations.people_vaccinated,
sum(cast(dbo.CovidVaccinations.people_vaccinated as bigint)) over (partition by dbo.CovidDeaths.location) as vaccinatedcounts
from dbo.CovidDeaths
join dbo.CovidVaccinations
on dbo.CovidDeaths.location = dbo.CovidVaccinations.location
and dbo.CovidDeaths.date = dbo.CovidVaccinations.date
--order by 1

select *, (vaccinatedcounts/population)*100 as vacpercentage
from #vaccinationpercent

--Creating view

create view vaccinationpercent as
select dbo.CovidDeaths.continent, CovidDeaths.location, dbo.CovidDeaths.date, dbo.CovidDeaths.population, dbo.CovidVaccinations.people_vaccinated,
sum(cast(dbo.CovidVaccinations.people_vaccinated as bigint)) over (partition by dbo.CovidDeaths.location) as vaccinatedcounts
from dbo.CovidDeaths
join dbo.CovidVaccinations
on dbo.CovidDeaths.location = dbo.CovidVaccinations.location
and dbo.CovidDeaths.date = dbo.CovidVaccinations.date
--order by 1

select *
from vaccinationpercent