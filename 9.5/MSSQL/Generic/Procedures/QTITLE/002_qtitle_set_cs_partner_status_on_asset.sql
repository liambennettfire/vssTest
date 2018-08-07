IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qtitle_set_cspartnerstatus_on_asset')
  BEGIN
    PRINT 'Dropping Procedure qtitle_set_cspartnerstatus_on_asset'
    DROP  Procedure  qtitle_set_cspartnerstatus_on_asset
  END

GO

PRINT 'Creating Procedure qtitle_set_cspartnerstatus_on_asset'
GO

CREATE PROCEDURE qtitle_set_cspartnerstatus_on_asset
 (@i_taqelementkey      integer,
  @i_userid             varchar(30),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qtitle_set_cspartnerstatus_on_asset
**  Desc: 
**
**              
**    Return values: 
**
**    Called by:   qtitle_set_cspartnerstatus_on_title
**              
**    Parameters:
**    Input              
**    ----------         
**    taqelementkey - for given element - Required
**    userid - Userid of user causing write to taqprojectelement - Required   
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
**    07/08/2013 Kusum          Case 24571
**    3/19/14	Jen				efficiency improvements without changing the logic dramatically (changes denoted with --jl comment                         
**	  9/17/15		Jen				calls to the inner procedures were not using the OUTPUT tag on the error arguments, so errors were not being captured properly                     
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
          @v_count8 INT,
		  @v_bookkey	int			--jl

  EXEC qtitle_set_cspartnerstatus @i_taqelementkey,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT
 
  IF @o_error_code = -1 BEGIN
     RETURN
  END
  
  select @v_bookkey = bookkey		--jl
	from taqprojectelement
	where taqelementkey = @i_taqelementkey

  SELECT @v_count = 0
   
  SELECT @v_count = count(*)
    FROM taqprojectelementpartner 
   WHERE assetkey = @i_taqelementkey 
     and bookkey = @v_bookkey			--jl index help

  IF @v_count = 0 BEGIN   --no taqprojectelementpartner rows exist
     UPDATE taqprojectelement
        SET cspartnerstatuscode = 1,    --Not Distributed
            lastuserid = @i_userid, lastmaintdate = getdate()
      WHERE taqelementkey = @i_taqelementkey
        and bookkey = @v_bookkey			--jl index help

     SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
     IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to update taqprojectelement (cspartnerstatuscode) (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
     END
  END  -- no taqprojectelementpartner records exist
  ELSE BEGIN  --taqprojectelementpartner rows exist
    SELECT @v_count7 = 0
    SELECT @v_count5 = 0
    SELECT @v_count2 = 0
    SELECT @v_count6 = 0
    SELECT @v_count8 = 0
    SELECT @v_count3 = 0
--jl consolidate the counts so this table is only queried once

    SELECT  @v_count7 = sum(case when cspartnerstatuscode = 1 then 1 else 0 end),	-- Case 24571 KB 07/08/2013  - (Not Distributed)and partners are receiving resends
			@v_count5 = COUNT(*),															--total partnes receiving Resends
			@v_count2 = sum(case when cspartnerstatuscode = 5 then 1 else 0 end),			--(Not up to date at all selected partners)
			@v_count6 = sum(case when cspartnerstatuscode = 4 then 1 else 0 end),			--(Distributed to all selected partners)
			@v_count8 = sum(case when cspartnerstatuscode = 3 then 1 else 0 end)			--(Scheduled for Distributions)
      FROM taqprojectelementpartner 
     WHERE assetkey = @i_taqelementkey
       AND resendind = 1
--       AND cspartnerstatuscode = 1 --Not Distributed
       and bookkey = @v_bookkey			--jl index help

	set @v_count3 = @v_count5		--jl both variables were getting the total count where resendind = 1, regardless of cspartnerstatuscode

    --All cspartnerstatuscode = 1 
    IF @v_count = @v_count7 BEGIN
      UPDATE taqprojectelement
         SET cspartnerstatuscode = 1,    --(not distributed)
             lastuserid = @i_userid, lastmaintdate = getdate()
       WHERE taqelementkey = @i_taqelementkey
         and bookkey = @v_bookkey			--jl index help

       SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
       IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to update taqprojectelement (cspartnerstatuscode) (' + cast(@error_var AS VARCHAR) + ').'
          RETURN
       END
    END -- All taqprojectelementpartner rows have cspartnerstatuscode = 1
    ELSE BEGIN  -- All taqprojectelementpartner rows do not have cspartnerstatuscode = 1
--      SELECT @v_count5 = 0		--jl
--
--      SELECT @v_count5 = COUNT(*)
--        FROM taqprojectelementpartner 
--       WHERE assetkey = @i_taqelementkey
--         AND resendind = 1
--         and bookkey = @v_bookkey			--jl index help

      --No partner is receiving sends
      IF @v_count5 = 0 BEGIN
        UPDATE taqprojectelement
           SET cspartnerstatuscode = 4,    --(distributed to all selected partners)
               lastuserid = @i_userid, lastmaintdate = getdate()
         WHERE taqelementkey = @i_taqelementkey
           and bookkey = @v_bookkey			--jl index help

         SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
         IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to update taqprojectelement (cspartnerstatuscode) (' + cast(@error_var AS VARCHAR) + ').'
            RETURN
         END
      END
    ELSE BEGIN -- @v_count5 > 0 (partners are receiving sends)
--      SELECT @v_count2 = 0			--jl
--      -- partners are receiving sends and not up to date at all partners
--      SELECT @v_count2 = count(*)
--        FROM taqprojectelementpartner 
--       WHERE assetkey = @i_taqelementkey
--         AND cspartnerstatuscode = 5
--         AND resendind = 1

      IF @v_count2 > 0 BEGIN
        UPDATE taqprojectelement
          SET cspartnerstatuscode = 5,   -- (Not up to date at all selected partners)
              lastuserid = @i_userid, lastmaintdate = getdate()
        WHERE taqelementkey = @i_taqelementkey
          and bookkey = @v_bookkey			--jl index help

         SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
         IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to update taqprojectelement (cspartnerstatuscode) (' + cast(@error_var AS VARCHAR) + ').'
            RETURN
         END
      END  --any taqprojectelementpartner.cspartnerstatuscode for this elementkey = 5
      ELSE BEGIN --check if all taqprojectelementpartner.cspartnerstatuscode for this elementkey = 4
--        SELECT @v_count3 = 0		--jl
--
--        SELECT @v_count3 = count(*)
--          FROM taqprojectelementpartner 
--         WHERE assetkey = @i_taqelementkey 
--           AND resendind = 1
--		   and bookkey = @v_bookkey			--jl index help
--
--        SELECT @v_count6 = 0
--
--        SELECT @v_count6 = COUNT(*)
--          FROM taqprojectelementpartner 
--         WHERE assetkey = @i_taqelementkey 
--           AND resendind = 1
--           AND cspartnerstatuscode = 4
--		   and bookkey = @v_bookkey			--jl index help

        IF @v_count6 = @v_count3 BEGIN
          UPDATE taqprojectelement
            SET cspartnerstatuscode = 4,   --(Distributed to all selected partners)
                lastuserid = @i_userid, lastmaintdate = getdate()
          WHERE taqelementkey = @i_taqelementkey
            and bookkey = @v_bookkey			--jl index help

           SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
           IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'Unable to update taqprojectelement (cspartnerstatuscode) (' + cast(@error_var AS VARCHAR) + ').'
              RETURN
           END
        END --all taqprojectelementpartner.cspartnerstatuscode for this elementkey = 4
        ELSE BEGIN   --Case 24571 KB 7/8/13 check if all taqprojectelementpartner.cspartnerstatuscode for this elementkey = 3
--          SELECT @v_count3 = 0		--jl
--
--          SELECT @v_count3 = count(*)
--            FROM taqprojectelementpartner 
--           WHERE assetkey = @i_taqelementkey 
--             AND resendind = 1
--
--          SELECT @v_count8 = 0
--
--          SELECT @v_count8 = COUNT(*)
--            FROM taqprojectelementpartner 
--           WHERE assetkey = @i_taqelementkey 
--             AND resendind = 1
--             AND cspartnerstatuscode = 3

          IF @v_count8 = @v_count3 BEGIN
            UPDATE taqprojectelement
              SET cspartnerstatuscode = 3,   --(Scheduled for Distributions)
                  lastuserid = @i_userid, lastmaintdate = getdate()
            WHERE taqelementkey = @i_taqelementkey
              and bookkey = @v_bookkey			--jl index help

             SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
             IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
                SET @o_error_code = -1
                SET @o_error_desc = 'Unable to update taqprojectelement (cspartnerstatuscode) (' + cast(@error_var AS VARCHAR) + ').'
                RETURN
             END
          END --all taqprojectelementpartner.cspartnerstatuscode for this elementkey = 3
          ELSE BEGIN
					  UPDATE taqprojectelement
						 SET cspartnerstatuscode = 2,   --(Mixed Status,See Parnter Details)
							 lastuserid = @i_userid, lastmaintdate = getdate()
					  WHERE taqelementkey = @i_taqelementkey
						and bookkey = @v_bookkey			--jl index help

					   SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
					   IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
							  SET @o_error_code = -1
							  SET @o_error_desc = 'Unable to update taqprojectelement (cspartnerstatuscode) (' + cast(@error_var AS VARCHAR) + ').'
							  RETURN
					   END
          END -- mix of 3s, 4s, maybe 1s, maybe NULLs 
        END 
      END --@v_count5 > 0 
    END
    END
  END
  
 RETURN 
GO 

GRANT EXEC ON qtitle_set_cspartnerstatus_on_asset TO PUBLIC
GO