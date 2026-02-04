-- Build Gold Layer (SQL)
-- Purpose: Star schema exposed via views

DROP DATABASE IF EXISTS gold;
CREATE DATABASE gold DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE gold;


-- dim_customers
CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT
  ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
  ci.cst_id        AS customer_id,
  ci.cst_key       AS customer_number,
  ci.cst_firstname AS first_name,
  ci.cst_lastname  AS last_name,
  la.cntry         AS country,
  ci.cst_marital_status AS marital_status,
  CASE 
    WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr
    ELSE COALESCE(ca.gen, 'n/a')
  END AS gender,
  ca.bdate         AS birthdate,
  ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid;

SELECT COUNT(*) AS dim_customers_rows FROM gold.dim_customers;



-- dim_products
CREATE OR REPLACE VIEW gold.dim_products AS
SELECT
  ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
  pn.prd_id       AS product_id,
  pn.prd_key      AS product_number,
  pn.prd_nm       AS product_name,
  pn.cat_id       AS category_id,
  pc.cat          AS category,
  pc.subcat       AS subcategory,
  pc.maintenance  AS maintenance,
  pn.prd_cost     AS cost,
  pn.prd_line     AS product_line,
  pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;
SELECT COUNT(*) AS dim_products_rows FROM gold.dim_products;



-- fact_sales
CREATE OR REPLACE VIEW gold.fact_sales AS
SELECT
  sd.sls_ord_num  AS order_number,
  pr.product_key  AS product_key,
  cu.customer_key AS customer_key,
  sd.sls_order_dt AS order_date,
  sd.sls_ship_dt  AS shipping_date,
  sd.sls_due_dt   AS due_date,
  sd.sls_sales    AS sales_amount,
  sd.sls_quantity AS quantity,
  sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu ON sd.sls_cust_id = cu.customer_id;

SELECT COUNT(*) AS fact_sales_rows FROM gold.fact_sales;

SELECT * FROM fact_sales;
SELECT * FROM dim_products;


-- OLDEST

SELECT 
	first_name,
    last_name,
    FLOOR(DATEDIFF(NOW(),birthdate)/365) AS age 
FROM dim_customers
WHERE birthdate IS NOT NULL
ORDER BY DATEDIFF(NOW(),birthdate) DESC 
LIMIT 1;



-- YOUNGEST

SELECT 
	first_name,
    last_name,
    FLOOR(DATEDIFF(NOW(),birthdate)/365) AS age 
FROM dim_customers
WHERE birthdate IS NOT NULL
ORDER BY DATEDIFF(NOW(),birthdate) ASC 
LIMIT 1;


-- Compute revenue by category

SELECT dp.category, SUM(fs.sales_amount) AS revenue
FROM dim_products dp
 JOIN
fact_sales fs
ON dp.product_key = fs.product_key
GROUP BY dp.category
ORDER BY revenue DESC;

     
-- Compute units sold by country

SELECT c.country,SUM(s.quantity) AS units_sold
FROM dim_customers c
LEFT JOIN 
fact_sales s
ON c.customer_key = s.customer_key
WHERE s.quantity IS NOT NULL AND c.country != 'n/a'
GROUP BY c.country
ORDER BY units_sold DESC;


-- 3 customers with the fewest orders


SELECT
  dc.customer_key,
  dc.customer_id,
  dc.customer_number,
  dc.first_name,
  dc.last_name,
  COUNT(DISTINCT fs.order_number) AS order_count
FROM gold.fact_sales fs
JOIN gold.dim_customers dc
  ON fs.customer_key = dc.customer_key
GROUP BY
  dc.customer_key, dc.customer_id, dc.customer_number, dc.first_name, dc.last_name
HAVING COUNT(DISTINCT fs.customer_key) >=1
ORDER BY order_count  ASC, dc.customer_key
LIMIT 3;


-- 5 bottom product revenue

SELECT dp.product_id, dp.product_name, SUM(fs.sales_amount) AS revenue
FROM dim_products dp
LEFT JOIN
fact_sales fs
ON dp.product_key = fs.product_key
WHERE fs.sales_amount IS NOT NULl
GROUP BY dp.product_key
ORDER BY revenue LIMIT 5;


-- YEAR WISE REVENUE

SELECT * FROM fact_sales WHERE order_date IS NULL;

SELECT YEAR(order_date) AS year_, product_name, SUM(sales_amount) AS revenue
FROM fact_sales s
LEFT JOIN dim_products p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(s.order_date) ,s.product_key;