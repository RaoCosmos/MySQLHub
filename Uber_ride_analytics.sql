/* ==============================================================
   2024 Uber Rides Analytics
   Author: Sohan Rao
   KPIs:
   1.Demand Supply Balance
   2.Revenue Leakage 
   3.Revenue Summary - payment methods, vehicle type, 
   4.Ride Performance by Time of day 
   5.Customer Retention 
   6.Cancellation Pattern 
   7.Fleet Management
   8.City/Zone Operations 
   ============================================================= */

--------------------------------------------------------------------------------------
/* 
	1.Demand and Supply Balance 
	Metric: Analyze Booking Demand Fulfillment Ratio date and hour wise 
*/

select   
	  date as booking_date, 
	  date_trunc('hour', time) as booking_hour,
	  count(booking_id) as total_bookings, 
	  sum(case when booking_status = 'Completed' then 1 else 0 end) as completed_rides, 
	  sum(case when booking_status = 'Cancelled by Customer' 
		         OR booking_status = 'Cancelled by Driver' 
		         OR booking_status = 'Incomplete' 
		         OR booking_status = 'No Driver Found' then 1 else 0 end) as cancelled_rides,				
	  round((100* sum(case when booking_status = 'Completed' then 1 else 0 end)/ count(booking_id)),2) fulfillment
from  uber_rides 
group by rollup (1,2)
order by 1, 2;
-------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------
/* 
	2. Revenue leakage.
	caused by incomplete rides. 
	Aggregates incomplete rides by vehicle type, highlighting total counts and 
	associated revenue leakage.

	Business Context:
	Incomplete rides indicate lost revenue and operational inefficiency. Segmenting by 
	vehicle type helps pinpoint underperforming fleet categories for corrective action.
*/

select   
	  vehicle_type ride_type, 
	  count(incomplete_rides) AS incomplete_rides,
	  sum(booking_value) AS revenue_lost
from  uber_rides
where booking_status= 'Incomplete'
group by 1
order by 2 desc;

/* 
	2. Revenue leakage  
	caused by vehicle breakdowns by vehicle type.
	Identify vehicle types with the highest breakdown counts leading to 
	incomplete bookings over the year.

	Key Observations:
	1. Auto consistently has the highest number of breakdowns in most months except 
	   for June, September, and November.
	2. UberXL consistently has the lowest number of vehicle breakdowns all year
*/

select 
	  vehicle_type ride_type, 
	  date_part('month',date) as month_number,
	  initcap(to_char(date, 'month')) as month,
	  count(incomplete_rides) as breakdown_count,
	  sum(booking_value) as revenue_lost
from  uber_rides
where incomplete_rides_reason = 'Vehicle Breakdown'
group by 1,2,3
order by 2,4 DESC;
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
/* 
	3. Revenue Summary
    Revenue analysis by Payment Method 
*/

select 
	coalesce(payment_method,'Unknown'), 
	count(booking_id)total_bookings,
	sum(booking_value) total_revenue
from uber_rides
group by 1
order by 3 desc;

/* 
	3. Revenue Summary 
	Revenue by ride_type
*/

select 
	vehicle_type as ride_type, 
	sum(booking_value) as revenue
from uber_rides 
where booking_status = 'Completed'
group by 1 
order by 2 desc;

--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
/*  
	4. Ride Performance by Time of Day
*/
		  
select 
	'A. 6am_and_12pm' as TIME_OF_DAY, 
	count(*) as total_bookings,
	sum(case when booking_status='Completed' then 1 else 0 end) as completed_bookings,
	sum(CASE when booking_status = 'Cancelled by Customer' 
		       OR booking_status = 'Cancelled by Driver'
		       OR booking_status = 'Incomplete'
		       OR booking_status = 'No Driver Found' 
		then 1 else 0 end) as cancelled_bookings,
	 round((100*sum(case when booking_status = 'Completed' then 1 else 0 end)/ count(*)),2) fulfillment
from uber_rides 
where time >= '06:00:00' and time <= '12:00:00'
union
select 
	'B. 12pm_and_6pm' as TIME_OF_DAY, 
	count(*) as total_bookings,
	sum(case when booking_status='Completed' then 1 else 0 end) as completed_bookings,
	sum(CASE when booking_status = 'Cancelled by Customer' 
		       OR booking_status = 'Cancelled by Driver'
		       OR booking_status = 'Incomplete'
		       OR booking_status = 'No Driver Found' 
		then 1 else 0 end) as cancelled_bookings,
	 round((100* sum(case when booking_status = 'Completed' then 1 else 0 end)/ count(*)),2) fulfillment
from uber_rides 
where time >= '12:00:00' and time <= '18:00:00'
union
select 
	'C. 6pm_and_12am' as TIME_OF_DAY, 
	count(*) as total_bookings,
	sum(case when booking_status='Completed' then 1 else 0 end) as completed_bookings,
	sum(CASE when booking_status = 'Cancelled by Customer' 
		       OR booking_status = 'Cancelled by Driver'
		       OR booking_status = 'Incomplete'
		       OR booking_status = 'No Driver Found' 
		then 1 else 0 end) as cancelled_bookings,
	 round((100* sum(case when booking_status = 'Completed' then 1 else 0 end)/ count(*)),2) fulfillment
from uber_rides 
where time >= '18:00:00' and time <= '23:59:59'
order by TIME_OF_DAY;
-------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------
/* 
	5. Customer retention
	Who are one time users and Ocassional users

*/		  
SELECT 
    CASE 
        WHEN ride_count = 1 THEN 'One-time User'
        WHEN ride_count BETWEEN 2 AND 5 THEN 'Occasional User'
        ELSE 'Frequent User'
    END AS customer_segment,
    COUNT(*) AS customer_count
FROM (
    SELECT customer_id, COUNT(*) AS ride_count
    FROM uber_rides
    WHERE booking_status = 'Completed'
    GROUP BY customer_id
	order by 2 desc
) t
GROUP BY customer_segment;		  		  
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
/*  
	6. Cancellation Pattern Analysis
	Top reasons for driver and customer cancellations
*/	  

select 
	reason_for_cancelling_by_customer, 
	count(cancelled_rides_by_customer) 
from 
	uber_rides group by 1 		 
union
select 
	driver_cancellation_reason, 
	count(cancelled_rides_by_driver) 
from 
     uber_rides group by 1 order by 2 desc;
	
/*
   side by side comparision of driver vs customer cancellations by ride type
*/
SELECT  
	vehicle_type, 
	'cancelled_by_driver' as cancel_status,
	COUNT(cancelled_rides_by_driver) AS cancelled_count,
	avg(avg_vtat),
	SUM(booking_value) AS revenue_leakage
FROM uber_rides
WHERE booking_status = 'Cancelled by Driver'
GROUP BY 1
UNION ALL
SELECT  
	vehicle_type, 
	'cancelled_by_customer' as cancel_status,
	COUNT(cancelled_rides_by_customer) AS cancelled_count,
	avg(avg_vtat),
	SUM(booking_value) AS revenue_leakage
FROM uber_rides
WHERE booking_status = 'Cancelled by Customer'
GROUP BY 1
ORDER BY 1 asc;	    
------------------------------------------------------------------------------------		    

------------------------------------------------------------------------------------
/* 
	7. Fleet Management
	
*/
select 
	vehicle_type as ride_type, 
	sum(booking_value)/100 as total_revenue,
	sum(ride_distance) as total_distance_driven,
	round(avg(ride_distance),2) as avg_distance_driven
from uber_rides 
where booking_status ='Completed' 
OR booking_status = 'incomplete'
group by 1
order by 2 desc;

/* 

	Fleet Mix Optimization
*/

SELECT 
    vehicle_type,
    COUNT(*) AS total_rides,
    SUM(booking_value) AS total_revenue,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM uber_rides), 2) AS ride_share_percent,
    100.0 * SUM(booking_value) / (SELECT SUM(booking_value) FROM uber_rides) AS revenue_share_percent
FROM uber_rides
WHERE booking_status = 'Completed'
GROUP BY vehicle_type
ORDER BY revenue_share_percent DESC;
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------

/*
	8. City/Zone Operations
*/

SELECT 
    pickup_location,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) AS completed_rides,
    SUM(CASE WHEN booking_status LIKE 'Cancelled%' THEN 1 ELSE 0 END) AS cancelled_rides,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS fulfillment_rate
FROM uber_rides
GROUP BY pickup_location
ORDER BY cancelled_rides DESC
LIMIT 20;
---------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------
-- Load data into the Table 
create table if not exists uber_rides
(
    date date,
	time time,
	Booking_id varchar(20) not null,
	Booking_status varchar(25) not null,
	Customer_id varchar(20) not null,
	Vehicle_type varchar(20) not null,
	Pickup_location varchar(50) not null, 
	Drop_location varchar(100) not null, 
	Avg_VTAT numeric,
	Avg_CTAT numeric,
	Cancelled_rides_by_customer int, 
	Reason_for_cancelling_by_customer varchar(100),
	Cancelled_rides_by_driver int, 
	Driver_cancellation_reason varchar(100),
	Incomplete_rides int,
	Incomplete_rides_reason varchar(100),
	Booking_value money,
	Ride_distance numeric , 
	Driver_ratings numeric ,
	Customer_rating numeric ,
	Payment_method varchar(50)
);
