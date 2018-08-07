IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_bisac_subjects')
BEGIN
  DROP  Procedure  onix21_bisac_subjects
END
GO

  CREATE 
    PROCEDURE dbo.onix21_bisac_subjects 
        @i_bookkey integer,
        @i_printingkey integer,
        @i_batchkey integer,
        @i_jobkey integer,
        @i_userid varchar(50),
        @o_xml text OUTPUT ,
        @o_error_code integer OUTPUT ,
        @o_error_desc varchar(255) OUTPUT 
    AS
          DECLARE 

            @v_xml varchar(max),
            @v_count integer,
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @v_bisacsubject varchar(25),
            @v_bisacsubjectdesc varchar(100),
            @v_datacode integer,
            @v_datasubcode integer,
            @v_tableid integer,
            @v_msg varchar(4000),
            @v_msgshort varchar(255),
            @v_messagetypecode integer,
            @v_jobkey integer,
            @v_batchkey integer,
            @v_rownumber integer,
            @v_record_separator varchar(2),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer,
            @return_onixcode_notfound integer,
            @cursor_row$BISACDATACODE varchar(8000),
            @cursor_row$DATADESC varchar(8000),
            @cursor_row$DATACODE integer,
            @cursor_row$DATASUBCODE integer          
          SET @v_xml = ''

          SET @v_record_separator = char(13) + char(10)
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1
          SET @return_onixcode_notfound =  -99


            SET @o_error_code = @return_no_err_code
            SET @o_error_desc = ''
            SET @o_xml = ''
            SET @v_tableid = 339
            SET @v_jobkey = @i_jobkey
            SET @v_batchkey = @i_batchkey
            SET @v_rownumber = 0

            BEGIN

              DECLARE 
                @cursor_row$BISACDATACODE$2 varchar(100),
                @cursor_row$DATADESC$2 varchar(255),
                @cursor_row$DATACODE$2 integer,
                @cursor_row$DATASUBCODE$2 integer              

              DECLARE 
                subject_cursor CURSOR LOCAL 
                 FOR 
                  SELECT 
                      sg.BISACDATACODE, 
                      dbo.REPLACE_XCHARS(sg.DATADESC) AS DATADESC, 
                      sg.DATACODE, 
                      sg.DATASUBCODE
                    FROM dbo.BOOKBISACCATEGORY bb, dbo.SUBGENTABLES sg
                    WHERE ((bb.BOOKKEY = @i_bookkey) AND 
                            (bb.PRINTINGKEY = @i_printingkey) AND 
                            (sg.TABLEID = 339) AND 
                            (sg.DATACODE = bb.BISACCATEGORYCODE) AND 
                            (sg.DATASUBCODE = bb.BISACCATEGORYSUBCODE))
                  ORDER BY bb.SORTORDER
              

              OPEN subject_cursor

              FETCH NEXT FROM subject_cursor
                INTO 
                  @cursor_row$BISACDATACODE$2, 
                  @cursor_row$DATADESC$2, 
                  @cursor_row$DATACODE$2, 
                  @cursor_row$DATASUBCODE$2


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
                  SET @v_bisacsubject = @cursor_row$BISACDATACODE$2
                  SET @v_bisacsubjectdesc = SYSDB.SSMA.SUBSTR3_VARCHAR(@cursor_row$DATADESC$2, 1, 100)

                  /*  Onix suggests up to 100 chars */
                  IF @v_bisacsubject  IS NOT NULL
                    BEGIN
                      IF (@v_rownumber = 1)
                        BEGIN
                          /*  first subject */
                          SET @v_xml = (isnull(@v_xml, '') + '<b064>' + isnull(@v_bisacsubject, '') + '</b064>')
                        END
                      ELSE 
                        BEGIN
                          SET @v_xml = (isnull(@v_xml, '') + '<subject>')
                          SET @v_xml = (isnull(@v_xml, '') + '<b067>10</b067>')
                          SET @v_xml = (isnull(@v_xml, '') + '<b069>' + isnull(@v_bisacsubject, '') + '</b069>')
                          SET @v_xml = (isnull(@v_xml, '') + '<b070><![CDATA[' + isnull(@v_bisacsubjectdesc, '') + ']]></b070>')
                          SET @v_xml = (isnull(@v_xml, '') + '</subject>' + isnull(@v_record_separator, ''))
                        END
                      SET @o_xml = @v_xml
                    END
                  ELSE 
                    IF (@v_jobkey > 0)
                      BEGIN
                        SET @v_msg = ('Bisacdatacode not found for tableid ' + isnull(CAST( @v_tableid AS varchar(100)), '') + ' and datacode ' + isnull(CAST( @cursor_row$DATACODE$2 AS varchar(8000)), '') + ' and datasubcode ' + isnull(CAST( @cursor_row$DATASUBCODE$2 AS varchar(100)), ''))
                        SET @v_msgshort = 'Bisacdatacode not found'
                        SET @v_messagetypecode = 3

                       /*  Warning */
                        EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 0, 0, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                      END

                  FETCH NEXT FROM subject_cursor
                    INTO 
                      @cursor_row$BISACDATACODE$2, 
                      @cursor_row$DATADESC$2, 
                      @cursor_row$DATACODE$2, 
                      @cursor_row$DATASUBCODE$2

                END

              CLOSE subject_cursor

              DEALLOCATE subject_cursor
         
      END

go
grant execute on onix21_bisac_subjects  to public
go

