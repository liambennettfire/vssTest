IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_istitleinoutbox]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qcs_get_istitleinoutbox]
GO

/*******************************************************************************************************
**  Name: qcs_get_istitleinoutbox
**  Desc: This function returns a 0 if the title is in not the cloud outbox, 1 if it is
**
**  Auth: Uday
**  Date: July 17 2013
*******************************************************************************************************/

CREATE FUNCTION [dbo].[qcs_get_istitleinoutbox](@bookkey INT)
RETURNS int
AS
BEGIN
	DECLARE @count INT
	
	SET @count = 0
	
	SELECT @count = COUNT(*) FROM bookdetail
	WHERE ([dbo].qcs_get_csapproved(@bookkey) = 1) AND (bookdetail.csmetadatastatuscode =5 OR bookdetail.csassetstatuscode = 5)
	AND bookkey = @bookkey
	
	IF @count > 0 BEGIN
		RETURN 1
	END
	
	RETURN 0
END
GO

GRANT EXEC ON dbo.qcs_get_istitleinoutbox TO PUBLIC
GO
