IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_csapprovalcode]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qcs_get_csapprovalcode]
GO

CREATE FUNCTION [dbo].[qcs_get_csapprovalcode](@bookkey int)
RETURNS int
AS
BEGIN
	DECLARE @csApprovalCode int
	
	SET @csApprovalCode = 0
	
	SELECT TOP 1
		@csApprovalCode = COALESCE(bd.csapprovalcode,0)
	FROM
		bookdetail AS bd
	WHERE
		bd.bookkey = @bookkey

	RETURN @csApprovalCode
END
GO

GRANT EXEC ON dbo.qcs_get_csapprovalcode TO PUBLIC
GO
