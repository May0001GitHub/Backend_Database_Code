CREATE DEFINER=`root`@`%` PROCEDURE `sp_getAgedCareHome`(IN suburbName varchar(45), IN focusGrpID int, IN fundedTID int,   IN DapCatID int)
BEGIN

/* Retrive aged care home data and return as a result list based on the criteria passed by client side*/

	DECLARE vFocusGroup Varchar(400);
    DECLARE vFunded Varchar (5);
	DECLARE vFrom_DAP decimal(6,2); 
	DECLARE vTo_DAP decimal(6,2); 


   
    SET vFrom_DAP = (SELECT  FromDap FROM DAPCategoryDim WHERE DapCategoryID= DapCatID);
	SET vTo_DAP = (SELECT  ToDap FROM DAPCategoryDim WHERE DapCategoryID= DapCatID);


  /* focusGrpID = 0 means, client side doesnot want to filter by focus group. User choose 'All' for focus group filter
   in data , some agedcare homes donot support specific focus group. so, there is no relation between aged care home table and focusgroup table.
   Therefore, aged care home table needs to have left join with agedcarehome focus group table*/
        
	IF (focusGrpID = 0) THEN

		SELECT DISTINCT a.Home_ID, 
		CONCAT( a.Service_Name , '    \r\n ' , a.Street_Suburb , ' , ' ,  a.Street_State, ' ', a.Street_Pcode ) AS ServiceName , 
        a.Accreditation, 	a.Notice_Of_Non_Compliance,   a.Notice_Of_Sanction, 
		CONCAT('From ', r.maxDap_Desc ) as Price_Desc, 
		CONCAT('From ' , r.maxRad_Desc) as Rad_Desc 
		FROM  AgedCareHomeDim a   LEFT JOIN AgedCareHomeFocusGroup_Bridge b ON a.Home_ID = b.Home_ID JOIN
															(SELECT Home_ID,  Min(Max_DAP) as  maxDap_Desc, Format(Min(Max_RAD),2) as maxRad_Desc  
															FROM AgedCareHomeRoom 
															WHERE ((Max_DAP BETWEEN vFrom_DAP AND vTo_DAP)  OR DapCatID =0)
															GROUP BY Home_ID) r  ON a.Home_ID	= r.Home_ID
		WHERE (a.Street_Suburb LIKE concat(suburbName, '%')  or (a.Street_PCode = suburbName ) or (suburbName =''))
		AND ((b.FocusGroup_ID = focusGrpID)  OR focusGrpID = 0)
		AND (a.FundedType_ID = fundedTID OR fundedTID = 0);

	ELSE
        
        
        
	/* focusGrpID != 0 means, client side  want to filter by specific focus group. 
	in data , some agedcare homes donot support specific focus group. so, there is no relation between aged care home table and focusgroup table.
	Therefore, aged care home table needs to have equal join with agedcarehome focus group table */
    
        SELECT DISTINCT a.Home_ID, 
		CONCAT( a.Service_Name , '    \r\n ' , a.Street_Suburb , ' , ' ,  a.Street_State, ' ', a.Street_Pcode ) AS ServiceName , 
        a.Accreditation, 	a.Notice_Of_Non_Compliance,   a.Notice_Of_Sanction, 
		CONCAT('From ', r.maxDap_Desc ) as Price_Desc, 
		CONCAT('From ' , r.maxRad_Desc) as Rad_Desc 
		FROM  AgedCareHomeDim a   JOIN AgedCareHomeFocusGroup_Bridge b ON a.Home_ID = b.Home_ID JOIN
															(SELECT Home_ID,  Min(Max_DAP) as  maxDap_Desc, Format(Min(Max_RAD),2) as maxRad_Desc  
															FROM AgedCareHomeRoom 
															WHERE ((Max_DAP BETWEEN vFrom_DAP AND vTo_DAP)  OR DapCatID =0)
															GROUP BY Home_ID) r  ON a.Home_ID	= r.Home_ID
		WHERE (a.Street_Suburb LIKE concat(suburbName, '%')  or (a.Street_PCode = suburbName ) or (suburbName =''))
		AND ((b.FocusGroup_ID = focusGrpID)  OR focusGrpID = 0)
		AND (a.FundedType_ID = fundedTID OR fundedTID = 0);

  
     END IF;

END