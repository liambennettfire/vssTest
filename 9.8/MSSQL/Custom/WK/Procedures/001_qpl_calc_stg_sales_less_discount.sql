if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_sales_less_discount') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_sales_less_discount
GO

CREATE PROCEDURE qpl_calc_stg_sales_less_discount (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_saleschanneltype  VARCHAR(50),    
  @i_formattype  VARCHAR(50),   
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_sales_less_discount
**  Desc: This stored procedure gets the Sales Net of Discount amount by sales channel and format grouping.
**        Sales channel is determined by gentext1 string stored on gentables_ext 118.
**        Format is determined by gentext1 string stored on gentables_ext/subgentables_ext 312.
**
**  Auth: Kate W.
**  Date: October 16 2013
*******************************************************************************************/

DECLARE
  @v_actuals_stage  INT,
  @v_count  INT,
  @v_selected_versionkey  INT
  
BEGIN
  
  SET @o_result = NULL

  -- Get the Actuals stage code
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 562 AND qsicode = 1
  
  IF @v_count > 0
    SELECT @v_actuals_stage = datacode
    FROM gentables
    WHERE tableid = 562 AND qsicode = 1
  ELSE
    SET @v_actuals_stage = 0
  
  IF @i_plstage = @v_actuals_stage
  BEGIN
    SET @o_result = NULL
  END
  ELSE
  BEGIN
      -- Get the selected versionkey for this stage
      SELECT @v_selected_versionkey = selectedversionkey
      FROM taqplstage
      WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage

      -- If there is no selected version for this stage, return NULL
      IF @v_selected_versionkey = 0 OR @v_selected_versionkey IS NULL
        RETURN

      -- Version/Sales Less Discount Dollars
      EXEC dbo.qpl_calc_ver_sales_less_discount @i_projectkey, @i_plstage, @v_selected_versionkey, @i_saleschanneltype, @i_formattype, @o_result OUTPUT
  END
   
END
go

GRANT EXEC ON dbo.qpl_calc_stg_sales_less_discount TO PUBLIC
GO

