if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_all_defaults') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_all_defaults
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_all_defaults
 (@o_error_code          integer output,
  @o_error_desc          varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qutl_get_all_defaults
**  Desc: This stored procedure returns all existing defaults from the  
**        defaults table to the calling program.  
**
**              
**
**    Auth: Alan Katzen
**    Date: 25 April 2005
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

  SELECT * FROM defaults
  WHERE defaultkey = 1

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'no data found: '
  END 

GO

GRANT EXEC ON qutl_get_all_defaults TO PUBLIC
GO


