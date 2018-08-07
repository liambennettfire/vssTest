if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_copy_channel') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_copy_channel
GO

CREATE PROCEDURE qpl_copy_channel (  
  @i_new_projectkey   integer,
  @i_new_plstage      integer,
  @i_new_plversion    integer, 
  @i_new_formatkey    integer, 
  @i_from_formatkey   integer,
  @i_from_channel     integer,
  @i_from_subchannel  integer,
  @i_copyvalues       tinyint,
  @i_userid           varchar(30),
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*********************************************************************************************************
**  Name: qpl_copy_channel
**  Desc: This stored procedure copies Sales Units information for the given format/channel:
**        if @i_copyvalues = 0, copy rows but not the values
**        if @i_copyvalues = 1, copy all rows and values
**
**  Auth: Kate
**  Date: September 5 2012
********************************************************************************************************
**    Change History
**********************************************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**   02/08/2017   Colman       41910     Added netprice and calcdiscountind to taqversaleschannel
********************************************************************************************************/

DECLARE
  @v_count	INT, 
  @v_cur_saleskey INT, 
  @v_discountpercent FLOAT,
  @v_error  INT,
  @v_grossunits INT,
  @v_netunits INT,
  @v_returnpercent FLOAT,
  @v_saleskey INT,
  @v_salespercent FLOAT,  
  @v_yearcode INT,
  @v_netprice DECIMAL(9,2),
  @v_calcdiscountind TINYINT
  
BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- TAQVERSIONSALESCHANNEL
  IF @i_copyvalues = 1 AND @i_from_formatkey > 0 --copy everything
  BEGIN
    -- generate new taqversionsaleskey
    EXEC get_next_key @i_userid, @v_saleskey OUTPUT
  
    SELECT @v_cur_saleskey = taqversionsaleskey, @v_discountpercent = discountpercent, @v_returnpercent = returnpercent, @v_netprice = netprice, @v_calcdiscountind = calcdiscountind
    FROM taqversionsaleschannel
    WHERE taqprojectformatkey = @i_from_formatkey AND
      saleschannelcode = @i_from_channel AND
      saleschannelsubcode = @i_from_subchannel

    INSERT INTO taqversionsaleschannel
      (taqversionsaleskey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
      saleschannelcode, saleschannelsubcode, discountpercent, returnpercent, netprice, calcdiscountind, lastuserid, lastmaintdate)
    VALUES
      (@v_saleskey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, @i_new_formatkey, 
      @i_from_channel, @i_from_subchannel, @v_discountpercent, @v_returnpercent, @v_netprice, @v_calcdiscountind, @i_userid, getdate())
      
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE saleschannel_cur
      DEALLOCATE saleschannel_cur
      SET @o_error_desc = 'Could not insert into taqversionsaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END      
      
    -- *** Loop through sales unit info for this sales channel and copy one at a time with new key ***
    DECLARE salesunit_cur CURSOR FOR
      SELECT yearcode, grosssalesunits, netsalesunits, salespercent
      FROM taqversionsalesunit
      WHERE taqversionsaleskey = @v_cur_saleskey

    OPEN salesunit_cur

    FETCH salesunit_cur 
    INTO @v_yearcode, @v_grossunits, @v_netunits, @v_salespercent

    WHILE (@@FETCH_STATUS=0)
    BEGIN

      -- TAQVERSIONSALESUNIT
      IF @i_copyvalues = 1 --copy everything
        INSERT INTO taqversionsalesunit
          (taqversionsaleskey, yearcode, grosssalesunits, netsalesunits, salespercent, lastuserid, lastmaintdate)
        VALUES
          (@v_saleskey, @v_yearcode, @v_grossunits, @v_netunits, @v_salespercent, @i_userid, getdate())
      ELSE  --don't copy percentages or units
        INSERT INTO taqversionsalesunit
          (taqversionsaleskey, yearcode, lastuserid, lastmaintdate)
        VALUES
          (@v_saleskey, @v_yearcode, @i_userid, getdate())                

      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        CLOSE salesunit_cur
        DEALLOCATE salesunit_cur        
        CLOSE saleschannel_cur
        DEALLOCATE saleschannel_cur
        SET @o_error_desc = 'Could not insert into taqversionsalesunit table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END      

      FETCH salesunit_cur 
      INTO @v_yearcode, @v_grossunits, @v_netunits, @v_salespercent
    END

    CLOSE salesunit_cur
    DEALLOCATE salesunit_cur      
  END
  ELSE  --just insert channel rows
  BEGIN
    -- Don't insert if the channel already exists for this version/format
    SELECT @v_count = COUNT(*)
    FROM taqversionsaleschannel
    WHERE taqprojectkey = @i_new_projectkey AND
      plstagecode = @i_new_plstage AND
      taqversionkey = @i_new_plversion AND
      taqprojectformatkey = @i_new_formatkey AND
      saleschannelcode = @i_from_channel AND
      saleschannelsubcode = @i_from_subchannel
      
    IF @v_count = 0
    BEGIN
      -- generate new taqversionsaleskey
      EXEC get_next_key @i_userid, @v_saleskey OUTPUT
    
      INSERT INTO taqversionsaleschannel
        (taqversionsaleskey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
        saleschannelcode, saleschannelsubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_saleskey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, @i_new_formatkey, 
        @i_from_channel, @i_from_subchannel, @i_userid, getdate())
        
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        CLOSE saleschannel_cur
        DEALLOCATE saleschannel_cur
        SET @o_error_desc = 'Could not insert into taqversionsaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END
    END          
  END
     
  RETURN

RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN
  
END
GO

GRANT EXEC ON qpl_copy_channel TO PUBLIC
GO
