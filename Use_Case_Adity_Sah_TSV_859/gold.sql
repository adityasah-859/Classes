--  Aditya Sah TSV-859

-- SET GLOBAL local_infile = 1;


DROP DATABASE IF EXISTS aditya_sah_TSV_859_gold_db;

CREATE DATABASE aditya_sah_TSV_859_gold_db; 
USE aditya_sah_TSV_859_gold_db;


-- dim_customers

CREATE TABLE aditya_sah_TSV_859_gold_db.dim_customers (
    customer_key INT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    customer_name VARCHAR(255),
    city VARCHAR(100),
    last_seen_ts DATETIME
);




INSERT INTO aditya_sah_TSV_859_gold_db.dim_customers (
    customer_key,
    email,
    customer_name,
    city,
    last_seen_ts
)
SELECT
    ROW_NUMBER() OVER (ORDER BY email) AS customer_key,
    email,
    customer_name,
    city,
    load_timestamp AS last_seen_ts
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY email
               ORDER BY load_timestamp DESC
           ) AS rn
    FROM aditya_sah_TSV_859_silver_db.silver_sales_raw
    WHERE email IS NOT NULL
) t
WHERE rn = 1;

SELECT * FROM aditya_sah_TSV_859_gold_db.dim_customers;

-- dim_products

CREATE TABLE aditya_sah_TSV_859_gold_db.dim_product AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_name, product_category) AS product_key,
    product_name,
    product_category
FROM (
    SELECT DISTINCT product_name, product_category
    FROM aditya_sah_TSV_859_silver_db.silver_sales_raw
) t;

TRUNCATE TABLE aditya_sah_TSV_859_gold_db.dim_product;

INSERT INTO aditya_sah_TSV_859_gold_db.dim_product (product_key, product_name, product_category)
SELECT
    ROW_NUMBER() OVER (ORDER BY product_name, product_category) AS product_key,
    product_name,
    product_category 
FROM (
    SELECT DISTINCT product_name, product_category
    FROM aditya_sah_TSV_859_silver_db.silver_sales_raw
    WHERE product_name IS NOT NULL
      AND product_category IS NOT NULL
) t;


ALTER TABLE aditya_sah_TSV_859_gold_db.dim_product
MODIFY COLUMN product_key INT NOT NULL PRIMARY KEY;

SELECT * FROM aditya_sah_TSV_859_gold_db.dim_product;


-- dim_fact_sales

CREATE TABLE IF NOT EXISTS aditya_sah_TSV_859_gold_db.fact_sales (
    sales_key INT PRIMARY KEY AUTO_INCREMENT,
    order_id VARCHAR(50),
    customer_key INT,
    product_key INT,
    sale_date DATE,
    quantity INT,
    unit_price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    load_timestamp DATETIME,
    FOREIGN KEY (customer_key) REFERENCES dim_customers(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key)
);





INSERT INTO aditya_sah_TSV_859_gold_db.fact_sales (
    order_id,
    customer_key,
    product_key,
    sale_date,
    quantity,
    unit_price,
    total_amount,
    load_timestamp
)
SELECT
    s.order_id,
    c.customer_key,
    p.product_key,
    s.sale_date,
    s.quantity,
    s.unit_price,
    ROUND(s.quantity * s.unit_price,2) AS total_amount,
    s.load_timestamp
FROM aditya_sah_TSV_859_silver_db.silver_sales_raw s
JOIN aditya_sah_TSV_859_gold_db.dim_customers c
    ON s.email = c.email
JOIN aditya_sah_TSV_859_gold_db.dim_product p
    ON s.product_name = p.product_name
   AND s.product_category = p.product_category;

SELECT * FROM aditya_sah_TSV_859_gold_db.fact_sales;

SELECT COUNT(*) FROM aditya_sah_TSV_859_gold_db.dim_customers;
SELECT COUNT(*) FROM aditya_sah_TSV_859_gold_db.dim_product;
SELECT COUNT(*) FROM aditya_sah_TSV_859_gold_db.fact_sales;


SELECT * FROM aditya_sah_TSV_859_gold_db.fact_sales ORDER BY sale_date, order_id;