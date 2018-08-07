if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_jobsummary') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_jobsummary
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qutl_get_jobsummary]
(@i_jobkey				int,
 @o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	SELECT *
	FROM jobsummary_view
	WHERE jobkey = @i_jobkey
	
	IF @@ERROR <> 0
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Failed to retrieve data from jobsummary view.'
		RETURN
	END
	
GO

GRANT EXEC ON qutl_get_jobsummary TO PUBLIC
GO

