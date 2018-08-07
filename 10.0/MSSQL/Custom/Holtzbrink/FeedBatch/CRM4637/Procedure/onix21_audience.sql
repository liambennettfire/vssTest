IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_audience')
BEGIN
  DROP  Procedure  onix21_audience
END
GO

  CREATE 
    PROCEDURE dbo.onix21_audience 
        @i_bookkey integer,
        @i_batchkey integer,
        @i_jobkey integer,
        @i_userid varchar(50),
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
            @v_audiencecode integer,
            @v_tableid integer,
            @v_onixcode varchar(30),
            @v_onixcodedefault integer,
            @v_msg varchar(4000),
            @v_msgshort varchar(255),
            @v_messagetypecode integer,
            @v_batchkey integer,
            @v_jobkey integer,
            @v_printingkey integer,
            @v_record_separator varchar(2),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer,
            @return_onixcode_notfound integer,
            @cursor_row$AUDIENCECODE integer          

          SET @v_xml = ''
          SET @v_record_separator = char(13) + char(10)
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1
          SET @return_onixcode_notfound =  -99

            SET @o_error_code = @return_no_err_code
            SET @o_error_desc = ''
            SET @o_xml = ''
            SET @v_tableid = 460
            SET @v_jobkey = @i_jobkey
            SET @v_batchkey = @i_batchkey
            SET @v_printingkey = 1
            BEGIN
              DECLARE 
                @cursor_row$AUDIENCECODE$2 integer              
              DECLARE 
                audience_cursor CURSOR LOCAL 
                 FOR 
                  SELECT dbo.BOOKAUDIENCE.AUDIENCECODE
                    FROM dbo.BOOKAUDIENCE
                    WHERE (dbo.BOOKAUDIENCE.BOOKKEY = @i_bookkey)
                  ORDER BY dbo.BOOKAUDIENCE.SORTORDER

              OPEN audience_cursor

              FETCH NEXT FROM audience_cursor
                INTO @cursor_row$AUDIENCECODE$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN
                  IF (@@FETCH_STATUS = -1)
                    BEGIN
                      /*  return 0 */
                      SET @o_error_code = @return_nodata_err_code
                      SET @o_error_desc = ''
                      RETURN 
                    END
                  SET @v_audiencecode = @cursor_row$AUDIENCECODE$2
                  IF (@v_audiencecode > 0)
                    BEGIN
                      EXEC dbo.GET_ONIXCODE_GENTABLES @v_tableid, @v_audiencecode, @v_onixcode OUTPUT, @v_onixcodedefault OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                      IF (@v_retcode <= 0)
                        BEGIN
                          /*  error or not found */
                          SET @o_error_code = @v_retcode
                          SET @o_error_desc = @v_error_desc
                          RETURN 
                        END
                      IF @v_onixcode IS NOT NULL
                        BEGIN
                          SET @v_xml = (isnull(@v_xml, '') + '<b073>' + isnull(@v_onixcode, '') + '</b073>' + isnull(@v_record_separator, ''))
                          SET @o_xml = @v_xml
                        END
                      ELSE 
                        IF (@v_jobkey > 0)
                          BEGIN
                            SET @v_msg = ('Onixcode not found for tableid ' + isnull(CAST( @v_tableid AS varchar(100)), '') + ' and datacode ' + isnull(CAST( @v_audiencecode AS varchar(100)), ''))
                            SET @v_msgshort = 'Onixcode not found'
                            SET @v_messagetypecode = 3

                            /*  Warning */

                           EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 0, 0, '', '', @i_userid, @i_bookkey, 1, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                          END
                    END

                  FETCH NEXT FROM audience_cursor
                    INTO @cursor_row$AUDIENCECODE$2

                END

              CLOSE audience_cursor

              DEALLOCATE audience_cursor

            END
      END
go
grant execute on onix21_audience  to public
go


