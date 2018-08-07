if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_recalc_sales_units_targetmkt') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_recalc_sales_units_targetmkt
GO

CREATE PROCEDURE qpl_recalc_sales_units_targetmkt (  
  @i_projectkey   INT,
  @i_plstage      INT,
  @i_plversion    INT,
  @i_userid       VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_recalc_sales_units_targetmkt
**  Desc: This stored procedure recalculates detail sales units for the given version
**        based on Target Market Data and existing sales percentages and Format allocation.
**
**  Auth: Kate
**  Date: November 16 2011
*******************************************************************************************/

DECLARE
  @v_channelcode  INT,
  @v_channeldesc  VARCHAR(40),
  @v_count	INT,
  @v_cur_gross  INT,
  @v_cur_net  INT,
  @v_error  INT,
  @v_formatdesc	VARCHAR(120),
  @v_formatkey  INT,
  @v_formatpercent  FLOAT,
  @v_formatunits  INT,
  @v_genunitsind  TINYINT,
  @v_grossind TINYINT,
  @v_grossunits INT,
  @v_isopentrans TINYINT,
  @v_netunits INT,
  @v_returnpercent  FLOAT,
  @v_saleskey INT,
  @v_salespercent FLOAT,
  @v_salesunits FLOAT,
  @v_subchanneldesc VARCHAR(120),
  @v_totalunits INT,
  @v_yearcode INT,
  @v_unitschanged	TINYINT
  
BEGIN

  SET @v_isopentrans = 0
  SET @v_unitschanged = 0
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
  
  SELECT @v_grossind = grosssalesunitind, @v_genunitsind = generatedetailsalesunitsind
  FROM taqversion
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error getting Version information from taqversion table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  IF @v_genunitsind < 2 --return if entering units (0) or generating from Total (1)
    RETURN
  
  IF @v_grossind = 1
    PRINT 'Target Market sell through units are GROSS units'
  ELSE
    PRINT 'Target Market sell through units are NET units'
  
  -- ***** BEGIN TRANSACTION ****  
  BEGIN TRANSACTION
  SET @v_isopentrans = 1
  
  SELECT @v_count = COALESCE(SUM(sellthroughunits),0)
  FROM taqversionmarketchannelyear m
    JOIN gentables g ON m.saleschannelcode = g.datacode AND g.tableid = 118
  WHERE m.targetmarketkey IN
    (SELECT targetmarketkey 
     FROM taqversionmarket 
     WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion)     
     
  IF @v_count = 0
  BEGIN
    -- There is no target market data - set all sales unit quantities to 0
    UPDATE taqversionsalesunit 
    SET grosssalesunits = 0, netsalesunits = 0, lastmaintdate = getdate(), lastuserid = @i_userid
    WHERE taqversionsaleskey IN 
      (SELECT taqversionsaleskey 
      FROM taqversionsaleschannel 
      WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion)
      
    SET @v_unitschanged = 1      
  END

  DECLARE channel_cur CURSOR FOR 
    SELECT DISTINCT g.datadesc, m.saleschannelcode
    FROM taqversionmarketchannelyear m
      JOIN gentables g ON m.saleschannelcode = g.datacode AND g.tableid = 118
    WHERE m.targetmarketkey IN
      (SELECT targetmarketkey 
       FROM taqversionmarket 
       WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion)

  OPEN channel_cur
  
  FETCH channel_cur INTO @v_channeldesc, @v_channelcode

  WHILE @@fetch_status = 0
  BEGIN
  
    PRINT '---'
    PRINT 'Channel: ' + CONVERT(VARCHAR, @v_channelcode) + ' (' + @v_channeldesc + ')'
    
    SELECT @v_count = COUNT(*)
    FROM taqversionsaleschannel c, taqversionsalesunit u 
    WHERE c.taqversionsaleskey = u.taqversionsaleskey AND 
      c.taqprojectkey = @i_projectkey AND
      c.plstagecode = @i_plstage AND
      c.taqversionkey = @i_plversion AND
      c.saleschannelcode = @v_channelcode
      
    IF @v_count > 0
    BEGIN  
      -- Loop through target market data - get total Sell Through Units for each given Channel/Year
      DECLARE targetmarket_cur CURSOR FOR 
        SELECT yearcode, SUM(sellthroughunits)
        FROM taqversionmarketchannelyear
        WHERE saleschannelcode = @v_channelcode AND targetmarketkey IN
          (SELECT targetmarketkey 
           FROM taqversionmarket 
           WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion)
        GROUP BY yearcode
           
      OPEN targetmarket_cur
      
      FETCH targetmarket_cur INTO @v_yearcode, @v_totalunits

      WHILE @@fetch_status = 0
      BEGIN
        
        IF @v_totalunits IS NULL
          SET @v_totalunits = 0
        
        PRINT 'Year: ' + CONVERT(VARCHAR, @v_yearcode)
        PRINT 'Total Sell Through Units (Channel/Year): ' + CONVERT(VARCHAR, @v_totalunits)
                 
        -- Loop through all Formats for this version - get formatkey and format percentage allocation
        DECLARE formats_cur CURSOR FOR 
          SELECT f.taqprojectformatkey, f.formatpercentage, s.datadesc
          FROM taqversionformat f
	      JOIN subgentables s ON f.mediatypecode = s.datacode AND f.mediatypesubcode = s.datasubcode AND s.tableid = 312
          WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion

        OPEN formats_cur
        
        FETCH formats_cur INTO @v_formatkey, @v_formatpercent, @v_formatdesc

        WHILE @@fetch_status = 0
        BEGIN
        
          -- Calculate the Sell Through Units for this Channel/Year/Format
          SET @v_formatunits = ROUND(@v_totalunits * @v_formatpercent / 100, 0)
          
          PRINT '  --'
          PRINT '  Format Key: ' + CONVERT(VARCHAR, @v_formatkey) + ' (' + @v_formatdesc + ')'
          PRINT '  Fromat Percent: ' + CONVERT(VARCHAR, @v_formatpercent) + '%'
          PRINT '  Calculated Format Units: ' + CONVERT(VARCHAR, @v_formatunits)
         
          DECLARE salesunits_cur CURSOR FOR 
            SELECT c.taqversionsaleskey, c.returnpercent, COALESCE(u.salespercent,0), COALESCE(s.datadesc, '(No sub channels)')
            FROM taqversionsaleschannel c
              JOIN taqversionsalesunit u ON c.taqversionsaleskey = u.taqversionsaleskey AND u.yearcode = @v_yearcode
              LEFT OUTER JOIN subgentables s ON c.saleschannelcode = s.datacode AND c.saleschannelsubcode = s.datasubcode AND s.tableid = 118
            WHERE c.taqprojectkey = @i_projectkey AND
              c.plstagecode = @i_plstage AND
              c.taqversionkey = @i_plversion AND
              c.taqprojectformatkey = @v_formatkey AND 
              c.saleschannelcode = @v_channelcode
              
          OPEN salesunits_cur
          
          FETCH salesunits_cur INTO @v_saleskey, @v_returnpercent, @v_salespercent, @v_subchanneldesc

          WHILE @@fetch_status = 0
          BEGIN      
                      
            -- Calculate the Sell Through Units for this Year/Format and Channel/Sub Channel
            SET @v_salesunits = @v_formatunits * @v_salespercent / 100

            PRINT '   -'
            PRINT '   Sales Key: ' + CONVERT(VARCHAR, @v_saleskey) + ' (CHANNEL: ' + @v_channeldesc + '/' + @v_subchanneldesc + '; FORMAT: ' + @v_formatdesc + '; YEAR: ' + CONVERT(VARCHAR,@v_yearcode) + ')'
            PRINT '   Sales Percent: ' + CONVERT(VARCHAR, @v_salespercent) + '%'
            PRINT '   Calculated Sales Units (Format Units * Sales Percent/100): ' + CONVERT(VARCHAR, @v_salesunits)
            PRINT '   Return Percent: ' + CONVERT(VARCHAR, @v_returnpercent) + '%'

            IF @v_grossind = 1  --calculated units are Gross Units
            BEGIN
              SET @v_grossunits = ROUND(@v_salesunits, 0)              
              SET @v_salesunits = (1 - (@v_returnpercent / 100)) * @v_salesunits
              SET @v_netunits = ROUND(@v_salesunits, 0)
            
              PRINT '   Gross Units: ' + CONVERT(VARCHAR, @v_grossunits)
              PRINT '   Calculated Net Units ((1 - Return Percent/100) * Sales Units): ' + CONVERT(VARCHAR, @v_salesunits)
              PRINT '   Net Units: ' + CONVERT(VARCHAR, @v_netunits)
            END
            ELSE  --calculated units are Net Units
            BEGIN
              SET @v_netunits = ROUND(@v_salesunits, 0)              
              SET @v_salesunits = @v_salesunits / (1 - (@v_returnpercent / 100));
              SET @v_grossunits = ROUND(@v_salesunits, 0)

              PRINT '   Calculated Gross Units (Sales Units / (1 - Return Percent/100)): ' + CONVERT(VARCHAR, @v_salesunits)
              PRINT '   Gross Units: ' + CONVERT(VARCHAR, @v_grossunits)
              PRINT '   Net Units: ' + CONVERT(VARCHAR, @v_netunits)
            END

            SELECT @v_cur_gross = grosssalesunits, @v_cur_net = netsalesunits
            FROM taqversionsalesunit
            WHERE taqversionsaleskey = @v_saleskey AND yearcode = @v_yearcode
            
            IF (@v_cur_gross <> @v_grossunits OR ((@v_cur_gross IS NULL AND @v_grossunits IS NOT NULL) OR (@v_cur_gross IS NOT NULL AND @v_grossunits IS NULL))) 
							OR (@v_cur_net <> @v_netunits OR ((@v_cur_net IS NULL AND @v_netunits IS NOT NULL) OR (@v_cur_net IS NOT NULL AND @v_netunits IS NULL)))
            BEGIN
              UPDATE taqversionsalesunit
              SET grosssalesunits = @v_grossunits, netsalesunits = @v_netunits, lastmaintdate = getdate(), lastuserid = @i_userid
              WHERE taqversionsaleskey = @v_saleskey AND yearcode = @v_yearcode
              
              SET @v_unitschanged = 1
            END
            
            SELECT @v_error = @@ERROR
            IF @v_error <> 0 BEGIN
              SET @o_error_desc = 'Update to taqversionsalesunit table failed (Error ' + cast(@v_error AS VARCHAR) + ').'
              GOTO RETURN_ERROR
            END        
            
            FETCH salesunits_cur INTO @v_saleskey, @v_returnpercent, @v_salespercent, @v_subchanneldesc
          END

          CLOSE salesunits_cur
          DEALLOCATE salesunits_cur
            
          FETCH formats_cur INTO @v_formatkey, @v_formatpercent, @v_formatdesc
        END

        CLOSE formats_cur 
        DEALLOCATE formats_cur
        
        FETCH targetmarket_cur INTO @v_yearcode, @v_totalunits
      END

      CLOSE targetmarket_cur 
      DEALLOCATE targetmarket_cur
    END
    ELSE
      PRINT 'NOTE: Cannot allocate sell through units for ' + @v_channeldesc + ' - this Channel is missing on Sales Units screen (taqversionsaleschannel/taqversionsalesunit)'
   
    FETCH channel_cur INTO @v_channeldesc, @v_channelcode
  END
  
  CLOSE channel_cur 
  DEALLOCATE channel_cur
  
  IF @v_isopentrans = 1
    COMMIT
    
  IF @v_unitschanged = 1
    EXEC qpl_update_production_quantities @i_projectkey, @i_plstage, @i_plversion, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  RETURN  

  RETURN_ERROR:
    IF @v_isopentrans = 1
      ROLLBACK
  
    SET @o_error_code = -1
    RETURN
      
END
GO

GRANT EXEC ON qpl_recalc_sales_units_targetmkt TO PUBLIC
GO
