IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_CsDistributionRowForDistTag]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].qcs_get_CsDistributionRowForDistTag
GO

CREATE PROCEDURE [dbo].qcs_get_CsDistributionRowForDistTag(
	@disttag varchar(25)
)
AS
BEGIN

SELECT     transactionkey, bookkey, assetkey, partnercontactkey, transactiontag, statuscode, notes, errormessage, lastuserid, lastmaintdate
FROM         csdistribution 
WHERE transactiontag = @disttag

END

GRANT EXEC ON qcs_get_CsDistributionRowForDistTag TO PUBLIC
GO
