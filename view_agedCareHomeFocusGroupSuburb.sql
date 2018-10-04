CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `view_agedCareHomeFocusGroupSuburb` AS
    SELECT 
        `loc`.`STREET_SUBURB` AS `Street_Suburb`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'CALD') THEN `f`.`Total_Num_AgedCareHome`
        END) AS `CALD`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'ATSI') THEN `f`.`Total_Num_AgedCareHome`
        END) AS `ATSI`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'Dementia') THEN `f`.`Total_Num_AgedCareHome`
        END) AS `Dementia`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'Disadvantaged') THEN `f`.`Total_Num_AgedCareHome`
        END) AS `Disadvantaged`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'Terminal Illness') THEN `f`.`Total_Num_AgedCareHome`
        END) AS `Terminal_Illness`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'Cultural Food') THEN `f`.`Total_Num_AgedCareHome`
        END) AS `Cultural_Food`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'LGBTI') THEN `f`.`Total_Num_AgedCareHome`
        END) AS `LGBTI`
    FROM
        (((`AgedCareHomeFact` `f`
        JOIN `AgedCareHomeFocusGroup_Bridge` `b`)
        JOIN `LocationDim` `loc`)
        JOIN `FocusGroupDim` `fd`)
    WHERE
        ((`f`.`Home_ID` = `b`.`Home_ID`)
            AND (`f`.`Location_ID` = `loc`.`LOCATION_ID`)
            AND (`b`.`FocusGroup_ID` = `fd`.`FocusGroup_ID`))