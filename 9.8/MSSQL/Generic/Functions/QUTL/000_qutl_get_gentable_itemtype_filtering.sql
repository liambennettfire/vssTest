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
	datacode INT,
	datasubcode INT,
	datasub2code INT
)
AS
/****************************************************************************************************************************
**  File: 
**  Name: qutl_get_gentable_itemtype_filtering
**  Desc: Function to return gentable values for a given tableid based on
**        itemtype/usageclass filtering.
**
**        NOTE: Pass 0 itemtype to retrieve all gentables (no itemtype filtering)
**
**  Auth: Alan Katzen
**  Date: 10/26/09
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    05/09/2016   Uday			   37359 Allow "Copy from Project" to be a different class from project being created 
*****************************************************************************************************************************/

BEGIN
  DECLARE @error_var    integer,
          @rowcount_var integer,
          @v_itemtypefilterind integer
          
  SELECT @v_itemtypefilterind = COALESCE(itemtypefilterind,0)
    FROM gentablesdesc
   WHERE tableid = @i_tableid
   
  -- itemtype filtering is at the gentablesdesc level if itemtypefilterind = 1
  IF (@v_itemtypefilterind = 1 AND @i_itemtype > 0) BEGIN
    -- add all gentables with no itemtype/usageclass filtering setup
    INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
    SELECT g.tableid, COALESCE(g.datacode, 0) datacode, COALESCE(sg.datasubcode, 0) datasubcode, COALESCE(s2g.datasub2code, 0) as datasub2code
      FROM gentables g LEFT OUTER JOIN subgentables sg ON g.datacode = sg.datacode AND g.tableid = sg.tableid
					   LEFT OUTER JOIN sub2gentables s2g ON sg.datacode = s2g.datacode  AND sg.datasubcode = sg.datasubcode AND sg.tableid = s2g.tableid
     WHERE g.tableid = @i_tableid 
       AND LTRIM(RTRIM(UPPER(COALESCE(g.deletestatus, 'N'))))='N'
       AND LTRIM(RTRIM(UPPER(COALESCE(sg.deletestatus, 'N'))))='N'
       AND LTRIM(RTRIM(UPPER(COALESCE(s2g.deletestatus, 'N'))))='N'
       and not exists (SELECT * FROM gentablesitemtype 
					   WHERE tableid = @i_tableid)     
      
    IF (@i_itemtype > 0) BEGIN              
      -- add all gentables with itemtype filtering setup for all usageclasses (0 usageclass)
      INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
      SELECT g.tableid, COALESCE(g.datacode, 0) datacode, COALESCE(sg.datasubcode, 0) datasubcode, COALESCE(s2g.datasub2code, 0) as datasub2code
      FROM gentables g LEFT OUTER JOIN subgentables sg ON g.datacode = sg.datacode AND g.tableid = sg.tableid
			   LEFT OUTER JOIN sub2gentables s2g ON sg.datacode = s2g.datacode  AND sg.datasubcode = sg.datasubcode AND sg.tableid = s2g.tableid
       WHERE g.tableid = @i_tableid
       AND LTRIM(RTRIM(UPPER(COALESCE(g.deletestatus, 'N'))))='N'
       AND LTRIM(RTRIM(UPPER(COALESCE(sg.deletestatus, 'N'))))='N'
       AND LTRIM(RTRIM(UPPER(COALESCE(s2g.deletestatus, 'N'))))='N'       
       and exists (SELECT * FROM gentablesitemtype 
					   WHERE tableid = @i_tableid AND 
					         datacode = 0 AND 
					         datasubcode = 0 AND
					         datasub2code = 0 AND
					         itemtypecode = @i_itemtype AND
                             COALESCE(itemtypesubcode,0) = 0)
       and not exists (SELECT * FROM @gentablelist 
					   WHERE tableid = @i_tableid AND 
					         datacode = COALESCE(g.datacode, 0) AND 
					         datasubcode = COALESCE(datasubcode, 0) AND
					         datasub2code = COALESCE(datasub2code, 0))             
    END 
                        
    IF (@i_itemtype > 0 and @i_usageclass > 0) BEGIN              
      -- add all gentables with itemtype/usageclass filtering setup
      INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
      SELECT g.tableid, COALESCE(g.datacode, 0) datacode, COALESCE(sg.datasubcode, 0) datasubcode, COALESCE(s2g.datasub2code, 0) as datasub2code
      FROM gentables g LEFT OUTER JOIN subgentables sg ON g.datacode = sg.datacode AND g.tableid = sg.tableid
			   LEFT OUTER JOIN sub2gentables s2g ON sg.datacode = s2g.datacode  AND sg.datasubcode = sg.datasubcode AND sg.tableid = s2g.tableid
       WHERE g.tableid = @i_tableid
       AND LTRIM(RTRIM(UPPER(COALESCE(g.deletestatus, 'N'))))='N'
       AND LTRIM(RTRIM(UPPER(COALESCE(sg.deletestatus, 'N'))))='N'
       AND LTRIM(RTRIM(UPPER(COALESCE(s2g.deletestatus, 'N'))))='N'       
       and exists (SELECT * FROM gentablesitemtype 
					   WHERE tableid = @i_tableid AND 
					         datacode = 0 AND 
					         datasubcode = 0 AND
					         datasub2code = 0 AND
					         itemtypecode = @i_itemtype AND
                             COALESCE(itemtypesubcode,0) = @i_usageclass)
       and not exists (SELECT * FROM @gentablelist 
					   WHERE tableid = @i_tableid AND 
					         datacode = COALESCE(g.datacode, 0) AND 
					         datasubcode = COALESCE(datasubcode, 0) AND
					         datasub2code = COALESCE(datasub2code, 0))        
    END   
  END   
  -- itemtype filtering is at the gentables level if itemtypefilterind = 2
  ELSE IF (@v_itemtypefilterind = 2 AND @i_itemtype > 0) BEGIN
    -- add all gentables with no itemtype/usageclass filtering setup
    INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
    SELECT g.tableid, g.datacode, 0, 0
      FROM gentables g
     WHERE g.tableid = @i_tableid
       AND LTRIM(RTRIM(UPPER(COALESCE(g.deletestatus, 'N'))))='N'     
       and not exists (SELECT * FROM gentablesitemtype 
					   WHERE tableid = @i_tableid AND 
					         datacode = g.datacode)     
      
    IF (@i_itemtype > 0) BEGIN              
      -- add all gentables with itemtype filtering setup for all usageclasses (0 usageclass)
      INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
      SELECT g.tableid, g.datacode, 0, 0
        FROM gentables g
       WHERE g.tableid = @i_tableid
       AND LTRIM(RTRIM(UPPER(COALESCE(g.deletestatus, 'N'))))='N'       
       and exists (SELECT * FROM gentablesitemtype 
					   WHERE tableid = @i_tableid AND 
					         datacode = g.datacode AND 
					         datasubcode = 0 AND
					         datasub2code = 0 AND
					         itemtypecode = @i_itemtype AND
                             COALESCE(itemtypesubcode,0) = 0)
       and not exists (SELECT * FROM @gentablelist 
					   WHERE tableid = @i_tableid AND 
					         datacode = g.datacode AND 
					         datasubcode = 0 AND
					         datasub2code = 0)             
    END 
                        
    IF (@i_itemtype > 0 and @i_usageclass > 0) BEGIN              
      -- add all gentables with itemtype/usageclass filtering setup
      INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
      SELECT g.tableid, g.datacode, 0, 0
        FROM gentables g
       WHERE g.tableid = @i_tableid
       AND LTRIM(RTRIM(UPPER(COALESCE(g.deletestatus, 'N'))))='N'       
       and exists (SELECT * FROM gentablesitemtype 
					   WHERE tableid = @i_tableid AND 
					         datacode = g.datacode AND 
					         datasubcode = 0 AND
					         datasub2code = 0 AND
					         itemtypecode = @i_itemtype AND
                             COALESCE(itemtypesubcode,0) = @i_usageclass)
       and not exists (SELECT * FROM @gentablelist 
					   WHERE tableid = @i_tableid AND 
					         datacode = g.datacode AND 
					         datasubcode = 0 AND
					         datasub2code = 0)        
    END
    
    --IF (@i_itemtype > 0 and @i_usageclass = 0) BEGIN
    --  -- add all gentables with itemtype/usageclass filtering setup 
    --  INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
    --  SELECT DISTINCT g.tableid, g.datacode, 0, 0
    --    FROM gentables g
    --   WHERE g.tableid = @i_tableid
    --   and exists (SELECT * FROM gentablesitemtype 
				--	   WHERE tableid = @i_tableid AND 
				--	         datacode = g.datacode AND 
				--	         datasubcode = 0 AND
				--	         datasub2code = 0 AND
				--	         itemtypecode = @i_itemtype AND
    --                         COALESCE(itemtypesubcode,0) IN (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND datacode = @i_itemtype))
    --   and not exists (SELECT * FROM @gentablelist 
				--	   WHERE tableid = @i_tableid AND 
				--	         datacode = g.datacode AND 
				--	         datasubcode = 0 AND
				--	         datasub2code = 0)   	    
    --END                  
  END
  -- itemtype filtering is at the subgentables level if itemtypefilterind = 3
  ELSE IF (@v_itemtypefilterind = 3 AND @i_itemtype > 0) BEGIN
    -- add all gentables with no itemtype/usageclass filtering setup
    INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
    SELECT sg.tableid, sg.datacode, sg.datasubcode, 0
      FROM subgentables sg
     WHERE sg.tableid = @i_tableid       
       AND LTRIM(RTRIM(UPPER(COALESCE(sg.deletestatus, 'N'))))='N'     
       and not exists (SELECT * FROM gentablesitemtype 
					   WHERE tableid = @i_tableid AND 
					         datacode = sg.datacode AND 
					         datasubcode = sg.datasubcode)
      
    IF (@i_itemtype > 0) BEGIN              
      -- add all subgentables with itemtype filtering setup for all usageclasses (0 usageclass)
      INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
      SELECT sg.tableid, sg.datacode, sg.datasubcode, 0
        FROM subgentables sg
       WHERE sg.tableid = @i_tableid    
       AND LTRIM(RTRIM(UPPER(COALESCE(sg.deletestatus, 'N'))))='N'       
       and exists (SELECT * FROM gentablesitemtype 
					   WHERE tableid = @i_tableid AND 
					         datacode = sg.datacode AND 
					         datasubcode = sg.datasubcode AND
					         datasub2code = 0 AND
					         itemtypecode = @i_itemtype AND
                             COALESCE(itemtypesubcode,0) = 0)
       and not exists (SELECT * FROM @gentablelist 
					   WHERE tableid = @i_tableid AND 
					         datacode = sg.datacode AND 
					         datasubcode = sg.datasubcode AND
					         datasub2code = 0)                                 
    END 
                        
    IF (@i_itemtype > 0 and @i_usageclass > 0) BEGIN              
      -- add all subgentables with itemtype/usageclass filtering setup
      INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
      SELECT sg.tableid, sg.datacode, sg.datasubcode, 0
        FROM subgentables sg
       WHERE sg.tableid = @i_tableid
       AND LTRIM(RTRIM(UPPER(COALESCE(sg.deletestatus, 'N'))))='N'       
       and exists (SELECT * FROM gentablesitemtype 
					   WHERE tableid = @i_tableid AND 
					         datacode = sg.datacode AND 
					         datasubcode = sg.datasubcode AND
					         datasub2code = 0 AND
					         itemtypecode = @i_itemtype AND
                             COALESCE(itemtypesubcode,0) = @i_usageclass)
       and not exists (SELECT * FROM @gentablelist 
					   WHERE tableid = @i_tableid AND 
					         datacode = sg.datacode AND 
					         datasubcode = sg.datasubcode AND
					         datasub2code = 0) 
    END
    
    --IF (@i_itemtype > 0 and @i_usageclass = 0) BEGIN
    --  -- add all gentables with itemtype/usageclass filtering setup 
    --  INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
    --  SELECT DISTINCT sg.tableid, sg.datacode, sg.datasubcode, 0
    --    FROM subgentables sg
    --   WHERE sg.tableid = @i_tableid
    --   and exists (SELECT * FROM gentablesitemtype 
				--	   WHERE tableid = @i_tableid AND 
				--	         datacode = sg.datacode AND 
				--	         datasubcode = sg.datasubcode AND
				--	         datasub2code = 0 AND
				--	         itemtypecode = @i_itemtype AND
    --                         COALESCE(itemtypesubcode,0) IN (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND datacode = @i_itemtype))
    --   and not exists (SELECT * FROM @gentablelist 
				--	   WHERE tableid = @i_tableid AND 
				--	         datacode = sg.datacode AND 
				--	         datasubcode = sg.datasubcode AND
				--	         datasub2code = 0)   	    
    --END                        
  END  
  -- itemtype filtering is at the sub2gentables level if itemtypefilterind = 4
  ELSE IF (@v_itemtypefilterind = 4 AND @i_itemtype > 0) BEGIN
    -- add all sub2gentables with no itemtype/usageclass filtering setup
    INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
    SELECT s2g.tableid, s2g.datacode, s2g.datasubcode, s2g.datasub2code
      FROM sub2gentables s2g
     WHERE s2g.tableid = @i_tableid
       AND LTRIM(RTRIM(UPPER(COALESCE(s2g.deletestatus, 'N'))))='N'     
       and not exists (SELECT * FROM gentablesitemtype 
					   WHERE tableid = @i_tableid AND 
					         datacode = s2g.datacode AND 
					         datasubcode = s2g.datasubcode AND
					         datasub2code = s2g.datasub2code)
      
    IF (@i_itemtype > 0) BEGIN              
      -- add all sub2gentables with itemtype filtering setup for all usageclasses (0 usageclass)
      INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
      SELECT s2g.tableid, s2g.datacode, s2g.datasubcode, s2g.datasub2code
        FROM sub2gentables s2g
       WHERE s2g.tableid = @i_tableid    
       AND LTRIM(RTRIM(UPPER(COALESCE(s2g.deletestatus, 'N'))))='N'       
       and exists (SELECT * FROM gentablesitemtype 
					   WHERE tableid = @i_tableid AND 
					         datacode = s2g.datacode AND 
					         datasubcode = s2g.datasubcode AND
					         datasub2code = s2g.datasub2code AND
					         itemtypecode = @i_itemtype AND
                             COALESCE(itemtypesubcode,0) = 0)
       and not exists (SELECT * FROM @gentablelist 
					   WHERE tableid = @i_tableid AND 
					         datacode = s2g.datacode AND 
					         datasubcode = s2g.datasubcode AND
					         datasub2code = s2g.datasub2code)                                 
    END 
                        
    IF (@i_itemtype > 0 and @i_usageclass > 0) BEGIN              
      -- add all sub2gentables with itemtype/usageclass filtering setup
      INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
      SELECT s2g.tableid, s2g.datacode, s2g.datasubcode, s2g.datasub2code
        FROM sub2gentables s2g
       WHERE s2g.tableid = @i_tableid
       AND LTRIM(RTRIM(UPPER(COALESCE(s2g.deletestatus, 'N'))))='N'       
       and exists (SELECT * FROM gentablesitemtype 
					   WHERE tableid = @i_tableid AND 
					         datacode = s2g.datacode AND 
					         datasubcode = s2g.datasubcode AND
					         datasub2code = s2g.datasub2code AND
					         itemtypecode = @i_itemtype AND
                             COALESCE(itemtypesubcode,0) = @i_usageclass)
       and not exists (SELECT * FROM @gentablelist 
					   WHERE tableid = @i_tableid AND 
					         datacode = s2g.datacode AND 
					         datasubcode = s2g.datasubcode AND
					         datasub2code = s2g.datasub2code) 
    END   
    
    --IF (@i_itemtype > 0 and @i_usageclass = 0) BEGIN
    --  -- add all gentables with itemtype/usageclass filtering setup 
    --  INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
    --  SELECT DISTINCT s2g.tableid, s2g.datacode, s2g.datasubcode, s2g.datasub2code
    --    FROM sub2gentables s2g
    --   WHERE s2g.tableid = @i_tableid
    --   and exists (SELECT * FROM gentablesitemtype 
				--	   WHERE tableid = @i_tableid AND 
				--	         datacode = s2g.datacode AND 
				--	         datasubcode = s2g.datasubcode AND
				--	         datasub2code = s2g.datasub2code AND
				--	         itemtypecode = @i_itemtype AND
    --                         COALESCE(itemtypesubcode,0) IN (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND datacode = @i_itemtype))
    --   and not exists (SELECT * FROM @gentablelist 
				--	   WHERE tableid = @i_tableid AND 
				--	         datacode = s2g.datacode AND 
				--	         datasubcode = s2g.datasubcode AND
				--	         datasub2code = s2g.datasub2code)   	    
    --END                   
  END  
  ELSE BEGIN
    -- itemtype filtering is not at the gentables level - add all gentables rows
    INSERT INTO @gentablelist (tableid,datacode, datasubcode, datasub2code)
    SELECT g.tableid, COALESCE(g.datacode, 0) datacode, COALESCE(sg.datasubcode, 0) datasubcode, COALESCE(s2g.datasub2code, 0)  datasub2code
      FROM gentables g LEFT OUTER JOIN subgentables sg ON g.datacode = sg.datacode AND g.tableid = sg.tableid
					   LEFT OUTER JOIN sub2gentables s2g ON sg.datacode = s2g.datacode  AND sg.datasubcode = sg.datasubcode AND sg.tableid = s2g.tableid
     WHERE g.tableid = @i_tableid
       AND LTRIM(RTRIM(UPPER(COALESCE(g.deletestatus, 'N'))))='N'
       AND LTRIM(RTRIM(UPPER(COALESCE(sg.deletestatus, 'N'))))='N'
       AND LTRIM(RTRIM(UPPER(COALESCE(s2g.deletestatus, 'N'))))='N'     
  END
    
  RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

