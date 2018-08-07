if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc041') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc041
GO
 
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_net_unt_hard') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_net_unt_hard
GO

CREATE PROCEDURE qpl_calc_yr_net_unt_hard (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_net_unt_hard
**  Desc: P&L Item 41 - Year/Net Units - Hardcover.
**
**  Auth: Kate
**  Date: November 20 2009
*******************************************************************************************/

DECLARE
  @v_hardcover_net_units  INT
  
BEGIN

  SET @o_result = NULL

  SELECT @v_hardcover_net_units = SUM(netsalesunits)
  FROM taqversionsalesunit u, taqversionsaleschannel c, taqversionformat f
  WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
      c.taqprojectkey = f.taqprojectkey AND
      c.plstagecode = f.plstagecode AND
      c.taqversionkey = f.taqversionkey AND
      c.taqprojectformatkey = f.taqprojectformatkey AND
      c.taqprojectkey = @i_projectkey AND
      c.plstagecode = @i_plstage AND
      c.taqversionkey = @i_plversion AND
      u.yearcode = @i_yearcode AND
      f.mediatypecode = 2 AND 
      f.mediatypesubcode IN (6,26)

  SET @o_result = @v_hardcover_net_units
  
END
GO

GRANT EXEC ON qpl_calc_yr_net_unt_hard TO PUBLIC
GO
