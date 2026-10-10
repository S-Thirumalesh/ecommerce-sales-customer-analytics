#  load data
DESCRIBE stg_superstore;
TRUNCATE TABLE stg_superstore;
SELECT COUNT(*) FROM stg_superstore;
TRUNCATE TABLE stg_superstore;
SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/superstore.csv'
INTO TABLE stg_superstore
CHARACTER SET latin1
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SELECT COUNT(*) AS total_rows FROM stg_superstore;
SELECT * FROM stg_superstore WHERE `Order ID` = 'Order ID';
SELECT * FROM stg_superstore LIMIT 5;
SELECT COUNT(*) AS bad_rows FROM stg_superstore WHERE `Profit` LIKE '%\r%';
SELECT COUNT(DISTINCT `Order ID`) AS total_orders FROM stg_superstore;
SELECT DISTINCT `Product Name`
FROM stg_superstore
WHERE `Product Name` REGEXP '[^ -~]'
LIMIT 10;