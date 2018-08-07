IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_copy_list')
BEGIN
  DROP  Procedure  qse_copy_list
END
GO

CREATE PROCEDURE qse_copy_list
 (@i_from_listkey   integer,
  @i_to_listkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/**********************************************************************************
**  Name: qse_copy_list
**  Desc: This stored procedure copies all results from one list to another.
**
**  Auth: Kate
**  Date: 8 August 2006
**********************************************************************************/

  DECLARE 
  @SQLString  NVARCHAR(4000)
  
  IF @i_from_listkey <> @i_to_listkey
  BEGIN
    SET @SQLString = N'INSERT INTO qse_searchresults (listkey, key1, key2)
      SELECT ' + CONVERT(VARCHAR, @i_to_listkey) + ', key1, key2
      FROM qse_searchresults WHERE listkey = ' + CONVERT(VARCHAR, @i_from_listkey)
      
    EXECUTE sp_executesql @SQLString
  END

GO

GRANT EXEC ON qse_copy_list TO PUBLIC
GO
