IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_linked_titles')
BEGIN
  DROP  Procedure  onix21_linked_titles
END
GO
  CREATE 
    PROCEDURE dbo.onix21_linked_titles 
        @i_bookkey integer,
        @i_batchkey integer,
        @i_jobkey integer,
        @i_userid varchar(8000),
        @o_xml varchar(max) OUTPUT ,
        @o_error_code integer OUTPUT ,
        @o_error_desc varchar(8000) OUTPUT 
    AS
      BEGIN

        /* **************************************** */
        /*  This is a HBPUB Custom Procedure        */
        /* **************************************** */

          DECLARE 
            @v_xml varchar(max),
            @v_xml_temp varchar(max),
            @v_count integer,
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @v_datacode integer,
            @v_datasubcode integer,
            @v_linked_bookkey integer,
            @v_workkey integer,
            @v_linklevelcode integer,
            @v_tableid integer,
            @v_printingkey integer,
            @v_msg varchar(4000),
            @v_msgshort varchar(255),
            @v_messagetypecode integer,
            @v_batchkey integer,
            @v_jobkey integer,
            @v_onixsubcode varchar(30),
            @v_onixsubcodedefault integer,
            @v_otheronixcode varchar(10),
            @v_otheronixcodedesc varchar(100),
            @v_record_separator varchar(2),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer,
            @return_qsicode_notfound integer,
            @return_onixcode_notfound integer,
            @cursor_row$BOOKKEY integer,
            @cursor_row$MEDIATYPECODE integer,
            @cursor_row$MEDIATYPESUBCODE integer          
          SET @v_xml = ''
          SET @v_xml_temp = ''
          SET @v_tableid = 312
          SET @v_record_separator = char(13) + char(10)
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1
          SET @return_qsicode_notfound =  -98
          SET @return_onixcode_notfound =  -99


            SET @o_error_code = @return_no_err_code
            SET @o_error_desc = ''
            SET @o_xml = ''
            SET @v_printingkey = 1
            SET @v_jobkey = @i_jobkey
            SET @v_batchkey = @i_batchkey

            /*  linklevelcode 10 is primary title / 20 is subordinate title */

            SELECT @v_count = count( * )
              FROM dbo.BOOK b
              WHERE ((b.BOOKKEY = @i_bookkey) AND 
                      (b.LINKLEVELCODE IN (10, 20 )))

            IF (@v_count > 0)
              BEGIN

                SELECT @v_linklevelcode = b.LINKLEVELCODE, @v_workkey = b.WORKKEY
                  FROM dbo.BOOK b
                  WHERE (b.BOOKKEY = @i_bookkey)

                IF (@v_linklevelcode = 10)
                  BEGIN
                    /*  This is the primary title */
                    SET @v_workkey = @i_bookkey
                  END

                IF (@v_workkey > 0)
                  BEGIN
                    /*  get linked titles */
                    BEGIN

                      DECLARE 
                        @cursor_row$BOOKKEY$2 integer,
                        @cursor_row$MEDIATYPECODE$2 integer,
                        @cursor_row$MEDIATYPESUBCODE$2 integer                      

                      DECLARE 
                        linkedtitles_cursor CURSOR LOCAL 
                         FOR 
                          SELECT bd.BOOKKEY, bd.MEDIATYPECODE, bd.MEDIATYPESUBCODE
                            FROM dbo.BOOK b, dbo.BOOKDETAIL bd
                            WHERE ((b.BOOKKEY = bd.BOOKKEY) AND 
                                    (b.WORKKEY = @v_workkey) AND 
                                    (b.WORKKEY <> b.BOOKKEY))
                      

                      OPEN linkedtitles_cursor

                      FETCH NEXT FROM linkedtitles_cursor
                        INTO @cursor_row$BOOKKEY$2, @cursor_row$MEDIATYPECODE$2, @cursor_row$MEDIATYPESUBCODE$2


                      WHILE  NOT(@@FETCH_STATUS = -1)
                        BEGIN
                          IF (@@FETCH_STATUS = -1)
                            BEGIN

                              /*  return 0 */
                              SET @o_error_code = @return_nodata_err_code
                              SET @o_error_desc = ''
                              RETURN 
                            END

                          SET @v_linked_bookkey = @cursor_row$BOOKKEY$2
                          EXEC dbo.GET_ONIXCODE_SUBGENTABLES @v_tableid, @cursor_row$MEDIATYPECODE$2, @cursor_row$MEDIATYPESUBCODE$2, @v_onixsubcode OUTPUT, @v_onixsubcodedefault OUTPUT, @v_otheronixcode OUTPUT, @v_otheronixcodedesc OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                          IF (@v_retcode < 0)
                            BEGIN

                              /*  error or not found */
                              SET @o_error_code = @v_retcode
                              SET @o_error_desc = @v_error_desc
                              RETURN 
                            END

                          /*  From HBPUB - send CL for hardcover/PB for paperback/OTH for everything else */

                          IF (upper(@v_onixsubcode) = 'BB')
                            SET @v_onixsubcode = 'CL'
                          ELSE 
                            IF (upper(@v_onixsubcode) = 'BC')
                              SET @v_onixsubcode = 'PB'
                            ELSE 
                              SET @v_onixsubcode = 'OTH'

                          SET @v_xml = (isnull(@v_xml, '') + '<relatedproduct>')
                          SET @v_xml = (isnull(@v_xml, '') + '<h208>' + isnull(@v_onixsubcode, '') + '</h208>')

                          /*  ean */
                          SET @v_xml_temp = ''
                          EXEC dbo.ONIX21_EAN_NODASHES @v_linked_bookkey, @v_xml_temp OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                          IF (@v_retcode < 0)
                            BEGIN
                              SET @o_error_code = @return_sys_err_code
                              SET @o_error_desc = @v_error_desc
                              RETURN 
                            END

                          IF (@v_retcode = 0)
                            BEGIN

                              /*  no data found */
                              SET @v_msg = ('EAN not found for linked bookkey ' + isnull(CAST( @v_linked_bookkey AS varchar(8000)), ''))
                              SET @v_msgshort = 'EAN not found'
                              SET @v_messagetypecode = 3

                              /*  Warning */

                              EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 0, 0, '', '', @i_userid, @i_bookkey, @v_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                            END

                          IF ((@v_retcode > 0) AND 
                                  (len(@v_xml_temp) > 0))
                            SET @v_xml = (isnull(@v_xml, '') + isnull(@v_xml_temp, ''))

                          /*  isbn10 */

                          SET @v_xml_temp = ''
                          EXEC dbo.ONIX21_ISBN10 @v_linked_bookkey, @v_xml_temp OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                          IF (@v_retcode < 0)
                            BEGIN
                              SET @o_error_code = @return_sys_err_code
                              SET @o_error_desc = @v_error_desc
                              RETURN 
                            END

                          IF (@v_retcode = 0)
                            BEGIN

                              /*  no data found */
                              SET @v_msg = ('ISBN10 not found for linked bookkey ' + isnull(CAST( @v_linked_bookkey AS varchar(50)), ''))
                              SET @v_msgshort = 'ISBN10 not found'
                              SET @v_messagetypecode = 3

                              /*  Warning */
                              EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 0, 0, '', '', @i_userid, @i_bookkey, @v_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                            END

                          IF ((@v_retcode > 0) AND 
                                  (len(@v_xml_temp) > 0))
                            SET @v_xml = (isnull(@v_xml, '') + isnull(@v_xml_temp, ''))
                            SET @v_xml = (isnull(@v_xml, '') + '</relatedproduct>' + isnull(@v_record_separator, ''))
                            SET @o_xml = @v_xml

                          FETCH NEXT FROM linkedtitles_cursor
                            INTO @cursor_row$BOOKKEY$2, @cursor_row$MEDIATYPECODE$2, @cursor_row$MEDIATYPESUBCODE$2

                        END
                      CLOSE linkedtitles_cursor
                      DEALLOCATE linkedtitles_cursor
                    END
                  END
                ELSE 
                  BEGIN

                    /*  return 0 */
                    SET @o_error_code = @return_nodata_err_code
                    SET @o_error_desc = 'workkey is empty'
                    RETURN 
                  END
              END
            ELSE 
              BEGIN
                /*  return 0 */
                SET @o_error_code = @return_nodata_err_code
                SET @o_error_desc = ''
                RETURN 
              END

      END

go
grant execute on onix21_linked_titles  to public
go

