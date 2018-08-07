/*
	Project: 1991 Quarto Publishing Group : Quarto Co-editions 01 Analysis, Config, Dev, QA
	Case: 42880
	Name: Contract verification procedure
*/

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcontract_coEdition_verification')
  DROP PROCEDURE qcontract_coEdition_verification
GO

CREATE PROCEDURE dbo.qcontract_coEdition_verification
(
	@i_contractProjectID INT,
	@i_verificationtypecode INT,
	@i_username VARCHAR(50),
	@o_result_code INT OUTPUT,
	@o_result_desc VARCHAR(MAX) OUTPUT
)
AS

/****************************************************************************************************************************************
**  Name: qcontract_coEdition_verification
**  Desc: Contract verification procedure
**
**  Summary: 
**	When the Co-edition Contract is set to an active status (meaning it is considered signed and live), a verification will be done to 
**	ensure the rights are available. 
**	The system needs to verify a number of things before the Contract can be set to signed status. 
**	1. Client must be approved. This will be stored in a contact misc item that needs to be setup. It will be a checkbox for 
**		"Approved for Contracts". If this is false (0), the verification should fail. 
**	2. A Master Contract (class qsicode = 64) must be related to the contract
**	3. Rights must exist as a valid subright that is available 
**	4. For each right that is a production included right (gen1ind = 1 on tableid 157 for rights type), a Work/Title/Printing must be 
**		related to this right on taqprojectrights
**
**  CASE: 42880
**
**  Paramaters:
**		@o_result_code output param 
**		@o_result_desc output param
**		@i_contractProjectID input param for the contract to verify
**
**	o_result_code returns 0 for an error, and 1 for success
**	the C# will not work properly otherwise.
**
**  Auth: Joshua Granville
**  Date: 22 February 2017
*****************************************************************************************************************************************
**  Date        Who      Change
**  -------     ---      ---------------------------------------------------------------------------------------------------------------
**  05/17/2017  Uday     Case 45101
**  07/20/2017  Susan	 Case 44581 - Once the project verification passes it will never switch back to failed.  Fixed the order in 
**                       which the verifications run so the the customer approval and master contract get done for all.  Also, fixed 
**                       customer approval so it checks the value of the misc item if it finds it.  The master contract failure was
**                       being reset to passed later in the procedure so this was fixed as well.
**  12/11/2017  Colman   Case 48528 Rename includeproduction column to relatetitleprtg
**  01/11/2018  Colman   Case 49135 Change misc item that determines client approval
**  05/17/2018  Tolga	 Bug fixes. Routine assigns a "passed" status to begin with. It should assign "ready for verification". 
						 Also, add functionality to bypass "Master Contract" requirement if the co-edition project type is "Customer's Own Contract"
******************************************************************************************************************************************/

BEGIN

DECLARE
	@v_relationShipCodeCoEditionCont INT,
	@v_relationShipCodeMasterCont INT,
	@v_clientRoleCode INT,
	@v_errorMessage VARCHAR(MAX),
	@v_passFail VARCHAR(20),
	@v_passFailReason VARCHAR(255),
	@v_workProjectType INT,
	@v_contractProjectType INT,
	@v_errorCounter INT,
	@v_JobTypeCode INT,
	@v_failedCode INT,
	@v_passedCode INT,
	@v_readyForVerification INT,
	@v_nextkey INT,
	@v_messageStarted INT,
	@v_messageCompleted INT,
	@v_messageError INT,
	@v_messageWarning INT,
	@v_informational INT,
	@v_misMatchCount INT,
	@v_rightCount INT,
	@v_errorMessageDetail VARCHAR(MAX),
	@v_TurnOnRightsCalculus INT,
	@v_approvedind INT, 
	--@v_datacode_customersowncontract INT, 
	@v_projecttypecode INT 

SET @v_clientRoleCode = (SELECT dataCode FROM gentables WHERE tableID = 285 AND qsiCode = 28)
SET @v_relationShipCodeCoEditionCont = (SELECT dataCode from gentables where tableId = 582 AND qsicode = 36) 
SET @v_relationShipCodeMasterCont = (SELECT dataCode from gentables where tableId = 582 AND qsicode = 37) 
SET @v_workProjectType = (SELECT dataCode from gentables where tableId = 582 AND qsiCode = 38) --Work Relationship Type
SET @v_contractProjectType = (SELECT dataCode from gentables where tableId = 582 AND qsiCode = 39) --Contract Relationship Type
SET @v_JobTypeCode = (SELECT dataCode from gentables WHERE tableID = 628 AND qsicode = 2)
SET @v_failedCode = (SELECT datacode FROM gentables WHERE tableid = 513 AND qsicode = 2)
SET @v_passedCode = (SELECT datacode FROM gentables WHERE tableid = 513 AND qsicode = 3)
SET @v_readyForVerification = (SELECT datacode FROM gentables WHERE tableid = 513 AND qsicode = 1)
SET @v_messageStarted = (select dataCode from gentables WHERE tableid = 539 and qsiCode = 1)
SET @v_messageCompleted = (select dataCode from gentables WHERE tableid = 539 and qsiCode = 6)
SET @v_messageError = (select dataCode from gentables WHERE tableid = 539 and qsiCode = 2)
SET @v_messageWarning = (select dataCode from gentables WHERE tableid = 539 and qsiCode = 3)
SET @v_informational = (select dataCode from gentables WHERE tableid = 539 and qsiCode = 4)
SET @v_TurnOnRightsCalculus = (SELECT COALESCE(optionvalue, 0) FROM clientoptions WHERE optionid = 122)
 
SET @v_passFail = ''
SET @o_result_code = 1
SET @o_result_desc = ''
SET @v_errorCounter = 0




	--Insert verification row
	IF NOT EXISTS(SELECT 1 FROM taqprojectverification 
				  WHERE taqProjectKey = @i_contractProjectID
				  AND verificationtypecode = @v_JobTypeCode)
	BEGIN
	INSERT INTO taqprojectverification
	(
		taqprojectkey,
		verificationtypecode,
		verificationstatuscode,
		lastuserid,
		lastmaintdate
	)
	VALUES
	(
		@i_contractProjectID,
		@v_JobTypeCode,
		--CASE WHEN @o_result_desc = 0 THEN @v_failedCode ELSE @v_passedCode END,
		@v_readyForVerification,
		@i_username,
		GETDATE()
	)
	END

	--Remove old messages
	DELETE taqprojectverificationmessage
	where taqprojectkey = @i_contractProjectID
	and verificationtypecode = @v_JobTypeCode



	--Client must be approved. This is stored in a contact misc item, gentables dropdown: 'Account Status' 
  -- At least one client must have a status of 1 (Approved)
	IF NOT EXISTS (SELECT  1 
					FROM 
						taqProjectContactRole cr
					INNER JOIN taqProjectContact c
						ON cr.taqProjectContactKey = c.taqProjectContactKey
					INNER JOIN globalContactMisc m
						ON c.globalContactKey = m.globalContactKey
					WHERE EXISTS(SELECT 1 FROM bookMiscItems bi
									 WHERE m.misckey = bi.misckey
									 AND bi.externalid = 'AccountStatus' 
									 AND ISNULL (m.longvalue,0) = 1) -- approved
					AND	cr.taqProjectKey = @i_contractProjectID
					AND cr.rolecode = @v_clientRoleCode)
	BEGIN
		SET @o_result_code = 0
		SET @v_errorMessage = 'The contract is not related to an approved client'
		
		--messages
		EXEC get_next_key @i_username, @v_nextkey OUT

		INSERT INTO taqprojectverificationmessage
		(
			messagekey,
			taqprojectkey,
			verificationtypecode,
			messagetypecode,
			message,
			lastuserid,
			lastmaintdate
		)
		VALUES
		(
			@v_nextkey,
			@i_contractProjectID,
			@v_JobTypeCode,
			@v_messageError,
			@v_errorMessage,
			@i_username,
			GETDATE()
		)

		--popup
		SET @v_errorCounter = @v_errorCounter + 1
		SET @o_result_desc = @o_result_desc + CAST(@v_errorCounter AS VARCHAR(50)) + ') ' + @v_errorMessage + '\r\n'
	END	



	--Make sure there is a master contract linked 
	-- Quarto specific rule, do not require master contract linking it the project type is customer's own contract 
	-- hardcoding the datacode for Quarto 
	--SET @v_datacode_customersowncontract = 114 

	if not exists (Select 1 from taqproject where taqprojectkey = @i_contractProjectID and taqprojecttype = 114)
	BEGIN

			SET @v_passFail = 'Fail'
			IF EXISTS(SELECT 1 FROM taqprojectrelationship rel
						WHERE rel.taqprojectkey1 = @i_contractProjectID
						AND rel.relationshipcode1 = @v_relationShipCodeCoEditionCont
						AND rel.relationshipcode2 = @v_relationShipCodeMasterCont)
			BEGIN 
				SET @v_passFail = 'Pass'
			END
			ELSE
			IF EXISTS(SELECT 1 FROM taqprojectrelationship rel
						WHERE rel.taqprojectkey2 = @i_contractProjectID
						AND rel.relationshipcode2 = @v_relationShipCodeCoEditionCont
						AND rel.relationshipcode1 = @v_relationShipCodeMasterCont)
				BEGIN
					SET @v_passFail = 'Pass'
				END

			IF @v_passFail = 'Fail'
			BEGIN
				SET @o_result_code = 0
				SET @v_errorMessage = 'The CoEdition contract is not linked to a Master Contract'
				--messages
				EXEC get_next_key @i_username, @v_nextkey OUT

				INSERT INTO taqprojectverificationmessage
				(
					messagekey,
					taqprojectkey,
					verificationtypecode,
					messagetypecode,
					message,
					lastuserid,
					lastmaintdate
				)
				VALUES
				(
					@v_nextkey,
					@i_contractProjectID,
					@v_JobTypeCode,
					@v_messageError,
					@v_errorMessage,
					@i_username,
					GETDATE()
				)

				--popup
				SET @v_errorCounter = @v_errorCounter + 1
				SET @o_result_desc = @o_result_desc + CAST(@v_errorCounter AS VARCHAR(50)) + ') ' + @v_errorMessage + '\r\n'
			END

	END

	--See if we need to verify the contract at all before setting it to active
	--It must have a rightsTypeCode with a gen1ind = 1
	-- Commenting out this section 05/18/19 (Tolga)
	-- 1- It is not setting the error parameter and immediately returning out of the procedure which is wrong 
	-- 2- We are checking on relatetitleprtg below as well. 
	--IF NOT EXISTS(SELECT 1 FROM taqProjectRights tr
	--			WHERE tr.taqprojectkey = @i_contractProjectID
	--			AND tr.relatetitleprtg = 1)
	--BEGIN
	--	UPDATE taqprojectverification 
	--	SET verificationstatuscode = (CASE WHEN @o_result_code = 0 THEN @v_failedCode ELSE @v_passedCode END)
	--	WHERE taqprojectkey = @i_contractProjectID
	--	AND verificationtypecode = @v_JobTypeCode
	--	RETURN
	--END
							
	IF @v_TurnOnRightsCalculus = 0 
	BEGIN
	--messages
		EXEC get_next_key @i_username, @v_nextkey OUT
		SET @v_errorMessage = 'Rights Calculus is not turned on, rights could not be verified'

		INSERT INTO taqprojectverificationmessage
		(
			messagekey,
			taqprojectkey,
			verificationtypecode,
			messagetypecode,
			message,
			lastuserid,
			lastmaintdate
		)
		VALUES
		(
			@v_nextkey,
			@i_contractProjectID,
			@v_JobTypeCode,
			@v_informational,  --Informational Message
			@v_errorMessage,
			@i_username,
			GETDATE()
		)
			--Un comment if you want the informational message in the popup 
			--SET @v_errorCounter = @v_errorCounter + 1
			--SET @o_result_desc = CAST(@v_errorCounter AS VARCHAR(50)) + ') ' + @v_errorMessage + '\r\n'			
	END
	ELSE BEGIN
		--Rights must exist as a valid subright that is available 
		--find the works associated with the right
		SELECT 
			rel.taqprojectkey1 AS workID,
			rel.taqprojectkey2 AS contractID, --Works linked to contracts
			tr.rightstypecode,
			tp.rightsImpactCode
		INTO
			#qcontract_coEdition_verification_workContracts
		FROM 
			taqprojectrelationship rel
		INNER JOIN taqProjectRights tr
			ON rel.taqprojectkey2 = tr.taqprojectkey
		INNER JOIN taqproject tp
			ON tr.taqprojectkey = tp.taqprojectkey
		WHERE 
			rel.relationshipcode1 = @v_workProjectType
		AND rel.relationshipcode2 = @v_contractProjectType
		AND rel.taqprojectkey2 = @i_contractProjectID
		UNION
		SELECT 
			rel.taqprojectkey2,
			rel.taqprojectkey1, --Contracts linked to works
			tr.rightstypecode,
			tp.rightsImpactCode
		FROM 
			taqprojectrelationship rel
		INNER JOIN taqProjectRights tr
			ON rel.taqprojectkey1 = tr.taqprojectkey
		INNER JOIN taqproject tp
			ON tr.taqprojectkey = tp.taqprojectkey
		WHERE 
			rel.relationshipcode2 = @v_workProjectType
		AND rel.relationshipcode1 = @v_contractProjectType
		AND rel.taqprojectkey1 = @i_contractProjectID

		--Find the rights records
		SELECT 
			wc.workID,
			wc.contractID,
			tr.rightsKey,
			tr.rightsTypeCode,
			tr.rightsLanguageTypeCode,
			tr.subrightssalecode,
			wc.rightsImpactCode
		INTO
			#fbt_rightsCalculus_base
		FROM	
			#qcontract_coEdition_verification_workContracts wc
		INNER JOIN taqprojectrights tr	--get all rightsKeys 
			ON wc.contractID = tr.taqprojectkey

		SELECT
			b.workID,
			b.contractID,
			b.rightsKey,
			b.rightsTypeCode,
			ISNULL(lang.languageCode,0) AS languageCode
		INTO
			#fbt_rightsCalculus_lang
		FROM
			#fbt_rightsCalculus_base b
		LEFT JOIN taqprojectrightslanguage lang
			ON b.rightsKey = lang.rightskey
			AND ISNULL(lang.excludeind,0) = 0
		WHERE 
			lang.languageCode IS NOT NULL OR ISNULL(b.rightslanguagetypecode,0) = 1
		UNION
		SELECT
			b.workID,
			b.contractID,
			b.rightsKey,
			b.rightsTypeCode,
			g.dataCode AS languageCode
		FROM
			#fbt_rightsCalculus_base b
		INNER JOIN taqprojectrightslanguage lang
			ON b.rightsKey = lang.rightskey
			AND ISNULL(lang.excludeind,0) != 0
		CROSS JOIN(SELECT gen.dataCode FROM gentables gen WHERE gen.tableID = 318 AND gen.deleteStatus = 'N') g
		WHERE g.datacode != lang.languagecode

		--Get all formats
		SELECT
			b.workID,
			b.contractID,
			b.rightsKey,
			b.rightsTypeCode,
			form.mediacode,
			form.formatcode
		INTO
			#fbt_rightsCalculus_form
		FROM
			#fbt_rightsCalculus_base b
		INNER JOIN taqprojectrightsformat form
			ON b.rightsKey = form.rightskey

		SELECT
			b.workID,
			b.contractID,
			b.rightsKey,
			b.rightsTypeCode,
			co.countrycode,
			co.currentexclusiveind AS currentexclusiveind,
			co.forsaleind,
			cr.updatewithsubrightsind,
			co.exclusivesubrightsoldind,
			co.nonexclusivesubrightsoldind,
			1 AS includeForSubrightsSelection
		INTO
			#fbt_rightsCalculus_country
		FROM
			#fbt_rightsCalculus_base b
		INNER JOIN territoryrights cr
			ON b.rightsKey = cr.rightskey
			AND b.contractID = cr.taqprojectkey
		INNER JOIN territoryrightcountries co
			ON cr.territoryrightskey = co.territoryrightskey
			AND cr.rightskey = co.rightskey
		WHERE 
			cr.currentterritorycode IN (3,0)
		UNION
		--specific country (2)
		SELECT
			b.workID,
			b.contractID,
			b.rightsKey,
			b.rightsTypeCode,
			cj.dataCode,
			cr.exclusiveCode,
			CASE WHEN cj.datacode = cr.singlecountrycode THEN 1 ELSE 0 END forsaleind,
			cr.updatewithsubrightsind,
			0 AS exclusivesubrightsoldind,
			0 AS nonexclusivesubrightsoldind,
			CASE WHEN cj.datacode = cr.singlecountrycode THEN 1 ELSE 0 END includeForSubrightsSelection
		FROM
			#fbt_rightsCalculus_base b
		INNER JOIN territoryrights cr
			ON b.rightsKey = cr.rightskey
			AND b.contractID = cr.taqprojectkey
		CROSS JOIN (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 114 AND gen.deletestatus = 'N' ) cj
		WHERE 
			cr.currentterritorycode = 2
		UNION
		--all countries
		SELECT
			b.workID,
			b.contractID,
			b.rightsKey,
			b.rightsTypeCode,
			0 AS countryCode,
			cr.exclusiveCode,
			1 AS forsaleind, 
			cr.updatewithsubrightsind,
			0 AS exclusivesubrightsoldind,
			0 AS nonexclusivesubrightsoldind,
			1 AS includeForSubrightsSelection
		FROM
			#fbt_rightsCalculus_base b
		INNER JOIN territoryrights cr
			ON b.rightsKey = cr.rightskey
			AND b.contractID = cr.taqprojectkey
		WHERE 
			cr.currentterritorycode = 1
		--All countries except...5 singleCountryCode
		UNION
		SELECT
			b.workID,
			b.contractID,
			b.rightsKey,
			b.rightsTypeCode,
			cj.dataCode AS countryCode,
			cr.exclusiveCode,
			CASE WHEN cj.datacode = cr.singlecountrycode THEN 0 ELSE 1 END forsaleind, 
			cr.updatewithsubrightsind,
			0 AS exclusivesubrightsoldind,
			0 AS nonexclusivesubrightsoldind,
			CASE WHEN cj.datacode = cr.singlecountrycode THEN 1 ELSE 0 END includeForSubrightsSelection
		FROM
			#fbt_rightsCalculus_base b
		INNER JOIN territoryrights cr
			ON b.rightsKey = cr.rightskey
			AND b.contractID = cr.taqprojectkey
		CROSS JOIN (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 114 AND gen.deletestatus = 'N') cj
		WHERE 
			cr.currentterritorycode = 5
		--4 SingleCountryGroupCode
		UNION
		SELECT
			b.workID,
			b.contractID,
			b.rightsKey,
			b.rightsTypeCode,
			cj.dataCode AS countryCode,
			cr.exclusiveCode,
			CASE WHEN cj.datacode = r.code2 THEN 1 ELSE 0 END forsaleind,
			cr.updatewithsubrightsind,
			0 AS exclusivesubrightsoldind,
			0 AS nonexclusivesubrightsoldind,
			CASE WHEN cj.datacode = r.code2 THEN 1 ELSE 0 END includeForSubrightsSelection
		FROM
			#fbt_rightsCalculus_base b
		INNER JOIN territoryrights cr
			ON b.rightsKey = cr.rightskey
			AND b.contractID = cr.taqprojectkey
		CROSS JOIN (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 114 AND gen.deletestatus = 'N') cj
		LEFT JOIN gentablesrelationshipdetail r
			ON r.code1 = cr.singlecountrygroupcode
			AND r.gentablesrelationshipkey = 23
			AND cj.datacode = r.code2
		WHERE 
			cr.currentterritorycode = 4
		--All except singleCountryGroupCode (6)
		UNION
		SELECT
			b.workID,
			b.contractID,
			b.rightsKey,
			b.rightsTypeCode,
			cj.datacode AS countryCode,
			cr.exclusiveCode,
			CASE WHEN r.code2 IS NOT NULL THEN 0 ELSE 1 END forsaleind, 
			cr.updatewithsubrightsind,
			0 AS exclusivesubrightsoldind,
			0 AS nonexclusivesubrightsoldind,
			CASE WHEN r.code2 IS NOT NULL THEN 0 ELSE 1 END includeForSubrightsSelection 
		FROM
			#fbt_rightsCalculus_base b
		INNER JOIN territoryrights cr
			ON b.rightsKey = cr.rightskey
			AND b.contractID = cr.taqprojectkey
		CROSS JOIN (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 114 AND gen.deletestatus = 'N') cj
		LEFT JOIN gentablesrelationshipdetail r
			ON r.code1 = cr.singlecountrygroupcode
			AND r.gentablesrelationshipkey = 23
			AND r.code2 = cj.datacode
		WHERE
			cr.currentterritorycode = 6

		SELECT
			b.workID,
			b.contractID,
			b.rightsKey,
			b.rightsTypeCode,
			lang.languageCode AS languageCode,
			ISNULL(form.mediacode,0) AS mediaCode,
			form.formatcode AS formatCode,
			cn.countryCode AS countryCode,
			b.subrightssalecode
		INTO
			#fbt_rightsCalculus_insupd
		FROM
			#fbt_rightsCalculus_base b
		INNER JOIN #fbt_rightsCalculus_lang lang
			ON b.workID = lang.workID
			AND b.contractID = lang.contractID
			AND b.rightskey = lang.rightskey
		INNER JOIN #fbt_rightsCalculus_form form
			ON b.workID = form.workID
			AND b.contractID = form.contractID
			AND b.rightskey = form.rightskey
		INNER JOIN #fbt_rightsCalculus_country cn
			ON b.workID = cn.workID
			AND b.contractID = cn.contractID
			AND b.rightskey = cn.rightskey
		WHERE 
			b.rightsImpactCode = 2
		OR (b.rightsImpactCode = 1 AND cn.updatewithsubrightsind = 1)

		INSERT INTO #fbt_rightsCalculus_insupd(workId,contractId,rightsKey,rightsTypeCode,languageCode,mediaCode,FormatCode,countryCode)
		SELECT
			ins.workId,ins.contractId,ins.rightsKey,ins.rightsTypeCode,ins.languageCode,ins.mediaCode,ins.FormatCode,cj.datacode
		FROM
			#fbt_rightsCalculus_insupd ins
		CROSS JOIN (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 114 AND gen.deletestatus = 'N' ) cj
		WHERE
			ins.countryCode = 0

		INSERT INTO #fbt_rightsCalculus_insupd(workId,contractId,rightsKey,rightsTypeCode,mediaCode,FormatCode,countryCode,languageCode)
		SELECT
			ins.workId,ins.contractId,ins.rightsKey,ins.rightsTypeCode,ins.mediaCode,ins.FormatCode,ins.countryCode,g.datacode
		FROM
			#fbt_rightsCalculus_insupd ins
		CROSS JOIN(SELECT gen.dataCode FROM gentables gen WHERE gen.tableID = 318 AND gen.deleteStatus = 'N') g
		WHERE
			ins.languageCode = 0

		--Remove the Zero rows
		DELETE ins 
		FROM #fbt_rightsCalculus_insupd ins
		WHERE EXISTS(SELECT 1 FROM #fbt_rightsCalculus_insupd t
					WHERE ins.workID = t.workID 
					AND ins.contractID = t.contractID
					AND ((ins.countryCode = 0 AND t.countryCode != 0)
						OR (ins.languageCode = 0 AND t.languageCode != 0)))
		AND (ins.countryCode = 0 OR ins.languageCode = 0)


		SELECT t.*
		INTO #countOfMisMatches
		FROM #fbt_rightsCalculus_insupd t
		WHERE NOT EXISTS(SELECT 1 FROM CoreWorkRightsAvailableSubrights cs
						WHERE t.workID = cs.workProjectKey
						AND t.rightstypecode = cs.rightsType
						AND t.mediaCode = cs.mediaCode
						AND ((t.formatCode = (CASE WHEN cs.formatCode = 0 THEN t.formatCode ELSE cs.formatCode END)
							OR (cs.formatCode = (CASE WHEN t.formatCode = 0 THEN cs.formatCode ELSE t.formatCode END))
							OR cs.formatCode = t.formatCode))
						AND t.languageCode = cs.languageCode
						AND t.countryCode = cs.countryCode)

		SET @v_misMatchCount = @@ROWCOUNT
		SET @v_rightCount = (SELECT COUNT(1) FROM #fbt_rightsCalculus_insupd)

		IF (ISNULL(@v_rightCount,0) = 0)
		BEGIN
			SET @o_result_code = 0
			SET @v_errorMessage = 'There are no available subrights on this contract'

			EXEC get_next_key @i_username, @v_nextkey OUT

			INSERT INTO taqprojectverificationmessage
			(
				messagekey,
				taqprojectkey,
				verificationtypecode,
				messagetypecode,
				message,
				lastuserid,
				lastmaintdate
			)
			VALUES
			(
				@v_nextkey,
				@i_contractProjectID,
				@v_JobTypeCode,
				@v_messageError,
				@v_errorMessage,
				@i_username,
				GETDATE()
			)
					
			SET @v_errorCounter = @v_errorCounter + 1
			SET @o_result_desc = CAST(@v_errorCounter AS VARCHAR(50)) + ') ' + @v_errorMessage + '\r\n'
		END


		IF (ISNULL(@v_misMatchCount,0) > 0 AND ISNULL(@v_rightCount,0) != 0)
		BEGIN
			SET @o_result_code = 0
			SET @v_errorMessage = 'There are unavailable subrights on this contract'

			--Grab all the workKeys and rightTypes
			DECLARE @msg_workKey INT, @msg_rightTypeCode INT, @msg_rightType VARCHAR(255)

			DECLARE msgcsr CURSOR FAST_FORWARD FOR 
			SELECT DISTINCT workId,rightsTypeCode
			FROM #countOfMisMatches

			OPEN msgcsr 

			FETCH msgcsr INTO @msg_workKey, @msg_rightTypeCode

			WHILE (@@FETCH_STATUS=0)
			BEGIN
			--messages
				EXEC get_next_key @i_username, @v_nextkey OUT

				SET @msg_rightType = (SELECT TOP 1 dataDesc FROM gentables gen WHERE gen.tableID = 157 AND gen.dataCode = @msg_rightTypeCode)
				SET @v_errorMessageDetail = @v_errorMessage + ' Workkey: ' + CAST(@msg_workKey AS VARCHAR(50)) + ' Right Type: ' + @msg_rightType
				INSERT INTO taqprojectverificationmessage
				(
					messagekey,
					taqprojectkey,
					verificationtypecode,
					messagetypecode,
					message,
					lastuserid,
					lastmaintdate
				)
				VALUES
				(
					@v_nextkey,
					@i_contractProjectID,
					@v_JobTypeCode,
					@v_messageError,
					@v_errorMessageDetail,
					@i_username,
					GETDATE()
				)
			FETCH msgcsr INTO @msg_workKey, @msg_rightTypeCode
			END
			CLOSE msgcsr
			DEALLOCATE msgcsr

			--popup
			SET @v_errorCounter = @v_errorCounter + 1
			SET @o_result_desc = CAST(@v_errorCounter AS VARCHAR(50)) + ') ' + @v_errorMessage + '\r\n'
		END
	END  --END Check Rights

	

	--Must have a link to a work / productionbookkey / printing
	IF NOT EXISTS(SELECT 1 FROM taqProjectRights rt
					WHERE rt.taqprojectkey = @i_contractProjectID
					AND NULLIF(rt.taqprojectprintingkey,0) IS NOT NULL
					AND NULLIF(rt.workkey,0) IS NOT NULL
					AND NULLIF(rt.productionbookkey,0) IS NOT NULL
					AND NULLIF(rt.relatetitleprtg,0) = 1 )
	BEGIN
		SET @o_result_code = 0
		SET @v_errorMessage = 'A Work, Title and Printing must be related to the Rights on this Contract'
		--messages
		EXEC get_next_key @i_username, @v_nextkey OUT

		INSERT INTO taqprojectverificationmessage
		(
			messagekey,
			taqprojectkey,
			verificationtypecode,
			messagetypecode,
			message,
			lastuserid,
			lastmaintdate
		)
		VALUES
		(
			@v_nextkey,
			@i_contractProjectID,
			@v_JobTypeCode,
			@v_messageError,
			@v_errorMessage,
			@i_username,
			GETDATE()
		)

		--popup
		SET @v_errorCounter = @v_errorCounter + 1
		SET @o_result_desc = @o_result_desc + CAST(@v_errorCounter AS VARCHAR(50)) + ') ' + @v_errorMessage + '\r\n'
	END

	--Update status
	UPDATE taqprojectverification 
	SET verificationstatuscode = (CASE WHEN @o_result_code = 0 THEN @v_failedCode ELSE @v_passedCode END)
	WHERE taqprojectkey = @i_contractProjectID
	AND verificationtypecode = @v_JobTypeCode

	
RETURN
END
GO

GRANT EXEC ON qcontract_coEdition_verification TO PUBLIC
GO 