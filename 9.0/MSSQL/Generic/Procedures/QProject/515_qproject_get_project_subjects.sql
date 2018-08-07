if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_subjects') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_project_subjects
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_project_subjects
 (@i_projectkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qproject_get_project_subjects
**  Desc: This stored procedure returns subject information
**        from the taqprojectsubjectcategory table. 
**
**    Auth: Kate
**    Date: 5/30/04
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:           Author:            Description:
**    --------        --------           -------------------------------------------
**    12/22/2014	  Uday A. Khisty     Enable filtering for categories
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT DISTINCT g.tabledesclong, s.*,
         dbo.qproject_is_sent_to_tmm(N'subjectcategory',g.tableid,0,COALESCE(p.usageclasscode,0)) sendtotmm, 
         o.orgentrykey, i.itemtypecode, i.itemtypesubcode  
    FROM taqproject p, taqprojectsubjectcategory s, gentablesdesc g
    LEFT OUTER JOIN gentablesorglevel o ON g.tableid = o.tableid,   
    gentablesitemtype i  
   WHERE s.categorytableid = g.tableid and
         s.taqprojectkey = p.taqprojectkey and
         s.taqprojectkey = @i_projectkey AND
         g.activeind = 1  
ORDER BY s.categorytableid,s.sortorder,s.categorycode,s.categorysubcode,s.categorysub2code

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: projectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qproject_get_project_subjects TO PUBLIC
GO


