if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_salesunits_change_to_channel') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_salesunits_change_to_channel
GO

CREATE PROCEDURE qpl_salesunits_change_to_channel
 (@i_projectkey     integer,
  @i_plstage        integer,
  @i_plversion      integer,
  @i_userid         varchar(30),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*****************************************************************************************************
**  Name: qpl_salesunits_change_to_channel
**  Desc: This stored procedure applies the Sales Channel Level change for Sales Units
**        from "Sub Sales Channel" to "Sales Channel".
**
**  Auth: Kate
**  Date: February 13 2008
*****************************************************************************************************/

DECLARE
  @v_avg_discount FLOAT,
  @v_avg_return FLOAT,
  @v_channelcode  INT,
  @v_error  INT,
  @v_formatkey  INT,
  @v_isopentrans  TINYINT,
  @v_new_saleskey INT,
  @v_num_subchannels  INT,
  @v_sum_discount FLOAT,
  @v_sum_gross INT,
  @v_sum_net INT,
  @v_sum_percent FLOAT,
  @v_sum_return FLOAT,
  @v_yearcode INT
  
BEGIN

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

  -- Get the sum of all Sub Channel values for the given Format/Sales Channel/Year
  DECLARE channel_cur INSENSITIVE CURSOR FOR  
    SELECT c.taqprojectformatkey, c.saleschannelcode, u.yearcode, COUNT(c.saleschannelsubcode) num_subchannels,
        SUM(c.discountpercent) sum_discount, SUM(c.returnpercent) sum_return, 
        SUM(u.grosssalesunits) sum_gross, SUM(u.netsalesunits) sum_net, SUM(u.salespercent) sum_percent
    FROM taqversionsaleschannel c, taqversionsalesunit u
    WHERE c.taqversionsaleskey = u.taqversionsaleskey AND
        c.taqprojectkey = @i_projectkey AND
        c.plstagecode = @i_plstage AND
        c.taqversionkey = @i_plversion
    GROUP BY c.taqprojectformatkey, c.saleschannelcode, u.yearcode
    ORDER BY c.taqprojectformatkey, c.saleschannelcode, u.yearcode
    
  OPEN channel_cur
  
  FETCH channel_cur INTO @v_formatkey, @v_channelcode, @v_yearcode, @v_num_subchannels,
    @v_sum_discount, @v_sum_return, @v_sum_gross, @v_sum_net, @v_sum_percent

  WHILE (@@FETCH_STATUS=0)
  BEGIN
    -- When only 1 Sub Channel record exists for this Channel, there is no reason to do anything
    -- since the summary sales channel record (and corresponding sales unit records) will be the same
    IF @v_num_subchannels = 1
    BEGIN
      IF @v_yearcode = 1
      BEGIN
        UPDATE taqversionsaleschannel
        SET saleschannelsubcode = 0, lastuserid = @i_userid, lastmaintdate = getdate()
        WHERE taqprojectkey = @i_projectkey AND
              plstagecode = @i_plstage AND
              taqversionkey = @i_plversion AND
              taqprojectformatkey = @v_formatkey AND
              saleschannelcode = @v_channelcode
              
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          CLOSE channel_cur
          DEALLOCATE channel_cur
          SET @o_error_desc = 'Could not update summary records on taqversionsaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
          GOTO RETURN_ERROR
        END
      END
      
      -- Continue to next row
      GOTO FetchNextRow
    END
    
    -- Calculate average Discount Percent and Return Percent for this Sales Channel from Sub channel records
    SET @v_avg_discount = ROUND(@v_sum_discount / @v_num_subchannels, 2)
    SET @v_avg_return = ROUND(@v_sum_return / @v_num_subchannels, 2)
    
    -- When processing first Year for each Format/Sales channel, insert taqversionsaleschannel record
    IF @v_yearcode = 1
    BEGIN
      -- generate new taqversionsaleskey
      EXEC get_next_key @i_userid, @v_new_saleskey OUTPUT    
   
      -- ***** TAQVERSIONSALESCHANNEL *****
      INSERT INTO taqversionsaleschannel
        (taqversionsaleskey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
         saleschannelcode, saleschannelsubcode, discountpercent, returnpercent, lastuserid, lastmaintdate)
      VALUES
        (@v_new_saleskey, @i_projectkey, @i_plstage, @i_plversion, @v_formatkey,
         @v_channelcode, 0, @v_avg_discount, @v_avg_return, @i_userid, getdate())
    
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
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
          CLOSE channel_cur
          DEALLOCATE channel_cur
          SET @o_error_desc = 'Could not update templatechanged indicators on taqversionsaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
          GOTO RETURN_ERROR
        END        
      END --@i_plstage > 0
    END --@v_yearcode = 1
      
    -- ***** TAQVERSIONSALESUNIT *****
    INSERT INTO taqversionsalesunit
      (taqversionsaleskey, yearcode, grosssalesunits, netsalesunits, salespercent, lastuserid, lastmaintdate)
    VALUES
      (@v_new_saleskey, @v_yearcode, @v_sum_gross, @v_sum_net, @v_sum_percent, @i_userid, getdate())
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
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
        CLOSE channel_cur
        DEALLOCATE channel_cur
        SET @o_error_desc = 'Could not update templatechanged indicators on taqversionsalesunit table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END
    END --@i_plstage > 0    

              
    FetchNextRow:
        
    FETCH channel_cur INTO @v_formatkey, @v_channelcode, @v_yearcode, @v_num_subchannels,
      @v_sum_discount, @v_sum_return, @v_sum_gross, @v_sum_net, @v_sum_percent
  END
  
  CLOSE channel_cur
  DEALLOCATE channel_cur  
  
  
  -- Now delete all Sub Channel records
  DELETE FROM taqversionsalesunit
  WHERE taqversionsaleskey IN 
      (SELECT taqversionsaleskey
       FROM taqversionsaleschannel
       WHERE taqprojectkey = @i_projectkey AND
            plstagecode = @i_plstage AND
            taqversionkey = @i_plversion AND
            saleschannelsubcode > 0)
            
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not delete Sub Sales Channel records from taqversionsalesunit table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  DELETE FROM taqversionsaleschannel
  WHERE taqprojectkey = @i_projectkey AND
        plstagecode = @i_plstage AND
        taqversionkey = @i_plversion AND
        saleschannelsubcode > 0
            
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not delete Sub Sales Channel records from taqversionsaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- At the end, update sales channel level indicator on taqversion from "Sub Sales Channel" (0) to "Sales Channel" (1)
  UPDATE taqversion
  SET saleschannellevelind = 1
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

GRANT EXEC ON qpl_salesunits_change_to_channel TO PUBLIC
GO
