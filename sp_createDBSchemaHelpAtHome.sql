CREATE DEFINER=`root`@`%` PROCEDURE `sp_createDBSchemaHelpAtHome`()
BEGIN

	/* data from Help At Home dataset csv is loaded into the tbl_HelpAtHomes.
	-- This is for creating database schema with ETL process (extract, transform and load data from aged care home dataset table)
    -- This data is retrived from agedcarehome dataset table 'tbl_HelpAtHomes'.**/
	-- Create table to store Help At Home provider data from dataset table
	DROP TABLE IF EXISTS HelpAtHome;

	CREATE TABLE `HelpAtHome` (
	  `HelpAtHome_ID` int(11) NOT NULL AUTO_INCREMENT,
	  `OUTLET_NAME` VARCHAR(500) NULL,		
		DIVERSE_NEEDS VARCHAR(5000) NULL, 
	  `ST_ADDR_PO_BOX` VARCHAR(200) NULL,		
	  `SUBURB_PHYSICAL` VARCHAR(100) NULL,		
	  `POST_CODE_PHYSICAL` VARCHAR(45) NULL,		
	  `STATE_PHYSICAL` VARCHAR(45) NULL,		
		Location_ID int(11),
	  
		PRIMARY KEY (`HelpAtHome_ID`)
	) ;

-- RetrieveHelp At Home Data from Data Set. Only retrive data of victoria.
	INSERT INTO HelpAtHome 
	(OUTLET_NAME,  ST_ADDR_PO_BOX,  SUBURB_PHYSICAL, STATE_PHYSICAL )
	SELECT  DISTINCT OUTLET_NAME,   STREET_ST_ADDRESS,  STREET_SUBURB, STREET_STATE
	FROM Tbl_HelpAtHome_Dataset
	WHERE TRIM(STREET_STATE) LIKE '%VIC%';

	commit;

	-- remove duplicate value of focus group (diverse needs) 

	call sp_cleanDuplicateFocusGroup_HelpAtHome();
  
  
	-- create location dimension table for help at home data
	  
	DROP TABLE IF EXISTS helpAtHomeLocationDim;

	CREATE TABLE helpAtHomeLocationDim
	(LOCATION_ID INT(11)  NOT NULL AUTO_INCREMENT,
	STREET_SUBURB VARCHAR (45),
	PRIMARY KEY (LOCATION_ID)
	);



	INSERT INTO helpAtHomeLocationDim (  STREET_SUBURB)
	SELECT DISTINCT  STREET_SUBURB
	FROM Tbl_HelpAtHome_Dataset
	WHERE TRIM(STREET_STATE) LIKE '%VIC%';
	  
	  
	UPDATE HelpAtHome   a JOIN helpAtHomeLocationDim l ON a.Suburb_Physical = l.Street_Suburb 
	SET a.Location_ID = l.Location_ID
	WHERE a.HelpAtHome_ID >= 1 AND l.location_ID >=1;



	-- Create bridge table for focus group with help at home relation

	DROP TABLE IF EXISTS HelpAtHomeFocusGroup_Bridge;

	CREATE TABLE HelpAtHomeFocusGroup_Bridge
		 (
		   HelpAtHome_ID int(11)  ,
		   FocusGroup_ID int(11) ,
		   PRIMARY KEY (HelpAtHome_ID, FocusGroup_ID)
		  );
		  
	CALL sp_createFocGroupHelpAtHomeBridge();



	DROP TABLE IF EXISTS HelpAtHomeFact;

	CREATE TABLE HelpAtHomeFact
	 (
	   HelpAtHome_ID int(11),
	   Location_ID int(11),
	   Total_Num_HelpAtHome  int(11), 
	   PRIMARY KEY (HelpAtHome_ID, Location_ID)
	  );
	  
	  
	  INSERT INTO HelpAtHomeFact (HelpAtHome_ID,  Location_ID, Total_Num_HelpAtHome)
	  SELECT DISTINCT a.HelpAtHome_ID,  loc.Location_ID, COUNT(a.HelpAtHome_ID)
	  FROM HelpAtHome a  LEFT JOIN  helpAtHomeLocationDim loc ON  a.Location_ID = loc.Location_ID
	  GROUP BY  a.HelpAtHome_ID,   loc.Location_ID;


END