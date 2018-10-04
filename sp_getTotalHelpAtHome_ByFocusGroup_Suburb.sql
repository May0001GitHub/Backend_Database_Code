CREATE DEFINER=`root`@`%` PROCEDURE `sp_getTotalHelpAtHome_ByFocusGroup_Suburb`()
BEGIN

-- retrieve total number of help at home providers in victoria by focus group and suburb
	SELECT totalHomesBySuburbNoFocusGroup.Suburb_Physical as Street_Suburb,
				   coalesce( totalHomesBySuburbNoFocusGroup.TotalinSuburb,0) as TotalinSuburb, 
                   coalesce( totHomesBySuburbWithFocusGroup.CALD,0) as  CALD, 
                   coalesce( totHomesBySuburbWithFocusGroup.ATSI,0) as ATSI, 
                   coalesce( totHomesBySuburbWithFocusGroup.Dementia,0) as Dementia , 
                   coalesce( totHomesBySuburbWithFocusGroup.Disadvantaged, 0) as Disadvantaged, 
                   coalesce( totHomesBySuburbWithFocusGroup.Terminal_Illness,0)  as Terminal_Illness, 
                   coalesce( totHomesBySuburbWithFocusGroup.Cultural_Food, 0) as Cultural_Food, 
                   coalesce( totHomesBySuburbWithFocusGroup.LGBTI,0) as LGBTI
    FROM  
	(SELECT 
						count(HelpAtHome_ID) as TotalinSuburb, 
                        Suburb_Physical 
                        FROM HelpAtHome
                        GROUP BY Suburb_Physical 
	) totalHomesBySuburbNoFocusGroup  
    LEFT JOIN
	(SELECT 
						Street_Suburb,
						sum(coalesce(CALD,0)) as CALD,
						sum(coalesce(ATSI, 0)) as ATSI,
						sum(coalesce(Dementia, 0)) as Dementia,
						sum(coalesce(Disadvantaged, 0)) as Disadvantaged,
						sum(coalesce(Terminal_Illness, 0)) as Terminal_Illness,
						sum(coalesce(Cultural_Food, 0)) as 'Cultural_Food',
						sum(coalesce(LGBTI, 0)) as LGBTI
						FROM view_helpAtHomeFocusGroupSuburb
						GROUP BY Street_Suburb
                        ) totHomesBySuburbWithFocusGroup
		ON totalHomesBySuburbNoFocusGroup.Suburb_Physical = totHomesBySuburbWithFocusGroup.Street_Suburb;
    
                                                        
                                                        
	


END