IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_fixtags]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_fixtags]
GO

CREATE PROCEDURE [dbo].[qcs_fixtags]
    @oldTag VARCHAR(25),
    @newTag VARCHAR(25)
AS
BEGIN
    DECLARE @likeTag VARCHAR(20)
    SET @likeTag=@oldTag+'-%'

    UPDATE csdistribution SET transactiontag=dbo.qcs_fixtag(transactiontag, @newTag) WHERE transactiontag LIKE @likeTag
    UPDATE csconversion SET transactiontag=dbo.qcs_fixtag(transactiontag, @newTag) WHERE transactiontag LIKE @likeTag
END
GO

GRANT EXEC ON qcs_fixtags TO PUBLIC
GO
