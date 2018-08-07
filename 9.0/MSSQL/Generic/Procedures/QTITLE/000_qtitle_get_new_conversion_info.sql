if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_new_conversion_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_new_conversion_info
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_new_conversion_info
 (@i_listkeyfrom    integer,
  @i_bookkeyfrom    integer,
  @i_assettypeto    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_new_conversion_info
**  Desc: This stored procedure returns all title information
**        for new conversions being created.
**
**    Auth: Alan Katzen
**    Date: 8 October 2010
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT
      
  IF (isnull(@i_bookkeyfrom,0) = 0 AND isnull(@i_listkeyfrom,0) = 0  AND isnull(@i_assettypeto,0) > 0) BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error getting conversion info - invalid from bookkey and listkey' 
    return 
  END
      

  IF @i_listkeyfrom > 0 BEGIN      
    SELECT distinct c.title titlefrom, c.productnumber isbn13from, 0 bookkeyto, c.workkey workkeyfrom,
           dbo.get_subgentables_desc(312,c.mediatypecode,c.mediatypesubcode,'long') formatfromdesc,
           dbo.get_gentables_desc(287,@i_assettypeto,'long') assettodesc,@i_assettypeto assettypeto,
           0 assettoexists, 0 assettypefrom, c.bookkey bookkeyfrom, '' assetfromdesc, '' isbn13todesc 
      FROM qse_searchresults sr
           JOIN coretitleinfo c on c.bookkey = sr.key1 and c.printingkey = sr.key2           
     WHERE sr.listkey = @i_listkeyfrom  
       
    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error getting conversion info: listkey = ' + cast(isnull(@i_listkeyfrom,0) AS VARCHAR)  
    END       
  END
  ELSE BEGIN
    SELECT distinct c.title titlefrom, c.ean isbn13from, 0 bookkeyto, c.workkey workkeyfrom,
           dbo.get_subgentables_desc(312,c.mediatypecode,c.mediatypesubcode,'long') formatfromdesc,
           dbo.get_gentables_desc(287,@i_assettypeto,'long') assettodesc,@i_assettypeto assettypeto,
           0 assettoexists, 0 assettypefrom, @i_bookkeyfrom bookkeyfrom, '' assetfromdesc, '' isbn13todesc 
      FROM coretitleinfo c
     WHERE c.bookkey = @i_bookkeyfrom 
       and c.printingkey = 1  

    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error getting conversion info: bookkey = ' + cast(isnull(@i_bookkeyfrom,0) AS VARCHAR)  
    END 
  END
GO
GRANT EXEC ON qtitle_get_new_conversion_info TO PUBLIC
GO



