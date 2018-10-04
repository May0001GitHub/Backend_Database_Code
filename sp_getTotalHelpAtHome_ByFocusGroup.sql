CREATE DEFINER=`root`@`%` PROCEDURE `sp_getTotalHelpAtHome_ByFocusGroup`()
BEGIN
	-- Return total number of HelpAtHome Providers in Victoria  Group By different FocusGroup
    	SELECT g.FocusGroupAbbr, SUM(Total_Num_HelpAtHome) as Total_HelpAtHomes
		FROM HelpAtHomeFact f,  HelpAtHomeFocusGroup_Bridge b,  FocusGroupDim g
		WHERE f.HelpAtHome_ID = b.HelpAtHome_ID
		AND b.FocusGroup_ID = g.FocusGroup_ID
		GROUP BY g.FocusGroupAbbr;
                                                        
END