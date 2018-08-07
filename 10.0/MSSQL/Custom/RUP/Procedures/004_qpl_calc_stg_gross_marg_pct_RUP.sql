if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_gross_marg_pct_RUP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_gross_marg_pct_RUP
GO

CREATE PROCEDURE qpl_calc_stg_gross_marg_pct_RUP (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_gross_marg_pct_RUP
**  Desc: P&L - Stage/Gross Margin % for Rutgers.
**        This differs from standard because it uses just net sales instead of total income    
**
**  Auth: SLB
**  Date: February 23 2011
*******************************************************************************************/

DECLARE
  @v_gross_margin FLOAT,
  @v_gross_margin_percent FLOAT,
  @v_netsales FLOAT

BEGIN

  SET @o_result = NULL
 
  -- Stage - Net Sales
  EXEC qpl_calc_stg_net_sales @i_projectkey, @i_plstage, @v_netsales OUTPUT

  IF @v_netsales IS NULL
    SET @v_netsales = 0
    
 -- stage - Gross Margin
  EXEC qpl_calc_stg_gross_marg @i_projectkey, @i_plstage, @v_gross_margin OUTPUT

  IF @v_gross_margin IS NULL
    SET @v_gross_margin = 0
  
  IF @v_netsales = 0
    SET @v_gross_margin_percent = 0
  ELSE
    SET @v_gross_margin_percent = @v_gross_margin / @v_netsales

  SET @o_result = @v_gross_margin_percent
  
END
GO

GRANT EXEC ON qpl_calc_stg_gross_marg_pct_RUP TO PUBLIC
GO
