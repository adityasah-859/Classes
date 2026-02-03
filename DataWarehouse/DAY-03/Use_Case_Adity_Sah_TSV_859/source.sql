--  Aditya Sah TSV-859

-- SET GLOBAL local_infile = 1;

DROP DATABASE IF EXISTS aditya_sah_TSV_859_source_db;

CREATE DATABASE aditya_sah_TSV_859_source_db; 
USE aditya_sah_TSV_859_source_db;

CREATE TABLE aditya_sah_TSV_859_source_db.sales_raw_source1(
	order_id VARCHAR(20),
    customer_name VARCHAR(100),
    city VARCHAR(50),
    email VARCHAR(100),
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    sale_date DATE,
    quantity INT,
    unit_price DECIMAL(10,2),
    load_timestamp TIMESTAMP
);

LOAD DATA LOCAL INFILE '/Users/as-mac-1346/Desktop/Classes/DataWarehouse/DAY-03/source1.csv' 
INTO TABLE aditya_sah_TSV_859_source_db.sales_raw_source1
FIELDS TERMINATED BY ',' IGNORE 1 LINES;

SELECT * FROM aditya_sah_TSV_859_source_db.sales_raw_source1 ORDER BY load_timestamp, order_id;

CREATE TABLE aditya_sah_TSV_859_source_db.sales_raw_source2(
	order_id VARCHAR(20),
    customer_name VARCHAR(100),
    city VARCHAR(50),
    email VARCHAR(100),
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    sale_date DATE,
    quantity INT,
    unit_price DECIMAL(10,2),
    load_timestamp TIMESTAMP
);

LOAD DATA LOCAL INFILE '/Users/as-mac-1346/Desktop/Classes/DataWarehouse/DAY-03/source2.csv' 
INTO TABLE aditya_sah_TSV_859_source_db.sales_raw_source2
FIELDS TERMINATED BY ',' IGNORE 1 LINES;

SELECT * FROM aditya_sah_TSV_859_source_db.sales_raw_source2 ORDER BY load_timestamp, order_id;

