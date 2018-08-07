if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_specific_project_task') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_specific_project_task
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_specific_project_task
 (@i_taskkey        integer,
  @i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qproject_get_specific_project_task
**  Desc: This stored procedure returns task information
**        from the taqprojecttask table for a specific task. 
**
**    Auth: Alan Katzen
**    Date: 9/15/04
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT COALESCE(d.datelabel,d.description) description,t.*,e.taqelementtypecode,e.taqelementtypesubcode,
         e.taqelementdesc, COALESCE(d.usedexclusivelybycsind,0) usedexclusivelybycsind,
         CASE 
          WHEN t.bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(@i_userkey,'tasktracking',323,t.datetypecode,t.bookkey,t.printingkey,0)
          ELSE 2
         END accesscode,
         CASE 
          WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel))='' THEN d.description
          ELSE d.datelabel
         END datelabel,
         cp.projecttitle projectname,ct.title, d.triggerdateind            
  FROM taqprojecttask t LEFT OUTER JOIN taqprojectelement e ON t.taqelementkey = e.taqelementkey
					    INNER JOIN datetype d ON t.datetypecode = d.datetypecode
					    LEFT OUTER JOIN coreprojectinfo cp ON t.taqprojectkey = cp.projectkey
					    LEFT OUTER JOIN coretitleinfo ct ON t.bookkey = ct.bookkey AND t.printingkey = ct.printingkey
						LEFT OUTER JOIN printing p ON t.bookkey = p.bookkey AND t.printingkey = p.printingkey											
  WHERE t.datetypecode = d.datetypecode AND 
	t.taqtaskkey = @i_taskkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taskkey = ' + cast(@i_taskkey AS VARCHAR)
  END 

GO
GRANT EXEC ON qproject_get_specific_project_task TO PUBLIC
GO


