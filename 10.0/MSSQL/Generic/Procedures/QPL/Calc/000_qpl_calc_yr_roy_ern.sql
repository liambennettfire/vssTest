IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qpl_calc_yr_roy_ern')
  DROP PROCEDURE qpl_calc_yr_roy_ern
GO

CREATE PROCEDURE [dbo].[qpl_calc_yr_roy_ern] (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT,
  @i_debugind	TINYINT,
  @o_result     FLOAT OUTPUT,
  @i_roleSumItemCode VARCHAR(255) = NULL,
  @i_allIncludedInd INT = NULL,
  @i_participantKey INT = NULL
  )
AS

/**************************************************************************************************************************
**  Name: qpl_calc_yr_roy_ern
**  Desc: P&L Item 53 - Year/Royalty Earned.
**
**  Auth: Kate
**  Date: November 20 2009
**************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**  01/09/2017  Josh G    Case 42565 Royalty Advances and Rates by contributor P&L Procedure changes 
**************************************************************************************************************************/

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
  @v_test INT,
  @v_total_royalty  FLOAT,
  @v_yearsort INT,
  @v_ytd_netqty INT,
  @v_globalContactKey INT

BEGIN
 
  /* Test Susan's example: 
  IF @i_yearcode = 4
    SET @o_result = 10000
  ELSE IF @i_yearcode = 3
    SET @o_result = 2000
  ELSE IF @i_yearcode = 2
    SET @o_result = 5000
  ELSE IF @i_yearcode = 1
    SET @o_result = 7000
  ELSE
    SET @o_result = 0 

  RETURN
*/

  -- Get the sortorder for the passed yearcode
  SELECT @v_yearsort = sortorder
  FROM gentables
  WHERE tableid = 563 AND datacode = @i_yearcode

  -- Check if Royalties are entered by Sales Channel (0) or as Average (1) for this version, 
  -- and if Sales Units are entered by Sales Channel (1) or by Sub Channel (0), and get project name
  SELECT @v_avgroyaltyind = v.avgroyaltyenteredind, @v_saleschannellevelind = saleschannellevelind, 
    @v_projectname = p.taqprojecttitle
  FROM taqversion v, taqproject p
  WHERE v.taqprojectkey = p.taqprojectkey AND
    v.taqprojectkey = @i_projectkey AND
    v.plstagecode = @i_plstage AND
    v.taqversionkey = @i_plversion
     
  IF @i_debugind = 1
  BEGIN
    PRINT 'Project: ' + CONVERT(VARCHAR, @i_projectkey) + ' (' + @v_projectname + ')'
    PRINT 'Stage/Version/Year: ' + CONVERT(VARCHAR, @i_plstage) + '/' + CONVERT(VARCHAR, @i_plversion) + '/' + CONVERT(VARCHAR, @v_yearsort)
    IF @v_avgroyaltyind = 1
      PRINT 'Royalties entered As Average'
    ELSE
      PRINT 'Royalties entered by Sales Channel'    
    IF @v_saleschannellevelind = 1
      PRINT 'Sales Units entered at Sales Channel level'
    ELSE
      PRINT 'Sales Units entered at SUB Sales Channel level'
  END
    

--Loop for every role as well. JRG
	--Load all roles into a table to use later
	DECLARE @roleCodes TABLE
	(
		dataCode INT
	)

	IF (@i_roleSumItemCode IS NOT NULL)
	BEGIN
		INSERT INTO @roleCodes
		SELECT 
			xt.dataCode
		FROM 
			gentables_ext xt
		WHERE 
			xt.tableID = 285
		AND xt.gentext1 = @i_roleSumItemCode
	END

	IF (@i_allIncludedInd IS NULL AND @i_roleSumItemCode IS NULL)
	BEGIN
		INSERT INTO @roleCodes
		VALUES (0)

		INSERT INTO @roleCodes
		SELECT 
			xt.dataCode
		FROM 
			gentables_ext xt
		WHERE 
			xt.tableID = 285
	END

	IF (@i_allIncludedInd = 1)
	BEGIN
		INSERT INTO @roleCodes
		VALUES (0)
		
		INSERT INTO @roleCodes
		SELECT 
			xt.dataCode
		FROM 
			gentables_ext xt
		WHERE 
			xt.tableID = 285
		AND xt.gentext1 IS NULL
		EXCEPT 
		SELECT dataCode FROM @roleCodes
		
	END

  -- Loop through all sales channel royalty info to calculate total royalty for the selected stage version
  IF (@i_allIncludedInd IS NULL AND @i_roleSumItemCode IS NULL)  
  BEGIN
  DECLARE saleschannel_cur CURSOR FOR  
    SELECT tv.taqversionroyaltykey, tv.taqprojectformatkey, tv.saleschannelcode, tv.pricetypeforroyalty
    FROM taqversionroyaltysaleschannel tv
    WHERE tv.taqprojectkey = @i_projectkey 
		AND tv.plstagecode = @i_plstage 
		AND tv.taqversionkey = @i_plversion
    ORDER BY taqprojectformatkey, saleschannelcode
  END
  ELSE
  BEGIN
  DECLARE saleschannel_cur CURSOR FOR  
    SELECT tv.taqversionroyaltykey, tv.taqprojectformatkey, tv.saleschannelcode, tv.pricetypeforroyalty
    FROM taqversionroyaltysaleschannel tv
    WHERE tv.taqprojectkey = @i_projectkey 
		AND tv.plstagecode = @i_plstage 
		AND tv.taqversionkey = @i_plversion
		-- if user passes in 0 for @i_participantKey then all contacts are valid, else use the specific one they passed in
		AND tv.globalcontactkey = (CASE WHEN ISNULL(@i_participantKey,0) = 0 THEN tv.globalcontactkey ELSE @i_participantKey END)
	    AND EXISTS(SELECT 1 FROM @roleCodes rc
					WHERE rc.dataCode = tv.roleTypeCode)
    ORDER BY taqprojectformatkey, saleschannelcode
  END
  OPEN saleschannel_cur
  
  FETCH saleschannel_cur INTO @v_royaltykey, @v_formatkey, @v_channelcode, @v_royaltypricetype

  SET @v_total_royalty = 0
  WHILE (@@FETCH_STATUS=0)
  BEGIN
  
    SELECT @v_test = COUNT(*)
    FROM taqversionroyaltyrates
    WHERE taqversionroyaltykey = @v_royaltykey

    IF @v_test = 0
    BEGIN
      GOTO NEXT_FORMAT_CHANNEL_FETCH
    END
      
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
        
        -- Get the TOTAL Gross and Net Quantity for this Format and Year
        SELECT @v_format_grossqty = SUM(u.grosssalesunits), @v_format_netqty = SUM(u.netsalesunits)
        FROM taqversionsaleschannel c, taqversionsalesunit u
        WHERE c.taqversionsaleskey = u.taqversionsaleskey AND 
          c.taqprojectkey = @i_projectkey AND
          c.plstagecode = @i_plstage AND
          c.taqversionkey = @i_plversion AND
          u.yearcode = @i_yearcode AND
          c.taqprojectformatkey = @v_formatkey
		  
      
        IF @v_format_grossqty IS NULL
          SET @v_format_grossqty = 0
        IF @v_format_netqty IS NULL
          SET @v_format_netqty = 0     
          
        -- Royalties will be calculated based on total Format Net Quantity
        SET @v_net_quantity = @v_format_netqty
      
        -- Get the TOTAL YTD Net Quantity for this Format (all previous years)
        SELECT @v_ytd_netqty = SUM(u.netsalesunits)
        FROM taqversionsaleschannel c, taqversionsalesunit u, gentables g
        WHERE c.taqversionsaleskey = u.taqversionsaleskey AND 
          u.yearcode = g.datacode AND
          g.tableid = 563 AND
          c.taqprojectkey = @i_projectkey AND
          c.plstagecode = @i_plstage AND
          c.taqversionkey = @i_plversion AND
          g.sortorder < @v_yearsort AND
          c.taqprojectformatkey = @v_formatkey
      
        IF @v_ytd_netqty IS NULL
          SET @v_ytd_netqty = 0
              
        IF @i_debugind = 1
        BEGIN
          PRINT '  ** Calculating Average Discount % for this FORMAT over all existing SALES UNIT Channels: **'
          PRINT ' '
          PRINT ' TOTAL FORMAT Gross/Net Units: ' + CONVERT(VARCHAR, @v_format_grossqty) + '/' + CONVERT(VARCHAR, @v_format_netqty)
		  PRINT ' TOTAL YTD Net Quantity for this Format and Channel: ' + CONVERT(VARCHAR, @v_ytd_netqty) 	
        END       
        -- Loop through all SALES UNIT saleschannel records to calculate the Average Discount % for this Format        
        DECLARE salesunit_cur CURSOR FOR  
          SELECT c.discountpercent, SUM(u.grosssalesunits), SUM(u.netsalesunits)
          FROM taqversionsaleschannel c, taqversionsalesunit u
          WHERE c.taqversionsaleskey = u.taqversionsaleskey AND
            c.taqprojectkey = @i_projectkey AND
            c.plstagecode = @i_plstage AND
            c.taqversionkey = @i_plversion AND
            u.yearcode = @i_yearcode AND
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
            IF @i_debugind = 1
			  PRINT '  ** Single SALES UNIT Channel record found for this FORMAT - using that Discount %: **'
            
            SELECT @v_discount_percent = c.discountpercent, @v_channel_grossqty = SUM(u.grosssalesunits), @v_channel_netqty = SUM(u.netsalesunits)
            FROM taqversionsalesunit u, taqversionsaleschannel c
            WHERE c.taqversionsaleskey = u.taqversionsaleskey AND
              c.taqprojectkey = @i_projectkey AND
              c.plstagecode = @i_plstage AND
              c.taqversionkey = @i_plversion AND
              u.yearcode = @i_yearcode AND
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
                                   
            -- Get the TOTAL YTD Net Quantity for this Format and Channel (all previous years)
            SELECT @v_ytd_netqty = SUM(u.netsalesunits)
            FROM taqversionsaleschannel c, taqversionsalesunit u, gentables g
            WHERE c.taqversionsaleskey = u.taqversionsaleskey AND 
              u.yearcode = g.datacode AND
              g.tableid = 563 AND
              c.taqprojectkey = @i_projectkey AND
              c.plstagecode = @i_plstage AND
              c.taqversionkey = @i_plversion AND
              g.sortorder < @v_yearsort AND
              c.taqprojectformatkey = @v_formatkey AND
              c.saleschannelcode = @v_channelcode
            GROUP BY c.taqversionsaleskey, c.discountpercent
          
            IF @v_ytd_netqty IS NULL
              SET @v_ytd_netqty = 0  
            
			IF @i_debugind = 1
            BEGIN
				PRINT '  TOTAL YTD Net Quantity for this Format and Channel: ' + CONVERT(VARCHAR, @v_ytd_netqty) 
            END			  
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
              u.yearcode = @i_yearcode AND
              c.taqprojectformatkey = @v_formatkey AND
              c.saleschannelcode = @v_channelcode
              
            IF @v_channel_grossqty IS NULL
              SET @v_channel_grossqty = 0
            IF @v_channel_netqty IS NULL
              SET @v_channel_netqty = 0
              
            -- Royalties will be calculated based on total Channel Net Quantity
            SET @v_net_quantity = @v_channel_netqty
            
            -- Get the TOTAL YTD Net Quantity for this Format and Channel (all previous years)
            SELECT @v_ytd_netqty = SUM(u.netsalesunits)
            FROM taqversionsaleschannel c, taqversionsalesunit u, gentables g
            WHERE c.taqversionsaleskey = u.taqversionsaleskey AND 
              u.yearcode = g.datacode AND
              g.tableid = 563 AND
              c.taqprojectkey = @i_projectkey AND
              c.plstagecode = @i_plstage AND
              c.taqversionkey = @i_plversion AND
              g.sortorder < @v_yearsort AND
              c.taqprojectformatkey = @v_formatkey AND
              c.saleschannelcode = @v_channelcode
            GROUP BY c.saleschannelcode 
          
            IF @v_ytd_netqty IS NULL
              SET @v_ytd_netqty = 0
                            
            IF @i_debugind = 1
            BEGIN
              PRINT '  ** Multiple Channel records found for this FORMAT (Sub Channel records exist) **'
              PRINT '  ** Calculating Average Discount % for this FORMAT/CHANNEL over all existing SALES UNIT Sub Channels: **'
              PRINT ' '
              PRINT '  TOTAL CHANNEL Gross/Net Units: ' + CONVERT(VARCHAR, @v_channel_grossqty) + '/' + CONVERT(VARCHAR, @v_channel_netqty)
			  PRINT '  TOTAL YTD Net Quantity for this Format and Channel: ' + CONVERT(VARCHAR, @v_ytd_netqty) 
            END
 
            -- Loop through all Sales Unit Sub Channel records to calculate the Average Discount % for this Sales Channel        
            DECLARE subchannel_cur CURSOR FOR  
              SELECT c.discountpercent, SUM(u.grosssalesunits), SUM(u.netsalesunits)
              FROM taqversionsaleschannel c, taqversionsalesunit u
              WHERE c.taqversionsaleskey = u.taqversionsaleskey AND
                c.taqprojectkey = @i_projectkey AND
                c.plstagecode = @i_plstage AND
                c.taqversionkey = @i_plversion AND
                u.yearcode = @i_yearcode AND
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
            IF @i_debugind = 1
              PRINT '  ** No SALES UNIT Channel record found for this FORMAT/CHANNEL **'
          
            SET @v_net_quantity = 0
            SET @v_discount_percent = 0
          END
          
      END --@v_avgroyaltyind = 0 (royalties entered "By Sales Channel")
    
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
    
    IF @i_debugind = 1
    BEGIN
      PRINT ' FORMAT Price: ' + CONVERT(VARCHAR, @v_format_price)
      PRINT ' Price used for Royalty: ' + CONVERT(VARCHAR, @v_calc_price)
      IF @v_avgroyaltyind = 1
      BEGIN
        PRINT ' Using Total FORMAT Net Quantity: ' + CONVERT(VARCHAR, @v_net_quantity)
        PRINT ' Total FORMAT YTD Net Quantity: ' + CONVERT(VARCHAR, @v_ytd_netqty)
      END
      ELSE
      BEGIN
        PRINT ' Using Total CHANNEL Net Quantity: ' + CONVERT(VARCHAR, @v_net_quantity)
        PRINT ' Total CHANNEL YTD Net Quantity: ' + CONVERT(VARCHAR, @v_ytd_netqty)
      END
      PRINT ' '
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
        IF @i_debugind = 1
          PRINT '    CHANNEL Royalty: ' + CONVERT(VARCHAR, @v_channel_royalty)
        GOTO NEXT_FORMAT_CHANNEL
      END
    
      IF @v_royaltyrate IS NULL
        SET @v_royaltyrate = 0        
      IF @v_quantity IS NULL
        SET @v_quantity = 0
        
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
          
      IF (@v_quantity < @v_ytd_netqty) AND @v_last_threshold = 0
      BEGIN
        IF @i_debugind = 1
          PRINT '    (Threshold quantity less than YTD net qty - go to next rate)'
        GOTO NEXT_ROYALTY_RATE
      END
          
      IF (@v_net_quantity + @v_ytd_netqty) - @v_quantity < 0 OR @v_last_threshold = 1
        BEGIN
          IF @v_prev_quantity = 0
            SET @v_prev_quantity = @v_ytd_netqty
            
          SET @v_channel_royalty = (@v_net_quantity + @v_ytd_netqty - @v_prev_quantity) * @v_calc_price * @v_royaltyrate / 100
          SET @v_format_royalty = @v_format_royalty + @v_channel_royalty
          
          IF @i_debugind = 1
          BEGIN
            IF @v_prev_quantity = @v_ytd_netqty
              PRINT '    CHANNEL Royalty: ' + CONVERT(VARCHAR, @v_net_quantity) + ' * ' + CONVERT(VARCHAR, @v_calc_price) + ' * ' + CONVERT(VARCHAR, @v_royaltyrate) + '/100 = ' + CONVERT(VARCHAR, @v_channel_royalty)                      
            ELSE
              PRINT '    CHANNEL Royalty: (' + CONVERT(VARCHAR, @v_net_quantity) + ' + ' + CONVERT(VARCHAR, @v_ytd_netqty) + ' - ' + CONVERT(VARCHAR, @v_prev_quantity) + ') * ' + CONVERT(VARCHAR, @v_calc_price) + ' * ' + CONVERT(VARCHAR, @v_royaltyrate) + '/100 = ' + CONVERT(VARCHAR, @v_channel_royalty)          
          END

          GOTO NEXT_FORMAT_CHANNEL
        END
      ELSE
        BEGIN
          SET @v_channel_royalty = (@v_quantity - @v_ytd_netqty - @v_prev_quantity) * @v_calc_price * @v_royaltyrate / 100
          IF @i_debugind = 1
            PRINT '    CHANNEL Royalty: (' + CONVERT(VARCHAR, @v_quantity) + ' - ' + CONVERT(VARCHAR, @v_ytd_netqty) + ' - ' + CONVERT(VARCHAR, @v_prev_quantity) + ') * ' + CONVERT(VARCHAR, @v_calc_price) + ' * ' + CONVERT(VARCHAR, @v_royaltyrate) + '/100 = ' + CONVERT(VARCHAR, @v_channel_royalty)          
        END
        
      SET @v_format_royalty = @v_format_royalty + @v_channel_royalty
      SET @v_prev_quantity = @v_quantity
      SET @v_count = @v_count + 1
      
      NEXT_ROYALTY_RATE:
      FETCH royaltyrates_cur INTO @v_royaltyrate, @v_quantity, @v_last_threshold
    END
    
    NEXT_FORMAT_CHANNEL:
    IF @i_debugind = 1
    BEGIN
      PRINT ' TOTAL FORMAT CHANNEL Royalty: ' + CONVERT(VARCHAR, @v_format_royalty)
      PRINT ' -------------------------'
    END
    
    CLOSE royaltyrates_cur
    DEALLOCATE royaltyrates_cur
    
    SET @v_total_royalty = @v_total_royalty + @v_format_royalty
    
    NEXT_FORMAT_CHANNEL_FETCH:
    FETCH saleschannel_cur INTO @v_royaltykey, @v_formatkey, @v_channelcode, @v_royaltypricetype
  END
  
  CLOSE saleschannel_cur
  DEALLOCATE saleschannel_cur
  
  IF @i_debugind = 1
    PRINT ' TOTAL YEAR Royalty: ' + CONVERT(VARCHAR, @v_total_royalty)
  
  SET @o_result = @v_total_royalty
  
END
GO

GRANT EXEC ON qpl_calc_yr_roy_ern TO PUBLIC
GO
