if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_qpl_calc_ver_tot_net_unt') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_qpl_calc_ver_tot_net_unt
GO

CREATE FUNCTION [dbo].[rpt_get_qpl_calc_ver_tot_net_unt] (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT)
  RETURNS Float


/******************************************************************************************
**  Name: rpt_get_qpl_calc_ver_tot_net_unt
**  Desc: Island Press Item 33 - Version/TOTAL Net Sales Units.  converted from qpl_calc_ver_tot_net_unt
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
      c.taqversionkey = @i_plversion

  SET @RETURN = @v_total_net_units
  
  RETURN @RETURN

END


GO
GRANT EXECUTE ON dbo.rpt_get_qpl_calc_ver_tot_net_unt TO PUBLIC
GO