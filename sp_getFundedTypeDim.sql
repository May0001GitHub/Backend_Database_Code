CREATE DEFINER=`root`@`%` PROCEDURE `sp_getFundedTypeDim`()
BEGIN

	-- Return funded type data  ('Common Wealth government funded' or 'private'
	SELECT * FROM FundedTypeDim;
END