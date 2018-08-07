IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_edition_type')
BEGIN
  DROP  Procedure  onix21_edition_type
END
GO


  CREATE 
    PROCEDURE dbo.onix21_edition_type 
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
            @v_editioncode integer,
            @v_editiondesc varchar(40),
            @v_tableid integer,
            @v_onixcode varchar(30),
            @v_onixcodedefault integer,
            @v_record_separator varchar(2),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer,
            @return_onixcode_notfound integer          

          SET @v_xml = ''
          SET @v_record_separator = char(13) + char(10)
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1
          SET @return_onixcode_notfound =  -99


            SET @o_error_code = @return_no_err_code
            SET @o_error_desc = ''
            SET @o_xml = ''
            SET @v_tableid = 200

            /*  Retrieve Data from coretitleinfo */

            SELECT @v_count = count( * )
              FROM dbo.BOOKDETAIL
              WHERE (dbo.BOOKDETAIL.BOOKKEY = @i_bookkey)

            IF (@v_count > 0)
              BEGIN

                SELECT @v_editioncode = dbo.BOOKDETAIL.EDITIONCODE
                  FROM dbo.BOOKDETAIL
                  WHERE (dbo.BOOKDETAIL.BOOKKEY = @i_bookkey)

                IF (@v_editioncode > 0)
                  BEGIN
                    SET @v_xml = ''
                    SET @v_editiondesc = dbo.GENTABLES_LONGDESC_FUNCTION(@v_tableid, @v_editioncode)

                    IF @v_editiondesc IS NOT NULL
                      BEGIN
                        SET @v_xml = (isnull(@v_xml, '') + '<b058><![CDATA[' + isnull(@v_editiondesc, '') + ']]></b058>')
                        SET @o_xml = @v_xml
                      END

                    EXEC dbo.GET_ONIXCODE_GENTABLES @v_tableid, @v_editioncode, @v_onixcode OUTPUT, @v_onixcodedefault OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                    IF (@v_retcode <= 0)
                      BEGIN

                        /*  error or not found */
                        SET @o_error_code = @v_retcode
                        SET @o_error_desc = @v_error_desc
                        RETURN 
                      END

                    IF @v_onixcode IS NOT NULL
                      BEGIN
                        SET @v_xml = (isnull(@v_xml, '') + '<b056><![CDATA[' + isnull(@v_onixcode, '') + ']]></b056>' + isnull(@v_record_separator, ''))
                        SET @o_xml = @v_xml
                      END
                    ELSE 
                      BEGIN

                        /*  return -99 */

                        SET @o_error_code = @return_onixcode_notfound
                        SET @o_error_desc = ('Onixcode not found for tableid ' + isnull(CAST( @v_tableid AS varchar(50)), '') + ' and datacode ' + isnull(CAST( @v_editioncode AS varchar(50)), ''))
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
            ELSE 
              BEGIN

                /*  return 0 */

                SET @o_error_code = @return_nodata_err_code
                SET @o_error_desc = ''
                RETURN 
              END

      END

go
grant execute on onix21_edition_type  to public
go


