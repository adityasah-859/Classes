
-- 01 — Build Bronze Layer 

CREATE DATABASE bronze DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE bronze;

-- crm_cust_info
CREATE TABLE IF NOT EXISTS crm_cust_info (
  cst_id INT,
  cst_key VARCHAR(50),
  cst_firstname VARCHAR(50),
  cst_lastname VARCHAR(50),
  cst_marital_status VARCHAR(50),
  cst_gndr VARCHAR(50),
  cst_create_date DATE
) ENGINE=InnoDB;
TRUNCATE TABLE crm_cust_info;
LOAD DATA LOCAL INFILE '/Users/as-mac-1346/Desktop/Classes/SQL/Datasets/cust_info.csv' INTO TABLE crm_cust_info
FIELDS TERMINATED BY ',' IGNORE 1 LINES;
SELECT COUNT(*) AS rows_loaded_cust FROM crm_cust_info;

SELECT * FROM crm_cust_info ;

-- crm_prd_info
CREATE TABLE IF NOT EXISTS crm_prd_info (
  prd_id INT,
  prd_key VARCHAR(50),
  prd_nm VARCHAR(50),
  prd_cost INT,
  prd_line VARCHAR(50),
  prd_start_dt DATETIME,
  prd_end_dt DATETIME
) ENGINE=InnoDB;
TRUNCATE TABLE crm_prd_info;
LOAD DATA LOCAL INFILE '/Users/as-mac-1346/Desktop/Classes/SQL/Datasets/prd_info.csv' INTO TABLE crm_prd_info
FIELDS TERMINATED BY ',' IGNORE 1 LINES;
SELECT COUNT(*) AS rows_loaded_prd FROM crm_prd_info;

SELECT * FROM crm_prd_info;

-- crm_sales_details
CREATE TABLE IF NOT EXISTS crm_sales_details (
  sls_ord_num VARCHAR(50),
  sls_prd_key VARCHAR(50),
  sls_cust_id INT,
  sls_order_dt INT,
  sls_ship_dt INT,
  sls_due_dt INT,
  sls_sales INT,
  sls_quantity INT,
  sls_price INT
) ENGINE=InnoDB;
TRUNCATE TABLE crm_sales_details;
LOAD DATA LOCAL INFILE '/Users/as-mac-1346/Desktop/Classes/SQL/Datasets/sales_details.csv' INTO TABLE crm_sales_details
FIELDS TERMINATED BY ',' IGNORE 1 LINES;
SELECT COUNT(*) AS rows_loaded_sales FROM crm_sales_details;

SELECT * FROM crm_sales_details ;

-- erp_loc_a101
CREATE TABLE IF NOT EXISTS erp_loc_a101 (
  cid VARCHAR(50),
  cntry VARCHAR(50)
) ENGINE=InnoDB;
TRUNCATE TABLE erp_loc_a101;
LOAD DATA LOCAL INFILE '/Users/as-mac-1346/Desktop/Classes/SQL/Datasets/LOC_A101.csv' INTO TABLE erp_loc_a101
FIELDS TERMINATED BY ',' IGNORE 1 LINES;
SELECT COUNT(*) AS rows_loaded_loc FROM erp_loc_a101;

SELECT * FROM erp_loc_a101 ;

-- erp_cust_az12
CREATE TABLE IF NOT EXISTS erp_cust_az12 (
  cid VARCHAR(50),
  bdate DATE,
  gen VARCHAR(50)
) ENGINE=InnoDB;
TRUNCATE TABLE erp_cust_az12;
LOAD DATA LOCAL INFILE '/Users/as-mac-1346/Desktop/Classes/SQL/Datasets/CUST_AZ12.csv' INTO TABLE erp_cust_az12
FIELDS TERMINATED BY ',' IGNORE 1 LINES;
SELECT COUNT(*) AS rows_loaded_az12 FROM erp_cust_az12;

SELECT * FROM erp_cust_az12;

-- erp_px_cat_g1v2
CREATE TABLE IF NOT EXISTS erp_px_cat_g1v2 (
  id VARCHAR(50),
  cat VARCHAR(50),
  subcat VARCHAR(50),
  maintenance VARCHAR(50)
) ENGINE=InnoDB;
TRUNCATE TABLE erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE '/Users/as-mac-1346/Desktop/Classes/SQL/Datasets/PX_CAT_G1V2.csv' INTO TABLE erp_px_cat_g1v2
FIELDS TERMINATED BY ',' IGNORE 1 LINES;
SELECT COUNT(*) AS rows_loaded_cat FROM erp_px_cat_g1v2;

SELECT * FROM erp_px_cat_g1v2 ;





SELECT cr.cst_key,er.cid,er.gen
FROM erp_cust_az12 er
JOIN crm_cust_info cr
ON cr.cst_id = SUBSTR(er.cid,4)
WHERE cr.cst_gndr = '' ;