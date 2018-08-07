if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_conversion_to_title_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_conversion_to_title_info
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_conversion_to_title_info
 (@i_workkey  integer,
  @i_bookkey  integer = 0,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS


/******************************************************************************
**  Name: qtitle_get_conversion_to_title_info
**  Desc: This stored procedure gets a list of titles to convert 
**        to (used in CS Conversion page).
**
**  Auth: Alan Katzen
**  Date: 8 October 2010
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @error_var = 0
  SET @rowcount_var = 0
  
  if @i_bookkey > 0 begin
    -- get info for a specific bookkey
    SELECT c.bookkey, c.title, c.ean, c.productnumber, c.mediatypecode, 
           COALESCE(c.mediatypesubcode,0) mediatypesubcode,
           dbo.get_gentables_desc(312,c.mediatypecode,'long') mediadesc,
           c.formatname formatdesc,
           COALESCE(ltrim(rtrim(c.productnumber)),'(none)') + ' / '+ 
           COALESCE(ltrim(rtrim(c.formatname)),'(none)') detailline,
           CASE
             WHEN (SELECT COUNT(*) FROM bookauthor WHERE bookkey = c.bookkey AND primaryind=1) = 1 THEN (SELECT authorkey FROM bookauthor WHERE bookkey = c.bookkey AND primaryind=1)
             ELSE 0
           END authorkey         
      FROM coretitleinfo c 
     WHERE c.workkey = @i_workkey  
       AND c.bookkey = @i_bookkey
  ORDER BY c.productnumber ASC  
  end
  else begin
    SELECT c.bookkey, c.title, c.ean, c.productnumber, c.mediatypecode, 
           COALESCE(c.mediatypesubcode,0) mediatypesubcode,
           dbo.get_gentables_desc(312,c.mediatypecode,'long') mediadesc,
           c.formatname formatdesc,
           COALESCE(ltrim(rtrim(c.productnumber)),'(none)') + ' / '+ 
           COALESCE(ltrim(rtrim(c.formatname)),'(none)') detailline,
           CASE
             WHEN (SELECT COUNT(*) FROM bookauthor WHERE bookkey = c.bookkey AND primaryind=1) = 1 THEN (SELECT authorkey FROM bookauthor WHERE bookkey = c.bookkey AND primaryind=1)
             ELSE 0
           END authorkey         
      FROM coretitleinfo c 
     WHERE c.workkey = @i_workkey   
  ORDER BY c.productnumber ASC  
  end   
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error getting related title list: workkey = ' + cast(@i_workkey AS VARCHAR)
  END 

GO

GRANT EXEC ON qtitle_get_conversion_to_title_info TO PUBLIC
GO


