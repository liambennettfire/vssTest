IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TF' AND name = 'qtitle_get_territorycountry_by_title')
  DROP FUNCTION qtitle_get_territorycountry_by_title
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
    @v_bookkey INT,  
    @v_derivedfromcontractind TINYINT,      
    @v_territoryrightskey INT,  
    @v_rightskey INT,  
    @v_taqprojectkey INT,  
    @v_currentterritorycode INT,  
    @v_exclusivecode INT,  
    @v_singlecountrycode INT,  
    @v_singlecountrygroupcode INT,  
    @v_lastuserid VARCHAR(30),  
    @v_lastmaintdate DATETIME,
	@v_coeditionopt TINYINT
    
  IF coalesce(@i_bookkey,0) = 0 BEGIN  
    return  
  END  
  
  SELECT @v_coeditionopt = optionvalue
  FROM clientoptions
  WHERE optionid = 125

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
    IF @v_derivedfromcontractind = 1 AND @v_coeditionopt = 1
    BEGIN
		INSERT INTO @territoryctrybytable 
		(
			bookkey,
			countryCode,
			forsaleInd,
			currentexclusiveind,
			contractExclusiveInd,
			lastUserID,
			lastMaintDate
		)
		SELECT DISTINCT
			b.bookkey,
			cai.countryCode,
			0 AS forSaleInd,
			0,
			0,
			cai.lastUserID,
			cai.lastMaintDate
		FROM 
			CoreWorkRightsNotAvailableInternal cai
		INNER JOIN taqprojecttitle tpt --Got to the work
			ON cai.workProjectKey = tpt.taqprojectkey
		INNER JOIN book b
			ON tpt.bookkey = b.bookkey
		INNER JOIN bookdetail bd
			ON b.bookkey = bd.bookkey
			AND bd.mediatypecode = CASE WHEN cai.mediaCode = 0 THEN bd.mediatypecode ELSE cai.mediaCode END
			AND bd.mediatypesubcode = CASE WHEN cai.formatCode = 0 THEN bd.mediatypesubcode ELSE cai.formatCode END
			AND bd.rightstypecode = CASE WHEN bd.rightstypecode > 0 THEN cai.rightstype ELSE bd.rightstypecode END
		WHERE b.bookkey = @v_bookkey

		INSERT INTO @territoryctrybytable 
		(
			bookkey,
			countryCode,
			forSaleInd,
			currentExclusiveInd,
			contractExclusiveInd,
			lastUserID,
			lastMaintDate
		)
		SELECT DISTINCT
			b.bookkey,
			cai.countryCode,
			1 AS forSaleInd,
			cai.exclusiveind,
			cai.exclusiveind,
			cai.lastUserID,
			cai.lastMaintDate
		FROM 
			CoreWorkRightsAvailableInternal cai
		INNER JOIN taqprojecttitle tpt --Got to the work
			ON cai.workProjectKey = tpt.taqprojectkey
		INNER JOIN book b
			ON tpt.bookkey = b.bookkey
		INNER JOIN bookdetail bd
			ON b.bookkey = bd.bookkey
			AND bd.mediatypecode = CASE WHEN cai.mediaCode = 0 THEN bd.mediatypecode ELSE cai.mediaCode END
			AND bd.mediatypesubcode = CASE WHEN cai.formatCode = 0 THEN bd.mediatypesubcode ELSE cai.formatCode END
			AND bd.rightstypecode = CASE WHEN bd.rightstypecode > 0 THEN cai.rightstype ELSE bd.rightstypecode END
		WHERE b.bookkey = @v_bookkey
		AND cai.countryCode not in (select countryCode from @territoryctrybytable where bookkey = @v_bookkey and forsaleind = 0)

		INSERT INTO @territoryctrybytable(bookkey,countryCode,forsaleind,contractexclusiveind,nonexclusivesubrightsoldind,currentexclusiveind,exclusivesubrightsoldind,lastuserid,lastmaintdate)
		SELECT
			tt.bookkey,
			cn.dataCode,
			tt.forSaleInd,
			tt.contractExclusiveInd,
			tt.nonExclusiveSubrightSoldInd,
			tt.currentExclusiveInd,
			tt.exclusiveSubRightSoldInd,
			tt.lastUserId,
			tt.lastMaintDate
		FROM
			@territoryctrybytable tt
		CROSS APPLY(SELECT gen.dataCode FROM gentables gen WHERE gen.tableID = 114 AND gen.deletestatus = 'N' and gen.dataCode not in (select countrycode from @territoryctrybytable)) cn
		WHERE tt.countrycode = 0

		DELETE @territoryctrybytable WHERE countryCode = 0

    END  
    ELSE BEGIN
		IF @v_derivedfromcontractind = 1
		BEGIN
			SELECT @v_rightskey = [dbo].qcontract_get_rightskey_from_contract_title(@v_bookkey,0,0,0)
			IF @v_rightskey > 0
			BEGIN
				SELECT @v_territoryrightskey = territoryrightskey
				FROM territoryrights
				WHERE rightskey = @v_rightskey
			END
		END
		ELSE BEGIN
			SELECT @v_territoryrightskey = territoryrightskey  
			FROM territoryrights  
			WHERE bookkey = @v_bookkey
		END
  
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
	END
  
    FETCH bookdetail_cur INTO @v_bookkey, @v_derivedfromcontractind  
  END
  
  CLOSE bookdetail_cur  
  DEALLOCATE bookdetail_cur  
  
  RETURN  
END  
GO

GRANT SELECT ON qtitle_get_territorycountry_by_title TO PUBLIC
GO
