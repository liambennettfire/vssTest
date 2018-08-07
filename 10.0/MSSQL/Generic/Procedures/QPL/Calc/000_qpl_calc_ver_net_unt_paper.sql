if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc016') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc016
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_net_unt_paper') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_net_unt_paper
GO
 
CREATE PROCEDURE qpl_calc_ver_net_unt_paper (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_net_unt_paper
**  Desc: Island Press Item 16 - Version/Net Units - Paperback.
**
**  Auth: Kate
**  Date: January 29 2008
*******************************************************************************************/

DECLARE
  @v_paperback_net_units  INT
  
BEGIN

  SET @o_result = NULL

  SELECT @v_paperback_net_units = SUM(netsalesunits)
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
      f.mediatypesubcode IN (20,27)

  SET @o_result = @v_paperback_net_units
  
END
GO

GRANT EXEC ON qpl_calc_ver_net_unt_paper TO PUBLIC
GO
