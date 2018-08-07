
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_tot_inc_UCAL') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_tot_inc_UCAL
GO

CREATE PROCEDURE qpl_calc_ver_tot_inc_UCAL (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_tot_inc_UCAL
**  Desc: UCAL Version/TOTAL Income.
**
**  Auth: slb
**  Date: October 25 2011
*******************************************************************************************/

DECLARE
  @v_bulk_sales FLOAT,
  @v_net_sales FLOAT,
  @v_other_income FLOAT,
  @v_selected_versionkey  INT,
  --@v_prodsubsidy_income FLOAT,
  @v_subrights_income  FLOAT,  
  @v_total_income FLOAT

BEGIN

  SET @v_total_income = 0
  SET @o_result = NULL

  -- Version - Net Sales
  EXEC qpl_calc_ver_net_sales @i_projectkey, @i_plstage, @i_plversion, @v_net_sales OUTPUT
  
  IF @v_net_sales IS NULL
    SET @v_net_sales = 0
    
 
 -- Version - Production Subsidy Income
 --EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MISCINC', 'PRODSUB', 1, @v_prodsubsidy_income OUTPUT
  
 -- IF @v_prodsubsidy_income IS NULL
 --   SET @v_prodsubsidy_income = 0


   -- Version - Subsidiary Rights Income
  EXEC qpl_calc_ver_sub_rights_inc @i_projectkey, @i_plstage, @i_plversion, @v_subrights_income OUTPUT

  IF @v_subrights_income IS NULL
    SET @v_subrights_income = 0
  
  -- Version - Bulk Sales
  EXEC qpl_calc_ver_bulk_sales @i_projectkey, @i_plstage, @i_plversion, @v_bulk_sales OUTPUT
  
  IF @v_bulk_sales IS NULL
    SET @v_bulk_sales = 0
    
  -- Version - Other Income
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MISCINC', 'OTHINC', 1, @v_other_income OUTPUT
  
  IF @v_other_income IS NULL
    SET @v_other_income = 0
  
  --SET @v_total_income = @v_net_sales + @v_prodsubsidy_income + @v_subrights_income + @v_bulk_sales + @v_other_income
  SET @v_total_income = @v_net_sales + @v_subrights_income + @v_bulk_sales + @v_other_income
  
  SET @o_result = @v_total_income
  
END
GO

GRANT EXEC ON qpl_calc_ver_tot_inc_UCAL TO PUBLIC
GO
