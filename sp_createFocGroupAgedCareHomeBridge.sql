CREATE DEFINER=`root`@`%` PROCEDURE `sp_createFocGroupAgedCareHomeBridge`()
BEGIN

	
    -- To create a bridge table which store age care home and focus group (particular need services) relations
	DECLARE done1, done2 BOOLEAN DEFAULT FALSE;  

    DECLARE vOriginalStrLen int(4);
    DECLARE vParticular_Need_Services VARCHAR(400);
	DECLARE vHome_ID int(11);
    DECLARE vFocusGroup_ID int (11);
	DECLARE vFocusGroupCount INT(3);
    DECLARE vLoopCount INT(3);
    DECLARE vFocusGroupFromDataSet VARCHAR(400);
    
    
    
-- Retrive Particular Need Service (Focus Group)  fromdataset. This focsu group  will be separated line by line and stored record by record
    
   DECLARE cur2 CURSOR FOR SELECT DISTINCT Home_ID, 
   CASE WHEN Particular_Need_Services IS NULL or Particular_Need_Services = '' THEN 'empty'  ELSE Particular_Need_Services END AS FocusGroup 
   FROM AgedCareHomeDim;
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = TRUE;
    
    DELETE FROM AgedCareHomeFocusGroup_Bridge WHERE Home_ID >= 1;

	
    
   OPEN cur2;

	  read_loop2: LOOP
      
	  FETCH cur2 INTO vHome_ID, vParticular_Need_Services ;
		
        IF done1 THEN
			LEAVE read_loop2;
		END IF;
        
		BLOCK1 : BEGIN
		
		DECLARE cur3 CURSOR FOR SELECT DISTINCT FocusGroup_ID , FocusGroupFromDataSet  FROM FocusGroupDim;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;

		OPEN cur3;

			read_loop3: LOOP
			
			FETCH cur3 INTO vFocusGroup_ID, vFocusGroupFromDataSet ;

			IF done2 THEN
					SET done2= FALSE;
				  LEAVE read_loop3;
			END IF;
			
            -- Insert separted focsu group into record by record
		   IF  (INSTR(vParticular_Need_Services, vFocusGroupFromDataSet )) THEN

				INSERT INTO AgedCareHomeFocusGroup_Bridge
				(Home_ID, FocusGroup_ID )
				VALUES (vHome_ID, vFocusGroup_ID);		
                
		  END IF;
        
		END LOOP read_loop3;
		CLOSE cur3;

		END BLOCK1;	


       
	END LOOP read_loop2;

	CLOSE cur2;

	COMMIT;


END