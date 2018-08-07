if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_subgentables_datacode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_subgentables_datacode
GO

CREATE PROCEDURE qutl_get_subgentables_datacode (
  @i_tableid      INT,
  @i_datacode     INT,
  @i_itemtype     INT,
  @i_usageclass   INT, 
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/***************************************************************************************************
**  Name: qutl_get_subgentables_datacode
**  Desc: This stored procedure returns active subgentable records for given tableid/datacode.
**
**  Auth: Kate
**  Date: February 8 2008
****************************************************************************************************/

  DECLARE
    @v_error  INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
    
  IF @i_itemtype > 0  --itemtype passed - include itemtype/usageclass filter
    SELECT s.datasubcode, s.datadesc, s.sortorder
    FROM subgentables s, gentablesitemtype gi
    WHERE s.tableid = gi.tableid 
      AND s.datacode = gi.datacode
      AND s.datasubcode = gi.datasubcode
      AND s.tableid = @i_tableid 
      AND s.datacode = @i_datacode
      AND gi.itemtypecode = @i_itemtype AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)
      AND UPPER(s.deletestatus) = 'N'
    ORDER BY s.sortorder, datadesc
  ELSE
    SELECT datasubcode, datadesc, sortorder
    FROM subgentables 
    WHERE tableid = @i_tableid 
      AND datacode = @i_datacode
      AND UPPER(deletestatus) = 'N'
    ORDER BY sortorder, datadesc
      
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not access subgentables (tableid=' + CAST(@i_tableid AS VARCHAR) + 
      ', datacode=' + CAST(@i_datacode AS VARCHAR) + ').'
  END 

GO

GRANT EXEC ON qutl_get_subgentables_datacode TO PUBLIC
GO


