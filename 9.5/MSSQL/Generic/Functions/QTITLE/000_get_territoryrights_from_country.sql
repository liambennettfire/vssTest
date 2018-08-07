if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].get_territoryrights_from_country') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].get_territoryrights_from_country
GO

CREATE FUNCTION dbo.get_territoryrights_from_country (@i_countrycode int)

RETURNS @territoryrightstable TABLE(
    territoryrightskey INT,
    bookkey INT,
    exclusiveind INT,
    forsaleind tinyint
	)
AS
BEGIN

DECLARE
  @v_count	INT,
  @v_code   INT,
  @v_forsaleind INT,
  @v_contractexclusiveind INT,
  @v_currentexclusiveind  INT,
  @v_datadesc	VARCHAR(40),
  @v_currentterritorycode INT ,
  @v_singlecountrycode INT,
  @v_singlecountrygroup INT,
  @v_exclusivecode INT,
  @v_territoryrightskey INT,
  @v_bookkey INT

  IF COALESCE(@i_countrycode,0) = 0 BEGIN
    return
  END

  -- Insert any title with World Rights as For Sale
  INSERT INTO @territoryrightstable
  SELECT tr.territoryrightskey, tr.bookkey,       
      CASE COALESCE(tr.exclusivecode,0)
        WHEN 1 THEN 1  -- Exclusive
        WHEN 2 THEN 0  -- Non Exclusive
        ELSE null
      END, 1 
    FROM territoryrights tr
   WHERE tr.bookkey > 0
     AND tr.itemtype = 1
     AND tr.currentterritorycode = 1  -- World
    
  -- Single Country
  INSERT INTO @territoryrightstable
  -- For Sale
  SELECT tr.territoryrightskey, tr.bookkey,       
      CASE COALESCE(tr.exclusivecode,0)
        WHEN 1 THEN 1  -- Exclusive
        WHEN 2 THEN 0  -- Non Exclusive
        ELSE null
      END, 1 
    FROM territoryrights tr
   WHERE tr.bookkey > 0
     AND tr.itemtype = 1
     AND tr.currentterritorycode = 2
     AND tr.singlecountrycode = @i_countrycode
   UNION 
  -- Not For Sale
  SELECT tr.territoryrightskey, tr.bookkey, null, 0 
    FROM territoryrights tr
   WHERE tr.bookkey > 0
     AND tr.itemtype = 1
     AND tr.currentterritorycode = 2
     AND tr.singlecountrycode <> @i_countrycode

  --Selected Countries
  INSERT INTO @territoryrightstable
  -- For Sale/Not For Sale
  SELECT trc.territoryrightskey, trc.bookkey, trc.currentexclusiveind, trc.forsaleind 
    FROM territoryrightcountries trc, territoryrights tr
   WHERE trc.territoryrightskey = tr.territoryrightskey
     AND trc.bookkey > 0
     AND trc.itemtype = 1
     AND tr.currentterritorycode = 3
     AND trc.countrycode = @i_countrycode
   UNION 
  -- Not Accounted For
  SELECT tr.territoryrightskey, tr.bookkey, null, 99 
    FROM territoryrights tr
   WHERE tr.bookkey > 0
     AND tr.itemtype = 1
     AND tr.currentterritorycode = 3
     AND tr.territoryrightskey not in (SELECT trc.territoryrightskey FROM territoryrightcountries trc
                                        WHERE trc.countrycode = @i_countrycode)    

  --Single Country Group
  INSERT INTO @territoryrightstable
  -- For Sale
  SELECT tr.territoryrightskey, tr.bookkey,       
      CASE COALESCE(tr.exclusivecode,0)
        WHEN 1 THEN 1  -- Exclusive
        WHEN 2 THEN 0  -- Non Exclusive
        ELSE null
      END, 1 
    FROM territoryrights tr, gentablesrelationshipdetail r
   WHERE tr.bookkey > 0
     AND tr.itemtype = 1
     AND tr.currentterritorycode = 4
     AND r.gentablesrelationshipkey = 23
     AND r.code1 = tr.singlecountrygroupcode
     AND r.code2 = @i_countrycode      
   UNION 
  -- Not For Sale
  SELECT tr.territoryrightskey, tr.bookkey, null, 0 
    FROM territoryrights tr
   WHERE tr.bookkey > 0
     AND tr.itemtype = 1
     AND tr.currentterritorycode = 4    
     AND @i_countrycode NOT IN (SELECT code2
                                  FROM gentablesrelationshipdetail
                                 WHERE gentablesrelationshipkey = 23
                                   AND code1 = tr.singlecountrygroupcode)
    
  --World Excluding Single Country
  INSERT INTO @territoryrightstable
  -- For Sale
  SELECT tr.territoryrightskey, tr.bookkey,       
      CASE COALESCE(tr.exclusivecode,0)
        WHEN 1 THEN 1  -- Exclusive
        WHEN 2 THEN 0  -- Non Exclusive
        ELSE null
      END, 1 
    FROM territoryrights tr
   WHERE tr.bookkey > 0
     AND tr.itemtype = 1
     AND tr.currentterritorycode = 5
     AND tr.singlecountrycode <> @i_countrycode
   UNION 
  -- Not For Sale
  SELECT tr.territoryrightskey, tr.bookkey, null, 0
    FROM territoryrights tr
   WHERE tr.bookkey > 0
     AND tr.itemtype = 1
     --AND tr.exclusivecode > 0
     AND tr.currentterritorycode = 5
     AND tr.singlecountrycode = @i_countrycode
    
  --World Excluding Single Country Group
  INSERT INTO @territoryrightstable
  -- For Sale
  SELECT tr.territoryrightskey, tr.bookkey,       
      CASE COALESCE(tr.exclusivecode,0)
        WHEN 1 THEN 1  -- Exclusive
        WHEN 2 THEN 0  -- Non Exclusive
        ELSE null
      END, 1 
    FROM territoryrights tr
   WHERE tr.bookkey > 0
     AND tr.itemtype = 1
     AND tr.currentterritorycode = 6    
     AND @i_countrycode NOT IN (SELECT code2
                                  FROM gentablesrelationshipdetail
                                 WHERE gentablesrelationshipkey = 23
                                   AND code1 = tr.singlecountrygroupcode)
   UNION 
  -- Not For Sale
  SELECT tr.territoryrightskey, tr.bookkey, null, 0 
    FROM territoryrights tr, gentablesrelationshipdetail r
   WHERE tr.bookkey > 0
     AND tr.itemtype = 1
     AND tr.currentterritorycode = 6
     AND r.gentablesrelationshipkey = 23
     AND r.code1 = tr.singlecountrygroupcode
     AND r.code2 = @i_countrycode      
   
	 RETURN
END
GO

GRANT SELECT ON dbo.get_territoryrights_from_country TO PUBLIC
GO