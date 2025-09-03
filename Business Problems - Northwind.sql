/*
	Author: SOHAN RAO
	Dataset: Northwind Sales Data
	Purpose: Analyze and answer complex business problems using advanced SQL functions
*/

-- customers who have ordered something 
-- using a right join 
SELECT 
DISTINCT o.customerid
FROM customers c 
RIGHT JOIN orders o ON c.customerid=o.customerid;

-- Using a correlated subquery 
SELECT c.customerid
FROM customers c
WHERE EXISTS (SELECT o.customerid FROM orders o WHERE o.customerid=c.customerid);

-- High Freight charge problems last year
-- LAST 12 MONTHS DATA- USE INTERVAL FUNCTION
-- FIRST FIND THE LATEST ORDERDATE (USE MAX)
-- USE INTERVAL WHICH WILL TAKE BACK THE DATE 12 MONTHS BEHIND
-- THEN SELECT ORDERDATE THAT IS > THAN THAT INTERVAL DATE 
SELECT  
	o.shipcountry,
	o.orderdate,
	ceil(avg(o.freight)) avg_freight
FROM orders o 
GROUP BY 1,2
HAVING o.orderdate > (SELECT max(orderdate) FROM orders) - interval '12 months' 
ORDER BY 3 DESC
LIMIT 3;

	SELECT 
		max(orderdate) - interval '12 months'
	FROM orders;

-- customers with no orders
-- using subquery single columns multiple row 
-- customers with no orders for empid 4
SELECT 
	c.customerid FROM customers c 
WHERE c.customerid not in (SELECT o.customerid FROM orders o WHERE o.employeeid=4);

-- using correlated sub query 
SELECT 
	c.customerid
FROM customers c 
WHERE c.customerid NOT IN (SELECT o.customerid FROM orders o WHERE o.customerid=c.customerid AND o.employeeid=4);

-- first order in each country
SELECT * 
	FROM 
		(SELECT 
				o.shipcountry,
				o.customerid,
				o.orderid, 
				o.orderdate,
				rank() over(partition by shipcountry order by orderdate asc) rn
		 FROM orders o 
		 ORDER BY 1) X
		 WHERE x.rn=1;

-- Analyze Customers with high orders in 2016
-- using a CTE
WITH total_sum AS 
  ( 
	SELECT 
 	c.customerid, 
	c.companyname,
	o.orderid,
	o.orderdate,
	(od.unitprice*od.quantity ) AS total_sum,
	od.discount,
    (od.unitprice*od.quantity)-
	( (od.unitprice*od.quantity )*od.discount) after_discount
	FROM orders o
	JOIN order_details od ON od.orderid=o.orderid
	JOIN customers c ON c.customerid=o.customerid
	ORDER BY 1
  )
SELECT  
	total_sum.customerid,
	total_sum.companyname,
	total_sum.orderid,
	total_sum.orderdate,
	sum(after_discount) AS total_value_after_discount
FROM total_sum 
GROUP BY 1,2,3,4
HAVING sum(after_discount) >= 10000 AND orderdate >= '1997-01-01' AND orderdate <= '1998-01-01'
ORDER BY 4 DESC;

-- Analyze High end customers with discount
WITH total_sum AS
(
	SELECT  
	c.customerid, 
	c.companyname,
	o.orderid,
	o.orderdate,
	(od.unitprice*od.quantity ) AS total_sum,
	od.discount,
	(od.unitprice*od.quantity)-
	((od.unitprice*od.quantity )*od.discount) after_discount
FROM orders o
JOIN order_details od ON od.orderid=o.orderid
JOIN customers c ON c.customerid=o.customerid
ORDER BY 1
)
SELECT 
	total_sum.customerid,
	total_sum.companyname,
	total_sum.orderid,
	total_sum.orderdate,
	sum(after_discount) AS total_value_after_discount
FROM total_sum 
GROUP BY 1,2,3,4
HAVING sum(after_discount) >= 10000 AND orderdate >= '1997-01-01' AND orderdate <= '1998-01-01'
ORDER BY 4 DESC;

-- Calculate Month end orders
-- USE DATE_TRUNC WHICH WILL RESET THE FIELD(DAY,MONTH,YEAR)
-- THEN ADD DAYS TO IT
SELECT 
	o.orderid,
	o.employeeid,
	o.orderdate
FROM orders o
WHERE o.orderdate = (date_trunc('month',orderdate) + '1 MONTH - 1 DAY'::interval)::DATE
ORDER BY 3;

SELECT (date_trunc('month', orderdate) + interval '1 month - 1 day')::date
FROM orders 
ORDER BY 1 ;

-- most line items in orders
SELECT  
	o.orderid,
COUNT(od.orderid)
FROM orders o 
JOIN order_details od
ON o.orderid=od.orderid
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 10;

-- orders accidental double entry
-- Using SubQuery to calcualte
SELECT 
	orderid, 
	quantity
FROM Order_Details
WHERE Quantity >= 60
GROUP BY OrderID,Quantity
HAVING COUNT(*) > 1

(SELECT 
	o.orderid,
	o.quantity,
RANK() OVER(PARTITION BY o.quantity ORDER BY o.orderid) rnk
FROM order_details o
ORDER BY 2 )x
WHERE x.rnk>1;

-- late orders 
--& which employees, 
-- late orders vs total orders

WITH late_orders as 
(
	SELECT employeeid, lastname, COUNT(order_status) late_orders
FROM 
	(
	SELECT  
 		o.orderid, 
    	o.employeeid, 
    	e.lastname, 
    	CASE WHEN 
				o.shippeddate > o.requireddate THEN 'late'
        	 ELSE 
				'on-time '
        	END AS
				order_status
	FROM orders o
	JOIN employees e ON o.employeeid= e.employeeid ) X
	WHERE X.order_status= 'late'
	GROUP BY 1, 2
    ORDER BY 3 DESC
	),
total_orders AS 
(
	SELECT  
		o.employeeid, e.lastname, COUNT(o.orderid) total
	FROM orders o
	JOIN employees e 
	ON e.employeeid=o.employeeid
	GROUP BY 1, 2
	ORDER BY 3 DESC
)
SELECT 
	late_orders.employeeid, 
	late_orders.lastname, 
	late_orders.late_orders,
	total_orders.total,
	round(((late_orders::real)/(total::real))::decimal,2)  percentage_lateorders
FROM late_orders
JOIN total_orders on late_orders.lastname=total_orders.lastname;

-- missing employee
-- customer grouping
with total_sum as 
( select 
  c.customerid, 
  c.companyname,
  o.orderid,
  o.orderdate,
  SUM(od.unitprice*od.quantity)::real as total
from orders o
join order_details od on od.orderid=o.orderid
join customers c on c.customerid=o.customerid
where orderdate between '1997-01-01' and '1998-01-01'
group by 1,2,3,4
order by 1)

select 
total_sum.customerid,
total_sum.companyname,
total_sum.orderid,
total_sum.orderdate,
total_sum.total,
case when (total_sum.total) between 0 and 1000 then 'Low'
when (total_sum.total) between 1001 and 5000 then 'Medium'
when (total_sum.total) between 5001 and 10000 then 'High'
when (total_sum.total)>10000 then 'Very High'
end from total_sum
order by 1 asc;

-- countries and suppliers
select s.country from suppliers s
union
select c.country from customers c
order by country;

-- countries with suppliers or customer s
with supplier_country as
(
	select distinct country from suppliers supplier_country
),
customer_country as
(
	select distinct country from customers
)
select * from supplier_country 
full outer join customer_country
on supplier_country.country=customer_country.country
;



with Total_sup as 
(
select country, count(supplierid) sup_count from suppliers
group by 1 order by 2 desc
),
Total_cust as
(
select country, count(customerid) cust_count from customers
group by 1 order by 2 desc
)

select total_sup.country, total_sup.sup_count, 
       total_cust.country, total_cust.cust_count
from total_sup 
full outer join total_cust on
total_sup.country=total_cust.country
;

-- 5 day order period
-- date difference 
-- age, - operator

select age(shippeddate, orderdate) from orders;
select 
shippeddate::date - orderdate::date from orders;

select 
initial.customerid,
initial.orderid, 
initial.orderdate initial_order_date, 
next.orderid, 
next.orderdate next_order_date,
next.orderdate::date - initial.orderdate::date days_between
from orders initial
join orders next on 
initial.customerid=next.customerid
where initial.orderdate<next.orderdate
and 
next.orderdate::date - initial.orderdate::date < 5
order by 1;
-- same using lead 
with cte1 as (
select o.customerid, 
o.orderid, 
o.orderdate initial_orderdate, 
lead(orderdate) over(partition by customerid order by orderdate asc)
as next_orderdate
from orders o
order by 1 )

select *, cte1.next_orderdate- cte1.initial_orderdate::date 
from cte1
where cte1.next_orderdate- cte1.initial_orderdate::date 
< 5;

-- Categories
select 
c.categoryid,
c.categoryname,
count(p.productid)
from products p
join categories c 
on c.categoryid=p.categoryid
group by 1, 2
order by 3 desc;

-- total customers per country
select * from customers;
select c.country,
c.city,
count(distinct c.customerid)
from customers c 
group by 1,2 
order by 3 desc;

-- Products that need reordering
select * from products;
select productid, productname,
unitsinstock,
reorderlevel
from products
where 
unitsinstock < reorderlevel
order by 1;

-- customer by region
select
coalesce(c.region,'NA'),
c.customerid,
initcap(c.companyname)
from customers c 
order by 1 asc;

-- High freight charges problem
SELECT  
	o.shipcountry,
	ceil(avg(o.freight)) avg_freight
FROM orders o 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- High Freight charge problem in the year 2015
SELECT  
	o.shipcountry,
	o.orderdate,
	ceil(avg(o.freight)) avg_freight
FROM orders o 
GROUP BY 1,2
HAVING o.orderdate >= '1997-01-01'
ORDER BY 2 DESC
LIMIT 3;

--- end ----
