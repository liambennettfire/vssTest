IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qpl_calc_ver_roy_adv')
  DROP PROCEDURE qpl_calc_ver_roy_adv
GO

CREATE PROCEDURE [dbo].[qpl_calc_ver_roy_adv] (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @o_result     FLOAT OUTPUT,
  @i_roleSumItemCode VARCHAR(255) = NULL,
  @i_allIncludedInd INT = NULL)
AS

/**************************************************************************************************************************
**  Name: qpl_calc_ver_roy_adv
**  Desc: P&L Item 65 - Version/Royalty Advance
**
**  Auth: Kate
**  Date: February 9, 2010
**************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**  01/09/2017  Josh G    Case 42565 Royalty Advances and Rates by contributor P&L Procedure changes 
**************************************************************************************************************************/

DECLARE
  @v_royalty_advance  FLOAT

BEGIN
 
	IF (@i_allIncludedInd IS NULL AND @i_roleSumItemCode IS NULL)
	BEGIN
		SELECT @v_royalty_advance = SUM(amount) 
		FROM taqversionroyaltyadvance 
		WHERE taqprojectkey = @i_projectkey AND
		plstagecode = @i_plstage AND
		taqversionkey = @i_plversion
	
		SET @o_result = @v_royalty_advance
	END
	ELSE
	BEGIN
		--Load all roles into a table to use later
		DECLARE @roleCodes TABLE
		(
			dataCode INT
		)

		INSERT INTO @roleCodes
		SELECT 
			xt.dataCode
		FROM 
			gentables_ext xt
		WHERE 
			xt.tableID = 285
		AND xt.gentext1 = @i_roleSumItemCode

		--If @i_allIncludedInd = 1 also include all rows with role = 0
		--and roles with NO summaryItemCode
		--if null then we want everything possible
		IF (@i_allIncludedInd = 1)
		BEGIN
			INSERT INTO @roleCodes
			VALUES (0)
			
			INSERT INTO @roleCodes
			SELECT 
				xt.dataCode
			FROM 
				gentables_ext xt
			WHERE 
				xt.tableID = 285
			AND xt.gentext1 IS NULL
			EXCEPT 
			SELECT dataCode FROM @roleCodes
			
		END

		SELECT 
			@v_royalty_advance = SUM(amount) 
		FROM 
			taqversionroyaltyadvance 
		WHERE 
			taqprojectkey = @i_projectkey 
		AND plstagecode = @i_plstage 
		AND taqversionkey = @i_plversion
		AND EXISTS(SELECT 1 FROM @roleCodes rc
					WHERE taqversionroyaltyadvance.roletypeCode = rc.dataCode)	
    
		SET @o_result = @v_royalty_advance
  END
  
END
GO

GRANT EXEC ON qpl_calc_ver_roy_adv TO PUBLIC
GO