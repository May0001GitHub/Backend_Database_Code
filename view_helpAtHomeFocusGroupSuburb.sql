CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `view_helpAtHomeFocusGroupSuburb` AS
    SELECT 
        `loc`.`STREET_SUBURB` AS `Street_Suburb`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'CALD') THEN `f`.`Total_Num_HelpAtHome`
        END) AS `CALD`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'ATSI') THEN `f`.`Total_Num_HelpAtHome`
        END) AS `ATSI`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'Dementia') THEN `f`.`Total_Num_HelpAtHome`
        END) AS `Dementia`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'Disadvantaged') THEN `f`.`Total_Num_HelpAtHome`
        END) AS `Disadvantaged`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'Terminal Illness') THEN `f`.`Total_Num_HelpAtHome`
        END) AS `Terminal_Illness`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'Cultural Food') THEN `f`.`Total_Num_HelpAtHome`
        END) AS `Cultural_Food`,
        (CASE
            WHEN (`fd`.`FocusGroupAbbr` = 'LGBTI') THEN `f`.`Total_Num_HelpAtHome`
        END) AS `LGBTI`
    FROM
        (((`HelpAtHomeFact` `f`
        JOIN `HelpAtHomeFocusGroup_Bridge` `b`)
        JOIN `helpAtHomeLocationDim` `loc`)
        JOIN `FocusGroupDim` `fd`)
    WHERE
        ((`f`.`HelpAtHome_ID` = `b`.`HelpAtHome_ID`)
            AND (`f`.`Location_ID` = `loc`.`LOCATION_ID`)
            AND (`b`.`FocusGroup_ID` = `fd`.`FocusGroup_ID`))