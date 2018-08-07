IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_trim_size')
BEGIN
  DROP  Procedure  onix21_trim_size
END
GO


  CREATE 
    PROCEDURE dbo.onix21_trim_size 
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
            @v_trimlength numeric(9, 4),
            @v_trimwidth numeric(9, 4),
            @v_spinesize numeric(9, 4),
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
              FROM dbo.PRINTING
              WHERE ((dbo.PRINTING.BOOKKEY = @i_bookkey) AND 
                      (dbo.PRINTING.PRINTINGKEY = @i_printingkey))


            IF (@v_count > 0)
              BEGIN

                SELECT @v_trimlength = dbo.FRACTION_TO_DECIMAL(isnull(dbo.PRINTING.TRIMSIZELENGTH, dbo.PRINTING.ESTTRIMSIZELENGTH)), 
	       @v_trimwidth = dbo.FRACTION_TO_DECIMAL(isnull(dbo.PRINTING.TRIMSIZEWIDTH, dbo.PRINTING.ESTTRIMSIZEWIDTH)), 
	       @v_spinesize = dbo.FRACTION_TO_DECIMAL(dbo.PRINTING.SPINESIZE)
                  FROM dbo.PRINTING
                  WHERE ((dbo.PRINTING.BOOKKEY = @i_bookkey) AND 
                          (dbo.PRINTING.PRINTINGKEY = @i_printingkey))

                IF (((@v_trimlength > 0) AND 
                                (@v_trimwidth > 0)) OR 
                        (@v_spinesize > 0))
                  BEGIN

                    IF ((@v_trimlength > 0) AND 
                            (@v_trimwidth > 0))
                      BEGIN

                        /*  Height */

                        SET @v_xml = (isnull(@v_xml, '') + '<measure>')

                        SET @v_xml = (isnull(@v_xml, '') + '<c093>04</c093>')

                        SET @v_xml = (isnull(@v_xml, '') + '<c094>' + isnull(ltrim(cast(@v_trimlength as varchar(20))), '') + '</c094>')

                        SET @v_xml = (isnull(@v_xml, '') + '<c095>in</c095>')

                        SET @v_xml = (isnull(@v_xml, '') + '</measure>' + isnull(@v_record_separator, ''))

                        /*  Width */

                        SET @v_xml = (isnull(@v_xml, '') + '<measure>')

                        SET @v_xml = (isnull(@v_xml, '') + '<c093>05</c093>')

                        SET @v_xml = (isnull(@v_xml, '') + '<c094>' + isnull(ltrim(cast(@v_trimwidth as varchar(20))), '') + '</c094>')

                        SET @v_xml = (isnull(@v_xml, '') + '<c095>in</c095>')

                        SET @v_xml = (isnull(@v_xml, '') + '</measure>' + isnull(@v_record_separator, ''))

                      END

                    IF (@v_spinesize > 0)
                      BEGIN

                        /*  thickness */

                        SET @v_xml = (isnull(@v_xml, '') + '<measure>')

                        SET @v_xml = (isnull(@v_xml, '') + '<c093>03</c093>')

                        SET @v_xml = (isnull(@v_xml, '') + '<c094>' + isnull(ltrim(cast(@v_spinesize as varchar(20))), '') + '</c094>')

                        SET @v_xml = (isnull(@v_xml, '') + '<c095>in</c095>')

                        SET @v_xml = (isnull(@v_xml, '') + '</measure>' + isnull(@v_record_separator, ''))

                      END

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
grant execute on onix21_trim_size  to public
go

