IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_num_pages')
BEGIN
  DROP  Procedure  onix21_num_pages
END
GO

  CREATE 
    PROCEDURE dbo.onix21_num_pages 
        @i_bookkey integer,
        @i_printingkey integer,
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
            @v_numpages integer,
            @v_pagecount integer,
            @v_tentativepagecount integer,
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

                SELECT @v_pagecount = isnull(dbo.PRINTING.PAGECOUNT, 0), @v_tentativepagecount = isnull(dbo.PRINTING.TENTATIVEPAGECOUNT, 0)
                  FROM dbo.PRINTING
                  WHERE ((dbo.PRINTING.BOOKKEY = @i_bookkey) AND 
                          (dbo.PRINTING.PRINTINGKEY = @i_printingkey))

                IF (@v_pagecount > 0)
                  SET @v_numpages = @v_pagecount
                ELSE 
                  SET @v_numpages = @v_tentativepagecount

                IF (@v_numpages > 0)
                  BEGIN
                    SET @v_xml = (isnull(@v_xml, '') + '<b061>' + isnull(CAST( @v_numpages AS varchar(100)), '') + '</b061>' + isnull(@v_record_separator, ''))
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
grant execute on onix21_num_pages  to public
go

