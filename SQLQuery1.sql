											-- "SQL Project on Data Exploration of Indian Census" --

-- Display table from dataset1

select * from project.dbo.data1;


-- Display table from dataset2

select * from project.dbo.data2;


-- Show number of rows into both the dataset's

select count(*) from project..data1
select count(*) from project..data2


-- Show dataset for only 2 states (here for jharkhand and bihar only)

select * from project..data1 where state in ('Jharkhand' ,'Bihar')


-- What is the total population of India according to given data.

select sum(population) as Population from project..data2


-- Avg growth for every state

select state,avg(growth)*100 avg_growth from project..data1 group by state;


-- Avg sex ratio for every state

select state,round(avg(sex_ratio),0) avg_sex_ratio from project..data1 group by state order by avg_sex_ratio desc;


-- avg literacy rate for every state
 
select state,round(avg(literacy),0) avg_literacy_ratio from project..data1 
group by state having round(avg(literacy),0)>90 order by avg_literacy_ratio desc ;


-- Display Top 3 state showing highest growth ratio

select state,avg(growth)*100 avg_growth from project..data1 group by state order by avg_growth desc limit 3;


-- Display Bottom 3 state showing lowest sex ratio

select top 3 state,round(avg(sex_ratio),0) avg_sex_ratio from project..data1 group by state order by avg_sex_ratio asc;


-- Top and Bottom 3 states in literacy rate

drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstate float

  )

insert into #topstates
select state,round(avg(literacy),0) avg_literacy_ratio from project..data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstate desc;

drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstate float

  )

insert into #bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio from project..data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;

-- Show use of union opertor

select * from (
select top 3 * from #topstates order by #topstates.topstate desc) a

union

select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b;


-- States starting with letter a

select distinct state from project..data1 where lower(state) like 'a%' or lower(state) like 'b%'

select distinct state from project..data1 where lower(state) like 'a%' and lower(state) like '%m'


-- Total number of males and females

select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from project..data1 a inner join project..data2 b on a.district=b.district ) c) d
group by d.state;


-- Total literacy rate

select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from project..data1 a 
inner join project..data2 b on a.district=b.district) d) c
group by c.state


-- Population in previous census

select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from project..data1 a inner join project..data2 b on a.district=b.district) d) e
group by e.state)m


-- Population vs area

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from (

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from project..data1 a inner join project..data2 b on a.district=b.district) d) e
group by e.state)m) n) q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from project..data2)z) r on q.keyy=r.keyy)g


-- window 

output top 3 districts from each state with highest literacy rate

select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from project..data1) a

where a.rnk in (1,2,3) order by state