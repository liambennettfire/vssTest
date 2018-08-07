if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_cssblacklist') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_cssblacklist
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_cssblacklist
 (@o_error_code          integer output,
  @o_error_desc          varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qutl_get_cssblacklist
**  Desc: This stored procedure returns the cross site scripting blacklist. 
**
**    Auth: Alan Katzen
**    Date: 12 December 2013
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT * FROM cssblacklist

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing cssblacklist table'
  END 
GO

GRANT EXEC ON qutl_get_cssblacklist TO PUBLIC
GO


