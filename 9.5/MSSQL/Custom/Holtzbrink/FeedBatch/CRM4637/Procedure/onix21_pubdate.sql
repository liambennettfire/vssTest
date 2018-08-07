IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_pubdate')
BEGIN
  DROP  Procedure  onix21_pubdate
END
GO

  CREATE 
    PROCEDURE dbo.onix21_pubdate 
        @i_bookkey integer,
        @i_printingkey integer,
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
            @v_datetypecode integer,
            @v_pubdate datetime,
            @v_record_separator varchar(2),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer          

          SET @v_xml = ''
          SET @v_record_separator =  char(13) +  char(10)
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1

            SET @o_error_code = @return_no_err_code
            SET @o_error_desc = ''
            SET @o_xml = ''
            SET @v_datetypecode = 8

            /*  Retrieve Data from coretitleinfo */

            SELECT @v_count = count( * )
              FROM dbo.BOOKDATES
              WHERE ((dbo.BOOKDATES.BOOKKEY = @i_bookkey) AND 
                      (dbo.BOOKDATES.PRINTINGKEY = @i_printingkey) AND 
                      (dbo.BOOKDATES.DATETYPECODE = @v_datetypecode))

            IF (@v_count > 0)
              BEGIN

                SELECT @v_pubdate = dbo.BOOKDATES.BESTDATE
                  FROM dbo.BOOKDATES
                  WHERE ((dbo.BOOKDATES.BOOKKEY = @i_bookkey) AND 
                          (dbo.BOOKDATES.PRINTINGKEY = @i_printingkey) AND 
                          (dbo.BOOKDATES.DATETYPECODE = @v_datetypecode))


                /* ***************************************** */
                /*  Pub Date                                 */
                /* ***************************************** */

                IF (@v_pubdate IS NOT NULL)
                  BEGIN
                    SET @v_xml = ('<b003>' + isnull(convert(varchar(20), @v_pubdate, 112), '') + '</b003>' + isnull(@v_record_separator, ''))
                    SET @o_xml = @v_xml
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
                SET @o_error_desc = ''
                RETURN 
              END

      END

go
grant execute on onix21_pubdate  to public
go

