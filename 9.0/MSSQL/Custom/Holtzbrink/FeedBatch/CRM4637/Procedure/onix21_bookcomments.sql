IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_bookcomments')
BEGIN
  DROP  Procedure  onix21_bookcomments
END
GO

  CREATE 
    PROCEDURE dbo.onix21_bookcomments 
        @i_bookkey integer,
        @i_printingkey integer,
        @i_commenttypecode integer,
        @i_commenttypesubcode integer,
        @i_commenttype varchar(100),
        @o_xml TEXT OUTPUT ,
        @o_error_code integer OUTPUT ,
        @o_error_desc varchar(255) OUTPUT 
    AS
      BEGIN
          DECLARE 
	    @blob_pointer varbinary (16),
            @v_onix_format varchar(2),
            @v_count integer,
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @v_tableid integer,
            @v_onixsubcode varchar(30),
            @v_onixsubcodedefault integer,
            @v_otheronixcode varchar(10),
            @v_otheronixcodedesc varchar(100),
            @v_record_separator varchar(2),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer,
            @return_onixcode_notfound integer,
	    @v_cnt   integer,
	    @v_offset   integer ,
 	    @v_xml varchar(8000)       


          SET @v_record_separator = char(13) + char(10)
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1
          SET @return_onixcode_notfound =  -99
          SET @v_offset = 0

            SET @o_error_code = @return_no_err_code
            SET @o_error_desc = ''
            SET @o_xml = ''
            SET @v_tableid = 284

            IF ((@i_commenttypecode IS NULL) OR 
                    (@i_commenttypecode <= 0) OR 
                    (@i_commenttypesubcode IS NULL) OR 
                    (@i_commenttypesubcode <= 0))
              BEGIN

                /*  commenttypecode and commenttypesubcode need to be passed in */
                SET @o_error_code = @return_sys_err_code
                SET @o_error_desc = 'Comment Type and Comment Sub Type are required.'
                RETURN 
              END

            /*  try to get onix codes - must find onixcodes */
            EXEC dbo.GET_ONIXCODE_SUBGENTABLES @v_tableid, @i_commenttypecode, @i_commenttypesubcode, @v_onixsubcode OUTPUT, @v_onixsubcodedefault OUTPUT, @v_otheronixcode OUTPUT, @v_otheronixcodedesc OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode <= 0)
              BEGIN

                /*  error or not found */
                SET @o_error_code = @v_retcode
                SET @o_error_desc = @v_error_desc
                RETURN 
              END

            IF @v_onixsubcode IS NOT NULL
              BEGIN

                /*  return -99 */
                SET @o_error_code = @return_onixcode_notfound
                SET @o_error_desc = ('Onixcode not found for tableid ' + isnull(CAST( @v_tableid AS varchar(100)), '') + ' and datacode ' + isnull(CAST( @i_commenttypecode AS varchar(100)), '') + ' and datasubcode ' + isnull(CAST( @i_commenttypesubcode AS varchar(100)), ''))
                RETURN 
              END

            /*  Retrieve Data from bookcomment */

            SELECT @v_count = count( * )
              FROM dbo.BOOKCOMMENTS
              WHERE ((dbo.BOOKCOMMENTS.BOOKKEY = @i_bookkey) AND 
                      (dbo.BOOKCOMMENTS.PRINTINGKEY = @i_printingkey) AND 
                      (dbo.BOOKCOMMENTS.COMMENTTYPECODE = @i_commenttypecode) AND 
                      (dbo.BOOKCOMMENTS.COMMENTTYPESUBCODE = @i_commenttypesubcode))


            IF (@v_count > 0)
              BEGIN

                SELECT @o_xml = CASE upper(@i_commenttype) WHEN 'HTML' THEN dbo.BOOKCOMMENTS.COMMENTHTML WHEN 'LITE' THEN dbo.BOOKCOMMENTS.COMMENTHTMLLITE ELSE dbo.BOOKCOMMENTS.COMMENTTEXT END
                  FROM dbo.BOOKCOMMENTS
                  WHERE ((dbo.BOOKCOMMENTS.BOOKKEY = @i_bookkey) AND 
                          (dbo.BOOKCOMMENTS.PRINTINGKEY = @i_printingkey) AND 
                          (dbo.BOOKCOMMENTS.COMMENTTYPECODE = @i_commenttypecode) AND 
                          (dbo.BOOKCOMMENTS.COMMENTTYPESUBCODE = @i_commenttypesubcode))


                IF (upper(@i_commenttype) = 'HTML')
                  SET @v_onix_format = '02'
                ELSE 
                  IF (upper(@i_commenttype) = 'LITE')
                    SET @v_onix_format = '02'
                  ELSE 
                    SET @v_onix_format = '07'

                IF @o_xml IS NOT NULL
                  BEGIN

		--NOTE:
	        --datatype text cannot be declared in body (oracle allow that but it's limited to 32k so it's not a real clob)
		--using working table to build large text
		 select @v_cnt = count(*)
		 from temp_blob
		 where keyid = 99999999
	         if @v_cnt = 0 begin
		         insert into temp_blob (keyid)
		        	values(99999999)
	         end else begin
			update temp_blob
			set htmldata = null
			where keyid = 99999999	
		 end
	      
	 	 select @blob_pointer = textptr(htmldata) 
		 from temp_blob
		 where keyid = 99999999


	          SET @v_xml = '<othertext>' + '<d102>' + isnull(@v_onixsubcode, '') + '</d102>' +  '<d103>' + isnull(@v_onix_format, '') + '</d103>' +  '<d104><![CDATA[' 
		  updatetext temp_blob.htmldata @blob_pointer @v_offset null @v_xml

		  set @v_offset = len(@v_xml) + 1
		  updatetext temp_blob.htmldata @blob_pointer @v_offset null @o_xml

	          SET @v_xml = ']]></d104>' +  '</othertext>' + isnull(@v_record_separator, '')
	 	  set @v_offset =  @v_offset + datalength(@o_xml)
		  updatetext temp_blob.htmldata @blob_pointer @v_offset null @v_xml
		  
		  select @o_xml = htmldata
		  from temp_blob
		  where keyid = 99999999

                  END
                ELSE 
                  BEGIN

                    /*  return 0 */
                    SET @o_error_code = @return_nodata_err_code
                    SET @o_error_desc = ''
                    RETURN 
                  END
              END
            ELSE 
              BEGIN

                /*  return 0 */
                SET @o_error_code = @return_nodata_err_code
                SET @o_error_desc = ('There is no comment entered for bookkey ' + isnull(CAST( @i_bookkey AS varchar(100)), '') + ' for commenttypecode ' + isnull(CAST( @i_commenttypecode AS varchar(100)), '') + ' and commenttypesubcode ' + isnull(CAST( @i_commenttypesubcode AS varchar(100)), ''))
                RETURN 
              END

END

go
grant execute on onix21_bookcomments  to public
go

