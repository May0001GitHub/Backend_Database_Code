CREATE DEFINER=`root`@`%` PROCEDURE `sp_compareAgedCareRooms`(IN firstHomeID Int(11), IN secondHomeID int(11) )
BEGIN

/*
 Retrive room information of two aged care homes for the purpose of comparison function

*/


 

	DECLARE vPCode Varchar(200);
	DECLARE done INT DEFAULT FALSE;
    DECLARE vhomeID int(11);
    DECLARE a varchar(200);
    DECLARE vRoomtype varchar(200);
	DECLARE vFirstHomeID int(11);
	DECLARE vCRoom_Type_ID INT(11);
	DECLARE vRoomtypeList varchar(400);
	DECLARE vMax_RadList varchar(200);
	DECLARE vMax_DapList varchar(200);
	DECLARE vRoomOccupancyList varchar(200);
	DECLARE vFundedList varchar(200);
    DECLARE vFunded varchar(200);
    DECLARE vMax_Rad varchar(200);
    DECLARE vMax_Dap varchar(200);
    DECLARE vRoomOccupancy varchar(200);

    -- Declare Cursor to loop room information of two aged care homes
    DECLARE cur1 CURSOR FOR
    SELECT DISTINCT r.Home_ID, r.Room_Type_ID, Commgovt_Subsidised, MIN(Max_RAD), MIN(Max_DAP), MIN(Max_Room_Occupancy)
    FROM AgedCareHomeRoom r, AgedCareHomeDim a
    WHERE a.Home_ID= r.Home_ID
	AND a.Home_ID IN ( firstHomeID, secondHomeID)
    GROUP BY r.Home_ID, r.Room_Type_ID, Commgovt_Subsidised
    ORDER BY r.Home_ID;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
	
    DROP TEMPORARY TABLE IF EXISTS temp_RoomCompare;
    
     /* Create Temporay Table */
	CREATE TEMPORARY TABLE temp_RoomCompare
    (Home_ID int(11),  
    Service_Name varchar(200) , 
    Room_TypeList varchar(400), 
    Max_RADList varchar(200), 
    Max_DapList varchar(200), 
    Max_RoomOccupancyList varchar (200), 
    FundedList varchar(200));
	
   /* Insert room information of two aged care home into the Temporay Table */
    INSERT INTO temp_RoomCompare (Home_ID, Service_Name)   
    SELECT Home_ID, Service_Name
    FROM AgedCareHomeDim
    WHERE Home_ID IN ( firstHomeID, secondHomeID);

	SET vRoomtypeList = '';
	SET vMax_RadList = '';
	SET vMax_DapList =  '';
	SET vRoomOccupancyList = '';
	SET vFundedList = '';    
    SET vFirstHomeID =0;
	SET SQL_SAFE_UPDATES = 0;
	
    -- Open cursor and read room information from the cursor
    OPEN cur1;

	  read_loop: LOOP
	  FETCH cur1 INTO vhomeID , vCRoom_Type_ID , vFunded, vMax_Rad, vMax_Dap, vRoomOccupancy;

		IF done THEN
		  LEAVE read_loop;
		END IF;
		SET a = (SELECT ROOM_TYPE FROM RoomTypeDim WHERE ROOM_TYPE_ID = vCRoom_Type_ID);
        
        
		-- string concatanation of room infromation including price, room occupancy and funded status
         if (vhomeID = vFirstHomeID) then
			SET vRoomtypeList = CONCAT(vRoomtypeList, ' , ', a);
            SET vMax_RadList = CONCAT(vMax_RadList, ' ', Format(vMax_Rad,2));
			SET vMax_DapList = CONCAT(vMax_DapList, ' , ', vMax_Dap);
			SET vRoomOccupancyList = CONCAT(vRoomOccupancyList, ' , ', vRoomOccupancy);
			SET vFundedList = CONCAT(vFundedList, ' , ', vFunded);

            
		else
			SET vRoomtypeList = a;
            SET vMax_RadList = Format(vMax_Rad,2);
			SET vMax_DapList =  vMax_Dap;
			SET vRoomOccupancyList = vRoomOccupancy;
			SET vFundedList = vFunded;
            SET vFirstHomeID= vhomeID;
		end if;

		-- Update room information of two aged care homes to temporay table
		UPDATE temp_RoomCompare
		SET Room_TypeList = vRoomtypeList, 
				Max_RADList =vMax_RadList, 
                Max_DapList =vMax_DapList ,
                Max_RoomOccupancyList = vRoomOccupancyList,
                FundedList =vFundedList
		WHERE Home_ID = vhomeID;
		
		
		 
	  END LOOP;
	  CLOSE cur1;
    

	-- Return room information of two aged care homes as result list
	SELECT Home_ID ,  Service_Name, Room_TypeList  , Max_RADList , Max_DapList , Max_RoomOccupancyList , FundedList 
    FROM temp_RoomCompare
    ORDER BY Room_TypeList ;
     

END