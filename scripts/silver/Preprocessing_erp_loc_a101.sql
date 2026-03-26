
INSERT INTO silver.epr_loc_a101(
	cid,
	cntry
)
SELECT
REPLACE(cid, '-','') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
	 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry --Normalize and handle missing values
FROM bronze.erp_loc_a101

--Data Consistency
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101