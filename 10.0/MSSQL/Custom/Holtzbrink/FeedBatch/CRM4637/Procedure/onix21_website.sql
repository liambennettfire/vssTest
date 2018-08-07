IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_website')
BEGIN
  DROP  Procedure  onix21_website
END
GO

  CREATE 
    PROCEDURE dbo.onix21_website 
        @i_bookkey integer,
        @i_printingkey integer,
        @i_batchkey integer,
        @i_jobkey integer,
        @i_userid varchar(100),
        @o_xml text OUTPUT ,
        @o_error_code integer OUTPUT ,
        @o_error_desc varchar(255) OUTPUT 
    AS
      BEGIN
          DECLARE 
            @v_xml varchar(max),
            @v_count integer,
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @v_filetypecode integer,
            @v_tableid integer,
            @v_onixcode varchar(30),
            @v_onixcodedefault integer,
            @v_msg varchar(4000),
            @v_msgshort varchar(255),
            @v_messagetypecode integer,
            @v_batchkey integer,
            @v_jobkey integer,
            @v_record_separator varchar(2),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer,
            @return_onixcode_notfound integer,
            @cursor_row$FILETYPECODE integer,
            @cursor_row$PATHNAME varchar(8000),
            @cursor_row$DATADESC varchar(8000)          

          SET @v_xml = ''
          SET @v_tableid = 354
          SET @v_record_separator = char(13) + char(10)
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1
          SET @return_onixcode_notfound =  -99


            SET @o_error_code = @return_no_err_code

            SET @o_error_desc = ''

            SET @o_xml = ''

            SET @v_jobkey = @i_jobkey

            SET @v_batchkey = @i_batchkey

            BEGIN

              DECLARE 
                @cursor_row$FILETYPECODE$2 integer,
                @cursor_row$PATHNAME$2 varchar(8000),
                @cursor_row$DATADESC$2 varchar(8000)              

              DECLARE 
                website_cursor CURSOR LOCAL 
                 FOR 
                  SELECT f.FILETYPECODE, f.PATHNAME, g.DATADESC
                    FROM dbo.FILELOCATION f, dbo.GENTABLES g
                    WHERE ((f.FILETYPECODE = g.DATACODE) AND 
                            (g.TABLEID = @v_tableid) AND 
                            (f.BOOKKEY = @i_bookkey) AND 
                            (f.PRINTINGKEY = @i_printingkey) AND 
                            (g.GEN1IND = 1))
                  ORDER BY f.SORTORDER
              

              OPEN website_cursor

              FETCH NEXT FROM website_cursor
                INTO @cursor_row$FILETYPECODE$2, @cursor_row$PATHNAME$2, @cursor_row$DATADESC$2


              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@FETCH_STATUS = -1)
                    BEGIN

                      /*  return 0 */

                      SET @o_error_code = @return_nodata_err_code

                      SET @o_error_desc = ''

                      RETURN 

                    END

                  SET @v_filetypecode = @cursor_row$FILETYPECODE$2

                  IF (@v_filetypecode > 0)
                    BEGIN

                      EXEC dbo.GET_ONIXCODE_GENTABLES @v_tableid, @v_filetypecode, @v_onixcode OUTPUT, @v_onixcodedefault OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                      IF (@v_retcode < 0)
                        BEGIN

                          /*  error */

                          SET @o_error_code = @v_retcode

                          SET @o_error_desc = @v_error_desc

                          RETURN 

                        END

                      IF @v_retcode = 0 OR @v_onixcode IS NOT NULL
                        BEGIN
                          /*  not found */
                          SET @v_onixcode = '00'
                        END

                      IF @v_onixcode IS NOT NULL and @cursor_row$PATHNAME$2 IS NOT NULL
                        BEGIN

                          SET @v_xml = (isnull(@v_xml, '') + '<website>')

                          /*  Website Role */

                          SET @v_xml = (isnull(@v_xml, '') + '<b367>' + isnull(@v_onixcode, '') + '</b367>')

                          /*  Website Description */

                          IF (@v_onixcode = '00')
                            SET @v_xml = (isnull(@v_xml, '') + '<b294>' + isnull(@cursor_row$DATADESC$2, '') + '</b294>')

                          /*  Website Link */

                          SET @v_xml = (isnull(@v_xml, '') + '<b295>' + isnull(@cursor_row$PATHNAME$2, '') + '</b295>')

                          SET @v_xml = (isnull(@v_xml, '') + '</website>' + isnull(@v_record_separator, ''))

                          SET @o_xml = @v_xml

                        END
                      ELSE 
                        IF (@v_jobkey > 0)
                          BEGIN

                            SET @v_msg = ('Onixcode not found for tableid ' + isnull(CAST( @v_tableid AS varchar(100)), '') + ' and datacode ' + isnull(CAST( @v_filetypecode AS varchar(100)), ''))

                            SET @v_msgshort = 'Onixcode not found'

                            SET @v_messagetypecode = 3

                            /*  Warning */

                            EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 0, 0, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 


                          END

                    END

                  FETCH NEXT FROM website_cursor
                    INTO @cursor_row$FILETYPECODE$2, @cursor_row$PATHNAME$2, @cursor_row$DATADESC$2

                END

              CLOSE website_cursor

              DEALLOCATE website_cursor

            END

      END

go
grant execute on onix21_website  to public
go

