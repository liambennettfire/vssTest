IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_title')
BEGIN
  DROP  Procedure  onix21_title
END
GO


  CREATE 
    PROCEDURE dbo.onix21_title 
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
            @v_title varchar(255),
            @v_subtitle varchar(255),
            @v_titleprefix varchar(15),
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
              FROM dbo.BOOK b, dbo.BOOKDETAIL bd
              WHERE ((b.BOOKKEY = bd.BOOKKEY) AND 
                      (b.BOOKKEY = @i_bookkey))


            IF (@v_count > 0)
              BEGIN

                SELECT @v_title = dbo.REPLACE_XCHARS(b.TITLE), @v_titleprefix = dbo.REPLACE_XCHARS(bd.TITLEPREFIX), @v_subtitle = dbo.REPLACE_XCHARS(b.SUBTITLE)
                  FROM dbo.BOOK b, dbo.BOOKDETAIL bd
                  WHERE ((b.BOOKKEY = bd.BOOKKEY) AND 
                          (b.BOOKKEY = @i_bookkey))


                /* ***************************************** */
                /*  Title Composite                          */
                /* ***************************************** */

                IF @v_title IS NOT NULL
                  BEGIN
                    SET @v_xml = '<title>'

                    /*  Title Type (Distictive Title) */

                    SET @v_xml = (isnull(@v_xml, '') + '<b202>01</b202>')

                    /*  title prefix and title with prefix */

                    IF @v_titleprefix IS NOT NULL
                      BEGIN
                        SET @v_xml = (isnull(@v_xml, '') + '<b203><![CDATA[' + isnull(@v_titleprefix, '') + ' ' + isnull(@v_title, '') + ']]></b203>')
                        SET @v_xml = (isnull(@v_xml, '') + '<b030><![CDATA[' + isnull(@v_titleprefix, '') + ']]></b030>')
                      END

                    /*  title without prefix */

                    SET @v_xml = (isnull(@v_xml, '') + '<b031><![CDATA[' + isnull(@v_title, '') + ']]></b031>')

                    /*  subtitle */

                    IF @v_subtitle IS NOT NULL
                      SET @v_xml = (isnull(@v_xml, '') + '<b029><![CDATA[' + isnull(@v_subtitle, '') + ']]></b029>')

                    SET @v_xml = (isnull(@v_xml, '') + '</title>' + isnull(@v_record_separator, ''))

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
grant execute on onix21_title  to public
go

