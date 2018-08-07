if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc022') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc022
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_tot_inc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_tot_inc
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_tot_inc_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_tot_inc_HMH
GO

CREATE PROCEDURE qpl_calc_ver_tot_inc_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_tot_inc_HMH
**  Desc: Island Press Item 22 - Version/TOTAL Income.
**
**  Auth: Kate
**  Date: November 15 2007
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

  -- Version - Net Sales
  EXEC qpl_calc_ver_net_sales @i_projectkey, @i_plstage, @i_plversion, @v_net_sales OUTPUT
  
  IF @v_net_sales IS NULL
    SET @v_net_sales = 0

  -- Version - Production Subsidy Income
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MISCINC', 'PRODSUB', 1, @v_prodsubsidy_income OUTPUT
  
  IF @v_prodsubsidy_income IS NULL
    SET @v_prodsubsidy_income = 0

  -- Version - Subsidiary Rights Income
  EXEC qpl_calc_ver_sub_rights_inc_HMH @i_projectkey, @i_plstage, @i_plversion, @v_subrights_income OUTPUT

  IF @v_subrights_income IS NULL
    SET @v_subrights_income = 0
    
  -- Version - Other Income
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MISCINC', 'OTHINC', 1, @v_other_income OUTPUT
  
  IF @v_other_income IS NULL
    SET @v_other_income = 0
    
  SET @v_total_income = @v_net_sales + @v_prodsubsidy_income + @v_subrights_income + @v_other_income
  SET @o_result = @v_total_income
  
END
GO

GRANT EXEC ON qpl_calc_ver_tot_inc_HMH TO PUBLIC
GO
