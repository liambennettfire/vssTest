if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc017') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc017
GO
 
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_net_unt_oth') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_net_unt_oth
GO

CREATE PROCEDURE qpl_calc_ver_net_unt_oth (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_net_unt_oth
**  Desc: Island Press Item 17 - Version/Net Units - Other formats.
**
**  Auth: Kate
**  Date: January 29 2008
*******************************************************************************************/

DECLARE
  @v_other_net_units  INT
  
BEGIN

  SET @o_result = NULL

  SELECT @v_other_net_units = SUM(netsalesunits)
  FROM taqversionsalesunit u, taqversionsaleschannel c, taqversionformat f
  WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
      c.taqprojectkey = f.taqprojectkey AND
      c.plstagecode = f.plstagecode AND
      c.taqversionkey = f.taqversionkey AND
      c.taqprojectformatkey = f.taqprojectformatkey AND
      c.taqprojectkey = @i_projectkey AND
      c.plstagecode = @i_plstage AND
      c.taqversionkey = @i_plversion AND
      NOT (f.mediatypecode = 2 AND f.mediatypesubcode IN(6,20,26,27))

  SET @o_result = @v_other_net_units
  
END
GO

GRANT EXEC ON qpl_calc_ver_net_unt_oth TO PUBLIC
GO
