
--Check For Nulls and duplicates in Primary Key
--Expectation: No Result

select 
cst_id,
count(*)
from bronze.crm_cust_info
group by cst_id
having count(*)>1 or cst_id is null

--Check For Unwanted Spaces

SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname!= TRIM(cst_firstname)

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname!= TRIM(cst_lastname)

SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr!= TRIM(cst_gndr)

--Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT cst_material_status
FROM bronze.crm_cust_info


--Insert into silver layer table
INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_material_status,
	cst_gndr,
	cst_create_date)
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
CASE UPPER(TRIM(cst_material_status))
	WHEN 'M' THEN 'Married'
	WHEN 'S' THEN 'Single'
	ELSE 'n/a'
END as cst_material_status, -- Normalize marital status values to readable format
CASE UPPER(TRIM(cst_gndr))
	WHEN 'M' THEN 'Male'
	WHEN 'F' THEN 'Female'
	ELSE 'n/a'
END as cst_gndr, -- Normalize gendar values to readable format
cst_create_date
FROM (SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag
FROM
bronze.crm_cust_info)t WHERE flag=1 AND cst_id IS NOT NULL --select the most recent record per customer
