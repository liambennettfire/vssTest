DECLARE
  @v_key INT,
  @v_orglevel INT,
  @v_orgentrykey  INT  

BEGIN

  -- Add calculation for Exchange Rate stage item
  SELECT @v_key = plsummaryitemkey
  FROM plsummaryitemdefinition
  WHERE itemname = 'Stage - Exchange Rate'

  INSERT INTO plsummaryitemcalc
    (plsummaryitemkey, orglevelkey, orgentrykey, calcsql, lastuserid, lastmaintdate)
  SELECT
    @v_key, orglevelkey, orgentrykey, 'EXEC qpl_calc_exchange_rate @projectkey, @plstagecode, @displaycurrency, @result OUTPUT', 'QSIDBA', getdate()
  FROM orgentry
  WHERE orglevelkey IN (SELECT filterorglevelkey FROM filterorglevel WHERE filterkey=29)
  
  -- Add calculation for Exchange Rate consolidated stage item
  SELECT @v_key = plsummaryitemkey
  FROM plsummaryitemdefinition
  WHERE itemname = 'Cons. - Exchange Rate'

  INSERT INTO plsummaryitemcalc
    (plsummaryitemkey, orglevelkey, orgentrykey, calcsql, lastuserid, lastmaintdate)
  SELECT
    @v_key, orglevelkey, orgentrykey, 'EXEC qpl_calc_exchange_rate @projectkey, @plstagecode, @displaycurrency, @result OUTPUT', 'QSIDBA', getdate()
  FROM orgentry
  WHERE orglevelkey IN (SELECT filterorglevelkey FROM filterorglevel WHERE filterkey=29)  
 
  -- Add calculation for Gross Margin % consolidated stage item
  SELECT @v_key = plsummaryitemkey
  FROM plsummaryitemdefinition
  WHERE itemname = 'Cons. - Gross Margin %'

  INSERT INTO plsummaryitemcalc
    (plsummaryitemkey, orglevelkey, orgentrykey, calcsql, lastuserid, lastmaintdate)
  SELECT
    @v_key, orglevelkey, orgentrykey, 'EXEC qpl_calc_cons_stg_gross_marg_pct @projectkey, @plstagecode, @displaycurrency, @result OUTPUT', 'QSIDBA', getdate()
  FROM orgentry
  WHERE orglevelkey IN (SELECT filterorglevelkey FROM filterorglevel WHERE filterkey=29)  

  -- Delete any existing orphan calculations
  DELETE FROM plsummaryitemcalc 
  WHERE NOT EXISTS (SELECT * FROM plsummaryitemdefinition i WHERE i.plsummaryitemkey = plsummaryitemcalc.plsummaryitemkey)

  -- Loop through all orgentries at the P&L Item Calculations Org Level and insert calculations for all Consolidated Stage items
  SELECT @v_orglevel = filterorglevelkey
  FROM filterorglevel
  WHERE filterkey = 29
 
  DECLARE orgs_cur CURSOR FOR
    SELECT orgentrykey
    FROM orgentry
    WHERE orglevelkey = @v_orglevel
  		
  OPEN orgs_cur

  FETCH orgs_cur INTO @v_orgentrykey

  WHILE @@fetch_status = 0
  BEGIN
   
    INSERT INTO plsummaryitemcalc
      (plsummaryitemkey, orglevelkey, orgentrykey, lastuserid, lastmaintdate, calcsql)
    SELECT
      plsummaryitemkey, @v_orglevel, @v_orgentrykey, 'QSIDBA', getdate(),
      'EXEC qpl_calc_consolidated_stage @projectkey, @plstagecode, ' + convert(varchar, (SELECT d.plsummaryitemkey FROM plsummaryitemdefinition d WHERE d.assocplsummaryitemkey = plsummaryitemdefinition.plsummaryitemkey)) + ', @displaycurrency, @result OUTPUT'
    FROM plsummaryitemdefinition
    WHERE summarylevelcode = 5 AND itemlabel <> 'Exchange Rate' AND itemlabel <> 'Gross Margin %'
    
    FETCH orgs_cur INTO @v_orgentrykey
  END
  
  CLOSE orgs_cur
  DEALLOCATE orgs_cur

END
go
