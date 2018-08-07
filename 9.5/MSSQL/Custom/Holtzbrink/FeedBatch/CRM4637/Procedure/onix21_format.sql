IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_format')
BEGIN
  DROP  Procedure  onix21_format
END
GO

  CREATE 
    PROCEDURE dbo.onix21_format 
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
            @v_mediatypecode integer,
            @v_mediatypesubcode integer,
            @v_tableid integer,
            @v_onixsubcode varchar(30),
            @v_onixsubcodedefault integer,
            @v_otheronixcode varchar(10),
            @v_otheronixcodedesc varchar(100),
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
            SET @v_tableid = 312

            /*  Retrieve Data from coretitleinfo */

            SELECT @v_count = count( * )
              FROM dbo.BOOKDETAIL
              WHERE (dbo.BOOKDETAIL.BOOKKEY = @i_bookkey)

            IF (@v_count > 0)
              BEGIN

                SELECT @v_mediatypecode = dbo.BOOKDETAIL.MEDIATYPECODE, @v_mediatypesubcode = dbo.BOOKDETAIL.MEDIATYPESUBCODE
                  FROM dbo.BOOKDETAIL
                  WHERE (dbo.BOOKDETAIL.BOOKKEY = @i_bookkey)

                IF (@v_mediatypesubcode > 0)
                  BEGIN

                    EXEC dbo.GET_ONIXCODE_SUBGENTABLES @v_tableid, @v_mediatypecode, @v_mediatypesubcode, @v_onixsubcode OUTPUT, @v_onixsubcodedefault OUTPUT, @v_otheronixcode OUTPUT, @v_otheronixcodedesc OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                    IF (@v_retcode <= 0)
                      BEGIN

                        /*  error or not found */
                        SET @o_error_code = @v_retcode
                        SET @o_error_desc = @v_error_desc
                        RETURN 
                      END

                    IF @v_onixsubcode IS NOT NULL
                      BEGIN
                        SET @v_xml = ('<b012>' + isnull(@v_onixsubcode, '') + '</b012>')
                        IF @v_otheronixcode  IS NOT NULL
                          BEGIN
                            /*  b333 productformdetail */
                            SET @v_xml = (isnull(@v_xml, '') + '<b333>' + isnull(@v_otheronixcode, '') + '</b333>')
                          END

                        IF @v_otheronixcodedesc  IS NOT NULL
                          BEGIN
                            /*  b014 ProductFormDescription */
                            SET @v_xml = (isnull(@v_xml, '') + '<b014><![CDATA[' + isnull(@v_otheronixcodedesc, '') + ']]></b014>')
                          END

                        SET @o_xml = (isnull(@v_xml, '') + isnull(@v_record_separator, ''))

                      END
                    ELSE 
                      BEGIN

                        /*  return -99 */

                        SET @o_error_code = @return_onixcode_notfound
                        SET @o_error_desc = ('Onixsubcode not found for tableid ' + isnull(CAST( @v_tableid AS varchar(50)), '') + ' and datacode ' + isnull(CAST( @v_mediatypecode AS varchar(50)), '') + ' and datasubcode ' + isnull(CAST( @v_mediatypesubcode AS varchar(50)), ''))

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
grant execute on onix21_format  to public
go

