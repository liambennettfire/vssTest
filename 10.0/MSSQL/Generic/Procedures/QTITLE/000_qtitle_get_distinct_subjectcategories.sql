if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_distinct_subjectcategories') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_distinct_subjectcategories
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_distinct_subjectcategories
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_distinct_subjectcategories
**  Desc: This stored procedure returns a list of distinct subjects
**        from gentables. 
**
**  Auth: Alan Katzen
**  Date: 5 April 2004
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:     Description:
**  -------   ---------   ----------------------------------------------------
**  6/2/11    Kate        Get categories based on the title's item type/usage class.
**  12/13/06  Kate        Distinct rows not being returned (case 4482 fixes).
**  8/14/06   A. Katzen   Use gentablesitemtype instead of hardcoding tableids.
** 10/17/17   D. Kurth    Use a temp table for better performance.
*******************************************************************************/
  DECLARE 
    @error_var    INT,
    @rowcount_var INT,
    @v_itemtype INT,
    @v_usageclass INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Set up a temp table to hold whether each category exists:
  SELECT * INTO #catexists FROM (
	SELECT 317 AS tableid, (CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END) categoriesexist FROM bookcategory WHERE bookkey = @i_bookkey
	UNION
  	SELECT 339 AS tableid, (CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END) categoriesexist FROM bookbisaccategory WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
	UNION
  	SELECT DISTINCT
		categorytableid AS tableid, 
		(CASE WHEN (COUNT(CASE WHEN bookkey = @i_bookkey THEN 1 ELSE null END)) > 0 THEN 1 ELSE 0 END) AS categoriesexist
	FROM booksubjectcategory 
	GROUP BY categorytableid
  ) as tmp
  
  -- Get Item Type and Usage Class for the passed title
  SELECT @v_itemtype = itemtypecode, @v_usageclass = usageclasscode 
  FROM coretitleinfo
  WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey

  -- Get categories based on the titles's item type and usage class
  SELECT DISTINCT g.tableid, g.tabledesclong, o.orgentrykey, #catexists.categoriesexist 
  FROM gentablesdesc g
    LEFT OUTER JOIN gentablesorglevel o ON g.tableid = o.tableid
 	  JOIN #catexists on g.tableid = #catexists.tableid,
    gentablesitemtype i
  WHERE g.tableid = i.tableid AND 
    g.subjectcategoryind = 1 AND
    g.activeind = 1 AND
    i.itemtypecode = @v_itemtype AND
    (i.itemtypesubcode = 0 OR i.itemtypesubcode = @v_usageclass)
  ORDER BY g.tableid, o.orgentrykey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: subjectcategories on gentablesdesc.'   
  END 

GO


GRANT EXEC ON qtitle_get_distinct_subjectcategories TO PUBLIC
GO
