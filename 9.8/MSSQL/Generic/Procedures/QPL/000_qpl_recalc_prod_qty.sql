if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_recalc_prod_qty') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_recalc_prod_qty
GO

CREATE PROCEDURE qpl_recalc_prod_qty (  
  @i_projectkey   INT,
  @i_plstage      INT,
  @i_plversion    INT,
  @i_userid       VARCHAR(30),
  @i_calc_percent TINYINT,
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_recalc_prod_qty
**  Desc: This stored procedure recalculates detail production units (or percentages)
**        for the given version from Total Required Units and existing percentages.
**
**  Auth: Kate
**  Date: March 11 2008
*******************************************************************************************/

DECLARE
  @v_current_percent FLOAT,
  @v_current_quantity INT,  
  @v_current_prtgnum  INT,
  @v_formatkey  INT,
  @v_formatyearkey  INT,
  @v_isopentrans TINYINT,
  @v_next_prtgnum INT,
  @v_prod_percent FLOAT,
  @v_prod_units FLOAT,
  @v_prodqty_code INT, 
  @v_required_qty INT,
  @v_set_prtgnum  INT,
  @v_yearcode	INT  
    
BEGIN

  SET @v_isopentrans = 0
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
  
  -- ***** BEGIN TRANSACTION ****  
  BEGIN TRANSACTION
  SET @v_isopentrans = 1
  
  -- Get the production quantity entry type code value
  SELECT @v_prodqty_code = prodqtyentrytypecode 
  FROM taqversion 
  WHERE taqprojectkey = @i_projectkey AND 
	  plstagecode = @i_plstage AND 
	  taqversionkey = @i_plversion
  
  DECLARE formats_cur CURSOR FOR 
    SELECT taqprojectformatkey 
    FROM taqversionformat 
    WHERE taqprojectkey = @i_projectkey AND
        plstagecode = @i_plstage AND
        taqversionkey = @i_plversion

  OPEN formats_cur
  
  FETCH formats_cur INTO @v_formatkey

  WHILE @@fetch_status = 0
  BEGIN
  
    SET @v_next_prtgnum = 0
  
    -- Get the Total Required Quantity for this P&L Version/Format
    SET @v_required_qty = dbo.qpl_get_format_totalrequiredqty(@i_projectkey, @i_plstage, @i_plversion, @v_formatkey)
    
    -- ***** TAQVERSIONFORMATYEAR - Production Percentages/Units *****
    DECLARE formatyear_cur CURSOR FOR 
      SELECT taqversionformatyearkey, yearcode, percentage, quantity, printingnumber
      FROM taqversionformatyear 
      WHERE taqprojectkey = @i_projectkey AND 
          plstagecode = @i_plstage AND 
          taqversionkey = @i_plversion AND 
          taqprojectformatkey = @v_formatkey AND
          yearcode NOT IN (SELECT datacode FROM gentables WHERE tableid = 563 AND qsicode = 1)	--skip Pre-Pub year
      ORDER BY yearcode             
    
    OPEN formatyear_cur
    
    FETCH formatyear_cur INTO @v_formatyearkey, @v_yearcode, @v_current_percent, @v_current_quantity, @v_current_prtgnum

    WHILE @@fetch_status = 0
    BEGIN
    
      IF @v_prodqty_code = 2 --calculate from required qty by year instead of total
      BEGIN
        EXEC qpl_get_totalrequnits_year @i_projectkey, @i_plstage, @i_plversion, @v_yearcode, @v_formatkey, @v_required_qty OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
      END
    
      IF @i_calc_percent = 1  --calculate percentage from Total Required Quantity based on current Year quantity
        BEGIN
          IF @v_required_qty <> 0
            SET @v_prod_percent = @v_current_quantity * 100 / @v_required_qty
          ELSE
            SET @v_prod_percent = 0
          
          UPDATE taqversionformatyear
          SET percentage = @v_prod_percent, lastuserid = @i_userid, lastmaintdate = GETDATE()
          WHERE taqversionformatyearkey = @v_formatyearkey        
        END
        
      ELSE  --calculate quantity from Total Required Quantity based on current percentage
        BEGIN
          SET @v_prod_units = @v_required_qty * @v_current_percent / 100
          SET @v_prod_units = ROUND(@v_prod_units, 0)
          
          SET @v_set_prtgnum = 0
          IF @v_prod_units > 0
          BEGIN
            SET @v_next_prtgnum = @v_next_prtgnum + 1
            SET @v_set_prtgnum = @v_next_prtgnum
          END
          ELSE
            SET @v_set_prtgnum = NULL
          
          UPDATE taqversionformatyear
          SET quantity = @v_prod_units, printingnumber = @v_set_prtgnum, lastuserid = @i_userid, lastmaintdate = GETDATE()
          WHERE taqversionformatyearkey = @v_formatyearkey
        END
      
      FETCH formatyear_cur INTO @v_formatyearkey, @v_yearcode, @v_current_percent, @v_current_quantity, @v_current_prtgnum
    END

    CLOSE formatyear_cur 
    DEALLOCATE formatyear_cur    
    
    FETCH formats_cur INTO @v_formatkey
  END

  CLOSE formats_cur 
  DEALLOCATE formats_cur
  
  
  IF @v_isopentrans = 1
    COMMIT
  
  RETURN  

  RETURN_ERROR:
    IF @v_isopentrans = 1
      ROLLBACK
  
    SET @o_error_code = -1
    RETURN
      
END
GO

GRANT EXEC ON qpl_recalc_prod_qty TO PUBLIC
GO