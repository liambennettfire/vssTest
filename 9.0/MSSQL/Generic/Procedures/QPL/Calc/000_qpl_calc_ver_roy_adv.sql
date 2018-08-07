if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc065') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc065
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_roy_adv') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_roy_adv
GO

CREATE PROCEDURE qpl_calc_ver_roy_adv (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_roy_adv
**  Desc: P&L Item 65 - Version/Royalty Advance
**
**  Auth: Kate
**  Date: February 9, 2010
*******************************************************************************************/

DECLARE
  @v_royalty_advance  FLOAT

BEGIN
 
  SELECT @v_royalty_advance = SUM(amount) 
  FROM taqversionroyaltyadvance 
  WHERE taqprojectkey = @i_projectkey AND
    plstagecode = @i_plstage AND
    taqversionkey = @i_plversion
  
  SET @o_result = @v_royalty_advance
  
END
GO

GRANT EXEC ON qpl_calc_ver_roy_adv TO PUBLIC
GO
