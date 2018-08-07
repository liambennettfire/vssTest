if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc033') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc033
GO
 
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_tot_net_unt') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_tot_net_unt
GO

CREATE PROCEDURE qpl_calc_ver_tot_net_unt (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_tot_net_unt
**  Desc: Island Press Item 33 - Version/TOTAL Net Sales Units.
**
**  Auth: Kate
**  Date: January 29 2008
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
      c.taqversionkey = @i_plversion

  SET @o_result = @v_total_net_units
  
END
GO

GRANT EXEC ON qpl_calc_ver_tot_net_unt TO PUBLIC
GO
