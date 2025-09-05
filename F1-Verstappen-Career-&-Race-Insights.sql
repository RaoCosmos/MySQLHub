/* ===========================================================================
 FORMULA1 2024 SEASON 
 Author: Sohan Rao
 Dataset: F12024 from Kaggle
 Purpose: Exploring the 2024 season and Max Verstappens Career in 2024 
============================================================================*/

---- 2024 RACE RESULTS ---
--------------------------
SELECT RA.NAME GRANDPRIX, 
		RA.DATE DATE, 
		CONCAT(D.FORENAME,' ', D.SURNAME) AS WINNER, 
		C.NAME TEAM, 
		RE.LAPS, 
		RE.FASTESTLAPTIME TIME
FROM RESULTS RE 
JOIN RACES RA ON RE.RACEID=RA.RACEID
JOIN DRIVERS D ON D.DRIVERID=RE.DRIVERID
JOIN CONSTRUCTORS C ON C.CONSTRUCTORID=RE.CONSTRUCTORID
WHERE RE.POSITION = 1 AND RA.YEAR=2024
GROUP BY 1,2,3,4,5,6
ORDER BY 2 ASC;

---- 2024 FASTEST LAP RESULTS ----
----------------------------------
SELECT  GP.GRANDPRIX, 
		GP. DATE,
		GP.DRIVER,
		GP.TEAM,
		GP.TIME
		FROM
(SELECT RA.NAME GRANDPRIX, 
	   	RA.DATE DATE, 
	   	CONCAT(D.FORENAME,' ', D.SURNAME) driver, 
	   	C.NAME TEAM, 
	   	RE.FASTESTLAPTIME TIME,
	   	RANK() OVER (PARTITION BY RA.RACEID ORDER BY RE.FASTESTLAPTIME ASC) AS LAP_TIME
FROM RESULTS RE 
JOIN RACES RA ON RE.RACEID=RA.RACEID
JOIN DRIVERS D ON D.DRIVERID=RE.DRIVERID
JOIN CONSTRUCTORS C ON C.CONSTRUCTORID=RE.CONSTRUCTORID
WHERE RA.YEAR=2024 AND RE.FASTESTLAPTIME <> '00:00:00'
ORDER BY 2,5 ASC) GP
WHERE LAP_TIME =1
ORDER BY 2, 3 ASC;

---- MAX VERSTAPPEN CAREER SUMMARY ----
---------------------------------------
WITH season_points as 
(
    SELECT 
        re.driverid,
        ra.year as season,
        sum(re.points) as points
    FROM results re
    JOIN races ra ON re.raceid = ra.raceid
    GROUP BY re.driverid, ra.year
),

season_ranks as 
(
    SELECT 
        driverid,
        season,
        points,
        rank() over (partition by season order by points desc) as championship_position
    FROM season_points
)

SELECT 
    X.*,
    lag(X.points) over (partition by X.driverid order by X.season asc) as previous_season_points,
    rank() over (order by X.points desc) as ranking,
    sum(X.points) over () as total_career_points,
    case when sr.championship_position = 1 then 'World Champion' end as championship_status,
    sr.championship_position
FROM 
(
    SELECT 
        re.driverid,
        CONCAT(d.forename, d.surname) as driver_name, 
        d.number,
	    d.nationality,
        to_char(d.dob,'DD-MonthYYYY') as birthday,
        ra.year as season,
        sum(re.points) as points
    FROM results re 
    join races ra on re.raceid = ra.raceid
    join drivers d on d.driverid = re.driverid
    where re.driverid = 830
    group by 1,2,3,4,5,6
)X
JOIN season_ranks sr
ON sr.driverid = X.driverid
AND sr.season  = X.season
ORDER BY X.season;


