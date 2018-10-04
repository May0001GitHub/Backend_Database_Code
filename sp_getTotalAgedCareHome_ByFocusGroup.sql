CREATE DEFINER=`root`@`%` PROCEDURE `sp_getTotalAgedCareHome_ByFocusGroup`()
BEGIN

	-- Return total number of AGed Care Homes in Victoria Group By different FocusGroup
    
    	SELECT g.FocusGroupAbbr, count(Total_Num_AgedCareHome) as Total_AgedCareHomes
		FROM  AgedCareHomeFact f,  AgedCareHomeFocusGroup_Bridge b, FocusGroupDim g
		WHERE f.Home_ID = b.Home_ID
		AND b.FocusGroup_ID = g.FocusGroup_ID
		GROUP BY g.FocusGroupAbbr;
                                                        
                                                        
	
    	
                                                        

END