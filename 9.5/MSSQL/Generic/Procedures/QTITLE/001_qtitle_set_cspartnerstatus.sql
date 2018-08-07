IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qtitle_set_cspartnerstatus')
  BEGIN
    PRINT 'Dropping Procedure qtitle_set_cspartnerstatus'
    DROP  Procedure  qtitle_set_cspartnerstatus
  END

GO

PRINT 'Creating Procedure qtitle_set_cspartnerstatus'
GO

CREATE PROCEDURE qtitle_set_cspartnerstatus
 (@i_taqelementkey      integer,
  @i_userid             varchar(30),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_set_cspartnerstatus
**  Desc: 
**
**              
**    Return values: 
**
**    Called by:   qtitle_set_cspartnerstatus_on_asset
**              
**    Parameters:
**    Input              
**    ----------         
**    taqelementkey - for given element - Required
**    userid - Userid of user causing write to taqprojectelement - Required 
**  
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Kusum Basra
**    Date: 10/30/2012
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    7/2/2013 Kusum            CASE 24535
**                              Instead of comparing the "Latest Actual Distribute Date" 
**                              to the "Last Upload Date", the "Last Processed Date"
**                              will be compared to the "Last Upload Date"
**    3/19/14	Jen				efficiency improvements without changing the logic dramatically (changes denoted with --jl comment
**	  9/22/15	Jen				fixes made to handle lingering unactual distributions causing partners to not get updates through the outbox                         
*******************************************************************************/

  -- verify that all required values are filled in
  IF @i_userid IS NULL OR ltrim(rtrim(@i_userid)) = '' BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'Unable to update taqprojectelement: userid is empty.'
     RETURN
  END   

  IF @i_taqelementkey IS NULL OR @i_taqelementkey = 0 BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'Unable to update taqprojectelement: taqelementkey is empty.'
     RETURN
  END

  SET @o_error_code = 0
  SET @o_error_desc = ''

  DECLARE @error_var    INT,
          @v_csmetadatastatuscode INT,
          @v_cspartnerstatuscode  INT,
          @v_taqelementtypecode INT,
          @v_bookkey INT,
          @v_count  INT,
          @v_count2 INT,
          @v_count3 INT,
          @v_count4 INT,
          @v_taqelementkey  INT,
          @v_latestassetchangedate DATETIME,
          @v_latestuploaddate DATETIME,
          @v_partnercontactkey  INT,
          @v_pendingdistribution  TINYINT,
		  @v_latestpendingdate	DATETIME,
--          @v_latestactualdistributedate DATETIME,
--          @v_latest_actual_distribute_date_found TINYINT,
          @v_latestactualprocesseddate DATETIME,    
          @v_latest_distribution_processed_date_found TINYINT,
          @v_date_var CHAR(8)

  SELECT @v_taqelementtypecode = taqelementtypecode, @v_bookkey = bookkey
    FROM taqprojectelement
   WHERE taqelementkey = @i_taqelementkey

  IF @v_taqelementtypecode = (SELECT datacode FROM gentables WHERE tableid = 287 AND qsicode = 3) BEGIN
    -- metadata asset
    -- latest asset change date
    SELECT @v_latestassetchangedate = csmetadatalastupdate
      FROM bookdetail
     WHERE bookkey = @v_bookkey

    IF @v_latestassetchangedate IS NULL BEGIN
        SET @v_date_var ='01011990'
        SET @v_latestassetchangedate = CONVERT(datetime,RIGHT(@v_date_var,4)+LEFT(@v_date_var,2)+SUBSTRING(@v_date_var,3,2), 101)
    END 

    -- latest upload date
    SELECT @v_count = 0

    SELECT @v_count = count(*), @v_latestuploaddate = MAX(activedate) --jl  if no rows retrieved, count returns 0, max returns null
      FROM taqprojecttask 
     WHERE taqelementkey = @i_taqelementkey
       AND datetypecode = (select datetypecode from datetype where qsicode = 16)--12)
       and actualind = 1
	   and bookkey = @v_bookkey			--jl added to improve index usage (ever so slightly)

--    IF @v_count > 0 BEGIN  --jl
--       SELECT @v_latestuploaddate = MAX(activedate) 
--        FROM taqprojecttask 
--       WHERE taqelementkey = @i_taqelementkey
--         AND datetypecode = (select datetypecode from datetype where qsicode = 16)--12)
--         and actualind = 1
--    END

    IF (@v_latestuploaddate < @v_latestassetchangedate) OR (@v_count = 0 AND @v_latestassetchangedate IS NOT NULL) BEGIN
      UPDATE taqprojectelementpartner
         SET cspartnerstatuscode = 5,        --Not up to date
             lastuserid = @i_userid,
             lastmaintdate = getdate()
       WHERE assetkey = @i_taqelementkey
	     and bookkey = @v_bookkey			--jl added to improve index usage (ever so slightly)

      SELECT @error_var = @@ERROR
      IF @error_var <> 0 BEGIN
         SET @o_error_code = -1
         SET @o_error_desc = 'Unable to update taqprojectelementpartner (' + cast(@error_var AS VARCHAR) + ').'
         RETURN
      END
      RETURN
    END 
  END -- metadata asset
  ELSE BEGIN  
    -- not metadata asset
    SELECT @v_latestassetchangedate = MAX(activedate)
      FROM taqprojecttask
     WHERE taqelementkey = @i_taqelementkey
       AND datetypecode = (select datetypecode from datetype where qsicode = 16)--12)
       and actualind = 1
	   and bookkey = @v_bookkey			--jl added to improve index usage (ever so slightly)
  END

  --continues on for all assets - metadata continues here if the @v_latestuploaddate is not earlier than @v_latestassetchangedate
  DECLARE taqprojectlementpartner_cur CURSOR FOR
    SELECT partnercontactkey
      FROM taqprojectelementpartner 
     WHERE assetkey = @i_taqelementkey
              
  OPEN taqprojectlementpartner_cur

  FETCH NEXT FROM taqprojectlementpartner_cur INTO @v_partnercontactkey
      
  WHILE (@@FETCH_STATUS = 0) 
  BEGIN
    SELECT @v_count = 0
--    SELECT @v_latest_actual_distribute_date_found = 0  --KB #24534
    SELECT @v_latest_distribution_processed_date_found = 0
    SELECT @v_pendingdistribution = 0
        
    SELECT @v_count = count(*), @v_latestpendingdate = max(activedate)
      FROM taqprojecttask
     WHERE taqelementkey = @i_taqelementkey
       AND globalcontactkey = @v_partnercontactkey
       AND datetypecode = (SELECT datetypecode FROM datetype WHERE qsicode = 11)  
       AND (actualind = 0 OR actualind IS NULL)
	   and bookkey = @v_bookkey			--jl added to improve index usage (ever so slightly)

    IF @v_count > 0 BEGIN
      SELECT @v_pendingdistribution = 1
    END
    ELSE BEGIN
      SELECT @v_pendingdistribution = 0
    END

    SELECT @v_count2 = 0

              --KB #24535 Select Latest Processed Date instead of Latest Actual Distribute Date
    SELECT @v_count2 = count(*), @v_latestactualprocesseddate = MAX(activedate)  --same variable being set to 2 values, @v_latestactualprocesseddate = MAX(originaldate)		--jl
      FROM taqprojecttask
     WHERE taqelementkey = @i_taqelementkey
       AND globalcontactkey = @v_partnercontactkey
       AND datetypecode IN (SELECT datetypecode FROM datetype WHERE distributionprocessedind = 1)  --KB #24535
       AND actualind = 1
	   and bookkey = @v_bookkey			--jl added to improve index usage (ever so slightly)

    IF @v_count2 = 0 BEGIN
       SET @v_latest_distribution_processed_date_found = 0
    END
    ELSE BEGIN
--      --KB #24535 Select Latest Processed Date instead of Latest Actual Distribute Date
--      SELECT @v_latestactualprocesseddate = MAX(activedate)				--jl moved the max up to the select above to reduce taqprojecttask drag
--        FROM taqprojecttask
--       WHERE taqelementkey = @i_taqelementkey
--         AND globalcontactkey = @v_partnercontactkey
--         AND datetypecode IN (SELECT datetypecode FROM datetype WHERE distributionprocessedind = 1)  --KB #24535
--         AND actualind = 1

      IF @v_latestactualprocesseddate IS NOT NULL BEGIN
        SET @v_latest_distribution_processed_date_found = 1
      END
      ELSE BEGIN
        SET @v_latest_distribution_processed_date_found = 0
      END
    END

    IF @v_latest_distribution_processed_date_found = 0 AND @v_pendingdistribution = 0 BEGIN  
    -- There were distribute activity that was cancelled or failed; no distributions have happened
      UPDATE taqprojectelementpartner
         SET cspartnerstatuscode = 1,        --Not Distributed
             lastuserid = @i_userid,
             lastmaintdate = getdate()
       WHERE assetkey = @i_taqelementkey
         AND partnercontactkey = @v_partnercontactkey
	     and bookkey = @v_bookkey			--jl added to improve index usage (ever so slightly)

      SELECT @error_var = @@ERROR
      IF @error_var <> 0 BEGIN
         SET @o_error_code = -1
         SET @o_error_desc = 'Unable to update taqprojectelementpartner (' + cast(@error_var AS VARCHAR) + ').'
         RETURN
      END
    END
    ELSE IF @v_latest_distribution_processed_date_found = 1 BEGIN
    -- Latest Actual Distribute Date found

    -- KB #22596 Interim solution until TMM Cloud Sync can be modifed to return expected value
    -- as currently the correct values are not being returned 
 
    --determine when the distribution was sent. This is the original date for the distribute asset task. If sent before the change date then need to resend
    -- KB #24535 - determine when distribution was processed (and not when distribution was sent)
--      SELECT @v_latestactualprocesseddate = MAX(originaldate)		--jl max moved up to single select from this table for this same where clause to reduce taqprojecttask access
--        FROM taqprojecttask
--       WHERE taqelementkey = @i_taqelementkey
--         AND globalcontactkey = @v_partnercontactkey
--         AND datetypecode IN (SELECT datetypecode FROM datetype WHERE distributionprocessedind = 1) --KB #24535
--         AND actualind = 1


      IF @v_latestassetchangedate IS NOT NULL AND (@v_latestassetchangedate < @v_latestactualprocesseddate) BEGIN
      -- this asset was processed after the most recent change
         UPDATE taqprojectelementpartner
            SET cspartnerstatuscode = 4,        --Changed to 'All Distributions Processed' from 'Distributed' KB #24535
                lastuserid = @i_userid,
                lastmaintdate = getdate()
          WHERE assetkey = @i_taqelementkey
            AND partnercontactkey = @v_partnercontactkey
	        and bookkey = @v_bookkey			--jl added to improve index usage (ever so slightly)

         SELECT @error_var = @@ERROR
         IF @error_var <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to update taqprojectelementpartner (' + cast(@error_var AS VARCHAR) + ').'
            RETURN
         END
       END -- this asset was processed after the most recent change
       ELSE IF (@v_latestassetchangedate > @v_latestactualprocesseddate) BEGIN
        IF @v_pendingdistribution = 1 and @v_latestpendingdate is not null and @v_latestpendingdate > @v_latestactualprocesseddate BEGIN
        -- Asset is up to date in cloud and there is a pending distribution
           UPDATE taqprojectelementpartner
              SET cspartnerstatuscode = 3,        --Scheduled
                  lastuserid = @i_userid,
                  lastmaintdate = getdate()
            WHERE assetkey = @i_taqelementkey
              AND partnercontactkey = @v_partnercontactkey
	          and bookkey = @v_bookkey			--jl added to improve index usage (ever so slightly)

           SELECT @error_var = @@ERROR
           IF @error_var <> 0 BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'Unable to update taqprojectelementpartner (' + cast(@error_var AS VARCHAR) + ').'
              RETURN
           END
        END -- Asset is up to date in cloud and there is a pending distribution
        ELSE BEGIN
        -- Changes have been made and no distributions are scheduled 
          UPDATE taqprojectelementpartner
             SET cspartnerstatuscode = 5,        --Not up to Date
                 lastuserid = @i_userid,
                 lastmaintdate = getdate()
           WHERE assetkey = @i_taqelementkey
             AND partnercontactkey = @v_partnercontactkey
	         and bookkey = @v_bookkey			--jl added to improve index usage (ever so slightly)

          SELECT @error_var = @@ERROR
          IF @error_var <> 0 BEGIN
           SET @o_error_code = -1
           SET @o_error_desc = 'Unable to update taqprojectelementpartner (' + cast(@error_var AS VARCHAR) + ').'
           RETURN
          END
        END -- Changes have been made and no distributions are scheduled
       END 
       END -- Changed to Latest Actual Processed Date from Latest Actual Distribute Date found KB 7/2/2013 Case24535 
			ELSE IF @v_pendingdistribution = 1 BEGIN
			   UPDATE taqprojectelementpartner
            SET cspartnerstatuscode = 3,        --Scheduled
                lastuserid = @i_userid,
                lastmaintdate = getdate()
          WHERE assetkey = @i_taqelementkey
            AND partnercontactkey = @v_partnercontactkey
	        and bookkey = @v_bookkey			--jl added to improve index usage (ever so slightly)

         SELECT @error_var = @@ERROR
         IF @error_var <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to update taqprojectelementpartner (' + cast(@error_var AS VARCHAR) + ').'
            RETURN
         END
       END
        
       FETCH NEXT FROM taqprojectlementpartner_cur INTO @v_partnercontactkey
     END	/* taqprojectlementpartner_cur cursor */
  	
	   CLOSE taqprojectlementpartner_cur 
     DEALLOCATE taqprojectlementpartner_cur
 RETURN
GO 

GRANT EXEC ON qtitle_set_cspartnerstatus TO PUBLIC
GO
