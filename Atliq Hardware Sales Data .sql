-- Queries to answer business problems for a hypothetical FMCG company - Atliq --
-- Assuming the role of a supply chain analyst to dig deep into their data and provide some reports and useful insights --

/*Report 1 
LIST OF MARKETS WHERE ATLIQ EXLUSIVELY OPERATES IN THE APAC REGION */
SELECT  
	concat(region,' ', 'Asia-Pacific') Region, customer Customer, UPPER(market) Current_Operating_Markets
FROM 
	dim_customer 
WHERE region = 'APAC' AND customer = 'Atliq Exclusive'
ORDER BY 2 ASC; 


/*REPORT 2 
PERCENTAGE OF UNIQUE PRODUCT INCREASE IN 2021 COMPARED TO 2020 */
use gdb023;
-- A. PERCENTAGE OF UNIQUE PRODUCT INCREASE 
WITH UNQ_2020 AS
(SELECT 
	COUNT(distinct PRODUCT_CODE) Unique_Products_2020 , FISCAL_YEAR FROM FACT_SALES_MONTHLY GROUP BY 2 HAVING FISCAL_YEAR =2020),
        UNQ_2021 AS
(SELECT COUNT(distinct PRODUCT_CODE) Unique_Products_2021 , FISCAL_YEAR FROM FACT_SALES_MONTHLY GROUP BY 2 HAVING FISCAL_YEAR =2021)

SELECT UNQ_2020.FISCAL_YEAR Fiscal_Year, UNIQUE_PRODUCTS_2020 Unique_Prods_2020, UNQ_2021.FISCAL_YEAR Fiscal_Year, 
       UNIQUE_PRODUCTS_2021 Unique_Prods_2021, 
	concat(round((((UNQ_2021.UNIQUE_PRODUCTS_2021 - UNQ_2020.UNIQUE_PRODUCTS_2020 ) / UNQ_2020.UNIQUE_PRODUCTS_2020) * 100), 2), '', '%') Percentage_Chng
FROM UNQ_2020 CROSS JOIN UNQ_2021;

/* B. UNIQUE PRODUCT SOLD QUANTITY % INCREASE */
WITH 
T1 AS 
(select distinct(s.product_code), p.product, sum(s.sold_quantity) sum1, s.fiscal_year from fact_sales_monthly s
	join dim_product p on p.product_code=s.product_code
	group by s.product_code, s.fiscal_year having s.fiscal_year = 2020
),
T2 AS 
(select distinct(s.product_code), p.product, sum(s.sold_quantity) sum2, s.fiscal_year from fact_sales_monthly s
	join dim_product p on p.product_code=s.product_code
	group by s.product_code, s.fiscal_year having s.fiscal_year = 2021   )

SELECT 
	coalesce (T1.product_code,'DidNotExist') 2020_Unique_Products , T1.product Product, sum1 sold_qty_in_2020, 
	T2.product_code 2021_Unique_Products, T2.product Product, sum2 sold_qty_in_2021, 
        concat( coalesce(round((((sum2-sum1)/sum2)*100),1),0) , '%') Percentage_change 
FROM T1 
	RIGHT JOIN T2 ON T1.product_code=T2.product_code 
ORDER BY 7 DESC;

/*REPORT 3 
PROVIDE SEGMENT WISE UNIQUE PRODUCT OFFERING */ 

SELECT  
UPPER(segment) Segment , CONCAT(COUNT(DISTINCT product_code), ' ' , 'Unique Products') Products 
FROM dim_product 
GROUP BY segment ORDER BY 2 ASC;

/* REPORT 4 
WHICH SEGMENT HAD THE MOST INCREASE IN UNIQUE PRODUCT OFFERING IN 2021 COMPARED TO 2020? */
 
WITH PRODUCTS_2020 AS
(select 
p.segment Segment, count(distinct s.product_code) product_count_2020, s.fiscal_year from fact_sales_monthly s 
join dim_product p on s.product_code=p.product_code group by 1,3 having s.fiscal_year=2020 order by 2 desc ),

PRODUCTS_2021 AS 
(select 
p.segment Segment, count(distinct s.product_code) Product_count_2021, s.fiscal_year from fact_sales_monthly s join dim_product p on 
s.product_code=p.product_code group by 1,3 having s.fiscal_year=2021 order by 2 desc )

SELECT  PRODUCTS_2020.SEGMENT Segment, 
		PRODUCTS_2020.product_count_2020, 
        PRODUCTS_2021.product_count_2021, 
        (product_count_2021-product_count_2020) Product_Increase  
FROM PRODUCTS_2020 JOIN PRODUCTS_2021 
ON PRODUCTS_2020.SEGMENT = PRODUCTS_2021.SEGMENT ORDER BY Product_Increase DESC;

/* REPORT 5 
PRODUCT WITH HIGHEST AND LOWEST MANUFACTURING COSTS */
select m.product_code, 
	   p.product,
       m.manufacturing_cost
from dim_product p join fact_manufacturing_cost m on m.product_code=p.product_code where manufacturing_cost=
(select max(manufacturing_cost) from fact_manufacturing_cost)
union
select m.product_code, 
	   p.product,
       m.manufacturing_cost
from dim_product p join fact_manufacturing_cost m on m.product_code=p.product_code where manufacturing_cost=
(select min(manufacturing_cost) from fact_manufacturing_cost);

/* REPORT 6 
TOP 5 CUSTOMERS WITH HIGHEST AVERAGE DISCOUNTS FOR 2021 IN THE INDIAN MARKET */
 SELECT 
	D.FISCAL_YEAR Fiscal_Year, 
	D.CUSTOMER_CODE Cust_Code, 
	UPPER(C.CUSTOMER) Customer,
	C.MARKET Market,
	CONCAT(ROUND(AVG(D.PRE_INVOICE_DISCOUNT_PCT),2), ' ', '%') Avg_Disc
 FROM fact_pre_invoice_deductions D JOIN dim_customer C ON D.customer_code=C.customer_code
 GROUP BY 1,2 
 HAVING FISCAL_YEAR =2021 AND C.MARKET = 'India' ORDER BY 5 DESC limit 5 ;
 
 
/* REPORT 7 
MONTHLY GROSS SALES AMOUNT FOR ATLIQ EXCLUSIVE */

 SELECT  
 c.customer Customer, month(s.date) Month, year(s.date) Year,
 -- s.fiscal_year,
 SUM((s.sold_quantity*g.gross_price)) Gross_Sales_Amount
 from fact_sales_monthly s
 join dim_customer c on s.customer_code=c.customer_code
 join fact_gross_price g on g.product_code=s.product_code
 group by 1,2,3 having c.customer = 'Atliq Exclusive'
 order by 3 asc ;
 
 /* REPORT 8 
WHICH QUARTER OF 2020 GOT THE MAXIMUM TOTAL SOLD QUANTITIES?*/
WITH CTE1 AS 
(SELECT 
	s.fiscal_year, 
    s.date, 
	s.product_code, 
    p.product, 
    sum(s.sold_quantity) TOTAL_QTY
FROM fact_sales_monthly s join dim_product p ON p.product_code=s.product_code
GROUP BY 1,2,3 HAVING s.fiscal_year=2020 ORDER BY 5 DESC )

SELECT 
	CTE1.FISCAL_YEAR Fiscal_Year, 
    CASE 
WHEN MONTH(CTE1.DATE) BETWEEN 9 AND 11 THEN 'Q1'
WHEN MONTH(CTE1.DATE) BETWEEN 12 AND 2 THEN 'Q2'
WHEN MONTH(CTE1.DATE) BETWEEN 3 AND 5  THEN 'Q3'
WHEN MONTH(CTE1.DATE) BETWEEN 6 AND 8  THEN 'Q4'
END AS Quarter, 
CTE1.TOTAL_QTY Total_Sold_Qty
FROM CTE1 GROUP BY 1,2 ORDER BY 3 DESC;

select  case
WHEN MONTH(DATE) BETWEEN 9  AND 11 THEN 'Q1'
WHEN MONTH(DATE) BETWEEN 12 AND 2  THEN 'Q2'
WHEN MONTH(DATE) BETWEEN 3  AND 5  THEN 'Q3'
WHEN MONTH(DATE) BETWEEN 6  AND 8  THEN 'Q4'
 end as quarter,
 sum(sold_quantity) as total_sold
 from fact_sales_monthly
 where fiscal_year=2020
 group by quarter
 order by total_sold desc;
 
 
 /* REPORT 9 
CHANNELS THAT BROUGHT MOST GROSS SALES IN 2021 AND PERCENTAGE CONTRIBUTION */

WITH CGS AS 
( select s.fiscal_year, 
         c.channel, 
         SUM(round((g.gross_price*s.sold_quantity),2)) gross_sales 
from fact_sales_monthly s 
join fact_gross_price g on s.product_code=g.product_code 
join dim_customer c on c.customer_code=s.customer_code
group by 1, 2 having s.fiscal_year = 2021 order by 3 desc ),

TGS AS 
( SELECT CGS.FISCAL_YEAR, SUM(CGS.GROSS_SALES) TOTAL_GROSS_SALES FROM CGS )

SELECT 
CGS.FISCAL_YEAR Fiscal_Year, 
CGS.CHANNEL Channel, 
CGS.GROSS_SALES Gross_Sales, 
CONCAT(round(((CGS.gross_sales/TGS.total_gross_sales)*100),2),' ', '%')  Percentage
from CGS join TGS on CGS.fiscal_year=TGS.fiscal_year;

/* REPORT 10  
TOP 3 PRODUCTS IN EACH DIVISION WITH HIGH TOTAL SOLD QUANTITY FOR 2021? */
with sales as 
( select division, 
	     m.product_code, 
		product, 
        sum(sold_quantity) total_sold_quantity
from fact_sales_monthly m
left join dim_product p on m.product_code = p.product_code
where fiscal_year = 2021  group by m.product_code, division, product),

RANKS as 
(select product_code,
        total_sold_quantity, 
		dense_rank() over (partition by division order by total_sold_quantity desc) rank_order
from sales s )

select 
	division, s.product_code, product, s.total_sold_quantity, rank_order 
from
sales s 
	inner join ranks as r on r.product_code=s.product_code 
where rank_order between 1 and 3;

--------- END ----------

