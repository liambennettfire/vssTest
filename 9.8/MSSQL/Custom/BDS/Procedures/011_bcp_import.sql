BULK INSERT bds_tmm_cispub_feed_testexport
    FROM 'E:\TestData\BDS\TMM2CISPUB_20100414075848.txt' 
    WITH 
    (         
        FIELDTERMINATOR = '^|', 
        ROWTERMINATOR = '||\n' 
    )
