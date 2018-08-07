IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_series')
BEGIN
  DROP  Procedure  onix21_series
END
GO


  CREATE 
    PROCEDURE dbo.onix21_series 
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
            @v_seriescode integer,
            @v_seriesdesc varchar(255),
            @v_totalvolumes varchar(10),
            @v_volumenumber integer,
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
            SET @v_tableid = 327

            /*  Retrieve Data from coretitleinfo */

            SELECT @v_count = count( * )
              FROM dbo.BOOKDETAIL
              WHERE (dbo.BOOKDETAIL.BOOKKEY = @i_bookkey)

            IF (@v_count > 0)
              BEGIN

                SELECT @v_seriescode = dbo.BOOKDETAIL.SERIESCODE, @v_volumenumber = isnull(dbo.BOOKDETAIL.VOLUMENUMBER, 0)
                  FROM dbo.BOOKDETAIL
                  WHERE (dbo.BOOKDETAIL.BOOKKEY = @i_bookkey)

                IF (@v_seriescode > 0)
                  BEGIN

                    SELECT @v_count = count( * )
                      FROM dbo.GENTABLES
                      WHERE ((dbo.GENTABLES.TABLEID = @v_tableid) AND 
                              (dbo.GENTABLES.DATACODE = @v_seriescode))

                    IF (@v_count <= 0)
                      BEGIN

                        /*  not found */
                        SET @o_error_code = @return_nodata_err_code
                        SET @o_error_desc = ''
                        RETURN 

                      END

                    SELECT @v_seriesdesc = isnull(GENTABLES.ALTERNATEDESC1, GENTABLES.DATADESC), 
	           @v_totalvolumes = ltrim(rtrim(CAST( dbo.GENTABLES.NUMERICDESC1 AS varchar(8000))))
                      FROM dbo.GENTABLES
                      WHERE ((dbo.GENTABLES.TABLEID = @v_tableid) AND 
                              (dbo.GENTABLES.DATACODE = @v_seriescode))


                    IF (@v_totalvolumes = '0')
                      SET @v_totalvolumes = ''

                    IF @v_seriesdesc IS NOT NULL
                      BEGIN

                        SET @v_xml = '<series>'
                        SET @v_xml = (isnull(@v_xml, '') + '<b018><![CDATA[' + isnull(@v_seriesdesc, '') + ']]></b018>')
                        IF (@v_volumenumber > 0)
                          IF (SYSDB.SSMA.LENGTH_VARCHAR(@v_totalvolumes) > 0)
                            SET @v_xml = (isnull(@v_xml, '') + '<b019>No. ' + isnull(CAST( @v_volumenumber AS varchar(100)), '') + ' of ' + isnull(@v_totalvolumes, '') + '</b019>')
                          ELSE 
                            SET @v_xml = (isnull(@v_xml, '') + '<b019>No. ' + isnull(CAST( @v_volumenumber AS varchar(100)), '') + '</b019>')

                        SET @v_xml = (isnull(@v_xml, '') + '</series>' + isnull(@v_record_separator, ''))

                        SET @o_xml = @v_xml

                      END
                    ELSE 
                      BEGIN

                        /*  return 0 */

                        SET @o_error_code = @return_nodata_err_code

                        SET @o_error_desc = ('series not found for tableid ' + isnull(CAST( @v_tableid AS varchar(100)), '') + ' and datacode ' + isnull(CAST( @v_seriescode AS varchar(100)), ''))

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
grant execute on onix21_series  to public
go

