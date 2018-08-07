if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_version_verification') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_version_verification
GO

CREATE PROCEDURE qpl_version_verification
 (@i_projectkey   integer,
  @i_plstage      integer,
  @i_versionkey   integer,
  @i_userid       varchar(30),
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qpl_version_verification
**  Desc: This is the P&L Version Verification stored procedure for Kaplan.
**        It will run through all active P&L Version Details and verify that each detail
**        is marked complete and all financials are zero or greater.
**        In addition, it will check if sales units are entered for sales channels 
**        without corresponding royalty rates.
**
**  Auth: Kate
**  Date: 6 January 2011
************************************************************************************************/

DECLARE
  @v_amount FLOAT,
  @v_detailtype VARCHAR(50),
  @v_detailtext VARCHAR(50),
  @v_error  INT,
  @v_formatdesc VARCHAR(120),
  @v_formatkey  INT,
  @v_marked_complete  TINYINT,
  @v_num_royaltyrates INT,
  @v_plstatus INT,
  @v_price  FLOAT,
  @v_quantity INT,
  @v_rowcount INT,
  @v_saleschannelcode INT,
  @v_saleschanneldesc VARCHAR(40),
  @v_salesunitsvernote  VARCHAR(MAX),
  @v_status_complete  INT,
  @v_status_incomplete  INT,  
  @v_sum_salesunits INT,
  @v_vermisccostsind  TINYINT,
  @v_vermiscincomeind TINYINT,
  @v_vermktgcompind TINYINT,
  @v_vermktgcostsind  TINYINT,
  @v_verprodcostsind  TINYINT,
  @v_verprodqtyind  TINYINT,
  @v_verprodspecsind  TINYINT,
  @v_verroyaltyind  TINYINT,
  @v_versalesunitsind TINYINT,
  @v_versubrightsind  TINYINT,
  @v_vertotalunitsind TINYINT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- Make sure that taqversioncomplete table exists for this version
  SELECT @v_rowcount = COUNT(*)
  FROM taqversioncomplete
  WHERE taqprojectkey = @i_projectkey AND
      plstagecode = @i_plstage AND
      taqversionkey = @i_versionkey
      
  IF @v_rowcount = 0
  BEGIN
    INSERT INTO taqversioncomplete
      (taqprojectkey, plstagecode, taqversionkey, lastuserid, lastmaintdate)
    VALUES
      (@i_projectkey, @i_plstage, @i_versionkey, @i_userid, getdate())
  END
  
  -- Loop to verify all active details (P&L Comments and Production Costs by Year are not being verified)
  DECLARE pldetails_cur CURSOR FOR 
    SELECT detailtype, detailtext 
    FROM pldetails 
    WHERE activeind = 1 AND detailtype NOT IN ('PLVerProductionCostsByYear', 'PLVerComments')
    ORDER BY sortorder
        
  OPEN pldetails_cur
  
  FETCH pldetails_cur INTO @v_detailtype, @v_detailtext

  WHILE @@fetch_status = 0
  BEGIN
        
    -- ********* SALES UNITS ***********
    IF @v_detailtype = 'PLVerSalesUnits'
    BEGIN
      -- Assume everything is complete on Sales Units screen - invalidate and note reasons in the loop
      SET @v_versalesunitsind = 1
      SET @v_salesunitsvernote = ' '
    
      -- Loop through taqversionformatcomplete table to see if Complete checkbox was checked on Sales Units screen for all formats
      DECLARE formatcomplete_cur CURSOR FOR 
        SELECT f.taqprojectformatkey, s.datadesc, f.activeprice, c.salesunitcompleteind
        FROM taqversionformat f
          LEFT OUTER JOIN taqversionformatcomplete c ON f.taqprojectkey = c.taqprojectkey AND 
            f.plstagecode = c.plstagecode AND
            f.taqversionkey = c.taqversionkey AND
            f.taqprojectformatkey = c.taqprojectformatkey,
            subgentables s
        WHERE f.mediatypecode = s.datacode AND
            f.mediatypesubcode = s.datasubcode AND
            s.tableid = 312 AND
            f.taqprojectkey = @i_projectkey AND
            f.plstagecode = @i_plstage AND
            f.taqversionkey = @i_versionkey
    
      OPEN formatcomplete_cur
      
      FETCH formatcomplete_cur INTO @v_formatkey, @v_formatdesc, @v_price, @v_marked_complete

      WHILE @@fetch_status = 0
      BEGIN
        
        IF @v_marked_complete IS NULL OR @v_marked_complete = 0
        BEGIN
          IF @v_salesunitsvernote <> ' '
            SET @v_salesunitsvernote = @v_salesunitsvernote + ', '
            
          SET @v_versalesunitsind = 0
          SET @v_salesunitsvernote = @v_salesunitsvernote + 'Sales Units marked Incomplete for ' + @v_formatdesc  
        END
        ELSE
        BEGIN
        
          IF @v_price IS NULL
          BEGIN
            IF @v_salesunitsvernote <> ' '
              SET @v_salesunitsvernote = @v_salesunitsvernote + ', '
            
            SET @v_versalesunitsind = 0
            SET @v_salesunitsvernote = @v_salesunitsvernote + 'Missing price for ' + @v_formatdesc
          END
          
          -- Check format prices, sales units and corresponding sales channel royalties
          DECLARE salesunits_cur CURSOR FOR          
            SELECT c.saleschannelcode, g.datadesc, SUM(u.grosssalesunits), 
                (SELECT COUNT(*) FROM taqversionroyaltysaleschannel cr, taqversionroyaltyrates r
                 WHERE cr.taqversionroyaltykey = r.taqversionroyaltykey AND 
                    cr.taqprojectformatkey = c.taqprojectformatkey AND 
                    cr.saleschannelcode = c.saleschannelcode)
            FROM taqversionsaleschannel c 
                LEFT OUTER JOIN taqversionsalesunit u ON u.taqversionsaleskey = c.taqversionsaleskey,
                gentables g
            WHERE c.saleschannelcode = g.datacode AND g.tableid = 118 AND
                c.taqprojectkey = @i_projectkey AND
                c.plstagecode = @i_plstage AND
                c.taqversionkey = @i_versionkey AND
                c.taqprojectformatkey = @v_formatkey
            GROUP BY c.taqprojectformatkey, c.saleschannelcode, g.datadesc, g.sortorder
            ORDER BY c.taqprojectformatkey, g.sortorder
          
          OPEN salesunits_cur
          
          FETCH salesunits_cur INTO @v_saleschannelcode, @v_saleschanneldesc, @v_sum_salesunits, @v_num_royaltyrates

          WHILE @@fetch_status = 0
          BEGIN
            
            IF @v_num_royaltyrates = 0
            BEGIN
              IF @v_salesunitsvernote <> ' '
                SET @v_salesunitsvernote = @v_salesunitsvernote + ', '
              
              SET @v_versalesunitsind = 0
              SET @v_salesunitsvernote = @v_salesunitsvernote + 'Missing royalty rates for ' + @v_saleschanneldesc + ' sales channel (' + @v_formatdesc + ')'
            END
                        
            IF @v_sum_salesunits IS NULL
            BEGIN
              IF @v_salesunitsvernote <> ' '
                SET @v_salesunitsvernote = @v_salesunitsvernote + ', '
              
              SET @v_versalesunitsind = 0
              SET @v_salesunitsvernote = @v_salesunitsvernote + 'Missing sales units for ' + @v_saleschanneldesc + ' sales channel (' + @v_formatdesc + ')'
            END
                    
            FETCH salesunits_cur INTO @v_saleschannelcode, @v_saleschanneldesc, @v_sum_salesunits, @v_num_royaltyrates
          END

          CLOSE salesunits_cur 
          DEALLOCATE salesunits_cur        
        END
      
        FETCH formatcomplete_cur INTO @v_formatkey, @v_formatdesc, @v_price, @v_marked_complete
      END

      CLOSE formatcomplete_cur 
      DEALLOCATE formatcomplete_cur
            
    END --PLVerSalesUnits
    
    -- ********* ROYALTY ***********
    ELSE IF @v_detailtype = 'PLVerRoyalty' BEGIN
    
      SELECT @v_marked_complete = royaltycompleteind
      FROM taqversioncomplete
      WHERE taqprojectkey = @i_projectkey AND
                plstagecode = @i_plstage AND
                taqversionkey = @i_versionkey
      
      -- If Royalty screen is not marked complete, we are done - set royaltyverifiedind to false
      IF @v_marked_complete IS NULL OR @v_marked_complete = 0
      BEGIN
        SET @v_verroyaltyind = 0  
      END
      -- If Royalty screen is marked complete, we must verify that it actually is - check for NULL Royalty Advance amounts 
      ELSE
      BEGIN             
        DECLARE advance_cur CURSOR FOR
          SELECT amount FROM taqversionroyaltyadvance 
          WHERE taqprojectkey = @i_projectkey AND
              plstagecode = @i_plstage AND
              taqversionkey = @i_versionkey
          ORDER BY amount
                  
        OPEN advance_cur
        
        FETCH advance_cur INTO @v_amount

        IF @@fetch_status <> 0
          SET @v_verroyaltyind = 1  --no royalty advance rows - OK
        ELSE
        BEGIN
          WHILE @@fetch_status = 0
          BEGIN
            IF @v_amount IS NULL
              BREAK
          
            FETCH advance_cur INTO @v_amount
          END
        
          IF @v_amount IS NULL
            SET @v_verroyaltyind = 0
          ELSE
            SET @v_verroyaltyind = 1
        END
        
        CLOSE advance_cur 
        DEALLOCATE advance_cur        
      END
      
    END --PLVerRoyalty
        
    -- ********* MARKETING COSTS ***********
    ELSE IF @v_detailtype = 'PLVerMarketingCosts' BEGIN
    
      SELECT @v_marked_complete = mktgcostcompleteind
      FROM taqversioncomplete
      WHERE taqprojectkey = @i_projectkey AND
                plstagecode = @i_plstage AND
                taqversionkey = @i_versionkey
      
      -- If Marketing Costs screen is not marked complete, we are done - set mktgcostverifiedind to false
      IF @v_marked_complete IS NULL OR @v_marked_complete = 0
      BEGIN
        SET @v_vermktgcostsind = 0
      END
      -- If Marketing Costs screen is marked complete, we must verify that it actually is - check for NULL amounts for any of the marketing chargecodes
      ELSE
      BEGIN      
        DECLARE mktgcosts_cur CURSOR FOR
          SELECT SUM(c.versioncostsamount) 
          FROM taqversioncosts c, taqversionformatyear y
          WHERE c.taqversionformatyearkey = y.taqversionformatyearkey AND
            y.taqprojectkey = @i_projectkey AND 
            y.plstagecode = @i_plstage AND 
            y.taqversionkey = @i_versionkey AND
            c.acctgcode IN (SELECT internalcode FROM cdlist WHERE placctgcategorycode = 1)
          GROUP BY y.taqprojectformatkey, c.acctgcode
          ORDER BY SUM(c.versioncostsamount)
                  
        OPEN mktgcosts_cur
        
        FETCH mktgcosts_cur INTO @v_amount

        IF @@fetch_status <> 0
          SET @v_vermktgcostsind = 1  --no marketing costs - OK
        ELSE
        BEGIN
          WHILE @@fetch_status = 0
          BEGIN
          
            IF @v_amount IS NULL
              BREAK
          
            FETCH mktgcosts_cur INTO @v_amount
          END
        
          IF @v_amount IS NULL
            SET @v_vermktgcostsind = 0
          ELSE
            SET @v_vermktgcostsind = 1
        END
        
        CLOSE mktgcosts_cur 
        DEALLOCATE mktgcosts_cur        
      END
          
    END --PLVerMarketingCosts
    
    -- ********* MARKETING COMP COPIES ***********
    ELSE IF @v_detailtype = 'PLVerMarketingCompCopies' BEGIN
    
      SELECT @v_marked_complete = mktgcompcompleteind
      FROM taqversioncomplete
      WHERE taqprojectkey = @i_projectkey AND
                plstagecode = @i_plstage AND
                taqversionkey = @i_versionkey
      
      -- If Marketing Comp Copies screen is not marked complete, we are done - set mktgcompverifiedind to false
      IF @v_marked_complete IS NULL OR @v_marked_complete = 0
      BEGIN
        SET @v_vermktgcompind = 0 
      END
      -- If Marketing Comp Copies screen is marked complete, we must verify that it actually is - check for NULL quantities
      ELSE
      BEGIN      
        DECLARE mktgcomp_cur CURSOR FOR
          SELECT SUM(y.quantity)
          FROM taqversionaddtlunits u 
            LEFT OUTER JOIN taqversionaddtlunitsyear y ON y.addtlunitskey = u.addtlunitskey
          WHERE u.taqprojectkey = @i_projectkey AND
            u.plstagecode = @i_plstage AND
            u.taqversionkey = @i_versionkey AND
            u.plunittypecode = (SELECT datacode FROM gentables WHERE tableid = 570 AND qsicode = 1) --Marketing units
          GROUP BY u.addtlunitskey
          ORDER BY SUM(y.quantity)
                  
        OPEN mktgcomp_cur
        
        FETCH mktgcomp_cur INTO @v_quantity

        IF @@fetch_status <> 0
          SET @v_vermktgcompind = 1 --no comp copy rows - OK
        ELSE
        BEGIN
          WHILE @@fetch_status = 0
          BEGIN
          
            IF @v_quantity IS NULL
              BREAK
          
            FETCH mktgcomp_cur INTO @v_quantity
          END
        
          IF @v_quantity IS NULL
            SET @v_vermktgcompind = 0
          ELSE
            SET @v_vermktgcompind = 1
        END
        
        CLOSE mktgcomp_cur 
        DEALLOCATE mktgcomp_cur        
      END
      
    END --PLVerMarketingCompCopies
    
    -- ********* SUBRIGHTS INCOME ***********
    ELSE IF @v_detailtype = 'PLVerSubrightsIncome' BEGIN
    
      SELECT @v_marked_complete = subrightscompleteind
      FROM taqversioncomplete
      WHERE taqprojectkey = @i_projectkey AND
                plstagecode = @i_plstage AND
                taqversionkey = @i_versionkey
      
      -- If Subrights Income screen is not marked complete, we are done - set subrightsverifiedind to false
      IF @v_marked_complete IS NULL OR @v_marked_complete = 0
      BEGIN
        SET @v_versubrightsind = 0
      END
      -- If Subrights Income screen is marked complete, we must verify that it actually is - check for NULL amounts for each subright
      ELSE
      BEGIN      
        DECLARE subrights_cur CURSOR FOR
          SELECT SUM(y.amount)
          FROM taqversionsubrights s LEFT OUTER JOIN taqversionsubrightsyear y ON y.subrightskey = s.subrightskey
          WHERE s.taqprojectkey = @i_projectkey AND
            s.plstagecode = @i_plstage AND
            s.taqversionkey = @i_versionkey 
          GROUP BY s.subrightskey
          ORDER BY SUM(y.amount)
                  
        OPEN subrights_cur
        
        FETCH subrights_cur INTO @v_amount

        IF @@fetch_status <> 0
          SET @v_versubrightsind = 1
        ELSE
        BEGIN
          WHILE @@fetch_status = 0
          BEGIN
          
            IF @v_amount IS NULL
              BREAK
          
            FETCH subrights_cur INTO @v_amount
          END
        
          IF @v_amount IS NULL
            SET @v_versubrightsind = 0
          ELSE
            SET @v_versubrightsind = 1
        END
        
        CLOSE subrights_cur 
        DEALLOCATE subrights_cur        
      END    
    
    END --PLVerSubrightsIncome
    
    -- ********* MISCELLANEOUS INCOME ***********
    ELSE IF @v_detailtype = 'PLVerMiscIncome' BEGIN
    
      SELECT @v_marked_complete = miscincomecompleteind
      FROM taqversioncomplete
      WHERE taqprojectkey = @i_projectkey AND
                plstagecode = @i_plstage AND
                taqversionkey = @i_versionkey
      
      -- If Misc Income screen is not marked complete, we are done - set miscincomeverifiedind to false
      IF @v_marked_complete IS NULL OR @v_marked_complete = 0
      BEGIN
        SET @v_vermiscincomeind = 0
      END
      -- If Misc Income screen is marked complete, we must verify that it actually is - check for NULL amounts for any of the misc income chargecodes
      ELSE
      BEGIN      
        DECLARE miscincome_cur CURSOR FOR
          SELECT SUM(i.incomeamount) 
          FROM taqversionincome i, taqversionformatyear y
          WHERE i.taqversionformatyearkey = y.taqversionformatyearkey AND
              y.taqprojectkey = @i_projectkey AND 
              y.plstagecode = @i_plstage AND
              y.taqversionkey = @i_versionkey AND
              i.acctgcode IN (SELECT internalcode FROM cdlist WHERE placctgcategorycode = 3)
          GROUP BY y.taqprojectformatkey, i.acctgcode
          ORDER BY SUM(i.incomeamount)
                  
        OPEN miscincome_cur
        
        FETCH miscincome_cur INTO @v_amount

        IF @@fetch_status <> 0
          SET @v_vermiscincomeind = 1 --no misc income rows - OK
        ELSE
        BEGIN
          WHILE @@fetch_status = 0
          BEGIN
          
            IF @v_amount IS NULL
              BREAK
          
            FETCH miscincome_cur INTO @v_amount
          END
        
          IF @v_amount IS NULL
            SET @v_vermiscincomeind = 0
          ELSE
            SET @v_vermiscincomeind = 1
        END
        
        CLOSE miscincome_cur 
        DEALLOCATE miscincome_cur        
      END
          
    END --PLVerMiscIncome
    
    -- ********* MISCELLANEOUS COSTS ***********
    ELSE IF @v_detailtype = 'PLVerMiscCosts' BEGIN
    
      SELECT @v_marked_complete = misccostcompleteind
      FROM taqversioncomplete
      WHERE taqprojectkey = @i_projectkey AND
                plstagecode = @i_plstage AND
                taqversionkey = @i_versionkey
      
      -- If Misc Costs screen is not marked complete, we are done - set misccostverifiedind to false
      IF @v_marked_complete IS NULL OR @v_marked_complete = 0
      BEGIN
        SET @v_vermisccostsind = 0
      END
      -- If Misc Costs screen is marked complete, we must verify that it actually is - check for NULL amounts for any of the misc chargecodes
      ELSE
      BEGIN      
        DECLARE misccosts_cur CURSOR FOR
          SELECT SUM(c.versioncostsamount) 
          FROM taqversioncosts c, taqversionformatyear y
          WHERE c.taqversionformatyearkey = y.taqversionformatyearkey AND
            y.taqprojectkey = @i_projectkey AND 
            y.plstagecode = @i_plstage AND 
            y.taqversionkey = @i_versionkey AND
            c.acctgcode IN (SELECT internalcode FROM cdlist WHERE placctgcategorycode = 10)
          GROUP BY y.taqprojectformatkey, c.acctgcode
          ORDER BY SUM(c.versioncostsamount)         
                  
        OPEN misccosts_cur
        
        FETCH misccosts_cur INTO @v_amount

        IF @@fetch_status <> 0
          SET @v_vermisccostsind = 1  --no misc costs rows - OK
        ELSE
        BEGIN
          WHILE @@fetch_status = 0
          BEGIN
          
            IF @v_amount IS NULL
              BREAK
          
            FETCH misccosts_cur INTO @v_amount
          END
        
          IF @v_amount IS NULL
            SET @v_vermisccostsind = 0
          ELSE
            SET @v_vermisccostsind = 1
        END
        
        CLOSE misccosts_cur 
        DEALLOCATE misccosts_cur        
      END
    
    END --PLVerMiscCosts
    
    -- ********* PRODUCTION QUANTITY ***********
    ELSE IF @v_detailtype = 'PLVerProductionQuantity' BEGIN
        
      SELECT @v_marked_complete = prodqtycompleteind
      FROM taqversioncomplete
      WHERE taqprojectkey = @i_projectkey AND
                plstagecode = @i_plstage AND
                taqversionkey = @i_versionkey
      
      -- If Production Quantity screen is not marked complete, we are done - set prodqtyverifiedind to false
      IF @v_marked_complete IS NULL OR @v_marked_complete = 0
      BEGIN
        SET @v_verprodqtyind = 0
      END
      -- If Production Quantity screen is marked complete, we must verify that it actually is - check for NULL quantities for each format
      ELSE
      BEGIN      
        DECLARE prodqty_cur CURSOR FOR
          SELECT y.taqprojectformatkey, s.datadesc, SUM(y.quantity)
          FROM taqversionformatyear y, taqversionformat f, subgentables s
          WHERE y.taqprojectkey = f.taqprojectkey AND
              y.plstagecode = f.plstagecode AND
              y.taqversionkey = f.taqversionkey AND
              y.taqprojectformatkey = f.taqprojectformatkey AND
              f.mediatypecode = s.datacode AND f.mediatypesubcode = s.datasubcode AND s.tableid = 312 AND
              y.taqprojectkey = @i_projectkey AND
              y.plstagecode = @i_plstage AND 
              y.taqversionkey = @i_versionkey AND
              y.yearcode NOT IN (SELECT datacode FROM gentables WHERE tableid = 563 AND qsicode = 1)
          GROUP BY y.taqprojectformatkey, s.datadesc
                  
        OPEN prodqty_cur
        
        FETCH prodqty_cur INTO @v_formatkey, @v_formatdesc, @v_quantity

        WHILE @@fetch_status = 0
        BEGIN
        
          IF @v_quantity IS NULL
            BREAK
        
          FETCH prodqty_cur INTO @v_formatkey, @v_formatdesc, @v_quantity
        END

        CLOSE prodqty_cur 
        DEALLOCATE prodqty_cur
        
        IF @v_quantity IS NULL
          SET @v_verprodqtyind = 0
        ELSE
          SET @v_verprodqtyind = 1                      
      END
          
    END --PLVerProductionQuantity
        
    -- ********* PRODUCTION SPECIFICATIONS ***********
    ELSE IF @v_detailtype = 'PLVerProductionSpecs' BEGIN
    
      -- Loop through taqversionformatcomplete table to see if Complete checkbox was checked on Prod Specs screen for all formats
      DECLARE prodspecscomplete_cur CURSOR FOR 
        SELECT f.taqprojectformatkey, c.prodspecscompleteind
        FROM taqversionformat f
          LEFT OUTER JOIN taqversionformatcomplete c ON f.taqprojectkey = c.taqprojectkey AND 
            f.plstagecode = c.plstagecode AND
            f.taqversionkey = c.taqversionkey AND
            f.taqprojectformatkey = c.taqprojectformatkey 
        WHERE f.taqprojectkey = @i_projectkey AND
              f.plstagecode = @i_plstage AND
              f.taqversionkey = @i_versionkey   
        ORDER BY prodspecscompleteind
    
      OPEN prodspecscomplete_cur
      
      FETCH prodspecscomplete_cur INTO @v_formatkey, @v_marked_complete

      WHILE @@fetch_status = 0
      BEGIN
      
        IF @v_marked_complete IS NULL OR @v_marked_complete = 0
          BREAK
      
        FETCH prodspecscomplete_cur INTO @v_formatkey, @v_marked_complete        
      END

      CLOSE prodspecscomplete_cur 
      DEALLOCATE prodspecscomplete_cur
      
      -- If any of the formats on Prod Specs screen is marked incomplete, Prod Specs version detail is Incomplete
      IF @v_marked_complete = 1
        SET @v_verprodspecsind = 1
      ELSE
        SET @v_verprodspecsind = 0
          
    END --PLVerProductionSpecs
    
    -- ********* PRODUCTION COSTS ***********
    ELSE IF @v_detailtype = 'PLVerProductionCostsByPrtg' BEGIN
    
      SELECT @v_marked_complete = prodcostscompleteind
      FROM taqversioncomplete
      WHERE taqprojectkey = @i_projectkey AND
                plstagecode = @i_plstage AND
                taqversionkey = @i_versionkey
      
      -- If Prod Costs screen is not marked complete, we are done - set prodcostsverifiedind to false
      IF @v_marked_complete IS NULL OR @v_marked_complete = 0
      BEGIN
        SET @v_verprodcostsind = 0 
      END
      -- If Prod Costs screen is marked complete, we must verify that it actually is - check for NULL amounts for any of the prod chargecodes
      ELSE
      BEGIN      
        DECLARE prodcosts_cur CURSOR FOR
          SELECT SUM(c.versioncostsamount) 
          FROM taqversioncosts c, taqversionformatyear y
          WHERE c.taqversionformatyearkey = y.taqversionformatyearkey AND
            y.taqprojectkey = @i_projectkey AND 
            y.plstagecode = @i_plstage AND 
            y.taqversionkey = @i_versionkey AND
            c.acctgcode IN (SELECT internalcode FROM cdlist WHERE placctgcategorycode = 2)
          GROUP BY y.taqprojectformatkey, c.acctgcode
          ORDER BY SUM(c.versioncostsamount)
                  
        OPEN prodcosts_cur
        
        FETCH prodcosts_cur INTO @v_amount

        WHILE @@fetch_status = 0
        BEGIN
        
          IF @v_amount IS NULL
            BREAK
        
          FETCH prodcosts_cur INTO @v_amount
        END

        CLOSE prodcosts_cur 
        DEALLOCATE prodcosts_cur
        
        IF @v_amount IS NULL
          SET @v_verprodcostsind = 0
        ELSE
          SET @v_verprodcostsind = 1
      END
          
    END --PLVerProductionCostsByPrtg
    
    -- ********* TOTAL UNITS REQUIRED ***********
    ELSE IF @v_detailtype = 'PLVerTotalUnitsRequired' BEGIN
    
      SELECT @v_marked_complete = totalunitscompleteind
      FROM taqversioncomplete
      WHERE taqprojectkey = @i_projectkey AND
                plstagecode = @i_plstage AND
                taqversionkey = @i_versionkey
      
      -- If Total Units Required screen is not marked complete, we are done - set totalunitsverifiedind to false
      IF @v_marked_complete IS NULL OR @v_marked_complete = 0
      BEGIN
        SET @v_vertotalunitsind = 0
      END
      -- If Total Units Required screen is marked complete, we must verify that it actually is - check for NULL quantities
      ELSE
      BEGIN      
        DECLARE totalunits_cur CURSOR FOR
          SELECT SUM(y.quantity)
          FROM taqversionaddtlunits u 
            LEFT OUTER JOIN taqversionaddtlunitsyear y ON y.addtlunitskey = u.addtlunitskey
          WHERE u.taqprojectkey = @i_projectkey AND
            u.plstagecode = @i_plstage AND
            u.taqversionkey = @i_versionkey AND
            u.plunittypecode IN (SELECT datacode FROM gentables WHERE tableid = 570 AND qsicode <> 1) --Other than marketing units
          GROUP BY u.addtlunitskey
          ORDER BY SUM(y.quantity)
                  
        OPEN totalunits_cur
        
        FETCH totalunits_cur INTO @v_quantity
        
        IF @@fetch_status <> 0
          SET @v_vertotalunitsind = 1 --no additional units rows - OK
        ELSE
        BEGIN
          WHILE @@fetch_status = 0
          BEGIN
          
            IF @v_quantity IS NULL
              BREAK
          
            FETCH totalunits_cur INTO @v_quantity
          END
        
          IF @v_quantity IS NULL
            SET @v_vertotalunitsind = 0
          ELSE
            SET @v_vertotalunitsind = 1
        END
        
        CLOSE totalunits_cur 
        DEALLOCATE totalunits_cur        
      END
          
    END --PLVerTotalUnitsRequired
    
    FETCH pldetails_cur INTO @v_detailtype, @v_detailtext    
  END

  CLOSE pldetails_cur 
  DEALLOCATE pldetails_cur
  
  -- Update version complete indicators on taqversioncomplete table
  UPDATE taqversioncomplete
  SET salesunitsverifiedind = @v_versalesunitsind, royaltyverifiedind = @v_verroyaltyind, 
      mktgcostverifiedind = @v_vermktgcostsind, mktgcompverifiedind = @v_vermktgcompind,
      subrightsverifiedind = @v_versubrightsind, miscincomeverifiedind = @v_vermiscincomeind,
      misccostverifiedind = @v_vermisccostsind, prodspecsverifiedind = @v_verprodspecsind,
      prodcostsverifiedind = @v_verprodcostsind, prodqtyverifiedind = @v_verprodqtyind,
      totalunitsverifiedind = @v_vertotalunitsind, salesunitsvernote = @v_salesunitsvernote,
      lastverifieduserid = @i_userid, lastverifieddatetime = getdate()
  WHERE taqprojectkey = @i_projectkey AND
      plstagecode = @i_plstage AND
      taqversionkey = @i_versionkey

    SELECT @v_error = @@error
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not update verification indicators taqversion table (@@error=' + CONVERT(VARCHAR, @v_error) + ').'
      RETURN
    END
    
  SELECT @v_status_incomplete = datacode
  FROM gentables
  WHERE tableid = 565 AND qsicode = 1
  
  SELECT @v_rowcount = @@ROWCOUNT
  IF @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Missing qsicode=1 row on gentables 565 (P&L Status).'
    RETURN
  END
        
  IF @v_versalesunitsind = 1 AND @v_verroyaltyind = 1 AND @v_vermktgcostsind = 1 AND @v_vermktgcompind = 1 AND
    @v_versubrightsind = 1 AND @v_vermiscincomeind = 1 AND @v_vermisccostsind = 1 AND @v_verprodspecsind = 1 AND
    @v_verprodcostsind = 1 AND @v_verprodqtyind = 1 AND @v_vertotalunitsind = 1 --All version details are complete
  BEGIN
    -- First, check if the current P&L Status on this version allows for changing the status to the verified complete - only for "Incomplete"
    SELECT @v_plstatus = plstatuscode
    FROM taqversion
    WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_versionkey
    
    IF @v_plstatus = @v_status_incomplete
    BEGIN
      SELECT @v_status_complete = clientdefaultvalue
      FROM clientdefaults
      WHERE clientdefaultid = 53  --P&L Verified Complete Status
      
      SELECT @v_rowcount = @@ROWCOUNT
      IF @v_rowcount = 0
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Missing client default 53-P&L Verified Complete Status.'
        RETURN
      END
      
      IF @v_status_complete IS NULL OR @v_status_complete = 0
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Client default 53 has no value.'
        RETURN
      END
          
      UPDATE taqversion
      SET plstatuscode = @v_status_complete
      WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_versionkey
      
      SELECT @v_error = @@error
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not update plstatuscode on taqversion table (@@error=' + CONVERT(VARCHAR, @v_error) + ').'
        RETURN
      END      
    END     
  END
  ELSE  --at least one version detail is Incomplete
  BEGIN     
    UPDATE taqversion
    SET plstatuscode = @v_status_incomplete
    WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_versionkey
    
    SELECT @v_error = @@error
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not update plstatuscode on taqversion table (@@error=' + CONVERT(VARCHAR, @v_error) + ').'
      RETURN
    END    
  END
  
END
GO

GRANT EXEC ON qpl_version_verification TO PUBLIC
GO


