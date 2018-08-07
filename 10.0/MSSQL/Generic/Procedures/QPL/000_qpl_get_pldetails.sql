if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_pldetails') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_pldetails
GO

CREATE PROCEDURE qpl_get_pldetails
 (@i_itemtype     integer,
  @i_usageclass   integer,
  @i_verification_details tinyint,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*********************************************************************************************************
**  Name: qpl_get_pldetails
**  Desc: This stored procedure returns all details for the P&L Version Detail Selection.
**        If @i_verification_details=1, it returns only the details used for P&L Version Verification.
**
**  Auth: Kate
**  Date: November 16 2009
*********************************************************************************************************/

BEGIN

  DECLARE
    @v_count  INT,
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 581 AND itemtypecode = @i_itemtype AND itemtypesubcode IN (@i_usageclass,0)

  IF @i_verification_details = 1
    IF @v_count > 0
      SELECT x.gentext1 detailtype, g.datadesc detailtext
      FROM gentables g, gentables_ext x, gentablesitemtype i
      WHERE g.tableid = x.tableid AND g.datacode = x.datacode 
        AND g.tableid = i.tableid AND g.datacode = i.datacode
        AND g.tableid = 581
        AND g.deletestatus = 'N' AND x.gentext1 NOT IN ('PLVerProductionCostsByYear', 'PLVerComments')
        AND i.itemtypecode = @i_itemtype 
        AND (i.itemtypesubcode = @i_usageclass OR i.itemtypesubcode = 0)
      ORDER BY g.sortorder
    ELSE
      SELECT x.gentext1 detailtype, g.datadesc detailtext
      FROM gentables g, gentables_ext x
      WHERE g.tableid = x.tableid AND g.datacode = x.datacode 
        AND g.tableid = 581
        AND g.deletestatus = 'N' AND x.gentext1 NOT IN ('PLVerProductionCostsByYear', 'PLVerComments')
      ORDER BY g.sortorder
  ELSE  
    IF @v_count > 0
      SELECT x.gentext1 detailtype, g.datadesc detailtext, g.sortorder, g.deletestatus, 2 security
      FROM gentables g, gentables_ext x, gentablesitemtype i
      WHERE g.tableid = x.tableid AND g.datacode = x.datacode
        AND g.tableid = i.tableid AND g.datacode = i.datacode
        AND g.tableid = 581
        AND g.deletestatus = 'N'
        AND i.itemtypecode = @i_itemtype 
        AND (i.itemtypesubcode = @i_usageclass OR i.itemtypesubcode = 0)
      ORDER BY g.sortorder
    ELSE
      SELECT x.gentext1 detailtype, g.datadesc detailtext, g.sortorder, g.deletestatus, 2 security
      FROM gentables g, gentables_ext x
      WHERE g.tableid = x.tableid AND g.datacode = x.datacode
        AND g.tableid = 581
        AND g.deletestatus = 'N'
      ORDER BY g.sortorder          

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access gentables 581.'
  END

END
GO

GRANT EXEC ON qpl_get_pldetails TO PUBLIC
GO
