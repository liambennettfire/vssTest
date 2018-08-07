IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'tmm_seesaw_create_file')
BEGIN
  DROP  Procedure  tmm_seesaw_create_file
END
GO

 
 
  CREATE 
    PROCEDURE dbo.tmm_seesaw_create_file 
        @i_xmltype integer,
        @i_batchkey integer,
        @i_jobkey integer,
        @i_jobtypecode integer,
        @i_jobtypesubcode integer,
        @i_userid varchar(50),
        @i_location varchar(2000),
        @o_error_code integer OUTPUT ,
        @o_error_desc varchar(255) OUTPUT 
    AS
      BEGIN
          DECLARE 
            @cursor_row$KEY1 integer,
            @cursor_row$KEY2 integer,
            @cursor_row$KEY3 integer,
	    @v_sbstr varchar(1000),
            @cursor_row$VALIDXML varchar(8000),
            @v_messagetypecode integer,
            @v_msg varchar(4000),
            @v_msgshort varchar(255),
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @v_batchkey integer,
            @v_jobkey integer,
            @v_filename varchar(2000),
            @v_file_id_num integer,
            @v_output_string varchar(max),
            @v_xml varchar(max),
            @v_currentdate varchar(15),
            @v_number_of_titles integer,
            @v_key1 integer,
            @v_key2 integer,
            @v_key3 integer,
            @v_record_separator varchar(2),
            @v_linelength integer,
            @v_offset integer,
            @v_part varchar(4000),
            @v_clob_len integer,
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
	    @OLEResult integer,
            @return_no_err_code integer    ,
	    @FS integer
      
          SET @v_xml = ''
          SET @v_record_separator = char(13) + char(10)
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1


            SET @v_jobkey = @i_jobkey
            SET @v_batchkey = @i_batchkey
            SET @v_number_of_titles = 0
            SET @v_key1 = 0
            SET @v_key2 = 0
            SET @v_key3 = 0

            IF (@v_batchkey IS NULL)
              BEGIN
               SET @v_messagetypecode = 2
                /*  Error */
                SET @v_msg = 'Cannot create file without a batchkey'
                SET @v_msgshort = 'Cannot create file without a batchkey'
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, 0, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END

            IF (@v_jobkey IS NULL)
              BEGIN
                SET @v_messagetypecode = 2
                /*  Error */
                SET @v_msg = 'Cannot create file without a jobkey'
                SET @v_msgshort = 'Cannot create file without a jobkey'
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, 0, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END

            IF @i_location IS NULL
              BEGIN

                SET @v_messagetypecode = 2
                /*  Error */
                SET @v_msg = 'Cannot create file - location is empty'
                SET @v_msgshort = 'Cannot create file - location is empty'
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, 0, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END
            SET @v_filename = @i_location + '\' + 'TMM_TO_SEESAW_' + isnull(CAST( @v_batchkey AS varchar(100)), '') + '.xml'


            /*  Open Output File */
           -- EXEC SYSDB.SSMA.UTL_FILE_FOPEN$IMPL @i_location, @v_filename, 'W', 32000, @v_file_id_num OUTPUT 
		execute @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
		IF @OLEResult <> 0 begin
		  PRINT 'Error: Scripting.FileSystemObject Failed.'
	          goto destroy
	        end

		execute @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @v_file_id_num OUT, @v_filename, 8, 1
		IF @OLEResult <> 0 begin
		  PRINT 'Error: OpenTextFile Failed1'
	          goto destroy
	        end

            /*  Create Header Information for Onix Feed */

           /*  output acsii equivalent of quiestion mark to avoid oracle compiler converting to bind variable */
            SET @v_output_string = '<' + char(63) + 'xml version="1.0"' + ' encoding="ISO-8859-1"' + char(63) + '>'
		execute @OLEResult = sp_OAMethod @v_file_id_num, 'WriteLine', Null, @v_output_string
	        IF @OLEResult <> 0 begin
		   PRINT 'Error: WriteLine Failed'
	           goto destroy
	        end


            /* v_output_string := '<!DOCTYPE ONIXmessage SYSTEM "http://www.editeur.org/onix/2.1/short/onix-international.dtd">'; */
            /* UTL_FILE.PUT(v_file_id_num,v_output_string); */
            SET @v_xml = ''
            SET @v_xml = '<ONIXmessage>'
            SET @v_xml = @v_xml + '<header>'

            /*  Sender */
            SET @v_xml = @v_xml + '<SenderIdentifier>'
            SET @v_xml = @v_xml + '<m379>02</m379>'
            SET @v_xml = @v_xml + '<b233>System</b233>'
            SET @v_xml = @v_xml + '<b244>TMM</b244>'
            SET @v_xml = @v_xml + '</SenderIdentifier>' + @v_record_separator

            /*  Recipient */
            SET @v_xml = @v_xml + '<AddresseeIdentifier>'
            SET @v_xml = @v_xml + '<m380>02</m380>'
            SET @v_xml = @v_xml + '<b233>System</b233>'
            SET @v_xml = @v_xml + '<b244>SEESAW</b244>'
            SET @v_xml = @v_xml + '</AddresseeIdentifier>' + @v_record_separator

            /*  Sequence Number */
            SET @v_xml = @v_xml + '<m180>' + isnull(CAST( @v_jobkey AS varchar(100)), '') + '</m180>' + @v_record_separator

            /*  Sent Date */
            set @v_currentdate =  substring(replace(replace(replace(convert(varchar(50), getdate(), 120), '-', ''), ':', ''), ' ' , ''), 0, 13)
            --SELECT @v_currentdate = SYSDB.SSMA.TO_CHAR_DATE(getdate(), 'YYYYMMDDHHMI')

            SET @v_xml = @v_xml + '<m182>' + isnull(@v_currentdate, '') + '</m182>' + @v_record_separator

            /*  Default Price Code */
            SET @v_xml = @v_xml + '<m185>01</m185>' + @v_record_separator

            /*  Default Currency Code */
            SET @v_xml = @v_xml + '<m186>USD</m186>' + @v_record_separator
            SET @v_xml = @v_xml + '</header>' + @v_record_separator
            SET @v_output_string = @v_xml


            /* UTL_FILE.PUT_LINE(v_file_id_num,v_output_string); */
		execute @OLEResult = sp_OAMethod @v_file_id_num, 'WriteLine', Null, @v_output_string
	        IF @OLEResult <> 0 begin
		   PRINT 'Error: WriteLine Failed'
	           goto destroy
	        end
            BEGIN
              DECLARE 
                @cursor_row$KEY1$2 integer,
                @cursor_row$KEY2$2 integer,
                @cursor_row$KEY3$2 integer,
                @cursor_row$VALIDXML$2 varchar(8000)              

              DECLARE  
                xml_cursor CURSOR LOCAL 
                 FOR 
                  SELECT 
                      x.KEY1, 
                      x.KEY2, 
                      x.KEY3, 
                      datalength(x.VALIDXML)
                    FROM dbo.QSIEXPORTXML x, dbo.QSIEXPORTKEYS k
                    WHERE ((x.KEY1 = k.KEY1) AND 
                            (x.KEY2 = k.KEY2) AND 
                            (x.KEY3 = k.KEY3) AND 
                            (isnull(x.INVALIDIND, 0) = 0) AND 
                            (x.QSIXMLTYPE = @i_xmltype) AND 
                            (k.QSIBATCHKEY = @i_batchkey))

              OPEN xml_cursor
              FETCH NEXT FROM xml_cursor
                INTO 
                  @cursor_row$KEY1$2, 
                  @cursor_row$KEY2$2, 
                  @cursor_row$KEY3$2, 
                  @v_clob_len

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN
                  IF (@@FETCH_STATUS = -1)
                    BEGIN
                      SET @v_messagetypecode = 4
		      set @v_clob_len = IsNull(@v_clob_len, 0)

                      /*  Information */
                      SET @v_msg = 'No New Title Information to Send to SeeSaw'
                      SET @v_msgshort = 'No New Title Information'
                      EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, 0, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                      BREAK 
                    END

                  SET @v_key1 = isnull(@cursor_row$KEY1$2, 0)
                  SET @v_key2 = isnull(@cursor_row$KEY2$2, 0)
                  SET @v_key3 = isnull(@cursor_row$KEY3$2, 0)
                  SET @v_linelength = 100
                  SET @v_offset = 1
                  PRINT 'v_clob_len :' + CAST( @v_clob_len AS varchar(100))
                  WHILE (@v_offset < @v_clob_len)
                    BEGIN
                      PRINT ('v_offset :' + isnull(CAST( @v_offset AS varchar(100)), ''))
                      PRINT ('v_linelength :' + isnull(CAST( @v_linelength AS varchar(100)), ''))

                      SELECT @v_sbstr = substring(VALIDXML, @v_offset, @v_linelength)
                      FROM QSIEXPORTXML
                      WHERE KEY1 = @cursor_row$KEY1$2 AND 
                            KEY2 = @cursor_row$KEY2$2 AND 
                            KEY3 = @cursor_row$KEY3$2 AND 
                            QSIXMLTYPE = @i_xmltype

		     PRINT @v_sbstr

		     execute @OLEResult = sp_OAMethod @v_file_id_num, 'WriteLine', Null, @v_sbstr
		     IF @OLEResult <> 0 begin
			 PRINT 'Error: WriteLine Failed'
		         goto destroy
		     end 
                      PRINT 'HERE'
                      SET @v_offset = (@v_offset + @v_linelength)
                    END

                  IF @v_clob_len > 0
                    BEGIN
                      SET @v_number_of_titles = (@v_number_of_titles + 1)
                    END

                  FETCH NEXT FROM xml_cursor
                    INTO 
                      @cursor_row$KEY1$2, 
                      @cursor_row$KEY2$2, 
                      @cursor_row$KEY3$2, 
                      @cursor_row$VALIDXML$2
                END

              CLOSE xml_cursor
              DEALLOCATE xml_cursor
            END

            SET @v_key1 = 0
            SET @v_key2 = 0
            SET @v_key3 = 0

            /*  Trailer */
            SET @v_xml = ''
            SET @v_xml = '<trailer>'

            /*  Number of Records */
            SET @v_xml = @v_xml + '<NoOfRecords>' + CAST( @v_number_of_titles AS varchar(100)) + '</NoOfRecords>' + @v_record_separator

            /*  End Time */
            set @v_currentdate =  substring(replace(replace(replace(convert(varchar(50), getdate(), 120), '-', ''), ':', ''), ' ' , ''), 0, 13)
            SET @v_xml = @v_xml + '<EndTime>' + @v_currentdate + '</EndTime>' + @v_record_separator
            SET @v_xml = @v_xml + '</trailer>' + @v_record_separator
            SET @v_xml = @v_xml + '</ONIXmessage>'
            SET @v_output_string = @v_xml

            /* UTL_FILE.PUT_LINE(v_file_id_num,v_output_string); */
	     execute @OLEResult = sp_OAMethod @v_file_id_num, 'WriteLine', Null, @v_output_string
	     IF @OLEResult <> 0 begin
		 PRINT 'Error: WriteLine Failed'
	         goto destroy
	     end 

	     exec @OLEResult = sp_OAMethod @FS, 'Close', @v_file_id_num

            IF (cursor_status(N'local', N'xml_cursor') = 1)
              BEGIN
                CLOSE xml_cursor
                DEALLOCATE xml_cursor
              END

            SET @v_messagetypecode = 4

            /*  Information */
            SET @v_msg = (isnull(CAST( @v_number_of_titles AS varchar(8000)), '') + ' titles exported to file')
            SET @v_msgshort = (isnull(CAST( @v_number_of_titles AS varchar(8000)), '') + ' titles exported')
            EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, 0, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

destroy:
exec @OLEResult = sp_OAMethod @FS, 'Close', @v_file_id_num
EXECUTE @OLEResult = sp_OADestroy @v_file_id_num
EXECUTE @OLEResult = sp_OADestroy @FS

END

go
grant execute on tmm_seesaw_create_file  to public
go


