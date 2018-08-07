if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc007') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc007
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_tot_inc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_tot_inc
GO

CREATE PROCEDURE qpl_calc_stg_tot_inc (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_tot_inc
**  Desc: Island Press Item 7 - Stage/TOTAL Income.
**
**  Auth: Kate
**  Date: November 15 2007
*******************************************************************************************/

DECLARE
  @v_bulk_sales FLOAT,
  @v_net_sales FLOAT,
  @v_other_income FLOAT,
  @v_prodsubsidy_income FLOAT,
  @v_subrights_income  FLOAT,  
  @v_total_income FLOAT

BEGIN

  SET @v_total_income = 0
  SET @o_result = NULL
 
  -- Stage - Net Sales
  EXEC qpl_calc_stg_net_sales @i_projectkey, @i_plstage, @v_net_sales OUTPUT
  
  IF @v_net_sales IS NULL
    SET @v_net_sales = 0
    
  -- Stage - Production Subsidy Income  
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'MISCINC', 'PRODSUB', 1, @v_prodsubsidy_income OUTPUT
  
  IF @v_prodsubsidy_income IS NULL
    SET @v_prodsubsidy_income = 0
    
  -- Stage - Subsidiary Rights Income
  EXEC qpl_calc_stg_sub_rights_inc @i_projectkey, @i_plstage, @v_subrights_income OUTPUT

  IF @v_subrights_income IS NULL
    SET @v_subrights_income = 0

  -- Stage - Bulk Sales
  EXEC qpl_calc_stg_bulk_sales @i_projectkey, @i_plstage, @v_bulk_sales OUTPUT
  
  IF @v_bulk_sales IS NULL
    SET @v_bulk_sales = 0
    
  -- Stage - Other Income
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'MISCINC', 'OTHINC', 1, @v_other_income OUTPUT
  
  IF @v_other_income IS NULL
    SET @v_other_income = 0
    
  SET @v_total_income = @v_net_sales + @v_prodsubsidy_income + @v_subrights_income + @v_bulk_sales + @v_other_income
  SET @o_result = @v_total_income
  
END
GO

GRANT EXEC ON qpl_calc_stg_tot_inc TO PUBLIC
GO
