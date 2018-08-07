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
	DECLARE 
		@v_curdate	datetime,
		@v_recent		INT, --in days
		@v_typefilter    INT,
		@v_reviewfilter	int,
		@v_userfilter	varchar(30)
					
	SET @v_curdate = GETDATE()
	
	SELECT @v_recent = clientdefaultvalue
	FROM clientdefaults
	WHERE clientdefaultid = 72
	
	--Remove parameter sniffing by setting new variables = to the passed in variables
	--This will allow the proc to choose a new plan each run rather than picking a bad plan
	--that has uncommon selectability per db.
	SET @v_typefilter = @i_typefilter
	SET @v_reviewfilter	= @i_reviewfilter
	SET @v_userfilter = @i_userfilter

	
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	IF @i_showfilter = 1 --Recent Jobs
	BEGIN
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate
		FROM(
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate,
				ROW_NUMBER() OVER(ORDER BY startdatetime DESC)rnk	
		FROM dbo.qutl_jobsummary_by_userid(@v_userfilter)
		WHERE (@v_typefilter <= 0 OR jobtypecode = @v_typefilter)
			AND (@v_reviewfilter < 0 OR COALESCE(reviewind, 0) = @v_reviewfilter)
			AND (@v_userfilter = '' OR userid = @v_userfilter)
		)t
		WHERE rnk <= @v_recent
		ORDER BY rnk
    OPTION (RECOMPILE)
	END
	ELSE IF @i_showfilter = 2 --Recent Jobs w/ Errors
	BEGIN	
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate
		FROM(
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate,
				ROW_NUMBER() OVER(ORDER BY startdatetime DESC)rnk	
		FROM dbo.qutl_jobsummary_by_userid(@v_userfilter)
		WHERE (@v_typefilter <= 0 OR jobtypecode = @v_typefilter)
			AND (@i_reviewfilter < 0 OR COALESCE(reviewind, 0) = @v_reviewfilter)
			AND (@v_userfilter = '' OR userid = @v_userfilter)
			AND errorind = 1	
		)t 
		WHERE rnk <= @v_recent
		ORDER BY rnk
    OPTION (RECOMPILE)	
	END
	ELSE IF @i_showfilter = 3 --Recent Jobs w/ Warnings (WARNINGS PIECE NOT DONE, SAME AS ERROR!)
	BEGIN
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate
		FROM(
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate,
				ROW_NUMBER() OVER(ORDER BY startdatetime DESC)rnk		
		FROM dbo.qutl_jobsummary_by_userid(@v_userfilter)
		WHERE (@v_typefilter <= 0 OR jobtypecode = @v_typefilter)
			AND (@v_reviewfilter < 0 OR COALESCE(reviewind, 0) = @v_reviewfilter)
			AND (@v_userfilter = '' OR userid = @v_userfilter)
			AND errorind = 1	
		)t 
		WHERE rnk <= @v_recent
		ORDER BY rnk
    OPTION (RECOMPILE)
	END
	ELSE IF @i_showfilter = 4 --Today's Jobs
	BEGIN
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate
		FROM(
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate,
				ROW_NUMBER() OVER(ORDER BY startdatetime DESC)rnk		
		FROM dbo.qutl_jobsummary_by_userid(@v_userfilter)
		WHERE (@v_typefilter <= 0 OR jobtypecode = @v_typefilter)
			AND (@v_reviewfilter < 0 OR COALESCE(reviewind, 0) = @v_reviewfilter)
			AND (@v_userfilter = '' OR userid = @v_userfilter)
			AND DATEDIFF(day, startdatetime, GETDATE()) = 0	
		)t 
		ORDER BY rnk
    OPTION (RECOMPILE)	
	END
	ELSE IF @i_showfilter = 5 --Yesterday's Jobs
	BEGIN
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate
		FROM(
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate,
				ROW_NUMBER() OVER(ORDER BY startdatetime DESC)rnk	
		FROM dbo.qutl_jobsummary_by_userid(@v_userfilter)
		WHERE (@v_typefilter <= 0 OR jobtypecode = @v_typefilter)
			AND (@v_reviewfilter < 0 OR COALESCE(reviewind, 0) = @v_reviewfilter)
			AND (@v_userfilter = '' OR userid = @v_userfilter)
			AND DATEDIFF(day, startdatetime, GETDATE()) = 1
		)t 
		ORDER BY rnk
    OPTION (RECOMPILE)	
	END
	ELSE IF @i_showfilter = 6 --Jobs in the past week
	BEGIN
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate
		FROM(
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate,
				ROW_NUMBER() OVER(ORDER BY startdatetime DESC)rnk	
		FROM dbo.qutl_jobsummary_by_userid(@v_userfilter)
		WHERE (@v_typefilter <= 0 OR jobtypecode = @v_typefilter)
			AND (@v_reviewfilter < 0 OR COALESCE(reviewind, 0) = @v_reviewfilter)
			AND (@v_userfilter = '' OR userid = @v_userfilter)
			AND DATEDIFF(week, startdatetime, GETDATE()) <= 1
		)t 
		ORDER BY rnk
    OPTION (RECOMPILE)
	END
	ELSE IF @i_showfilter = 7 --Jobs in the past month
	BEGIN
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate
		FROM(
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate,
				ROW_NUMBER() OVER(ORDER BY startdatetime DESC)rnk		
		FROM dbo.qutl_jobsummary_by_userid(@v_userfilter)
		WHERE (@v_typefilter <= 0 OR jobtypecode = @v_typefilter)
			AND (@v_reviewfilter < 0 OR COALESCE(reviewind, 0) = @v_reviewfilter)
			AND (@v_userfilter = '' OR userid = @v_userfilter)
			AND DATEDIFF(month, startdatetime, GETDATE()) <= 1
		)t 
		ORDER BY rnk
    OPTION (RECOMPILE)
	END
	ELSE BEGIN
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate
		FROM(
		SELECT jobkey,reviewind,errorind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc,jobdesc,jobdescshort,
				startdatetime,stopdatetime,userid,statuscode,statusdesc,summarymessage,lastuserid,lastmaintdate,
				ROW_NUMBER() OVER(ORDER BY startdatetime DESC)rnk		
		FROM dbo.qutl_jobsummary_by_userid(@v_userfilter)
		WHERE (@v_typefilter <= 0 OR jobtypecode = @v_typefilter)
			AND (@v_reviewfilter < 0 OR COALESCE(reviewind, 0) = @v_reviewfilter)
			AND (@v_userfilter = '' OR userid = @v_userfilter)
		)t 
		ORDER BY rnk
    OPTION (RECOMPILE)	
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

