DROP DATABASE IF EXISTS qa_db;
CREATE DATABASE IF NOT EXISTS qa_db;
USE qa_db;

SET @test_run_id = DATE_FORMAT(NOW(),'%y%m%d_%H%i%s');


DROP TABLE IF EXISTS qa_db.test_results;

CREATE TABLE qa_db.test_results (
    test_run_id VARCHAR(20),
    test_name VARCHAR(255),
    status_ VARCHAR(10),
    actual_value INT,
    expected_desc VARCHAR(255),
    details VARCHAR(500),
    run_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (test_run_id)
);

TRUNCATE TABLE test_results;
SET @test_run_id = DATE_FORMAT(NOW(),'%y%m%d_%H%i%s');

INSERT INTO qa_db.test_results
    (test_run_id, test_name, status_, actual_value, expected_desc, details)
SELECT
    @test_run_id,
    'Silver: Beauty exclusion rule',
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS' 
        ELSE 'FAIL' 
    END,
    COUNT(*),
    '0 expected',
    'Beauty rows should not be promoted to Silver'
FROM aditya_sah_TSV_859_silver_db.silver_sales_raw
WHERE product_category = 'Beauty';




SET @test_run_id = DATE_FORMAT(NOW(),'%y%m%d_%H%i%s');

INSERT INTO qa_db.test_results
    (test_run_id, test_name, status_, actual_value, expected_desc, details)
SELECT
    @test_run_id,
    'Bronze: Duplicate order_id Check',
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status_,
    COUNT(*) AS actual_value,
    '0 expected',
    'order_id values should not appear more than once in Bronze'
FROM (
    SELECT order_id
    FROM aditya_sah_TSV_859_bronze_db.bronze_sales_raw
    GROUP BY order_id
    HAVING COUNT(*) > 1
) dup;



SELECT * FROM qa_db.test_results;



SET @test_run_id = DATE_FORMAT(NOW(),'%y%m%d_%H%i%s');

INSERT INTO qa_db.test_results
    (test_run_id, test_name, status_, actual_value, expected_desc, details)
SELECT
    @test_run_id,
    'Silver: Null/Blank City Check',
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status_,
    COUNT(*) AS actual_value,
    '0 expected',
    '0 rows with city IS NULL OR TRIM(city) = '' in Silver'
FROM (
    SELECT city
    FROM aditya_sah_TSV_859_silver_db.silver_sales_raw
    WHERE city = 'NULL' OR TRIM(city) = ''
) n;


SELECT * FROM qa_db.test_results;






SET @test_run_id = DATE_FORMAT(NOW(),'%y%m%d_%H%i%s');

INSERT INTO qa_db.test_results
    (test_run_id, test_name, status_, actual_value, expected_desc, details)
SELECT
    @test_run_id,
    'Silver: Invalid Email Format Check',
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status_,
    COUNT(*) AS actual_value,
    '0 expected',
    'Email must contain both @ and . in Silver'
FROM (
    SELECT email
    FROM aditya_sah_TSV_859_silver_db.silver_sales_raw
    WHERE email NOT LIKE '%@%' AND email NOT LIKE '%.%'
) n;


SELECT * FROM qa_db.test_results;



SET @test_run_id = DATE_FORMAT(NOW(),'%y%m%d_%H%i%s');

INSERT INTO qa_db.test_results
    (test_run_id, test_name, status_, actual_value, expected_desc, details)
SELECT
    @test_run_id,
    'Gold Fact: total_amount Calculation Check',
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status_,
    COUNT(*) AS actual_value,
    '0 expected',
    'Validate total_amount matches quantity * unit_price within tolerance in Silver'
FROM (
    SELECT *
    FROM aditya_sah_TSV_859_gold_db.fact_sales
    WHERE (total_amount - quantity*unit_price) > 0.01
) n;


SELECT * FROM qa_db.test_results;



SET @test_run_id = DATE_FORMAT(NOW(),'%y%m%d_%H%i%s');

INSERT INTO qa_db.test_results
    (test_run_id, test_name, status_, actual_value, expected_desc, details)
SELECT
    @test_run_id,
    'Completeness: Silver → Gold Missing order_id Check',
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status_,
    COUNT(*) AS actual_value,
    '0 expected',
    'Ensure every Silver order_id exists in Gold fact_sales.'
FROM (
    SELECT s.order_id
	FROM aditya_sah_TSV_859_gold_db.fact_sales g
	RIGHT JOIN 
	aditya_sah_TSV_859_silver_db.silver_sales_raw s
	ON g.order_id = s.order_id
	WHERE g.order_id IS NULL
) n;



SELECT * FROM qa_db.test_results;