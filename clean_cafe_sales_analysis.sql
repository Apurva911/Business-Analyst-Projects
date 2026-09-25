--cafe sales performance analysis
--file -02,Clean_cafe_sales_analysis
--Description: Business queries answering executive, product, 
--              channel, and operational questions from clean data.


--1.Executive Summary(High-level-KPI)
 

 --Business Questions:what is the total business Footprint(revenue,order,AOV)
select  
	count ([Transaction_ID])as total_orders,
	sum([Quantity]) as total_unit_sold,
	ROUND(sum([Total_Spent]),2) as total_revenue,
	ROUND(avg([Total_Spent]),2) as average_order_value
from [Sales].[dbo].[clean_cafe_sales];

select Item from [Sales].[dbo].[clean_cafe_sales]


--Menu And Item performance
--Question: Which items bring in the most money vs. sell the most volume?
-- Highlights whether low-price items dominate volume or if premium items drive revenue.

select 
	Item,
	sum(Quantity) as total_unit_sold,
	ROUND(sum([Total_Spent]),2) as total_revenue,
	ROUND(100.0*sum([Total_Spent])/sum(sum([Total_Spent])) over(),2) as revenue_contribution_pecentage,
	DENSE_RANK() over(order by sum([Total_Spent]) desc) as revenue_rank
from [Sales].[dbo].[clean_cafe_sales]
where Item <> 'uncategorized'
group by Item
order by total_revenue desc;


--3.CHANNEL DYNAMICS: IN-STORE VS. TAKEAWAY
--Business Question: How does dining location impact order size and revenue?

select location ,
count(Transaction_ID) as total_order, 
sum(Total_Spent) as total_revenue,
round(avg(Total_Spent),2) as avg_spent_per_order,
avg(Quantity) as avg_order_size
from [Sales].[dbo].[clean_cafe_sales]
where location <> 'not specified'
group by Location


--4. payment method destriustion
--Business Question: What are customers' preferred payment channels?
select
	Payment_Method,
	count(Transaction_ID) as transaction_count,
	round(sum(total_spent),2) as total_revenue
	
from [Sales].[dbo].[clean_cafe_sales]
where Payment_Method<> 'not mention'
group by Payment_Method
order by total_revenue desc;



--5.MONTHLY SALES & GROWTH TRENDS
--Business Question: How does revenue trend across the year (2023)?

select format(Transaction_Date,'yyyy-mm') as Sales_month, 
count(Transaction_ID) as total_order,
round(sum(total_spent),2) as total_revenue,
round(avg(Total_Spent),2) as avg_order_value
from  [Sales].[dbo].[clean_cafe_sales]
WHERE [Transaction_Date] is not null
group by format(Transaction_Date,'yyyy-mm');

select  *
from  [Sales].[dbo].[clean_cafe_sales] 


--6.Business Question: Which days require more staffing based on demand?

select datename(WEEKDAY,[Transaction_Date]) as day_of_week,
count([Transaction_ID]) as total_transaction,
round(sum(total_spent),2) as total_revenue,
round(avg(total_spent),2) as avg_spend_per_order
from [Sales].[dbo].[clean_cafe_sales] 
where [Transaction_Date] is not null
group by datename(WEEKDAY,[Transaction_Date]),
datepart(WEEKDAY,[Transaction_Date])
order by datepart(WEEKDAY,[Transaction_Date]);


