if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].get_territorycounty_by_formatlanguage') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].get_territorycounty_by_formatlanguage
GO

CREATE FUNCTION dbo.get_territorycounty_by_formatlanguage(@i_taqprojectkey INT)

RETURNS @territoryctrybyformatlang TABLE(
  territoryrightskey INT,
  taqprojectkey INT,
  rightskey INT,
  mediacode INT,
  formatcode INT,
  languagecode INT,
  countrycode INT,
  forsaleind	INT,
  contractexclusiveind INT,
  nonexclusivesubrightsoldind	INT,
  currentexclusiveind	INT,
  exclusivesubrightsoldind	INT,
  lastuserid	VARCHAR(30),
  lastmaintdate	DATETIME		
)
AS

BEGIN
  DECLARE	@v_territoryrightskey	integer,
    @v_taqprojectkey	integer,
    @v_rightskey	integer,
    @v_taqversionkey	integer,
    @v_mediacode	integer,
    @v_formatcode	integer,
    @v_languagecode	integer, 
    @v_countrycode	integer, 
    @v_forsaleind	integer,
    @v_contractexclusiveind integer,
    @v_nonexclusivesubrightsoldind	integer,
    @v_currentexclusiveind	integer,
    @v_exclusivesubrightsoldind	integer, 
    @v_lastuserid varchar(30),
    @v_lastmaintdate	datetime,
    @v_count1 INT,
    @v_count2 INT,
    @v_rightspermissioncode INT,
    @v_rightslanguagetypecode INT,
    @v_currentterritorycode INT,
    @v_exclusivecode  INT,
    @v_singlecountrycode  INT,
    @v_singlecountrygroupcode INT     
		
	IF coalesce(@i_taqprojectkey,0) = 0 BEGIN
	  return
	END
				
  DECLARE territoryrights_cur CURSOR fast_forward FOR
    SELECT DISTINCT r.territoryrightskey, u.rightskey, u.rightspermissioncode, u.rightslanguagetypecode,
    r.currentterritorycode, r.exclusivecode, u.taqprojectkey, r.singlecountrycode, r.singlecountrygroupcode
    FROM territoryrights r,
      taqprojectrights u 
      LEFT OUTER JOIN territoryrightcountries y ON u.rightskey = y.rightskey
    WHERE r.rightskey = u.rightskey AND
      u.rightspermissioncode IN (SELECT datacode FROM gentables WHERE tableid = 463 AND (gen1ind = 0 OR gen1ind IS NULL)) AND
      u.taqprojectkey = @i_taqprojectkey
				
  OPEN territoryrights_cur
		
  FETCH FROM territoryrights_cur 
  INTO @v_territoryrightskey, @v_rightskey, @v_rightspermissioncode, @v_rightslanguagetypecode,
    @v_currentterritorycode, @v_exclusivecode, @v_taqprojectkey, @v_singlecountrycode, @v_singlecountrygroupcode

  WHILE @@fetch_status = 0
  BEGIN

    DECLARE taqprojectrightsformat_cur CURSOR fast_forward FOR
      SELECT mediacode, formatcode
      FROM taqprojectrightsformat
      WHERE rightskey = @v_rightskey

    OPEN taqprojectrightsformat_cur

    FETCH taqprojectrightsformat_cur INTO @v_mediacode, @v_formatcode

    WHILE @@fetch_status = 0 
    BEGIN
     
      DECLARE language_cur CURSOR fast_forward FOR
        SELECT languagecode 
        FROM contractslanguage_view 
        WHERE rightskey = @v_rightskey

      OPEN language_cur
      
      FETCH language_cur INTO @v_languagecode

      WHILE @@fetch_status = 0
      BEGIN
        IF @v_currentterritorycode = 3 OR @v_exclusivecode = 3 BEGIN  --Selected Countries
          DECLARE territoryrightcountries_cur CURSOR fast_forward FOR
            SELECT countrycode, forsaleind, contractexclusiveind, nonexclusivesubrightsoldind, 
              currentexclusiveind, exclusivesubrightsoldind, lastuserid, lastmaintdate
            FROM territoryrightcountries
            WHERE territoryrightskey = @v_territoryrightskey
              AND rightskey = @v_rightskey 

          OPEN territoryrightcountries_cur

          FETCH territoryrightcountries_cur 
          INTO @v_countrycode, @v_forsaleind, @v_contractexclusiveind, @v_nonexclusivesubrightsoldind,
            @v_currentexclusiveind, @v_exclusivesubrightsoldind, @v_lastuserid, @v_lastmaintdate

          WHILE (@@FETCH_STATUS = 0)
          BEGIN

            INSERT INTO @territoryctrybyformatlang
              (territoryrightskey, taqprojectkey, rightskey, mediacode, formatcode, languagecode,
              countrycode, forsaleind, contractexclusiveind, nonexclusivesubrightsoldind, currentexclusiveind,                     
              exclusivesubrightsoldind, lastuserid, lastmaintdate)
            VALUES
              (@v_territoryrightskey, @v_taqprojectkey, @v_rightskey, @v_mediacode, @v_formatcode, @v_languagecode,
              @v_countrycode, @v_forsaleind, @v_contractexclusiveind, @v_nonexclusivesubrightsoldind, @v_currentexclusiveind,                     
              @v_exclusivesubrightsoldind, @v_lastuserid, @v_lastmaintdate)

            FETCH territoryrightcountries_cur 
            INTO @v_countrycode, @v_forsaleind, @v_contractexclusiveind, @v_nonexclusivesubrightsoldind,
              @v_currentexclusiveind, @v_exclusivesubrightsoldind, @v_lastuserid, @v_lastmaintdate
          END
          
          CLOSE territoryrightcountries_cur
          DEALLOCATE territoryrightcountries_cur
        END --Selected Countries          
        ELSE BEGIN

          DECLARE countries_cur CURSOR fast_forward FOR
            SELECT countrycode, forsaleind, exclusivity
            FROM dbo.get_countries_from_territory(@v_currentterritorycode, @v_singlecountrycode, @v_singlecountrygroupcode, @v_exclusivecode)

          OPEN countries_cur

          FETCH countries_cur INTO @v_countrycode, @v_forsaleind, @v_contractexclusiveind

          WHILE (@@FETCH_STATUS = 0)
          BEGIN

            INSERT INTO @territoryctrybyformatlang
              (territoryrightskey, taqprojectkey, rightskey, mediacode, formatcode, languagecode,
              countrycode, forsaleind, contractexclusiveind, nonexclusivesubrightsoldind, currentexclusiveind,                     
              exclusivesubrightsoldind, lastuserid, lastmaintdate)
            VALUES
              (@v_territoryrightskey, @v_taqprojectkey, @v_rightskey, @v_mediacode, @v_formatcode, @v_languagecode,
              @v_countrycode, @v_forsaleind, @v_contractexclusiveind, @v_nonexclusivesubrightsoldind, @v_contractexclusiveind,                     
              @v_exclusivesubrightsoldind, @v_lastuserid, @v_lastmaintdate)

            FETCH countries_cur INTO @v_countrycode, @v_forsaleind, @v_contractexclusiveind
          END
          
          CLOSE countries_cur
          DEALLOCATE countries_cur
        END

        FETCH language_cur INTO @v_languagecode
      END
      
      CLOSE language_cur
      DEALLOCATE language_cur 

      FETCH taqprojectrightsformat_cur INTO @v_mediacode, @v_formatcode
    END 
    
    CLOSE taqprojectrightsformat_cur
    DEALLOCATE taqprojectrightsformat_cur

    FETCH FROM territoryrights_cur 
    INTO @v_territoryrightskey, @v_rightskey, @v_rightspermissioncode, @v_rightslanguagetypecode,
      @v_currentterritorycode, @v_exclusivecode, @v_taqprojectkey, @v_singlecountrycode, @v_singlecountrygroupcode
  END

  CLOSE territoryrights_cur
  DEALLOCATE territoryrights_cur

  RETURN
END