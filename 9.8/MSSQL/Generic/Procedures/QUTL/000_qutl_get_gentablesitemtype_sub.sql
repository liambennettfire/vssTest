  if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_gentablesitemtype_sub') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_gentablesitemtype_sub
GO

CREATE PROCEDURE qutl_get_gentablesitemtype_sub
  (@i_tableid     integer,
  @i_itemtype     integer,
  @i_usageclass   integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/************************************************************************************************************************************
**  Name: qutl_get_gentablesitemtype_sub
**  Desc: This stored procedure returns Item Type filter information
**        from gentablesitemtype table joining to subgentables.
**
**  Auth: Kate J. Wiewiora
**  Date: May 16 2014
*************************************************************************************************************************************
**    Change History
*************************************************************************************************************************************
**    Date:       Author:        Case #:   Description:
**    --------    --------       -------   -----------------------------------------------------------------------------------
**   06/26/2014   Uday A. Khisty 28323     Need datacode to distinguish the control
**   09/24/2014   Uday A. Khisty 29155 - Task 005 rows with Usageclass take priority if exist over those that have just Itemtype
**   11/14/2017   Colman         48292     Return in datasubcode order. Participant by Role column config relies on it.
*************************************************************************************************************************************/

  DECLARE
    @v_error  INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  CREATE TABLE #gentablesitemtypeinfo (
    datacode int null,
    datasubcode int null,     
	datadesc VARCHAR(120) null,
	sortorder int null,
	relateddatacode int null,
	indicator1 tinyint null,
	text1 VARCHAR(255) null)  
	  
  IF @i_usageclass > 0 BEGIN 
	  INSERT INTO #gentablesitemtypeinfo	  
	  SELECT gi.datacode, gi.datasubcode, s.datadesc, gi.sortorder, gi.relateddatacode, gi.indicator1, gi.text1
	  FROM gentablesitemtype gi, subgentables s
	  WHERE gi.tableid = s.tableid AND
		  gi.datacode = s.datacode AND
		  gi.datasubcode = s.datasubcode AND
		  gi.tableid = @i_tableid AND
		  gi.itemtypecode = @i_itemtype AND
		  (gi.itemtypesubcode = @i_usageclass)     
  END
  
  INSERT INTO #gentablesitemtypeinfo	  
  SELECT gi.datacode, gi.datasubcode, s.datadesc, gi.sortorder, gi.relateddatacode, gi.indicator1, gi.text1
  FROM gentablesitemtype gi, subgentables s
  WHERE gi.tableid = s.tableid AND
      gi.datacode = s.datacode AND
      gi.datasubcode = s.datasubcode AND
      gi.tableid = @i_tableid AND
      gi.itemtypecode = @i_itemtype AND
      (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)
      AND NOT EXISTS(SELECT * FROM #gentablesitemtypeinfo t WHERE t.datacode = gi.datacode AND t.datasubcode = gi.datasubcode)   
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing gentablesitemtype table (tableid=' + CONVERT(VARCHAR, @i_tableid) + ').'
  END
  
  SELECT * FROM #gentablesitemtypeinfo order by datacode, datasubcode
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing #gentablesitemtypeinfo table (tableid=' + CONVERT(VARCHAR, @i_tableid) + ').'
  END  
  
  DROP TABLE #gentablesitemtypeinfo
GO

GRANT EXEC ON qutl_get_gentablesitemtype_sub TO PUBLIC
GO
