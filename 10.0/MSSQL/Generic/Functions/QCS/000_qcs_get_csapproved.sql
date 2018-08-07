IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_csapproved]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qcs_get_csapproved]
GO

CREATE FUNCTION [dbo].[qcs_get_csapproved](@bookkey int)
RETURNS bit
AS
BEGIN
	DECLARE @csApprovalCode int,
			@eloCloud int,
			@csApproved bit

	SET @csApprovalCode = 0
	SET @csApproved = 0
	SET @eloCloud = 0
	
	SELECT TOP 1 @csApprovalCode = COALESCE(bd.csapprovalcode, 0)
	FROM bookdetail bd
	WHERE bd.bookkey = @bookkey

	SELECT @eloCloud = COALESCE(co.optionvalue, 0)
	from clientoptions co
	where co.optionid = 111

	IF @csApprovalCode = 1 OR (@eloCloud = 2 AND @csApprovalCode = 4)
	BEGIN
		SET @csApproved = 1
	END

	RETURN @csApproved
END
GO

GRANT EXEC ON dbo.qcs_get_csapproved TO PUBLIC
GO
