-- NorthWind Database Tables
/*TABLES AND DATA */
create table categories 
( categoryid int, categoryname char(20), description text ); 

create table customers 
( customerid char(20), companyname text, contactname text,
contacttitle text, address text, city char(20),
region char(20), postalcode varchar(50), country varchar(50),
phone varchar(50), fax varchar(50) );

create table employees 
( employeeid int, lastname text, firstname text, title text,
titleofcourtesy text, birthdate date, hiredate date,
address text, city text, region text, postalcode text,
country text, homephone text, extension int, notes text,
reports_to int );

create table employeeterritories
( employeeid int, territoryid int );

create table order_details
( orderid int, productid int, unitprice real, quantity int, discount real);

create table orders 
( orderid int, customerid text, employeeid int, orderdate date,
requireddate date, shippeddate date, shipvia int, freight real,
shipname text, shipaddress text, shipcity text,
shipregion text, shippostalcode text, shipcountry text );

create table products 
( productid int, productname text, supplierid int, categoryid int,
quantityperunit text, unitprice real,
unitsinstock real, unitsonorder real, reorderlevel real, discontinued int );

create table region
( regionid int, regiondescription text );

create table shippers
( shipperid int, companyname text, phone text );

create table suppliers
( supplierid int, companyname text, contactname text,
contacttitle text,address text,city text, region text,
postalcode text, country text, phone text, fax text,
homepage text);

create table territories
( territoryid int,territorydescription text, regionid int);

create table usstates
( stateid int, statename text, stateabbr text, stateregion text);

------------------/* BUSINESS QUESTIONS */----------------------

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
select 
o.shipcountry,
ceil(avg(o.freight)) avg_freight
from orders o 
group by 1
order by 2 desc
limit 3;

-- High Freight charge problem in the year 2015
select 
o.shipcountry,
o.orderdate,
ceil(avg(o.freight)) avg_freight
from orders o 
group by 1,2
having o.orderdate >= '1997-01-01'
order by 2 desc
limit 3;

-- High Freight charge problems last year
-- LAST 12 MONTHS DATA- USE INTERVAL FUNCTION
-- FIRST FIND THE LATEST ORDERDATE (USE MAX)
-- USE INTERVAL WHICH WILL TAKE BACK THE DATE 12 MONTHS BEHIND
-- THEN SELECT ORDERDATE THAT IS > THAN THAT INTERVAL DATE 
select 
o.shipcountry,
o.orderdate,
ceil(avg(o.freight)) avg_freight
from orders o 
group by 1,2
having o.orderdate > (select max(orderdate)
from orders) - interval '12 months' 
order by 3 desc
limit 3;

select max(orderdate) - interval '12 months'
from orders;

-- customers with no orders
-- using subquery single columns multiple row sq
-- customers with no orders for empid 4
select c.customerid from customers c 
where c.customerid  not in 
(select o.customerid from orders o where 
o.employeeid=4);

-- using correlated sub query 
select c.customerid
from customers c 
where c.customerid not in
( select o.customerid from orders o
  where o.customerid=c.customerid and 
  o.employeeid=4	
);

-- customers who have ordered something 
-- using right join
select 
distinct o.customerid
from customers c 
right join orders o 
on c.customerid=o.customerid;

-- correlated subquery 
select c.customerid
from customers c
where
exists (select o.customerid from orders o
where o.customerid=c.customerid);


/* ADVANCED BUSINESS QUESTIONS */

-- customers with high orders in 2016
WITH total_sum as 
  ( select 
 	c.customerid, 
	c.companyname,
	o.orderid,
	o.orderdate,
	(od.unitprice*od.quantity ) as total_sum,
	od.discount,
    (od.unitprice*od.quantity)-
	( (od.unitprice*od.quantity )*od.discount) after_discount
	from orders o
	join order_details od on od.orderid=o.orderid
	join customers c on c.customerid=o.customerid
	order by 1
  )

select 
total_sum.customerid,
total_sum.companyname,
total_sum.orderid,
total_sum.orderdate,
sum(after_discount) as total_value_after_discount
from total_sum 
group by 1,2,3,4
having
sum(after_discount) >= 10000
and orderdate >= '1997-01-01' and orderdate <= '1998-01-01'
order by 4 desc;

-- High end customers with discount
WITH total_sum as 
(
	select 
	c.customerid, 
	c.companyname,
	o.orderid,
	o.orderdate,
	(od.unitprice*od.quantity ) as total_sum,
	od.discount,
	(od.unitprice*od.quantity)-
	( (od.unitprice*od.quantity )*od.discount) after_discount
from orders o
join order_details od on od.orderid=o.orderid
join customers c on c.customerid=o.customerid
order by 1
)

select 
total_sum.customerid,
total_sum.companyname,
total_sum.orderid,
total_sum.orderdate,
sum(after_discount) as total_value_after_discount
from total_sum 
group by 1,2,3,4
having
sum(after_discount) >= 10000
and orderdate >= '1997-01-01' and orderdate <= '1998-01-01'
order by 4 desc;

-- month end orders
-- USE DATE_TRUNC WHICH WILL RESET THE FIELD(DAY,MONTH,YEAR)
-- THEN ADD DAYS TO IT
select
o.orderid,
o.employeeid,
o.orderdate
from orders o
where
o.orderdate=
(date_trunc('month',orderdate) + '1 MONTH - 1 DAY'::interval)::DATE
order by 3;

select 
(date_trunc('month', orderdate) + 
interval '1 month - 1 day')::date
from orders order by 1 ;

-- most line items in orders
select 
o.orderid,
count(od.orderid)
from orders o 
join order_details od
on o.orderid=od.orderid
group by 1 
order by 2 desc
limit 10;

--orders- random assortment
select * from orders;
select * from order_details;

-- orders accidental double entry
select orderid, quantity
From Order_Details
Where Quantity >= 60
Group By
OrderID
,Quantity
Having Count(*) > 1

(select
o.orderid,
o.quantity,
rank() over(partition by o.quantity order by o.orderid) rnk
from order_details o
order by 2 )x
where x.rnk>1;

-- late orders 
--& which employees, 
-- late orders vs total orders

with late_orders as 
(
select employeeid, lastname, count(order_status) late_orders
from 
	(select 
 		o.orderid, 
    	o.employeeid, 
    	e.lastname, 
    	case when
			o.shippeddate > o.requireddate then 'late'
        	else 'on-time '
        	end as order_status
		from orders o
			join employees e
				on o.employeeid= e.employeeid ) X
where X.order_status= 'late'
group by 1, 2
order by 3 desc
),
total_orders as 
(
select 
o.employeeid, e.lastname, count(o.orderid) total
from orders o
join employees e 
on e.employeeid=o.employeeid
group by 1, 2
order by 3 desc
)
select late_orders.employeeid, late_orders.lastname, 
late_orders.late_orders,
total_orders.total,
round(((late_orders::real)/(total::real))::decimal,2)  percentage_lateorders
from late_orders
join total_orders on 
late_orders.lastname=total_orders.lastname;

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

select * from suppliers;
--supplierid
select * from customers;
--customerid
--country

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

-- first order in each country
select * from 
(select 
o.shipcountry,
o.customerid,
o.orderid, 
o.orderdate,
rank() over(partition by shipcountry order by orderdate asc) rn
from orders o 
order by 1) X
where x.rn=1;

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











