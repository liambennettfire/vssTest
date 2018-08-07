if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_update_component_qty') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_update_component_qty
GO

CREATE PROCEDURE qpl_update_component_qty (
  @i_categorykey  INT,
  @i_projectkey   INT,
  @i_plstage      INT,
  @i_plversion    INT,
  @i_formatkey    INT,
  @i_userid       VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/**************************************************************************************************************************
**  Name: qpl_update_component_qty
**  Desc: This stored procedure processes component quantity change.
**
**  Auth: Kate
**  Date: October 7 2014
****************************************************************************************************************************
**  Change History
****************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**	03/03/16    Kate      Update Production Qty only when > 0 i.e. keep default 1 value rather than NULL or 0 (see Case 36595)
**  05/13/16    Kate      Case 37437 - Issues with Quantity column on taqversionformatyear table 
****************************************************************************************************************************/

DECLARE
  @v_acctgcode  INT,
  @v_categorykey  INT,
  @v_categorycode INT,
  @v_calcqty  INT,
  @v_compqty  INT,
  @v_compunitcost FLOAT,
  @v_count INT,
  @v_error  INT,
  @v_finishedgoodind  TINYINT,
  @v_first_categorykey INT,  
  @v_first_categorykey_qty INT,
  @v_first_relatedspeccategorykey INT, 
  @v_formatkey INT, 
  @v_formatyearkey  INT,
  @v_itemtype INT,
  @v_lockedind INT, 
  @v_newcompqty INT,
  @v_newtotalcost FLOAT,
  @v_newunitcost  FLOAT,
  @v_plcalccostcode INT,
  @v_plstage INT,
  @v_plversion INT, 
  @v_printingnumber INT,
  @v_prodqtyentrytypecode INT,
  @v_projectkey INT,
  @v_qty  INT,  
  @v_relatedcategorykey INT,
  @v_related_formatkey INT,  
  @v_related_plstage INT,
  @v_related_plversion INT,
  @v_related_projectkey INT,  
  @v_speccategorykey  INT,
  @v_spoilagepercent  DECIMAL(8,2),
  @v_taqversionspecategorykey INT,
  @v_totalcost  FLOAT
  
BEGIN

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

  IF @i_formatkey IS NULL BEGIN
    SET @o_error_desc = 'Invalid formatkey.'
    GOTO RETURN_ERROR
  END

  --PRINT '@i_categorykey=' + convert(varchar, @i_categorykey)
  --PRINT '@i_projectkey=' + convert(varchar, @i_projectkey)
  --PRINT '@i_plstage=' + convert(varchar, @i_plstage)
  --PRINT '@i_plversion=' + convert(varchar, @i_plversion)
  --PRINT '@i_formatkey=' + convert(varchar, @i_formatkey)

  IF @i_categorykey IS NULL OR @i_categorykey = 0
  BEGIN
    DECLARE components_cur CURSOR FOR
      SELECT taqversionspecategorykey
      FROM taqversionspeccategory
      WHERE taqprojectkey = @i_projectkey 
        AND plstagecode = @i_plstage 
        AND taqversionkey = @i_plversion 
        AND taqversionformatkey = @i_formatkey

    OPEN components_cur 

    FETCH components_cur INTO @v_categorykey

    WHILE (@@FETCH_STATUS=0)
    BEGIN
      EXEC qpl_update_component_qty @v_categorykey, @i_projectkey, @i_plstage, @i_plversion, @i_formatkey, 
        @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT

      IF @o_error_code = -1
        GOTO RETURN_ERROR

      FETCH components_cur INTO @v_categorykey
    END

    CLOSE components_cur
    DEALLOCATE components_cur
  END
  ELSE IF @i_categorykey > 0 BEGIN
    -- check to see if this has a related component
    SELECT @v_relatedcategorykey = relatedspeccategorykey
    FROM taqversionspeccategory
    WHERE taqversionspecategorykey = @i_categorykey

    --PRINT '@v_relatedcategorykey=' + convert(varchar, @v_relatedcategorykey) 
     
    IF @v_relatedcategorykey > 0 BEGIN
      -- call this procedure again for the related speccategory
      SELECT @v_related_projectkey = taqprojectkey, @v_related_formatkey = taqversionformatkey,
        @v_related_plstage = plstagecode, @v_related_plversion = taqversionkey
      FROM taqversionspeccategory
      WHERE taqversionspecategorykey = @v_relatedcategorykey
        
      --PRINT '@v_related_projectkey=' + convert(varchar, @v_related_projectkey)
      --PRINT '@v_related_plstage=' + convert(varchar, @v_related_plstage)
      --PRINT '@v_related_plversion=' + convert(varchar, @v_related_plversion)
      --PRINT '@v_related_formatkey=' + convert(varchar, @v_related_formatkey)
        
      EXEC qpl_update_component_qty @v_relatedcategorykey, @v_related_projectkey, @v_related_plstage, @v_related_plversion, @v_related_formatkey, 
        @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT

      IF @o_error_code = -1 BEGIN
        GOTO RETURN_ERROR        
      END
      
      RETURN
    END
  END
  
  IF COALESCE(@i_categorykey,0) = 0 BEGIN
    RETURN
  END

  SELECT @v_itemtype = searchitemcode
  FROM taqproject
  WHERE taqprojectkey = @i_projectkey

  IF @v_itemtype = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 14)  --Printing project
    SELECT @v_printingnumber = printingnum
    FROM taqprojectprinting_view
    WHERE taqprojectkey = @i_projectkey
  ELSE
    SET @v_printingnumber = 1
    
  --PRINT '@v_printingnumber=' + CONVERT(VARCHAR, @v_printingnumber)  
  
  DECLARE updateprodqty_cur CURSOR FOR
    SELECT taqversionspecategorykey, taqprojectkey, taqversionformatkey, plstagecode, taqversionkey, itemcategorycode, relatedspeccategorykey
    FROM taqversionspeccategory
    WHERE taqversionspecategorykey = @i_categorykey
   UNION
    SELECT c.taqversionspecategorykey, c.taqprojectkey, c.taqversionformatkey, c.plstagecode, c.taqversionkey, c.itemcategorycode, c.relatedspeccategorykey
    FROM taqprojectrelationship r, taqversionspeccategory c 
    WHERE r.taqprojectkey1 = c.taqprojectkey 
      AND r.taqprojectkey2 = @i_projectkey 
      AND r.relationshipcode2 = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 25)
      AND r.relationshipcode1 = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 26)
   
  OPEN updateprodqty_cur 

  FETCH updateprodqty_cur
  INTO @v_categorykey, @v_projectkey, @v_formatkey, @v_plstage, @v_plversion, @v_categorycode, @v_relatedcategorykey

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    --PRINT ' --'
    --PRINT ' @v_categorykey=' + convert(varchar, @v_categorykey) 
    --PRINT ' @v_projectkey=' + convert(varchar, @v_projectkey)
    --PRINT ' @v_formatkey=' + convert(varchar, @v_formatkey)    
    --PRINT ' @v_plstage=' + convert(varchar, @v_plstage)
    --PRINT ' @v_plversion=' + convert(varchar, @v_plversion)
    --PRINT ' @v_categorycode=' + convert(varchar, @v_categorycode)
    --PRINT ' @v_relatedcategorykey=' + coalesce(convert(varchar, @v_relatedcategorykey),'NULL')

    -- Because we are updating quantities throughout the run, we need to retrieve component quantity real-time
    IF @v_relatedcategorykey > 0
      SELECT @v_finishedgoodind = finishedgoodind, @v_compqty = quantity
      FROM taqversionspeccategory
      WHERE taqversionspecategorykey = @v_relatedcategorykey
    ELSE
      SELECT @v_finishedgoodind = finishedgoodind, @v_compqty = quantity
      FROM taqversionspeccategory
      WHERE taqversionspecategorykey = @v_categorykey

    --PRINT ' @v_finishedgoodind=' + convert(varchar, @v_finishedgoodind)
    --PRINT ' @v_compqty=' + coalesce(convert(varchar, @v_compqty),'NULL')
  
    -- make sure project is not locked
    SELECT @v_lockedind = COALESCE(g.gen2ind,0)
      FROM taqproject tp, gentables g
     WHERE tp.taqprojectkey = @v_projectkey
       AND g.tableid = 522
       AND tp.taqprojectstatuscode = g.datacode

    --PRINT ' @v_lockedind=' + convert(varchar, @v_lockedind)
     
    IF @v_lockedind = 0 BEGIN
      SELECT @v_prodqtyentrytypecode = prodqtyentrytypecode
      FROM taqversion
      WHERE taqprojectkey = @v_projectkey 
        AND plstagecode = @v_plstage 
        AND taqversionkey = @v_plversion

      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_desc = 'Unable to get prodqtyentrytypecode from taqversion (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END
      
      --PRINT ' @v_prodqtyentrytypecode=' + convert(varchar, @v_prodqtyentrytypecode)

      IF @v_finishedgoodind = 1
      BEGIN
        
        -- When generating from FG Component Quantity, and this is a Finished Good component,
        -- update Production Quantity on taqversionformatyear to the FG component quantity
        IF @v_prodqtyentrytypecode = 4 AND @v_compqty > 0 --Generate from FG Component Quantity
        BEGIN 
          UPDATE taqversionformatyear
          SET quantity = @v_compqty, printingnumber = @v_printingnumber, lastuserid = @i_userid, lastmaintdate = getdate()
          WHERE taqprojectkey = @v_projectkey 
            AND plstagecode = @v_plstage 
            AND taqversionkey = @v_plversion 
            AND taqprojectformatkey = @v_formatkey 
            AND yearcode = 1

          SELECT @v_error = @@ERROR
          IF @v_error <> 0 BEGIN
            SET @o_error_desc = 'Update of taqversionformatyear table failed (quantity) (Error ' + cast(@v_error AS VARCHAR) + ').'
            GOTO RETURN_ERROR
          END
        END
        
        -- Loop through all components on this format/version that have quantities derived from FG qty and recalculate
        -- The first part of the union is for the derived from FG components directly on the processed version (ex. Printing project's derived components)
        -- The second part of the union is for the derived from FG components on the related version (ex. PO with both FG Bind comp and some derived components)
        DECLARE deriveqty_cur CURSOR FOR
         SELECT t.taqversionspecategorykey, COALESCE(t.spoilagepercentage,0)
           FROM taqversionspeccategory t
          WHERE t.taqprojectkey = @v_projectkey 
            AND t.plstagecode = @v_plstage 
            AND t.taqversionkey = @v_plversion 
            AND t.taqversionformatkey = @v_formatkey
            AND t.deriveqtyfromfgqty = 1
            AND COALESCE(t.relatedspeccategorykey,0) = 0
          UNION
         SELECT t.taqversionspecategorykey, COALESCE((select t2.spoilagepercentage from taqversionspeccategory t2 where t2.taqversionspecategorykey = t.relatedspeccategorykey),0)
           FROM taqversionspeccategory t
          WHERE t.taqprojectkey = @v_projectkey 
            AND t.plstagecode = @v_plstage 
            AND t.taqversionkey = @v_plversion 
            AND t.taqversionformatkey = @v_formatkey
            AND COALESCE(t.relatedspeccategorykey,0) > 0
            AND (select t2.deriveqtyfromfgqty from taqversionspeccategory t2 where t2.taqversionspecategorykey = t.relatedspeccategorykey) = 1
          
        OPEN deriveqty_cur 

        FETCH deriveqty_cur INTO @v_taqversionspecategorykey, @v_spoilagepercent

        WHILE (@@FETCH_STATUS=0)
        BEGIN
          SET @v_calcqty = @v_compqty + (@v_compqty * @v_spoilagepercent / 100)
          SET @v_newcompqty = ROUND(@v_calcqty, 0)          
          
          --PRINT '  --'
          --PRINT '  @v_taqversionspecategorykey=' + convert(varchar, @v_taqversionspecategorykey)
          --PRINT '  @v_spoilagepercent=' + convert(varchar, @v_spoilagepercent)
          --PRINT '  @v_newcompqty=' + convert(varchar, @v_newcompqty)

          UPDATE taqversionspeccategory
          SET quantity = @v_newcompqty, lastuserid = @i_userid, lastmaintdate = getdate()
          WHERE taqversionspecategorykey = @v_taqversionspecategorykey AND COALESCE(relatedspeccategorykey,0) = 0
                    
          FETCH deriveqty_cur INTO @v_taqversionspecategorykey, @v_spoilagepercent
        END

        CLOSE deriveqty_cur
        DEALLOCATE deriveqty_cur

        -- For Finished Good components, get the costs associated with the FG component and those costs not assigned to any component
        DECLARE compqtycosts_cur CURSOR FOR
          SELECT c.taqversionformatyearkey, c.acctgcode, c.taqversionspeccategorykey, c.plcalccostcode, c.versioncostsamount, c.compunitcost, @v_compqty
          FROM taqversioncosts c, taqversionformatyear y
          WHERE c.taqversionformatyearkey = y.taqversionformatyearkey
            AND y.taqprojectkey = @v_projectkey 
            AND y.plstagecode = @v_plstage 
            AND y.taqversionkey = @v_plversion 
            AND y.taqprojectformatkey = @v_formatkey 
            AND c.taqversionspeccategorykey in (@v_categorykey,0)

      END ---@v_finishedgoodind = 1
      ELSE
      BEGIN 
              
        SELECT @v_count = count(*)
          FROM taqversionspeccategory
         WHERE taqprojectkey = @v_projectkey 
           AND plstagecode = @v_plstage 
           AND taqversionkey = @v_plversion 
           AND taqversionformatkey = @v_formatkey 
           AND finishedgoodind = 1
                      
        IF @v_count > 0 BEGIN
          -- there is a finished good component so we only need to worry about costs for this component 
          SELECT @v_first_categorykey = -1
        END
        ELSE BEGIN
          -- No finished good component exists on this format/version - get the taqversionspeccategorykey and quantity of the first component
          SELECT TOP 1 @v_first_categorykey = COALESCE(taqversionspecategorykey,0), @v_first_categorykey_qty = COALESCE(quantity,0),
                       @v_first_relatedspeccategorykey = relatedspeccategorykey
            FROM taqversionspeccategory
           WHERE taqprojectkey = @v_projectkey 
             AND plstagecode = @v_plstage 
             AND taqversionkey = @v_plversion 
             AND taqversionformatkey = @v_formatkey 
          ORDER BY coalesce(sortorder, 9999), speccategorydescription
        END
                   
        --PRINT ' @v_categorykey=' + convert(varchar, @v_categorykey)
        --PRINT ' @v_first_categorykey=' + convert(varchar, @v_first_categorykey)
        
        IF @v_categorykey = @v_first_categorykey BEGIN
          -- this is the first non finished good component and no finished good component exists
          IF @v_first_relatedspeccategorykey > 0 BEGIN
            SELECT @v_first_categorykey_qty = COALESCE(quantity,0)
              FROM taqversionspeccategory
             WHERE taqversionspecategorykey = @v_first_relatedspeccategorykey
          END
          
          --PRINT ' @v_first_relatedspeccategorykey=' + convert(varchar, @v_first_relatedspeccategorykey)

          -- When generating from FG Component Quantity, and there is no FG component,
          -- update Production Quantity on taqversionformatyear to the first component quantity
          IF @v_prodqtyentrytypecode = 4 AND @v_first_categorykey_qty > 0  --Generate from FG Component Quantity
          BEGIN 
            UPDATE taqversionformatyear
            SET quantity = @v_first_categorykey_qty, printingnumber = @v_printingnumber, lastuserid = @i_userid, lastmaintdate = getdate()
            WHERE taqprojectkey = @v_projectkey 
              AND plstagecode = @v_plstage 
              AND taqversionkey = @v_plversion 
              AND taqprojectformatkey = @v_formatkey 
              AND yearcode = 1

            SELECT @v_error = @@ERROR
            IF @v_error <> 0 BEGIN
              SET @o_error_desc = 'Update of taqversionformatyear table failed (quantity) (Error ' + cast(@v_error AS VARCHAR) + ').'
              GOTO RETURN_ERROR
            END
          END

          -- For non-Finished Good first component, get the costs associated with that component and ones not assigned to any component
          DECLARE compqtycosts_cur CURSOR FOR
           SELECT c.taqversionformatyearkey, c.acctgcode, c.taqversionspeccategorykey, c.plcalccostcode, c.versioncostsamount, c.compunitcost, @v_compqty
             FROM taqversioncosts c, taqversionformatyear y
            WHERE c.taqversionformatyearkey = y.taqversionformatyearkey
              AND taqprojectkey = @v_projectkey 
              AND plstagecode = @v_plstage 
              AND taqversionkey = @v_plversion 
              AND taqprojectformatkey = @v_formatkey 
              AND taqversionspeccategorykey = @v_categorykey    
            UNION        
           SELECT c.taqversionformatyearkey, c.acctgcode, @v_first_categorykey, c.plcalccostcode, c.versioncostsamount, c.compunitcost, @v_first_categorykey_qty
             FROM taqversioncosts c, taqversionformatyear y
            WHERE c.taqversionformatyearkey = y.taqversionformatyearkey
              AND taqprojectkey = @v_projectkey 
              AND plstagecode = @v_plstage 
              AND taqversionkey = @v_plversion 
              AND taqprojectformatkey = @v_formatkey 
              AND taqversionspeccategorykey = 0         
        END
        ELSE BEGIN
          -- For non-Finished Good other components (not first), get only the costs associated with that component                  
          DECLARE compqtycosts_cur CURSOR FOR
           SELECT c.taqversionformatyearkey, c.acctgcode, c.taqversionspeccategorykey, c.plcalccostcode, c.versioncostsamount, c.compunitcost, @v_compqty
             FROM taqversioncosts c, taqversionformatyear y
            WHERE c.taqversionformatyearkey = y.taqversionformatyearkey
              AND taqprojectkey = @v_projectkey 
              AND plstagecode = @v_plstage 
              AND taqversionkey = @v_plversion 
              AND taqprojectformatkey = @v_formatkey 
              AND taqversionspeccategorykey = @v_categorykey    
        END   
      END
     
      --PRINT '  --- BEGIN costs cursor ---'

      -- For both finished good and non-finished good components, recalculate costs for the new quantity
      OPEN compqtycosts_cur 

      FETCH compqtycosts_cur
      INTO @v_formatyearkey, @v_acctgcode, @v_speccategorykey, @v_plcalccostcode, @v_totalcost, @v_compunitcost, @v_qty

      WHILE (@@FETCH_STATUS=0)
      BEGIN

        IF @v_qty IS NULL OR @v_qty = 0
          SET @v_qty = 1

        --PRINT '  --'
        --PRINT '  @v_formatyearkey=' + convert(varchar, @v_formatyearkey)
        --PRINT '  @v_acctgcode=' + convert(varchar, @v_acctgcode)
        --PRINT '  @v_speccategorykey=' + convert(varchar, @v_speccategorykey)
        --PRINT '  @v_plcalccostcode=' + convert(varchar, @v_plcalccostcode)
        --PRINT '  @v_totalcost=' + convert(varchar, @v_totalcost)
        --PRINT '  @v_compunitcost=' + convert(varchar, @v_compunitcost)
        --PRINT '  @v_qty=' + convert(varchar, @v_qty)
    	    	
        IF @v_plcalccostcode = 1  --calculate Unit cost
        BEGIN
          SET @v_newtotalcost = @v_totalcost
          IF @v_qty > 0 BEGIN
            SET @v_newunitcost = @v_totalcost / @v_qty
          END
        END
        ELSE --calculate Total cost
        BEGIN
          SET @v_newtotalcost = @v_compunitcost * @v_qty
          SET @v_newunitcost = @v_compunitcost
        END

        --PRINT '  @v_newtotalcost=' + convert(varchar, @v_newtotalcost)
        --PRINT '  @v_newunitcost=' + convert(varchar, @v_newunitcost)

        UPDATE taqversioncosts
        SET versioncostsamount = @v_newtotalcost, compunitcost = @v_newunitcost, printingnumber = @v_printingnumber,
          lastuserid = @i_userid, lastmaintdate = getdate()
        WHERE taqversionformatyearkey = @v_formatyearkey 
          AND acctgcode = @v_acctgcode
          AND taqversionspeccategorykey = @v_speccategorykey

        FETCH compqtycosts_cur
        INTO @v_formatyearkey, @v_acctgcode, @v_speccategorykey, @v_plcalccostcode, @v_totalcost, @v_compunitcost, @v_qty
      END

      CLOSE compqtycosts_cur
      DEALLOCATE compqtycosts_cur
      
      --PRINT '  --- END costs cursor ---'
    END --IF @v_lockedind=0
         
    FETCH updateprodqty_cur
    INTO @v_categorykey, @v_projectkey, @v_formatkey, @v_plstage, @v_plversion, @v_categorycode, @v_relatedcategorykey
  END

  CLOSE updateprodqty_cur
  DEALLOCATE updateprodqty_cur
  
  RETURN 

  RETURN_ERROR:      
    SET @o_error_code = -1
    RETURN
      
END
GO

GRANT EXEC ON qpl_update_component_qty TO PUBLIC
GO
