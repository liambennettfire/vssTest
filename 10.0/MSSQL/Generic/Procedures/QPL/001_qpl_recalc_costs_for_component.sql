IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'dbo.qpl_recalc_costs_for_component') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qpl_recalc_costs_for_component
GO

CREATE PROCEDURE [dbo].[qpl_recalc_costs_for_component] (
  @i_categorykey  INT,
  @i_compqty      INT,
  @i_userid       VARCHAR(30),  
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/**************************************************************************************************************************
**  Name: qpl_recalc_costs_for_component
**  Desc: This stored procedure processes component quantity change.
**
**  Auth: Joshua G
**  Date: February 14 2017
****************************************************************************************************************************
**  Change History
****************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**  05/12/17    Colman    Case 44464
****************************************************************************************************************************/

BEGIN 

DECLARE
    @v_projectkey   INT,
    @v_plstage      INT,
    @v_plversion    INT,
    @v_formatkey    INT,
    @v_itemtype     INT,
    @v_usageclass   INT,
    @v_printingnumber INT,
    @v_printingnumber_orig INT,
    @v_relatedcategorykey INT,
    @v_finishedgoodind INT,
    @v_count INT,
    @v_first_categorykey INT,
    @v_first_relatedspeccategorykey INT,
    @v_prodqtyentrytypecode INT,
    @v_formatyearkey INT,
    @v_acctgcode INT,
    @v_speccategorykey INT,
    @v_plcalccostcode INT, 
    @v_totalcost FLOAT, 
    @v_compunitcost FLOAT, 
    @v_qty INT,
    @v_newtotalcost FLOAT,
    @v_newunitcost FLOAT,
    @v_first_categorykey_qty INT,
    @v_error INT,
    @v_project_is_taq_or_work INT
    
SET @v_project_is_taq_or_work = 0

SELECT  @v_projectkey = taqprojectkey,  @v_plstage = plstagecode, @v_plversion = taqversionkey, @v_formatkey= taqversionformatkey, @v_relatedcategorykey = relatedspeccategorykey, @v_finishedgoodind = finishedgoodind
     FROM taqversionspeccategory 
     WHERE taqversionspecategorykey = @i_categorykey

SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
FROM taqproject
WHERE taqprojectkey = @v_projectkey

IF EXISTS (SELECT 1 FROM subgentables WHERE tableid = 550 AND datacode = @v_itemtype AND datasubcode = @v_usageclass AND qsicode IN (1, 28, 53))
  SET @v_project_is_taq_or_work = 1
  
IF @v_relatedcategorykey > 0
  SELECT @v_finishedgoodind = finishedgoodind
  FROM taqversionspeccategory
  WHERE taqversionspecategorykey = @v_relatedcategorykey

  IF @v_itemtype = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 14)  --Printing project
    SELECT @v_printingnumber = printingnum
    FROM taqprojectprinting_view
    WHERE taqprojectkey = @v_projectkey
  ELSE
    SET @v_printingnumber = 1

IF @v_finishedgoodind = 1
BEGIN
    DECLARE compqtycosts_cur CURSOR FOR
    SELECT 
        c.taqversionformatyearkey, 
        c.printingnumber,
        c.acctgcode, 
        c.taqversionspeccategorykey, 
        c.plcalccostcode, 
        c.versioncostsamount, 
        c.compunitcost, 
        @i_compqty
    FROM 
        taqversioncosts c
    INNER JOIN taqversionformatyear y
        ON c.taqversionformatyearkey = y.taqversionformatyearkey
    WHERE 
        y.taqprojectkey = @v_projectkey 
    AND y.plstagecode =@v_plstage 
    AND y.taqversionkey = @v_plversion 
    AND y.taqprojectformatkey =@v_formatkey 
    AND c.taqversionspeccategorykey IN (@i_categorykey,0)
END
ELSE
BEGIN
    SELECT 
        @v_count = count(1)
    FROM 
        taqversionspeccategory
    WHERE 
        taqprojectkey = @v_projectkey 
    AND plstagecode =@v_plstage 
    AND taqversionkey = @v_plversion 
    AND taqversionformatkey =@v_formatkey 
    AND finishedgoodind = 1
    
    IF @v_count > 0 BEGIN
    -- there is a finished good component so we only need to worry about costs for this component 
        SELECT @v_first_categorykey = -1
    END    
    ELSE 
    BEGIN
        -- No finished good component exists on this format/version - get the taqversionspeccategorykey and quantity of the first component
        SELECT TOP 1 
            @v_first_categorykey = COALESCE(taqversionspecategorykey,0), 
            @v_first_categorykey_qty = COALESCE(quantity,0),
            @v_first_relatedspeccategorykey = relatedspeccategorykey
        FROM 
            taqversionspeccategory
        WHERE 
            taqprojectkey = @v_projectkey 
        AND plstagecode =@v_plstage 
        AND taqversionkey = @v_plversion 
        AND taqversionformatkey =@v_formatkey 
        ORDER BY coalesce(sortorder, 9999), speccategorydescription
    END
                   
    PRINT ' @v_categorykey=' + convert(varchar, @i_categorykey)
    PRINT ' @v_first_categorykey=' + convert(varchar, @v_first_categorykey)

    IF @i_categorykey = @v_first_categorykey BEGIN
          -- this is the first non finished good component and no finished good component exists
          IF @v_first_relatedspeccategorykey > 0 BEGIN
            SELECT @v_first_categorykey_qty = COALESCE(quantity,0)
              FROM taqversionspeccategory
             WHERE taqversionspecategorykey = @v_first_relatedspeccategorykey
          END
          
          PRINT ' @v_first_relatedspeccategorykey=' + convert(varchar, @v_first_relatedspeccategorykey)

          -- When generating from FG Component Quantity, and there is no FG component,
          -- update Production Quantity on taqversionformatyear to the first component quantity
          IF @v_prodqtyentrytypecode = 4 AND @v_first_categorykey_qty > 0  --Generate from FG Component Quantity
          BEGIN 
            PRINT 'Updating Qty from non FG Comp Qty, no FG exists'
            
            UPDATE taqversionformatyear
            SET quantity = @v_first_categorykey_qty, printingnumber = @v_printingnumber, lastuserid = @i_userid, lastmaintdate = getdate()
            WHERE taqprojectkey = @v_projectkey 
              AND plstagecode =@v_plstage 
              AND taqversionkey = @v_plversion 
              AND taqprojectformatkey =@v_formatkey 
              AND yearcode = 1

            SELECT @v_error = @@ERROR
            IF @v_error <> 0 BEGIN
              SET @o_error_desc = 'Update of taqversionformatyear table failed (quantity) (Error ' + cast(@v_error AS VARCHAR) + ').'
              GOTO RETURN_ERROR
            END
          END

          -- For non-Finished Good first component, get the costs associated with that component and ones not assigned to any component
          DECLARE compqtycosts_cur CURSOR FOR
           SELECT c.taqversionformatyearkey, c.printingnumber, c.acctgcode, c.taqversionspeccategorykey, c.plcalccostcode, c.versioncostsamount, c.compunitcost, @i_compqty
             FROM taqversioncosts c, taqversionformatyear y
            WHERE c.taqversionformatyearkey = y.taqversionformatyearkey
              AND taqprojectkey = @v_projectkey 
              AND plstagecode =@v_plstage 
              AND taqversionkey = @v_plversion 
              AND taqprojectformatkey =@v_formatkey 
              AND taqversionspeccategorykey = @i_categorykey    
            UNION        
           SELECT c.taqversionformatyearkey, c.printingnumber, c.acctgcode, @v_first_categorykey, c.plcalccostcode, c.versioncostsamount, c.compunitcost, @v_first_categorykey_qty
             FROM taqversioncosts c, taqversionformatyear y
            WHERE c.taqversionformatyearkey = y.taqversionformatyearkey
              AND taqprojectkey = @v_projectkey 
              AND plstagecode =@v_plstage 
              AND taqversionkey = @v_plversion 
              AND taqprojectformatkey =@v_formatkey 
              AND taqversionspeccategorykey = 0         
        END
        ELSE BEGIN
          -- For non-Finished Good other components (not first), get only the costs associated with that component                  
          DECLARE compqtycosts_cur CURSOR FOR
           SELECT c.taqversionformatyearkey, c.printingnumber, c.acctgcode, c.taqversionspeccategorykey, c.plcalccostcode, c.versioncostsamount, c.compunitcost, @i_compqty
             FROM taqversioncosts c, taqversionformatyear y
            WHERE c.taqversionformatyearkey = y.taqversionformatyearkey
              AND taqprojectkey = @v_projectkey 
              AND plstagecode =@v_plstage 
              AND taqversionkey = @v_plversion 
              AND taqprojectformatkey =@v_formatkey 
              AND taqversionspeccategorykey = @i_categorykey    
        END   
      END
     
      --PRINT '  --- BEGIN costs cursor ---'

      -- For both finished good and non-finished good components, recalculate costs for the new quantity
      OPEN compqtycosts_cur 

      FETCH compqtycosts_cur
      INTO @v_formatyearkey, @v_printingnumber_orig, @v_acctgcode, @v_speccategorykey, @v_plcalccostcode, @v_totalcost, @v_compunitcost, @v_qty

      WHILE (@@FETCH_STATUS=0)
      BEGIN

        IF @v_qty IS NULL OR @v_qty = 0
          SET @v_qty = 1

        PRINT '  -- recalc costs--'
        PRINT '  @v_formatyearkey=' + convert(varchar, @v_formatyearkey)
        PRINT '  @v_acctgcode=' + convert(varchar, @v_acctgcode)
        PRINT '  @v_speccategorykey=' + convert(varchar, @v_speccategorykey)
        PRINT '  @v_plcalccostcode=' + convert(varchar, @v_plcalccostcode)
        PRINT '  @v_totalcost=' + convert(varchar, @v_totalcost)
        PRINT '  @v_compunitcost=' + convert(varchar, @v_compunitcost)
        PRINT '  @v_qty=' + convert(varchar, @v_qty)
        
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
        IF @v_project_is_taq_or_work = 1
          SET @v_printingnumber = @v_printingnumber_orig
          
        UPDATE taqversioncosts
        SET versioncostsamount = @v_newtotalcost, compunitcost = @v_newunitcost, printingnumber = @v_printingnumber,
          lastuserid = @i_userid, lastmaintdate = getdate()
        WHERE taqversionformatyearkey = @v_formatyearkey 
          AND acctgcode = @v_acctgcode
          AND taqversionspeccategorykey = @v_speccategorykey

        FETCH compqtycosts_cur
        INTO @v_formatyearkey, @v_printingnumber_orig, @v_acctgcode, @v_speccategorykey, @v_plcalccostcode, @v_totalcost, @v_compunitcost, @v_qty
      END

      CLOSE compqtycosts_cur
      DEALLOCATE compqtycosts_cur
      
      PRINT '  --- END costs cursor ---'
    RETURN     
    RETURN_ERROR:      
        SET @o_error_code = -1
        RETURN    
END 
  
GRANT EXEC ON qpl_recalc_costs_for_component TO PUBLIC

GO


