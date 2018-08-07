if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_specific_associatedtitles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_specific_associatedtitles
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_specific_associatedtitles
 (@i_bookkey                integer,
  @i_associationtypecode    integer,
  @i_associationtypesubcode integer,
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_specific_associatedtitles
**  Desc: This stored procedure returns associated information
**        from the associatedtitles table. Used in ISBNDetailsEdit.
**
**  Auth: Alan Katzen
**  Date: 01 March 2006
*******************************************************************************/
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_associationtypecode is null OR @i_associationtypecode = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to retrieve from associatedtitles: associationtypecode is empty'  
    RETURN
  END 

  IF @i_associationtypesubcode > 0
    SELECT associatedtitles.bookkey,   
      associatedtitles.associationtypecode,   
      associatedtitles.associatetitlebookkey,   
      associatedtitles.sortorder,   
      associatedtitles.isbn productnumber,
      gentables.datadesc associatedtitlelabel,
      gentables.sortorder associationtypeorder,
      dbo.get_subgentables_desc(440, associatedtitles.associationtypecode, associatedtitles.associationtypesubcode, 'long') associatedtitlesublabel
     FROM associatedtitles, gentables  
   WHERE  associatedtitles.associationtypecode = gentables.datacode   and
      gentables.tableid = 440 AND
      associatedtitles.bookkey = @i_bookkey AND
      associatedtitles.associationtypecode = @i_associationtypecode AND
      associatedtitles.associationtypesubcode = @i_associationtypesubcode
    ORDER BY associationtypeorder, associatedtitles.associationtypecode,
      associatedtitles.associationtypesubcode, associatedtitles.sortorder
      
  ELSE  --@i_associationtypesubcode = 0 OR @i_associationtypesubcode IS NULL  
    SELECT associatedtitles.bookkey,   
      associatedtitles.associationtypecode,   
      associatedtitles.associatetitlebookkey,   
      associatedtitles.sortorder,   
      associatedtitles.isbn productnumber,
      gentables.datadesc associatedtitlelabel,
      gentables.sortorder associationtypeorder,
      '' associatedtitlesublabel
     FROM associatedtitles, gentables  
   WHERE  associatedtitles.associationtypecode = gentables.datacode   and
      gentables.tableid = 440 AND
      associatedtitles.bookkey = @i_bookkey AND
      associatedtitles.associationtypecode = @i_associationtypecode AND
      (associatedtitles.associationtypesubcode IS NULL OR associatedtitles.associationtypesubcode = 0)
    ORDER BY associationtypeorder, associatedtitles.associationtypecode,
      associatedtitles.associationtypesubcode, associatedtitles.sortorder

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR)  
  END 

GO

GRANT EXEC ON qtitle_get_specific_associatedtitles TO PUBLIC
GO

