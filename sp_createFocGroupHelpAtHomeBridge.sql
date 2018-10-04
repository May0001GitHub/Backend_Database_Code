CREATE DEFINER=`root`@`%` PROCEDURE `sp_createFocGroupHelpAtHomeBridge`()
BEGIN

-- Retrive diver needs (focus group) which are stored in dataset in freetext. Those data are seprated line by line and will be stored in table record by record
	DECLARE done1, done2 BOOLEAN DEFAULT FALSE;  
    DECLARE vFocusGroup_ID int (11);
    DECLARE vFocusGroupFromDataSet VARCHAR(400);
	DECLARE vHelpAtHome_ID int(11);
    DECLARE vParticular_Need_Services VARCHAR(400);
    
   DECLARE cur2 CURSOR FOR SELECT DISTINCT HelpAtHome_ID, 
   CASE WHEN DIVERSE_NEEDS IS NULL or DIVERSE_NEEDS = '' THEN 'empty'  ELSE DIVERSE_NEEDS END AS FocusGroup 
   FROM HelpAtHome;
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = TRUE;

	DELETE FROM HelpAtHomeFocusGroup_Bridge WHERE HelpAtHome_ID >=1;
    
   OPEN cur2;

	  read_loop2: LOOP
      
	  FETCH cur2 INTO vHelpAtHome_ID, vParticular_Need_Services ;
		
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
			-- insert seprated focus value to the bridge table record by record
		   IF  (INSTR(vParticular_Need_Services, vFocusGroupFromDataSet )) THEN

				INSERT INTO HelpAtHomeFocusGroup_Bridge
				(HelpAtHome_ID, FocusGroup_ID )
				VALUES (vHelpAtHome_ID, vFocusGroup_ID);		
                
		  END IF;
        
		END LOOP read_loop3;
		CLOSE cur3;

		END BLOCK1;	


       
	END LOOP read_loop2;

	CLOSE cur2;

	COMMIT;
END