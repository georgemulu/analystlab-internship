--Check number od rows in the dataset
SELECT COUNT(*)
FROM sales
--The dataset has 2823 rows

--Exploratory data analysis
SELECT COUNT(DISTINCT ordernumber)
FROM sales
--There are 307 distinc orders in the dataset

SELECT DISTINCT(status)
FROM sales
--There are 6 types of status for a product: shipped, resolved, cancelled, in process, disputed, on hold

SELECT DISTINCT(productline)
FROM sales
--There are 7 products sold in the dataset: classic cars, trains, planes, trucks and buses, vintage cars, motorcycles, ships

SELECT COUNT(DISTINCT customername)
FROM sales
--There products are sold to 92 customers

SELECT COUNT(DISTINCT country), COUNT(DISTINCT territory)
FROM sales
--Sales are made to 19 countries from 4 territories

SELECT DISTINCT(dealsize)
FROM sales
--There are 3 types of deal sizes: small, large, medium

SELECT MIN(orderdate), max(orderdate)
FROM sales
--The dataset contains sales made from 2003-01-06 to 2005-05-31

--REVENUE ANALYSIS
SELECT SUM(sales) 
FROM sales
WHERE status IN ('Shipped', 'Resolved')
--Total sales amount is 9442219.36

SELECT productline, SUM(sales) as total_sales
FROM sales
WHERE status IN ('Shipped', 'Resolved')
GROUP BY productline
ORDER BY total_sales DESC
--Classic cars generate the highest revenue at 3727559.67, followed by vintage cars, motorcycles, trucks and buses, planes, ships and then
--having the lowest revenue at 215352.57

SELECT customername, SUM(sales) as total_sales
FROM sales
WHERE status IN ('Shipped', 'Resolved')
GROUP BY customername
ORDER BY total_sales DESC
--Euro shopping channel is the customer generating the highest revenue at 795328.22 while Boards & Toys Co. has the lowest at 9129.35

SELECT country, SUM(sales) as total_sales
FROM sales
WHERE status IN ('Shipped', 'Resolved')
GROUP BY country
ORDER BY total_sales DESC
--USA is the highest generating revenue country at 3416477.64 while Ireland is the lowest at 57756.43

SELECT territory, SUM(sales) as total_sales
FROM sales
WHERE status IN ('Shipped', 'Resolved')
GROUP BY territory
ORDER BY total_sales DESC
--EMEA is the highest generating revenue territory at 4658717.63, followed by NA(3640556.20) and then APAC(687772.31) while Japan is the lowest at 455173.22

SELECT dealsize, SUM(sales) as total_sales
FROM sales
WHERE status IN ('Shipped', 'Resolved')
GROUP BY dealsize
ORDER BY total_sales DESC
--Medium dealsize generates the highest revenue at 5737563.42, followed by small at 2515376.84, then large the lowest at 1189279.10

--STATUS ANALYSIS
SELECT status, COUNT(*)
FROM sales
GROUP BY status
ORDER BY COUNT(*) DESC
--Shipped products are 2617 representing 93% of the dataset, followed by cancelled,resolved, on hold, in process and disputed having 14 products

SELECT status, SUM(quantityordered) as total_quantity, ROUND(AVG(quantityordered),2) as avg_quantity
FROM sales
GROUP BY status
ORDER BY total_quantity DESC
--Shipped has the highest quantity ordered at 91403 units and an average quantity of 34.93 per order while disputed has the lowest quantity at
--597 and average quantity of 42.64. On hold has the highest average at 42.70 units while cancelled has the lowest at 33.97

SELECT SUM(sales)
FROM sales
WHERE status NOT IN ('Shipped','Resolved')
--590409.49 is amount of money that sales has not generated

--PRODUCT ANALYSIS
SELECT 
	productline, 
	SUM(CASE WHEN status IN ('Shipped','Resolved') THEN quantityordered END) as sold_goods, 
	SUM(CASE WHEN status NOT IN ('Shipped','Resolved') THEN quantityordered END) as not_sold
FROM sales
GROUP BY productline
--Classic cars leads in quantity of units sold and not sold with 32249 and 1743 respectively, while trains has the lowest quantity of sold goods and not sold goods at 2622 and 90 respectively

SELECT productline, ROUND(AVG(priceeach),2) as average_price
FROM sales
WHERE status IN ('Shipped', 'Resolved')
GROUP BY productline
ORDER BY average_price DESC
--Trucks and buses have the highest average price at 87.57 followed by classic cars with the last two being vintage cars at 78.15 and trains at 75.01

WITH product_country AS (
	SELECT country, productline, SUM(sales) as total_sales
	FROM sales
	WHERE status IN ('Shipped', 'Resolved')
	GROUP BY country, productline),
product_ranking AS (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY country ORDER BY total_sales DESC) as ranking
	FROM product_country
)
SELECT *
FROM product_ranking
WHERE ranking = 1
--Classic Cars leads as the top selling product in 16 countries, followed by vintage cars in 2 and planes in 1

--CUSTOMER ANALYSIS
SELECT customername, SUM(quantityordered) as total_quantity
FROM sales
WHERE status IN ('Shipped', 'Resolved')
GROUP BY customername
ORDER BY total_quantity DESC
--Euro shopping channel bought the most units at 8194 corresponding with the high revenue generated, boards & toys Co. have the lowest units bought at 102

--GEOGRAPHICAL ANALYSIS
SELECT 
	country, 
	COUNT(DISTINCT customername) as no_of_customers, 
	ROUND(SUM(sales)/COUNT(DISTINCT customername),2) as customer_value
FROM sales
WHERE status IN ('Shipped', 'Resolved')
GROUP BY country
ORDER BY customer_value DESC
--USA leads with 35 customers which justifies the high revenue while Ireland has 1 customer corresponding with the low revenue however spain
--has the highest revenue per customer at 219744.21 with 5 customers while belgium has the lowest at 50000.34
--USA is number 10 at average revenue per customer
--France has the second highest no of customers but is ranked 12 in customer value

SELECT 
	territory,
	COUNT(DISTINCT country) as no_of_countries,
	COUNT(DISTINCT customername) as no_of_customers, 
	ROUND(SUM(sales)/COUNT(DISTINCT customername),2) as customer_value
FROM sales
WHERE status IN ('Shipped', 'Resolved')
GROUP BY territory
ORDER BY customer_value DESC
--The APAC region consisting of 2 countries has 6 customers and the highest customer value at 114628.72 while NA with 2 countries has the second highest number of customers at 38 but the lowest
--average revenue per customer at 95804.11
--EMEA has the highest number of countries at 13 and highest number of customers at 44 but second lowest average revenue per customer at 105879.95

--Time analysis
SELECT orderdate, SUM(sales) AS total_sales
FROM sales
WHERE status IN ('Shipped', 'Resolved')
GROUP BY orderdate
ORDER BY total_sales DESC;
--The single highest-revenue day was 24 November 2004 137,644.72; the lowest was 22 April 2005.

SELECT orderdate, 
	   ROUND(AVG(sales) OVER(
	   ORDER BY orderdate
	   ROWS BETWEEN 29 PRECEDING AND CURRENT ROW),2)  as moving_average
FROM sales
WHERE status IN ('Shipped','Resolved') 
ORDER BY orderdate
--Sales fluctuate mostly between 3000 and 4000 suggesting a fairly consistent level of activity
--There are sustained peaks lasting weeks nearing 5000 they likely correspond to seasonal demand, promotion or events that boosted performance
--There are periods where sales surge below 3000 possibly off season or after surge, because the average is 30 day this suggests the weak performance lasted over
--a month not just a few bad days
--Overally there is consistent performance

SELECT year_id, COUNT(DISTINCT month_id) as no_of_months, SUM(sales) as total_sales
FROM sales
WHERE status IN ('Shipped','Resolved')
GROUP BY  year_id
ORDER BY total_sales DESC
--2004 had the highest revenue at 4552125.83 while 2005 had the lowest 1421824.91
--The dataset contains only sales from 5 months of 2005 which explains the low revenue
--2003 and 2004 had all month sales data recorded and 2004 registered an increase in sales by 1083857.21

SELECT year_id, 
	   qtr_id, 
	   COALESCE(SUM(sales) - LAG(SUM(sales)) OVER(ORDER BY year_id,qtr_id),0) as absolute_change,
	   COALESCE(ROUND((SUM(sales) - LAG(SUM(sales)) OVER(ORDER BY year_id,qtr_id))/
	   LAG(SUM(sales)) OVER(ORDER BY year_id,qtr_id) * 100,2),0) as quarter_over_quarter_change
FROM sales
WHERE status IN ('Shipped','Resolved')
GROUP BY  year_id, qtr_id
ORDER BY year_id, qtr_id
--The QoQ indicates a strong volatility with a high reaching 178.57% and a low of -67.37%
--There is a big surge in Q4 of 2003 suggesting a period of exceptional growth possible driven by season effect
--There is a drop in early 2004 plunging below zero compared to the previous quarter. This could be a post holiday slowdown or a correction after the surge
--There is a recovery in Q4 2004 showing stabilization and growth though not as strong as the previous year
--There is another decline in 2005 suggesting a downturn perharps cyclical or tied to external actors

SELECT year_id, COUNT(DISTINCT ordernumber)  as no_of_orders
FROM sales
WHERE status IN ('Shipped','Resolved')
GROUP BY year_id
ORDER BY no_of_orders DESC
--2004 leads with highest number of orders at 140, 2003 having 103 then 2005 having 47

