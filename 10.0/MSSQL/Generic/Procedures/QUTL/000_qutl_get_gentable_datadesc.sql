if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_gentable_datadesc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_gentable_datadesc
GO

CREATE PROCEDURE qutl_get_gentable_datadesc (  
  @i_tableid integer,
  @i_desccol varchar(20),
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************************
**  Name: qutl_get_gentable_datadesc
**  Desc: This stored procedure returns datacode and description for given tableid.
**
**  Auth: Kate
**  Date: October 31 2007
*******************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_desccol = 'alternatedesc1'
    SELECT datacode, COALESCE(alternatedesc1, datadesc) description, qsicode
    FROM gentables
    WHERE tableid = @i_tableid
    ORDER BY sortorder, description
  ELSE
    SELECT datacode, datadesc description, qsicode
    FROM gentables
    WHERE tableid = @i_tableid
    ORDER BY sortorder, description


  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: tableid=' + cast(@i_tableid AS VARCHAR)
  END 

END
GO

GRANT EXEC ON qutl_get_gentable_datadesc TO PUBLIC
GO
