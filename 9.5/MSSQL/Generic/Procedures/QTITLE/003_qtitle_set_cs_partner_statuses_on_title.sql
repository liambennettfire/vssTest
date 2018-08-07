IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qtitle_set_cspartnerstatuses_on_title')
  BEGIN
    PRINT 'Dropping Procedure qtitle_set_cspartnerstatuses_on_title'
    DROP  Procedure  qtitle_set_cspartnerstatuses_on_title
  END

GO

PRINT 'Creating Procedure qtitle_set_cspartnerstatuses_on_title'
GO

CREATE PROCEDURE qtitle_set_cspartnerstatuses_on_title
 (@i_bookkey            integer,
  @i_userid             varchar(30),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qtitle_set_cspartnerstatus_on_title
**  Desc: 
**
**              
**    Return values: 
**
**    Called by:  Cloud Sync to TM 
**              
**    Parameters:
**    Input              
**    ----------         
**    bookkey - bookkey of title - Required
**    userid - Userid of user causing write to bookdetail - Required   
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
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    07/08/2013  Kusum           Case 24571
**    3/19/14		Jen				efficiency improvements without changing the logic dramatically (changes denoted with --jl comment    
**	  9/17/15		Jen				calls to the inner procedures were not using the OUTPUT tag on the error arguments, so errors were not being captured properly
**    2/23/16   Colman    check for null cspartnerstatuscode sums. Case 36368
*******************************************************************************/

 -- verify that all required values are filled in
  IF @i_userid IS NULL OR ltrim(rtrim(@i_userid)) = '' BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'Unable to update bookdetail: userid is empty.'
     RETURN
  END   

  IF @i_bookkey IS NULL OR @i_bookkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update bookdetail: bookkey is empty.'
    RETURN
  END 

  SET @o_error_code = 0
  SET @o_error_desc = ''

  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_csmetadatastatuscode INT,
          @v_cspartnerstatuscode  INT,
          @v_assetkey INT,
          @v_count  INT,
          @v_count2 INT,
          @v_count3 INT,
          @v_count4 INT,
          @v_count5 INT,
          @v_count6 INT,
          @v_count7 INT,
          @v_taqelementkey  INT

  DECLARE taqprojectlement_cur CURSOR FOR
    SELECT taqelementkey
    FROM taqprojectelement t
	join gentables g
	on t.taqelementtypecode = g.datacode
	and g.tableid = 287
	and gen1ind = 1
    WHERE bookkey = @i_bookkey
    ORDER BY taqelementkey ASC
        
  OPEN taqprojectlement_cur

  FETCH NEXT FROM taqprojectlement_cur INTO @v_taqelementkey
  
  WHILE (@@FETCH_STATUS = 0) 
  BEGIN
    EXEC qtitle_set_cspartnerstatus_on_asset @v_taqelementkey,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT

    IF @o_error_code = -1 BEGIN
      RETURN
    END

    FETCH NEXT FROM taqprojectlement_cur INTO @v_taqelementkey
  END	/* taqprojectlement cursor */
	
	CLOSE taqprojectlement_cur 
  DEALLOCATE taqprojectlement_cur

  SELECT @v_count = 0
  SELECT @v_count5 = 0			--jl
  SELECT @v_count2 = 0			--jl
  SELECT @v_count3 = 0			--jl
  SELECT @v_count4 = 0			--jl
  SELECT @v_count6 = 0			--jl
  SELECT @v_count7 = 0			--jl

--jl 3/18/14 consolidate these counts to count all metadata and nonmetadata CS assets in one call
--variables were kept the same except @v_count7 was added since the original code reused @v_count.  @v_count is set to @v_count7 lower in the code	
  SELECT @v_count = isnull((sum (case when isnull(g.qsicode,0) = 3 then 1 else 0 end)),0),									--metadata
		@v_count5 = count(*),																					                                          --all CS assets
		@v_count7 = isnull((sum (case when isnull(g.qsicode,0) <> 3 then 1 else 0 end)),0),                               --all non metadata CS assets
		@v_count2 = isnull((sum (case when isnull(g.qsicode,0) <> 3 AND cspartnerstatuscode = 1 then 1 else 0 end)),0),		--non metadata, Not Distributed
		@v_count3 = isnull((sum (case when isnull(g.qsicode,0) <> 3 AND cspartnerstatuscode = 5 then 1 else 0 end)),0),		--non metadata, Not up to date at all selected Partners
		@v_count4 = isnull((sum (case when isnull(g.qsicode,0) <> 3 AND cspartnerstatuscode = 4 then 1 else 0 end)),0),		--non metadata, Distributed to all selected Partners
		@v_count6 = isnull((sum (case when isnull(g.qsicode,0) <> 3 AND cspartnerstatuscode = 3 then 1 else 0 end)),0)		--non metadata, scheduled
    FROM taqprojectelement t
	join gentables g
	on t.taqelementtypecode = g.datacode
	and g.tableid = 287
	and gen1ind = 1			--only CS asset elementtypes
   WHERE bookkey = @i_bookkey 
--     AND taqelementtypecode = (SELECT datacode FROM gentables WHERE tableid = 287 AND qsicode = 3)		--jl

  IF @v_count > 0 BEGIN
     SELECT @v_cspartnerstatuscode = cspartnerstatuscode
       FROM taqprojectelement 
      WHERE bookkey = @i_bookkey AND taqelementtypecode = (SELECT datacode FROM gentables WHERE tableid = 287 AND qsicode = 3)  --Metadata

     UPDATE bookdetail
        SET csmetadatastatuscode = @v_cspartnerstatuscode,
            lastuserid = @i_userid, lastmaintdate = getdate()
      WHERE bookkey = @i_bookkey
   
     SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
     IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to update bookdetail (csmetadatastatuscode) (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
     END
  END

--  SELECT @v_count5 = 0		--jl
--
--  SELECT @v_count5 = count(*)
--    FROM taqprojectelement t
--	join gentables g
--	on t.taqelementtypecode = g.datacode
--	and g.tableid = 287
--	and gen1ind = 1
--   WHERE bookkey = @i_bookkey 

  IF @v_count = @v_count5 BEGIN
    -- only element for this bookkey is metadata
    -- set csassetstatuscode = 'Not Applicable'
     UPDATE bookdetail
         SET csassetstatuscode = 6,
             lastuserid = @i_userid, lastmaintdate = getdate()
       WHERE bookkey = @i_bookkey
     
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
         SET @o_error_code = -1
         SET @o_error_desc = 'Unable to update bookdetail (csassetstatuscode) (' + cast(@error_var AS VARCHAR) + ').'
         RETURN
      END
      RETURN
  END 
  
  SELECT @v_count = @v_count7		--jl

--  SELECT @v_count = count(*)		--jl
--    FROM taqprojectelement t
--	join gentables g
--	on t.taqelementtypecode = g.datacode
--	and g.tableid = 287
--	and gen1ind = 1
--   WHERE bookkey = @i_bookkey
--     AND (taqelementtypecode <> (SELECT datacode FROM gentables WHERE tableid = 287 AND qsicode = 3))   --Non-metadata assets

--  SELECT @v_count2 = 0			--jl
--
--  SELECT @v_count2 = count(*)
--    FROM taqprojectelement t
--	join gentables g
--	on t.taqelementtypecode = g.datacode
--	and g.tableid = 287
--	and gen1ind = 1
--   WHERE bookkey = @i_bookkey 
--     AND (taqelementtypecode <> (SELECT datacode FROM gentables WHERE tableid = 287 AND qsicode = 3)  --Metadata assets
--     AND  cspartnerstatuscode = 1 )

  IF @v_count > 0 AND (@v_count = @v_count2) BEGIN 
      -- all taqprojectelement.cspartnerstatuscode for this bookkey for non metadata elements = 1(Not Distributed)
      UPDATE bookdetail
         SET csassetstatuscode = 1,
             lastuserid = @i_userid, lastmaintdate = getdate()
       WHERE bookkey = @i_bookkey
     
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
         SET @o_error_code = -1
         SET @o_error_desc = 'Unable to update bookdetail (csassetstatuscode) (' + cast(@error_var AS VARCHAR) + ').'
         RETURN
      END
  END  -- all taqprojectelement.cspartnerstatuscode for this bookkey for non metadata elements = 1
  ELSE BEGIN  
    -- any taqprojectelement.cspartnerstatuscode for this bookkey for non metadata elements = 5 (Not up to date at all selected Partners)
--    SELECT @v_count3 = 0			--jl
--
--    SELECT @v_count3 = count(*)
--      FROM taqprojectelement t
--		join gentables g
--		on t.taqelementtypecode = g.datacode
--		and g.tableid = 287
--		and gen1ind = 1
--     WHERE bookkey = @i_bookkey 
--       AND (taqelementtypecode <> (SELECT datacode FROM gentables WHERE tableid = 287 AND qsicode = 3)
--       AND  cspartnerstatuscode = 5 )

    IF @v_count3 > 0 BEGIN
       UPDATE bookdetail
          SET csassetstatuscode = 5, -- changed from from 1 to 5 - ct 12/14/2012
              lastuserid = @i_userid, lastmaintdate = getdate()
        WHERE bookkey = @i_bookkey
   
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to update bookdetail (csassetstatuscode) (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END
    END -- any taqprojectelement.cspartnerstatuscode for this bookkey for non metadata elements = 5
    ELSE BEGIN 
      -- all taqprojectelement.cspartnerstatuscode for this bookkey for non metadata elements = 4(Distributed to all selected Partners)
--      SELECT @v_count4 = 0			--jl
--
--      SELECT @v_count4 = count(*)
--        FROM taqprojectelement t
--		join gentables g
--		on t.taqelementtypecode = g.datacode
--		and g.tableid = 287
--		and gen1ind = 1
--       WHERE bookkey = @i_bookkey 
--         AND (taqelementtypecode <> (SELECT datacode FROM gentables WHERE tableid = 287 AND qsicode = 3)
--         AND  cspartnerstatuscode = 4 )

      IF @v_count > 0 AND (@v_count = @v_count4) BEGIN -- all taqprojectelement.cspartnerstatuscode for this bookkey for non metadata elements = 4
        UPDATE bookdetail
           SET csassetstatuscode = 4, --  -- changed from from 1 to 4 - ct 12/14/2012
               lastuserid = @i_userid, lastmaintdate = getdate()
         WHERE bookkey = @i_bookkey
       
        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
           SET @o_error_code = -1
           SET @o_error_desc = 'Unable to update bookdetail (csassetstatuscode) (' + cast(@error_var AS VARCHAR) + ').'
           RETURN
        END
      END  -- all taqprojectelement.cspartnerstatuscode for this bookkey for non metadata elements = 4
    ELSE BEGIN  --KB 7/8/13 Case 24571 
      -- all taqprojectelement.cspartnerstatuscode for this bookkey for non metadata elements = 3 (Scheduled)
--      SELECT @v_count6 = 0				--jl
--
--      SELECT @v_count6 = count(*)
--        FROM taqprojectelement t
--		join gentables g
--		on t.taqelementtypecode = g.datacode
--		and g.tableid = 287
--		and gen1ind = 1
--       WHERE bookkey = @i_bookkey 
--         AND (taqelementtypecode <> (SELECT datacode FROM gentables WHERE tableid = 287 AND qsicode = 3)
--         AND  cspartnerstatuscode = 3 )

      IF @v_count > 0 AND (@v_count = @v_count6) BEGIN -- all taqprojectelement.cspartnerstatuscode for this bookkey for non metadata elements = 3
        UPDATE bookdetail
           SET csassetstatuscode = 3, --Scheduled
               lastuserid = @i_userid, lastmaintdate = getdate()
         WHERE bookkey = @i_bookkey
       
        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
           SET @o_error_code = -1
           SET @o_error_desc = 'Unable to update bookdetail (csassetstatuscode) (' + cast(@error_var AS VARCHAR) + ').'
           RETURN
        END
      END  -- all taqprojectelement.cspartnerstatuscode for this bookkey for non metadata elements = 3
    ELSE BEGIN
      -- mixture of statuses - Sent to CS  - 2 (Mixed)
      UPDATE bookdetail
         SET csassetstatuscode = 2,     -- Mixed Status, See Partner Detail
             lastuserid = @i_userid, lastmaintdate = getdate()
       WHERE bookkey = @i_bookkey
       
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
         SET @o_error_code = -1
         SET @o_error_desc = 'Unable to update bookdetail (csassetstatuscode) (' + cast(@error_var AS VARCHAR) + ').'
         RETURN
      END
    END  -- mixture of statuses - Sent to CS but not all sent to partners - 3 (Scheduled for Distributions)
   END
  END
 END
 RETURN 
GO 

GRANT EXEC ON qtitle_set_cspartnerstatuses_on_title TO PUBLIC
GO