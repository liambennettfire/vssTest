if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_distinct_categories') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_get_distinct_categories
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_get_distinct_categories
 (@i_globalcontactkey   integer,
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_get_distinct_categories
**  Desc: This stored procedure returns a list of distinct subjects
**        from gentables. 
**
**  Auth: Alan Katzen
**  Date: 14 August 2006
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:     Description:
**  -------   ---------   ----------------------------------------------------
**  12/13/06  Kate        Distinct rows not being returned (case 4482 fixes).
*******************************************************************************/

  DECLARE 
    @error_var    INT,
    @rowcount_var INT,
    @itemtypecode_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @itemtypecode_var = 2  --Contacts

  SELECT DISTINCT gentablesdesc.tableid, gentablesdesc.tabledesclong, gentablesorglevel.orgentrykey,
      dbo.qcontact_get_subjectcategory_count(@i_globalcontactkey,gentablesdesc.tableid) categoriesexist
   FROM gentablesdesc  LEFT OUTER JOIN gentablesorglevel on gentablesdesc.tableid = gentablesorglevel.tableid,
  gentablesitemtype
   where   gentablesdesc.tableid = gentablesitemtype.tableid and
      gentablesdesc.subjectcategoryind = 1 and
      gentablesdesc.activeind = 1 and
      gentablesitemtype.itemtypecode = @itemtypecode_var and
      gentablesitemtype.itemtypesubcode = 0
  ORDER BY gentablesdesc.tabledesclong, gentablesdesc.tableid

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: subjectcategories on gentablesdesc.'   
  END 

GO

GRANT EXEC ON qcontact_get_distinct_categories TO PUBLIC
GO

