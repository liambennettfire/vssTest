if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc029') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc029
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_gross_marg') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_gross_marg
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_gross_marg_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_gross_marg_HMH
GO

CREATE PROCEDURE qpl_calc_ver_gross_marg_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,  
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_gross_marg_HMH
**  Desc: Houghton Mifflin Item 29 - Version/Gross Margin.
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
  
  -- Version - TOTAL Income
  EXEC qpl_calc_ver_tot_inc_HMH @i_projectkey, @i_plstage, @i_plversion, @v_total_income OUTPUT

  IF @v_total_income IS NULL
    SET @v_total_income = 0
    
  -- Version - Prepress & PPBF
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'PRODEXP', NULL, 0, @v_production OUTPUT

  IF @v_production IS NULL
    SET @v_production = 0

  -- Version - Royalty Expense
  EXEC qpl_calc_ver_roy_exp @i_projectkey, @i_plstage, @i_plversion, 0, @v_royalty OUTPUT

  IF @v_royalty IS NULL
    SET @v_royalty = 0
          
  SET @v_gross_margin = @v_total_income - @v_production - @v_royalty
  SET @o_result = @v_gross_margin
  
END
GO

GRANT EXEC ON qpl_calc_ver_gross_marg_HMH TO PUBLIC
GO
