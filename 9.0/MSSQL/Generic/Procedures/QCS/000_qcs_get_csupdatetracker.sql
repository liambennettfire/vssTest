if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_get_csupdatetracker') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
  PRINT 'Dropping Procedure qcs_get_csupdatetracker'
  DROP PROCEDURE  qcs_get_csupdatetracker
END
GO

PRINT 'Creating Procedure qcs_get_csupdatetracker'
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcs_get_csupdatetracker
 --(@o_error_code     integer output,
 -- @o_error_desc     varchar(2000) output)
AS

  --SET @o_error_code = 0
  --SET @o_error_desc = ''
  --DECLARE @error_var    INT
  --DECLARE @rowcount_var INT

  SELECT * FROM csupdatetracker
    
  ---- Save the @@ERROR and @@ROWCOUNT values in local 
  ---- variables before they are cleared.
  --SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  --IF @error_var <> 0 or @rowcount_var = 0 
  -- BEGIN
  --  SET @o_error_code = -1
  --  SET @o_error_desc = 'Could not access csupdatetracker'  
  -- END 

GO
GRANT EXEC ON qcs_get_csupdatetracker TO PUBLIC
GO


