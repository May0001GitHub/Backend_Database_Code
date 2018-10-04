CREATE DEFINER=`root`@`%` PROCEDURE `sp_getTotalHelpAtHome`()
BEGIN

	-- Return total number of help at home providers in Victoria

	SELECT Count(HelpAtHome_ID) as HelpAtHomeFact
    FROM HelpAtHome;

END