# ☕ Coffee Shop Sales Analysis — SQL + Excel Dashboard

End-to-end sales analysis project for a 3-location coffee shop chain. I took raw transaction data all the way from a messy SQL table to a fully interactive Excel dashboard, pulling out the insights a business owner would actually want to act on.

**Tech used:** MySQL · Excel (Pivot Tables, Pivot Charts, Slicers, KPI Cards)

## 📌 Project Overview

| | |
|---|---|
| **Dataset** | Coffee shop transaction-level sales data (Jan – Jun) |
| **Locations** | 3 stores — Astoria, Hell's Kitchen, Lower Manhattan |
| **Goal** | Find revenue trends, peak sales times, top products, and location performance |
| **Approach** | Clean & query data in MySQL → Build a dashboard in Excel → Translate numbers into business insights |

---

## 🗄️ Part 1: SQL Analysis

All analysis started in MySQL. I went from raw data to business-ready answers using everything from basic aggregations to **window functions and CTEs**.

### Setup & Cleaning
```sql
create database Coffee_shop;
use Coffee_shop;

alter table `coffee shop sales`
rename to coffe_shop;
```

### Core KPIs
```sql
-- Total revenue of the coffee shop
select round(sum(transaction_qty * unit_price),2) as Revenue from coffe_shop;

-- Total number of customers
select count(distinct(transaction_id)) as Total_Customer from coffe_shop;

-- Average bill per person
select round(avg(transaction_qty * unit_price),2) as Avg_Bill from coffe_shop;

-- Average number of items per order
select round(avg(transaction_qty),2) as avg_no_item_per_order from coffe_shop;
```

### Time-Based Trends
```sql
-- Which hour of the day has the most sales?
select hour(transaction_time) as Clock,
       sum(transaction_qty) as Quantity,
       round(sum(transaction_qty * unit_price)) as total_bill
from coffe_shop
group by Clock
order by total_bill desc;

-- Which day of the week has the highest revenue?
select dayname(str_to_date(transaction_date,'%d-%m-%Y')) as day_name,
       count(*) as Total_orders,
       round(sum(transaction_qty * unit_price),2) as total_revenue
from coffe_shop
group by dayname(str_to_date(transaction_date,'%d-%m-%Y'))
order by total_revenue desc;
```

### Advanced: Window Functions & CTEs

This is where it gets interesting — instead of just pulling totals, I used **window functions** to compare performance across time and locations:

```sql
-- Which month had the biggest revenue jump from the previous month?
select month_name,
       Revenue,
       lag(Revenue) over(order by month_num) as Previous_month_Revenue,
       round((Revenue - lag(Revenue) over(order by month_num)),2) as Revenue_Difference
from (
    select month(str_to_date(transaction_date,'%d-%m-%Y')) as month_num,
           monthname(str_to_date(transaction_date,'%d-%m-%Y')) as month_name,
           round(sum(transaction_qty * unit_price),2) as Revenue
    from coffe_shop
    group by month_num, month_name
) months
order by Revenue_Difference desc;

-- Revenue contribution % of each location
select store_location,
       ROUND(SUM(transaction_qty * unit_price) * 100 /
             SUM(SUM(transaction_qty * unit_price)) OVER(), 2) AS Revenue_Percentage
from coffe_shop
group by store_location;

-- Best selling product in each location (using CTE + RANK)
with selling_product as (
    select store_location,
           product_type,
           sum(transaction_qty) as Quantity,
           rank() over(partition by store_location order by sum(transaction_qty) desc) as rnk
    from coffe_shop
    group by store_location, product_type
)
select store_location, product_type, Quantity
from selling_product
where rnk = 1;
```

**SQL skills demonstrated:** aggregate functions, `GROUP BY` / `ORDER BY` logic, date parsing (`STR_TO_DATE`, `MONTHNAME`, `DAYNAME`), subqueries, **window functions** (`LAG()`, `RANK()`, `OVER(PARTITION BY...)`), and **CTEs** for clean, readable multi-step logic.

---

## 📊 Part 2: Excel Dashboard

Once the SQL answers were ready, I built a one-page interactive dashboard in Excel to make the data easy for anyone (not just analysts) to explore.

**Dashboard features:**
- **KPI cards** at the top — Total Sales, Total Footfall, Avg Bill/Person, Avg Order/Person
- **Line chart** — Quantity sold by hour, to spot the morning rush
- **Bar chart** — Quantity & sales by weekday
- **3D Pie charts** — Category split and order-size split
- **Bar chart** — Top 5 products by revenue
- **Bar chart** — Footfall & sales by location
- **Slicers** for Month and Day, so anyone can filter the whole dashboard interactively

> 📁 Dashboard file: `Coffee_Shop_Sales_Dashboard.xlsx`
> 🖼️ Preview image: `dashboard_preview.png`

![alt text](image.png)

**Excel skills demonstrated:** Pivot Tables & Pivot Charts, slicers for interactivity, KPI card design, 3D pie & clustered bar charts, and a clean single-page dashboard layout designed for non-technical viewers.

---

## 💡 Key Insights

| Area | Insight |
|---|---|
| **Revenue** | $6,98,812 total revenue from 1,49,116 customers |
| **Peak Hours** | 8 AM – 10 AM is the busiest window (18,000+ units); sales fall sharply after 6 PM |
| **Best Days** | Monday & Friday lead; weekends (Sat/Sun) are the slowest — a weekday-driven business |
| **Growth** | Revenue nearly **doubled** from Jan ($81.6K) to Jun ($166K); Feb was the only dip |
| **Locations** | All 3 stores perform within $6,500 of each other — but Lower Manhattan sells the most units while earning the least, hinting customers buy cheaper items there |
| **Top Product** | Barista Espresso is the #1 seller, ahead of Brewed Chai Tea and Hot Chocolate |
| **Categories** | Coffee (42%) and Tea (32%) dominate; everything else splits the rest |
| **Data Quality** | 30% of orders have no recorded size — worth fixing at the data-entry stage |

---
## 🚀 What This Project Shows

This was built to practice the full analyst workflow — not just running queries, but turning raw transactional data into a **story a business can actually use**:

1. Clean & structure data in SQL
2. Ask the right business questions
3. Write queries from simple aggregates to window functions/CTEs
4. Visualize findings in a dashboard non-technical people can use
5. Translate numbers into clear, actionable insights

