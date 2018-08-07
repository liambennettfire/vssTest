if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc055') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc055
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_wo_edt_comps') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_wo_edt_comps
GO

CREATE PROCEDURE qpl_calc_yr_wo_edt_comps (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,  
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_wo_edt_comps
**  Desc: P&L Item 55 - Year/Write-offs & Edit Comps.
**
**  Auth: Kate
**  Date: November 20 2009
*******************************************************************************************/

DECLARE
  @v_formatkey  INT,
  @v_formatyear_qty INT,
  @v_formatyear_unitcost FLOAT,
  @v_formatyear_total FLOAT,
  @v_grand_total  FLOAT,
  @v_yearcode INT

BEGIN

  SET @o_result = NULL

  -- Loop through all Format/Year additional units (other than Marketing Units)
  DECLARE formatyearqty_cur CURSOR FOR
    SELECT u.taqprojectformatkey, y.yearcode, SUM(y.quantity) formatyear_qty
    FROM taqversionaddtlunits u, taqversionaddtlunitsyear y
    WHERE u.addtlunitskey = y.addtlunitskey AND
        u.taqprojectkey = @i_projectkey AND
        u.plstagecode = @i_plstage AND 
        u.taqversionkey = @i_plversion AND
        y.yearcode = @i_yearcode AND
        u.plunittypecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 570 AND qsicode = 1)
    GROUP BY u.taqprojectformatkey, y.yearcode
    ORDER BY u.taqprojectformatkey, y.yearcode
  
  OPEN formatyearqty_cur
  
  FETCH formatyearqty_cur INTO @v_formatkey, @v_yearcode, @v_formatyear_qty

  SET @v_grand_total = 0
  WHILE (@@FETCH_STATUS=0)
  BEGIN
    -- Get the Total Unit Cost for the closest previous year for this Format
    SET @v_formatyear_unitcost = dbo.qpl_get_total_unitcost_by_formatyear(@v_formatkey, @v_yearcode)
    
    IF @v_formatyear_qty IS NULL
      SET @v_formatyear_qty = 0

    -- Calculate the Write-Off for this Format/Year by multiplying the total additional units by the total unit cost
    SET @v_formatyear_total = @v_formatyear_qty * @v_formatyear_unitcost
    SET @v_grand_total = @v_grand_total + @v_formatyear_total
    
    FETCH formatyearqty_cur INTO @v_formatkey, @v_yearcode, @v_formatyear_qty
  END
  
  CLOSE formatyearqty_cur
  DEALLOCATE formatyearqty_cur

  SET @o_result = @v_grand_total
  
END
GO

GRANT EXEC ON qpl_calc_yr_wo_edt_comps TO PUBLIC
GO
