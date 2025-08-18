-------- THE ILLUSTRIOUS CAREER OF FERNANDO ALONSO CAREER ---------
-------------------------------------------------------------------
---- FERNANDO IS THE OLDEST DRIVER TO BE STILL DRIVING IN F1 ------


with season_points as (
    select 
        re.driverid,
        ra.year as season,
        sum(re.points) as points
    from results re
    join races ra on re.raceid = ra.raceid
    group by re.driverid, ra.year
),
season_ranks as 
(
    select 
        driverid,
        season,
        points,
        rank() over (partition by season order by points desc) as championship_position
    from season_points
)
select 
    X.*,
    lag(X.points) over (partition by X.driverid order by X.season asc) as previous_season_points,
    rank() over (order by X.points desc) as ranking,
    sum(X.points) over () as total_career_points,
    case when sr.championship_position = 1 then 'World Champion' end as championship_status,
    sr.championship_position
from (
    select 
        re.driverid,
        CONCAT(d.forename, d.surname) as driver_name, 
        d.number,
	    d.nationality,
        to_char(d.dob,'DD-MonthYYYY') as birthday,
        ra.year as season,
        sum(re.points) as points
    from results re 
    join races ra on re.raceid = ra.raceid
    join drivers d on d.driverid = re.driverid
    where re.driverid = 4
    group by 1,2,3,4,5,6
)X

join season_ranks sr
  on sr.driverid = X.driverid
 and sr.season   = X.season
order by X.season;



------ FERNANDO ALONSO VS LEWIS HAMILTON COMPARISION -----
----------------------------------------------------------

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
