IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_csdist_datetypecode_for_statustag]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].qcs_get_csdist_datetypecode_for_statustag
GO

CREATE PROCEDURE [dbo].qcs_get_csdist_datetypecode_for_statustag(
	@statustag     varchar(25),
	@datetypecode  INT OUT

)
AS
BEGIN

SELECT @datetypecode = datetypecode
FROM datetype 
WHERE 
cstransactioncode in 
( select datacode from gentables where tableid = 575 and qsicode = 2 )
AND 
csstatuscode in 
( select datacode from gentables where tableid = 576 and eloquencefieldtag = @statustag )

END

GRANT EXEC ON qcs_get_csdist_datetypecode_for_statustag TO PUBLIC
GO
