SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_processbackgroundjobs')
drop procedure qutl_processbackgroundjobs
go

CREATE PROCEDURE [dbo].[qutl_processbackgroundjobs]
 (@i_bookkey              integer,
  @i_numofrows            integer,
  @i_failedattemptinterval  datetime,
  @o_error_code           integer output,
  @o_error_desc			  varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_processbackgroundjobs
**  Desc: This stored procedure will be run on a timed basis plus it can be
**        invoked directly by Get Product for a specific bookkey.
**        Every time it wakes up, it will start processing any jobs that exist
**        in the BackgroundProcess table until nothing is left in the table.
**        It will grab the defined number of rows at a time and mark them as processing.
**        This will allow the procedure to wake up numerous times and be able to
**        asynchronously process these jobs to get them done quicker.
**        It does not have to be set up to run this way but it should be able to.
**        RowLinkKey and RowLinkSortOrder will identify those rows that need to be
**        processed together in a specific order.  These are not required to be filled in
**        – only if order of processing is important
**
**    Auth: Kusum
**    Date: 14 March 2016
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:		Author:			Description:
**    -----		--------		-------------------------------------------
	  7/6/16	Chris			Qa Fixup
**    6/2/16	Kusum			Case 38153
**    6/20/16   Kusum           Case 36929
*******************************************************************************/
  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @v_count INT
  DECLARE @v_count2 INT
  DECLARE @v_count3 INT
  DECLARE @v_standardmsgcode INT
  DECLARE @v_standardmsgsubcode INT
  DECLARE @v_numrows INT
  DECLARE @v_numrows2 INT
  DECLARE @v_counter1 INT
  DECLARE @v_backgroundprocesskey INT
  DECLARE @v_rowlinkkey INT
  DECLARE @v_storedprocname VARCHAR(255)
  DECLARE @v_error  INT
  DECLARE @v_errordesc  VARCHAR(2000)
  DECLARE @v_sql  NVARCHAR(2000)
  DECLARE @v_numofattempts INT
  DECLARE @v_numofattempts2 INT
  DECLARE @v_key1 INT
  DECLARE @v_key2 INT
  DECLARE @v_key3 INT
  DECLARE @v_jobtypecode INT
  DECLARE @v_msgcode INT
  DECLARE @v_msgsubcode INT
  DECLARE @v_count_rowlinkkey INT

  -- DOIT_AGAIN Label:
  -- When the number of rows that fit the criteria exceed the @i_numofrows,
  -- this procedure will get executed again to process the remaining rows.
  DOIT_AGAIN:

  SET @v_count = 0
  SET @v_count2 = 0
  SET @v_count3 = 0
  SET @v_numrows = 0
  SET @v_numrows2 = 0
  SET @v_counter1 = 0


  IF @i_numofrows IS NULL SET @i_numofrows = 0


  IF @i_bookkey IS NULL OR @i_bookkey = 0 BEGIN
	SELECT @v_count = COUNT(*)
	  FROM backgroundprocess bgp1
	 WHERE processingind = 0
	   AND (lastattemptdate IS NULL OR lastattemptdate <= @i_failedattemptinterval)
	   AND NOT EXISTS (SELECT * FROM backgroundprocess bgp2 where bgp1.jobtypecode = bgp2.jobtypecode
	        AND COALESCE(bgp1.key1,0) = COALESCE(bgp2.key1,0) AND COALESCE(bgp1.key2,0) = COALESCE(bgp2.key2,0)
	        AND COALESCE(bgp1.key3,0) = COALESCE(bgp2.key3,0) AND bgp2.processingind = 1)
  END --IF @i_bookkey IS NULL OR @i_bookkey = 0
  ELSE BEGIN
	SELECT @v_count = COUNT(*)
	  FROM backgroundprocess bgp1
	 WHERE processingind = 0
	   AND key1 = @i_bookkey
	   AND (lastattemptdate IS NULL OR lastattemptdate <= @i_failedattemptinterval)
	   AND NOT EXISTS (SELECT * FROM backgroundprocess bgp2 where bgp1.jobtypecode = bgp2.jobtypecode
	        AND COALESCE(bgp1.key1,0) = COALESCE(bgp2.key1,0) AND COALESCE(bgp1.key2,0) = COALESCE(bgp2.key2,0)
	        AND COALESCE(bgp1.key3,0) = COALESCE(bgp2.key3,0) AND bgp2.processingind = 1)
  END --IF @i_bookkey IS NOT NULL OR @i_bookkey <> 0

  IF @v_count = 0 RETURN --nothing to process

  CREATE TABLE #backgroundprocessrows (
    rowid int identity (1,1),
    backgroundprocesskey int not null,
    rowlinkkey int null,
    createdate datetime null,
    key1 int null,
    rowlinksortorder int null,
    storedprocname varchar(255),
    numofattempts int null,
    processingind int null)


  IF @i_bookkey IS NULL OR @i_bookkey = 0 BEGIN
	  --SELECT @v_count = COUNT(*)
	  --  FROM backgroundprocess bgp1
	  -- WHERE processingind = 0
	  --   AND (lastattemptdate IS NULL OR lastattemptdate > @i_failedattemptinterval)
	  --   AND NOT EXISTS (SELECT * FROM backgroundprocess bgp2 where bgp1.jobtypecode = bgp2.jobtypecode
	  --        AND COALESCE(bgp1.key1,0) = COALESCE(bgp2.key1,0) AND COALESCE(bgp1.key2,0) = COALESCE(bgp2.key2,0)
	  --        AND COALESCE(bgp1.key3,0) = COALESCE(bgp2.key3,0) AND bgp2.processingind = 1)

	  IF @v_count > 0 BEGIN
		  IF @i_numofrows > 0 BEGIN
			  INSERT INTO #backgroundprocessrows
				  SELECT TOP (@i_numofrows) backgroundprocesskey,rowlinkkey,createdate,key1,rowlinksortorder,storedprocname,numofattempts,processingind
				    FROM backgroundprocess bgp1
				   WHERE processingind = 0
				     AND (lastattemptdate IS NULL OR lastattemptdate <= @i_failedattemptinterval)
				     AND NOT EXISTS (SELECT * FROM backgroundprocess bgp2 where bgp1.jobtypecode = bgp2.jobtypecode
						  AND COALESCE(bgp1.key1,0) = COALESCE(bgp2.key1,0) AND COALESCE(bgp1.key2,0) = COALESCE(bgp2.key2,0)
						  AND COALESCE(bgp1.key3,0) = COALESCE(bgp2.key3,0) AND bgp2.processingind = 1)
				  ORDER BY createdate ASC
	     END
	     ELSE BEGIN
			  INSERT INTO #backgroundprocessrows
				  SELECT backgroundprocesskey,rowlinkkey,createdate,key1,rowlinksortorder,storedprocname,numofattempts,processingind
				    FROM backgroundprocess bgp1
				   WHERE processingind = 0
				     AND (lastattemptdate IS NULL OR lastattemptdate <= @i_failedattemptinterval)
				     AND NOT EXISTS (SELECT * FROM backgroundprocess bgp2 where bgp1.jobtypecode = bgp2.jobtypecode
						  AND COALESCE(bgp1.key1,0) = COALESCE(bgp2.key1,0) AND COALESCE(bgp1.key2,0) = COALESCE(bgp2.key2,0)
						  AND COALESCE(bgp1.key3,0) = COALESCE(bgp2.key3,0) AND bgp2.processingind = 1)
				  ORDER BY createdate ASC
	     END --@i_numofrows = 0
	  END ---@v_count > 0
  END --IF @i_bookkey IS NULL OR @i_bookkey = 0
  ELSE BEGIN
	  --SELECT @v_count = COUNT(*)
	  --  FROM backgroundprocess bgp1
	  -- WHERE processingind = 0
	  --   AND key1 = @i_bookkey
	  --   AND (lastattemptdate IS NULL OR lastattemptdate > @i_failedattemptinterval)
	  --   AND NOT EXISTS (SELECT * FROM backgroundprocess bgp2 where bgp1.jobtypecode = bgp2.jobtypecode
	  --        AND COALESCE(bgp1.key1,0) = COALESCE(bgp2.key1,0) AND COALESCE(bgp1.key2,0) = COALESCE(bgp2.key2,0)
	  --        AND COALESCE(bgp1.key3,0) = COALESCE(bgp2.key3,0) AND bgp2.processingind = 1)

	  IF @v_count > 0 BEGIN
		  INSERT INTO #backgroundprocessrows
			  --SELECT TOP (@i_numofrows) backgroundprocesskey,rowlinkkey,createdate,key1,rowlinksortorder,storedprocname,numofattempts
			  SELECT backgroundprocesskey,rowlinkkey,createdate,key1,rowlinksortorder,storedprocname,numofattempts,processingind
			    FROM backgroundprocess bgp1
			   WHERE processingind = 0
			     AND key1 = @i_bookkey
			     AND (lastattemptdate IS NULL OR lastattemptdate <= @i_failedattemptinterval)
			     AND NOT EXISTS (SELECT * FROM backgroundprocess bgp2 where bgp1.jobtypecode = bgp2.jobtypecode
			     AND COALESCE(bgp1.key1,0) = COALESCE(bgp2.key1,0) AND COALESCE(bgp1.key2,0) = COALESCE(bgp2.key2,0)
			     AND COALESCE(bgp1.key3,0) = COALESCE(bgp2.key3,0) AND bgp2.processingind = 1)
				  ORDER BY createdate ASC
	  END ---@v_count > 0
  END --IF @i_bookkey IS NOT NULL OR @i_bookkey <> 0

  CREATE TABLE #backgroundprocessrows_temp (
    rowid int identity (1,1),
    backgroundprocesskey int not null,
    createdate datetime null,
    rowlinkkey int null,
    key1 int null,
    rowlinksortorder int null,
    storedprocname varchar(255),
    numofattempts int )

  SELECT @v_numrows = count(*)
	FROM #backgroundprocessrows

  SET @v_counter1 = 1

  WHILE @v_counter1 <= @v_numrows BEGIN
	  SELECT @v_backgroundprocesskey = backgroundprocesskey FROM #backgroundprocessrows WHERE rowid = @v_counter1

	  SELECT @v_rowlinkkey = COALESCE(rowlinkkey,0) FROM #backgroundprocessrows WHERE backgroundprocesskey = @v_backgroundprocesskey

	  IF @v_rowlinkkey = 0 BEGIN
		  INSERT INTO #backgroundprocessrows_temp
			SELECT backgroundprocesskey, createdate,rowlinkkey, key1, rowlinksortorder, storedprocname,numofattempts FROM #backgroundprocessrows
			 WHERE rowid = @v_counter1
	  END
	  ELSE BEGIN
      -- Find all rows with the same rowlinkkey.  If any of them have processing=1, skip processing all these linked rows
      -- because they will be grabbed by the other process that set one of them to processing = 1
		  SELECT @v_numrows2 = COUNT(*) FROM backgroundprocess WHERE rowlinkkey = @v_rowlinkkey AND processingind = 1
		  IF @v_numrows2 > 0 BEGIN
        -- at least one linked row is processing, remove them all
        DELETE FROM #backgroundprocessrows_temp WHERE rowlinkkey = @v_rowlinkkey
      END
      ELSE BEGIN
        -- no linked row is processing so grab them all
			  INSERT INTO #backgroundprocessrows_temp
			  SELECT backgroundprocesskey, createdate,rowlinkkey, key1, rowlinksortorder, storedprocname,numofattempts FROM backgroundprocess
				 WHERE rowlinkkey = @v_rowlinkkey AND processingind = 0
				   AND NOT EXISTS (SELECT backgroundprocesskey FROM #backgroundprocessrows_temp)
      END
	  END

	  SET @v_counter1 = @v_counter1 + 1
  END

  CREATE TABLE #backgroundprocessrows_temp2 (
    rowid int identity (1,1),
    backgroundprocesskey int not null,
    createdate datetime null,
    rowlinkkey int null,
    key1 int null,
    rowlinksortorder int null,
    storedprocname varchar(255),
    numofattempts INT)

  INSERT INTO #backgroundprocessrows_temp2
    SELECT backgroundprocesskey,createdate,rowlinkkey,key1,rowlinksortorder,storedprocname,numofattempts
      FROM #backgroundprocessrows_temp
	  ORDER BY rowlinkkey ASC,backgroundprocesskey ASC,rowlinksortorder ASC

  SELECT @v_numrows = count(*) FROM #backgroundprocessrows_temp2

  SET @v_counter1 = 1

  WHILE @v_counter1 <= @v_numrows BEGIN
	  SELECT @v_backgroundprocesskey = backgroundprocesskey
	    FROM #backgroundprocessrows_temp2 where rowid = @v_counter1

	  UPDATE backgroundprocess SET processingind = 1 WHERE backgroundprocesskey = @v_backgroundprocesskey

	  SET @v_counter1 = @v_counter1 + 1
  END

  SET @v_counter1 = 1

  WHILE @v_counter1 <= @v_numrows BEGIN
	  SELECT @v_backgroundprocesskey = backgroundprocesskey,
	         @v_numofattempts = numofattempts
	    FROM #backgroundprocessrows_temp2 where rowid = @v_counter1

	  SELECT @v_storedprocname = storedprocname FROM backgroundprocess WHERE backgroundprocesskey = @v_backgroundprocesskey

	  SET @v_sql = N'EXEC ' + @v_storedprocname + ' ' + CONVERT(VARCHAR, @v_backgroundprocesskey) + ',
		  @v_error_code OUTPUT, @v_standardmsgcode OUTPUT,@v_standardmsgsubcode OUTPUT, @v_error_desc OUTPUT'

	  EXEC sp_executesql @v_sql,
		    N'@i_backgroundprocesskey int,  @v_error_code INT OUTPUT,@v_standardmsgcode INT OUTPUT,
		    @v_standardmsgsubcode INT OUTPUT, @v_error_desc VARCHAR(2000) OUTPUT',
		    @i_backgroundprocesskey = @v_backgroundprocesskey,
		    @v_error_code = @v_error OUTPUT,
		    @v_standardmsgcode = @v_msgcode OUTPUT,
		    @v_standardmsgsubcode =@v_msgsubcode OUTPUT,
		    @v_error_desc = @v_errordesc OUTPUT

	  IF (@@ERROR!=0) BEGIN
		SET @v_error = -1
		SET @v_errordesc = 'There was an error processing stored procedure: ' + @v_storedprocname
	  END

	  IF @v_error = -1 BEGIN

		  SET @o_error_code = -1

		  IF @v_numofattempts = 4 BEGIN
			  SET @v_numofattempts = 5

			  INSERT INTO backgroundprocess_history (backgroundprocesskey,jobtypecode,storedprocname,reqforgetprodind,failgetprodind,numofattempts,jobkey,
					 returncode,standardmsgcode,standardmsgsubcode,returnmsgdesc,
					 key1,key2,key3,textvalue1,textvalue2,textvalue3,textvalue4,
					 integervalue1,integervalue2,integervalue3,integervalue4,
					 floatvalue1,floatvalue2,floatvalue3,floatvalue4,
					 rowlinkkey,rowlinksortorder,createddate,processeddate,lastuserid,lastmaintdate)
				SELECT @v_backgroundprocesskey,jobtypecode,storedprocname,reqforgetprodind,1,@v_numofattempts,0,
					 @v_error,@v_msgcode,@v_msgsubcode,@v_errordesc,
					 key1,key2,key3,textvalue1,textvalue2,textvalue3,textvalue4,
					 integervalue1,integervalue2,integervalue3,integervalue4,
					 floatvalue1,floatvalue2,floatvalue3,floatvalue4,
					 rowlinkkey,rowlinksortorder,createdate,GETDATE(),lastuserid,lastmaintdate
			     FROM backgroundprocess where backgroundprocesskey = @v_backgroundprocesskey

			  DELETE FROM backgroundprocess where backgroundprocesskey = @v_backgroundprocesskey
		  END
		  ELSE BEGIN
			SET @v_numofattempts = @v_numofattempts + 1
			UPDATE backgroundprocess
			SET numofattempts = @v_numofattempts,
				lastattemptdate = GETDATE(),
				returncode=@v_error,
				standardmsgcode=@v_msgcode,
				standardmsgsubcode=@v_msgsubcode,
				returnmsgdesc=@v_errordesc,
				processingind = 0
			WHERE backgroundprocesskey = @v_backgroundprocesskey
		  END
	  END--@v_error = -1
	  ELSE IF @v_error = 0 BEGIN
	      SELECT @v_numofattempts2 = COALESCE(numofattempts,0) + 1
		  FROM backgroundprocess
		  WHERE backgroundprocesskey = @v_backgroundprocesskey

		  INSERT INTO backgroundprocess_history (backgroundprocesskey,jobtypecode,storedprocname,reqforgetprodind,failgetprodind,numofattempts,jobkey,
				 returncode,standardmsgcode,standardmsgsubcode,returnmsgdesc,
				 key1,key2,key3,textvalue1,textvalue2,textvalue3,textvalue4,
			     integervalue1,integervalue2,integervalue3,integervalue4,
				 floatvalue1,floatvalue2,floatvalue3,floatvalue4,
			     rowlinkkey,rowlinksortorder,createddate,processeddate,lastuserid,lastmaintdate)
		  SELECT @v_backgroundprocesskey,jobtypecode,storedprocname,reqforgetprodind,0,@v_numofattempts2,0,
				 @v_error,@v_msgcode,@v_msgsubcode,@v_errordesc,
				 key1,key2,key3,textvalue1,textvalue2,textvalue3,textvalue4,
			     integervalue1,integervalue2,integervalue3,integervalue4,
				 floatvalue1,floatvalue2,floatvalue3,floatvalue4,
			     rowlinkkey,rowlinksortorder,createdate,GETDATE(),lastuserid,lastmaintdate
			     FROM backgroundprocess where backgroundprocesskey = @v_backgroundprocesskey

		  SELECT @v_jobtypecode = jobtypecode, @v_key1 = key1, @v_key2 = COALESCE(key2,0), @v_key3 = COALESCE(key3,0) FROM backgroundprocess
			 WHERE backgroundprocesskey = @v_backgroundprocesskey

		  DELETE FROM backgroundprocess where backgroundprocesskey = @v_backgroundprocesskey

		  SET @v_count2 = 0

		  SELECT @v_count2 = COUNT(*)
		    FROM backgroundprocess_history
		   WHERE jobtypecode = @v_jobtypecode AND key1 = @v_key1 AND COALESCE(key2,0) = @v_key2 AND COALESCE(key3,0) = @v_key3 AND failgetprodind = 1

	      IF @v_count2 > 0 BEGIN
			  UPDATE backgroundprocess_history
			     SET failgetprodind = 0
			   WHERE jobtypecode = @v_jobtypecode AND key1 = @v_key1 AND COALESCE(key2,0) = @v_key2 AND COALESCE(key3,0) = @v_key3 AND failgetprodind = 1
		  END
	  END --@v_error = 1
	  ELSE BEGIN
		  SET @o_error_code = -1
		  SET @v_errordesc = 'There was an error processing stored procedure: ' + @v_storedprocname
	  END

	  SET @v_counter1 = @v_counter1 + 1
  END

  IF @v_count > @i_numofrows BEGIN
    DROP TABLE #backgroundprocessrows_temp
    DROP TABLE #backgroundprocessrows
    DROP TABLE #backgroundprocessrows_temp2

    -- Call itself again to process remaining rows
    GOTO DOIT_AGAIN
  END
  ELSE BEGIN
	  IF @i_bookkey IS NOT NULL AND @i_bookkey > 0 BEGIN
		  SET @v_count2 = 0

		  SELECT @v_count2 = COUNT(*) FROM backgroundprocess WHERE key1 = @i_bookkey

		  IF @v_count2 > 0 BEGIN
		      SET @v_count = 0

			  SELECT @v_count = COUNT(*)
			    FROM backgroundprocess
			   WHERE key1 = @i_bookkey AND processingind = 0 AND lastattemptdate <= @i_failedattemptinterval

			  IF @v_count > 0 AND @v_count2 = @v_count BEGIN
				  SET @o_error_code = -1
				  SET @o_error_desc = 'This title for bookkey: ' + CONVERT(VARCHAR(20),@i_bookkey) + ' has failed Get Product processes and cannot be sent to the cloud until these have been resolved.'
			  END
			  ELSE BEGIN
			    SET @v_count3 = 0

				  SELECT @v_count3 = COUNT(*)
			      FROM backgroundprocess WHERE key1 = @i_bookkey AND processingind = 1

			    IF @v_count > 0 AND @v_count3 = @v_count BEGIN
					  SET @o_error_code = -1
					  SET @o_error_desc = 'This title for bookkey: ' + CONVERT(VARCHAR(20),@i_bookkey) + ' cannot be sent to the cloud because there are currently processes running that are required to finish first.'
				  END
			  END
		  END  --IF @v_count2 > 0
	  END  --IF @i_bookkey IS NOT NULL AND @i_bookkey > 0 BEGIN
  END --@v_count < @i_numofrows

GO
GRANT EXEC ON qutl_processbackgroundjobs TO PUBLIC
GO
