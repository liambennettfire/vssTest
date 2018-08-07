if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc025') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc025
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_roy_ern') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_roy_ern
GO

CREATE PROCEDURE qpl_calc_ver_roy_ern (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_debugind	TINYINT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_roy_ern
**  Desc: P&L Item 25 - Version/Royalty Earned.
**
**  Auth: Kate
**  Date: March 26 2008
*******************************************************************************************/

DECLARE
  @v_avgroyaltyind  TINYINT,
  @v_calc_price FLOAT,
  @v_channelcode  INT,
  @v_channeldesc  VARCHAR(40),
  @v_channel_discount FLOAT,
  @v_channel_grossqty INT,
  @v_channel_netqty INT,
  @v_channel_royalty  FLOAT,
  @v_count  INT,
  @v_discount_percent FLOAT,
  @v_formatkey  INT,
  @v_formatname VARCHAR(120),
  @v_format_grossqty INT,
  @v_format_netqty  INT,
  @v_format_price FLOAT,
  @v_format_royalty FLOAT,
  @v_last_threshold TINYINT,
  @v_net_quantity INT,
  @v_num_royalty_rows  INT,
  @v_num_salesunit_rows  INT,
  @v_percent_weight FLOAT,
  @v_prev_quantity  INT,
  @v_projectname  VARCHAR(80),
  @v_quantity INT,
  @v_royaltykey INT,
  @v_royaltyrate  FLOAT,
  @v_royaltypricetype TINYINT,
  @v_saleschannellevelind TINYINT,
  @v_subchannel_discount  FLOAT,
  @v_subchannel_grossqty  INT,
  @v_subchannel_netqty  INT,
  @v_total_royalty  FLOAT

BEGIN

  SET @o_result = NULL

  -- Check if Royalties are entered by Sales Channel (0) or as Average (1) for this version, 
  -- and if Sales Units are entered by Sales Channel (1) or by Sub Channel (0), and get project name
  SELECT @v_avgroyaltyind = v.avgroyaltyenteredind, @v_saleschannellevelind = saleschannellevelind, 
    @v_projectname = p.taqprojecttitle
  FROM taqversion v, taqproject p
  WHERE v.taqprojectkey = p.taqprojectkey AND
    v.taqprojectkey = @i_projectkey AND
    v.plstagecode = @i_plstage AND
    v.taqversionkey = @i_plversion
    
  --DEBUG
  IF @i_debugind = 1
  BEGIN
    PRINT 'Project: ' + CONVERT(VARCHAR, @i_projectkey) + ' (' + @v_projectname + ')'
    PRINT 'Stage/Version: ' + CONVERT(VARCHAR, @i_plstage) + '/' + CONVERT(VARCHAR, @i_plversion)
    IF @v_avgroyaltyind = 1
      PRINT 'Royalties entered As Average'
    ELSE
      PRINT 'Royalties entered by Sales Channel'    
    IF @v_saleschannellevelind = 1
      PRINT 'Sales Units entered at Sales Channel level'
    ELSE
      PRINT 'Sales Units entered at SUB Sales Channel level'
  END
    
  -- Loop through all sales channel royalty info to calculate total royalty for the selected stage version
  DECLARE saleschannel_cur CURSOR FOR  
    SELECT taqversionroyaltykey, taqprojectformatkey, saleschannelcode, pricetypeforroyalty
    FROM taqversionroyaltysaleschannel
    WHERE taqprojectkey = @i_projectkey AND
      plstagecode = @i_plstage AND
      taqversionkey = @i_plversion
    ORDER BY taqprojectformatkey, saleschannelcode

  OPEN saleschannel_cur
  
  FETCH saleschannel_cur INTO @v_royaltykey, @v_formatkey, @v_channelcode, @v_royaltypricetype

  SET @v_total_royalty = 0
  WHILE (@@FETCH_STATUS=0)
  BEGIN
  
    -- Get Format name and Sales Channel name (optional - for messages only)
    SELECT @v_formatname = s.datadesc
    FROM taqversionformat f, subgentables s
    WHERE f.mediatypecode = s.datacode AND
      f.mediatypesubcode = s.datasubcode AND
      s.tableid = 312 AND
      f.taqprojectformatkey = @v_formatkey
    
    IF @v_channelcode > 0
      SELECT @v_channeldesc = datadesc
      FROM gentables
      WHERE tableid = 118 AND datacode = @v_channelcode
    ELSE
      SET @v_channeldesc = 'none'
    
    -- DEBUG
    IF @i_debugind = 1
    BEGIN
      PRINT ' '
      PRINT ' Royalty Sales Channel Key: ' + CONVERT(VARCHAR, @v_royaltykey)
      PRINT ' Format: ' + CONVERT(VARCHAR, @v_formatkey) + ' (' + @v_formatname + ')'
      PRINT ' Sales Channel: ' + CONVERT(VARCHAR, @v_channelcode) + ' (' + @v_channeldesc + ')'
      IF @v_royaltypricetype = 2
        PRINT ' Royalties based on Net Sales (discounted price)'
      ELSE
        PRINT ' Royalties based on Retail Price'
      PRINT ' '
    END
    
    -- If entering Royalties "As Average for All Channels", must calculate the AVERAGE Discount % over all existing Sales Unit sales channels
    IF @v_avgroyaltyind = 1
      BEGIN
              
        SET @v_discount_percent = 0
        
        -- Get the TOTAL Gross and Net Quantity for this Format
        SELECT @v_format_grossqty = SUM(u.grosssalesunits), @v_format_netqty = SUM(u.netsalesunits)
        FROM taqversionsaleschannel c, taqversionsalesunit u
        WHERE c.taqversionsaleskey = u.taqversionsaleskey AND 
          c.taqprojectkey = @i_projectkey AND
          c.plstagecode = @i_plstage AND
          c.taqversionkey = @i_plversion AND
          c.taqprojectformatkey = @v_formatkey
      
        IF @v_format_grossqty IS NULL
          SET @v_format_grossqty = 0
        IF @v_format_netqty IS NULL
          SET @v_format_netqty = 0
          
        -- Royalties will be calculated based on total Format Net Quantity
        SET @v_net_quantity = @v_format_netqty
      
        -- DEBUG
        IF @i_debugind = 1
        BEGIN
          PRINT '  ** Calculating Average Discount % for this FORMAT over all existing SALES UNIT Channels: **'
          PRINT ' '
          PRINT ' TOTAL FORMAT Gross/Net Units: ' + CONVERT(VARCHAR, @v_format_grossqty) + '/' + CONVERT(VARCHAR, @v_format_netqty)
        END
                
        -- Loop through all SALES UNIT saleschannel records to calculate the Average Discount % for this Format        
        DECLARE salesunit_cur CURSOR FOR  
          SELECT c.discountpercent, SUM(u.grosssalesunits), SUM(u.netsalesunits)
          FROM taqversionsaleschannel c, taqversionsalesunit u
          WHERE c.taqversionsaleskey = u.taqversionsaleskey AND
            c.taqprojectkey = @i_projectkey AND
            c.plstagecode = @i_plstage AND
            c.taqversionkey = @i_plversion AND
            c.taqprojectformatkey = @v_formatkey
          GROUP BY c.taqversionsaleskey, c.discountpercent
        
        OPEN salesunit_cur
        
        FETCH salesunit_cur INTO @v_channel_discount, @v_channel_grossqty, @v_channel_netqty

        SET @v_count = 0
        WHILE (@@FETCH_STATUS=0)
        BEGIN
        
          IF @v_channel_discount IS NULL
            SET @v_channel_discount = 0
          IF @v_channel_grossqty IS NULL
            SET @v_channel_grossqty = 0
          IF @v_channel_netqty IS NULL
            SET @v_channel_netqty = 0        
        
          -- DEBUG
          IF @i_debugind = 1
          BEGIN
            IF @v_count > 0
              PRINT ' '
            PRINT '  Channel Discount %: ' + CONVERT(VARCHAR, @v_channel_discount)
            PRINT '  TOTAL CHANNEL Gross/Net Units: ' + CONVERT(VARCHAR, @v_channel_grossqty) + '/' + CONVERT(VARCHAR, @v_channel_netqty)
          END
          
          -- Determine the "weight" percentage (sales channel Net Qty divided by the format total Net Qty)
          -- to be multipled by the sales channel Discount % to come up with AVERAGE Discount % for this Format
          IF @v_format_netqty = 0
            SET @v_percent_weight = 0
          ELSE
            SET @v_percent_weight = CONVERT(FLOAT, @v_channel_netqty) / @v_format_netqty            
          SET @v_channel_discount = CONVERT(FLOAT, @v_channel_discount) * @v_percent_weight          
          SET @v_discount_percent = @v_discount_percent + @v_channel_discount
          SET @v_count = @v_count + 1
        
          -- DEBUG
          IF @i_debugind = 1
          BEGIN
            PRINT '  Channel Percent Weight: ' + CONVERT(VARCHAR, @v_percent_weight)
            PRINT '  Channel Discount % (by weight): ' + CONVERT(VARCHAR, @v_channel_discount)
          END
          
          FETCH salesunit_cur INTO @v_channel_discount, @v_channel_grossqty, @v_channel_netqty
        END
        
        CLOSE salesunit_cur
        DEALLOCATE salesunit_cur
        
      END --@v_avgroyaltyind = 1 (royalties entered "As Average for All Sales Channels")
      
    ELSE  --@v_avgroyaltyind = 0 (royalties entered "By Sales Channel")
      BEGIN      
        -- Check if Quantities/Discount%/Return% exist for this Format and Sales Channel on taqversionsalesunit table
        SELECT @v_num_salesunit_rows = COUNT(*)
        FROM taqversionsaleschannel 
        WHERE taqprojectkey = @i_projectkey AND
          plstagecode = @i_plstage AND 
          taqversionkey = @i_plversion AND 
          taqprojectformatkey = @v_formatkey AND
          saleschannelcode = @v_channelcode
      
        IF @v_num_salesunit_rows = 1 -- single record found for this Format/Sales Channel - use that Discount %
          BEGIN
            -- DEBUG
            IF @i_debugind = 1
              PRINT '  ** Single SALES UNIT Channel record found for this FORMAT - using that Discount %: **'
            
            SELECT @v_discount_percent = c.discountpercent, @v_channel_grossqty = SUM(u.grosssalesunits), @v_channel_netqty = SUM(u.netsalesunits)
            FROM taqversionsalesunit u, taqversionsaleschannel c
            WHERE c.taqversionsaleskey = u.taqversionsaleskey AND
              c.taqprojectkey = @i_projectkey AND
              c.plstagecode = @i_plstage AND
              c.taqversionkey = @i_plversion AND
              c.taqprojectformatkey = @v_formatkey AND
              c.saleschannelcode = @v_channelcode
            GROUP BY c.taqversionsaleskey, c.discountpercent
            
            IF @v_discount_percent IS NULL
              SET @v_discount_percent = 0
            IF @v_channel_grossqty IS NULL
              SET @v_channel_grossqty = 0
            IF @v_channel_netqty IS NULL
              SET @v_channel_netqty = 0
            
            -- Royalties will be calculated based on total Channel Net Quantity
            SET @v_net_quantity = @v_channel_netqty            
          END
          
        ELSE IF @v_num_salesunit_rows > 1  --multiple Sub Sales Channels found for this Format/Sales Channel - use AVERAGE Discount % for this Sales Channel
          BEGIN
            -- Default Discount % to 0
            SET @v_discount_percent = 0
                        
            -- Get the Total Gross and Net Quantity for this Sales Channel
            SELECT @v_channel_grossqty = SUM(u.grosssalesunits), @v_channel_netqty = SUM(u.netsalesunits)
            FROM taqversionsalesunit u, taqversionsaleschannel c
            WHERE c.taqversionsaleskey = u.taqversionsaleskey AND
              c.taqprojectkey = @i_projectkey AND
              c.plstagecode = @i_plstage AND
              c.taqversionkey = @i_plversion AND
              c.taqprojectformatkey = @v_formatkey AND
              c.saleschannelcode = @v_channelcode
              
            IF @v_channel_grossqty IS NULL
              SET @v_channel_grossqty = 0
            IF @v_channel_netqty IS NULL
              SET @v_channel_netqty = 0
              
            -- Royalties will be calculated based on total Channel Net Quantity
            SET @v_net_quantity = @v_channel_netqty            
              
            -- DEBUG
            IF @i_debugind = 1
            BEGIN
              PRINT '  ** Multiple Channel records found for this FORMAT (Sub Channel records exist) **'
              PRINT '  ** Calculating Average Discount % for this FORMAT/CHANNEL over all existing SALES UNIT Sub Channels: **'
              PRINT ' '
              PRINT '  TOTAL CHANNEL Gross/Net Units: ' + CONVERT(VARCHAR, @v_channel_grossqty) + '/' + CONVERT(VARCHAR, @v_channel_netqty)
            END
              
            -- Loop through all Sales Unit Sub Channel records to calculate the Average Discount % for this Sales Channel        
            DECLARE subchannel_cur CURSOR FOR  
              SELECT c.discountpercent, SUM(u.grosssalesunits), SUM(u.netsalesunits)
              FROM taqversionsaleschannel c, taqversionsalesunit u
              WHERE c.taqversionsaleskey = u.taqversionsaleskey AND
                c.taqprojectkey = @i_projectkey AND
                c.plstagecode = @i_plstage AND
                c.taqversionkey = @i_plversion AND
                c.taqprojectformatkey = @v_formatkey AND
                c.saleschannelcode = @v_channelcode
              GROUP BY c.saleschannelcode, c.discountpercent
            
            OPEN subchannel_cur
            
            FETCH subchannel_cur INTO @v_subchannel_discount, @v_subchannel_grossqty, @v_subchannel_netqty

            SET @v_count = 0
            WHILE (@@FETCH_STATUS=0)
            BEGIN
            
              IF @v_subchannel_discount IS NULL
                SET @v_subchannel_discount = 0
              IF @v_subchannel_grossqty IS NULL
                SET @v_subchannel_grossqty = 0
              IF @v_subchannel_netqty IS NULL
                SET @v_subchannel_netqty = 0            
            
              -- DEBUG
              IF @i_debugind = 1
              BEGIN
                IF @v_count > 0
                  PRINT ' '
                PRINT '   Sub Channel Discount %: ' + CONVERT(VARCHAR, @v_subchannel_discount)
                PRINT '   TOTAL SUB CHANNEL Gross/Net Units: ' + CONVERT(VARCHAR, @v_subchannel_grossqty) + '/' + CONVERT(VARCHAR, @v_subchannel_netqty)
              END
              
              -- Determine the "weight" percentage (Sub Channel Net Qty divided by the Channel total Net Qty)
              -- to be multipled by the sales channel Discount % to come up with AVERAGE Discount % for this Channel
              IF @v_channel_netqty = 0
                SET @v_percent_weight = 0
              ELSE
                SET @v_percent_weight = CONVERT(FLOAT, @v_subchannel_netqty) / @v_channel_netqty
              SET @v_subchannel_discount = CONVERT(FLOAT, @v_subchannel_discount) * @v_percent_weight          
              SET @v_discount_percent = @v_discount_percent + @v_subchannel_discount
              SET @v_count = @v_count + 1
            
              -- DEBUG
              IF @i_debugind = 1
              BEGIN
                PRINT '   Sub Channel Percent Weight: ' + CONVERT(VARCHAR, @v_percent_weight)
                PRINT '   Sub Channel Discount % (by weight): ' + CONVERT(VARCHAR, @v_subchannel_discount)
              END
              
              FETCH subchannel_cur INTO @v_subchannel_discount, @v_subchannel_grossqty, @v_subchannel_netqty
            END
            
            CLOSE subchannel_cur
            DEALLOCATE subchannel_cur              
          END
        ELSE
          BEGIN
            -- DEBUG
            IF @i_debugind = 1
              PRINT '  ** No SALES UNIT Channel record found for this FORMAT/CHANNEL **'
          
            SET @v_net_quantity = 0
            SET @v_discount_percent = 0
          END
          
      END --@v_avgroyaltyind = 0 (royalties entered "By Sales Channel")
    
    -- DEBUG
    IF @i_debugind = 1
    BEGIN
      PRINT ' '
      PRINT ' FORMAT Discount %: ' + CONVERT(VARCHAR, @v_discount_percent)
    END
  
    -- Get the active Price for this Format
    SELECT @v_format_price = activeprice
    FROM taqversionformat
    WHERE taqprojectkey = @i_projectkey AND
      plstagecode = @i_plstage AND 
      taqversionkey = @i_plversion AND 
      taqprojectformatkey = @v_formatkey
    
    IF @v_format_price IS NULL
      SET @v_format_price = 0
      
    -- Royalties will be calculated based on retail price or discounted price, depending on the taqversionroyaltysaleschannel.pricetypeforroyalty
    -- value for this Format/Sales Channel
    IF @v_royaltypricetype = 2  --Net Sales
      SET @v_calc_price = @v_format_price - (@v_format_price * @v_discount_percent / 100)
    ELSE  --Retail Price
      SET @v_calc_price = @v_format_price      
    
    -- DEBUG
    IF @i_debugind = 1
    BEGIN
      PRINT ' FORMAT Price: ' + CONVERT(VARCHAR, @v_format_price)
      PRINT ' Price used for Royalty: ' + CONVERT(VARCHAR, @v_calc_price)
      IF @v_avgroyaltyind = 1
        PRINT ' Using Total FORMAT Net Quantity: ' + CONVERT(VARCHAR, @v_net_quantity)
      ELSE
        PRINT ' Using Total CHANNEL Net Quantity: ' + CONVERT(VARCHAR, @v_net_quantity)
    END
      
    -- Loop through royalty rates for the current Format/Sales Channel to calculate total channel royalty
    DECLARE royaltyrates_cur CURSOR FOR
      SELECT royaltyrate, threshold, lastthresholdind
      FROM taqversionroyaltyrates 
      WHERE taqversionroyaltykey = @v_royaltykey
      ORDER BY lastthresholdind, threshold
      
    OPEN royaltyrates_cur
    
    FETCH royaltyrates_cur INTO @v_royaltyrate, @v_quantity, @v_last_threshold
    
    SET @v_channel_royalty = 0
    SET @v_format_royalty = 0
    SET @v_prev_quantity = 0
    
    IF (@@FETCH_STATUS <> 0)
    BEGIN
      -- DEBUG
      IF @i_debugind = 1
        PRINT ' ** No Royalty Rates exist for this FORMAT/CHANNEL **'
      GOTO NEXT_FORMAT_CHANNEL
    END
    
    SET @v_count = 0
    WHILE (@@FETCH_STATUS=0)
    BEGIN
    
      -- When the Net Quantity is 0 then Channel Royalty is 0
      IF @v_net_quantity = 0
      BEGIN
        SET @v_channel_royalty = 0
        -- DEBUG
        IF @i_debugind = 1
          PRINT '  CHANNEL Royalty: ' + CONVERT(VARCHAR, @v_channel_royalty)
        GOTO NEXT_FORMAT_CHANNEL
      END
    
      IF @v_royaltyrate IS NULL
        SET @v_royaltyrate = 0        
      IF @v_quantity IS NULL
        SET @v_quantity = 0
        
      -- DEBUG
      IF @i_debugind = 1
      BEGIN
        IF @v_count > 0
          PRINT ' '
        PRINT '  Royalty Rate: ' + CONVERT(VARCHAR, @v_royaltyrate)
        IF @v_last_threshold = 1
          PRINT '  Royalty Threshold Qty: AND UP'
        ELSE
          PRINT '  Royalty Threshold Qty: ' + CONVERT(VARCHAR, @v_quantity)
      END
          
      IF @v_net_quantity - @v_quantity < 0 OR @v_last_threshold = 1
        BEGIN
          SET @v_channel_royalty = (@v_net_quantity - @v_prev_quantity) * @v_calc_price * @v_royaltyrate / 100
          SET @v_format_royalty = @v_format_royalty + @v_channel_royalty
          -- DEBUG
          IF @i_debugind = 1
            PRINT '  CHANNEL Royalty: ' + CONVERT(VARCHAR, @v_channel_royalty)
          GOTO NEXT_FORMAT_CHANNEL
        END
      ELSE
        SET @v_channel_royalty = (@v_quantity - @v_prev_quantity) * @v_calc_price * @v_royaltyrate / 100      
      
      SET @v_format_royalty = @v_format_royalty + @v_channel_royalty
      SET @v_prev_quantity = @v_quantity
      SET @v_count = @v_count + 1

      -- DEBUG
      IF @i_debugind = 1
        PRINT '  CHANNEL Royalty: ' + CONVERT(VARCHAR, @v_channel_royalty)
      
      FETCH royaltyrates_cur INTO @v_royaltyrate, @v_quantity, @v_last_threshold
    END
    
    NEXT_FORMAT_CHANNEL:
    -- DEBUG
    IF @i_debugind = 1
    BEGIN
      PRINT ' FORMAT Royalty: ' + CONVERT(VARCHAR, @v_format_royalty)
      PRINT ' -------------------------'
    END
    
    CLOSE royaltyrates_cur
    DEALLOCATE royaltyrates_cur
    
    SET @v_total_royalty = @v_total_royalty + @v_format_royalty
    
    FETCH saleschannel_cur INTO @v_royaltykey, @v_formatkey, @v_channelcode, @v_royaltypricetype
  END
  
  CLOSE saleschannel_cur
  DEALLOCATE saleschannel_cur
  
  -- DEBUG
  IF @i_debugind = 1
    PRINT ' TOTAL Royalty: ' + CONVERT(VARCHAR, @v_total_royalty)
  
  SET @o_result = @v_total_royalty
  
END
GO

GRANT EXEC ON qpl_calc_ver_roy_ern TO PUBLIC
GO
