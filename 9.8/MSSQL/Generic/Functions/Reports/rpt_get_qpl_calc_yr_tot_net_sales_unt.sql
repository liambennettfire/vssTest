if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_qpl_calc_yr_tot_net_sales_unt') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_qpl_calc_yr_tot_net_sales_unt
GO

CREATE FUNCTION [dbo].[rpt_get_qpl_calc_yr_tot_net_sales_unt] (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT)
  RETURNS FLOAT

/******************************************************************************************
**  Name: rpt_get_qpl_calc_yr_tot_net_sales_unt
**  Desc: P&L Item 44 - Year/TOTAL Net Sales Units.  Converted from qpl_calc_yr_tot_net_sales_unt
**
**  Auth: Josh B
**  Date: July 9th 2018
*******************************************************************************************/
BEGIN
DECLARE
  @v_total_net_units  INT

  DECLARE @RETURN FLOAT
  SET @RETURN = NULL
  

  SELECT @v_total_net_units = SUM(netsalesunits)
  FROM taqversionsalesunit u, taqversionsaleschannel c
  WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
      c.taqprojectkey = @i_projectkey AND
      c.plstagecode = @i_plstage AND
      c.taqversionkey = @i_plversion AND
      u.yearcode = @i_yearcode

  SET @RETURN = @v_total_net_units

  RETURN @RETURN
  
END

GO
GRANT EXECUTE ON dbo.rpt_get_qpl_calc_yr_tot_net_sales_unt TO PUBLIC
GO