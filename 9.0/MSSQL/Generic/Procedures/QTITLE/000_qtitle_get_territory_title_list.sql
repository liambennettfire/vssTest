if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_territory_title_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_territory_title_list
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_territory_title_list
 (@i_listkey							integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_territory_title_list
**  Desc: This procedure retrieves all titles from the corresponding list for a territorial rights update
**
**	Auth: Dustin Miller
**	Date: July 9 2012
*******************************************************************************/
	DECLARE @v_error			INT,
          @v_rowcount		INT
	
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT c.bookkey, c.printingkey, tr.territoryrightskey, c.title, d.territoryderivedfromcontractind
  FROM qse_searchresults sr
		JOIN coretitleinfo c on c.bookkey = sr.key1 and c.printingkey = sr.key2
		JOIN bookdetail d on d.bookkey = sr.key1
		LEFT JOIN territoryrights tr on tr.bookkey = sr.key1
	WHERE sr.listkey = @i_listkey

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning title list information for use with territory (@i_listkey=' + cast(@i_listkey as varchar) + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qtitle_get_territory_title_list TO PUBLIC
GO