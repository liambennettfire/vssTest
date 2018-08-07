IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qproject_relate_master_contract_quarto') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qproject_relate_master_contract_quarto
GO

CREATE PROCEDURE dbo.qproject_relate_master_contract_quarto
 (@i_projectkey		INT,
  @i_lastuserid     VARCHAR(30),
  @o_error_code     INT OUTPUT,
  @o_error_desc     VARCHAR(2000) OUTPUT)
AS


/***************************************************************************************************
**  Name: qproject_relate_master_contract_quarto
**  Desc: We need a procedure (quarto specific) that when called from the web will look to see if 
**		there are any 'Active' (using clientdefault 85) Master Contracts (qsicode = 64) that have the 
**		same client (using client role qsicode) and will relate that master contract to the newly 
**		created Co-edition or Disk & Royalty contract
**
**  Auth: Joshua G
**  Date: March 6 2017
**
****************************************************************************************************
**  Change History
****************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -----------------------------------------------------------------------
*   12/04/17     Colman      48623 - need to update custom quarto procedure for Disk and Royalty contract class
**  01/18/18     Colman      49306 - Need to include Project Type when auto relating master contract 
****************************************************************************************************/

DECLARE
	@v_activeStatus INT,
	@v_masterRelationshipCode INT,
	@v_masterContractCode INT, 
  @v_masterProjectType INT,
	@v_contractCode INT,
	@v_clientRoleCode INT,
	@v_lastuserid VARCHAR(30),
	@v_contractID INT,
	@v_masterContractID INT,
	@v_currDate DATETIME,
	@v_new_taqprojecctrelationshipkey INT,
	@v_searchItemType INT,
	@v_orgEntry INT,
  @v_projectType INT,
  @v_projectClass INT,
  @v_projectTypeQsiCode INT

-- Disk & Royalty Master qsicode=16
-- Co-edition Master qsicode=17

SET @v_activeStatus = (SELECT clientdefaultvalue FROM clientdefaults WHERE clientdefaultid = 85)
SET @v_searchItemType = (SELECT dataCode FROM gentables WHERE tableID = 550 AND qsiCode = 10)
SET @v_clientRoleCode = (SELECT dataCode FROM gentables WHERE tableID = 285 AND qsiCode = 28)
SET @v_currDate = GETDATE()
SET @v_lastuserid = ISNULL(NULLIF(@i_lastuserid,''),'QSIADMIN')
SET @v_orgEntry = (SELECT orgEntryKey FROM taqprojectorgentry WHERE orglevelkey = 2 AND taqprojectkey = @i_projectkey)
SET @v_masterContractCode = (SELECT datasubcode FROM subgentables WHERE tableID = 550 AND qsiCode = 64) -- Master Contract

SELECT @v_projectType = searchitemcode, @v_projectClass = usageclasscode FROM taqproject WHERE taqprojectkey = @i_projectkey

SELECT @v_projectTypeQsiCode = qsicode 
FROM subgentables 
WHERE tableid = 550
  AND datacode = @v_projectType
  AND datasubcode = @v_projectClass

BEGIN

IF @v_projectTypeQsiCode = 63 -- Co-edition Contract
BEGIN
  SET @v_masterRelationshipCode = (SELECT dataCode FROM gentables WHERE tableId = 582 AND qsiCode = 37) --master contract
  SET @v_contractCode = (SELECT dataCode FROM gentables WHERE tableID = 582 AND qsiCode = 36) --subordinate contract
  SET @v_masterProjectType = (SELECT dataCode FROM gentables WHERE tableID = 521 AND qsiCode = 17) -- Co-edition Master
END
ELSE IF @v_projectTypeQsiCode = 76 -- Disk & Royalty Deals
BEGIN
  SET @v_masterRelationshipCode = (SELECT dataCode FROM gentables WHERE tableId = 582 AND qsiCode = 41) --Master (for Disk Royalty)
  SET @v_contractCode = (SELECT dataCode FROM gentables WHERE tableID = 582 AND qsiCode = 40) --Disk Royalty (for Master)
  SET @v_masterProjectType = (SELECT dataCode FROM gentables WHERE tableID = 521 AND qsiCode = 16) -- Disk & Royalty Master
END
ELSE
  RETURN

--Find all clients for our project
SELECT
  cr.taqProjectKey,
  c.globalcontactkey
INTO
  #tmp_potentialContactsToLink
FROM
  taqProjectContactRole cr
INNER JOIN taqProjectContact c
  ON cr.taqProjectContactKey = c.taqProjectContactKey
WHERE
      cr.taqProjectKey = @i_projectkey
  AND cr.rolecode = @v_clientRoleCode	

--insert
EXEC get_next_key @v_lastuserid, @v_new_taqprojecctrelationshipkey OUTPUT
      
INSERT INTO taqprojectrelationship 
(
  taqprojectrelationshipkey, 
  taqprojectkey1, 
  taqprojectkey2, 
  relationshipcode1, 
  relationshipcode2, 
  keyind, 
  lastuserid, 
  lastmaintdate
)
SELECT
  TOP 1 --It's possible we could match to multiple masters, but we only want one don't care which.
  @v_new_taqprojecctrelationshipkey, --taqprojectrelationshipkey
  cr.taqProjectKey AS masterContractID,
  ced.taqProjectKey AS contractID,
  @v_masterRelationshipCode,		   --relationshipcode1
  @v_contractCode,		   --relationshipcode2
  0,								   --keyind
  @v_lastuserid,					   --lastuserid
  @v_currDate						   --lastmaintdate
FROM
  taqProject tp
INNER JOIN taqProjectContactRole cr
  ON cr.taqprojectkey = tp.taqprojectkey
INNER JOIN taqProjectContact c
  ON cr.taqProjectContactKey = c.taqProjectContactKey
INNER JOIN #tmp_potentialContactsToLink ced
  ON c.globalcontactkey = ced.globalcontactkey
WHERE
    cr.rolecode = @v_clientRoleCode	
AND tp.usageclasscode = @v_masterContractCode
AND tp.taqprojectstatuscode = @v_activeStatus
AND tp.searchitemcode = @v_searchItemType
AND tp.taqprojecttype = @v_masterProjectType
AND EXISTS(SELECT 1 FROM taqprojectorgentry tao
      WHERE tp.taqprojectkey = tao.taqprojectkey
      AND tao.orgentrykey = @v_orgEntry)
      
END
GO

GRANT EXEC on dbo.qproject_relate_master_contract_quarto to PUBLIC
GO