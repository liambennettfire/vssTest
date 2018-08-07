if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_task_contactlist') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_task_contactlist
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_task_contactlist
 (@i_projectkeylist       varchar(max),
  @i_contactkeylist       varchar(max),
  @i_bookkeylist          varchar(max),
  @i_rolecode             integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS
/******************************************************************************
**  File: qproject_get_task_contactlist
**  Name: qproject_get_task_contactlist
**  Desc: This procedure calls a function to get contacts associated with a list 
**        of projects/journals and titles.  A list of contacts may be passed in to 
**        append to the list.  Also, a role may be passed in to filter the contacts.
**
**    Auth: Alan Katzen
**    Date: 21 April 2008
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @error_var = 0
  SET @rowcount_var = 0
  
  SELECT *, contactkey as globalcontactkey FROM dbo.qproject_build_task_contactlist(@i_projectkeylist,@i_contactkeylist,@i_bookkeylist,@i_rolecode)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error building task contactlist'
    RETURN  
  END 
  
ExitHandler:

GO
GRANT EXEC ON qproject_get_task_contactlist TO PUBLIC
GO


