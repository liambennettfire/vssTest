if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taskview') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_taskview
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_taskview
 (@i_taskviewcode   integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_taskview
**  Desc: This stored procedure returns taskview information for a key value.
**
**    Auth: Lisa Cormier
**    Date: 5/14/08
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT COALESCE(alldatetypesind,0) alldatetypesind, t.*, CASE WHEN u.lastname IS NULL OR u.lastname='' 
				THEN
					CASE WHEN u.firstname IS NULL OR u.firstname='' 
						 THEN u.userid
						 ELSE u.firstname
					END
				ELSE LTRIM(u.firstname + ' ' + u.lastname)
			END AS username,
  CASE WHEN COALESCE(t.itemtypecode, 0) > 0 THEN (SELECT datadesc FROM gentables WHERE tableid = 550 AND datacode = t.itemtypecode)			
  ELSE NULL 
  END as itemtypedesc,
    
  CASE WHEN COALESCE(t.itemtypecode, 0) > 0 AND COALESCE(t.usageclasscode, 0) > 0 THEN (SELECT datadesc FROM subgentables WHERE tableid = 550 AND datacode = t.itemtypecode AND datasubcode = t.usageclasscode)			
  ELSE NULL 
  END as usageclassdesc,
  
  CASE WHEN COALESCE(t.userkey, 0) > 0 THEN 
   (SELECT CASE WHEN u.lastname IS NULL OR u.lastname='' 
				THEN
					CASE WHEN u.firstname IS NULL OR u.firstname='' 
						 THEN u.userid
						 ELSE u.firstname
					END
				ELSE LTRIM(u.firstname + ' ' + u.lastname)
			END AS username
	FROM qsiusers u WHERE u.userkey = t.userkey)		   	
  ELSE NULL 
  END as username, 
			
  
  CASE WHEN COALESCE(t.orgentrykey, 0) > 0 THEN (SELECT orgentrydesc FROM orgentry WHERE orgentrykey = t.orgentrykey)			
  ELSE NULL 
  END as orgentrydesc 
			
  FROM taskview t
  LEFT JOIN qsiusers u on t.userkey = u.userkey
  WHERE t.taskviewkey = @i_taskviewcode
  ORDER BY t.taskviewkey  

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taskview table empty.'
  END 

GO

GRANT EXEC ON qproject_get_taskview TO PUBLIC
GO




