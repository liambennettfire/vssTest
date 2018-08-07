DECLARE @v_bookkey  INT
DECLARE @v_territoriescode  INT
DECLARE @v_count  INT
DECLARE @v_count2 INT
DECLARE @v_count3 INT
DECLARE @v_count4 INT
DECLARE @v_count5 INT
DECLARE @v_count6 INT
DECLARE @v_territoryrightskey INT
DECLARE @v_countrycode  INT
DECLARE @v_eloquencefieldtag  VARCHAR(25)
DECLARE @v_datacode_elo INT
DECLARE @v_datadesc VARCHAR(40)
DECLARE @v_description  VARCHAR(250)
DECLARE @v_currentterritorycode INT
DECLARE @v_forsalecountrycodes VARCHAR(MAX)
DECLARE @v_notforsalecountrycodes VARCHAR(MAX)
DECLARE @v_string VARCHAR(max)
DECLARE @v_start INT
DECLARE @v_end INT
DECLARE @v_counter2 INT
DECLARE @v_rowcount2 INT
DECLARE @v_eloquencefieldtag_ctry CHAR(2)



BEGIN
  DECLARE book_cursor CURSOR FOR
    SELECT DISTINCT bookkey, territoriescode
    FROM book
    WHERE territoriescode > 0
		  ORDER BY bookkey
		
	OPEN book_cursor
	
	FETCH NEXT FROM book_cursor INTO @v_bookkey, @v_territoriescode
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
     SELECT @v_count = count(*)
       FROM elo_full_rights_by_territory
      WHERE territorycode = @v_territoriescode

     IF @v_count > 0 BEGIN
        SELECT @v_count2 = count(*)
          FROM gentables
         WHERE tableid = 131
           AND datacode = @v_territoriescode
   
        IF @v_count = 1 BEGIN
          SELECT @v_eloquencefieldtag = ltrim(rtrim(eloquencefieldtag)), @v_datadesc = ltrim(rtrim(datadesc))
            FROM gentables
           WHERE tableid = 131
             AND datacode = @v_territoriescode
             
--print @v_territoriescode
--print @v_eloquencefieldtag
--print @v_datadesc

          IF @v_eloquencefieldtag IS NOT NULL BEGIN
             IF @v_eloquencefieldtag <> 'World' OR @v_eloquencefieldtag <> 'WWD' OR @v_datadesc <> 'Worldwide' OR @v_datadesc <> 'Worldwide/All' BEGIN
                SET @v_description = 'Converted from legacy territory ' + @v_eloquencefieldtag
                SET @v_currentterritorycode = 3
             END
             ELSE BEGIN
				SET @v_currentterritorycode = 0
             END
          END

          IF @v_currentterritorycode = 3 BEGIN
			  IF @v_eloquencefieldtag IS NOT NULL BEGIN

				SELECT @v_count6 = 0

				SELECT @v_count6 = count(*)
				  FROM gentables_eloprod
				 WHERE tableid = 131
				   AND eloquencefieldtag = @v_eloquencefieldtag
	            

				IF @v_count6 > 0 BEGIN

				  SELECT @v_datacode_elo = datacode
					FROM gentables_eloprod
				   WHERE tableid = 131
					 AND eloquencefieldtag = @v_eloquencefieldtag

				  EXEC dbo.get_next_key 'QSIDBA', @v_territoryrightskey OUT

				  INSERT INTO territoryrights (territoryrightskey, itemtype, taqprojectkey, rightskey, bookkey, currentterritorycode,
					  contractterritorycode, description, autoterritorydescind, exclusivecode, singlecountrycode, updatewithsubrightsind,
					  note, forsalehistory, notforsalehistory, lastuserid, lastmaintdate)
				   VALUES(@v_territoryrightskey,1,NULL,NULL,@v_bookkey,@v_currentterritorycode,
					  @v_currentterritorycode,@v_description,0,NULL,NULL,0,
					  NULL,NULL,NULL,'FB_CONVERSION_25195',getdate())

				  IF @v_description <> 'World' OR @v_description <> 'Worldwide' BEGIN --insert into territoryrightcountries
					  SET @v_start = 0
					  SET @v_end = 0
					  SET @v_count3 = 0
					  SET @v_string = ''

					  SELECT @v_forsalecountrycodes =  ltrim(rtrim(forsalerights)) 
						FROM elo_full_rights_by_territory 
					   WHERE territorycode = @v_datacode_elo

					  SET @v_start = CHARINDEX('<b090>',@v_forsalecountrycodes) + 6
	 --print @v_start
					  SET @v_end = CHARINDEX('</b090>',@v_forsalecountrycodes)
	 --print @v_end
					  IF @v_end > 0 BEGIN
						  IF @v_forsalecountrycodes <> '' AND @v_forsalecountrycodes IS NOT NULL BEGIN
							SET @v_string = substring(@v_forsalecountrycodes,@v_start,@v_end-(@v_start))
						  END 
					  END
					  ELSE
						SET @v_string = ''
	 --print @v_string
					  IF @v_string <> '' AND @v_string IS NOT NULL BEGIN

						SELECT @v_count3 = count(*)
						  FROM dbo.parse_string_xml(@v_string, ' ')

						IF @v_count3 > 0 BEGIN  -- forsale country rows
						  SET @v_counter2 = 1
							SET @v_rowcount2 = 0
							SET @v_eloquencefieldtag_ctry = ' '

						  SELECT @v_rowcount2 = count(*), @v_eloquencefieldtag_ctry = min(eloquencefieldtag)
							  FROM dbo.parse_string_xml(@v_string, ' ')
	--print '@v_rowcount2 for sale'
	--print @v_rowcount2
						  WHILE @v_counter2 <= @v_rowcount2 BEGIN
							SELECT @v_count4 = 0

							SELECT @v_count4 = count(*)
							  FROM gentables
							 WHERE tableid = 114
							   AND eloquencefieldtag = @v_eloquencefieldtag_ctry

							IF @v_count4 = 1 BEGIN
							  SELECT @v_countrycode = datacode
								FROM gentables
							   WHERE tableid = 114
								 AND eloquencefieldtag = @v_eloquencefieldtag_ctry

							  --print 'for sale countries for bookkey'
							  --print @v_bookkey
							  --print @v_countrycode
							  --print @v_eloquencefieldtag_ctry

							  SELECT @v_count5 = count(*)
								FROM territoryrightcountries
							   WHERE territoryrightskey = @v_territoryrightskey
								 AND countrycode = @v_countrycode

							  SELECT @v_count5 = 0

							  IF @v_count5 = 0 BEGIN
	          
								INSERT INTO territoryrightcountries
								 (territoryrightskey,countrycode,itemtype,taqprojectkey,rightskey,bookkey,forsaleind,contractexclusiveind,
								  nonexclusivesubrightsoldind,currentexclusiveind,exclusivesubrightsoldind,lastuserid,lastmaintdate)
								 VALUES(@v_territoryrightskey,@v_countrycode,1,NULL,NULL,@v_bookkey,1,0,
										0,0,NULL,'FB_CONVERSION_25195',getdate())

							  END
							END
	                                            
						  SELECT @v_eloquencefieldtag_ctry = min(eloquencefieldtag)
								FROM dbo.parse_string_xml(@v_string, ' ')
						   WHERE eloquencefieldtag > @v_eloquencefieldtag_ctry
	    	  	
							  SELECT @v_counter2 = @v_counter2 + 1
						  END  --@v_counter2 <= @v_rowcount2
						END -- forsale country rows
					  END -- @v_string <> ''

					  SET @v_start = 0
					  SET @v_end = 0
					  SET @v_count3 = 0
					  SET @v_string = ''

					  SELECT @v_notforsalecountrycodes =  ltrim(rtrim(notforsalerights)) 
						FROM elo_full_rights_by_territory 
					   WHERE territorycode = @v_datacode_elo

					  SET @v_start = CHARINDEX('<b090>',@v_notforsalecountrycodes) + 6
	--print @v_start
					  SET @v_end = CHARINDEX('</b090>',@v_notforsalecountrycodes)
	--print @v_end
	                  IF @v_end > 0 BEGIN
						  IF @v_notforsalecountrycodes <> '' AND @v_notforsalecountrycodes IS NOT NULL BEGIN
							SET @v_string = substring(@v_notforsalecountrycodes,@v_start,@v_end-(@v_start))
						  END
					  END
					  ELSE 
						SET @v_string = ''
	--print @v_string
					  IF @v_string <> '' AND @v_string IS NOT NULL BEGIN
						SELECT @v_count3 = count(*)
						  FROM dbo.parse_string_xml(@v_string, ' ')

						IF @v_count3 > 0 BEGIN  -- not forsale country rows
						  SET @v_counter2 = 1
							SET @v_rowcount2 = 0
							SET @v_eloquencefieldtag_ctry = ''

						  SELECT @v_rowcount2 = count(*), @v_eloquencefieldtag_ctry = min(eloquencefieldtag)
							  FROM dbo.parse_string_xml(@v_string, ' ')

						  WHILE @v_counter2 <= @v_rowcount2 BEGIN
							SELECT @v_count4 = 0

							SELECT @v_count4 = count(*)
							  FROM gentables
							 WHERE tableid = 114
							   AND eloquencefieldtag = @v_eloquencefieldtag_ctry

							IF @v_count4 = 1 BEGIN
							  SELECT @v_countrycode = datacode
								FROM gentables
							   WHERE tableid = 114
								 AND eloquencefieldtag = @v_eloquencefieldtag_ctry

							  --print 'not for sale countries for bookkey'
							  --print @v_bookkey
							  --print @v_countrycode
							  --print @v_eloquencefieldtag_ctry

							  SELECT @v_count5 = count(*)
								FROM territoryrightcountries
							   WHERE territoryrightskey = @v_territoryrightskey
								 AND countrycode = @v_countrycode
								 AND forsaleind = 1

							  SELECT @v_count5 = 0

							  IF @v_count5 = 0 BEGIN
	          
								INSERT INTO territoryrightcountries
								 (territoryrightskey,countrycode,itemtype,taqprojectkey,rightskey,bookkey,forsaleind,contractexclusiveind,
								  nonexclusivesubrightsoldind,currentexclusiveind,exclusivesubrightsoldind,lastuserid,lastmaintdate)
								 VALUES(@v_territoryrightskey,@v_countrycode,1,NULL,NULL,@v_bookkey,0,0,
										0,0,NULL,'FB_CONVERSION_25195',getdate())
							  END
							END
	                        
							SELECT @v_eloquencefieldtag_ctry = min(eloquencefieldtag)
								  FROM dbo.parse_string_xml(@v_string, ' ')
							 WHERE eloquencefieldtag > @v_eloquencefieldtag_ctry
	      	  	
								SELECT @v_counter2 = @v_counter2 + 1
						  END  --@v_counter2 <= @v_rowcount2
						END -- not forsale country rows
					END  --@v_string <> ''
				  END --insert into territoryrightcountries
				END  --@v_description <> 'World'
			END  -- @v_count6 > 0
		 END -- @v_currentterritorycode = 3	
        END --@v_eloquencefieldtag is not null on client gentable 131
      END  --@v_count = 1

      FETCH NEXT FROM book_cursor INTO @v_bookkey, @v_territoriescode
  END

  CLOSE book_cursor
  DEALLOCATE book_cursor

END
