if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_get_transactiontype_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcs_get_transactiontype_info
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qcs_get_transactiontype_info
 (@i_qsicode        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT *
  FROM gentables 
  WHERE tableid = 575
    AND qsicode = @i_qsicode
    
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'no data found on gentables: tableid 575 / qsicode = ' + cast(@i_qsicode AS VARCHAR)   
  END 

GO
GRANT EXEC ON qcs_get_transactiontype_info TO PUBLIC
GO


