IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_copyrightyear')
BEGIN
  DROP  Procedure  onix21_copyrightyear
END
GO


  CREATE 
    PROCEDURE dbo.onix21_copyrightyear 
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
            @v_copyrightyear integer,
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

            /*  Retrieve Data from coretitleinfo */

            SELECT @v_count = count( * )
              FROM dbo.BOOKDETAIL
              WHERE (dbo.BOOKDETAIL.BOOKKEY = @i_bookkey)


            IF (@v_count > 0)
              BEGIN
                SELECT @v_copyrightyear = dbo.BOOKDETAIL.COPYRIGHTYEAR
                  FROM dbo.BOOKDETAIL
                  WHERE (dbo.BOOKDETAIL.BOOKKEY = @i_bookkey)

                /* ***************************************** */
                /*  Copyright Year                           */
                /* ***************************************** */

                IF (@v_copyrightyear > 0)
                  BEGIN
                    SET @v_xml = (isnull(@v_xml, '') + '<b087>' + isnull(ltrim(rtrim(cast(@v_copyrightyear as varchar(4)))), '') + '</b087>' + isnull(@v_record_separator, ''))
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
grant execute on onix21_copyrightyear  to public
go

