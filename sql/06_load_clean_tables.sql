USE ecommerce_analytics;

-- 1) Customers: one row per customer
INSERT INTO customers (customer_id, customer_name, segment)
SELECT DISTINCT `Customer ID`, `Customer Name`, `Segment`
FROM stg_superstore;

-- 2) Products: one row per (Product ID, Product Name) pair.
--    The hidden character (bytes C2A0) is replaced with a normal space.
INSERT INTO products (product_id, product_name, category, sub_category)
SELECT DISTINCT
    `Product ID`,
    TRIM(REPLACE(`Product Name`, CONVERT(UNHEX('C2A0') USING utf8mb4), ' ')),
    `Category`,
    `Sub-Category`
FROM stg_superstore
ORDER BY `Product ID`, 2;

-- 3) Orders: one row per order. Text dates are converted to real dates.
INSERT INTO orders (order_id, order_date, ship_date, ship_mode, customer_id,
                    country, state, city, postal_code, region)
SELECT DISTINCT
    `Order ID`,
    STR_TO_DATE(`Order Date`, '%m/%d/%Y'),
    STR_TO_DATE(`Ship Date`,  '%m/%d/%Y'),
    `Ship Mode`,
    `Customer ID`,
    `Country`,
    `State`,
    `City`,
    `Postal Code`,
    `Region`
FROM stg_superstore;

-- 4) Order items: one row per line. Row ID 3407 is left out
--    because it repeats Row ID 3406 exactly (assumed double entry).
INSERT INTO order_items (row_id, order_id, product_key, sales, quantity, discount, profit)
SELECT
    CAST(s.`Row ID` AS UNSIGNED),
    s.`Order ID`,
    p.product_key,
    CAST(s.`Sales`    AS DECIMAL(12,4)),
    CAST(s.`Quantity` AS UNSIGNED),
    CAST(s.`Discount` AS DECIMAL(4,2)),
    CAST(s.`Profit`   AS DECIMAL(12,4))
FROM stg_superstore AS s
INNER JOIN products AS p
        ON  p.product_id   = s.`Product ID`
        AND p.product_name = TRIM(REPLACE(s.`Product Name`, CONVERT(UNHEX('C2A0') USING utf8mb4), ' '))
WHERE s.`Row ID` <> '3407';

SELECT 'customers' AS table_name, COUNT(*) AS rows_count FROM customers
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;

SELECT
    ROUND(st.total_sales - cl.total_sales, 4)   AS sales_difference,
    ROUND(st.total_profit - cl.total_profit, 4) AS profit_difference
FROM (SELECT SUM(CAST(`Sales`  AS DECIMAL(14,4))) AS total_sales,
             SUM(CAST(`Profit` AS DECIMAL(14,4))) AS total_profit
      FROM stg_superstore) AS st,
     (SELECT SUM(sales) AS total_sales, SUM(profit) AS total_profit
      FROM order_items) AS cl;

SELECT SUM(LOCATE(UNHEX('C2A0'), CAST(product_name AS BINARY)) > 0) AS products_with_hidden_char
FROM products;

SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order,
       SUM(ship_date < order_date) AS shipped_before_ordered
FROM orders;

SELECT o.order_id, o.order_date, c.customer_name, p.product_name,
       i.sales, i.quantity, i.profit
FROM order_items AS i
INNER JOIN orders    AS o ON o.order_id    = i.order_id
INNER JOIN customers AS c ON c.customer_id = o.customer_id
INNER JOIN products  AS p ON p.product_key = i.product_key
ORDER BY o.order_date, o.order_id
LIMIT 5;