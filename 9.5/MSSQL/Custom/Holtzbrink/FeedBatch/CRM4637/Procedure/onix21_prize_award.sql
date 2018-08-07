IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_prize_award')
BEGIN
  DROP  Procedure  onix21_prize_award
END
GO

  CREATE 
    PROCEDURE dbo.onix21_prize_award 
        @i_bookkey integer,
        @i_batchkey integer,
        @i_jobkey integer,
        @i_userid varchar(8000),
        @o_xml text OUTPUT ,
        @o_error_code integer OUTPUT ,
        @o_error_desc varchar(8000) OUTPUT 
    AS
      BEGIN

        /* **************************************** */
        /*  This is a HBPUB Custom Procedure        */
        /* **************************************** */

          DECLARE 
            @v_xml varchar(max),
            @v_count integer,
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @v_awarddesc varchar(40),
            @v_yeardesc varchar(40),
            @v_tableid integer,
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
            @cursor_row$CATEGORYCODE integer,
            @cursor_row$CATEGORYSUBCODE integer,
            @cursor_row$CATEGORYSUB2CODE integer,
            @cursor_row$AWARDDESC varchar(8000)          

          SET @v_xml = ''
          SET @v_tableid = 431
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
            SET @v_printingkey = 1

            BEGIN

              DECLARE 
                @cursor_row$CATEGORYCODE$2 integer,
                @cursor_row$CATEGORYSUBCODE$2 integer,
                @cursor_row$CATEGORYSUB2CODE$2 integer,
                @cursor_row$AWARDDESC$2 varchar(8000)              

              DECLARE 
                award_cursor CURSOR LOCAL 
                 FOR 
                  SELECT 
                      c.CATEGORYCODE, 
                      c.CATEGORYSUBCODE, 
                      c.CATEGORYSUB2CODE, 
                      dbo.REPLACE_XCHARS(dbo.SUBGENT_LONGDESC_FUNCTION(c.CATEGORYTABLEID, c.CATEGORYCODE, c.CATEGORYSUBCODE)) AS AWARDDESC
                    FROM dbo.BOOKSUBJECTCATEGORY c
                    WHERE ((c.BOOKKEY = @i_bookkey) AND 
                            (c.CATEGORYTABLEID = @v_tableid))
                  ORDER BY c.SORTORDER
              

              OPEN award_cursor

              FETCH NEXT FROM award_cursor
                INTO 
                  @cursor_row$CATEGORYCODE$2, 
                  @cursor_row$CATEGORYSUBCODE$2, 
                  @cursor_row$CATEGORYSUB2CODE$2, 
                  @cursor_row$AWARDDESC$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN
                  IF (@@FETCH_STATUS = -1)
                    BEGIN

                      /*  return 0 */
                      SET @o_error_code = @return_nodata_err_code
                      SET @o_error_desc = ''
                      RETURN 
                    END

                  SET @v_awarddesc = @cursor_row$AWARDDESC$2

                  IF @v_awarddesc IS NOT NULL
                    BEGIN
                      SET @v_xml = (isnull(@v_xml, '') + '<prize>')
                      SET @v_xml = (isnull(@v_xml, '') + '<g126><![CDATA[' + isnull(@v_awarddesc, '') + ']]></g126>')
                      SET @v_xml = (isnull(@v_xml, '') + '</prize>' + isnull(@v_record_separator, ''))
                      SET @o_xml = @v_xml

                    END
                  ELSE 
                    IF (@v_jobkey > 0)
                      BEGIN
                        SET @v_msg = ('Award Description not found for tableid ' + isnull(CAST( @v_tableid AS varchar(100)), '') + ' and datacode ' + isnull(CAST( @cursor_row$CATEGORYCODE$2 AS varchar(100)), '') + ' and datasubcode ' + isnull(CAST( @cursor_row$CATEGORYSUBCODE$2 AS varchar(100)), ''))
                        SET @v_msgshort = 'Award Description not found'
                        SET @v_messagetypecode = 3

                        /*  Warning */
                        EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 0, 0, '', '', @i_userid, @i_bookkey, @v_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                      END

                  FETCH NEXT FROM award_cursor
                    INTO 
                      @cursor_row$CATEGORYCODE$2, 
                      @cursor_row$CATEGORYSUBCODE$2, 
                      @cursor_row$CATEGORYSUB2CODE$2, 
                      @cursor_row$AWARDDESC$2

                END

              CLOSE award_cursor

              DEALLOCATE award_cursor

            END


      END

go
grant execute on onix21_prize_award  to public
go


