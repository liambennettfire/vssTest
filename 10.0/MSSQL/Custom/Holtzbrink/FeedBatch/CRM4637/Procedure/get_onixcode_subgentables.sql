IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'get_onixcode_subgentables')
BEGIN
  DROP  Procedure  get_onixcode_subgentables
END
GO

  CREATE 
    PROCEDURE dbo.get_onixcode_subgentables 
        @i_tableid integer,
        @i_datacode integer,
        @i_datasubcode integer,
        @o_onixsubcode varchar(255) OUTPUT ,
        @o_onixsubcodedefault integer OUTPUT ,
        @o_otheronixcode varchar(255) OUTPUT ,
        @o_otheronixcodedesc varchar(255) OUTPUT ,
        @o_error_code integer OUTPUT ,
        @o_error_desc varchar(255) OUTPUT 
    AS
      BEGIN
          DECLARE 
            @v_count integer,
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer          

          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1


            SET @o_error_code = @return_no_err_code
            SET @o_error_desc = ''
            SET @o_onixsubcode = ''
            SET @o_onixsubcodedefault = 0
            SET @o_otheronixcode = ''
            SET @o_otheronixcodedesc = ''

            /*  Retrieve Data */

            SELECT @v_count = count( * )
              FROM dbo.SUBGENTABLES_EXT_VIEW
              WHERE ((dbo.SUBGENTABLES_EXT_VIEW.TABLEID = @i_tableid) AND 
                      (dbo.SUBGENTABLES_EXT_VIEW.DATACODE = @i_datacode) AND 
                      (dbo.SUBGENTABLES_EXT_VIEW.DATASUBCODE = @i_datasubcode))


            IF (@v_count > 0)
              BEGIN
                SELECT 
                    @o_onixsubcode = rtrim(ltrim(isnull(dbo.SUBGENTABLES_EXT_VIEW.ONIXSUBCODE, ''))), 
                    @o_onixsubcodedefault = isnull(dbo.SUBGENTABLES_EXT_VIEW.ONIXSUBCODEDEFAULT, 0), 
                    @o_otheronixcode = rtrim(ltrim(isnull(dbo.SUBGENTABLES_EXT_VIEW.OTHERONIXCODE, ''))), 
                    @o_otheronixcodedesc = rtrim(ltrim(isnull(dbo.SUBGENTABLES_EXT_VIEW.OTHERONIXCODEDESC, '')))
                  FROM dbo.SUBGENTABLES_EXT_VIEW
                  WHERE ((dbo.SUBGENTABLES_EXT_VIEW.TABLEID = @i_tableid) AND 
                          (dbo.SUBGENTABLES_EXT_VIEW.DATACODE = @i_datacode) AND 
                          (dbo.SUBGENTABLES_EXT_VIEW.DATASUBCODE = @i_datasubcode))

              END
            ELSE 
              BEGIN

                SET @o_error_code = @return_nodata_err_code
                SET @o_error_desc = ''
                RETURN 
              END

      END

go
grant execute on get_onixcode_subgentables  to public
go

