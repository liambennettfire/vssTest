if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_subjectcategories') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_subjectcategories
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_subjectcategories
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_subjectcategories
**  Desc: This stored procedure returns subject information
**        from the bookcategory, bookbisaccategory and booksubjectcategory tables.
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
**    07/25/2017	  Colman             43941 Return union of all book category tables
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  -- bisac subject category
  SELECT g.tabledesclong,
          339 categorytableid,
          c.bisaccategorycode categorycode,
          c.bisaccategorysubcode categorysubcode,
          null categorysub2code,
          null subjectkey,
          c.sortorder
  FROM bookbisaccategory c, gentablesdesc g
  WHERE bookkey = @i_bookkey 
    AND printingkey = @i_printingkey
    AND g.tableid = 339
    AND g.activeind = 1
  UNION
  -- book category
  SELECT g.tabledesclong,
          317 categorytableid,
          categorycode,
          null categorysubcode,
          null categorysub2code,
          null subjectkey,
          sortorder
  FROM bookcategory, gentablesdesc g
  WHERE bookkey = @i_bookkey
    AND g.tableid = 317
    AND g.activeind = 1
  UNION
  -- book subject categories
  SELECT g.tabledesclong,
          categorytableid,
          categorycode,
          categorysubcode,
          categorysub2code,
          subjectkey,
          sortorder
  FROM booksubjectcategory s, gentablesdesc g
  WHERE s.bookkey = @i_bookkey 
    AND s.categorytableid = g.tableid
    AND g.activeind = 1
  ORDER BY categorytableid, sortorder

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
