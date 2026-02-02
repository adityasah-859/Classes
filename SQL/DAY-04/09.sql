USE retail_db;
SELECT * FROM customers;
SHOW TABLES;
SELECT 1
FROM products p
WHERE p.product_category_id = 3;

SELECT
  c.category_id,
  c.category_name
FROM categories c
WHERE EXISTS (
  SELECT 1
  FROM products p
  WHERE p.product_category_id = c.category_id
);


SELECT
  c.category_id,
  c.category_name
FROM categories c
WHERE NOT EXISTS (
  SELECT 1
  FROM products p
  WHERE p.product_category_id = c.category_id
);

SELECT COUNT(1) FROM customers;

-- Retrieve customers with atleast 5 orders

SELECT c.customer_id,
	c.customer_fname,
    c.customer_lname
FROM customers c
WHERE EXISTS (
	SELECT 1
    FROM orders o
    WHERE o.order_customer_id = c.customer_id
    HAVING COUNT(o.order_id) >= 5
);


SELECT
  c.customer_id,
  c.customer_fname,
  c.customer_lname
FROM customers c
WHERE (
  SELECT COUNT(*)
  FROM orders o
  WHERE o.order_customer_id = c.customer_id
) >= 5;

-- Products whose price is above avg prce in their category

SELECT 
	p.product_category_id,
    product_id,(
    SELECT ROUND(AVG(p2.product_price),2)
    FROM products p2
    WHERE p2.product_category_id = p.product_category_id
  ) AS category_avg,
  p.product_price,
  p.product_name
FROM products p
WHERE EXISTS(
	SELECT 1
    FROM products p1
    WHERE p.product_category_id = p1.product_category_id
    GROUP BY p.product_category_id
    HAVING p.product_price > AVG(p1.product_price)
);


-- Customers who have never placed an order
EXPLAIN 
SELECT c.customer_id, 
	c.customer_fname,
	c.customer_lname
FROM customers c
WHERE NOT EXISTS(
	SELECT 1
    FROM orders o
    WHERE c.customer_id = o.order_customer_id
);

EXPLAIN ANALYZE
SELECT c.customer_id, 
	c.customer_fname,
	c.customer_lname
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.order_customer_id
WHERE o.order_customer_id IS NULL;