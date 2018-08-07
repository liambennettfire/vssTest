if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qtitle_get_territorycountry_by_title') and xtype in (N'FN', N'IF', N'TF'))
  drop function [dbo].qtitle_get_territorycountry_by_title
GO

CREATE FUNCTION dbo.qtitle_get_territorycountry_by_title(@i_bookkey int)

RETURNS @territoryctrybytable TABLE(
  territoryrightskey INT,
  rightskey INT NULL,  
  contractkey INT NULL,
  bookkey INT NULL,
  countrycode INT NULL,
  forsaleind TINYINT NULL DEFAULT 0,
  contractexclusiveind TINYINT NULL DEFAULT 0,
  nonexclusivesubrightsoldind TINYINT NULL DEFAULT 0,
  currentexclusiveind TINYINT NULL DEFAULT 0,
  exclusivesubrightsoldind TINYINT NULL DEFAULT 0,
  lastuserid VARCHAR(30) NULL,
  lastmaintdate DATETIME NULL
)
AS

BEGIN
  DECLARE 
    @v_bookkey	INT,
    @v_derivedfromcontractind	TINYINT,    
    @v_territoryrightskey INT,
    @v_rightskey	INT,
    @v_taqprojectkey	INT,
    @v_currentterritorycode	INT,
    @v_exclusivecode	INT,
    @v_singlecountrycode	INT,
    @v_singlecountrygroupcode	INT,
    @v_lastuserid VARCHAR(30),
    @v_lastmaintdate DATETIME
  
  IF coalesce(@i_bookkey,0) = 0 BEGIN
    return
  END
  
  DECLARE bookdetail_cur CURSOR FAST_FORWARD FOR
    SELECT bookkey, territoryderivedfromcontractind
      FROM bookdetail
     WHERE bookkey = @i_bookkey
    
  OPEN bookdetail_cur

  FETCH bookdetail_cur INTO @v_bookkey, @v_derivedfromcontractind

  WHILE (@@FETCH_STATUS = 0)
  BEGIN

    SET @v_territoryrightskey = NULL
    SET @v_rightskey = NULL
    IF @v_derivedfromcontractind = 1
    BEGIN
      SELECT @v_rightskey = [dbo].qcontract_get_rightskey_from_contract_title(@v_bookkey,0,0,0)
      IF @v_rightskey > 0
        SELECT @v_territoryrightskey = territoryrightskey
        FROM territoryrights
        WHERE rightskey = @v_rightskey
    END
    ELSE
      SELECT @v_territoryrightskey = territoryrightskey
      FROM territoryrights
      WHERE bookkey = @v_bookkey

    IF @v_territoryrightskey > 0
    BEGIN
      SELECT @v_taqprojectkey = taqprojectkey, @v_currentterritorycode = currentterritorycode, @v_exclusivecode = exclusivecode,
        @v_singlecountrycode = singlecountrycode, @v_singlecountrygroupcode = singlecountrygroupcode, 
        @v_lastuserid = lastuserid, @v_lastmaintdate = lastmaintdate
      FROM territoryrights
      WHERE territoryrightskey = @v_territoryrightskey

      IF @v_currentterritorycode = 3 --selected countries
        INSERT @territoryctrybytable
          (territoryrightskey, rightskey, contractkey, bookkey, countrycode, forsaleind, contractexclusiveind, 
          nonexclusivesubrightsoldind, currentexclusiveind, exclusivesubrightsoldind, lastuserid, lastmaintdate)
        SELECT 
          territoryrightskey, rightskey, taqprojectkey AS contractkey, bookkey, countrycode, forsaleind, contractexclusiveind,
          nonexclusivesubrightsoldind, currentexclusiveind, exclusivesubrightsoldind, lastuserid, lastmaintdate
        FROM territoryrightcountries
        WHERE territoryrightskey = @v_territoryrightskey
        UNION
        SELECT @v_territoryrightskey, @v_rightskey, @v_taqprojectkey, @v_bookkey, g.datacode, 99, NULL, 
          NULL, NULL, NULL, @v_lastuserid, @v_lastmaintdate
        FROM gentables g
        WHERE g.tableid = 114 AND 
          NOT EXISTS (SELECT * FROM territoryrightcountries 
                      WHERE territoryrightcountries.countrycode = g.datacode AND territoryrightskey = @v_territoryrightskey)
      ELSE
        INSERT @territoryctrybytable
          (territoryrightskey, rightskey, contractkey, bookkey, countrycode, forsaleind, 
          contractexclusiveind, nonexclusivesubrightsoldind, currentexclusiveind, exclusivesubrightsoldind, lastuserid, lastmaintdate)        
        SELECT @v_territoryrightskey, @v_rightskey, @v_taqprojectkey, @v_bookkey, countrycode, forsaleind, 
          exclusivity, NULL, exclusivity, NULL, @v_lastuserid, @v_lastmaintdate
        FROM get_countries_from_territory(@v_currentterritorycode, @v_singlecountrycode, @v_singlecountrygroupcode, @v_exclusivecode)
    END

    FETCH bookdetail_cur INTO @v_bookkey, @v_derivedfromcontractind
  END

  CLOSE bookdetail_cur
  DEALLOCATE bookdetail_cur

  RETURN
END
go

GRANT SELECT ON dbo.qtitle_get_territorycountry_by_title TO PUBLIC
GO