if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_titles_by_assoc_bookkey') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_titles_by_assoc_bookkey
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_titles_by_assoc_bookkey
 (@i_bookkey  integer,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS


/******************************************************************************
**  Name: qtitle_get_titles_by_assoc_bookkey
**  Desc: This retrieves all associatedtitles records where the bookkey
**        is the associatetitlebookkey
**                       
**  Auth: Alan Katzen
**  Date: 12 October 2009
**
*******************************************************************************/
  
  DECLARE @error_var    INT,
          @rowcount_var INT

  SELECT bookkey, associationtypecode, associationtypesubcode, associatetitlebookkey, sortorder,   
    isbn, productidtype, salesunitgross, salesunitnet, 
    bookpos, lifetodatepointofsale, yeartodatepointofsale, previousyearpointofsale         
  FROM associatedtitles  
  WHERE associatetitlebookkey = @i_bookkey    
     
  -- Save the @@ERROR in local variable before it's cleared.
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error in qtitle_get_titles_by_assoc_bookkey accessing associatedtitles: bookkey=' + cast(@i_bookkey AS VARCHAR) + '.'
  END 
GO

GRANT EXEC ON qtitle_get_titles_by_assoc_bookkey TO PUBLIC
GO