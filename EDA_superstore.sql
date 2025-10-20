-- Exploratory Data Analysis (EDA)

SELECT *
FROM superstore_staging;

-- data understanding
-- total rows & columns important
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT Order_ID) AS total_orders,
COUNT(DISTINCT Customer_ID) AS total_customers
FROM superstore_staging;

-- range order date
SELECT MIN(Order_Date) AS first_order, MAX(Order_Date) AS last_order
FROM superstore_staging;


-- univariate analysis
-- product category distribution
SELECT Category, COUNT(*) AS total_orders, SUM(Sales) AS total_sales
FROM superstore_staging
GROUP BY Category
ORDER BY total_sales DESC;

-- customer segment distribution
SELECT Segment, COUNT(DISTINCT Customer_ID) AS total_customers, SUM(Sales) AS total_sales
FROM superstore_staging
GROUP BY Segment;

-- general sales statistics
SELECT
	ROUND(AVG(Sales),2) AS avg_sales,
    SUM(Sales) AS total_sales,
    ROUND(AVG(Profit),2) AS avg_profit,
    SUM(Profit) AS total_profit,
    ROUND(AVG(Quantity),2) AS avg_quantity,
    ROUND(AVG(Discount),2) AS avg_discount
FROM superstore_staging;


-- revenue & profitability
-- revenue vs profit
SELECT
	SUM(Sales) AS net_revenue_after_discount,
    ROUND(SUM(Sales/(1-Discount)), 3) AS gross_revenue_before_discount,
    SUM(Profit) AS total_profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2) AS profit_margin
FROM superstore_staging;


-- bivariate analysis
-- sales & profit per category
SELECT Category,
	SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2) AS profit_margin
FROM superstore_staging
GROUP BY Category
ORDER BY total_sales DESC;

-- discount vs profit margin
SELECT Discount,
	SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2) AS profit_margin
FROM superstore_staging
GROUP BY Discount
ORDER BY Discount;


-- quantity & discount behavior
-- average quantity per discount level
SELECT Discount,
	ROUND(AVG(Quantity), 2) AS avg_qty,
    ROUND(AVG(Sales), 2) AS avg_sales,
    ROUND(AVG(Profit), 2) AS avg_profit
FROM superstore_staging
GROUP BY Discount
ORDER BY Discount;


-- time series analysis
-- monthly sales
SELECT DATE_FORMAT(Order_Date, '%Y-%m') AS bulan,
	SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM superstore_staging
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY bulan;

-- delivery time
SELECT AVG(DATEDIFF(Ship_Date, Order_Date)) AS avg_shipping_days
FROM superstore_staging;

    
-- customer analysis
-- top 10 customers by sales
SELECT Customer_Name, SUM(Sales) AS total_sales, SUM(Profit) AS total_profit
FROM superstore_staging
GROUP BY Customer_Name
ORDER BY total_sales DESC
LIMIT 10;

-- repeat vs one-time customers
WITH customer_orders AS (
    SELECT Customer_ID, COUNT(DISTINCT Order_ID) AS order_count
    FROM superstore_staging
    GROUP BY Customer_ID
)
SELECT COUNT(Customer_ID) AS total_customers,
       SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
       SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END) AS one_time_customers
FROM customer_orders;


-- geospatial analysis
-- sales per region
SELECT Region, SUM(Sales) AS total_sales, SUM(Profit) AS total_profit
FROM superstore_staging
GROUP BY Region
ORDER BY total_sales DESC;

-- top 5 states by revenue
SELECT State, SUM(Sales) AS total_sales, SUM(Profit) AS total_profit
FROM superstore_staging
GROUP BY State
ORDER BY total_sales DESC
LIMIT 5;


-- product profitability
-- lowest margin products
SELECT Product_Name,
	SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2) AS profit_margin
FROM superstore_staging
GROUP BY Product_Name
HAVING SUM(Sales) > 1000 -- filter to only show significant products
ORDER BY profit_margin ASC
LIMIT 10;
