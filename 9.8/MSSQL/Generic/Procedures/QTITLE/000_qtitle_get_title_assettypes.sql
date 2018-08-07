if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_title_assettypes') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_title_assettypes
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_title_assettypes
 (@i_bookkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_title_assettypes
**  Desc: This stored procedure returns all elementtypes
**        for a title.
**
**    Auth: Alan Katzen
**    Date: 8 October 2010
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT
      
  IF isnull(@i_bookkey,0) = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error getting assettypes for a title - invalid from bookkey' 
    return 
  END
      
  SELECT taqelementtypecode datacode,
         dbo.get_gentables_desc(287,taqelementtypecode,'long') datadesc 
    FROM taqprojectelement e 
   WHERE taqelementtypecode in (select datacode from gentables where tableid = 287 and gen1ind = 1 and isnull(qsicode,0) <> 3)
     and bookkey = @i_bookkey
     and printingkey = 1

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error getting assettypes for a title: bookkey = ' + cast(isnull(@i_bookkey,0) AS VARCHAR)  
  END 
GO
GRANT EXEC ON qtitle_get_title_assettypes TO PUBLIC
GO



