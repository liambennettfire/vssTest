if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_subjectcategories') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_subjectcategories
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_subjectcategories
 (@i_bookkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_subjectcategories
**  Desc: This stored procedure returns subject information
**        from the booksubjectcategory table. 
**
**              
**
**    Auth: Alan Katzen
**    Date: 29 March 2004
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

  SELECT DISTINCT g.tabledesclong, s.*, o.orgentrykey, i.itemtypecode, i.itemtypesubcode   
    FROM booksubjectcategory s, gentablesdesc g
    LEFT OUTER JOIN gentablesorglevel o ON g.tableid = o.tableid,   
    gentablesitemtype i     
   WHERE s.categorytableid = g.tableid and
         s.bookkey = @i_bookkey  AND
    g.activeind = 1   
ORDER BY s.categorytableid,s.sortorder,s.categorycode,s.categorysubcode,s.categorysub2code

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qtitle_get_subjectcategories TO PUBLIC
GO


