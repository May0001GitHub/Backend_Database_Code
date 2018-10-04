CREATE DEFINER=`root`@`%` PROCEDURE `sp_focusGroupTransformation`()
BEGIN

	-- To transform focus group data. Focus group data in data set are not user understandbal to show to user. It will be transformed into description
	DECLARE done INT DEFAULT FALSE;
	DECLARE done1 BOOLEAN DEFAULT FALSE;  
	DECLARE done2 BOOLEAN DEFAULT FALSE;  

    DECLARE vOriginalStrLen int(4);
    DECLARE vParticular_Need_Services VARCHAR(400);
	DECLARE vSplitStrLen int(4);
    DECLARE vSplitStr VARCHAR (400);
    DECLARE vAllSplitStrLen int(4);
	DECLARE vOrgUpdateStr VARCHAR(400);
    DECLARE vExistStr INT (4);
    DECLARE vHome_ID int(11);
    DECLARE vFocusGroup_ID int (11);
	DECLARE vFocusGroupCount INT(3);
    DECLARE vLoopCount INT(3);
    DECLARE vFocusGroupFromDataSet VARCHAR(400);

    
    
    DECLARE cur1 CURSOR FOR SELECT DISTINCT Particular_Need_Services , length(Particular_Need_Services) as originalLen FROM Tbl_AgedCareHomes  
														WHERE Particular_Need_Services IS NOT NULL
														AND STREET_STATE = 'VIC'
														AND SERVICE_TYPE LIKE '%Permanent%'
														AND IFNULL(Particular_Need_Services,'') !='';
                                                        
                                                        
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;




   DELETE FROM FocusGroupDim WHERE FocusGroup_ID >=1;


    OPEN cur1;

	  read_loop: LOOP
      
	  FETCH cur1 INTO vParticular_Need_Services, vOriginalStrLen ;

		IF done THEN
		  LEAVE read_loop;
		END IF;
        
        
	    SET vSplitStrLen =0;
        SET vAllSplitStrLen =0;
	
		SET vSplitStr='start';
        
        SET vOrgUpdateStr = vParticular_Need_Services;
        
        
        
        WHILE (IFNULL(vSplitStr,'') != '' ) DO
        
        		
                SET vSplitStr =  (SELECT DISTINCT TRIM( LEADING FROM SUBSTRING(vOrgUpdateStr,1, LOCATE(',',vOrgUpdateStr)-1)));
                
                IF vSplitStr = 'Caters for cultural' THEN
                
                    SET vSplitStr = 'Caters for cultural, spiritual or ethical food requirements';
				END IF;
                
				SET vSplitStrLen = (SELECT LENGTH(vSplitStr)) +2 ;
				SET vOrgUpdateStr =  (SELECT DISTINCT SUBSTRING(vOrgUpdateStr FROM vSplitStrLen ));
				SET vOrgUpdateStr = ( SELECT TRIM( LEADING FROM vOrgUpdateStr));
				
				SET vExistStr = (SELECT COUNT(FocusGroupFromDataSet) FROM FocusGroupDim WHERE FocusGroupFromDataSet LIKE vSplitStr);
				
				IF (IFNULL(vSplitStr,'') !='' )  AND vExistStr = 0 THEN
				
					INSERT INTO FocusGroupDim ( FocusGroupFromDataSet) 
					VALUES( vSplitStr );
				END IF;
                    
        END WHILE;

		
		 
	  END LOOP;
	  CLOSE cur1;
      
      -- Update Focus Group Description to be user understandable because Focus Group Data from Dataset is not user understandable

      
	 UPDATE FocusGroupDim
	 SET FocusGroup ='Culturally and Linguistically Diverse Background People', FocusGroupAbbr = 'CALD'
	 WHERE FocusGroupFromDataSet LIKE '%CALD%' AND FocusGroup_ID>0;

	UPDATE FocusGroupDim
	SET FocusGroup ='Aboriginal and Torres Strait Islander people' , FocusGroupAbbr = 'ATSI'
	WHERE FocusGroupFromDataSet LIKE '%ATSI%' AND FocusGroup_ID>0;


	UPDATE FocusGroupDim
	SET FocusGroup ='People with dementia',  FocusGroupAbbr = 'Dementia'
	WHERE FocusGroupFromDataSet LIKE '%dementia%' AND FocusGroup_ID>0;

	UPDATE FocusGroupDim
	SET FocusGroup ='Socially and financially disadvantaged people', FocusGroupAbbr = 'Disadvantaged'
	WHERE FocusGroupFromDataSet LIKE '%socially%' AND FocusGroup_ID>0;

		
	UPDATE FocusGroupDim
	SET FocusGroup ='People with a terminal illness' , FocusGroupAbbr = 'Terminal Illness'
	WHERE FocusGroupFromDataSet LIKE '%terminal%' AND FocusGroup_ID>0;
    
	UPDATE FocusGroupDim
	SET FocusGroup ='Cultural, spiritual or ethical food requirements' , FocusGroupAbbr = 'Cultural Food'
	WHERE FocusGroupFromDataSet LIKE '%ethical food%' AND FocusGroup_ID>0;
    
      
	UPDATE FocusGroupDim
	SET FocusGroup ='Lesbian, gay, bisexual and transgender people, intersex people' , FocusGroupAbbr = 'LGBTI'
	WHERE FocusGroupFromDataSet LIKE '%LGBTI%' AND FocusGroup_ID>0;
    
    
    

	COMMIT;

      

END