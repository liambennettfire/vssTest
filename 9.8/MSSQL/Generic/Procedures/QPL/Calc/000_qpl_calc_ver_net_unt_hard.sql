if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc015') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc015
GO

 if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_net_unt_hard') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_net_unt_hard
GO

CREATE PROCEDURE qpl_calc_ver_net_unt_hard (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_net_unt_hard
**  Desc: Island Press Item 15 - Version/Net Units - Hardcover.
**
**  Auth: Kate
**  Date: January 29 2008
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
      f.mediatypecode = 2 AND 
      f.mediatypesubcode IN (6,26)

  SET @o_result = @v_hardcover_net_units
  
END
GO

GRANT EXEC ON qpl_calc_ver_net_unt_hard TO PUBLIC
GO
