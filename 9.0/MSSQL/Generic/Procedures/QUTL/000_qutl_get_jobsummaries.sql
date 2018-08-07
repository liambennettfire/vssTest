if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_jobsummaries') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_jobsummaries
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qutl_get_jobsummaries]
(@i_showfilter		int,
 @i_typefilter		int,
 @i_reviewfilter	int,
 @i_userfilter		varchar(30),
 @o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	DECLARE @v_curdate	datetime,
					@v_recent		int --in days
					
	SET @v_curdate = GETDATE()
	
	SELECT @v_recent = clientdefaultvalue
	FROM clientdefaults
	WHERE clientdefaultid = 72
	
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	IF @i_showfilter = 1 --Recent Jobs
	BEGIN
		SELECT TOP (@v_recent) *
		FROM jobsummary_view
		WHERE (@i_typefilter <= 0 OR jobtypecode = @i_typefilter)
			AND (@i_reviewfilter < 0 OR COALESCE(reviewind, 0) = @i_reviewfilter)
			AND (@i_userfilter = '' OR userid = @i_userfilter)
		ORDER BY startdatetime DESC
	END
	ELSE IF @i_showfilter = 2 --Recent Jobs w/ Errors
	BEGIN
		SELECT TOP (@v_recent) *
		FROM jobsummary_view
		WHERE (@i_typefilter <= 0 OR jobtypecode = @i_typefilter)
			AND (@i_reviewfilter < 0 OR COALESCE(reviewind, 0) = @i_reviewfilter)
			AND (@i_userfilter = '' OR userid = @i_userfilter)
			AND errorind = 1
		ORDER BY startdatetime DESC
	END
	ELSE IF @i_showfilter = 3 --Recent Jobs w/ Warnings (WARNINGS PIECE NOT DONE, SAME AS ERROR!)
	BEGIN
		SELECT TOP (@v_recent) *
		FROM jobsummary_view
		WHERE (@i_typefilter <= 0 OR jobtypecode = @i_typefilter)
			AND (@i_reviewfilter < 0 OR COALESCE(reviewind, 0) = @i_reviewfilter)
			AND (@i_userfilter = '' OR userid = @i_userfilter)
			AND errorind = 1
		ORDER BY startdatetime DESC
	END
	ELSE IF @i_showfilter = 4 --Today's Jobs
	BEGIN
		SELECT *
		FROM jobsummary_view
		WHERE (@i_typefilter <= 0 OR jobtypecode = @i_typefilter)
			AND (@i_reviewfilter < 0 OR COALESCE(reviewind, 0) = @i_reviewfilter)
			AND (@i_userfilter = '' OR userid = @i_userfilter)
			AND DATEDIFF(day, startdatetime, GETDATE()) = 0
		ORDER BY startdatetime DESC
	END
	ELSE IF @i_showfilter = 5 --Yesterday's Jobs
	BEGIN
		SELECT *
		FROM jobsummary_view
		WHERE (@i_typefilter <= 0 OR jobtypecode = @i_typefilter)
			AND (@i_reviewfilter < 0 OR COALESCE(reviewind, 0) = @i_reviewfilter)
			AND (@i_userfilter = '' OR userid = @i_userfilter)
			AND DATEDIFF(day, startdatetime, GETDATE()) = 1
		ORDER BY startdatetime DESC
	END
	ELSE IF @i_showfilter = 6 --Jobs in the past week
	BEGIN
		SELECT *
		FROM jobsummary_view
		WHERE (@i_typefilter <= 0 OR jobtypecode = @i_typefilter)
			AND (@i_reviewfilter < 0 OR COALESCE(reviewind, 0) = @i_reviewfilter)
			AND (@i_userfilter = '' OR userid = @i_userfilter)
			AND DATEDIFF(week, startdatetime, GETDATE()) <= 1
		ORDER BY startdatetime DESC
	END
	ELSE IF @i_showfilter = 7 --Jobs in the past month
	BEGIN
		SELECT *
		FROM jobsummary_view
		WHERE (@i_typefilter <= 0 OR jobtypecode = @i_typefilter)
			AND (@i_reviewfilter < 0 OR COALESCE(reviewind, 0) = @i_reviewfilter)
			AND (@i_userfilter = '' OR userid = @i_userfilter)
			AND DATEDIFF(month, startdatetime, GETDATE()) <= 1
		ORDER BY startdatetime DESC
	END
	ELSE BEGIN
		SELECT *
		FROM jobsummary_view
		WHERE (@i_typefilter <= 0 OR jobtypecode = @i_typefilter)
			AND (@i_reviewfilter < 0 OR COALESCE(reviewind, 0) = @i_reviewfilter)
			AND (@i_userfilter = '' OR userid = @i_userfilter)
		ORDER BY startdatetime DESC
	END
	
	IF @@ERROR <> 0
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Failed to retrieve data from jobsummary view.'
		RETURN
	END
GO

GRANT EXEC ON qutl_get_jobsummaries TO PUBLIC
GO

