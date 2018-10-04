CREATE DEFINER=`root`@`%` PROCEDURE `sp_createHelpAtHomeDatasetTable`()
BEGIN
	-- To store all data from Help At Home Dataset. 
    -- Create this table and upload dataset Help_At_Home.csv file into bucket of Cloud SQL.
    -- Then data from this dataset will be inserted automatically to this table "tbl_helpAthome_DataSet

	CREATE TABLE `Tbl_HelpAtHome_Dataset` (
	  

	`SR` INT NOT NULL,
	`OUTLET_NAME` VARCHAR(1000) NULL,	
	`DIVERSE_NEEDS` VARCHAR(5000) NULL,	
	`STREET_ST_ADDRESS` VARCHAR(500) NULL,	
	`STREET_SUBURB` VARCHAR(100) NULL,	
	`STREET_PCODE` VARCHAR(100) NULL,	
	`STREET_STATE` VARCHAR(100) NULL,	
	PRIMARY KEY (`SR`));
END