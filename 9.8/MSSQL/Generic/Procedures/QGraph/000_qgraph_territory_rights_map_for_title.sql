if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qgraph_territory_rights_map_for_title') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qgraph_territory_rights_map_for_title
GO

CREATE PROCEDURE qgraph_territory_rights_map_for_title 
 (@i_bookkey      integer)
AS

/******************************************************************************************
**  Name: qgraph_territory_rights_map_for_title
**  Desc: Gross Margin Transmittals By Month
**
**  Auth: Alan Katzen
**  Date: July 22 2016
*******************************************************************************************/

DECLARE
  @v_bookkey  INT,
  @v_count INT
  
BEGIN
  SELECT @v_count = count(*) 
    FROM dbo.qtitle_get_territorycountry_by_title (@i_bookkey) t

  IF @v_count > 0 BEGIN
    SELECT '{v:"' + (select bisacdatacode from gentables where tableid = 114 and datacode = t.countrycode) + '",f:"' + dbo.get_gentables_desc(114,t.countrycode,'') + '"}'  Country,
    case forsaleind 
      WHEN 99 THEN 2
      ELSE forsaleind
    end forsaleind,  
    case forsaleind
    --  WHEN 1 THEN '"For Sale in ' + (select datadesc from gentables where tableid = 114 and datacode = t.countrycode) + "'";
    --  WHEN 0 THEN '"Not For Sale in ' + (select datadesc from gentables where tableid = 114 and datacode = t.countrycode) + "'";
      WHEN 1 THEN '"For Sale"'
      WHEN 0 THEN '"Not For Sale"'
      WHEN 99 THEN '"Not Accounted For"'
      ELSE '"Unknown"'
    end tooltip  
    FROM dbo.qtitle_get_territorycountry_by_title (@i_bookkey) t
  END
  ELSE BEGIN
    -- no territiries found, make all not accounted for
    SELECT '{v:"' + bisacdatacode + '",f:"' + datadesc + '"}'  Country, 2 forsaleind, '"Not Accounted For"' tooltip
    FROM gentables 
    WHERE tableid = 114
  END
END
GO

GRANT EXEC ON qgraph_territory_rights_map_for_title TO PUBLIC
GO
