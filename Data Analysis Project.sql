CREATE TABLE samplesalesdata(
ordernumber INT NOT NULL, 
quantityordered INT NOT NULL,
priceeach DECIMAL (10,2) NOT NULL,
orderlinenumber INT NOT NULL,
sales DECIMAL (12,4) NOT NULL,
orderdate DATE NOT NULL,
status VARCHAR (255)NOT NULL,
quarter INT NOT NULL,
month INT NOT NULL,
year INT NOT NULL,
productline VARCHAR (255) NOT NULL,
msrp INT NOT NULL,
productcode VARCHAR (255) NOT NULL,
customername VARCHAR (255) NOT NULL,
address VARCHAR (255) NULL,
city VARCHAR (255)NOT NULL,
state VARCHAR (255) NULL,
postalcode VARCHAR (255) NULL,
country VARCHAR (255)NOT NULL,
territory VARCHAR (255) NULL,
lastname VARCHAR (255) NOT NULL,
firstname VARCHAR (255) NOT NULL,
dealsize VARCHAR (255) NOT NULL
);


----------------Data Analysis----------------------
Overview
-- 1. What is the total number of orders per year? 
SELECT year, COUNT(ordernumber) AS totalorders 
FROM samplesalesdata
GROUP BY year ORDER BY year ASC;

-- 2. What product lines are sold?  
SELECT DISTINCT productline FROM samplesalesdata;

-- 3. When was the first recorded sale?
SELECT MIN(orderdate) AS earliestdate 
FROM samplesalesdata;

-- 4. When was the most recent recorded sale?  
SELECT MAX(orderdate) AS latestdate 
FROM samplesalesdata;

Sales Performance
-- 1. What are the top 3 products that generate the highest revenue overall?
SELECT productline, SUM(sales) AS highestrevenue 
FROM samplesalesdata GROUP BY productline ORDER BY highestrevenue DESC LIMIT 3;

-- 2. Seasonality: Over the 3 year period, which quarter on average had the highest sales?
SELECT quarter, ROUND(AVG(sales),2) AS averagesales
FROM samplesalesdata GROUP BY quarter ORDER BY averagesales DESC; 

-- 3.How has yearly revenue changed over time?
SELECT year, 
SUM(sales) AS totalrevenue
FROM samplesalesdata
GROUP BY year ORDER BY year ASC;

-- 4. Which quarter experienced the largest revenue growth compared to the previous quarter?
SELECT 
    year,
    quarter,
    SUM(sales) AS revenue,
    ROUND(
        CASE 
            WHEN LAG(SUM(sales)) OVER (ORDER BY year, quarter) IS NULL 
                 OR LAG(SUM(sales)) OVER (ORDER BY year, quarter) = 0
            THEN 0
            ELSE 
                (SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY year, quarter))
                / LAG(SUM(sales)) OVER (ORDER BY year, quarter) * 100
        END,
        2
    ) AS pct_growth
FROM samplesalesdata
GROUP BY year, quarter
ORDER BY year, quarter;

Product Insights
-- 1. Which product lines are most popular in each country? 
SELECT country, productline, total_orders
FROM (
  	SELECT country,
           productline,
           COUNT(ordernumber) AS total_orders,
           RANK() OVER (PARTITION BY country ORDER BY COUNT(ordernumber) DESC) AS rnk
    FROM samplesalesdata
    GROUP BY country, productline
) ranked
WHERE rnk = 1
ORDER BY country;

-- 2. What’s the average selling price per product line?
SELECT productline, ROUND(AVG(priceeach),2) AS average_priceeach
FROM samplesalesdata GROUP BY productline ORDER BY average_priceeach DESC;

Customer Behavior
-- 1. What is the average order frequency per customer? 
SELECT AVG(order_count) AS average_order_frequency 
FROM(
	SELECT customername, COUNT(customername) AS order_count
	FROM samplesalesdata
	GROUP BY customername 
) AS customer_orders; 

-- 2. Which country has the highest customer spending? 
SELECT country, SUM(sales) AS customerspending 
FROM samplesalesdata
GROUP BY country ORDER BY customerspending DESC LIMIT 1;

Market Trends 
-- 1. What is the average deal size by country? 
SELECT country,
       ROUND(AVG(
           CASE dealsize
               WHEN 'Small' THEN 1
               WHEN 'Medium' THEN 2
               WHEN 'Large' THEN 3
           END
		  ),2) AS average_deal_size_number
FROM samplesalesdata
GROUP BY country;

-- 2. Which city has the highest revenue per customer? 
SELECT city, SUM(sales)/ COUNT(DISTINCT customername) 
AS revenuepercustomer
FROM samplesalesdata
GROUP BY city ORDER BY revenuepercustomer DESC LIMIT 1; 

-- 3. Which top 3 cities generated the highest revenue?
SELECT city, SUM(sales) AS revenue
FROM samplesalesdata
GROUP BY city ORDER BY revenue DESC LIMIT 3; 
