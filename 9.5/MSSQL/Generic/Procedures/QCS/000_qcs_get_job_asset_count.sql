IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_job_asset_count]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_job_asset_count]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dustin Miller
-- Create date: July 15, 2013
-- Description:	Returns the number of cloudsendpublish rows for the specific jobkey (not including jobend rows)
-- =============================================
CREATE PROCEDURE [qcs_get_job_asset_count] 
	@i_jobkey int,
	@o_error_code integer output,
  @o_error_desc varchar(2000) output
AS
BEGIN

DECLARE @v_error  INT

SET @o_error_code = 0
SET @o_error_desc = ''

SELECT COUNT(*) as assetcount
FROM cloudsendpublish
WHERE jobkey = @i_jobkey
	AND COALESCE(jobendind, 0) = 0

SELECT @v_error = @@ERROR
IF @v_error <> 0 BEGIN
	SET @o_error_code = 1
  SET @o_error_desc = 'Error retrieving asset count information for jobkey: ' + CAST(@i_jobkey as varchar)
END

END

GO

GRANT EXEC ON qcs_get_job_asset_count TO PUBLIC
GO