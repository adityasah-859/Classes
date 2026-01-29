USE retail_db;
SELECT DISTINCT order_status
FROM orders
ORDER BY order_status;

EXPLAIN
SELECT DISTINCT order_status -- <-- Here the query cost is very high
FROM orders
ORDER BY order_status;

CREATE INDEX idx_orders_order_status ON orders(order_status); -- <-- This Reduces the query cost to greater extent

EXPLAIN ANALYZE
SELECT DISTINCT order_status
FROM orders
ORDER BY order_status;



-- Next Sheet --

CREATE DATABASE IF NOT EXISTS retail_analytics;
USE retail_analytics;

CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    category VARCHAR(50),
    product_name VARCHAR(100),
    total_sales INT
);

INSERT INTO products (category, product_name, total_sales) VALUES
('Electronics', 'iPhone 17', 120),
('Electronics', 'Samsung Galaxy S25', 115),
('Electronics', 'OnePlus Nord CE5', 115),
('Electronics', 'Redmi A4', 100),
('Electronics', 'Vivo V27', 100),
('Electronics', 'Realme Narzo', 95),
('Electronics', 'Samsung Galaxy A55', 90),
('Electronics', 'iPhone 16 Pro', 85);

SELECT * FROM products;

-- ROW_NUMBER() OVER()

SELECT 
	product_name,
    total_sales,
	ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS row_num, 
    RANK() OVER(ORDER BY total_sales DESC) AS rank_num,
    DENSE_RANK() OVER(ORDER BY total_sales DESC) AS dense_rank_num,
    NTILE(4) OVER(ORDER BY total_sales DESC) AS performance_bucket  -- <-- Divides approximately into equal groups
FROM products;



CREATE TABLE sales (
    order_id   INT,
    order_date DATE,
    product    VARCHAR(50),
    amount     INT
);

INSERT INTO sales VALUES
(1, '2025-01-05', 'Laptop', 1000),
(2, '2025-01-10', 'Phone',  500),
(3, '2025-01-20', 'Tablet', 300),
(4, '2025-02-02', 'Laptop', 1200),
(5, '2025-02-05', 'Phone',  600),
(6, '2025-02-15', 'Tablet', 400);

SELECT *
FROM sales
ORDER BY order_date;

SELECT 
	order_id,
    order_date,
    product,
    amount,
    DATE_FORMAT(order_date,'%Y-%m') AS order_month
FROM sales
ORDER BY order_date;


SELECT 
    DATE_FORMAT(order_date,'%Y-%m') AS order_month,
    SUM(amount) AS revenuePerMonth
FROM sales
GROUP BY DATE_FORMAT(order_date,'%Y-%m');



SELECT 
    order_id,
    order_date,
    product,
    amount,
    SUM(amount) OVER (ORDER BY order_date) AS running_total
FROM sales;




SELECT
    order_id,
    order_date,
    product,
    amount,
    SUM(amount) OVER (
    PARTITION BY DATE_FORMAT(order_date,'%Y-%m')
    ORDER BY order_date) AS running_total
FROM sales;


SELECT
    order_id,
    order_date,
    product,
    amount,
    LEAD(amount) OVER (
    PARTITION BY DATE_FORMAT(order_date,'%Y-%m')
    ORDER BY order_date) AS next_order_amount,
    SUM(amount) OVER (
    PARTITION BY DATE_FORMAT(order_date,'%Y-%m')
    ORDER BY order_date) AS running_total
FROM sales;



SELECT 
	order_id,
    order_date,
    product,
    amount,
    LAG(amount) OVER(
    PARTITION BY DATE_FORMAT(order_date, '%y-%m')
    ORDER BY order_date) AS previous_order_amount,
    SUM(amount) OVER(
    PARTITION BY DATE_FORMAT(order_date,'%y-%m')
    ORDER BY order_date) AS running_total
FROM sales;



