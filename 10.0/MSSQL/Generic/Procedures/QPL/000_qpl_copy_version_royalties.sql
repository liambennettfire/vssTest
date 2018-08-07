if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_copy_version_royalties') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_copy_version_royalties
GO

CREATE PROCEDURE qpl_copy_version_royalties (  
  @i_projectkey           integer,
  @i_plstage              integer,
  @i_plversion            integer, 
  @i_fromroletypecode     integer, 
  @i_fromglobalcontactkey integer,
  @i_roletypecode         integer, 
  @i_globalcontactkey     integer,
  @i_userid               varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/*********************************************************************************************************
**  Name: qpl_copy_version_royalties
**  Desc: Copies all royalty rows for all formats of a PL Version for a particular roletypecode/globalcontactkey
**  Case: 42178
**
**  Auth: Colman
**  Date: January 13 2017
********************************************************************************************************
**  Change History
**********************************************************************************************************
**  Date:       Author:      Case #:   Description:
**  --------    --------     -------   --------------------------------------
**********************************************************************************************************/

DECLARE
  @v_count INT,  
  @v_cur_royaltykey INT,
  @v_error  INT,
  @v_floatvalue FLOAT,  
  @v_formatyearkey  INT,
  @v_lastthresholdind TINYINT,
  @v_longvalue INT,  
  @v_formatkey  INT,
  @v_percentage  FLOAT,
  @v_pricetypeforroyalty INT,
  @v_quantity INT,
  @v_returnpercent FLOAT,
  @v_royaltykey INT,
  @v_royaltyratekey INT,
  @v_royaltyrate FLOAT,
  @v_saleskey INT,
  @v_saleschannelcode INT,
  @v_saleschannelsubcode INT,
  @v_cur_saleskey INT, 
  @v_discountpercent FLOAT,
  @v_salespercent FLOAT,
  @v_textvalue VARCHAR(255),  
  @v_threshold INT,
  @v_yearcode INT,
  @v_datetypecode INT, 
  @v_dateoffsetcode INT, 
  @v_amount FLOAT, 
  @v_templatechangedind TINYINT
    
BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- *** Loop through all formats for this version ***
  DECLARE format_cur CURSOR FOR
    SELECT taqprojectformatkey
    FROM taqversionformat
    WHERE 
        taqprojectkey = @i_projectkey AND
        plstagecode = @i_plstage AND 
        taqversionkey = @i_plversion
        
  OPEN format_cur

  FETCH format_cur INTO @v_formatkey

  WHILE (@@FETCH_STATUS=0)
  BEGIN
      
    -- *** Loop through version royalty sales channel records for this format ***
    DECLARE saleschannel_cur CURSOR FOR
      SELECT taqversionroyaltykey, saleschannelcode, pricetypeforroyalty
      FROM taqversionroyaltysaleschannel
      WHERE taqprojectformatkey = @v_formatkey AND
            plstagecode = @i_plstage AND
            taqversionkey = @i_plversion AND
            roletypecode = @i_fromroletypecode AND
            globalcontactkey = @i_fromglobalcontactkey

    OPEN saleschannel_cur

    FETCH saleschannel_cur INTO @v_cur_royaltykey, @v_saleschannelcode, @v_pricetypeforroyalty

    WHILE (@@FETCH_STATUS=0)
    BEGIN

      -- generate new taqversionroyaltykey
      EXEC get_next_key @i_userid, @v_royaltykey OUTPUT

      -- TAQVERSIONROYALTYSALESCHANNEL
      INSERT INTO taqversionroyaltysaleschannel
        (taqversionroyaltykey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
        saleschannelcode, pricetypeforroyalty, lastuserid, lastmaintdate, roletypecode, globalcontactkey)
      VALUES
        (@v_royaltykey, @i_projectkey, @i_plstage, @i_plversion, @v_formatkey, 
        @v_saleschannelcode, @v_pricetypeforroyalty, @i_userid, getdate(), @i_roletypecode, @i_globalcontactkey)

      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        CLOSE saleschannel_cur
        DEALLOCATE saleschannel_cur
        SET @o_error_desc = 'Could not insert into taqversionroyaltysaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END

      -- Copy royalty rates
        -- *** Loop through royalty rates for this sales channel and copy one at a time with new key ***
        DECLARE royaltyrates_cur CURSOR FOR
          SELECT royaltyrate, threshold, lastthresholdind
          FROM taqversionroyaltyrates
          WHERE taqversionroyaltykey = @v_cur_royaltykey

        OPEN royaltyrates_cur

        FETCH royaltyrates_cur INTO @v_royaltyrate, @v_threshold, @v_lastthresholdind

        WHILE (@@FETCH_STATUS=0)
        BEGIN

          -- generate new taqversionroyaltyratekey
          EXEC get_next_key @i_userid, @v_royaltyratekey OUTPUT

          -- TAQVERSIONROYALTYRATES
          INSERT INTO taqversionroyaltyrates
            (taqversionroyaltyratekey, taqversionroyaltykey, royaltyrate, threshold, lastthresholdind, lastuserid, lastmaintdate)
          VALUES
            (@v_royaltyratekey, @v_royaltykey, @v_royaltyrate, @v_threshold, @v_lastthresholdind, @i_userid, getdate())

          SELECT @v_error = @@ERROR
          IF @v_error <> 0 BEGIN
            CLOSE royaltyrates_cur
            DEALLOCATE royaltyrates_cur        
            CLOSE saleschannel_cur
            DEALLOCATE saleschannel_cur
            SET @o_error_desc = 'Could not insert into taqversionroyaltyrates table (Error ' + cast(@v_error AS VARCHAR) + ').'
            GOTO RETURN_ERROR
          END      

          FETCH royaltyrates_cur 
          INTO @v_royaltyrate, @v_threshold, @v_lastthresholdind
        END

        CLOSE royaltyrates_cur
        DEALLOCATE royaltyrates_cur

      FETCH saleschannel_cur 
      INTO @v_cur_royaltykey, @v_saleschannelcode, @v_pricetypeforroyalty
    END

    CLOSE saleschannel_cur
    DEALLOCATE saleschannel_cur

    FETCH format_cur INTO @v_formatkey
  END
  
  CLOSE format_cur
  DEALLOCATE format_cur

  -- *** Loop through royalty advances and copy one at a time with new key ***
  DECLARE advance_cur CURSOR FOR
    SELECT yearcode, datetypecode, dateoffsetcode, amount, templatechangedind
    FROM taqversionroyaltyadvance
    WHERE 
        taqprojectkey = @i_projectkey AND
        plstagecode = @i_plstage AND
        taqversionkey = @i_plversion AND
        roletypecode = @i_fromroletypecode AND
        globalcontactkey = @i_fromglobalcontactkey

  OPEN advance_cur

  FETCH advance_cur INTO @v_yearcode, @v_datetypecode, @v_dateoffsetcode, @v_amount, @v_templatechangedind

  WHILE (@@FETCH_STATUS=0)
  BEGIN
    INSERT INTO taqversionroyaltyadvance 
      (taqprojectkey, plstagecode, taqversionkey, yearcode, datetypecode, dateoffsetcode, amount, lastuserid, lastmaintdate, templatechangedind, roletypecode, globalcontactkey)
    VALUES
      (@i_projectkey, @i_plstage, @i_plversion, @v_yearcode, @v_datetypecode, @v_dateoffsetcode, @v_amount, @i_userid, getdate(), @v_templatechangedind, @i_roletypecode, @i_globalcontactkey)
  
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE advance_cur
      DEALLOCATE advance_cur
      SET @o_error_desc = 'Could not insert into taqversionroyaltyadvance table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END      

    FETCH advance_cur INTO @v_yearcode, @v_datetypecode, @v_dateoffsetcode, @v_amount, @v_templatechangedind
  END
  
  CLOSE advance_cur
  DEALLOCATE advance_cur
  
  RETURN

RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN
  
END
GO

GRANT EXEC ON qpl_copy_version_royalties TO PUBLIC
GO
