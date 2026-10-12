USE ecommerce_analytics;
SELECT
    SUM(LOCATE(UNHEX('C2A0'), CAST(`Product Name`  AS BINARY)) > 0) AS product_name,
    SUM(LOCATE(UNHEX('C2A0'), CAST(`Customer Name` AS BINARY)) > 0) AS customer_name,
    SUM(LOCATE(UNHEX('C2A0'), CAST(`City`          AS BINARY)) > 0) AS city,
    SUM(LOCATE(UNHEX('C2A0'), CAST(`State`         AS BINARY)) > 0) AS state,
    SUM(LOCATE(UNHEX('C2A0'), CAST(`Category`      AS BINARY)) > 0) AS category,
    SUM(LOCATE(UNHEX('C2A0'), CAST(`Sub-Category`  AS BINARY)) > 0) AS sub_category,
    SUM(LOCATE(UNHEX('C2A0'), CAST(`Product ID`    AS BINARY)) > 0) AS product_id,
    SUM(LOCATE(UNHEX('C2A0'), CAST(`Customer ID`   AS BINARY)) > 0) AS customer_id,
    SUM(LOCATE(UNHEX('C2A0'), CAST(`Order ID`      AS BINARY)) > 0) AS order_id
FROM stg_superstore;

SELECT s.*
FROM stg_superstore AS s
INNER JOIN (
    SELECT `Order ID`, `Product ID`, `Sales`, `Quantity`, `Discount`, `Profit`
    FROM stg_superstore
    GROUP BY `Order ID`, `Product ID`, `Sales`, `Quantity`, `Discount`, `Profit`
    HAVING COUNT(*) > 1
) AS d
  ON  s.`Order ID`   = d.`Order ID`
  AND s.`Product ID` = d.`Product ID`
  AND s.`Sales`      = d.`Sales`
  AND s.`Quantity`   = d.`Quantity`
  AND s.`Discount`   = d.`Discount`
  AND s.`Profit`     = d.`Profit`
ORDER BY s.`Order ID`, s.`Row ID`;

SELECT `Product ID`, `Product Name`, COUNT(*) AS rows_count
FROM stg_superstore
WHERE `Product ID` IN (
    SELECT `Product ID`
    FROM stg_superstore
    GROUP BY `Product ID`
    HAVING COUNT(DISTINCT `Product Name`) > 1
)
GROUP BY `Product ID`, `Product Name`
ORDER BY `Product ID`, rows_count DESC;

SELECT
  (SELECT COUNT(*) FROM (SELECT `Order ID` FROM stg_superstore GROUP BY `Order ID` HAVING COUNT(DISTINCT `Ship Date`)   > 1) a) AS orders_many_ship_dates,
  (SELECT COUNT(*) FROM (SELECT `Order ID` FROM stg_superstore GROUP BY `Order ID` HAVING COUNT(DISTINCT `Ship Mode`)   > 1) b) AS orders_many_ship_modes,
  (SELECT COUNT(*) FROM (SELECT `Order ID` FROM stg_superstore GROUP BY `Order ID` HAVING COUNT(DISTINCT `City`)        > 1) c) AS orders_many_cities,
  (SELECT COUNT(*) FROM (SELECT `Order ID` FROM stg_superstore GROUP BY `Order ID` HAVING COUNT(DISTINCT `State`)       > 1) d) AS orders_many_states,
  (SELECT COUNT(*) FROM (SELECT `Order ID` FROM stg_superstore GROUP BY `Order ID` HAVING COUNT(DISTINCT `Postal Code`) > 1) e) AS orders_many_postal_codes,
  (SELECT COUNT(*) FROM (SELECT `State`    FROM stg_superstore GROUP BY `State`    HAVING COUNT(DISTINCT `Region`)      > 1) f) AS states_many_regions,
  (SELECT COUNT(*) FROM (SELECT `Customer ID` FROM stg_superstore GROUP BY `Customer ID` HAVING COUNT(DISTINCT `Segment`) > 1) g) AS customers_many_segments,
  (SELECT COUNT(*) FROM (SELECT `Customer ID` FROM stg_superstore GROUP BY `Customer ID` HAVING COUNT(DISTINCT `State`)   > 1) h) AS customers_many_states,
  (SELECT COUNT(*) FROM (SELECT `Product ID` FROM stg_superstore GROUP BY `Product ID` HAVING COUNT(DISTINCT `Category`)     > 1) i) AS products_many_categories,
  (SELECT COUNT(*) FROM (SELECT `Product ID` FROM stg_superstore GROUP BY `Product ID` HAVING COUNT(DISTINCT `Sub-Category`) > 1) j) AS products_many_subcategories;