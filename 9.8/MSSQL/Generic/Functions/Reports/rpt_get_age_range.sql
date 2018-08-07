
/****** Object:  UserDefinedFunction [dbo].[rpt_get_age_range]    Script Date: 03/24/2009 11:43:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_age_range') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_age_range
GO
CREATE FUNCTION [dbo].[rpt_get_age_range](@bookkey	INT)

/** Returns the Age Range as a string, including All Ages if specified, and 'and Up' if specified **/

RETURNS VARCHAR(20)

AS

BEGIN

DECLARE @agehigh	INT,
	@agehighupind	INT,
	@agelow		INT,
	@agelowupind	INT,
	@allagesind	INT,
	@RETURN		VARCHAR(20)


	SELECT @agehigh = agehigh,
		@agehighupind = agehighupind,
		@agelow = agelow,
		@agelowupind = agelowupind,
		@allagesind = allagesind
	FROM bookdetail
	WHERE bookkey = @bookkey

	IF COALESCE(@agelow,0)= 0 AND COALESCE(@agehigh,0)=0
		BEGIN
			SET @RETURN = ''
		END
	ELSE
		BEGIN
			IF COALESCE(@allagesind,0) <> 0
				SET @RETURN = 'All Ages'
			ELSE IF COALESCE(@agehigh,0)<>0 AND COALESCE(@agehighupind,0)<>0
				SET @RETURN = CONVERT(CHAR(2),@agehigh)+' and Up'
			ELSE IF COALESCE(@agehigh,0)<>0 AND COALESCE(@agelowupind,0)<>0
				SET @RETURN = 'Up to '+CONVERT(CHAR(2),@agehigh)
			ELSE IF COALESCE(@agelow,0)<>0 AND COALESCE(@agehighupind,0)<>0
				SET @RETURN = CONVERT(CHAR(2),@agelow)+' and Up'
			ELSE IF COALESCE(@agelow,0)<>0 AND COALESCE(@agehigh,0)<>0
				SET @RETURN = CONVERT(CHAR(2),@agelow)+' to '+CONVERT(CHAR(2),@agehigh)
			ELSE IF COALESCE(@agelow,0)<>0 AND COALESCE(@agehighupind,0)= 0
				SET @RETURN = CONVERT(CHAR(2),@agelow)
			ELSE IF COALESCE(@agehigh,0)<>0 AND (COALESCE(@agehighupind,0)= 0 OR COALESCE(@agelowupind,0)=0)
				SET @RETURN = CONVERT(CHAR(2),@agehigh)


		END

RETURN @RETURN

END


go
Grant All on dbo.rpt_get_age_range to Public
go