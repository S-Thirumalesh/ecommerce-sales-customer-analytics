USE ecommerce_analytics;
SELECT
    ROUND(SUM(i.sales), 2)                              AS total_sales,
    ROUND(SUM(i.profit), 2)                             AS total_profit,
    ROUND(SUM(i.profit) / SUM(i.sales) * 100, 2)        AS profit_margin_pct,
    COUNT(DISTINCT i.order_id)                          AS total_orders,
    COUNT(DISTINCT o.customer_id)                       AS total_customers,
    ROUND(SUM(i.sales) / COUNT(DISTINCT i.order_id), 2) AS avg_order_value
FROM order_items AS i
INNER JOIN orders AS o ON o.order_id = i.order_id;
SELECT
    yr,
    ROUND(total_sales, 2)  AS total_sales,
    ROUND(total_profit, 2) AS total_profit,
    ROUND((total_sales - LAG(total_sales) OVER (ORDER BY yr))
          / LAG(total_sales) OVER (ORDER BY yr) * 100, 2) AS sales_growth_pct
FROM (
    SELECT YEAR(o.order_date) AS yr,
           SUM(i.sales)       AS total_sales,
           SUM(i.profit)      AS total_profit
    FROM order_items AS i
    INNER JOIN orders AS o ON o.order_id = i.order_id
    GROUP BY YEAR(o.order_date)
) AS t
ORDER BY yr;

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m')  AS sales_month,
    ROUND(SUM(i.sales), 2)              AS total_sales,
    ROUND(SUM(i.profit), 2)             AS total_profit,
    COUNT(DISTINCT o.order_id)          AS total_orders
FROM order_items AS i
INNER JOIN orders AS o ON o.order_id = i.order_id
GROUP BY sales_month
ORDER BY sales_month;

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m')  AS sales_month,
    ROUND(SUM(i.sales), 2)              AS total_sales
FROM order_items AS i
INNER JOIN orders AS o ON o.order_id = i.order_id
GROUP BY sales_month
ORDER BY total_sales DESC
LIMIT 5;

SELECT
    MONTH(o.order_date)      AS month_number,
    MONTHNAME(o.order_date)  AS month_name,
    ROUND(SUM(i.sales), 2)   AS total_sales,
    ROUND(SUM(i.sales) / (SELECT SUM(sales) FROM order_items) * 100, 2) AS pct_of_total_sales
FROM order_items AS i
INNER JOIN orders AS o ON o.order_id = i.order_id
GROUP BY MONTH(o.order_date), MONTHNAME(o.order_date)
ORDER BY month_number;

SELECT
    p.category,
    ROUND(SUM(i.sales), 2)                       AS total_sales,
    ROUND(SUM(i.profit), 2)                      AS total_profit,
    ROUND(SUM(i.profit) / SUM(i.sales) * 100, 2) AS profit_margin_pct,
    SUM(i.quantity)                              AS units_sold
FROM order_items AS i
INNER JOIN products AS p ON p.product_key = i.product_key
GROUP BY p.category
ORDER BY total_sales DESC;

SELECT
    p.category,
    p.sub_category,
    ROUND(SUM(i.sales), 2)                       AS total_sales,
    ROUND(SUM(i.profit), 2)                      AS total_profit,
    ROUND(SUM(i.profit) / SUM(i.sales) * 100, 2) AS profit_margin_pct
FROM order_items AS i
INNER JOIN products AS p ON p.product_key = i.product_key
GROUP BY p.category, p.sub_category
ORDER BY total_profit DESC;

SELECT
    p.product_key,
    p.product_name,
    p.category,
    ROUND(SUM(i.sales), 2)  AS total_sales,
    ROUND(SUM(i.profit), 2) AS total_profit,
    SUM(i.quantity)         AS units_sold
FROM order_items AS i
INNER JOIN products AS p ON p.product_key = i.product_key
GROUP BY p.product_key, p.product_name, p.category
ORDER BY total_sales DESC
LIMIT 10;

SELECT COUNT(*) AS products_losing_money
FROM (
    SELECT p.product_key
    FROM order_items AS i
    INNER JOIN products AS p ON p.product_key = i.product_key
    GROUP BY p.product_key
    HAVING SUM(i.profit) < 0
) AS t;

SELECT
    o.region,
    ROUND(SUM(i.sales), 2)                       AS total_sales,
    ROUND(SUM(i.profit), 2)                      AS total_profit,
    ROUND(SUM(i.profit) / SUM(i.sales) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT o.order_id)                   AS total_orders,
    COUNT(DISTINCT o.customer_id)                AS total_customers
FROM order_items AS i
INNER JOIN orders AS o ON o.order_id = i.order_id
GROUP BY o.region
ORDER BY total_sales DESC;

SELECT
    o.state,
    o.region,
    ROUND(SUM(i.sales), 2)  AS total_sales,
    ROUND(SUM(i.profit), 2) AS total_profit
FROM order_items AS i
INNER JOIN orders AS o ON o.order_id = i.order_id
GROUP BY o.state, o.region
ORDER BY total_sales DESC
LIMIT 10;

SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(i.sales), 2)     AS total_sales,
    ROUND(SUM(i.profit), 2)    AS total_profit
FROM order_items AS i
INNER JOIN orders    AS o ON o.order_id    = i.order_id
INNER JOIN customers AS c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.segment
ORDER BY total_sales DESC
LIMIT 10;

SELECT order_count, COUNT(*) AS customers
FROM (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
) AS t
GROUP BY order_count
ORDER BY order_count;

SELECT
    ROUND((SELECT SUM(sales) FROM order_items) / (SELECT COUNT(*) FROM customers), 2)
        AS avg_sales_per_customer,
    (SELECT COUNT(*)
     FROM (
         SELECT o.customer_id
         FROM order_items AS i
         INNER JOIN orders AS o ON o.order_id = i.order_id
         GROUP BY o.customer_id
         HAVING SUM(i.sales) > (SELECT SUM(sales) FROM order_items) / (SELECT COUNT(*) FROM customers)
     ) AS t) AS customers_above_average;
     
SELECT
    discount,
    COUNT(*)                                     AS order_lines,
    ROUND(SUM(sales), 2)                         AS total_sales,
    ROUND(SUM(profit), 2)                        AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)     AS profit_margin_pct
FROM order_items
GROUP BY discount
ORDER BY discount;

