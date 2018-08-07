if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_propagate_title_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_propagate_title_list
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_propagate_title_list
 (@i_workkey  integer,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS


/******************************************************************************
**  Name: qtitle_get_propagate_title_list
**  Desc: This stored procedure gets a list of titles to propagate 
**        from (used in advanced new title creation).
**
**  Auth: Alan Katzen
**  Date: 23 July 2009
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @error_var = 0
  SET @rowcount_var = 0
  
  SELECT book.title,   
         gentables.datadesc,   
         subgentables.datadesc,   
         bookdetail.mediatypecode,   
         bookdetail.mediatypesubcode,   
         book.propagatefrombookkey,   
         book.bookkey,   
         book.lastuserid,   
         book.lastmaintdate,   
         book.linklevelcode,   
         productnumber.productnumber,
         ltrim(rtrim(title)) + ' / ' + 
         COALESCE(ltrim(rtrim(productnumber.productnumber)),'(none)') + ' / '+ 
         COALESCE(ltrim(rtrim(gentables.datadesc)),'(none)') + ' / ' + 
         COALESCE(ltrim(rtrim(subgentables.datadesc)),'(none)') detailline
    FROM book,   
         bookdetail,   
         subgentables,   
         gentables,   
         productnumber  
   WHERE ( bookdetail.bookkey = book.bookkey ) and  
         ( bookdetail.mediatypesubcode = subgentables.datasubcode ) and  
         ( bookdetail.mediatypecode = subgentables.datacode ) and  
         ( gentables.tableid = subgentables.tableid ) and  
         ( bookdetail.mediatypecode = gentables.datacode ) and  
         ( book.bookkey = productnumber.bookkey ) and  
         ( ( book.workkey = @i_workkey ) AND  
         ( book.linklevelcode <> 30 ) AND  
         (  gentables.tableid = 312 ) AND  
         ( book.propagatefrombookkey is null ) )   
ORDER BY book.linklevelcode ASC     
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error getting propagate title list: workkey = ' + cast(@i_workkey AS VARCHAR)
  END 

GO

GRANT EXEC ON qtitle_get_propagate_title_list TO PUBLIC
GO


