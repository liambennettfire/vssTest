if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc135') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc135
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_roy_exp_less_adv_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_roy_exp_less_adv_HMH
GO

CREATE PROCEDURE qpl_calc_ver_roy_exp_less_adv_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_roy_exp_less_adv_HMH
**  Desc: Houghton Mifflin Item 135 - Version/Royalty Expense Less Advance.
**
**  Auth: Kate
**  Date: March 31 2010
*******************************************************************************************/

DECLARE
  @v_royalty_advance	FLOAT,
  @v_royalty_expense	FLOAT,
  @v_total	FLOAT

BEGIN

  SET @o_result = NULL

  -- Version - Royalty Expense
  EXEC qpl_calc_ver_roy_exp @i_projectkey, @i_plstage, @i_plversion, 0, @v_royalty_expense OUTPUT
  
  IF @v_royalty_expense IS NULL
    SET @v_royalty_expense = 0

  -- Version - Royalty Advance
  EXEC qpl_calc_ver_roy_adv @i_projectkey, @i_plstage, @i_plversion, @v_royalty_advance OUTPUT
  
  IF @v_royalty_advance IS NULL
    SET @v_royalty_advance = 0
    
  SET @v_total = @v_royalty_expense - @v_royalty_advance
  SET @o_result = @v_total
  
END
GO

GRANT EXEC ON qpl_calc_ver_roy_exp_less_adv_HMH TO PUBLIC
GO
