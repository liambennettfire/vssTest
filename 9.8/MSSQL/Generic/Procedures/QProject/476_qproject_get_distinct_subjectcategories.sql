if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_distinct_subjectcategories') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_distinct_subjectcategories
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_distinct_subjectcategories
 (@i_projectkey     integer,
  @i_itemtypecode   integer,
  @i_usageclasscode integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_distinct_subjectcategories
**  Desc: This stored procedure returns a list of distinct subjects
**        from gentables. 
**
**  Auth: Alan Katzen
**  Date: 1 June 2004
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:     Description:
**  -------   ---------   ----------------------------------------------------
**  6/2/11    Kate        Took out the UNION - already getting categories based on project's itemtype/usageclass.
**  12/13/06  Kate        Distinct rows not being returned (case 4482 fixes).
*******************************************************************************/

  DECLARE 
    @error_var    INT,
    @rowcount_var INT,
    @itemtypecode_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Get categories based on the project's item type and usage class
  SELECT DISTINCT g.tableid, g.tabledesclong, o.orgentrykey,
      dbo.qproject_get_subjectcategory_count(@i_projectkey, g.tableid) categoriesexist,
      dbo.qproject_is_sent_to_tmm(N'subjectcategory', g.tableid, 0, i.itemtypesubcode) sendtotmm  
  FROM gentablesdesc g LEFT OUTER JOIN gentablesorglevel o ON g.tableid = o.tableid,
      gentablesitemtype i
  WHERE  g.tableid = i.tableid AND
      g.activeind = 1 AND
      g.subjectcategoryind = 1 AND
      i.itemtypecode = @i_itemtypecode AND
      (i.itemtypesubcode = COALESCE(@i_usageclasscode,0) OR i.itemtypesubcode = 0)

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: subjectcategories on gentablesdesc.'   
  END 

GO

GRANT EXEC ON qproject_get_distinct_subjectcategories TO PUBLIC
GO

