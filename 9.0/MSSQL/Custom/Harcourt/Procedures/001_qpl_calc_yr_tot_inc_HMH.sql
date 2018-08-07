if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc050') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc050
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_tot_inc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_tot_inc
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_tot_inc_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_tot_inc_HMH
GO

CREATE PROCEDURE qpl_calc_yr_tot_inc_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_tot_inc_HMH
**  Desc: P&L Item 50 - Year/TOTAL Income.
**
**  Auth: Kate
**  Date: November 20 2009
*******************************************************************************************/

DECLARE
  @v_net_sales FLOAT,
  @v_other_income FLOAT,
  @v_prodsubsidy_income FLOAT,
  @v_selected_versionkey  INT,
  @v_subrights_income  FLOAT,  
  @v_total_income FLOAT

BEGIN

  SET @v_total_income = 0
  SET @o_result = NULL

  -- Year - Net Sales
  EXEC qpl_calc_yr_net_sales @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_net_sales OUTPUT
  
  IF @v_net_sales IS NULL
    SET @v_net_sales = 0

  -- Year - Production Subsidy Income
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 'MISCINC', 'PRODSUB', 1, @v_prodsubsidy_income OUTPUT
  
  IF @v_prodsubsidy_income IS NULL
    SET @v_prodsubsidy_income = 0

  -- Year - Subsidiary Rights Income
  EXEC qpl_calc_yr_sub_rights_inc_HMH @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_subrights_income OUTPUT

  IF @v_subrights_income IS NULL
    SET @v_subrights_income = 0
     
  -- Year - Other Income
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 'MISCINC', 'OTHINC', 1, @v_other_income OUTPUT
  
  IF @v_other_income IS NULL
    SET @v_other_income = 0
    
  SET @v_total_income = @v_net_sales + @v_prodsubsidy_income + @v_subrights_income + @v_other_income
  SET @o_result = @v_total_income
  
END
GO

GRANT EXEC ON qpl_calc_yr_tot_inc_HMH TO PUBLIC
GO
