if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc013') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc013
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_gross_marg') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_gross_marg
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_gross_marg_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_gross_marg_HMH
GO

CREATE PROCEDURE qpl_calc_stg_gross_marg_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_gross_marg_HMH
**  Desc: Houghton Mifflin Item 13 - Stage/Gross Margin.
**
**  Auth: Kate
**  Date: February 25 2010
*******************************************************************************************/

DECLARE
  @v_gross_margin FLOAT,
  @v_production FLOAT,
  @v_royalty  FLOAT,
  @v_total_income FLOAT

BEGIN

  SET @o_result = NULL
  
  -- Stage - TOTAL Income
  EXEC qpl_calc_stg_tot_inc_HMH @i_projectkey, @i_plstage, @v_total_income OUTPUT

  IF @v_total_income IS NULL
    SET @v_total_income = 0
    
  -- Stage - Prepress & PPBF
  EXEC qpl_calc_stg_pre_PPBF @i_projectkey, @i_plstage, @v_production OUTPUT

  IF @v_production IS NULL
    SET @v_production = 0
    
  -- Stage - Royalty
  EXEC qpl_calc_stg_roy_exp @i_projectkey, @i_plstage, @v_royalty OUTPUT

  IF @v_royalty IS NULL
    SET @v_royalty = 0    
  
  SET @v_gross_margin = @v_total_income - @v_production - @v_royalty
  SET @o_result = @v_gross_margin
  
END
GO

GRANT EXEC ON qpl_calc_stg_gross_marg_HMH TO PUBLIC
GO
