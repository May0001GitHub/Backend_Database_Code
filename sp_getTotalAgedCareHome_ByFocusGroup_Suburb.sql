CREATE DEFINER=`root`@`%` PROCEDURE `sp_getTotalAgedCareHome_ByFocusGroup_Suburb`()
BEGIN
           
-- retrieve total number of AGed Care Homes in victoria by focus group and suburb
	SELECT totalHomesBySuburbNoFocusGroup.Street_Suburb as Street_Suburb,
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
						count(Home_ID) as TotalinSuburb, 
                        Street_Suburb 
                        FROM AgedCareHomeDim
                        GROUP BY Street_Suburb 
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
						FROM view_agedCareHomeFocusGroupSuburb
						GROUP BY Street_Suburb
                        ) totHomesBySuburbWithFocusGroup
		ON totalHomesBySuburbNoFocusGroup.Street_Suburb = totHomesBySuburbWithFocusGroup.Street_Suburb;
    
                                                        
                                                        
                                                        
	
END