DECLARE @v_code varchar(10)
DECLARE @v_replacement_code VARCHAR(10)
DECLARE @v_count INT
DECLARE @v_count2 INT
DECLARE @v_count3 INT
DECLARE @v_count4 INT
DECLARE @v_datacode INT
DECLARE @v_datasubcode INT
DECLARE @v_deletestatus varchar(1)
DECLARE @v_replacement_datacode INT
DECLARE @v_replacement_datasubcode INT
DECLARE @v_bookkey INT
DECLARE @v_printingkey INT
DECLARE @v_replacement_datacode_desc VARCHAR(40)
DECLARE @v_replacement_datasubcode_desc VARCHAR(120)
DECLARE @o_error_code  integer 
DECLARE @o_error_desc  varchar(2000) 


DECLARE replacement_cursor CURSOR FOR
	SELECT code,replacementcode 
       FROM temp_replacement_codes_2009 
     WHERE ReplacementCode NOT LIKE 'appropriate%'
	     AND ReplacementCode NOT LIKE '%and%' 
          AND ReplacementCode NOT LIKE '%for%'
	      AND ReplacementCode NOT LIKE '%or%' 
          AND ReplacementCode NOT LIKE '%code from%'

BEGIN
	OPEN replacement_cursor

	FETCH replacement_cursor INTO @v_code, @v_replacement_code

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		
		SELECT @v_count = 0

		SELECT @v_count = count(*)
            FROM subgentables 
          WHERE tableid = 339
               AND bisacdatacode = @v_code

		IF @v_count = 1 
         BEGIN
			SELECT @v_datacode = datacode, @v_datasubcode = datasubcode,@v_deletestatus = deletestatus
    			  FROM subgentables 
             WHERE tableid = 339
                 AND bisacdatacode = @v_code

			SELECT @v_count = 0

             SELECT @v_count2 = count(*)
               FROM bookbisaccategory
             WHERE bisaccategorycode = @v_datacode
                  AND bisaccategorysubcode = @v_datasubcode

			IF @v_count2 > 0 
			BEGIN
				SELECT @v_count3 = 0
				
				SELECT @v_count3 = count(*)
    			     FROM subgentables 
                 WHERE tableid = 339
                     AND bisacdatacode = @v_replacement_code 

				IF @v_count3 = 1
                  BEGIN				
					SELECT @v_replacement_datacode = datacode, @v_replacement_datasubcode = datasubcode
    			   		  FROM subgentables 
                		 WHERE tableid = 339
                   		 AND bisacdatacode = @v_replacement_code 
				
					 DECLARE bookbisaccategory_cur CURSOR FOR
                           SELECT bookkey, printingkey
                             FROM bookbisaccategory
                           WHERE bisaccategorycode = @v_datacode
                               AND bisaccategorysubcode = @v_datasubcode 

					OPEN bookbisaccategory_cur
        
                      FETCH bookbisaccategory_cur INTO @v_bookkey, @v_printingkey

                      WHILE (@@FETCH_STATUS = 0)
					BEGIN

						SELECT @v_count4 = 0

						SELECT @v_count4 = count(*)
						  FROM bookbisaccategory
						WHERE bookkey = @v_bookkey 
                                AND printingkey = @v_printingkey
                                AND bisaccategorycode = @v_replacement_datacode
							 AND bisaccategorysubcode =  @v_replacement_datasubcode

						IF @v_count4 = 0 
                           BEGIN
      
							 UPDATE bookbisaccategory
								  SET bisaccategorycode = @v_replacement_datacode,
									bisaccategorysubcode =  @v_replacement_datasubcode,
										lastuserid = 'FB_BISACSUBJECT_UPDATE',
									lastmaintdate = getdate()
								WHERE bookkey = @v_bookkey
                                 	   AND printingkey = @v_printingkey
                                  	  AND  bisaccategorycode = @v_datacode
									AND bisaccategorysubcode = @v_datasubcode

							IF @v_replacement_datacode <> @v_datacode
                                BEGIN
								SET  @v_replacement_datacode_desc = ltrim(rtrim(dbo.get_gentables_desc(339,convert(int,@v_replacement_datacode),'long'))) 
								exec qtitle_update_titlehistory 'bookbisaccategory', 'bisaccategorycode' , @v_bookkey, 1, 0, @v_replacement_datacode_desc, 'Update', 'FB_BISACSUBJECT_UPDATE', null,'Bisac Heading', @o_error_code output, @o_error_desc output
							END
							
                                IF @v_replacement_datasubcode <> @v_datasubcode
                                BEGIN
								SET @v_replacement_datasubcode_desc = ltrim(rtrim(dbo.get_subgentables_desc(339, @v_replacement_datacode, @v_replacement_datasubcode, 'long')))
									exec qtitle_update_titlehistory 'bookbisaccategory', 'bisaccategorysubcode' , @v_bookkey, 1, 0, @v_replacement_datasubcode_desc, 'Update', 'FB_BISACSUBJECT_UPDATE', null,'Bisac Sub Heading', @o_error_code output, @o_error_desc output
						 	 END

						 END
						 FETCH bookbisaccategory_cur INTO @v_bookkey, @v_printingkey
                      END  --@fetch_status for bookbisaccategory_cur
					CLOSE bookbisaccategory_cur
                      DEALLOCATE bookbisaccategory_cur

				END --v_count3 = 1
			END --v_count2 > 0
		END ---v_count = 1
		FETCH replacement_cursor INTO @v_code, @v_replacement_code
	END ---while fetch status
	CLOSE replacement_cursor
	DEALLOCATE replacement_cursor
END
go