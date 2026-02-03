--  Aditya Sah TSV-859

-- SET GLOBAL local_infile = 1;

DROP DATABASE IF EXISTS aditya_sah_TSV_859_bronze_db;

CREATE DATABASE aditya_sah_TSV_859_bronze_db; 
USE aditya_sah_TSV_859_bronze_db;


CREATE TABLE aditya_sah_TSV_859_bronze_db.bronze_sales_raw(
	order_id VARCHAR(20),
    customer_name VARCHAR(100),
    city VARCHAR(50),
    email VARCHAR(100),
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    sale_date DATE,
    quantity INT,
    unit_price DECIMAL(10,2),
    load_timestamp TIMESTAMP,
    source_system VARCHAR(20)
);

INSERT INTO aditya_sah_TSV_859_bronze_db.bronze_sales_raw (
SELECT * , 'flipkart' AS source_system FROM aditya_sah_TSV_859_source_db.sales_raw_source1)
UNION 
(SELECT * , 'amazon' AS source_system FROM aditya_sah_TSV_859_source_db.sales_raw_source2);

SELECT * FROM aditya_sah_TSV_859_bronze_db.bronze_sales_raw ORDER BY order_id;

