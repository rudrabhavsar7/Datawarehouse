--Duplicates
SELECT
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
--Separate CategoryId and prd_key From prd_key
SELECT
prd_key
FROM bronze.crm_prd_info

--Remove Spaces From prd_nm
SELECT 
prd_nm
FROM  bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--Check For The Null values in Price
SELECT
prd_cost
FROM  bronze.crm_prd_info
WHERE prd_cost<0 OR prd_cost IS NULL

--Check For Unique Values In prd_line
SELECT 
DISTINCT prd_line
FROM  bronze.crm_prd_info

--Validate The Start and End Date
SELECT 
*
FROM  bronze.crm_prd_info
WHERE prd_start_dt>prd_end_dt

INSERT INTO silver.crm_prd_info(
	prd_id ,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt ,
	prd_end_dt
)
SELECT
prd_id,
REPLACE(SUBSTRING(prd_key, 1,5),'-','_') AS cat_id, --Extract Category ID
SUBSTRING(prd_key, 7,LEN(prd_key)) AS prd_key,		--Extract Product Key
TRIM(prd_nm) AS prd_nm,
ISNULL(prd_cost,0) AS prd_cost,
CASE UPPER(TRIM(prd_line))
	WHEN 'R' THEN 'Road'
	WHEN 'S' THEN 'Other Sales'
	WHEN 'M' THEN 'Mountain'
	WHEN 'T' THEN 'Touring'
END AS prd_line, --Map Product line codes to descriptive values
CAST(prd_start_dt AS DATE) prd_start_dt,
CAST(
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE
	) AS prd_end_dt -- Calculate end date as one day before the next start date
FROM bronze.crm_prd_info
