IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_remove_orphan_send_assets]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_remove_orphan_send_assets]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Dustin Miller
-- Create date: July 1, 2013
-- Description:	
-- =============================================
CREATE PROCEDURE [qcs_remove_orphan_send_assets] 
    @i_userid varchar(30),
    @o_error_code integer output,
		@o_error_desc varchar(2000) output
AS
BEGIN

DECLARE @v_error int,
				@v_statusaborted int,
				@v_daysold int,
				@v_curdate datetime,
				@v_curtime varchar(50),
				@v_curjobkey int,
				@v_desc	varchar(4000)

SET @o_error_code = 0
SET @o_error_desc = ''

SELECT @v_statusaborted = datacode
FROM gentables
WHERE tableid = 539
	AND qsicode = 5

SET @v_daysold = -3
SET @v_curdate = GETDATE()
SET @v_curtime = CONVERT(varchar, GETDATE(), 114)

DECLARE job_cursor CURSOR FOR
SELECT DISTINCT jobkey
FROM cloudsendpublish
WHERE ((LEN(COALESCE(lastuserid, '')) = 0 AND lastmaintdate < (DATEADD(day, @v_daysold, @v_curdate)))
	OR LOWER(lastuserid) = LOWER(@i_userid))
	AND processstatuscode = 3
    
OPEN job_cursor

FETCH NEXT FROM job_cursor INTO @v_curjobkey

WHILE (@@FETCH_STATUS = 0) 
BEGIN
	SET @v_desc = 'Job Canceled by user ' + CONVERT(varchar, GETDATE(), 1) + ' ' + SUBSTRING(@v_curtime, 0, LEN(@v_curtime) - 6)

	EXEC qutl_update_job 0, @v_curjobkey, 0, 0, '', '', @i_userid, 0, 0, 0, @v_statusaborted,
		@v_desc, 'Job Canceled', -1, 5, 0, ''
		
	SELECT @v_error = @@ERROR
	IF @v_error <> 0 BEGIN
		SET @o_error_code = 1
		SET @o_error_desc = 'Error clearing cloudsendpublish (qcs_remove_orphan_send_assets)'
		RETURN
	END
	
	FETCH NEXT FROM job_cursor INTO @v_curjobkey
END

CLOSE job_cursor
DEALLOCATE job_cursor

DELETE FROM cloudsendpublish
WHERE ((LEN(COALESCE(lastuserid, '')) = 0 AND lastmaintdate < (DATEADD(day, @v_daysold, @v_curdate)))
	OR LOWER(lastuserid) = LOWER(@i_userid))
	AND processstatuscode = 3

SELECT @v_error = @@ERROR
IF @v_error <> 0 BEGIN
	SET @o_error_code = 1
	SET @o_error_desc = 'Error clearing cloudsendpublish (qcs_remove_orphan_send_assets)'
END

END

GO

GRANT EXEC ON qcs_remove_orphan_send_assets TO PUBLIC
GO