IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_CsConversionRowForConvTag]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].qcs_get_CsConversionRowForConvTag
GO

CREATE PROCEDURE [dbo].qcs_get_CsConversionRowForConvTag(
	@convtag varchar(25)
)
AS
BEGIN

SELECT conv.*, 
       (select bookkey from taqprojectelement where taqelementkey = conv.sourceassetkey) sourcebookkey,
       (select bookkey from taqprojectelement where taqelementkey = conv.targetassetkey) targetbookkey
  FROM csconversion conv
 WHERE conv.transactiontag = @convtag

END

GRANT EXEC ON qcs_get_CsConversionRowForConvTag TO PUBLIC
GO
