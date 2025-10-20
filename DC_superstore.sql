-- Data Cleaning

-- create a backup data
CREATE TABLE superstore_staging
LIKE superstore;

INSERT superstore_staging
SELECT *
FROM superstore;

SELECT *
FROM superstore_staging;

-- standardize order_date & ship_date format
SELECT Order_Date,
STR_TO_DATE(Order_Date, '%m/%d/%Y')
FROM superstore_staging;

SELECT Ship_Date,
STR_TO_DATE(Ship_Date, '%m/%d/%Y')
FROM superstore_staging;

UPDATE superstore_staging
SET Order_Date = STR_TO_DATE(Order_Date, '%m/%d/%Y'),
	Ship_Date = STR_TO_DATE(Ship_Date, '%m/%d/%Y');

 
ALTER TABLE superstore_staging
MODIFY COLUMN Order_Date DATE,
MODIFY COLUMN Ship_Date DATE;


-- change sales, discount & profit format to decimal
SELECT Sales, CAST(REPLACE(Sales, ',', '.') AS DECIMAL(10,3))
FROM superstore_staging;

UPDATE superstore_staging
SET Sales    = CAST(REPLACE(Sales, ',', '.') AS DECIMAL(10,3)),
    Discount = CAST(REPLACE(Discount, ',', '.') AS DECIMAL(5,2)),
    Profit   = CAST(REPLACE(Profit, ',', '.') AS DECIMAL(10,3));

ALTER TABLE superstore_staging
MODIFY COLUMN Sales DECIMAL(10,3),
MODIFY COLUMN Discount DECIMAL(5,2),
MODIFY COLUMN Profit DECIMAL(10,3);


-- check missing values
SELECT 
  SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
  SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
  SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
  SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS missing_sales,
  SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS missing_profit,
  SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS missing_quantity,
  SUM(CASE WHEN Discount IS NULL THEN 1 ELSE 0 END) AS missing_discount,
  SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
  SUM(CASE WHEN Ship_Date IS NULL THEN 1 ELSE 0 END) AS missing_ship_date
FROM superstore_staging;


-- check duplicates based on order_id + product_id
SELECT Order_ID, Product_ID, COUNT(*)
FROM superstore_staging
GROUP BY Order_ID, Product_ID
HAVING COUNT(*) > 1;


-- numeric column format and range validation
SELECT
  MIN(Sales) AS min_sales, MAX(Sales) AS max_sales,
  MIN(Profit) AS min_profit, MAX(Profit) AS max_profit,
  MIN(Quantity) AS min_quantity, MAX(Quantity) AS max_quantity,
  MIN(Discount) AS min_discount, MAX(Discount) AS max_discount
FROM superstore_staging;


    
-- Validate the relationship between the sales, quantity, discount, and profit columns
SELECT Order_ID, Product_ID, Sales, Quantity, Discount
FROM superstore_staging
WHERE Sales <=0 OR Discount < 0 OR Discount > 1;


-- product consistency validation
SELECT Product_ID, COUNT(DISTINCT Product_Name) AS name_count
FROM superstore_staging
GROUP BY Product_ID
HAVING COUNT(DISTINCT Product_Name) > 1;

SELECT Product_Name, COUNT(DISTINCT Product_ID) AS id_count
FROM superstore_staging
GROUP BY Product_Name
HAVING COUNT(DISTINCT Product_ID) > 1;



-- customer consistency validation
SELECT Customer_ID, COUNT(DISTINCT Customer_Name) AS name_count
FROM superstore_staging
GROUP BY Customer_ID
HAVING COUNT(DISTINCT Customer_Name) > 1;


-- date validation
SELECT Order_ID, Order_Date, Ship_Date
FROM superstore_staging
WHERE Ship_Date < Order_Date;


-- location data validation
SELECT City, COUNT(DISTINCT State) AS state_count
FROM superstore_staging
GROUP BY City
HAVING COUNT(DISTINCT State) > 1;

SELECT City, State
FROM superstore_staging
WHERE City = 'Arlington';

-- standardization of categorical values
SELECT DISTINCT Category 
FROM superstore_staging;

SELECT DISTINCT `Sub-Category` 
FROM superstore_staging;

SELECT DISTINCT Ship_Mode 
FROM superstore_staging;

