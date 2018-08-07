IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TMM_To_Artesia_Create_File]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TMM_To_Artesia_Create_File]
go

CREATE procedure [dbo].[TMM_To_Artesia_Create_File]  
    @i_batchkey integer,
    @i_jobkey integer,
    @i_jobtypecode integer,
    @i_jobtypesubcode integer,
    @i_userid varchar(30),
    @i_location varchar(2000),
    @o_filename varchar(2000) output,
    @o_error_code integer output ,
    @o_error_desc varchar(2000) output 
AS

BEGIN
  DECLARE 
    @v_messagetypecode integer,
    @v_msg varchar(4000),
    @v_msgshort varchar(255),
    @v_retcode integer,
    @v_error_desc varchar(2000),
    @v_batchkey integer,
    @v_jobkey integer,
    @v_filepath varchar(2000),
    @v_filename varchar(2000),
    @v_file_id_num integer,
    @v_output_string varchar(max),
    @v_xml varchar(max),
    @return_sys_err_code integer,
    @return_nodata_err_code integer,
    @OLEResult integer,
    @return_no_err_code integer,
    @FS integer,
    @Source nvarchar(255),
    @Description nvarchar(255),
    @Output nvarchar(255),
    @hrhex char(10),
    @v_num_titles integer,
    @v_titles_xml xml,
    @v_cmd_string varchar(4000),
    @c_datestamp varchar (25)
      
  SET @v_xml = ''
--  SET @v_record_separator = char(13) + char(10)
  SET @return_sys_err_code =  -1
  SET @return_nodata_err_code = 0
  SET @return_no_err_code = 1

  SET @v_jobkey = @i_jobkey
  SET @v_batchkey = @i_batchkey
  SET @v_num_titles = 0
--  SET @v_key1 = 0
--  SET @v_key2 = 0
--  SET @v_key3 = 0
  SET @o_filename = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF (@v_batchkey IS NULL) BEGIN
    SET @v_messagetypecode = 2
    /*  Error */
    SET @v_msg = 'Cannot create file without a batchkey'
    SET @v_msgshort = 'Cannot create file without a batchkey'
    EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, 0, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
    
  	SET @o_error_code = -1
    
    RETURN 
  END

  IF (@v_jobkey IS NULL) BEGIN
    SET @v_messagetypecode = 2
    /*  Error */
    SET @v_msg = 'Cannot create file without a jobkey'
    SET @v_msgshort = 'Cannot create file without a jobkey'
    EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, 0, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

  	SET @o_error_code = -2

    RETURN 
  END

  IF @i_location IS NULL BEGIN
    SET @v_messagetypecode = 2
    /*  Error */
    SET @v_msg = 'Cannot create file - location is empty'
    SET @v_msgshort = 'Cannot create file - location is empty'
    EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, 0, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
    
  	SET @o_error_code = -3
    
    RETURN 
  END
    
  SELECT @v_num_titles = count(*)
    FROM TMMToArtesia_bookkeys
   WHERE title_xml is not null
    
  IF COALESCE(@v_num_titles,0) > 0 BEGIN
--    SET @v_cmd_string = 'del ' + @i_location + 'TMM_TO_ARTESIA_*'
--    exec master.dbo.xp_cmdshell @v_cmd_string    
    --SELECT @v_filename = 'TMM_TO_ARTESIA_' + dbo.PADL(substring(cast(datepart(yy,getdate())as varchar),3,2),2,'0') + dbo.PADL(cast(datepart(mm,getdate()) as varchar),2,'0') + dbo.PADL(cast(datepart(dd,getdate())as varchar),2,'0') + '.xml'
    select @c_datestamp = replace(convert(varchar,getdate(),101),'/','') + ltrim(replace(substring(convert(varchar,getdate(),113),13,8) ,':',''))
    SELECT @v_filename = 'TMM_TO_ARTESIA_' + @c_datestamp + '.xml'
		SELECT @v_filepath = @i_location + @v_filename
		
    /*  Open Output File */
    -- EXEC SYSDB.SSMA.UTL_FILE_FOPEN$IMPL @i_location, @v_filename, 'W', 32000, @v_file_id_num OUTPUT 
	  execute @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	  IF @OLEResult <> 0 begin
	    PRINT 'Error: Scripting.FileSystemObject Failed.'
	    
		  SET @v_msg = 'Error: Scripting.FileSystemObject Failed.'
		  SET @v_msgshort = 'Error: Scripting.FileSystemObject Failed.'
	    SET @v_messagetypecode = 2
		  EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @OLEResult, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
	    
   		SET @o_error_code = -4

      goto destroy
    end

--    execute @OLEResult = sp_OAMethod @FS, 'DeleteFile', NULL, @v_filepath
--	  IF @OLEResult <> 0 begin
--	    PRINT 'Error: DeleteFile Failed'
--
--		  SET @v_msg = 'Error: DeleteFile Failed.'
--		  SET @v_msgshort = 'Error: DeleteFile Failed.'
--	    SET @v_messagetypecode = 2
--		  EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @OLEResult, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
--	    
--   		SET @o_error_code = -5
--
--      goto destroy
--    end

	  execute @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @v_file_id_num OUT, @v_filepath, 2, 1
	  IF @OLEResult <> 0 begin
	    PRINT 'Error: OpenTextFile Failed'

		  SET @v_msg = 'Error: OpenTextFile Failed.'
		  SET @v_msgshort = 'Error: OpenTextFile Failed.'
	    SET @v_messagetypecode = 2
		  EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @OLEResult, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
	    
   		SET @o_error_code = -6

      goto destroy
    end
    
    /*  Create Header Information for Feed */
    /*  output acsii equivalent of quiestion mark to avoid oracle compiler converting to bind variable */
    SET @v_output_string = '<' + char(63) + 'xml version="1.0"' + ' encoding="ISO-8859-1"' + char(63) + '>'
	  execute @OLEResult = sp_OAMethod @v_file_id_num, 'WriteLine', Null, @v_output_string
	  IF @OLEResult <> 0 begin
	    PRINT 'Error: WriteLine Failed'

		  SET @v_msg = 'Error: WriteLine Failed.'
		  SET @v_msgshort = 'Error: WriteLine Failed.'
	    SET @v_messagetypecode = 2
		  EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @OLEResult, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
	    
   		SET @o_error_code = -7

	    goto destroy
	  end

    /* v_output_string := '<!DOCTYPE ONIXmessage SYSTEM "http://www.editeur.org/onix/2.1/short/onix-international.dtd">'; */
    /* UTL_FILE.PUT(v_file_id_num,v_output_string); */

    /* get titles xml from the database */
    SET @v_titles_xml = 
    (SELECT 
      @v_num_titles as "NumberOfTitles", 
      (SELECT title_xml as "*"
         FROM TMMToArtesia_bookkeys
        WHERE title_xml is not null         
       FOR XML PATH(''), TYPE)
     FOR XML PATH(''), ROOT('Titles')) 

    SET @v_output_string = CAST(@v_titles_xml as nvarchar(max))

    /* UTL_FILE.PUT_LINE(v_file_id_num,v_output_string); */
		execute @OLEResult = sp_OAMethod @v_file_id_num, 'WriteLine', Null, @v_output_string
	  IF @OLEResult <> 0 begin
		  PRINT 'Error: WriteLine Failed'

		  SET @v_msg = 'Error: WriteLine Failed.'
		  SET @v_msgshort = 'Error: WriteLine Failed.'
	    SET @v_messagetypecode = 2
		  EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @OLEResult, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
	    
   		SET @o_error_code = -8

	    goto destroy
	  end
    
	  --exec @OLEResult = sp_OAMethod @FS, 'Close', @v_file_id_num

    SET @o_filename = @v_filename
    
    /*  Information */
    SET @v_messagetypecode = 4
    SET @v_msg = (isnull(CAST( @v_num_titles AS varchar), '') + ' titles exported to file')
    SET @v_msgshort = (isnull(CAST( @v_num_titles AS varchar), '') + ' titles exported')
    EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, 0, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

    destroy:
    IF @o_error_code < 0 and @OLEResult <> 0 BEGIN
      EXEC sp_hexadecimal @OLEResult, @hrhex OUT
      SELECT @output = '  HRESULT: ' + @hrhex
      PRINT @output
    END 
    
    IF @o_error_code < 0 BEGIN    
      EXEC @OLEResult = sp_OAGetErrorInfo @FS, @Source OUT, @Description OUT
      IF @OLEResult = 0 BEGIN
        SELECT @Output = N'  Source: '
        IF COALESCE(@Source,'') <> '' BEGIN
          SELECT @Output = @Output + @Source
        END
        PRINT @Output
        SELECT @Output = N'  Description: '
        IF COALESCE(@Description,'') <> '' BEGIN
          SELECT @Output = @Output + @Description
        END
        PRINT @Output
      END
      ELSE BEGIN
        PRINT N' sp_OAGetErrorInfo failed.'
      END
    END
    
    exec @OLEResult = sp_OAMethod @FS, 'Close', @v_file_id_num
    EXECUTE @OLEResult = sp_OADestroy @v_file_id_num
    EXECUTE @OLEResult = sp_OADestroy @FS
  END
END

go
grant execute on TMM_To_Artesia_Create_File to public
go


