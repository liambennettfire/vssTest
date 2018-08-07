IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_istitleinresendoutbox]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qcs_get_istitleinresendoutbox]
GO

/*******************************************************************************************************
**  Name: qcs_get_istitleinresendoutbox
**  Desc: This function returns a 0 if the title is in not the cloud resend outbox (cloudscheduleforresend), 1 if it is
**
**  Auth: Dustin Miller
**  Date: October 4 2016
*******************************************************************************************************/

CREATE FUNCTION [dbo].[qcs_get_istitleinresendoutbox](@bookkey INT)
RETURNS int
AS
BEGIN
	DECLARE @count INT
	
	SET @count = 0
	
	SELECT @count = COUNT(*) FROM cloudscheduleforresend
	WHERE ([dbo].qcs_get_csapproved(@bookkey) = 1)
	AND bookkey = @bookkey
	
	IF @count > 0 BEGIN
		RETURN 1
	END
	
	RETURN 0
END
GO

GRANT EXEC ON dbo.qcs_get_istitleinresendoutbox TO PUBLIC
GO
