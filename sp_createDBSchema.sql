CREATE DEFINER=`root`@`%` PROCEDURE `sp_createDBSchema`()
BEGIN

	-- The following two schema is for ETL process (extract, transform and load) from aged care home dataset and helpathome dataset
    -- Create tables to store data by extracting, transforming, loading (ETL process) from Aged Care Home Dataset
	CALL sp_createDBSchemaAgedCareHome();
	-- Create tables to store data by extracting, transforming, loading (ETL process) from Help At HOme Home Dataset
    CALL sp_createDBSchemaHelpAtHome();
    
END