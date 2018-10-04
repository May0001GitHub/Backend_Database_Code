CREATE DEFINER=`root`@`%` PROCEDURE `sp_createDBSchemaAgedCareHome`()
BEGIN

    /* data from dataset csv is loaded into tho the tbl_AgedCarehomes.
	-- This is for creating database schema with ETL process (extract, transform and load data from aged care home dataset table)
    -- This data is retrived from agedcarehome dataset table 'tbl_AgedCarehomes'.*/

	-- Create AgedCareHomeDim table to store aged care home information in Victoria. 
	DROP TABLE IF EXISTS AgedCareHomeRoom;

	DROP TABLE IF EXISTS AgedCareHomeDim;


	CREATE TABLE `AgedCareHomeDim` (
	  `HOME_ID` int(11) NOT NULL AUTO_INCREMENT,
	  `SERVICE_NAME` varchar(200) DEFAULT NULL,
	  `DESCRIPTION` varchar(1000) DEFAULT NULL,
	  `COMMGOVT_SUBSIDISED` varchar(45) DEFAULT NULL,
	  `STREET_UNIT_NO` varchar(45) DEFAULT NULL,
	  `STREET_ST_ADDRESS` varchar(200) DEFAULT NULL,
	  `STREET_SUBURB` varchar(100) DEFAULT NULL,
	  `STREET_PCODE` varchar(45) DEFAULT NULL,
	  `STREET_STATE` varchar(45) DEFAULT NULL,
	  `MAIN_PH_NUM` varchar(45) DEFAULT NULL,
	  `MAIN_FAX_NUM` varchar(45) DEFAULT NULL,
	  `MAIN_EMAIL_ADDR` varchar(45) DEFAULT NULL,
	  `WEBSITE` varchar(100) DEFAULT NULL,
	  `SERVICE_TYPE` varchar(45) DEFAULT NULL,
	  `APPROVED_PROVIDER` varchar(45) DEFAULT NULL,
	  `ACCREDITATION` varchar(45) DEFAULT NULL,
	  `ACCREDITATION_PERIOD` VARCHAR(45) NULL,		
	  `CERTIFICATION` VARCHAR(45) NULL,		
	  `NOTICE_OF_SANCTION` VARCHAR(45) NULL,		
	  `NOTICE_OF_NON_COMPLIANCE` VARCHAR(45) NULL,	
	  `PARTICULAR_NEED_SERVICES` varchar(400) DEFAULT NULL,
	  Location_ID int(11),
	  FundedType_ID int(11),
     
	  PRIMARY KEY (`HOME_ID`)
	) ;

	-- Retrieve Aged Care Home Data from Data Set. Only retrive aged care homes in Victoria state
	INSERT INTO AgedCareHomeDim 
	(SERVICE_NAME, DESCRIPTION, COMMGOVT_SUBSIDISED, STREET_UNIT_NO, STREET_ST_ADDRESS, STREET_SUBURB, STREET_PCODE,
	STREET_STATE,MAIN_PH_NUM,  MAIN_FAX_NUM,MAIN_EMAIL_ADDR,WEBSITE,SERVICE_TYPE,APPROVED_PROVIDER,
	ACCREDITATION, ACCREDITATION_PERIOD,	CERTIFICATION,  NOTICE_OF_SANCTION,  NOTICE_OF_NON_COMPLIANCE,
		PARTICULAR_NEED_SERVICES
	)
	SELECT DISTINCT SERVICE_NAME, Description, COMMGOVT_SUBSIDISED, STREET_UNIT_NO, STREET_ST_ADDRESS, STREET_SUBURB, STREET_PCODE,
	STREET_STATE,MAIN_PH_NUM,  MAIN_FAX_NUM,MAIN_EMAIL_ADDR,WEBSITE,SERVICE_TYPE,APPROVED_PROVIDER,
	ACCREDITATION, ACCREDITATION_PERIOD,	CERTIFICATION, NOTICE_OF_SANCTION, NOTICE_OF_NON_COMPLIANCE,	
	PARTICULAR_NEED_SERVICES
	FROM Tbl_AgedCareHomes
	WHERE STREET_STATE = 'VIC'
	AND SERVICE_TYPE LIKE '%Permanent%';


	COMMIT;
    

	-- Aged Care Home Room Type from Data Set. Create Room Type Table.

	DROP TABLE IF EXISTS RoomTypeDim;

	CREATE TABLE RoomTypeDim (
	  ROOM_TYPE_ID int(11) NOT NULL AUTO_INCREMENT,
	   ROOM_TYPE varchar(45) DEFAULT NULL,
	   PRIMARY KEY (ROOM_TYPE_ID)
	  );
	   

	INSERT INTO RoomTypeDim
	( ROOM_TYPE)
	SELECT DISTINCT ROOM_TYPE
	FROM Tbl_AgedCareHomes
	WHERE STREET_STATE = 'VIC'
	AND SERVICE_TYPE LIKE '%Permanent%';

	-- Create Aged Care Home Room table to store room data from Dataset. One aged care home has more than one room of different room type.
	CREATE TABLE AgedCareHomeRoom
	(

	ROOM_ID 	INT(11) NOT NULL AUTO_INCREMENT,
	HOME_ID INT(11) NOT NULL,
	ROOM_NAME VARCHAR(100) DEFAULT NULL,
	 ROOM_TYPE_ID INT(11) DEFAULT NULL,
	 MAX_ROOM_OCCUPANCY VARCHAR(45) DEFAULT NULL,
	 MAX_RAD INT(8) DEFAULT NULL,
	 MAX_DAP DECIMAL(6,2) DEFAULT NULL,
	 ROOM_TYPE VARCHAR(45) DEFAULT NULL,
	 PRIMARY KEY (ROOM_ID),
	 FOREIGN KEY (HOME_ID) REFERENCES AgedCareHomeDim(HOME_ID)
	 );
	 
	INSERT INTO AgedCareHomeRoom
	(HOME_ID, ROOM_NAME, MAX_ROOM_OCCUPANCY, MAX_RAD, MAX_DAP, ROOM_TYPE_ID, ROOM_TYPE)
	SELECT a.HOME_ID, d.ROOM_NAME, d. MAX_ROOM_OCCUPANCY , d.MAX_RAD, d.MAX_DAP, r.Room_Type_ID, r.Room_Type
	FROM AgedCareHomeDim a , Tbl_AgedCareHomes d, RoomTypeDim r
	WHERE a.SERVICE_NAME = d.SERVICE_NAME
	AND d.Room_Type = r.Room_Type
	AND d.STREET_STATE = 'VIC'
	AND d.SERVICE_TYPE LIKE '%Permanent%';


	-- Cretate focus group table to store focus group that aged care home support. Focus group  data is retrived from data set. 
	DROP TABLE IF EXISTS FocusGroupDim;

	CREATE TABLE FocusGroupDim
	( FocusGroup_ID int(11) NOT NULL AUTO_INCREMENT,
	  FocusGroup varchar(400) DEFAULT NULL,
	  FocusGroupFromDataSet  varchar(400) DEFAULT NULL,
	  FocusGroupAbbr varchar (50) DEFAULT NULL, 
	  PRIMARY KEY (FocusGroup_ID)
	  );

	-- Transform Focus group data with full description because Some Focus group data in dataset is abbrebriated. 
	CALL sp_focusGroupTransformation();

	DROP TABLE IF EXISTS AgedCareHomeFocusGroup_Bridge;

	CREATE TABLE AgedCareHomeFocusGroup_Bridge
		 (
		   Home_ID int(11) ,
		   FocusGroup_ID int(11) ,
		   PRIMARY KEY (Home_ID, FocusGroup_ID)
		  );
		  
	-- To store the relationship of aged care home and its services for focus group. 
    -- One aged care home support services for more than one group. (CALD/Demenia/ATSI and so on) 
	CALL sp_createFocGroupAgedCareHomeBridge();

	DROP TABLE IF EXISTS LocationDim;

	CREATE TABLE LocationDim
	(LOCATION_ID INT(11)  NOT NULL AUTO_INCREMENT,
	STREET_PCODE VARCHAR(45),
	STREET_SUBURB VARCHAR (45),
	PRIMARY KEY (LOCATION_ID)
	);

	-- To store location (suburb) of aged care homes as a separte location table
	-- (Location Dimension table to link with Aged Care Home Fact table) so that total number of aged care home can be aggregated based on suburb location.
	INSERT INTO LocationDim (  STREET_SUBURB)
	SELECT DISTINCT  STREET_SUBURB
	FROM Tbl_AgedCareHomes
	WHERE STREET_STATE = 'VIC'
	AND SERVICE_TYPE LIKE '%Permanent%';




	/*Retrive maximun daily accommodation price from dataset and divide into four categories 
	so that users can filter aged care home data between the range of daily price they selected.*/
    
	DROP TABLE IF EXISTS DAPCategoryDim;

	CREATE TABLE DAPCategoryDim
	 (
	  DAPCategoryID int(11) NOT NULL AUTO_INCREMENT,
	   DAPCategoryDesc varchar(45) DEFAULT NULL,
	   FromDap Decimal(6,2) DEFAULT NULL,
	   ToDap Decimal(6,2) DEFAULT NULL,
	   PRIMARY KEY (DAPCategoryID)
	  );
	  
	INSERT INTO DAPCategoryDim
	(DapCategoryDesc, FromDap,ToDap)
	VALUES('Less than $ 100', 0, 99);

	INSERT INTO DAPCategoryDim
	(DapCategoryDesc, FromDap,ToDap)
	VALUES('$ 100- $ 200', 100, 200);

	INSERT INTO DAPCategoryDim
	(DapCategoryDesc, FromDap,ToDap)
	VALUES('$ 200- $ 300', 201, 300);

	INSERT INTO DAPCategoryDim
	(DapCategoryDesc, FromDap,ToDap)
	VALUES('Over $ 300', 301, 0);


	-- Retrive Funded type. Cretate Funded Type Dimension table
	DROP TABLE IF EXISTS FundedTypeDim;

	CREATE TABLE FundedTypeDim
	 (
	  FundedTypeID int(11) NOT NULL AUTO_INCREMENT,
	   FundedType varchar(45) DEFAULT NULL,
	   Funded varchar(5) DEFAULT NULL,
	   PRIMARY KEY (FundedTypeID)
	  );
	-- Dataset has 'yes or No' value only for funded information. 'Yes 'means funded by government, 'No' means private service.
	INSERT INTO FundedTypeDim
	(FundedType , Funded)
	values ('Commonwealth Government', 'Yes');

	INSERT INTO FundedTypeDim
	(FundedType ,Funded )
	values ('Private Service', 'No');

	-- update location ID to the agedcarehome table after creating location table
	UPDATE AgedCareHomeDim   a JOIN LocationDim l ON a.Street_Suburb = l.Street_Suburb 
	SET a.Location_ID = l.Location_ID
	WHERE a.home_ID >= 1 AND l.location_ID >=1;

	-- update FundedType ID to the agedcarehome table after creating FundetType dimension table

	UPDATE AgedCareHomeDim   a JOIN FundedTypeDim f ON a.Commgovt_Subsidised = f.Funded 
	SET a.FundedType_ID = f.FundedTypeID
	WHERE a.home_ID >= 1 AND f.FundedTypeID >=1;

	-- Create Aged Care Home Fact Table . To display aggregated data of total number of aged care homes based on location and focus group
	DROP TABLE IF EXISTS AgedCareHomeFact;

	CREATE TABLE AgedCareHomeFact
	 (
	   Home_ID int(11),
	   Location_ID int(11),
	   Total_Num_AgedCareHome  int(11), 
	   PRIMARY KEY (Home_ID,  Location_ID)
	  );
	  
	  
	  INSERT INTO AgedCareHomeFact ( Home_ID,   Location_ID, Total_Num_AgedCareHome)
	  SELECT a.Home_ID, loc.Location_ID, COUNT(a.HOME_ID)
	  FROM AgedCareHomeDim a JOIN  LocationDim loc ON a.location_ID = loc.location_ID
	  GROUP BY  a.Home_ID, loc.Location_ID;


COMMIT;
END