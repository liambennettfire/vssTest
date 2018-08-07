IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_discountcode')
BEGIN
  DROP  Procedure  onix21_discountcode
END
GO

  CREATE 
    PROCEDURE dbo.onix21_discountcode 
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
            @v_discountcode integer,
            @v_discountdesc varchar(40),
            @v_discountcodedesc varchar(30),
            @v_tableid integer,
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
            SET @v_tableid = 459

            /*  Retrieve Data from coretitleinfo */

            SELECT @v_count = count( * )
              FROM dbo.BOOKDETAIL
              WHERE (dbo.BOOKDETAIL.BOOKKEY = @i_bookkey)

            IF (@v_count > 0)
              BEGIN

                SELECT @v_discountcode = dbo.BOOKDETAIL.DISCOUNTCODE
                  FROM dbo.BOOKDETAIL
                  WHERE (dbo.BOOKDETAIL.BOOKKEY = @i_bookkey)

                IF (@v_discountcode > 0)
                  BEGIN
                    SET @v_xml = '<discountcoded>'
                    SET @v_xml = (isnull(@v_xml, '') + '<j363>02</j363>')
                    SET @v_discountdesc = dbo.GENTABLES_LONGDESC_FUNCTION(@v_tableid, @v_discountcode)

                    IF @v_discountdesc IS NOT NULL
                      SET @v_xml = (isnull(@v_xml, '') + '<j378><![CDATA[' + isnull(@v_discountdesc, '') + ']]></j378>')

                    SELECT @v_count = count( * )
                      FROM dbo.GENTABLES
                      WHERE ((dbo.GENTABLES.TABLEID = @v_tableid) AND 
                              (dbo.GENTABLES.DATACODE = @v_discountcode))

                    IF (@v_count > 0)
                      BEGIN
                        SELECT @v_discountcodedesc = dbo.GENTABLES.EXTERNALCODE
                          FROM dbo.GENTABLES
                          WHERE ((dbo.GENTABLES.TABLEID = @v_tableid) AND 
                                  (dbo.GENTABLES.DATACODE = @v_discountcode))

                        IF @v_discountcodedesc IS NOT NULL
                          SET @v_xml = (isnull(@v_xml, '') + '<j364><![CDATA[' + isnull(@v_discountcodedesc, '') + ']]></j364>')

                      END

                    SET @v_xml = (isnull(@v_xml, '') + '</discountcoded>' + isnull(@v_record_separator, ''))
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
grant execute on onix21_discountcode  to public
go


