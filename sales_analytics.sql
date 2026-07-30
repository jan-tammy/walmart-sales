CREATE DATABASE walmart_analytics;
USE walmart_analytics;

-- verify that tables have been loaded
SELECT distinct(store)
FROM sales;

SELECT store
FROM stores;

SELECT COUNT(*) 
FROM features;

-- Standardize data types 
ALTER TABLE sales 
MODIFY Date DATE;

ALTER TABLE features
MODIFY Date DATE;

USE walmart_analytics;

DESCRIBE features;

describe sales;

describe stores;

-- Data Cleaning and Validation
SELECT Store, Dept, Date, COUNT(*) FROM sales GROUP BY Store, Dept, Date HAVING COUNT(*) > 1;
-- There are no duplicate rows for the same combination of Store, Dept, and Date. 

SELECT COUNT(*) FROM sales WHERE Weekly_Sales IS NULL OR Store IS NULL;
-- No NULL values for sales.

SELECT COUNT(*) FROM sales WHERE Weekly_Sales < 0;
-- There are 1285 weeks where weekly sales go below 0, meaning there could have been more returns than sales, or quality issues.

-- Verify that each Store in sales corresponds to a Store in stores
SELECT DISTINCT st.Store FROM stores st
LEFT JOIN sales s ON st.Store = s.Store
WHERE s.Store IS NULL;
-- it does

-- Verify that each Store+Date combination in features exists in sales
SELECT DISTINCT s.Store, s.Date FROM sales s
LEFT JOIN features f ON s.Store = f.Store AND s.Date = f.Date
WHERE f.Store IS NULL OR f.Date IS NULL;
-- it does

-- confirm date range is the same in sales and features
SELECT MIN(s.Date) AS sales_low, MAX(s.Date) AS sales_high,
MIN(f.Date) AS feats_low, MAX(f.Date) AS feats_high
FROM sales s INNER JOIN features f
ON s.Store = f.Store AND s.Date = f.Date;
-- same range

-- aggegate sales on store-week level first
CREATE VIEW sales_store_week AS
SELECT Store, Date, IsHoliday, SUM(Weekly_Sales) AS Total_Weekly_Sales
FROM sales
GROUP BY Store, Date, IsHoliday;

-- combine tables
CREATE VIEW master_sales AS
SELECT 
	sw.Store, sw.Date, sw.Total_Weekly_Sales, sw.IsHoliday,
    st.Type AS store_type, st.Size AS store_size,
    f. Temperature, f.Fuel_Price, f.Markdown1, f.Markdown2, f.Markdown3, f.Markdown4, f.Markdown5, f.CPI, f.Unemployment
FROM sales_store_week sw
JOIN stores st ON sw.Store = st.Store
JOIN features f ON sw.Store = f.Store AND sw.Date = f.Date;

SELECT * FROM master_sales;

SELECT COUNT(*) AS null_markdown_rows
FROM master_sales
WHERE Markdown4 IS NULL;