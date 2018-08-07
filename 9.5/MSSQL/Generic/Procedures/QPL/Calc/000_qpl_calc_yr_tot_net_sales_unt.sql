if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc044') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc044
GO
 
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_tot_net_sales_unt') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_tot_net_sales_unt
GO

CREATE PROCEDURE qpl_calc_yr_tot_net_sales_unt (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_tot_net_sales_unt
**  Desc: P&L Item 44 - Year/TOTAL Net Sales Units.
**
**  Auth: Kate
**  Date: November 20 2009
*******************************************************************************************/

DECLARE
  @v_total_net_units  INT
  
BEGIN

  SET @o_result = NULL

  SELECT @v_total_net_units = SUM(netsalesunits)
  FROM taqversionsalesunit u, taqversionsaleschannel c
  WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
      c.taqprojectkey = @i_projectkey AND
      c.plstagecode = @i_plstage AND
      c.taqversionkey = @i_plversion AND
      u.yearcode = @i_yearcode

  SET @o_result = @v_total_net_units
  
END
GO

GRANT EXEC ON qpl_calc_yr_tot_net_sales_unt TO PUBLIC
GO
