CREATE DEFINER=`root`@`%` PROCEDURE `sp_getFocusGroup`()
BEGIN

-- Return a list of focus goup data which was created during creating database schema
SELECT FocusGroup_ID, FocusGroup  FROM FocusGroupDim;

END