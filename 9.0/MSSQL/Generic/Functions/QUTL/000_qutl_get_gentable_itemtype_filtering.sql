if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qutl_get_gentable_itemtype_filtering') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qutl_get_gentable_itemtype_filtering
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
CREATE FUNCTION qutl_get_gentable_itemtype_filtering(
  @i_tableid            integer,
  @i_itemtype           integer,
  @i_usageclass         integer)
RETURNS @gentablelist TABLE(
	tableid INT,
	datacode INT
)
AS
/******************************************************************************
**  File: 
**  Name: qutl_get_gentable_itemtype_filtering
**  Desc: Function to return gentable values for a given tableid based on
**        itemtype/usageclass filtering.
**
**        NOTE: Pass 0 itemtype to retrieve all gentables (no itemtype filtering)
**
**  Auth: Alan Katzen
**  Date: 10/26/09
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN
  DECLARE @error_var    integer,
          @rowcount_var integer,
          @v_itemtypefilterind integer
          
  SELECT @v_itemtypefilterind = COALESCE(itemtypefilterind,0)
    FROM gentablesdesc
   WHERE tableid = @i_tableid
   
  -- itemtype filtering is at the gentables level if itemtypefilterind = 2
  IF (@v_itemtypefilterind = 2 AND @i_itemtype > 0) BEGIN
    -- add all gentables with no itemtype/usageclass filtering setup
    INSERT INTO @gentablelist (tableid,datacode)
    SELECT tableid,datacode
      FROM gentables g
     WHERE g.tableid = @i_tableid
       and g.datacode not in (SELECT datacode FROM gentablesitemtype
                              WHERE tableid = @i_tableid) 
      
    IF (@i_itemtype > 0) BEGIN              
      -- add all gentables with itemtype filtering setup for all usageclasses (0 usageclass)
      INSERT INTO @gentablelist (tableid,datacode)
      SELECT tableid,datacode
        FROM gentables g
       WHERE g.tableid = @i_tableid
         and g.datacode in (SELECT datacode FROM gentablesitemtype
                             WHERE tableid = @i_tableid
                               and itemtypecode = @i_itemtype
                               and COALESCE(itemtypesubcode,0) = 0) 
         and g.datacode not in (SELECT datacode FROM @gentablelist)
    END 
                        
    IF (@i_itemtype > 0 and @i_usageclass > 0) BEGIN              
      -- add all gentables with itemtype/usageclass filtering setup
      INSERT INTO @gentablelist (tableid,datacode)
      SELECT tableid,datacode
        FROM gentables g
       WHERE g.tableid = @i_tableid
         and g.datacode in (SELECT datacode FROM gentablesitemtype
                             WHERE tableid = @i_tableid
                               and itemtypecode = @i_itemtype
                               and COALESCE(itemtypesubcode,0) = @i_usageclass) 
         and g.datacode not in (SELECT datacode FROM @gentablelist)
    END                  
  END
  ELSE BEGIN
    -- itemtype filtering is not at the gentables level - add all gentables rows
    INSERT INTO @gentablelist (tableid,datacode)
    SELECT DISTINCT tableid,datacode
      FROM gentables g
     WHERE g.tableid = @i_tableid
  END
    
  RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

