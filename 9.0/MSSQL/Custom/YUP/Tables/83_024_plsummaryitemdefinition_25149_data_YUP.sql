DECLARE
  @v_new_itemkey  INT,
  @v_stg_itemkey  INT

BEGIN

  -- First, remove any item mapping for levels other than Year and P&L Report.
  -- At this point, no items other than Year and P&L Report should be mapped (to corresponding Version items).
  UPDATE plsummaryitemdefinition
  SET assocplsummaryitemkey = NULL
  WHERE assocplsummaryitemkey > 0 AND summarylevelcode NOT IN (3,4)

  SELECT @v_new_itemkey = COALESCE(MAX(plsummaryitemkey),0) + 1
  FROM plsummaryitemdefinition
  
  -- Add a new stage-level summary item for Exchange Rate
  INSERT INTO plsummaryitemdefinition
    (plsummaryitemkey, itemname, itemlabel, itemtype, fieldformat, summarylevelcode, summaryheadingcode, position, lastuserid, lastmaintdate, alwaysrecalcind, qsicode)
  VALUES
    (@v_new_itemkey, 'Stage - Exchange Rate', 'Exchange Rate', 6, '###,##0.0000', 1, 6, 1, 'QSIDBA', getdate(), 1, 1)  

  SET @v_new_itemkey = @v_new_itemkey + 1
  
  -- Loop to copy all active Stage p&l summary items to new Consolidated Stage items,
  -- and establish the mapping between them (Stage mapped to corresponding Consolidated Stage)
  DECLARE stage_items_cur CURSOR FOR
    SELECT plsummaryitemkey 
    FROM plsummaryitemdefinition 
    WHERE summarylevelcode = 1 AND activeind = 1
    ORDER BY CASE summaryheadingcode WHEN 4 THEN 0 ELSE summaryheadingcode END, position
  		
  OPEN stage_items_cur

  FETCH stage_items_cur INTO @v_stg_itemkey

  WHILE @@fetch_status = 0
  BEGIN

    INSERT INTO plsummaryitemdefinition
      (plsummaryitemkey, itemname, itemlabel, itemtype, fieldformat, boldind, italicind, activeind, 
      summarylevelcode, summaryheadingcode, position, lastuserid, lastmaintdate, alwaysrecalcind, currencyind)
    SELECT
      @v_new_itemkey, REPLACE(itemname, 'Stage', 'Cons.'), itemlabel, itemtype, fieldformat, boldind, italicind, activeind, 
      5, summaryheadingcode, position, 'QSIDBA', getdate(), 
      CASE WHEN currencyind = 1 OR itemlabel = 'Exchange Rate' OR itemlabel = 'Gross Margin %' THEN 1 ELSE 0 END, currencyind
    FROM plsummaryitemdefinition
    WHERE plsummaryitemkey = @v_stg_itemkey
    
    UPDATE plsummaryitemdefinition
    SET assocplsummaryitemkey = @v_new_itemkey
    WHERE plsummaryitemkey = @v_stg_itemkey
    
    SET @v_new_itemkey = @v_new_itemkey + 1
        
    FETCH stage_items_cur INTO @v_stg_itemkey
  END

  CLOSE stage_items_cur 
  DEALLOCATE stage_items_cur

END
go
