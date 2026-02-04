USE demo;

CREATE TABLE sales(
	store_id VARCHAR(50),
    store_name VARCHAR(50),
    product_category VARCHAR(50),
    _date DATE,
    unit_sales FLOAT,
    dollar_sales FLOAT,
    store_zip INT,
    promotion_flag BOOL
);

ALTER TABLE sales MODIFY COLUMN promotion_flag VARCHAR(50);
ALTER TABLE sales MODIFY COLUMN store_zip VARCHAR(50);

TRUNCATE TABLE sales;

LOAD DATA LOCAL INFILE '/Users/as-mac-1346/Desktop/Classes/DataWarehouse/DAY-04/sales_2024-09-01.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM sales;

SET SESSION sql_mode = '';

-- Top 3 revenue by sales

SELECT store_id, store_name, ROUND(SUM(dollar_sales),2) AS revenue
FROM sales
GROUP BY store_id
ORDER BY revenue DESC
LIMIT 3;


