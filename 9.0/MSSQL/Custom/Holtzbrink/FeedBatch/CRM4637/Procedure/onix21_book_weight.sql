IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_book_weight')
BEGIN
  DROP  Procedure  onix21_book_weight
END
GO


  CREATE 
    PROCEDURE dbo.onix21_book_weight 
        @i_bookkey integer,
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
            @v_bookweight numeric(9, 4),
            @v_record_separator varchar(2),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer          

          SET @v_xml = ''
          SET @v_record_separator = char(13) + char(10)
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1


            SET @o_error_code = @return_no_err_code
            SET @o_error_desc = ''
            SET @o_xml = ''

            SELECT @v_count = count( * )
              FROM dbo.BOOKSIMON
              WHERE (dbo.BOOKSIMON.BOOKKEY = @i_bookkey)


            IF (@v_count > 0)
              BEGIN

                SELECT @v_bookweight = isnull(dbo.BOOKSIMON.BOOKWEIGHT, 0)
                  FROM dbo.BOOKSIMON
                  WHERE (dbo.BOOKSIMON.BOOKKEY = @i_bookkey)

                IF (@v_bookweight > 0)
                  BEGIN

                    /*  Weight */
                    SET @v_xml = (isnull(@v_xml, '') + '<measure>')
                    SET @v_xml = (isnull(@v_xml, '') + '<c093>08</c093>')
                    SET @v_xml = (isnull(@v_xml, '') + '<c094>' + isnull(ltrim(SYSDB.SSMA.TO_CHAR_NUMERIC(@v_bookweight, '90.9999')), '') + '</c094>')
                    SET @v_xml = (isnull(@v_xml, '') + '<c095>lb</c095>')
                    SET @v_xml = (isnull(@v_xml, '') + '</measure>' + isnull(@v_record_separator, ''))
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
grant execute on onix21_book_weight  to public
go

