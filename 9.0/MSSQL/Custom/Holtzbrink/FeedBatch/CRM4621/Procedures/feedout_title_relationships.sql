IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'feedout_title_relationships')
BEGIN
  DROP  Procedure  feedout_title_relationships
END
GO

  CREATE  PROCEDURE dbo.feedout_title_relationships 
        @p_location varchar(255)
    AS
      BEGIN

          DECLARE 
	    @AtEndOfStream integer,
            @lv_count integer,
            @lv_count2 integer,
            @lv_count3 integer,
            @lv_authorkey integer,
            @c_currentdate varchar(10),
            @c_currentdatetime varchar(8),
            @lv_totalcount integer,
            @lv_totalcount_char varchar(8),
            @c_compqtysum integer,
            @c_compqtysum_char varchar(8),
            @c_filename varchar(100),
            @c_filename2 varchar(100),
            @lv_file_id_num integer,
            @lv_file_id_num2 integer,
	    @lv_file_id_num3 integer,
            @lv_output_string varchar(max),
            @lv_input_seqnum varchar(8),
            @i_sequence_num integer,
            @lv_outfilename varchar(50),
            @lv_defaultstring varchar(18),
            @i_printingkey integer,
            @lv_decimal numeric(10, 2),
            @lv_pos1 integer,
            @lv_pos2 integer,
            @c_recordtype varchar(2),
            @c_titreltype varchar(1),
            @c_parentisbn varchar(10),
            @c_childisbn varchar(10),
            @c_quantity varchar(10),
            @c_statuscode varchar(2),
            @c_sequencenum varchar(7),
            @cursor_row$PARENTISBN varchar(30),
            @cursor_row$CHILDISBN varchar(30),
            @cursor_row$QUANTITY integer,
            @cursor_row$SORTORDER integer,
	    @FS integer, 
	    @OLEResult integer ,
	    @c_line_text varchar(8000)         
          SET @lv_totalcount = 0
          SET @lv_totalcount_char = ''
          SET @c_compqtysum = 0
          SET @c_filename = ''
          SET @c_filename2 = ''
          SET @lv_output_string = ''
          SET @i_sequence_num = 0
          SET @c_titreltype = ''
          SET @c_parentisbn = ''
          SET @c_childisbn = ''
          SET @c_quantity = ''
          SET @c_statuscode = '  '
          SET @c_sequencenum = ''
	  set @AtEndOfStream = 0
          BEGIN

            /* read input file sequence number then create header record */

	SET @c_filename = 'tmfyirel_in_seqnum.txt'
	
	--open file
	set @c_filename = @p_location + '\' + @c_filename
	execute @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	IF @OLEResult <> 0 begin
	  PRINT 'Error: Scripting.FileSystemObject Failed.'
          goto destroy
        end
	execute @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @lv_file_id_num2 OUT, @c_filename, 1, 1
	IF @OLEResult <> 0 begin
	  PRINT 'Error: OpenTextFile Failed'
          goto destroy
        end

	--read last line
	WHILE @AtEndOfStream = 0 
	BEGIN 
		execute @OLEResult = sp_OAMethod @lv_file_id_num2, 'ReadLine', @c_line_text out
		IF @OLEResult <> 0 begin
		  PRINT 'Error: ReadLine Failed'
	          goto destroy
	        end
		EXEC @OLEResult = sp_OAMethod @lv_file_id_num2, 'AtEndOfStream', @AtEndOfStream OUTPUT 
		set @i_sequence_num = cast(@c_line_text as integer)
	END 

	--close file
	exec @OLEResult = sp_OAMethod @FS, 'Close', @lv_file_id_num2

        IF (@i_sequence_num > 0)BEGIN
	        set @lv_input_seqnum = CAST( @i_sequence_num AS varchar(8))
		while len(@lv_input_seqnum) < 8
		begin
		  set @lv_input_seqnum = '0' + @lv_input_seqnum
		end
                SET @i_sequence_num = @i_sequence_num + 1
       END ELSE BEGIN
                SET @i_sequence_num = 1
		set @lv_input_seqnum = CAST( @i_sequence_num AS varchar(8))
                SET @lv_input_seqnum = '0000000' + @lv_input_seqnum
                SET @i_sequence_num = @i_sequence_num + 1
       END

            SET @c_currentdate = convert(varchar(10), getdate(), 101)
            SET @c_currentdatetime = convert(varchar(8), getdate(), 108)

	    SET @c_filename2 = 'V' + isnull(@lv_input_seqnum, '') + '.FYI_TM_REL'

            /*  Open Output File  */
	    set @c_filename2 = @p_location + '\' + @c_filename2

	    execute @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @lv_file_id_num OUT, @c_filename2, 8, 1
	    IF @OLEResult <> 0 begin
	       PRINT 'Error: OpenTextFile Failed'
               goto destroy
           end
	    while len(@c_filename2) < 25
	    begin
	       set @c_filename2 = ' ' + @c_filename2
	    end
	
            /* output header record */
            IF (@i_sequence_num > 0)
              BEGIN
                SET @lv_output_string = 'H ' + isnull(@lv_input_seqnum, '') + isnull(@c_currentdate, '') + isnull(@c_currentdatetime, '') + isnull(@c_filename2, '') + 'Y'
		execute @OLEResult = sp_OAMethod @lv_file_id_num, 'WriteLine', Null, @lv_output_string
	        IF @OLEResult <> 0 begin
		   PRINT 'Error: WriteLine Failed'
	           goto destroy
	        end
              END
            ELSE 
              BEGIN
                INSERT INTO FEEDERROR
                  (
                    FEEDERROR.ISBN, 
                    FEEDERROR.BATCHNUMBER, 
                    FEEDERROR.PROCESSDATE, 
                    FEEDERROR.ERRORDESC
                  )
                  VALUES 
                    (
                      'Not Avail', 
                      '1', 
                      getdate(), 
                      'NO SEQUENCE NUMBER FILE, PLEASE ADD FILE tmfyirel_in_sequencenum.txt'
                    )
              END

            /* default these values */
            SET @c_recordtype = 'D '

            /*  Changed from 'D' to 'P' as per js on 060105 */
            SET @c_titreltype = 'P'

            INSERT INTO FEEDERROR
              (FEEDERROR.BATCHNUMBER, FEEDERROR.PROCESSDATE, FEEDERROR.ERRORDESC)
              VALUES ('1', getdate(), 'Vista TMM Relationship File Start')

            BEGIN

              DECLARE 
                @cursor_row$PARENTISBN$2 varchar(30),
                @cursor_row$CHILDISBN$2 varchar(30),
                @cursor_row$QUANTITY$2 integer,
                @cursor_row$SORTORDER$2 integer              

              DECLARE 
                titleout_cursor CURSOR LOCAL 
                 FOR 
                  SELECT 
                      i.ISBN10 AS PARENTISBN, 
                      i2.ISBN10 AS CHILDISBN, 
                      b.QUANTITY, 
                      b.SORTORDER
                    FROM ISBN i, ISBN i2, BOOKFAMILY b
                    WHERE i.BOOKKEY = b.PARENTBOOKKEY AND 
                          i2.BOOKKEY = b.CHILDBOOKKEY AND 
                          b.RELATIONCODE = 20001 AND 
			  i.ISBN10 is not null and
			  i2.ISBN10 is not null and
                          b.PARENTBOOKKEY IN
                                ( 
                                  SELECT BOOKFAMILY.PARENTBOOKKEY
                                    FROM BOOKFAMILY
                                    WHERE BOOKFAMILY.LASTMAINTDATE >= 
                                                      ( 
                                                        SELECT MAX(FEEDERROR.PROCESSDATE)
                                                          FROM FEEDERROR
                                                          WHERE FEEDERROR.ERRORDESC = 'Vista TMM Relationship File Completed'
                                                      ))
                  ORDER BY i.ISBN10, b.SORTORDER
              

              OPEN titleout_cursor

              FETCH NEXT FROM titleout_cursor
                INTO 
                  @cursor_row$PARENTISBN$2, 
                  @cursor_row$CHILDISBN$2, 
                  @cursor_row$QUANTITY$2, 
                  @cursor_row$SORTORDER$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@FETCH_STATUS = -1)
                    BEGIN

                      INSERT INTO FEEDERROR
                        (
                          FEEDERROR.ISBN, 
                          FEEDERROR.BATCHNUMBER, 
                          FEEDERROR.PROCESSDATE, 
                          FEEDERROR.ERRORDESC
                        )
                        VALUES 
                          (
                            'Not Avail', 
                            '1', 
                            getdate(), 
                            'NO RELATIONSHIP ROWS TO PROCESS'
                          )

                      BREAK 

                    END

                  SET @c_parentisbn = @cursor_row$PARENTISBN$2
                  SET @c_childisbn = @cursor_row$CHILDISBN$2
                  SET @c_sequencenum = SYSDB.SSMA.LPAD_VARCHAR(CAST( @cursor_row$SORTORDER$2 AS varchar(8000)), 7, '0')
                  SET @c_quantity = SYSDB.SSMA.LPAD_VARCHAR(CAST( @cursor_row$QUANTITY$2 AS varchar(8000)), 4, '0')

                  /*  060105 compensate for null quantities assume they = 1 */
                  SET @c_quantity = IsNull(@c_quantity, '0001')

                  /* output record */
                  SET @lv_output_string = (isnull(@c_recordtype, '') + isnull(@c_titreltype, '') + isnull(@c_parentisbn, '') + isnull(@c_childisbn, '') + isnull(@c_quantity, '') + isnull(@c_statuscode, '') + isnull(@c_sequencenum, ''))
		  execute @OLEResult = sp_OAMethod @lv_file_id_num, 'WriteLine', Null, @lv_output_string
		  IF @OLEResult <> 0 PRINT 'Error: WriteLine Failed.'
	          IF @OLEResult <> 0 begin
		     PRINT 'Error: WriteLine Failed'
	             goto destroy
	          end
                  SET @lv_totalcount = (@lv_totalcount + 1)
                  SET @c_compqtysum = @c_compqtysum +  @c_quantity

                  FETCH NEXT FROM titleout_cursor
                    INTO 
                      @cursor_row$PARENTISBN$2, 
                      @cursor_row$CHILDISBN$2, 
                      @cursor_row$QUANTITY$2, 
                      @cursor_row$SORTORDER$2

                END

              CLOSE titleout_cursor

              DEALLOCATE titleout_cursor

            END

            /* * Output New Sequence Number * */

            /*  Open Sequence File  */
	    set @c_filename = @p_location + '\tmfyirel_in_seqnum.txt'
	    execute @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @lv_file_id_num2 OUT, @c_filename, 8, 1

	    IF @OLEResult <> 0 PRINT 'Error: OpenTextFile Failedxxxxx.'


            SET @lv_output_string = CAST( @i_sequence_num AS varchar(30))
	    execute @OLEResult = sp_OAMethod @lv_file_id_num2, 'WriteLine', Null, @lv_output_string
	    IF @OLEResult <> 0 PRINT 'Error: WriteLine Failed.'
	    exec @OLEResult = sp_OAMethod @lv_file_id_num2, 'Close', null
	    IF @OLEResult <> 0 PRINT 'Error: Close Failed.'
            /* create footer record */

            /*  default college detail lines to 8 zeros  */
            SET @lv_defaultstring = '00000000'

            /* total 8 zeros for college total */
            IF (@lv_totalcount IS NULL)
              SET @lv_totalcount_char = '0'
            ELSE 
              SET @lv_totalcount_char = CAST( @lv_totalcount AS varchar(30))

	    while len(@lv_totalcount_char) < 8
	    begin
	        set @lv_totalcount_char = '0' + @lv_totalcount_char
	    end

	    set @c_parentisbn = IsNull(@c_parentisbn, '')
	    set @c_childisbn = IsNull(@c_childisbn, '')

            if (@c_compqtysum IS NULL) begin
              set @c_compqtysum_char = '0'
            end else begin

	    while len(@c_compqtysum_char) < 8
	    begin
	        set @c_compqtysum_char = '0' + @c_compqtysum_char
	    end
	    end

            /*
             -- New Total record spec 060105 
             -- Pos 1-2                        Record Type      "T "
             -- Pos 3-10                      Detail record count (excludes the Header and Trailer record)
             -- Pos 11-20                     Date
             -- Pos 21-28                     Time
             -- Pos 29-36                     Total Component Quantity
             -- The rest is blank
             --*/

            SET @lv_output_string = ('T ' + isnull(@lv_totalcount_char, '') + isnull(@c_currentdate, '') + isnull(@c_currentdatetime, '') + isnull(@c_compqtysum_char, ''))
	    execute @OLEResult = sp_OAMethod @lv_file_id_num, 'WriteLine', Null, @lv_output_string
	    IF @OLEResult <> 0 PRINT 'Error: WriteLine Failed.'

            INSERT INTO FEEDERROR
              (FEEDERROR.BATCHNUMBER, FEEDERROR.PROCESSDATE, FEEDERROR.ERRORDESC)
              VALUES ('1', getdate(), 'Vista TMM Relationship File Completed')

	   exec @OLEResult = sp_OAMethod @lv_file_id_num, 'Close', null

            IF (cursor_status(N'local', N'titleout_cursor') = 1)
              BEGIN
                CLOSE titleout_cursor
                DEALLOCATE titleout_cursor
              END

          END

        /*  end of begin cursor loop  */

        DELETE FROM FEEDTITLERELUPDATE

destroy:
EXECUTE @OLEResult = sp_OADestroy @lv_file_id_num
EXECUTE @OLEResult = sp_OADestroy @lv_file_id_num2
EXECUTE @OLEResult = sp_OADestroy @lv_file_id_num3
EXECUTE @OLEResult = sp_OADestroy @FS

      END
go
grant execute on feedout_title_relationships  to public
go

