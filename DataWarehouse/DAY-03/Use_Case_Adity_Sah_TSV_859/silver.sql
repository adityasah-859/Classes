--  Aditya Sah TSV-859

-- SET GLOBAL local_infile = 1;

DROP DATABASE IF EXISTS aditya_sah_TSV_859_silver_db;

CREATE DATABASE aditya_sah_TSV_859_silver_db; 
USE aditya_sah_TSV_859_silver_db;

CREATE TABLE aditya_sah_TSV_859_silver_db.silver_sales_raw(
	order_id VARCHAR(20),
    source_system VARCHAR(20),
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


ALTER TABLE aditya_sah_TSV_859_silver_db.silver_sales_raw ADD PRIMARY KEY(order_id);
SELECT * FROM aditya_sah_TSV_859_silver_db.silver_sales_raw;

INSERT INTO aditya_sah_TSV_859_silver_db.silver_sales_raw (
    order_id,
    source_system,
    customer_name,
    city,
    email,
    product_name,
    product_category,
    sale_date,
    quantity,
    unit_price,
    load_timestamp
)
SELECT
    order_id,
    source_system,
    TRIM(customer_name) AS customer_name,
    CASE 
        WHEN TRIM(city) IN ('Hyd', 'HYD') THEN 'Hyderabad'
        WHEN TRIM(city) IN ('NULL', 'null', '') OR city IS NULL THEN 'Hyderabad'
        WHEN TRIM(city) = 'NY' THEN 'New York'
        ELSE TRIM(city)
    END AS city,
    TRIM(email) AS email,
    TRIM(product_name),
    CASE WHEN product_category = '" Electronics"' THEN 'Electronics'
		ELSE product_category
	END AS product_category,
    sale_date,
    quantity,
    unit_price,
    load_timestamp
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY order_id 
               ORDER BY load_timestamp DESC
           ) AS rn
    FROM aditya_sah_TSV_859_bronze_db.bronze_sales_raw
    WHERE order_id IS NOT NULL
      AND product_category != 'Beauty'
) t
WHERE rn = 1;

SELECT * FROM aditya_sah_TSV_859_silver_db.silver_sales_raw ;

SELECT COUNT(*) FROM aditya_sah_TSV_859_silver_db.silver_sales_raw;

DESC aditya_sah_TSV_859_silver_db.silver_sales_raw;
