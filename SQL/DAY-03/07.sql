USE retail_db;
SELECT * FROM orders;

SELECT 
	order_id,
    order_date,
    order_status,
    CASE                                                   -- <-- CASE Staments
		WHEN order_status IN("COMPLETE","CLOSED")
			THEN 'No Action Needed'
		WHEN order_status IN("PENDING_PAYMENT",
							"PROCESSING",
                            "PAYMENT_REVIEW",
                            "PENDING","ON_HOLD")
			THEN 'Action Needed'
		WHEN order_status = 'SUSPECTED_FRAUD'
			THEN 'Risky'
		WHEN order_status = 'CANCELED'
			THEN 'Closed/No Action'
		ELSE 'Unknown/Review Required'
	END AS order_status_category
    FROM orders
ORDER BY order_date;
        
        
WITH orders_needing_action AS (                   -- <-- WITH stament(Just for Good Readability)
    SELECT
        order_id,
        order_status
    FROM orders
    WHERE order_status IN (
        'PENDING_PAYMENT',
        'PROCESSING',
        'PAYMENT_REVIEW',
        'ON_HOLD'
    )
)
SELECT *
FROM orders_needing_action;

USE demo1;

SELECT MAX(sal) AS second_highest_salary
FROM emp
WHERE sal < (
    SELECT MAX(sal)
    FROM emp
);



WITH max_salary AS (
    SELECT MAX(sal) AS highest_salary
    FROM emp
)
SELECT MAX(sal) AS second_highest_salary
FROM emp
WHERE sal < (
    SELECT highest_salary
    FROM max_salary
);

SELECT
  DATE_FORMAT(order_date, '%Y-%m') AS order_month,
  COUNT(*) AS total_orders,
  SUM(CASE WHEN order_status = 'COMPLETE' THEN 1 ELSE 0 END) AS complete_orders,
  SUM(CASE WHEN order_status = 'CLOSED'   THEN 1 ELSE 0 END) AS closed_orders
FROM orders
GROUP BY order_month
ORDER BY order_month;


SELECT o.order_date,
       oi.order_item_product_id,
       oi.order_item_subtotal
FROM orders AS o
INNER JOIN order_items AS oi
    ON o.order_id = oi.order_item_order_id;


SELECT o.order_id,
       o.order_date,
       oi.order_item_id,
       oi.order_item_product_id,
       oi.order_item_subtotal
FROM orders AS o
LEFT JOIN order_items AS oi
    ON o.order_id = oi.order_item_order_id
ORDER BY o.order_id;


SELECT o.order_date,
       oi.order_item_product_id,
       ROUND(SUM(oi.order_item_subtotal), 2) AS order_revenue
FROM orders AS o
INNER JOIN order_items AS oi
    ON o.order_id = oi.order_item_order_id
WHERE o.order_status IN ('COMPLETE', 'CLOSED')
GROUP BY o.order_date, oi.order_item_product_id
ORDER BY o.order_date, order_revenue DESC;


CREATE TABLE sales (
    order_id INT,
    order_date DATE,
    amount DECIMAL(10,2)
);

INSERT INTO sales VALUES
(1, '2025-01-01', 100.00),
(2, '2025-01-01', 150.00),
(3, '2025-01-02', 200.00),
(4, '2025-01-02', 50.00);

SELECT order_date, SUM(amount) AS daily_total
FROM sales
GROUP BY order_date;


CREATE TABLE daily_sales_summary AS -- <-- CTAS(Create Table AS Select)
SELECT
    order_date,
    SUM(amount) AS daily_total
FROM sales
GROUP BY order_date;

SELECT * FROM daily_sales_summary;





-- ANALYTICAL QUESTIONS -- 

SELECT * FROM orders;
SELECT * FROM order_items;

-- daily revenue table by calculating the total order value per day for all completed and closed orders
SELECT 
	DATE(o.order_date) AS date_,
    ROUND(SUM(oi.order_item_subtotal),2) AS daily_revenue
    FROM orders o
    JOIN
    order_items oi
    ON o.order_id = oi.order_item_order_id
    WHERE o.order_status IN('COMPLETE','CLOSED')
    GROUP BY DATE(o.order_date)
    ORDER BY DATE(o.order_date);
    
    
-- Create a table by calculating revenue per product per day
SELECT 
	DATE(o.order_date) AS date_,
	oi.order_item_product_id,
	ROUND(SUM(oi.order_item_subtotal),2) AS revenuePerDay
    FROM order_items oi
    JOIN
    orders o
    ON o.order_id = oi.order_item_order_id
    WHERE o.order_status IN('COMPLETE','CLOSED')
    GROUP BY oi.order_item_product_id,DATE(o.order_date)
    ORDER BY DATE(o.order_date);
    

-- monthly revenue while retaining daily rows
CREATE TABLE revenue_per_day AS
SELECT 
	DATE_FORMAT(o.order_date,'%d-%m-%y') AS date_,
    ROUND(SUM(oi.order_item_subtotal),2) AS daily_revenue
    FROM orders o
    JOIN
    order_items oi
    ON o.order_id = oi.order_item_order_id
    WHERE o.order_status IN('COMPLETE','CLOSED')
    GROUP BY o.order_date
    ORDER BY o.order_date;


SELECT 
	date_,daily_revenue,
	SUM(daily_revenue) OVER (
    PARTITION BY DATE_FORMAT(date_,'%y-%m')
    ) AS monthly_revenue
FROM revenue_per_day
ORDER BY date_;
    
    
    
-- Rank products globally by revenue for a given date    
    
SELECT 
	oi.order_item_product_id,
	ROUND(SUM(oi.order_item_subtotal),2) AS total_sales,
	RANK() OVER(ORDER BY SUM(oi.order_item_subtotal) DESC) AS ranking
FROM order_items oi
LEFT JOIN orders o
ON oi.order_item_order_id = o.order_id  
WHERE DATE(o.order_date) = "2014-01-01" AND o.order_status IN('COMPLETE','CLOSED')
GROUP BY oi.order_item_product_id;



-- top 5 products by revenue using dense ranking.


SELECT
	oi.order_item_product_id,
	ROUND(SUM(oi.order_item_subtotal),2) AS total_sales,
	DENSE_RANK() OVER(ORDER BY SUM(oi.order_item_subtotal) DESC) AS ranking
FROM order_items oi
LEFT JOIN orders o
ON oi.order_item_order_id = o.order_id
WHERE o.order_status IN('COMPLETE','CLOSED')
GROUP BY oi.order_item_product_id
LIMIT 5;