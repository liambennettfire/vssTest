if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_subjectcats_by_tableid') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_subjectcats_by_tableid
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_subjectcats_by_tableid
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @i_tableid        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_subjectcats_by_tableid
**  Desc: This stored procedure returns subject information
**        from the booksubjectcategory table for a tableid.
**        It also returns bisac category info from bookbisaccategory and
**        book category info from bookcategory.
**        The data must be made to look the same (column names) so 
**        one control can display results from both tables.
**
**    Auth: Alan Katzen
**    Date: 29 March 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:         Author:            Description:
**    ----------    --------           -------------------------------------------
**    07/25/2017	  Colman             43941 Return subjectkey for booksubjectcategory
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_tableid = 339 BEGIN
    -- bisac subject category
    SELECT 339 categorytableid,
           c.bisaccategorycode categorycode,
           c.bisaccategorysubcode categorysubcode,
           null categorysub2code,
           null subjectkey,
           c.sortorder
    FROM bookbisaccategory c
    WHERE bookkey = @i_bookkey and
          printingkey = @i_printingkey
    ORDER BY c.sortorder
  END
  ELSE IF @i_tableid = 317 BEGIN
    -- book category
    SELECT 317 categorytableid,
           categorycode,
           null categorysubcode,
           null categorysub2code,
           null subjectkey,
           sortorder
    FROM bookcategory
    WHERE bookkey = @i_bookkey
    ORDER BY sortorder    
  END
  ELSE BEGIN
    -- book subject categories
  SELECT categorytableid,
         categorycode,
         categorysubcode,
         categorysub2code,
         subjectkey,
         sortorder
    FROM booksubjectcategory s
    WHERE s.categorytableid = @i_tableid and
          s.bookkey = @i_bookkey 
    ORDER BY s.sortorder
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' / tableid = ' + cast(@i_tableid AS VARCHAR)
  END 

GO
GRANT EXEC ON qtitle_get_subjectcats_by_tableid TO PUBLIC
GO


