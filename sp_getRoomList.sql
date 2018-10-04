CREATE DEFINER=`root`@`%` PROCEDURE `sp_getRoomList`(In homeID int)
BEGIN

		-- Return a list of rooms provided by a particular aged care home
		SELECT DISTINCT Room_Name, Room_Type, Max_Room_Occupancy, FORMAT(Max_RAD,2) AS Max_RAD, Max_Dap  as Max_Dap
		FROM AgedCareHomeRoom 
		WHERE Home_ID = homeID 
		ORDER BY room_type;

END