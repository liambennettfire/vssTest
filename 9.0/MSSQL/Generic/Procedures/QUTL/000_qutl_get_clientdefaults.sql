if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_clientdefaults') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_clientdefaults
GO

CREATE PROCEDURE qutl_get_clientdefaults
  (@i_clientdefaultids  varchar(2000),
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_clientdefaults
**  Desc: This stored procedure returns clientdefaults records for given
**        list of clientdefaultids.
**
**  Auth: Kate J. Wiewiora
**  Date: September 25 2007
*******************************************************************************/

  DECLARE
    @v_error  INT,
  	@v_sql    NVARCHAR(2000)

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SET @v_sql = 'SELECT * FROM clientdefaults WHERE clientdefaultid IN (' + @i_clientdefaultids + ')' 

  EXECUTE sp_executesql @v_sql

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing clientdefaults table.'
  END
GO

GRANT EXEC ON qutl_get_clientdefaults TO PUBLIC
GO
