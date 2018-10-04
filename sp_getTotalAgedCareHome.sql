CREATE DEFINER=`root`@`%` PROCEDURE `sp_getTotalAgedCareHome`()
BEGIN

	-- Get total number of aged care homes in victoria (to show at dasboard factsumary)
	SELECT COUNT( Home_ID) as Total_AgedCareHomes
    FROM AgedCareHomeFact;

END