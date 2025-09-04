/* 
   Author: Sohan Rao
   Purpose: Exploratory Data Analysis of F1 dataset
*/

-- DRIVER PROFILE 
-- WHICH DRIVER HAS MOST WINS
SELECT 
      R.DRIVERID, 
      D.FORENAME, 
      D.NATIONALITY,
      COUNT(POSITION) AS WINS
FROM RESULTS R 
JOIN DRIVERS D 
ON D.DRIVERID=R.DRIVERID
WHERE POSITION = 1 
GROUP BY 1,2,3 ORDER BY 4 DESC;

-- WHICH NATIONALITY HAS MOST WINS 
WITH WINS AS 
(
SELECT R.DRIVERID, D.FORENAME, D.NATIONALITY,
COUNT(POSITION) AS WINS
FROM RESULTS R JOIN DRIVERS D ON 
D.DRIVERID=R.DRIVERID
WHERE POSITION = 1 GROUP BY 1,2,3 ORDER BY 4 DESC )
SELECT WINS.NATIONALITY, SUM(WINS.WINS) WINS 
FROM WINS GROUP BY 1 ORDER BY 2 DESC;

-- MOST POLE POSITIONS BY A DRIVER
SELECT * FROM RESULTS;

SELECT R.DRIVERID, D.FORENAME, D.NATIONALITY,
COUNT(R.GRID) POLES FROM RESULTS R 
JOIN DRIVERS D ON 
D.DRIVERID=R.DRIVERID
WHERE GRID = 1 GROUP BY 1,2,3 ORDER BY 4 DESC ;
 
-- WHICH NATIONALITY DRIVERS HAS BAGGED MOST POLES
WITH WINS AS 
(
 SELECT R.DRIVERID, D.FORENAME, D.NATIONALITY,
 COUNT(GRID) AS WINS
 FROM RESULTS R JOIN DRIVERS D ON D.DRIVERID=R.DRIVERID
 WHERE GRID = 1 
 GROUP BY 1,2,3 ORDER BY 4 DESC )

 SELECT 
      WINS.NATIONALITY, 
      SUM(WINS.WINS) WINS 
FROM WINS 
GROUP BY 1 
ORDER BY 2 DESC;

-- DRIVER WITH MOST CAREER POINTS
SELECT R.DRIVERID, D.FORENAME, D.NATIONALITY,
SUM(R.POINTS) POLES FROM RESULTS R 
JOIN DRIVERS D ON 
D.DRIVERID=R.DRIVERID
GROUP BY 1,2,3 ORDER BY 4 DESC ;


-- CONSTRUCTOR ANALYSIS
-- CONSTRUCTOR WITH MOST WINS
SELECT CS.CONSTRUCTORID, C.NAME, COUNT(CS.POSITION) FROM
CONSTRUCTOR_STANDINGS CS JOIN CONSTRUCTORS C
ON C.CONSTRUCTORID=CS.CONSTRUCTORID WHERE CS.POSITION = 1
GROUP BY 1,2 ORDER BY 3 DESC;

-- CONSTRUCTOR WITH MOST POINTS
SELECT CS.CONSTRUCTORID, C.NAME, SUM(CS.POINTS) FROM
CONSTRUCTOR_STANDINGS CS JOIN CONSTRUCTORS C
ON C.CONSTRUCTORID=CS.CONSTRUCTORID 
-- WHERE CS.POSITION = 1
GROUP BY 1,2 ORDER BY 3 DESC;

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


-- pitstop analysis

select * from pitstops;
select * from races;
select * from drivers;
select * from results; -- resultid, raceid, 
select * from circuits; -- circuitid, circuitname, location



select p.raceid, r.name, round((avg(p.milliseconds)/1000),2)
from pitstops p join races r on
p.raceid=r.raceid 
group by 1,2 order by 2 desc  ;

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

select * from laptimes;

-- lap time per year
select r.year, 
avg(l.laptime)
from laptimes l join races r on l.raceid=r.raceid
group by 1 order by 1 desc;



 

