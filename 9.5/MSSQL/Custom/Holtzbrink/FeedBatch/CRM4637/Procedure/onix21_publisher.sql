IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_publisher')
BEGIN
  DROP  Procedure  onix21_publisher
END
GO

  CREATE 
    PROCEDURE dbo.onix21_publisher 
        @i_bookkey integer,
        @i_filterkey integer,
        @o_xml text OUTPUT ,
        @o_error_code integer OUTPUT ,
        @o_error_desc varchar(8000) OUTPUT 
    AS
      BEGIN
          DECLARE 
            @v_xml varchar(max),
            @v_count integer,
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @v_publisher varchar(40),
            @v_orglevelkey integer,
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

            /*  get publisher level (use eloquence publisher level) */

            SELECT @v_count = count( * )
              FROM dbo.FILTERORGLEVEL
              WHERE (dbo.FILTERORGLEVEL.FILTERKEY = @i_filterkey)


            IF (@v_count <= 0)
              BEGIN
                SET @o_error_code = @return_sys_err_code
                SET @o_error_desc = 'Could not find publisher row on filterorglevel.'
                RETURN 
              END

            SELECT @v_orglevelkey = dbo.FILTERORGLEVEL.FILTERORGLEVELKEY
              FROM dbo.FILTERORGLEVEL
              WHERE (dbo.FILTERORGLEVEL.FILTERKEY = @i_filterkey)


            IF (@v_orglevelkey > 0)
              BEGIN
                SELECT @v_count = count( * )
                  FROM dbo.BOOKORGENTRY bo, dbo.ORGENTRY o
                  WHERE ((bo.ORGLEVELKEY = o.ORGLEVELKEY) AND 
                          (bo.ORGENTRYKEY = o.ORGENTRYKEY) AND 
                          (bo.BOOKKEY = @i_bookkey) AND 
                          (bo.ORGLEVELKEY = @v_orglevelkey))

                IF (@v_count > 0)
                  BEGIN
                    SELECT @v_publisher = dbo.REPLACE_XCHARS(o.ORGENTRYDESC)
                      FROM dbo.BOOKORGENTRY bo, dbo.ORGENTRY o
                      WHERE ((bo.ORGLEVELKEY = o.ORGLEVELKEY) AND 
                              (bo.ORGENTRYKEY = o.ORGENTRYKEY) AND 
                              (bo.BOOKKEY = @i_bookkey) AND 
                              (bo.ORGLEVELKEY = @v_orglevelkey))


                    IF @v_publisher IS NOT NULL
                      BEGIN
                        SET @v_xml = '<publisher>'
                        SET @v_xml = (isnull(@v_xml, '') + '<b291>01</b291>')
                        SET @v_xml = (isnull(@v_xml, '') + '<b081><![CDATA[' + isnull(@v_publisher, '') + ']]></b081>')
                        SET @v_xml = (isnull(@v_xml, '') + '</publisher>' + isnull(@v_record_separator, ''))
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

      END

go
grant execute on onix21_publisher  to public
go

