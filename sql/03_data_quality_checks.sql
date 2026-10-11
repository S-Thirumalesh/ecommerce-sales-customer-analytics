USE ecommerce_analytics;
SELECT COUNT(*) AS rows_with_nbsp
FROM stg_superstore
WHERE `Product Name` LIKE CONCAT('%', CHAR(160 USING latin1), '%');
SELECT HEX(`Product Name`) AS name_in_hex
FROM stg_superstore
WHERE `Product Name` LIKE 'Konftel 250%'
LIMIT 1;
# Check 1: Blank values
SELECT
    SUM(`Order ID`     = '') AS blank_order_id,
    SUM(`Order Date`   = '') AS blank_order_date,
    SUM(`Customer ID`  = '') AS blank_customer_id,
    SUM(`Product ID`   = '') AS blank_product_id,
    SUM(`Postal Code`  = '') AS blank_postal_code,
    SUM(`Sales`        = '') AS blank_sales,
    SUM(`Quantity`     = '') AS blank_quantity,
    SUM(`Discount`     = '') AS blank_discount,
    SUM(`Profit`       = '') AS blank_profit
FROM stg_superstore;
# Check 2: Is Row ID unique?
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT `Row ID`) AS unique_row_ids
FROM stg_superstore;
# Check 3: Which values exist in the text columns?
SELECT `Ship Mode`, COUNT(*) AS rows_count
FROM stg_superstore
GROUP BY `Ship Mode`
ORDER BY rows_count DESC;

SELECT `Segment`, COUNT(*) AS rows_count
FROM stg_superstore
GROUP BY `Segment`
ORDER BY rows_count DESC;

SELECT `Country`, COUNT(*) AS rows_count
FROM stg_superstore
GROUP BY `Country`;

SELECT `Region`, COUNT(*) AS rows_count
FROM stg_superstore
GROUP BY `Region`
ORDER BY rows_count DESC;

SELECT `Category`, `Sub-Category`, COUNT(*) AS rows_count
FROM stg_superstore
GROUP BY `Category`, `Sub-Category`
ORDER BY `Category`, `Sub-Category`;

# Check 4: Number ranges
SELECT
    MIN(CAST(`Quantity` AS SIGNED))        AS min_quantity,
    MAX(CAST(`Quantity` AS SIGNED))        AS max_quantity,
    MIN(CAST(`Sales`    AS DECIMAL(12,4))) AS min_sales,
    MAX(CAST(`Sales`    AS DECIMAL(12,4))) AS max_sales,
    MIN(CAST(`Discount` AS DECIMAL(5,2)))  AS min_discount,
    MAX(CAST(`Discount` AS DECIMAL(5,2)))  AS max_discount,
    MIN(CAST(`Profit`   AS DECIMAL(12,4))) AS min_profit,
    MAX(CAST(`Profit`   AS DECIMAL(12,4))) AS max_profit
FROM stg_superstore;

# Check 5: Dates
SELECT
    MIN(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS first_order_date,
    MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS last_order_date,
    SUM(STR_TO_DATE(`Order Date`, '%m/%d/%Y') IS NULL) AS unreadable_order_dates,
    SUM(STR_TO_DATE(`Ship Date`,  '%m/%d/%Y') IS NULL) AS unreadable_ship_dates,
    SUM(STR_TO_DATE(`Ship Date`,  '%m/%d/%Y') < STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS shipped_before_ordered
FROM stg_superstore;

# Check 6: Duplicates
SELECT COUNT(*) AS repeated_groups
FROM (
    SELECT `Order ID`, `Product ID`, `Sales`, `Quantity`, `Discount`, `Profit`,
           COUNT(*) AS times_seen
    FROM stg_superstore
    GROUP BY `Order ID`, `Product ID`, `Sales`, `Quantity`, `Discount`, `Profit`
    HAVING COUNT(*) > 1
) AS t;

# Check 7: Is the data consistent? (This decides our table design.)
SELECT
  (SELECT COUNT(DISTINCT `Customer ID`) FROM stg_superstore) AS customers,
  (SELECT COUNT(DISTINCT `Product ID`)  FROM stg_superstore) AS products,
  (SELECT COUNT(*) FROM (SELECT `Customer ID` FROM stg_superstore
        GROUP BY `Customer ID` HAVING COUNT(DISTINCT `Customer Name`) > 1) a) AS customers_with_many_names,
  (SELECT COUNT(*) FROM (SELECT `Product ID` FROM stg_superstore
        GROUP BY `Product ID` HAVING COUNT(DISTINCT `Product Name`) > 1) b) AS products_with_many_names,
  (SELECT COUNT(*) FROM (SELECT `Order ID` FROM stg_superstore
        GROUP BY `Order ID` HAVING COUNT(DISTINCT `Customer ID`) > 1) c) AS orders_with_many_customers,
  (SELECT COUNT(*) FROM (SELECT `Order ID` FROM stg_superstore
        GROUP BY `Order ID` HAVING COUNT(DISTINCT `Order Date`) > 1) d) AS orders_with_many_dates;