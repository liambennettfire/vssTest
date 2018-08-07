IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_short_title')
BEGIN
  DROP  Procedure  onix21_short_title
END
GO



  /*****
  *  WARNING ORA2MS-4016 line: 2 col: 25: Type number of argument i_bookkey  was changed to integer
  *  WARNING ORA2MS-4016 line: 3 col: 29: Type clob of argument o_xml  was changed to varchar(max)
  *  WARNING ORA2MS-4016 line: 4 col: 29: Type number of argument o_error_code  was changed to integer
  *  WARNING ORA2MS-4016 line: 5 col: 29: Type varchar2 of argument o_error_desc  was changed to varchar(8000)
  *****/

  CREATE 
    PROCEDURE dbo.onix21_short_title 
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
            @v_shorttitle varchar(50),
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
              FROM dbo.BOOK b
              WHERE (b.BOOKKEY = @i_bookkey)


            IF (@v_count > 0)
              BEGIN
                SELECT @v_shorttitle = dbo.REPLACE_XCHARS(b.SHORTTITLE)
                  FROM dbo.BOOK b
                  WHERE (b.BOOKKEY = @i_bookkey)


                /* ***************************************** */
                /*  Title Composite                          */
                /* ***************************************** */

                IF @v_shorttitle IS NOT NULL
                  BEGIN

                    SET @v_xml = '<title>'

                    /*  Title Type (Abbreviated Title) */

                    SET @v_xml = (isnull(@v_xml, '') + '<b202>05</b202>')

                    /*  Abbreviated Length */

                    SET @v_xml = (isnull(@v_xml, '') + '<b276>50</b276>')

                    /*  short title */

                    SET @v_xml = (isnull(@v_xml, '') + '<b203><![CDATA[' + isnull(@v_shorttitle, '') + ']]></b203>')

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
grant execute on onix21_short_title  to public
go

