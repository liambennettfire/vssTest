IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_edition_number')
BEGIN
  DROP  Procedure  onix21_edition_number
END
GO

  CREATE 
    PROCEDURE dbo.onix21_edition_number 
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
            @v_editionnumber numeric(9, 4),
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

                    SELECT @v_count = count( * )
                      FROM dbo.GENTABLES
                      WHERE ((dbo.GENTABLES.TABLEID = @v_tableid) AND 
                              (dbo.GENTABLES.DATACODE = @v_editioncode))
                    IF (@v_count <= 0)
                      BEGIN

                        /*  not found */

                        SET @o_error_code = @return_nodata_err_code
                        SET @o_error_desc = ''
                        RETURN 

                      END

                    SELECT @v_editionnumber = dbo.GENTABLES.NUMERICDESC1
                      FROM dbo.GENTABLES
                      WHERE ((dbo.GENTABLES.TABLEID = @v_tableid) AND 
                              (dbo.GENTABLES.DATACODE = @v_editioncode))


                    IF (@v_editionnumber > 0.0)
                      BEGIN
                        SET @v_xml = ('<b057><![CDATA[' + isnull(CAST( @v_editionnumber AS varchar(50)), '') + ']]></b057>' + isnull(@v_record_separator, ''))
                        SET @o_xml = @v_xml
                      END
                    ELSE 
                      BEGIN

                        /*  return 0 */
                        SET @o_error_code = @return_nodata_err_code
                        SET @o_error_desc = ('edition number not found for tableid ' + isnull(CAST( @v_tableid AS varchar(50)), '') + ' and datacode ' + isnull(CAST( @v_editioncode AS varchar(50)), ''))
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
grant execute on onix21_edition_number  to public
go

