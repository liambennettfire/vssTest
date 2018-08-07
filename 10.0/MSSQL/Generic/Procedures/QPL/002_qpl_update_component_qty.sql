if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_update_component_qty') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_update_component_qty
GO

CREATE PROCEDURE [dbo].[qpl_update_component_qty] (
  @i_categorykey  INT,
  @i_projectkey   INT,
  @i_plstage      INT,
  @i_plversion    INT,
  @i_formatkey    INT,
  @i_userid       VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT,
  @i_debug_ind    INT = 0)  --optional parameter to turn on debug indicator
AS

/**************************************************************************************************************************
**  Name: qpl_update_component_qty
**  Desc: This stored procedure processes component quantity change.
**
**  Auth: Kate
**  Date: October 7 2014
****************************************************************************************************************************
**  Change History
**********************************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**  03/03/16    Kate      Update Production Qty only when > 0 i.e. keep default 1 value rather than NULL or 0 (see Case 36595)
**  05/13/16    Kate      Case 37437 - Issues with Quantity column on taqversionformatyear table 
**  03/31/17    Susan     Case 42963 - Allow Dervied Quantities on Shared Sections and from Shared Section, Moved code from here to 
**                        new procedure to recalc costs so it could be called everytime a quantity was udpated:  
**                        qpl_recalc_costs_for_component
**  05/17/17    Susan     Case 44340 - Co-edition rights prod qty updates, removing unnecessary loops, updating component qty from section qty.
**                        Also added an optional parameter that determines whether to show Print statements.  Set to 0 as default
**  06/16/17    Colman    Case 45927 - Handle case where a FG component qty is updated on a printing and that printing belongs to a shared section.
**********************************************************************************************************************************************/

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
  @v_totalcost  FLOAT,
  @v_sharedposectionind INT,
  @v_fg_sharedposectionind INT,
  @v_derived_sharedposectionind INT,
  @v_derived_taqversionformatkey INT,
  @v_derived_versionformatrelatedkey INT,
  @v_derived_projectkey INT,
  @v_derived_relatedprojectkey INT,
  @v_taqversionformatrelatedkey INT,
  @v_taqversionformatkey INT,
  @v_derived_compqty INT,
  @v_total_quantity INT,
  @v_relationshipCode1 INT,
  @v_relationshipCode2 INT,
  @v_isPrinting INT,
  @v_itemTypePrinting INT,
  @v_derivedfromfgind INT,
  @v_fgorigformat INT
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SET @v_relationshipCode1 = (SELECT g.datacode FROM gentables g WHERE g.tableid = 582 AND g.qsicode = 26)
  SET @v_relationshipCode2 = (SELECT g.datacode FROM gentables g WHERE g.tableid = 582 AND g.qsicode = 25)
  SET @v_itemTypePrinting = (SELECT g.dataCode FROM gentables g WHERE g.tableID = 550 AND g.qsicode = 14)

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

  IF @i_debug_ind = 1  BEGIN
    PRINT '  ' 
    PRINT '** TOP **'
    PRINT '@i_categorykey=' + convert(varchar, @i_categorykey)
    PRINT '@i_projectkey=' + convert(varchar, @i_projectkey)
    PRINT '@i_plstage=' + convert(varchar, @i_plstage)
    PRINT '@i_plversion=' + convert(varchar, @i_plversion)
    PRINT '@i_formatkey=' + convert(varchar, @i_formatkey)
  END


-- Handle case of a finished good on a printing when that printing belongs to a shared section
  -- SET @v_taqversionformatrelatedkey = 0

  -- SELECT @v_taqversionformatrelatedkey = ISNULL(taqversionformatrelatedkey, 0), 
         -- @v_projectkey = r.taqprojectkey, 
         -- @v_taqversionformatkey = r.taqversionformatkey, 
         -- @v_compqty = c.quantity
  -- FROM taqversionspeccategory c
    -- JOIN taqversionformatrelatedproject r ON r.relatedversionformatkey = c.taqversionformatkey
    -- JOIN taqversionformat f ON f.taqprojectformatkey = r.taqversionformatkey
  -- WHERE c.taqprojectkey = @i_projectkey 
    -- AND c.plstagecode = @i_plstage 
    -- AND c.taqversionkey = @i_plversion 
    -- AND c.taqversionformatkey = @i_formatkey
    -- AND c.finishedgoodind = 1
    -- AND f.sharedposectionind = 1

  -- IF @v_taqversionformatrelatedkey > 0
  -- BEGIN
    -- IF @i_debug_ind = 1  BEGIN
      -- PRINT '  ' 
      -- PRINT '@v_taqversionformatrelatedkey=' + convert(varchar, @v_taqversionformatrelatedkey)
      -- PRINT '@v_projectkey=' + convert(varchar, @v_projectkey)
      -- PRINT '@v_taqversionformatkey=' + convert(varchar, @v_taqversionformatkey)
      -- PRINT '@v_compqty=' + convert(varchar, @v_compqty)
    -- END

    -- UPDATE taqversionformatrelatedproject
    -- SET quantity = @v_compqty
    -- WHERE taqversionformatrelatedkey = @v_taqversionformatrelatedkey

    -- EXEC qpl_update_component_qty 0, @v_projectkey, 0, 1, @v_taqversionformatkey, 
      -- @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT, @i_debug_ind

      -- IF @o_error_code = -1
        -- GOTO RETURN_ERROR
  -- END
  
  IF @i_categorykey IS NULL OR @i_categorykey = 0
  BEGIN
    DECLARE components_cur CURSOR LOCAL FOR
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
        @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT, @i_debug_ind

      IF @o_error_code = -1
      BEGIN
        CLOSE components_cur
        DEALLOCATE components_cur
        GOTO RETURN_ERROR
      END

      FETCH components_cur INTO @v_categorykey
    END

    CLOSE components_cur
    DEALLOCATE components_cur
  END
  ELSE IF @i_categorykey > 0 
  BEGIN
    -- check to see if this has a related component
    SELECT @v_relatedcategorykey = relatedspeccategorykey
    FROM taqversionspeccategory
    WHERE taqversionspecategorykey = @i_categorykey

    IF @i_debug_ind = 1  BEGIN
        PRINT '@v_relatedcategorykey=' + convert(varchar, @v_relatedcategorykey) 
    END 
  END
  
  IF COALESCE(@i_categorykey,0) = 0 BEGIN
    RETURN
  END

  -- Select the category passed and the related category if one exists  
  DECLARE updateprodqty_cur CURSOR FOR
    SELECT c.taqversionspecategorykey, c.taqprojectkey, c.taqversionformatkey, c.plstagecode, c.taqversionkey, c.itemcategorycode, c.relatedspeccategorykey, ISNULL(c.spoilagepercentage,0), f.sharedposectionind
    FROM taqversionspeccategory c, taqversionformat f
    WHERE taqversionspecategorykey = @i_categorykey
      AND f.taqprojectformatkey = c.taqversionformatkey
  UNION
    SELECT c.taqversionspecategorykey, c.taqprojectkey, c.taqversionformatkey, c.plstagecode, c.taqversionkey, c.itemcategorycode, c.relatedspeccategorykey, ISNULL(c.spoilagepercentage,0), f.sharedposectionind
    FROM taqversionspeccategory c, taqversionformat f
    WHERE relatedspeccategorykey = @i_categorykey
      AND f.taqprojectformatkey = c.taqversionformatkey
   
  OPEN updateprodqty_cur 

  FETCH updateprodqty_cur
  INTO @v_categorykey, @v_projectkey, @v_formatkey, @v_plstage, @v_plversion, @v_categorycode, @v_relatedcategorykey, @v_spoilagepercent, @v_sharedposectionind

  WHILE (@@FETCH_STATUS = 0)
  BEGIN  --PROCESSING COMPONENTS
    IF @i_debug_ind = 1  BEGIN
      PRINT ' -- Looping through '
      PRINT ' @v_categorykey=' + convert(varchar, @v_categorykey) 
      PRINT ' @v_projectkey=' + convert(varchar, @v_projectkey)
      PRINT ' @v_formatkey=' + convert(varchar, @v_formatkey)    
      PRINT ' @v_plstage=' + convert(varchar, @v_plstage)
      PRINT ' @v_plversion=' + convert(varchar, @v_plversion)
      PRINT ' @v_categorycode=' + convert(varchar, @v_categorycode)
      PRINT ' @v_relatedcategorykey=' + ISNULL(convert(varchar, @v_relatedcategorykey),'NULL')
    END

    SELECT @v_itemtype = searchitemcode
    FROM taqproject
    WHERE taqprojectkey = @v_projectkey

    IF @v_itemtype = @v_itemTypePrinting --Printing project
    BEGIN
      SELECT @v_printingnumber = printingnum
      FROM taqprojectprinting_view
      WHERE taqprojectkey = @v_projectkey
      SET @v_isPrinting = 1
    END

    ELSE
    BEGIN
      SET @v_printingnumber = 1
      SET @v_isPrinting = 0
    END
    
    IF @i_debug_ind = 1  BEGIN
      PRINT '  ' 
      PRINT ' Getting Prtg #'
      PRINT ' @v_printingnumber=' + CONVERT(VARCHAR, @v_printingnumber)  
    END

    -- Because we are updating quantities throughout the run, we need to retrieve component quantity real-time
    IF @v_relatedcategorykey > 0
    BEGIN
      -- Determine if the FG Qty is on a shared component (If so, you must get qty from taqversonrelatedproject) 
      SELECT @v_fg_sharedposectionind = ISNULL(tvf.sharedposectionind,0) 
      FROM taqversionformat tvf, taqversionspeccategory tc
      WHERE tvf.taqprojectformatkey =  tc.taqversionformatkey
          AND taqversionspecategorykey = @v_relatedcategorykey
      IF @v_fg_sharedposectionind = 1 
      BEGIN
        SELECT @v_finishedgoodind = finishedgoodind, @v_derivedfromfgind = deriveqtyfromfgqty, @v_fgorigformat = taqversionformatkey
        FROM taqversionspeccategory
        WHERE taqversionspecategorykey = @v_relatedcategorykey

        SELECT @v_compqty = quantity 
        FROM taqversionformatrelatedproject trp 
        WHERE trp.taqversionformatkey =  @v_fgorigformat
            AND trp.relatedprojectkey = @v_projectkey
      END
      ELSE BEGIN
        SELECT @v_finishedgoodind = finishedgoodind, @v_compqty = quantity, @v_derivedfromfgind = deriveqtyfromfgqty, @v_fgorigformat = taqversionformatkey
        FROM taqversionspeccategory
        WHERE taqversionspecategorykey = @v_relatedcategorykey
      END
    END
    ELSE
    BEGIN
      SELECT @v_finishedgoodind = finishedgoodind, @v_compqty = quantity, @v_derivedfromfgind = deriveqtyfromfgqty, @v_fgorigformat = taqversionformatkey
      FROM taqversionspeccategory
      WHERE taqversionspecategorykey = @v_categorykey

      SELECT @v_fg_sharedposectionind = ISNULL(tvf.sharedposectionind,0) 
      FROM taqversionformat tvf 
      WHERE tvf.taqprojectformatkey = @v_formatkey
    END

    IF @i_debug_ind = 1  BEGIN
      PRINT ' @v_finishedgoodind=' + convert(varchar, @v_finishedgoodind)
      PRINT ' @v_compqty=' + ISNULL(convert(varchar, @v_compqty),'NULL')
      PRINT ' @v_fg_sharedposectionind=' + ISNULL(convert(varchar, @v_fg_sharedposectionind),'NULL')
    END

    -- make sure project is not locked
    SELECT @v_lockedind = COALESCE(g.gen2ind,0)
    FROM taqproject tp, gentables g
    WHERE tp.taqprojectkey = @v_projectkey
      AND g.tableid = 522
      AND tp.taqprojectstatuscode = g.datacode
  
    IF @i_debug_ind = 1  BEGIN
      PRINT ' @v_lockedind=' + convert(varchar, @v_lockedind)
    END 

    IF @v_lockedind = 0 
    BEGIN
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
    
      IF @i_debug_ind = 1  BEGIN      
        PRINT ' @v_prodqtyentrytypecode=' + convert(varchar, @v_prodqtyentrytypecode)
      END

      IF @v_finishedgoodind = 1
      BEGIN
        IF @i_debug_ind = 1  BEGIN
          PRINT 'Updating Prod qty from FG'
        END
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
        
        UPDATE taqprojectrights
        SET productionqty = @v_compqty
        WHERE taqprojectprintingkey = @v_projectkey
        AND taqprojectprintingkey IS NOT NULL

        IF @i_debug_ind = 1  BEGIN
          PRINT 'taqprojectprintingkey (update contract prod qty) =' +  ISNULL(convert(varchar, @v_projectkey),'NULL')
          PRINT ' IN DERIVED'
          PRINT ' @v_relatedcategorykey=' + ISNULL(convert(varchar, @v_relatedcategorykey),'NULL')
        END
    
        --UPDATE ALL DERIVED COMPONENT QUANTITIES
        -- Loop through all components on this format/version that have quantities derived from FG qty, compute new quantities and recalculate costs
        -- The first part of the union is for derived components that do not have related components that are on the same same project/version 
        -- The second part of the union is for derived components that have related components that are on the same project/version/format
        -- The third part of the union is for derived components on other "formats" (PO sections) with same related projects that are on the same project/version
        -- The fourth part of the union is for derived related components for FG original projects on other projects (so a component that exists on another PO) 
        -- UPDATE March 2017 case 42963  -Allow Derived Quantities on Shared Sections and from Shared Section

        DECLARE deriveqty_cur CURSOR FOR
        SELECT t.taqversionspecategorykey, ISNULL(t.spoilagepercentage,0),t.taqprojectkey, t.taqversionformatkey --Get all derived components that do not have related components that are on the same same project/version 
        FROM taqversionspeccategory t
        WHERE t.taqversionformatkey = @v_formatkey
          AND t.deriveqtyfromfgqty = 1
          AND ISNULL(t.relatedspeccategorykey,0) = 0

        UNION --Get all derived components that have related components that are on the same project/version/format
          SELECT t.taqversionspecategorykey, ISNULL(t2.spoilagepercentage,0), t.taqprojectkey, t.taqversionformatkey
          FROM taqversionspeccategory t
          INNER JOIN taqversionspeccategory t2
          ON t.relatedspeccategorykey = t2.taqversionspecategorykey
            AND t2.deriveqtyfromfgqty = 1
          WHERE t.taqversionformatkey = @v_formatkey
          AND ISNULL(t.relatedspeccategorykey,0) > 0

        UNION -- Get all derived components on other "formats" (PO sections) with same related projects that are on the same project/version
          SELECT t.taqversionspecategorykey, ISNULL(t.spoilagepercentage,0),t.taqprojectkey,t.taqversionformatkey
          FROM taqversionspeccategory t
          LEFT OUTER JOIN taqversionformat tvf ON tvf.taqprojectformatkey = t.taqversionformatkey
          LEFT OUTER JOIN  taqversionformatrelatedproject trp on trp.taqversionformatkey = tvf.taqprojectformatkey
          WHERE t.deriveqtyfromfgqty = 1
          AND EXISTS(SELECT 1 FROM taqversionformatrelatedproject trp2 
                WHERE taqversionformatkey = @v_formatkey
                AND trp2.relatedprojectkey = trp.relatedprojectkey)

        UNION --Get any derived related components for FG original projects on other projects 
          SELECT t.taqversionspecategorykey, ISNULL(t.spoilagepercentage,0), t.taqprojectkey, t.taqversionformatkey
          FROM taqversionspeccategory t 
          WHERE t.deriveqtyfromfgqty = 1
          AND EXISTS(SELECT 1 FROM taqversionformatrelatedproject trp2 
                WHERE trp2.taqversionformatkey = @v_formatkey
                AND trp2.relatedprojectkey = t.taqprojectkey)

        OPEN deriveqty_cur 

        FETCH deriveqty_cur INTO @v_taqversionspecategorykey, @v_spoilagepercent, @v_derived_projectkey, @v_derived_taqversionformatkey

        WHILE (@@FETCH_STATUS=0)
        BEGIN  --UPDATE DERIVED QT LOOP 
          ----If the FG Qty is on a shared component, you must process each related project separately 
          SELECT @v_derived_sharedposectionind = ISNULL(tvf.sharedposectionind,0) 
          FROM taqversionformat tvf 
          WHERE tvf.taqprojectformatkey =  @v_derived_taqversionformatkey
    
            IF @i_debug_ind = 1  BEGIN
            PRINT 'FG Shared section = ' + convert(varchar, @v_fg_sharedposectionind)
            PRINT 'Derived Shared section = ' + convert(varchar, @v_derived_sharedposectionind)
            PRINT ' @v_taqversionspecategorykey=' + convert(varchar, @v_taqversionspecategorykey)
            PRINT ' @v_derived_projectkey=' + coalesce(convert(varchar, @v_derived_projectkey),'NULL')
            PRINT ' @v_derived_taqversionformatkey =' + coalesce(convert(varchar, @v_derived_taqversionformatkey),'NULL')
              END

          IF @v_derived_sharedposectionind = 1 AND @v_fg_sharedposectionind = 1       --** FG AND DERIVED ARE BOTH SHARED SECTIONS
          BEGIN 
            --Need to update every related project that is on both sections 
            IF @i_debug_ind = 1  BEGIN
              PRINT 'in shared section loop'
            END
            DECLARE sharedsection_cur CURSOR FOR
            SELECT t.taqversionformatrelatedkey, t.relatedprojectkey 
            FROM taqversionformatrelatedproject t
            WHERE t.taqversionformatkey = @v_derived_taqversionformatkey
            AND EXISTS(SELECT 1 FROM taqversionformatrelatedproject t2 
                WHERE t2.taqversionformatkey = @v_formatkey
                AND t2.relatedprojectkey = t.relatedprojectkey)

            OPEN sharedsection_cur 
            FETCH sharedsection_cur INTO @v_derived_versionformatrelatedkey, @v_derived_relatedprojectkey
      
            WHILE (@@FETCH_STATUS=0)
            BEGIN
              --  Get the FG qty for that related project
              SELECT @v_derived_compqty = t.quantity FROM taqversionformatrelatedproject t 
              WHERE t.relatedprojectkey = @v_derived_relatedprojectkey AND t.taqversionformatkey = @v_formatkey
        
              SET @v_calcqty = @v_derived_compqty + (@v_derived_compqty * @v_spoilagepercent / 100)
              SET @v_newcompqty = ROUND(@v_calcqty, 0) 
         
              IF @i_debug_ind = 1  BEGIN
                PRINT '  -- Calc Spoilage for Derived From FG Qty within shared loop-- '
                PRINT '  @v_taqversionspecategorykey=' + convert(varchar, @v_taqversionspecategorykey)
                PRINT '  @v_spoilagepercent=' + convert(varchar, @v_spoilagepercent)
                PRINT '  @v_newcompqty=' + convert(varchar, @v_newcompqty)
              END

              UPDATE taqversionformatrelatedproject 
                SET quantity = @v_newcompqty, lastuserid = @i_userid, lastmaintdate = getdate()
              WHERE taqversionformatrelatedkey =@v_derived_versionformatrelatedkey 

              UPDATE taqversionspeccategory
              SET quantity = @v_newcompqty, lastuserid = @i_userid, lastmaintdate = getdate()
                WHERE taqprojectkey = @v_derived_relatedprojectkey AND relatedspeccategorykey = @v_taqversionspecategorykey
      
              FETCH sharedsection_cur INTO @v_derived_versionformatrelatedkey, @v_derived_relatedprojectkey
            END
      
            SELECT @v_total_quantity = ISNULL(SUM (t.quantity),0) FROM taqversionformatrelatedproject t
            WHERE t.taqversionformatkey = @v_derived_taqversionformatkey

            -- Update component qty for shared section based on total of all related projects
            IF @i_debug_ind = 1  BEGIN
              PRINT '   @v_total_quantity=' + convert(varchar, @v_total_quantity)
            END
      
            UPDATE taqversionspeccategory
            SET quantity = @v_total_quantity
            WHERE taqversionspecategorykey = @v_taqversionspecategorykey
            --Update Costs for shared section component
            EXEC dbo.qpl_recalc_costs_for_component @v_taqversionspecategorykey,@v_total_quantity, @i_userid,@o_error_code OUTPUT, @o_error_desc OUTPUT
            IF @o_error_code != 0
                GOTO RETURN_ERROR      

            CLOSE sharedsection_cur
            DEALLOCATE sharedsection_cur
          END --END FG and Derived both Shared 
          ELSE IF @v_derived_sharedposectionind = 0 AND @v_fg_sharedposectionind = 1  --** FG SHARED AND DERIVED NOT SHARED
          BEGIN
            -- Need to find the FG related project qty that matches from related project table, not spec category table (which is a sum of all related qty)
            SELECT @v_derived_compqty = t.quantity FROM taqversionformatrelatedproject t 
            WHERE t.relatedprojectkey = @v_derived_projectkey AND t.taqversionformatkey = @v_fgorigformat
            SET @v_calcqty = @v_derived_compqty + (@v_derived_compqty * @v_spoilagepercent / 100)
            SET @v_newcompqty = ROUND(@v_calcqty, 0) 
            IF @i_debug_ind = 1  BEGIN
              PRINT 'In Shared FG, NOT shared Derived Comp'
              PRINT '  -- Calc Spoilage for Shared FG Qty/non shared derived-- '
              PRINT '  @v_taqversionspecategorykey=' + convert(varchar, @v_taqversionspecategorykey)
              PRINT '  @v_spoilagepercent=' + convert(varchar, @v_spoilagepercent)
              PRINT '  @v_newcompqty=' + convert(varchar, @v_newcompqty)
            END
            UPDATE taqversionspeccategory
            SET quantity = @v_newcompqty, lastuserid = @i_userid, lastmaintdate = getdate()
            WHERE taqversionspecategorykey = @v_taqversionspecategorykey
            --Update Costs for component
            EXEC dbo.qpl_recalc_costs_for_component @v_taqversionspecategorykey,@v_newcompqty, @i_userid,@o_error_code OUTPUT, @o_error_desc OUTPUT
            IF @o_error_code != 0
              GOTO RETURN_ERROR
          END--FG SHARED and DERIVED NOT SHARED
          ELSE IF @v_derived_sharedposectionind = 1 AND @v_fg_sharedposectionind = 0  --** FG NOT SHARED AND DERIVED SHARED,
          BEGIN
            --Need to find the update the correct project on the related project table as well as total section qty and related component qty)
            SET @v_calcqty = @v_compqty + (@v_compqty * @v_spoilagepercent / 100)
            SET @v_newcompqty = ROUND(@v_calcqty, 0) 
            SET @v_derived_versionformatrelatedkey = 0
            SET @v_derived_relatedprojectkey = 0
    
            IF @i_debug_ind = 1  BEGIN    
              PRINT 'In NOT Shared FG, Shared Derived Comp'
              PRINT '  -- Calc Spoilage for NOT Shared FG Qty/Shared derived-- '
              PRINT '  @v_taqversionspecategorykey=' + convert(varchar, @v_taqversionspecategorykey)
              PRINT '  @v_spoilagepercent=' + convert(varchar, @v_spoilagepercent)
              PRINT '  @v_newcompqty=' + convert(varchar, @v_newcompqty)
              PRINT '  @v_relatedcategorykey=' + convert(varchar, @v_relatedcategorykey)
            END

            SELECT  @v_derived_relatedprojectkey = tfr.relatedprojectkey
            FROM taqversionformatrelatedproject tfr 
            WHERE tfr.taqversionformatkey = @v_formatkey

            SELECT @v_derived_versionformatrelatedkey = t.taqversionformatrelatedkey
            FROM taqversionformatrelatedproject t
            WHERE t.taqversionformatkey = @v_derived_taqversionformatkey 
              AND t.relatedprojectkey = @v_derived_relatedprojectkey

            IF @i_debug_ind = 1  BEGIN
              PRINT  '@v_derived_relatedprojectkey =' + ISNULL(convert(varchar, @v_derived_relatedprojectkey),'NULL')
              PRINT  '@v_derived_versionformatrelatedkey=' + ISNULL(convert(varchar, @v_derived_versionformatrelatedkey),'NULL')
              PRINT  '@v_derived_taqversionformatkey=' + ISNULL(convert(varchar, @v_derived_taqversionformatkey),'NULL')
              PRINT  '@v_speccategorykey=' + ISNULL(convert(varchar, @v_speccategorykey),'NULL')
            END
       
            IF @v_derived_versionformatrelatedkey <> 0 AND  @v_derived_relatedprojectkey <> 0 
            BEGIN
              UPDATE taqversionformatrelatedproject --update related project quantity on shared section
              SET quantity = @v_newcompqty, lastuserid = @i_userid, lastmaintdate = getdate()
              WHERE taqversionformatrelatedkey = @v_derived_versionformatrelatedkey

              UPDATE taqversionspeccategory  --update quantity on shared section related component
              SET quantity = @v_newcompqty, lastuserid = @i_userid, lastmaintdate = getdate()
              WHERE taqprojectkey = @v_derived_relatedprojectkey AND relatedspeccategorykey = @v_taqversionspecategorykey

              -- Update component qty for shared section based on total of all related project
              SELECT @v_total_quantity = ISNULL(SUM (t.quantity),0) FROM taqversionformatrelatedproject t
              WHERE t.taqversionformatkey = @v_derived_taqversionformatkey
              UPDATE taqversionspeccategory
              SET quantity = @v_total_quantity
              WHERE taqversionspecategorykey = @v_taqversionspecategorykey
              
              --Update Costs for Shared Section component 
              EXEC dbo.qpl_recalc_costs_for_component @v_taqversionspecategorykey,@v_total_quantity, @i_userid,@o_error_code OUTPUT, @o_error_desc OUTPUT
              IF @o_error_code != 0
              GOTO RETURN_ERROR
              IF @i_debug_ind = 1  BEGIN         
                PRINT '   @v_total_quantity=' + convert(varchar, @v_total_quantity)
              END

            END
          END    -- FG not Shared/Derived Shared
          ELSE   -- FG AND DERIVED ARE NOT ON SHARED SECTIONS  
          BEGIN
            SET @v_calcqty = @v_compqty + (@v_compqty * @v_spoilagepercent / 100)
            SET @v_newcompqty = ROUND(@v_calcqty, 0)          
        
            IF @i_debug_ind = 1  BEGIN          
              PRINT '  -- Calc Spoilage for Derived From FG Qty-- '
              PRINT '  @v_taqversionspecategorykey=' + convert(varchar, @v_taqversionspecategorykey)
              PRINT '  @v_spoilagepercent=' + convert(varchar, @v_spoilagepercent)
              PRINT '  @v_newcompqty=' + convert(varchar, @v_newcompqty)
            END

            UPDATE taqversionspeccategory
            SET quantity = @v_newcompqty, lastuserid = @i_userid, lastmaintdate = getdate()
            WHERE taqversionspecategorykey = @v_taqversionspecategorykey AND ISNULL(relatedspeccategorykey,0) = 0
        
            -- Recalculate Costs for updated component
            EXEC dbo.qpl_recalc_costs_for_component @v_taqversionspecategorykey,@v_newcompqty, @i_userid,@o_error_code OUTPUT, @o_error_desc OUTPUT
            IF @o_error_code != 0
              GOTO RETURN_ERROR
          END
                    
          FETCH deriveqty_cur INTO @v_taqversionspecategorykey, @v_spoilagepercent, @v_derived_projectkey, @v_derived_taqversionformatkey
        END ----UPDATE DERIVED QT LOOP 

        CLOSE deriveqty_cur
        DEALLOCATE deriveqty_cur

      END -- FG COMPONENT
      ELSE IF @v_derivedfromfgind = 1 AND @v_sharedposectionind = 1 -- If this non-FG component qty is derived from shared section fg qty
      BEGIN
        -- Needed for Add Section and Update Spoilage/Derived on Shared Section (but currently running for all derived/shared sections whether updated or not)
        SELECT @v_newcompqty = ISNULL(SUM(quantity),0)
        FROM taqversionformatrelatedproject
        WHERE taqversionformatkey = @v_formatkey
        IF @i_debug_ind = 1  BEGIN
        PRINT 'In Component Qty Update Derived/Shared Section' 
        PRINT '  @v_newcompqty=' + convert(varchar, @v_newcompqty)
        END
        UPDATE taqversionspeccategory
        SET quantity = @v_newcompqty, lastuserid = @i_userid, lastmaintdate = getdate()
        WHERE taqversionspecategorykey = @v_categorykey
      END

      -- Recalculate Costs for current component  (code moved to separate procedure 3/31/17)
      EXEC dbo.qpl_recalc_costs_for_component @v_categorykey,@v_compqty, @i_userid,@o_error_code OUTPUT, @o_error_desc OUTPUT

      IF @o_error_code != 0
        GOTO RETURN_ERROR

    END  --IF UNLOCKED 

    FETCH updateprodqty_cur
    INTO @v_categorykey, @v_projectkey, @v_formatkey, @v_plstage, @v_plversion, @v_categorycode, @v_relatedcategorykey, @v_spoilagepercent, @v_sharedposectionind
  END -- PROCESSING COMPONENTS LOOP
  
  PRINT ' -- CLOSE updateprodqty_cur'

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
