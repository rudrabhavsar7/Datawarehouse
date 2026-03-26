INSERT INTO silver.epr_cust_az12(
	cid,
	bdate,
	gen
)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END cid, --Remove NAS from cid
CASE WHEN bdate > GETDATE() THEN NULL
	ELSE bdate
END AS bdate, --future values to null
CASE 
	WHEN UPPER(TRIM(gen)) IN ('F','Female') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M','Male') THEN 'Female'
	ELSE 'n/a'
END gen --normalized gender values
FROM bronze.erp_cust_az12


--Identify Out-Of-Range Dates
SELECT DISTINCT
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

--Data Consistency
SELECT DISTINCT
gen 
FROM bronze.erp_cust_az12