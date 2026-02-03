-- Revenue by City

SELECT c.city, SUM(f.total_amount) AS revenue
FROM aditya_sah_TSV_859_gold_db.dim_customers c
LEFT JOIN 
aditya_sah_TSV_859_gold_db.fact_sales f
ON c.customer_key = f.customer_key
GROUP BY c.city;


-- Revenue by Category

SELECT p.product_category, SUM(f.total_amount) AS revenue
FROM aditya_sah_TSV_859_gold_db.dim_product p
LEFT JOIN aditya_sah_TSV_859_gold_db.fact_sales f
ON p.product_key = f.product_key
GROUP BY p.product_category;

-- Daily Revenue Trend

SELECT f.sale_date, SUM(f.total_amount) AS revenue
FROM aditya_sah_TSV_859_gold_db.fact_sales f
GROUP BY f.sale_date;