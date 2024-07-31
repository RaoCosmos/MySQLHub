/* F1 EXPLORATORY DATA ANALYSIS */

/* Driver Analysis */
-- Driver wins
SELECT R.DRIVERID, D.FORENAME, d.surname, D.NATIONALITY,
COUNT(POSITION) AS WINS
FROM RESULTS R JOIN DRIVERS D ON 
D.DRIVERID=R.DRIVERID
WHERE POSITION = 1 GROUP BY 1,2,3,4ORDER BY 5 DESC;

-- Nationality Wins
WITH WINS AS 
(
SELECT R.DRIVERID, D.FORENAME, D.NATIONALITY,
COUNT(POSITION) AS WINS
FROM RESULTS R JOIN DRIVERS D ON 
D.DRIVERID=R.DRIVERID
WHERE POSITION = 1 GROUP BY 1,2,3 ORDER BY 4 DESC )
SELECT WINS.NATIONALITY, SUM(WINS.WINS) WINS 
FROM WINS GROUP BY 1 ORDER BY 2 DESC;

-- Most pole positions
SELECT R.DRIVERID, D.FORENAME, D.NATIONALITY,
COUNT(R.GRID) POLES FROM RESULTS R 
JOIN DRIVERS D ON 
D.DRIVERID=R.DRIVERID
WHERE GRID = 1 GROUP BY 1,2,3 ORDER BY 4 DESC ;
 
-- Nationality with most poles
WITH WINS AS 
(
SELECT R.DRIVERID, D.FORENAME, D.NATIONALITY,
COUNT(GRID) AS WINS
FROM RESULTS R JOIN DRIVERS D ON 
D.DRIVERID=R.DRIVERID
WHERE GRID = 1 GROUP BY 1,2,3 ORDER BY 4 DESC )
SELECT WINS.NATIONALITY, SUM(WINS.WINS) WINS 
FROM WINS GROUP BY 1 ORDER BY 2 DESC;

-- Driver career points
SELECT R.DRIVERID, D.FORENAME, D.NATIONALITY,
SUM(R.POINTS) POLES FROM RESULTS R 
JOIN DRIVERS D ON 
D.DRIVERID=R.DRIVERID
GROUP BY 1,2,3 ORDER BY 4 DESC ;


/* CONSTRUCTOR ANALYSIS */

-- Constructor with most wins
SELECT CS.CONSTRUCTORID, C.NAME, COUNT(CS.POSITION) FROM
CONSTRUCTOR_STANDINGS CS JOIN CONSTRUCTORS C
ON C.CONSTRUCTORID=CS.CONSTRUCTORID WHERE CS.POSITION = 1
GROUP BY 1,2 ORDER BY 3 DESC;

-- Constructor with most points
SELECT CS.CONSTRUCTORID, C.NAME, SUM(CS.POINTS) FROM
CONSTRUCTOR_STANDINGS CS JOIN CONSTRUCTORS C
ON C.CONSTRUCTORID=CS.CONSTRUCTORID 
-- WHERE CS.POSITION = 1
GROUP BY 1,2 ORDER BY 3 DESC;

/* General Analysis */ 

-- how points were awarded for 1st place over the years 
select 
a.year as Year, 
max(b.points) as PointsForWin
from results b 
left join races a on a.raceId = b.raceId
where Year not in ('2014')
group by Year
order by Year;

-- number of races on the calendar over the years 
select year, count(round) from races 
group by year order by 1 asc ;


/* Pitstop analysis */

select r.name, round((avg(p.milliseconds)/1000),2)
from pitstops p join races r on
p.raceid=r.raceid 
group by 1 order by 2 desc  ;

-- are f1 cars going slow or fast these days?
-- hybrid era 2014 to 2021

select 
c.circuitname,
rc.year,
avg(fastestlapspeed) fastest
from results r join races rc on 
rc.raceid=r.raceid join circuits c on
c.circuitid=rc.circuitid
group by 1,2 order by 2 desc;

-- avg speed over the years in the hybrid era 
select 
rc.year,
avg(fastestlapspeed) fastest
from results r join races rc on 
rc.raceid=r.raceid group by 1 order by 2 desc;



-- lap time per year
select r.year, 
avg(l.laptime)
from laptimes l join races r on l.raceid=r.raceid
group by 1 order by 1 desc;

/* GOAT FERNANDO ALONSO F1 CAREER analysis */

create or replace view alonso_career as
(
select * ,
lag(points) over(order by season asc) points_from_previous_season,
rank() over(order by points desc) ranking,
sum(points) over() total_points_scored
from
	(select 
	-- ra.raceid, 
	re.driverid,
	d.forename first_name,
	d.surname last_name,
	d.number,
	d.code,
	to_char(d.dob,'DD-MonthYYYY') birthday,
	ra.year season,
	sum(re.points) points
	from results re 
	join races ra on re.raceid=ra.raceid
	join drivers d on d.driverid=re.driverid
	where re.driverid =4
	group by 1,2,3,4,5,6,7
	order by 2,4 asc) X

union

select * ,
lag(points) over(order by season asc) points_from_previous_season,
rank() over(order by points desc) rnk,
sum(points) over() total_points_scored
from
	(select 
	-- ra.raceid, 
	re.driverid,
	d.forename first_name,
	d.surname last_name,
	d.number,
	d.code,
	to_char(d.dob,'DD-MonthYYYY') birthday,
	ra.year season,
	sum(re.points) points
	from results re 
	join races ra on re.raceid=ra.raceid
	join drivers d on d.driverid=re.driverid
	where re.driverid = 1
	group by 1,2,3,4,5,6,7
	order by 2,4 asc) X

order by 2,7) ;

select * from alonso_career;
select * from drivers;


create or replace view FA_14 
as 
(select * ,
lag(points) over(order by season asc) points_from_previous_season,
rank() over(order by points desc) rnk,
round(cume_dist() over(order by points)::numeric*100,2) cumt_dist,
sum(points) over() total_points_scored
from
	(select 
	re.driverid,
	d.forename first_name,
	d.surname last_name,
	d.number, 
	d.code,
	to_char(d.dob,'DD-MonthYYYY') birthday,
	ra.year season,
	sum(re.points) points	
	from results re
	join races ra on re.raceid=ra.raceid join drivers d on d.driverid=re.driverid
	where re.driverid =4
	group by 1,2,3,4,5,6,7 order by 2,4 asc) X );

select * from fa_14;
-- Rules for create or replace view 
  -- cannot make alias view columns 
  -- cannot change column name
  -- cannot add new column before last
  -- cannot change datatype of the column
-- edit a view -- by using the create or replace
-- drop a view
-- alter a view -- to change the structure of the view 
-- update a view 

alter view fa_14 rename column driver_code to code;
alter view fa_14 rename column points to season_points;

drop view fa_14;

SELECT  ra.year, re.raceid,
re.driverid, re.ranks
FROM RESULTS re 
join races ra on re.raceid=ra.raceid
where driverid = 4;

-- fastest laps
-- multiple column multiple row sub-query
-- fernando alonsos fastest laps so far at 25- actual 23
with fastest as 
( 
select 
re1.raceid, re1.driverid, re1.fastestlaptime 
from results re1
where 
(re1.raceid, re1.fastestlaptime) in
	(select re.raceid, 
		min(re.fastestlaptime)
			from results re 
				group by 1 order by 2)
order by 1 ,2 )

select *, ra.name from fastest
join races ra on 
ra.raceid=fastest.raceid where driverid=4;

select fastest.driverid, count(fastestlaptime)
from fastest 
where fastest.driverid=4
group by 1 ;

-- Driver profile fernando alonso

with cte1 as 
(SELECT * FROM RESULTS
  where positionorder < 4 and driverid = 4),

 cte2 as 
(SELECT * FROM RESULTS
  where driverid = 4)
	
	select driverid, 
	count(position)
	from cte2 where 
	position=1
	group by 1 
union
	select driverid, 
	count(positionorder)
	from cte1
	group by 1
union
	select driverid, 
	sum(points) points
	from cte2
	group by 1 
union

select driverid, 
	avg(fastestlapspeed) avg_fastest_lap_speed 
	from cte2
	group by 1
union
	select driverid, 
	count(raceid) racestarts  
	from cte2
	group by 1;


select * from driver_standings;
select 
ra.year, driverid, ra.raceid, points, position, wins 
from driver_standings 
join races ra on 
ra.raceid=driver_standings.raceid
where driverid=4
order by 1 asc;

 

