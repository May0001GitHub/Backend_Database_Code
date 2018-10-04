CREATE DEFINER=`root`@`%` PROCEDURE `sp_getAgedCareHomeDetail`(IN homeID int)
BEGIN

/* Return detailed infromation of aged care home including address, contact phone  website, and compliance information*/

			SELECT DISTINCT SERVICE_NAME,  DESCRIPTION as Description,
			CONCAT(Street_St_Address , ' , ' , Street_Suburb , ' , ' , Street_PCode , ' , '  , Street_State ) AS ADDRESS ,
			IF(Main_Ph_Num IS NULL or Main_Ph_Num = '', 'N/A', Main_Ph_Num) AS MAIN_PH_NUM,
			IF(Main_Fax_Num IS NULL or Main_Fax_Num = '', 'N/A', Main_Fax_Num) AS MAIN_FAX_NUM,
			IF(Main_Email_Addr IS NULL or Main_Email_Addr = '', 'N/A', Main_Email_Addr) AS MAIN_EMAIL_ADDR,
			IF(Website IS NULL or Website = '', 'N/A', Website) AS WEBSITE,
			IF(Particular_Need_Services IS NULL or Particular_Need_Services = '', 'N/A', Particular_Need_Services) AS Particular_Need_Services,
			IF(Accreditation IS NULL or Accreditation = '', 'N/A', Accreditation) AS Accreditation,
			IF(Notice_Of_Non_Compliance IS NULL or Notice_Of_Non_Compliance = '', 'N/A', Notice_Of_Non_Compliance) AS Notice_Of_Non_Compliance,
			IF(Notice_Of_Sanction IS NULL or Notice_Of_Sanction = '', 'N/A', Notice_Of_Sanction) AS Notice_Of_Sanction,
			IF(Accreditation_Period IS NULL or Accreditation_Period = '', 'N/A', Accreditation_Period) AS Accreditation_Period,
			IF(Certification IS NULL or Certification = '', 'N/A', Certification) AS Certification
			FROM AgedCareHomeDim
			WHERE HOME_ID = homeID;

END