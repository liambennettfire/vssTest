if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_maintain_format_year') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_maintain_format_year
GO

CREATE PROCEDURE qpl_maintain_format_year (  
  @i_projectkey   INT,
  @i_plstage      INT,
  @i_plversion    INT,
  @i_userid       VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/***************************************************************************************************************
**  Name: qpl_maintain_format_year
**  Desc: This stored procedure maintais all tables dependent on changes to version formats
**        (taqversionformat) and Include Up To Year value (taqversion.maxyearcode).
**
**  Auth: Kate
**  Date: November 9 2007
*****************************************************************************************************************
**  Change History
*****************************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    ------------------------------------------------------------------------
**	03/31/2016   Kate        Case 35972 - Background recalc
*****************************************************************************************************************/
DECLARE
  @v_calc_marketsize FLOAT,
  @v_calc_units  FLOAT,
  @v_count INT,
  @v_error  INT,
  @v_growthpercent  FLOAT,
  @v_marketshare  FLOAT,
  @v_marketsize INT,  
  @v_maxyearcode  INT,
  @v_newkey INT,
  @v_royaltyind TINYINT,
  @v_rowcount INT,
  @v_saleschannel INT,
  @v_saleskey INT,
  @v_sellthroughunits INT,
  @v_taqprojectformatkey INT,  
  @v_targetmarketkey  INT,
  @v_yearcode INT,
  @v_yearnum INT,
  @v_taqversionspecategorykey INT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid projectkey.'
    GOTO RETURN_ERROR
  END
  
  IF @i_plversion IS NULL OR @i_plversion <= 0 BEGIN
    SET @o_error_desc = 'Invalid taqversionkey.'
    GOTO RETURN_ERROR
  END  

  IF @i_plstage IS NULL BEGIN
    SET @o_error_desc = 'Invalid plstagecode.'
    GOTO RETURN_ERROR
  END  


  -- Get maxyearcode from taqversion
  SELECT @v_maxyearcode = maxyearcode
  FROM taqversion
  WHERE taqprojectkey = @i_projectkey and
      plstagecode = @i_plstage and
      taqversionkey = @i_plversion

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Unable to get maxyearcode from taqversion (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END

  IF @v_maxyearcode < 1 BEGIN
    SET @o_error_desc = 'Invalid maxyearcode.'
    GOTO RETURN_ERROR
  END
  
  -- ********************************************************************************************************************
  -- ***** Delete from all format/year-related tables for all formats no longer existing on taqversionformat table, *****
  -- ***** or years greater than the maxyearcode from taqversion
  -- ********************************************************************************************************************
  
  -- *** TAQVERSIONCOSTS ***
  -- delete costs for non-existing formats
  DELETE FROM taqversioncosts
  WHERE taqversionformatyearkey IN 
    (SELECT taqversionformatyearkey 
     FROM taqversionformatyear
     WHERE taqprojectkey = @i_projectkey AND 
        plstagecode = @i_plstage AND 
        taqversionkey = @i_plversion AND  
        NOT EXISTS (SELECT * FROM taqversionformat f 
                    WHERE f.taqprojectformatkey = taqversionformatyear.taqprojectformatkey AND
                          f.taqprojectkey = @i_projectkey AND 
                          f.plstagecode = @i_plstage AND 
                          f.taqversionkey = @i_plversion))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversioncosts table failed (format) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END

  -- delete costs for non-existing years
  DELETE FROM taqversioncosts
  WHERE taqversionformatyearkey IN 
    (SELECT taqversionformatyearkey
     FROM taqversionformatyear
     WHERE taqprojectkey = @i_projectkey AND 
          plstagecode = @i_plstage AND 
          taqversionkey = @i_plversion AND
          yearcode IN (SELECT datacode FROM gentables WHERE tableid = 563 AND sortorder > @v_maxyearcode))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversioncosts table failed (year) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
	
	-- *** TAQVERSIONCOSTMESSAGES	*** 
	-- delete messages for non-existing formats
  DELETE FROM taqversioncostmessages
  WHERE taqversionformatyearkey IN 
    (SELECT taqversionformatyearkey 
     FROM taqversionformatyear
     WHERE taqprojectkey = @i_projectkey AND 
        plstagecode = @i_plstage AND 
        taqversionkey = @i_plversion AND 
        NOT EXISTS (SELECT * FROM taqversionformat f 
                    WHERE f.taqprojectformatkey = taqversionformatyear.taqprojectformatkey AND
                          f.taqprojectkey = @i_projectkey AND 
                          f.plstagecode = @i_plstage AND 
                          f.taqversionkey = @i_plversion))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversioncostmessages table failed (format) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END

  -- delete messages for non-existing years
  DELETE FROM taqversioncostmessages
  WHERE taqversionformatyearkey IN 
    (SELECT taqversionformatyearkey
     FROM taqversionformatyear
     WHERE taqprojectkey = @i_projectkey AND 
          plstagecode = @i_plstage AND 
          taqversionkey = @i_plversion AND
          yearcode IN (SELECT datacode FROM gentables WHERE tableid = 563 AND sortorder > @v_maxyearcode))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversioncostmessages table failed (year) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END	
	
  -- *** TAQVERSIONINCOME ***
  -- delete income for non-existing formats
  DELETE FROM taqversionincome
  WHERE taqversionformatyearkey IN 
    (SELECT taqversionformatyearkey 
     FROM taqversionformatyear
     WHERE taqprojectkey = @i_projectkey AND 
        plstagecode = @i_plstage AND 
        taqversionkey = @i_plversion AND 
        NOT EXISTS (SELECT * FROM taqversionformat f 
                    WHERE f.taqprojectformatkey = taqversionformatyear.taqprojectformatkey AND
                          f.taqprojectkey = @i_projectkey AND 
                          f.plstagecode = @i_plstage AND 
                          f.taqversionkey = @i_plversion))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionincome table failed (format) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END

  -- delete income for non-existing years
  DELETE FROM taqversionincome
  WHERE taqversionformatyearkey IN 
    (SELECT taqversionformatyearkey
     FROM taqversionformatyear
     WHERE taqprojectkey = @i_projectkey AND 
          plstagecode = @i_plstage AND 
          taqversionkey = @i_plversion AND
          yearcode IN (SELECT datacode FROM gentables WHERE tableid = 563 AND sortorder > @v_maxyearcode))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionincome table failed (year) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END


	-- *** TAQVERSIONFORMATYEAR ***
	-- delete format/year records for non-existing formats
  DELETE FROM taqversionformatyear
  WHERE taqprojectkey = @i_projectkey AND 
      plstagecode = @i_plstage AND 
      taqversionkey = @i_plversion AND 
      NOT EXISTS (SELECT * FROM taqversionformat f 
                  WHERE f.taqprojectformatkey = taqversionformatyear.taqprojectformatkey AND
                        f.taqprojectkey = @i_projectkey AND 
                        f.plstagecode = @i_plstage AND 
                        f.taqversionkey = @i_plversion)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionformatyear table failed (format) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END

  -- delete format/year records for non-existing years
  DELETE FROM taqversionformatyear
  WHERE taqprojectkey = @i_projectkey AND 
        plstagecode = @i_plstage AND 
        taqversionkey = @i_plversion AND
        yearcode IN (SELECT datacode FROM gentables WHERE tableid = 563 AND sortorder > @v_maxyearcode)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionformatyear table failed (year) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END  
  
  
  -- *** TAQVERSIONSUBRIGHTSYEAR ***
  -- delete all subright rows for non-existing years
  DELETE FROM taqversionsubrightsyear
  WHERE subrightskey IN 
    (SELECT subrightskey 
     FROM taqversionsubrights
     WHERE taqprojectkey = @i_projectkey AND 
          plstagecode = @i_plstage AND 
          taqversionkey = @i_plversion AND 
          yearcode IN (SELECT datacode FROM gentables WHERE tableid = 563 AND sortorder > @v_maxyearcode))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionsubrightsyear table failed (year) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END

  
  -- *** TAQVERSIONROYALTYADVANCE ***
  -- delete royalty advance records for non-existing years
  DELETE FROM taqversionroyaltyadvance
  WHERE taqprojectkey = @i_projectkey AND 
        plstagecode = @i_plstage AND 
        taqversionkey = @i_plversion AND
        yearcode IN (SELECT datacode FROM gentables WHERE tableid = 563 AND sortorder > @v_maxyearcode)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionroyaltyadvance table failed (year) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END  
  
  
  -- *** TAQPLSUMMARYITEMS ***
  -- delete saved p&l summary item value records for non-existing years
  DELETE FROM taqplsummaryitems
  WHERE taqprojectkey = @i_projectkey AND 
        plstagecode = @i_plstage AND 
        taqversionkey = @i_plversion AND
        yearcode IN (SELECT datacode FROM gentables WHERE tableid = 563 AND sortorder > @v_maxyearcode)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqplsummaryitems table failed (year) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END   
  
  
  -- *** TAQVERSIONROYALTYRATES ***
  -- delete royalty rates for non-existing formats
  DELETE FROM taqversionroyaltyrates
  WHERE taqversionroyaltykey IN 
    (SELECT taqversionroyaltykey 
     FROM taqversionroyaltysaleschannel
     WHERE taqprojectkey = @i_projectkey AND 
        plstagecode = @i_plstage AND 
        taqversionkey = @i_plversion AND 
        NOT EXISTS (SELECT * FROM taqversionformat f 
                    WHERE f.taqprojectformatkey = taqversionroyaltysaleschannel.taqprojectformatkey AND
                          f.taqprojectkey = @i_projectkey AND 
                          f.plstagecode = @i_plstage AND 
                          f.taqversionkey = @i_plversion))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionroyaltyrates table failed (format) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- *** TAQVERSIONROYALTYSALESCHANNEL ***
  -- delete royalty sales channel records for non-existing formats
  DELETE FROM taqversionroyaltysaleschannel
  WHERE taqprojectkey = @i_projectkey AND 
      plstagecode = @i_plstage AND 
      taqversionkey = @i_plversion AND 
      NOT EXISTS (SELECT * FROM taqversionformat f 
                  WHERE f.taqprojectformatkey = taqversionroyaltysaleschannel.taqprojectformatkey AND
                        f.taqprojectkey = @i_projectkey AND 
                        f.plstagecode = @i_plstage AND 
                        f.taqversionkey = @i_plversion)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionroyaltysaleschannel table failed (format) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END


  -- *** TAQVERSIONSPECCATEGORY AND TAQVERSIONSPECITEMS ***
  -- delete production spec category and item records for non-existing formats
  DECLARE versionspeccategory_cur CURSOR FOR
    SELECT taqversionspecategorykey
    FROM taqversionspeccategory
    WHERE taqprojectkey = @i_projectkey AND 
      plstagecode = @i_plstage AND 
      taqversionkey = @i_plversion AND
      NOT EXISTS (SELECT * FROM taqversionformat f 
                  WHERE f.taqprojectformatkey = taqversionspeccategory.taqversionformatkey AND
                        f.taqprojectkey = @i_projectkey AND 
                        f.plstagecode = @i_plstage AND 
                        f.taqversionkey = @i_plversion)

  OPEN versionspeccategory_cur 

  FETCH versionspeccategory_cur INTO @v_taqversionspecategorykey

  WHILE (@@FETCH_STATUS=0)
  BEGIN
    DELETE FROM taqversionspecitems
    WHERE taqversionspecategorykey = @v_taqversionspecategorykey

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE versionspeccategory_cur 
      DEALLOCATE versionspeccategory_cur     
      SET @o_error_desc = 'Delete from taqversionspecitems table failed (format) (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END

    FETCH versionspeccategory_cur INTO @v_taqversionspecategorykey
  END

  CLOSE versionspeccategory_cur
  DEALLOCATE versionspeccategory_cur

  DELETE FROM taqversionspeccategory
  WHERE taqprojectkey = @i_projectkey AND 
    plstagecode = @i_plstage AND 
    taqversionkey = @i_plversion AND
    NOT EXISTS (SELECT * FROM taqversionformat f 
                WHERE f.taqprojectformatkey = taqversionspeccategory.taqversionformatkey AND
                      f.taqprojectkey = @i_projectkey AND 
                      f.plstagecode = @i_plstage AND 
                      f.taqversionkey = @i_plversion)  

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionspeccategory table failed (format) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- *** TAQVERSIONSALESUNIT ***
  -- delete sales unit records for non-existing formats
  DELETE FROM taqversionsalesunit
  WHERE taqversionsaleskey IN 
    (SELECT taqversionsaleskey 
     FROM taqversionsaleschannel
     WHERE taqprojectkey = @i_projectkey AND 
        plstagecode = @i_plstage AND 
        taqversionkey = @i_plversion AND 
        NOT EXISTS (SELECT * FROM taqversionformat f 
                    WHERE f.taqprojectformatkey = taqversionsaleschannel.taqprojectformatkey AND
                          f.taqprojectkey = @i_projectkey AND 
                          f.plstagecode = @i_plstage AND 
                          f.taqversionkey = @i_plversion))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionsalesunit table failed (format) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- delete sales unit records for non-existing years
  DELETE FROM taqversionsalesunit
  WHERE taqversionsaleskey IN 
    (SELECT taqversionsaleskey
     FROM taqversionsaleschannel
     WHERE taqprojectkey = @i_projectkey AND 
          plstagecode = @i_plstage AND 
          taqversionkey = @i_plversion AND
          yearcode IN (SELECT datacode FROM gentables WHERE tableid = 563 AND sortorder > @v_maxyearcode))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionsalesunit table failed (year) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- *** TAQVERSIONSALESCHANNEL ***
  -- delete sales channel records for non-existing formats
  DELETE FROM taqversionsaleschannel
  WHERE taqprojectkey = @i_projectkey AND 
      plstagecode = @i_plstage AND 
      taqversionkey = @i_plversion AND 
      NOT EXISTS (SELECT * FROM taqversionformat f 
                  WHERE f.taqprojectformatkey = taqversionsaleschannel.taqprojectformatkey AND
                        f.taqprojectkey = @i_projectkey AND 
                        f.plstagecode = @i_plstage AND 
                        f.taqversionkey = @i_plversion)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionsaleschannel table failed (format) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  
  -- *** TAQVERSIONADDTLUNITSYEAR ***
  -- delete additional unit year records for non-existing formats
  DELETE FROM taqversionaddtlunitsyear
  WHERE addtlunitskey IN 
    (SELECT addtlunitskey 
     FROM taqversionaddtlunits
     WHERE taqprojectkey = @i_projectkey AND 
        plstagecode = @i_plstage AND 
        taqversionkey = @i_plversion AND 
        NOT EXISTS (SELECT * FROM taqversionformat f 
                    WHERE f.taqprojectformatkey = taqversionaddtlunits.taqprojectformatkey AND
                          f.taqprojectkey = @i_projectkey AND 
                          f.plstagecode = @i_plstage AND 
                          f.taqversionkey = @i_plversion))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionaddtlunitsyear table failed (format) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- delete additional unit year records for non-existing years
  DELETE FROM taqversionaddtlunitsyear
  WHERE addtlunitskey IN 
    (SELECT addtlunitskey
     FROM taqversionaddtlunits
     WHERE taqprojectkey = @i_projectkey AND 
          plstagecode = @i_plstage AND 
          taqversionkey = @i_plversion AND
          yearcode IN (SELECT datacode FROM gentables WHERE tableid = 563 AND sortorder > @v_maxyearcode))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionaddtlunitsyear table failed (year) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- *** TAQVERSIONADDTLUNITS ***
  -- delete additional unit records for non-existing formats
  DELETE FROM taqversionaddtlunits
  WHERE taqprojectkey = @i_projectkey AND 
      plstagecode = @i_plstage AND 
      taqversionkey = @i_plversion AND 
      NOT EXISTS (SELECT * FROM taqversionformat f 
                  WHERE f.taqprojectformatkey = taqversionaddtlunits.taqprojectformatkey AND
                        f.taqprojectkey = @i_projectkey AND 
                        f.plstagecode = @i_plstage AND 
                        f.taqversionkey = @i_plversion)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionaddtlunits table failed (format) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  
  -- *** TAQVERSIONFORMATCOMPLETE ***
  -- delete Format Complete info for non-existing formats
  DELETE FROM taqversionformatcomplete
  WHERE taqprojectkey = @i_projectkey AND 
      plstagecode = @i_plstage AND 
      taqversionkey = @i_plversion AND 
      NOT EXISTS (SELECT * FROM taqversionformat f 
                  WHERE f.taqprojectformatkey = taqversionformatcomplete.taqprojectformatkey AND
                        f.taqprojectkey = @i_projectkey AND 
                        f.plstagecode = @i_plstage AND 
                        f.taqversionkey = @i_plversion)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionformatcomplete table failed (format) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END 
  
  
  -- *** TAQVERSIONMARKATCHANNELYEAR ***
  -- delete Market Channel Year info for non-existing years
  DELETE FROM taqversionmarketchannelyear
  WHERE targetmarketkey IN 
    (SELECT targetmarketkey
     FROM taqversionmarket
     WHERE taqprojectkey = @i_projectkey AND 
          plstagecode = @i_plstage AND 
          taqversionkey = @i_plversion AND
          yearcode IN (SELECT datacode FROM gentables WHERE tableid = 563 AND sortorder > @v_maxyearcode))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Delete from taqversionmarketchannelyear table failed (year) (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END       
  
  
  -- *******************************************************************
  -- ***** Insert all necessary records for missing formats/years ******
  -- *******************************************************************
  
  -- Loop through all formats for this version
  DECLARE format_cur CURSOR FOR 
    SELECT DISTINCT f.taqprojectformatkey
    FROM taqversionformat f
    WHERE taqprojectkey = @i_projectkey and
        plstagecode = @i_plstage and
        taqversionkey = @i_plversion 

  OPEN format_cur
  
  FETCH format_cur INTO @v_taqprojectformatkey

  WHILE @@fetch_status = 0
  BEGIN
  
    DECLARE year_cur CURSOR FOR 
      SELECT datacode, sortorder
      FROM gentables 
      WHERE tableid = 563

    OPEN year_cur
    
    FETCH year_cur INTO @v_yearcode, @v_yearnum
      
    WHILE @@fetch_status = 0
    BEGIN

      IF (@v_yearnum <= @v_maxyearcode)
      BEGIN
        -- ****** TAQVERSIONFORMATYEAR - must exist for each Format/Year *****
        -- only want to insert year row if it doesn't already exist
        SELECT @v_count = COUNT(*)
        FROM taqversionformatyear y
        WHERE y.taqprojectkey = @i_projectkey AND
            y.plstagecode = @i_plstage AND
            y.taqversionkey = @i_plversion AND
            y.taqprojectformatkey = @v_taqprojectformatkey AND 
            y.yearcode = @v_yearcode

        IF @v_count = 0 --Year doesn't exist for this Format - insert
        BEGIN
          -- generate new taqversionformatyearkey
          EXECUTE get_next_key @i_userid, @v_newkey OUTPUT

          INSERT INTO taqversionformatyear 
            (taqversionformatyearkey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
             yearcode, lastuserid, lastmaintdate)
          VALUES
            (@v_newkey, @i_projectkey, @i_plstage, @i_plversion, @v_taqprojectformatkey,
             @v_yearcode, @i_userid, getdate())

          SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
          IF @v_error <> 0 BEGIN
            SET @o_error_desc = 'INSERT into taqversionformatyear table failed (Error ' + cast(@v_error AS VARCHAR) + ').'
            CLOSE year_cur
            DEALLOCATE year_cur
            CLOSE format_cur 
            DEALLOCATE format_cur 
            GOTO RETURN_ERROR
          END
        END
      END --IF (@v_yearnum <= @v_maxyearcode)
    
      FETCH year_cur INTO @v_yearcode, @v_yearnum
    END

    CLOSE year_cur 
    DEALLOCATE year_cur

    FETCH format_cur INTO @v_taqprojectformatkey
  END

  CLOSE format_cur 
  DEALLOCATE format_cur
  
  
  -- ***** Calculate Market Size and Sell through units for the newly added years ******
  -- NOTE: This functionality is used on Target Market screen which many clients won't have
  
  -- Loop through all formats for this version
  DECLARE market_cur CURSOR FOR 
    SELECT targetmarketkey, marketgrowthpercent
    FROM taqversionmarket
    WHERE taqprojectkey = @i_projectkey AND
        plstagecode = @i_plstage AND
        taqversionkey = @i_plversion 

  OPEN market_cur
  
  FETCH market_cur INTO @v_targetmarketkey, @v_growthpercent

  WHILE @@fetch_status = 0
  BEGIN
  
    DECLARE channel_cur CURSOR FOR
      SELECT DISTINCT saleschannelcode
      FROM taqversionmarketchannelyear 
      WHERE targetmarketkey = @v_targetmarketkey

    OPEN channel_cur
    
    FETCH channel_cur INTO @v_saleschannel

    WHILE @@fetch_status = 0
    BEGIN
    
      DECLARE year_cur CURSOR FOR 
        SELECT datacode
        FROM gentables 
        WHERE tableid = 563 AND qsicode IS NULL

      OPEN year_cur
      
      FETCH year_cur INTO @v_yearcode
        
      WHILE @@fetch_status = 0
      BEGIN
      
        IF @v_yearcode <= @v_maxyearcode
        BEGIN
    
          SELECT @v_count = COUNT(*)
          FROM taqversionmarketchannelyear 
          WHERE targetmarketkey = @v_targetmarketkey AND saleschannelcode = @v_saleschannel AND yearcode = @v_yearcode
          
          SET @v_marketshare = 0
          SET @v_sellthroughunits = 0
          IF @v_count > 0
            SELECT @v_marketshare = marketshare, @v_marketsize = marketsize
            FROM taqversionmarketchannelyear 
            WHERE targetmarketkey = @v_targetmarketkey AND saleschannelcode = @v_saleschannel AND yearcode = @v_yearcode
         
          IF @v_yearcode > 1
          BEGIN
            SET @v_calc_marketsize = @v_marketsize * (1 + @v_growthpercent / 100)
            SET @v_marketsize = ROUND(@v_calc_marketsize, 0)
            
            SET @v_calc_units = (@v_marketshare / 100) * @v_marketsize
            SET @v_sellthroughunits = ROUND(@v_calc_units, 0)
            
            IF @v_count = 0
            BEGIN
              INSERT INTO taqversionmarketchannelyear
                (targetmarketkey, saleschannelcode, yearcode, marketshare, marketsize, sellthroughunits, lastuserid, lastmaintdate, marketsizechangedind)
              VALUES
                (@v_targetmarketkey, @v_saleschannel, @v_yearcode, @v_marketshare, @v_marketsize, @v_sellthroughunits, @i_userid, getdate(), 1)
            END
          END --@v_yearcode > 1
        END --@v_yearcode <= @v_maxyearcode
         
        FETCH year_cur INTO @v_yearcode
      END

      CLOSE year_cur 
      DEALLOCATE year_cur          
      
      FETCH channel_cur INTO @v_saleschannel
    END

    CLOSE channel_cur 
    DEALLOCATE channel_cur

    FETCH market_cur INTO @v_targetmarketkey, @v_growthpercent
  END

  CLOSE market_cur 
  DEALLOCATE market_cur
  
  
  -- ***** Recalculate Version and Year-level p&l summary item values ******
  -- This procedure will immediately recalculate all summary items for p&l levels set up on plsummaryitemrecalcorder table
  -- to procecess immediately (recalcorder=0) and push remaining summary items to background recalc
  EXEC qpl_process_immediate_recalc @i_projectkey, @i_plstage, @i_plversion, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  RETURN  

  RETURN_ERROR:      
    SET @o_error_code = -1
    RETURN
      
END
GO

GRANT EXEC ON qpl_maintain_format_year TO PUBLIC
GO
