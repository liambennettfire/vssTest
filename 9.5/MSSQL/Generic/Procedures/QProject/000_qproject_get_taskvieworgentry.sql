IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_get_taskvieworgentry]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_get_taskvieworgentry]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_get_taskvieworgentry]
 (@i_taskviewkey  integer,
  @i_orglevelkey  integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/************************************************************************************
**  Name: qproject_get_taskvieworgentry
**  Desc: If no orglevelkey passed, this stored procedure returns all organizational 
**        levels for a project, regardless if they are filled in or not.
**
**    Auth: lisa ( cloned from qproject_get_taqprojectorgentry )
**    Date: 19 May 2008
*************************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @orgLevel		INT
  DECLARE @orgKey		INT
  DECLARE @parentKey	INT
  DECLARE @parentLevel  INT
  DECLARE @parentOrgKeys varchar(1000)
  DECLARE @thisKey		 varchar(25)

  select @parentOrgKeys = ''

  select @orgKey = tv.orgentrykey, @orgLevel = o2.orglevelnumber
  from TaskView tv
  join orgentry o1 on tv.orgentrykey = o1.orgentrykey
  join orglevel o2 on o1.orglevelkey = o2.orglevelkey
  where tv.taskviewkey = @i_taskviewkey

  /*
   * The following loop attempts to walk through the parent organizations and get the keys.
   * It then builds a string "Level:GrandParentKey,Level:ParentKey".. etc. so that the lowest
   * level would be returned first in the string.  1:1,2:3,3:8... etc.
   */
  WHILE @orgKey > 0
  BEGIN
	select @parentKey = ( select orgentryparentkey from Orgentry where orgentrykey = @orgkey )

    if @parentKey != 0
    BEGIN
		select @parentLevel = o2.orglevelnumber
	    from orgentry o1 join orglevel o2 on o1.orglevelkey = o2.orglevelkey
		where o1.orgentrykey = @parentKey

		select @thisKey = convert(varchar(12), @parentLevel) + ':' + convert(varchar(12), @parentKey)
		if ( @parentOrgKeys = '' )
		   select @parentOrgKeys = @thisKey
		else
		   select @parentOrgKeys = @thisKey + ',' + @parentOrgKeys
	END	
	select @orgKey = @ParentKey
  END

  IF @i_orglevelkey > 0
    SELECT e.orgentrydesc, o.*, tv.*, @parentOrgKeys as OrgParentString
    FROM orglevel o 
      LEFT OUTER JOIN taskview tv ON o.orglevelkey = tv.orglevelkey AND tv.taskviewkey = @i_taskviewkey
      LEFT OUTER JOIN orgentry e ON tv.orgentrykey = e.orgentrykey
    WHERE o.orglevelkey = @i_orglevelkey
  ELSE
    SELECT e.orgentrydesc, o.*, tv.*, @parentOrgKeys as OrgParentString
    FROM orglevel o 
      LEFT OUTER JOIN taskview tv ON o.orglevelkey = tv.orglevelkey AND tv.taskviewkey = @i_taskviewkey
      LEFT OUTER JOIN orgentry e ON tv.orgentrykey = e.orgentrykey
    ORDER BY o.orglevelkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taskviewkey = ' + cast(@i_taskviewkey AS VARCHAR)   
  END 
GO

GRANT EXEC ON qproject_get_taskvieworgentry TO PUBLIC
GO



