CREATE DEFINER=`root`@`%` PROCEDURE `sp_getDapCategoryDim`()
BEGIN

    -- Return a list of dail accommodation price category which was created during creating database schema
	SELECT DAPCategoryID, DapCategoryDesc FROM DAPCategoryDim;
END