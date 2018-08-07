if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qse_get_list_searchtype') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qse_get_list_searchtype
GO

CREATE FUNCTION dbo.qse_get_list_searchtype
(
  @i_listkey INT
) 
RETURNS INT

/**********************************************************************************************
**  Name: qse_get_list_searchtype
**  Desc: This function returns a string containing all element type codes of assets 
**        to be resent for the given partnercontactkey.
**
**  Auth: Kate
**  Date: October 30 2012
**********************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_searchtype  INT

  SET @v_searchtype = 0
  
  SELECT @v_count = COUNT(*)
  FROM qse_searchlist
  WHERE listkey = @i_listkey
  
  IF @v_count > 0
    SELECT @v_searchtype = searchtypecode
    FROM qse_searchlist
    WHERE listkey = @i_listkey
    
  RETURN @v_searchtype
  
END
GO

GRANT EXEC ON dbo.qse_get_list_searchtype TO PUBLIC
GO

