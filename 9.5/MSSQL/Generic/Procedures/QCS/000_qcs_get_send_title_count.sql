IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_send_title_count]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_send_title_count]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dustin Miller
-- Create date: July 25, 2013
-- Description:	
-- =============================================
CREATE PROCEDURE [qcs_get_send_title_count] 
	@i_jobkey int,
	@o_error_code integer output,
  @o_error_desc varchar(2000) output
AS
BEGIN

DECLARE @v_error  INT

SET @o_error_code = 0
SET @o_error_desc = ''

SELECT COUNT(DISTINCT bookkey) as titlecount
FROM cloudsendpublish cp
WHERE cp.jobkey = @i_jobkey

SELECT @v_error = @@ERROR
IF @v_error <> 0 BEGIN
	SET @o_error_code = 1
  SET @o_error_desc = 'Error retrieving title count information from cloudsendpublish w/ jobkey: ' + CAST(@i_jobkey as varchar)
END

END

GO

GRANT EXEC ON qcs_get_send_title_count TO PUBLIC
GO