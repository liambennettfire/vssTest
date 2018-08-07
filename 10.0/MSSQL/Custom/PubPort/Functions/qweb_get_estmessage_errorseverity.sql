SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_estmessage_errorseverity]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_estmessage_errorseverity]
GO


CREATE FUNCTION qweb_get_estmessage_errorseverity
    ( @i_estkey as integer,@i_versionkey as integer) 

RETURNS smallint

/******************************************************************************
**  File: 
**  Name: qweb_get_estmessage_errorseverity
**  Desc: This function returns the most severe message error code 
**        (based on tableid 539) for an individual estimate version. 
**
**        Message Severity Order:
**          Error (datacode = 2)
**          Warning (datacode = 3)
**          Information/Notes (datacode = 4)
**
**    Auth: Alan Katzen
**    Date: 10 August 2005
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_count      INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_count = 0

  IF @i_estkey is null OR @i_estkey <= 0 OR
     @i_versionkey is null OR @i_versionkey <= 0 BEGIN
     RETURN -1
  END

  -- look for errors
  SELECT @i_count = count(*) 
    FROM estmessage
   WHERE estkey = @i_estkey and 
         version = @i_versionkey and
         severity = 1

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    RETURN -1
  END 

  IF @i_count > 0 BEGIN
    -- error message found
    RETURN 2
  END

  -- look for warnings
  SELECT @i_count = count(*) 
    FROM estmessage
   WHERE estkey = @i_estkey and 
         version = @i_versionkey and
         severity = 2

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    RETURN -1
  END 

  IF @i_count > 0 BEGIN
    -- warning message found
    RETURN 3
  END

  -- look for information/notes
  SELECT @i_count = count(*) 
    FROM estmessage
   WHERE estkey = @i_estkey and 
         version = @i_versionkey and
         severity in (3,4)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    RETURN -1
  END 

  IF @i_count > 0 BEGIN
    -- information/notes message found
    RETURN 4
  END
 
  -- no errors,warnings,info,notes messages found
  RETURN 0
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

