IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_promos]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_promos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Derek Kurth
-- Create date: May 2015
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[qcs_get_promos]
AS
BEGIN

	DECLARE @maxAmtMisckey INT;
	DECLARE @maxUseMisckey INT;

	EXEC @maxAmtMisckey = qutl_get_misckey 25, null, null -- get the misckey that goes with qsicode 25, for MaxDiscountAmount
	EXEC @maxUseMisckey = qutl_get_misckey 26, null, null -- for MaxTimesAllowed

	DECLARE @jobs TABLE
	(
		qsijobkey INT,
		qsibatchkey INT,
		taqprojectkey INT
	)

	INSERT INTO @jobs
	SELECT DISTINCT j.qsijobkey, j.qsibatchkey, jm.referencekey1 as taqprojectkey
	FROM qsijob j
	JOIN qsijobmessages jm
		ON j.qsijobkey = jm.qsijobkey
	JOIN gentables jg
		ON j.statuscode = jg.datacode
	JOIN gentables jg2
		ON j.jobtypecode = jg2.datacode
	WHERE jg.tableid = 544
			AND jg.qsicode = 4
			AND jg2.tableid = 543
			AND jg2.qsicode = 14

	SELECT 
		p.taqprojectkey AS ReferenceId
		,p.taqprojecttitle AS Name
		,j.qsijobkey
		,j.qsibatchkey
		,(SELECT t.activedate FROM taqprojecttask t JOIN datetype dt ON t.datetypecode = dt.datetypecode WHERE t.taqprojectkey = p.taqprojectkey AND eloquencefieldtag = 'CLD_PC_EFF_DT') AS EffectiveDate
		,(SELECT t.activedate FROM taqprojecttask t JOIN datetype dt ON t.datetypecode = dt.datetypecode WHERE t.taqprojectkey = p.taqprojectkey AND eloquencefieldtag = 'CLD_PC_EXP_DT') AS ExpirationDate
		,m.floatvalue AS MaxDiscountAmount
		,CAST(m2.floatvalue as INT) as MaxTimesAllowed
		,(CASE WHEN (SELECT eloquencefieldtag FROM gentables WHERE tableid = 522 AND datacode = g.datacode) = 'CLD_PC_ACTIVE' THEN 0 ELSE 1 END) AS Inactive
	FROM subgentables sg
		JOIN taqproject p ON p.searchitemcode = sg.datacode AND p.usageclasscode = sg.datasubcode
		LEFT OUTER JOIN taqprojectmisc m ON m.taqprojectkey = p.taqprojectkey AND m.misckey = @maxAmtMisckey
		LEFT OUTER JOIN taqprojectmisc m2 ON m2.taqprojectkey = p.taqprojectkey AND m2.misckey = @maxUseMisckey
		JOIN gentables g ON g.datacode = p.taqprojectstatuscode
		--JOIN csprojectupdatetracker tr ON tr.projectkey = p.taqprojectkey
		JOIN @jobs j ON p.taqprojectkey = j.taqprojectkey
	WHERE
		g.tableid = 550
		AND sg.eloquencefieldtag = 'CLD_PC_PROMOTION'
END
GO
GRANT EXEC ON qcs_get_promos TO PUBLIC
GO