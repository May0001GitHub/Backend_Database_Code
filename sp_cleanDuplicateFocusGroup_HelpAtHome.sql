CREATE DEFINER=`root`@`%` PROCEDURE `sp_cleanDuplicateFocusGroup_HelpAtHome`()
BEGIN

-- Data Cleaning... To Remove Duplicate value of diverse needs (focus group)  in dataset
    

   
   DECLARE done1 BOOLEAN DEFAULT FALSE;  
    DECLARE vOutlet_Name VARCHAR (1000);
    DECLARE vDiverse_Needs VARCHAR (5000);
    
   
  DECLARE cur2 CURSOR FOR SELECT DISTINCT OUTLET_NAME, DIVERSE_NEEDS FROM Tbl_HelpAtHome_Dataset
   WHERE TRIM(STREET_STATE) LIKE '%VIC%'
   AND IFNULL(DIVERSE_NEEDS,'') !=''
   ORDER BY OUTLET_NAME;
   
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = TRUE;
   
   OPEN cur2;
	read_loop2: LOOP
      
	  FETCH cur2 INTO vOutlet_Name, vDiverse_Needs ;
		
        IF done1 THEN
			LEAVE read_loop2;
		END IF;
        
		UPDATE HelpAtHome
		SET DIVERSE_NEEDS = vDiverse_Needs
		WHERE OUTLET_NAME LIKE vOutlet_Name
        AND HelpAtHome_ID >=1;
		

		
       
	END LOOP read_loop2;
	

	CLOSE cur2;
    COMMIT;
END