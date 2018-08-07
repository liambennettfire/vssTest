
/****** Object:  UserDefinedFunction [dbo].[rpt_get_grade_range]    Script Date: 03/24/2009 13:08:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_grade_range') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_grade_range
GO
CREATE FUNCTION [dbo].[rpt_get_grade_range](@bookkey	INT)
/** Returns the Grade Range as a string */

RETURNS VARCHAR(20)

AS

BEGIN

DECLARE @gradehigh	CHAR(4),
	@gradehighupind	INT,
	@gradelow	CHAR(4),
	@gradelowupind	CHAR(4),
	@RETURN		VARCHAR(20)


	SELECT @gradehigh = LTRIM(RTRIM(gradehigh)),
		@gradehighupind = gradehighupind,
		@gradelow = LTRIM(RTRIM(gradelow)),
		@gradelowupind = gradelowupind
	FROM bookdetail
	WHERE bookkey = @bookkey

	IF COALESCE(@gradelow,'')= '' AND COALESCE(@gradehigh,'')= ''
		BEGIN
			SET @RETURN = ''
		END
	ELSE
		BEGIN
			IF COALESCE(@gradelow,'')<>'' AND COALESCE(@gradehighupind,0)<>0
				SET @RETURN = LTRIM(RTRIM(@gradelow))+' and Up'
			ELSE IF COALESCE(@gradelow,'')<>'' AND COALESCE(@gradehigh,'')<>''
				SET @RETURN = LTRIM(RTRIM(@gradelow)) +' to '+LTRIM(RTRIM(@gradehigh))
			ELSE IF COALESCE(@gradelow,'')<>'' AND COALESCE(@gradehighupind,0)= 0
				SET @RETURN = @gradelow
			ELSE IF COALESCE(@gradehigh,'')<>'' AND COALESCE(@gradehighupind,0)<>0
				SET @RETURN = LTRIM(RTRIM(@gradehigh)) +' and Up'
			ELSE IF COALESCE(@gradehigh,'')<>'' AND COALESCE(@gradelowupind,0)<>0
				SET @RETURN = 'Up to '+ LTRIM(RTRIM(@gradehigh))
			ELSE IF COALESCE(@gradehigh,'')<>'' AND (COALESCE(@gradehighupind,0)= 0 OR COALESCE(@gradelowupind,0)=0)
				SET @RETURN = @gradehigh


		END

RETURN @RETURN

END

go
Grant All on dbo.rpt_get_grade_range to Public
go