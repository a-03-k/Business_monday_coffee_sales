-- ================================================
-- monday coffee Project
-- Author: Anjani K
-- Date: June 2026
-- Database: PostgreSQL
-- ================================================


select * from city;
select * from products;
select * from customers;
select * from sales;

-- Reports and data anslysis
-- 1. Coffee Consumers Count
-- ques. calculate how many people in each city are estimated to consume coffee, given that 25% of the population drinks?
select 
city_name,
Round((population * 0.25)/1000000,2) as coffee_consumers_millions,
city_rank
from city
order by 2 desc

-- 2.Total Revenue from Coffee Sales
-- q2. What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select *,
 Extract(year from sale_date) as year,
 Extract(quarter from sale_date) as qtr
from sales
where 
 Extract(year from sale_date) = 2023
  and
 Extract(quarter from sale_date) = 4

 select 
 sum(total) as total_revenue 
 from sales
 where
 Extract(year from sale_date) = 2023
  and
 Extract(quarter from sale_date) = 4

 -- joining city table and find city sales
 select ci.city_name,
 sum(s.total) as total_revenue 
 from sales as s
 join customers as c
 on s.customer_id = c.customer_id
 join city as ci
 on ci.city_id = c.city_id
 where
 Extract(year from s.sale_date) = 2023
  and
 Extract(quarter from s.sale_date) = 4
 group by 1
 order by 2 desc
 --  Pune, Chennai, Bangalore, Jaipur, Delhi top 5 cities with highest sales revenue

 -- 3.Sales Count for Each Product
 -- q.How many units of each coffee product have been sold?
 select 
 p.product_name,
 count(s.sale_id) as total_sales
 from products as p
 left join
 sales as s
 on s.product_id = p.product_id
 group by 1
 order by 2 desc
 
--  -- 4.City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city name, total current consumers, estimated coffee consumers(25%)

with city_table as 

(select city_name,
 ROUND((population * 0.25)/1000000,2) as coff_cons
 from city
 ),
 customer_table
 AS
(
select ci.city_name,
count(distinct c.customer_id)as unique_cust
from sales as s
join customers as c
on c.customer_id = s.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
)
select
ct.city_name,
ct.coff_cons as coff_cons_in_mills,
cut.unique_cust
from city_table as ct
join customer_table as cut
on cut.city_name = ct.city_name

-- this query gives all the coffee consumers in millions and the unique customers in each city

-- 5.Top Selling Products by City
-- find top 3 selling products in each city based on sales volume?
select * from
(select 
ci.city_name,
p.product_name,
count(s.sale_id)as total_sales,
rank() over(partition by ci.city_name order by count(s.sale_id)desc) as rank

from sales as s
join products as p
on s.product_id = p.product_id
join customers as c
on c.customer_id = s.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1,2
) as tab_1
where rank <= 3
-- order by 1,3 desc

-- Ahmedabad, Bangalore& Chennai are the top cities that sell most number of products and products based on rank

-- 6.Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

select ci.city_name,

count(distinct c.customer_id)as unique_cust
from city as ci
left join customers as c
on c.city_id = ci.city_id
join sales as s
on s.customer_id = c.customer_id
where s.product_id in(1,2,3,4,5,6,7,8,9,10,11,12,13,14)
group by 1

-- 7.Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
with city_table
as
(
select ci.city_name,
sum(s.total)as total_revenue,

count(distinct s.customer_id) as total_cust,
round(sum(s.total)::numeric/count(distinct s.customer_id::numeric),2)as avg_sales_per_cust

from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
order by 2 desc
),
city_rent as 
(select city_name, estimated_rent
from city)
select cr.city_name,
cr.estimated_rent,
ct.total_cust,
ct.avg_sales_per_cust,
round(cr.estimated_rent::numeric/ct.total_cust::numeric,2) as avg_rent_per_person
from city_rent as cr
join city_table as ct
on cr.city_name = ct.city_name
order by 5 desc


-- 8.Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly) by each city.
with 
monthly_sales 
as
(select
 ci.city_name,
 extract(month from sale_date)as month,
 extract(year from sale_date)as year,
 sum(s.total)as total_sale
 from sales as s
 join customers as c
 on s.customer_id = c.customer_id
 join city as ci
 on ci.city_id = c.city_id
 group by 1,2,3
 order by 1,3,2
),
growth_ratio
as
(
      select 
          city_name,
          month,
          year,
          total_sale as current_mnth_sale,
          lag(total_sale,1) over(partition by city_name order by year, month) as last_month_sale
          from monthly_sales
)
select city_name,
month,
year,
current_mnth_sale,
last_month_sale,
round((current_mnth_sale-last_month_sale)::numeric/last_month_sale::numeric*100,2) as growt_ratio

from growth_ratio
where last_month_sale is not null


-- 9. Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, 
-- total customers, estimated coffee consumer
with city_table
as
(
select ci.city_name,
sum(s.total)as total_revenue,

count(distinct s.customer_id) as total_cust,
round(sum(s.total)::numeric/count(distinct s.customer_id::numeric),2)as avg_sales_per_cust

from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
order by 2 desc
),
city_rent as 
(select city_name, estimated_rent,
round((population*0.25)/1000000,3) as estimated_coffee_consumers_in_millions
from city)
select cr.city_name,
total_revenue,
cr.estimated_rent as total_rent,
ct.total_cust,
estimated_coffee_consumers_in_millions,
ct.avg_sales_per_cust,
round(cr.estimated_rent::numeric/ct.total_cust::numeric,2) as avg_rent_per_person
from city_rent as cr
join city_table as ct
on cr.city_name = ct.city_name
order by 2 desc

-- recommendation
-- Pune: avg rent less, highest total revenue, avg sale per customer is high
-- Delhi: highest estimated coffee consumer, highest total customer, avg rent per customer
-- Jaipur: highest customer, avg rent less, avg sale more






