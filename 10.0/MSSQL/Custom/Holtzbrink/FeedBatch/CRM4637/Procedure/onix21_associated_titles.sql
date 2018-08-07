IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_associated_titles')
BEGIN
  DROP  Procedure  onix21_associated_titles
END
GO


  CREATE 
    PROCEDURE dbo.onix21_associated_titles 
        @i_bookkey integer,
        @i_qsicode_gentables integer,
        @i_qsicode_subgentables integer,
        @i_firstone_only integer,
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
            @v_xml_temp varchar(max),
            @v_count integer,
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @v_datacode integer,
            @v_datasubcode integer,
            @v_associatedtitle_bookkey integer,
            @v_tableid integer,
            @v_rownumber integer,
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
            @cursor_row$ASSOCIATETITLEBOOKKEY integer          

          SET @v_xml = ''
          SET @v_xml_temp = ''
          SET @v_tableid = 440
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
            SET @v_rownumber = 0
            SET @v_jobkey = @i_jobkey
            SET @v_batchkey = @i_batchkey

            /*  datacode */

            IF (@i_qsicode_gentables > 0)
              BEGIN
                SELECT @v_count = count( * )
                  FROM dbo.GENTABLES
                  WHERE ((dbo.GENTABLES.TABLEID = @v_tableid) AND 
                          (dbo.GENTABLES.QSICODE = @i_qsicode_gentables))

                IF (@v_count > 0)
                  BEGIN
                    SELECT @v_datacode = dbo.GENTABLES.DATACODE
                      FROM dbo.GENTABLES
                      WHERE ((dbo.GENTABLES.TABLEID = @v_tableid) AND 
                              (dbo.GENTABLES.QSICODE = @i_qsicode_gentables))
                  END
                ELSE 
                  BEGIN
                    SET @o_error_code = @return_nodata_err_code
                    SET @o_error_desc = ('Unable to find qsicode ' + isnull(CAST( @i_qsicode_gentables AS varchar(100)), '') + ' on gentables for tableid ' + isnull(CAST( @v_tableid AS varchar(100)), ''))
                    RETURN 
                  END
              END
            ELSE 
              BEGIN
                SET @o_error_code = @return_sys_err_code
                SET @o_error_desc = 'Cannot access associatedtitles.  Gentables qsicode is required.'
                RETURN 
              END

            IF (@v_datacode IS NOT NULL)
              BEGIN
                SET @o_error_code = @return_nodata_err_code
                SET @o_error_desc = ('Unable to find qsicode ' + isnull(CAST( @i_qsicode_gentables AS varchar(100)), '') + ' on gentables for tableid ' + isnull(CAST( @v_tableid AS varchar(100)), ''))
                RETURN 
              END

            /*  datasubcode - not required */

            IF (@i_qsicode_subgentables > 0)
              BEGIN

                SELECT @v_count = count( * )
                  FROM dbo.SUBGENTABLES
                  WHERE ((dbo.SUBGENTABLES.TABLEID = @v_tableid) AND 
                          (dbo.SUBGENTABLES.DATACODE = @v_datacode) AND 
                          (dbo.SUBGENTABLES.QSICODE = @i_qsicode_subgentables))

                IF (@v_count > 0)
                  BEGIN
                    SELECT @v_datacode = dbo.SUBGENTABLES.DATASUBCODE
                      FROM dbo.SUBGENTABLES
                      WHERE ((dbo.SUBGENTABLES.TABLEID = @v_tableid) AND 
                              (dbo.SUBGENTABLES.DATACODE = @v_datacode) AND 
                              (dbo.SUBGENTABLES.QSICODE = @i_qsicode_subgentables))
                  END
                ELSE 
                  BEGIN
                    SET @o_error_code = @return_nodata_err_code
                    SET @o_error_desc = ('Unable to find qsicode ' + isnull(CAST( @i_qsicode_subgentables AS varchar(100)), '') + ' on subgentables for tableid ' + isnull(CAST( @v_tableid AS varchar(100)), '') + ' and datacode ' + isnull(CAST( @v_datacode AS varchar(100)), ''))
                    RETURN 
                  END
              END
            ELSE 
              SET @v_datasubcode = 0
            IF (@v_datasubcode IS NOT NULL)
              BEGIN
                SET @o_error_code = @return_nodata_err_code
                SET @o_error_desc = ('Unable to find qsicode ' + isnull(CAST( @i_qsicode_subgentables AS varchar(100)), '') + ' on subgentables for tableid ' + isnull(CAST( @v_tableid AS varchar(100)), '') + ' and datacode ' + isnull(CAST( @v_datacode AS varchar(100)), ''))
                RETURN 
              END
            EXEC dbo.GET_ONIXCODE_SUBGENTABLES @v_tableid, @v_datacode, @v_datasubcode, @v_onixsubcode OUTPUT, @v_onixsubcodedefault OUTPUT, @v_otheronixcode OUTPUT, @v_otheronixcodedesc OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode <= 0)
              BEGIN

                /*  error or not found */
                SET @o_error_code = @v_retcode
                SET @o_error_desc = @v_error_desc
                RETURN 
              END

            IF @v_onixsubcode  IS NOT NULL
              BEGIN
                /*  return -99 */
                SET @o_error_code = @return_onixcode_notfound
                SET @o_error_desc = ('Onixsubcode not found for tableid ' + isnull(CAST( @v_tableid AS varchar(100)), '') + ' and datacode ' + isnull(CAST( @v_datacode AS varchar(100)), '') + ' and datasubcode ' + isnull(CAST( @v_datasubcode AS varchar(100)), ''))
                RETURN 
              END
            BEGIN
              DECLARE 
                @cursor_row$ASSOCIATETITLEBOOKKEY$2 integer              
              DECLARE 
                associatedtitles_cursor CURSOR LOCAL 
                 FOR 
                  SELECT a.ASSOCIATETITLEBOOKKEY
                    FROM dbo.ASSOCIATEDTITLES a
                    WHERE ((a.BOOKKEY = @i_bookkey) AND 
                            (a.ASSOCIATIONTYPECODE = @v_datacode) AND 
                            (a.ASSOCIATIONTYPESUBCODE = isnull(@v_datasubcode, 0)))
                  ORDER BY a.SORTORDER
              

              OPEN associatedtitles_cursor

              FETCH NEXT FROM associatedtitles_cursor
                INTO @cursor_row$ASSOCIATETITLEBOOKKEY$2


              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN
                  IF (@@FETCH_STATUS = -1)
                    BEGIN
                      /*  return 0 */
                      SET @o_error_code = @return_nodata_err_code
                      SET @o_error_desc = ''
                      RETURN 
                    END
                  SET @v_rownumber = (@v_rownumber + 1)
                  SET @v_associatedtitle_bookkey = @cursor_row$ASSOCIATETITLEBOOKKEY$2
                  IF (@v_associatedtitle_bookkey > 0)
                    BEGIN
                      SET @v_xml = (isnull(@v_xml, '') + '<relatedproduct>')
                      SET @v_xml = (isnull(@v_xml, '') + '<h208>' + isnull(@v_onixsubcode, '') + '</h208>')
                      /*  ean */
                      SET @v_xml_temp = ''
                      EXEC dbo.ONIX21_EAN_NODASHES @v_associatedtitle_bookkey, @v_xml_temp OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                      IF (@v_retcode < 0)
                        BEGIN
                          SET @o_error_code = @return_sys_err_code
                          SET @o_error_desc = @v_error_desc
                          RETURN 
                        END
                      IF (@v_retcode = 0)
                        BEGIN
                         /*  no data found */
                          SET @v_msg = ('EAN not found for associated bookkey ' + isnull(CAST( @v_associatedtitle_bookkey AS varchar(100)), ''))
                          SET @v_msgshort = 'EAN not found'
                          SET @v_messagetypecode = 3
                          /*  Warning */
                          EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 0, 0, '', '', @i_userid, @i_bookkey, @v_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                        END

                      IF @v_retcode > 0 AND len(@v_xml_temp) > 0
                        SET @v_xml = (isnull(@v_xml, '') + isnull(@v_xml_temp, ''))

                      /*  isbn10 */

                      SET @v_xml_temp = ''
                      EXEC dbo.ONIX21_ISBN10 @v_associatedtitle_bookkey, @v_xml_temp OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                      IF (@v_retcode < 0)
                        BEGIN
                          SET @o_error_code = @return_sys_err_code
                          SET @o_error_desc = @v_error_desc
                          RETURN 
                        END
                      IF (@v_retcode = 0)
                        BEGIN
                          /*  no data found */
                          SET @v_msg = ('ISBN10 not found for associated bookkey ' + isnull(CAST( @v_associatedtitle_bookkey AS varchar(100)), ''))
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

                      IF ((@i_firstone_only = 1) AND 
                              (@v_rownumber = 1))
                        BEGIN
                          /*  DONE */
                          BREAK 
                        END

                    END

                  FETCH NEXT FROM associatedtitles_cursor
                    INTO @cursor_row$ASSOCIATETITLEBOOKKEY$2

                END

              CLOSE associatedtitles_cursor
              DEALLOCATE associatedtitles_cursor
            END
      END

go
grant execute on onix21_associated_titles  to public
go


