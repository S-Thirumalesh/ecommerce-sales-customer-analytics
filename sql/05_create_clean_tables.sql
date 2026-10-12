USE ecommerce_analytics;

-- Drop old versions first (children before parents), so this script can be re-run safely
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id   VARCHAR(20)  NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    segment       VARCHAR(30)  NOT NULL,
    PRIMARY KEY (customer_id)
);

CREATE TABLE products (
    product_key   INT          NOT NULL AUTO_INCREMENT,
    product_id    VARCHAR(30)  NOT NULL,
    product_name  VARCHAR(255) NOT NULL,
    category      VARCHAR(50)  NOT NULL,
    sub_category  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (product_key),
    UNIQUE KEY uq_product (product_id, product_name)
);

CREATE TABLE orders (
    order_id     VARCHAR(30)  NOT NULL,
    order_date   DATE         NOT NULL,
    ship_date    DATE         NOT NULL,
    ship_mode    VARCHAR(30)  NOT NULL,
    customer_id  VARCHAR(20)  NOT NULL,
    country      VARCHAR(50)  NOT NULL,
    state        VARCHAR(100) NOT NULL,
    city         VARCHAR(100) NOT NULL,
    postal_code  VARCHAR(20)  NOT NULL,
    region       VARCHAR(30)  NOT NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);

CREATE TABLE order_items (
    row_id       INT           NOT NULL,
    order_id     VARCHAR(30)   NOT NULL,
    product_key  INT           NOT NULL,
    sales        DECIMAL(12,4) NOT NULL,
    quantity     INT           NOT NULL,
    discount     DECIMAL(4,2)  NOT NULL,
    profit       DECIMAL(12,4) NOT NULL,
    PRIMARY KEY (row_id),
    FOREIGN KEY (order_id)    REFERENCES orders (order_id),
    FOREIGN KEY (product_key) REFERENCES products (product_key)
);

SHOW TABLES;