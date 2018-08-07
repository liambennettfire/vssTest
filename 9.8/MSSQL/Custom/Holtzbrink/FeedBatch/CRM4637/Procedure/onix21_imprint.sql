IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_imprint')
BEGIN
  DROP  Procedure  onix21_imprint
END
GO

  CREATE 
    PROCEDURE dbo.onix21_imprint 
        @i_bookkey integer,
        @i_orglevelkey integer,
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
            @v_imprint varchar(40),
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
            SET @v_orglevelkey = @i_orglevelkey
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

                    SELECT @v_imprint = dbo.REPLACE_XCHARS(o.ORGENTRYDESC)
                      FROM dbo.BOOKORGENTRY bo, dbo.ORGENTRY o
                      WHERE ((bo.ORGLEVELKEY = o.ORGLEVELKEY) AND 
                              (bo.ORGENTRYKEY = o.ORGENTRYKEY) AND 
                              (bo.BOOKKEY = @i_bookkey) AND 
                              (bo.ORGLEVELKEY = @v_orglevelkey))

                    IF @v_imprint IS NOT NULL
                      BEGIN

                        SET @v_xml = '<imprint>'
                        SET @v_xml = (isnull(@v_xml, '') + '<b079><![CDATA[' + isnull(@v_imprint, '') + ']]></b079>')
                        SET @v_xml = (isnull(@v_xml, '') + '</imprint>' + isnull(@v_record_separator, ''))
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
grant execute on onix21_imprint  to public
go

