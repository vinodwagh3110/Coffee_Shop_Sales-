create database Coffee_shop;

use Coffee_shop;

alter table `coffee shop sales`
rename to coffe_shop;

select * from coffe_shop;

-- Total revenue of the coffee shop
select round(sum(transaction_qty * unit_price),2) as Revenue from coffe_shop;

-- Total number of customers.
select count(distinct(transaction_id)) as Total_Customer from coffe_shop;

-- Average bill per person
select round(avg(transaction_qty * unit_price),2) as Avg_Bill
	from coffe_shop ;

-- Average number of items per order
select round(avg(transaction_qty),2) as avg_no_item_per_order
	from coffe_shop;

-- Which hour of the day has the most sales?
select hour(transaction_time) as Clock,
		sum(transaction_qty) as Quantity,
		round(sum(transaction_qty * unit_price)) as total_bill
        from coffe_shop
        group by Clock
        order by total_bill desc;
            
-- Which day of the week has the highest revenue?
SELECT DAYNAME(STR_TO_DATE(transaction_date,'%d-%m-%Y')) AS day_name,
		count(*) as Total_orders,
       round(SUM(transaction_qty * unit_price),2) AS total_revenue
		FROM coffe_shop
		GROUP BY DAYNAME(STR_TO_DATE(transaction_date,'%d-%m-%Y'))
		ORDER BY total_revenue DESC;

-- Monthly revenue trend
select monthname(str_to_date(transaction_date,'%d-%m-%Y')) as 'Month',
	count(*) as Total_orders,
	round(SUM(transaction_qty * unit_price),2) AS total_revenue	
    from coffe_shop
    group by monthname(str_to_date(transaction_date,'%d-%m-%Y'))
    order by total_revenue desc;

-- Revenue by each store location
select store_location ,
	round(sum(transaction_qty * unit_price)) as Revenue
    from coffe_shop
    group by store_location
    order by Revenue desc ;

-- Which location has highest avg bill per customer?
select store_location ,
	round(avg(transaction_qty * unit_price),2) as Revenue
    from coffe_shop
    group by store_location
    order by Revenue desc ;

-- Top 5 products by revenue
select product_type ,
	round(sum(transaction_qty * unit_price),2) as Revenue
    from coffe_shop
    group by product_type
    order by Revenue desc
    limit 5;
		
-- Which product category sells the most?
select product_category ,
	sum(transaction_qty ) as Quantity
    from coffe_shop
    group by product_category
    order by Quantity desc;

-- Which month had the biggest revenue jump from previous month?
select month_name,
		Revenue,
		lag(Revenue)over(order by month_num) as Previous_month_Revenue,
        round((Revenue - lag(Revenue)over(order by month_num)),2) as Revenue_Difference
        from ( 	
				select month(str_to_date(transaction_date,'%d-%m-%Y')) as month_num,
						monthname(str_to_date(transaction_date,'%d-%m-%Y')) as month_name,
						round(sum(transaction_qty * unit_price),2) as Revenue
						from coffe_shop
						group by month_num,month_name 
                        ) months
        order by Revenue_Difference desc ;
        
-- Revenue contribution % of each location
select store_location , 
		ROUND(SUM(transaction_qty * unit_price) * 100 / SUM(SUM(transaction_qty * unit_price)) OVER(), 2) AS Revenue_Percentage 
		from coffe_shop
        group by store_location;
        
-- Best selling product in each location (using CTE )
with selling_product as (
		select store_location,
				product_type,
                sum(transaction_qty) as Quantity,
                rank() over( partition by store_location order by sum(transaction_qty) desc) as rnk
                from coffe_shop 
                group by store_location, product_type
		)
		select store_location ,
				product_type,
                Quantity
                from selling_product
                where rnk = 1;

-- Peak hour revenue per location
WITH Peak_Hour AS (
    SELECT 
        store_location,
        HOUR(transaction_time) AS peak_time,
        ROUND(SUM(transaction_qty * unit_price),2) AS Revenue,
        RANK() OVER (
            PARTITION BY store_location
            ORDER BY SUM(transaction_qty * unit_price) DESC
        ) AS rnk
    FROM coffe_shop
    GROUP BY store_location, HOUR(transaction_time)
)
SELECT 
    store_location,
    peak_time,
    Revenue
FROM Peak_Hour
WHERE rnk = 1;
	
-- Day and hour combination with highest sales
with combination as (
select dayname(str_to_date(transaction_date, '%d-%m-%Y')) as Days,
		hour(transaction_time) as times,
        round(sum(transaction_qty * unit_price),2) as Revenue,
        rank() over(order by round(sum(transaction_qty * unit_price),2) desc ) as rnk
 from coffe_shop
 group by days , times 
 )

select Days,
		times,
        Revenue
        from combination
        where rnk = 1;

-- -----------------------------------------------------------------------------------------------------------------------------------------------
select
    dayname(str_to_date(transaction_date,'%d-%m-%Y')) AS Days,
    hour(transaction_time) as times,
    round(sum(transaction_qty * unit_price),2) as Revenue
from coffe_shop
group by Days, times
order by Revenue desc
limit 1;


-- Running total of revenue month by month
select 
    monthname(str_to_date(transaction_date,'%d-%m-%Y')) as month,
    sum(transaction_qty * unit_price) as Monthly_Revenue,
    sum(sum(transaction_qty * unit_price)) over() as Running_Total
from coffe_shop
group by monthname(str_to_date(transaction_date,'%d-%m-%Y'));

-- Which category contributes most revenue in each location?
select
    store_location,
    product_category,
    Total_Revenue
from (
    select 
        store_location,
        product_category,
        sum(transaction_qty * unit_price) as Total_Revenue,
        rank() over (partition by store_location order by sum(transaction_qty * unit_price) desc) as rnk
    from coffe_shop
    group by store_location, product_category
) ranked
where rnk = 1;
