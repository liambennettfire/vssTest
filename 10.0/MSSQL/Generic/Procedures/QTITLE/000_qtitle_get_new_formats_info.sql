if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_new_formats_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_new_formats_info
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_new_formats_info
 (@i_listkey        integer,
  @i_mediatypecode  integer,
  @i_formatcode     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_new_formats_info
**  Desc: This stored procedure returns all title information
**        for new formats being created.
**
**    Auth: Alan Katzen
**    Date: 26 July 2010
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT
      
  SELECT c.title, c.authorname, c.ean sourceisbn13, '' newisbn13, c.workkey,
         c.itemtypecode,c.usageclasscode,
         dbo.get_gentables_desc(312,@i_mediatypecode,'long') mediadesc,
         dbo.get_subgentables_desc(312,@i_mediatypecode,@i_formatcode,'long') formatdesc,
         dbo.qtitle_check_format_exists(c.workkey,@i_mediatypecode,@i_formatcode) formatexists,
         @i_mediatypecode mediatypecode, @i_formatcode formatcode, '' newisbn, '' newgtin,
         0 entereanprefixcode, 0 enterisbnprefixcode, '' enterendean, 1 newrowind, 0 formatcreated
    FROM qse_searchresults sr
         JOIN coretitleinfo c on c.bookkey = sr.key1 and c.printingkey = sr.key2           
   WHERE sr.listkey = @i_listkey  

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error: listkey = ' + cast(@i_listkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_new_formats_info TO PUBLIC
GO



