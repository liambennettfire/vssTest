IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'get_onixcode_gentables')
BEGIN
  DROP  Procedure  get_onixcode_gentables
END
GO


  CREATE 
    PROCEDURE dbo.get_onixcode_gentables 
        @i_tableid integer,
        @i_datacode integer,
        @o_onixcode varchar(255) OUTPUT ,
        @o_onixcodedefault integer OUTPUT ,
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
            SET @o_onixcode = ''
            SET @o_onixcodedefault = 0
          /*  Retrieve Data */


            SELECT @v_count = count(*)
              FROM dbo.GENTABLES_EXT_VIEW
              WHERE dbo.GENTABLES_EXT_VIEW.TABLEID = @i_tableid AND 
                    dbo.GENTABLES_EXT_VIEW.DATACODE = @i_datacode


            IF (@v_count > 0)
              BEGIN
                SELECT @o_onixcode = rtrim(ltrim(isnull(dbo.GENTABLES_EXT_VIEW.ONIXCODE, ''))), 
	              @o_onixcodedefault = isnull(dbo.GENTABLES_EXT_VIEW.ONIXCODEDEFAULT, 0)
                  FROM dbo.GENTABLES_EXT_VIEW
                  WHERE ((dbo.GENTABLES_EXT_VIEW.TABLEID = @i_tableid) AND 
                          (dbo.GENTABLES_EXT_VIEW.DATACODE = @i_datacode))
           END

  
      END

go
grant execute on get_onixcode_gentables  to public
go

