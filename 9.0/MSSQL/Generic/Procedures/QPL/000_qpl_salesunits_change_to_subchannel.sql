if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_salesunits_change_to_subchannel') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_salesunits_change_to_subchannel
GO

CREATE PROCEDURE qpl_salesunits_change_to_subchannel
 (@i_projectkey     integer,
  @i_plstage        integer,
  @i_plversion      integer,
  @i_userid         varchar(30),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*****************************************************************************************************
**  Name: qpl_salesunits_change_to_subchannel
**  Desc: This stored procedure applies the Sales Channel Level change for Sales Units
**        from "Sales Channel" to "Sub Sales Channel".
**
**  Auth: Kate
**  Date: February 14 2008
*****************************************************************************************************/

DECLARE
  @v_channelcode  INT,
  @v_count  INT,
  @v_discount_percent FLOAT,
  @v_error  INT,
  @v_formatkey  INT,
  @v_isopentrans  TINYINT,
  @v_new_saleskey INT,
  @v_return_percent FLOAT,
  @v_saleskey INT,
  @v_subcode  INT,
  @v_yearcode INT
  
BEGIN

  SET NOCOUNT ON
  
  SET @v_isopentrans = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid projectkey.'
    GOTO RETURN_ERROR
  END
   
  IF @i_plversion IS NULL OR @i_plversion <= 0 BEGIN
    SET @o_error_desc = 'Invalid versionkey.'
    GOTO RETURN_ERROR
  END
  
  -- ***** BEGIN TRANSACTION ****  
  BEGIN TRANSACTION
  SET @v_isopentrans = 1

  -- Get the current Channel values for this version
  DECLARE channel_cur INSENSITIVE CURSOR FOR  
    SELECT taqversionsaleskey, taqprojectformatkey, saleschannelcode, discountpercent, returnpercent
    FROM taqversionsaleschannel 
    WHERE taqprojectkey = @i_projectkey AND
          plstagecode = @i_plstage AND
          taqversionkey = @i_plversion
    
  OPEN channel_cur
  
  FETCH channel_cur
  INTO @v_saleskey, @v_formatkey, @v_channelcode, @v_discount_percent, @v_return_percent

  WHILE (@@FETCH_STATUS=0)
  BEGIN

    SELECT @v_count = COUNT(*)
    FROM subgentables 
    WHERE tableid = 118 AND datacode = @v_channelcode
    
    -- If no Sub Channels exist for this channel, taqversionsaleschannel record remains the same.
    -- Only taqversionsalesunit rows need to be reset.
    IF @v_count = 0
    BEGIN
      UPDATE taqversionsalesunit
      SET grosssalesunits = 0, netsalesunits = 0, salespercent = NULL
      WHERE taqversionsaleskey = @v_saleskey
      
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        CLOSE channel_cur
        DEALLOCATE channel_cur
        SET @o_error_desc = 'Could not update taqversionsalesunit table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END
      
      -- If this is a P&L Version (not a Template), update templatechanged indicators
      IF @i_plstage > 0
      BEGIN
        UPDATE taqversionsalesunit
        SET grosschangedind = 1, netchangedind = 1, percentchangedind = 1
        WHERE taqversionsaleskey = @v_saleskey
        
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          CLOSE channel_cur
          DEALLOCATE channel_cur
          SET @o_error_desc = 'Could not update templatechanged indicators on taqversionsalesunit table (Error ' + cast(@v_error AS VARCHAR) + ').'
          GOTO RETURN_ERROR
        END      
      END
      
      -- Continue to the next row
      FETCH channel_cur
      INTO @v_saleskey, @v_formatkey, @v_channelcode, @v_discount_percent, @v_return_percent
      
      CONTINUE      
    END --@v_count = 0

    DECLARE subchannel_cur CURSOR FOR  
      SELECT datasubcode
      FROM subgentables
      WHERE tableid = 118 AND datacode = @v_channelcode
      ORDER BY COALESCE(sortorder, 0), datadesc
      
    OPEN subchannel_cur
    
    FETCH subchannel_cur INTO @v_subcode

    WHILE (@@FETCH_STATUS=0)
    BEGIN
    
      -- generate new taqversionsaleskey
      EXEC get_next_key @i_userid, @v_new_saleskey OUTPUT    
   
      -- ***** TAQVERSIONSALESCHANNEL *****
      INSERT INTO taqversionsaleschannel
        (taqversionsaleskey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
         saleschannelcode, saleschannelsubcode, discountpercent, returnpercent, lastuserid, lastmaintdate)
      VALUES
        (@v_new_saleskey, @i_projectkey, @i_plstage, @i_plversion, @v_formatkey,
         @v_channelcode, @v_subcode, @v_discount_percent, @v_return_percent, @i_userid, getdate())
    
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        CLOSE subchannel_cur
        DEALLOCATE subchannel_cur
        CLOSE channel_cur
        DEALLOCATE channel_cur
        SET @o_error_desc = 'Could not insert into taqversionsaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END
      
      -- If this is a P&L Version (not a Template), update templatechanged indicators
      IF @i_plstage > 0
      BEGIN
        UPDATE taqversionsaleschannel
        SET discounttemplatechangedind = 1, returntemplatechangedind = 1
        WHERE taqversionsaleskey = @v_new_saleskey
        
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          CLOSE subchannel_cur
          DEALLOCATE subchannel_cur          
          CLOSE channel_cur
          DEALLOCATE channel_cur
          SET @o_error_desc = 'Could not update templatechanged indicators on taqversionsaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
          GOTO RETURN_ERROR
        END        
      END
      
      -- Update saleschannelcode on the currently processed channel record from 0 to -1 to mark for delete
      UPDATE taqversionsaleschannel
      SET saleschannelcode = -1
      WHERE taqversionsaleskey = @v_saleskey

      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        CLOSE subchannel_cur
        DEALLOCATE subchannel_cur
        CLOSE channel_cur
        DEALLOCATE channel_cur
        SET @o_error_desc = 'Could not update taqversionsaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END        
      
      -- ***** TAQVERSIONSALESUNIT *****
      SET @v_yearcode = 1
      WHILE @v_yearcode < 5 --4 years
      BEGIN
      
        INSERT INTO taqversionsalesunit
          (taqversionsaleskey, yearcode, grosssalesunits, netsalesunits, salespercent, lastuserid, lastmaintdate)
        VALUES
          (@v_new_saleskey, @v_yearcode, 0, 0, NULL, @i_userid, getdate())
        
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          CLOSE subchannel_cur
          DEALLOCATE subchannel_cur        
          CLOSE channel_cur
          DEALLOCATE channel_cur
          SET @o_error_desc = 'Could not insert into taqversionsalesunit table (Error ' + cast(@v_error AS VARCHAR) + ').'
          GOTO RETURN_ERROR
        END
      
        -- If this is a P&L Version (not a Template), update templatechanged indicators
        IF @i_plstage > 0
        BEGIN
          UPDATE taqversionsalesunit
          SET grosschangedind = 1, netchangedind = 1, percentchangedind = 1
          WHERE taqversionsaleskey = @v_new_saleskey AND
                yearcode = @v_yearcode
          
          SELECT @v_error = @@ERROR
          IF @v_error <> 0 BEGIN
            CLOSE subchannel_cur
            DEALLOCATE subchannel_cur          
            CLOSE channel_cur
            DEALLOCATE channel_cur
            SET @o_error_desc = 'Could not update templatechanged indicators on taqversionsalesunit table (Error ' + cast(@v_error AS VARCHAR) + ').'
            GOTO RETURN_ERROR
          END
        END --@i_plstage > 0
        
        SET @v_yearcode = @v_yearcode + 1        
      END --Year LOOP

      FETCH subchannel_cur INTO @v_subcode
    END --subchannel_cur LOOP
    
    CLOSE subchannel_cur
    DEALLOCATE subchannel_cur   
                      
    FETCH channel_cur
    INTO @v_saleskey, @v_formatkey, @v_channelcode, @v_discount_percent, @v_return_percent
  END --channel_cur LOOP
  
  CLOSE channel_cur
  DEALLOCATE channel_cur  
  
  -- Now delete all marked Channel records
  DELETE FROM taqversionsalesunit
  WHERE taqversionsaleskey IN 
      (SELECT taqversionsaleskey
       FROM taqversionsaleschannel
       WHERE taqprojectkey = @i_projectkey AND
            plstagecode = @i_plstage AND
            taqversionkey = @i_plversion AND
            saleschannelcode = -1)
            
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not delete old Sales Channel records from taqversionsalesunit table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  DELETE FROM taqversionsaleschannel
  WHERE taqprojectkey = @i_projectkey AND
        plstagecode = @i_plstage AND
        taqversionkey = @i_plversion AND
        saleschannelcode = -1
            
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not delete old Sales Channel records from taqversionsaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- At the end, update sales channel level indicator on taqversion from "Sub Sales Channel" (0) to "Sales Channel" (1)
  UPDATE taqversion
  SET saleschannellevelind = 0
  WHERE taqprojectkey = @i_projectkey AND
        plstagecode = @i_plstage AND
        taqversionkey = @i_plversion
        
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not update Sales Channel Level on taqversion table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  IF @v_isopentrans = 1
    COMMIT TRANSACTION
    
  RETURN  


RETURN_ERROR:  
  IF @v_isopentrans = 1
    ROLLBACK TRANSACTION
    
  SET @o_error_code = -1
  RETURN
    
END
GO

GRANT EXEC ON qpl_salesunits_change_to_subchannel TO PUBLIC
GO
