# create table
SELECT VERSION();
CREATE DATABASE ecommerce_analytics;
SHOW DATABASES;
USE ecommerce_analytics;
CREATE TABLE stg_superstore (
    `Row ID`        VARCHAR(20),
    `Order ID`      VARCHAR(30),
    `Order Date`    VARCHAR(20),
    `Ship Date`     VARCHAR(20),
    `Ship Mode`     VARCHAR(30),
    `Customer ID`   VARCHAR(20),
    `Customer Name` VARCHAR(100),
    `Segment`       VARCHAR(30),
    `Country`       VARCHAR(50),
    `City`          VARCHAR(100),
    `State`         VARCHAR(100),
    `Postal Code`   VARCHAR(20),
    `Region`        VARCHAR(30),
    `Product ID`    VARCHAR(30),
    `Category`      VARCHAR(50),
    `Sub-Category`  VARCHAR(50),
    `Product Name`  VARCHAR(255),
    `Sales`         VARCHAR(30),
    `Quantity`      VARCHAR(10),
    `Discount`      VARCHAR(10),
    `Profit`        VARCHAR(30)
);
