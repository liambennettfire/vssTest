if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_usageclasses_for_user') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_usageclasses_for_user
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_usageclasses_for_user
 (@i_userkey        integer,
  @i_itemtypecode   integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qutl_get_usageclasses_for_user
**  Desc: This stored procedure returns all usage classes for a user.
**
**    Auth: Alan Katzen
**    Date: 1 September 2006
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------       -------------------------------------------
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @itemtypecode_var INT


  SELECT usageclasscode,primaryind,
         dbo.get_subgentables_desc(550,itemtypecode,usageclasscode,'long') usageclassdesclong,
         dbo.get_subgentables_desc(550,itemtypecode,usageclasscode,'short') usageclassdescshort
    FROM qsiusersusageclass 
   WHERE userkey = @i_userkey AND
         itemtypecode = @i_itemtypecode AND
         usageclasscode > 0

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Database Error: Unable to access qsiusersusageclass (userkey = ' + cast(@i_userkey as varchar) + ').'   
  END 
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'No Data Found on qsiusersusageclass for userkey = ' + cast(@i_userkey as varchar) + '.'   
  END 

GO
GRANT EXEC ON qutl_get_usageclasses_for_user TO PUBLIC
GO


