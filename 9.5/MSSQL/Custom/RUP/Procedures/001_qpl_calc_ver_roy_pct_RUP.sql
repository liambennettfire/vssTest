if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_roy_pct_RUP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_roy_pct_RUP
GO

CREATE PROCEDURE qpl_calc_ver_roy_pct_RUP (  
  @i_projectkey INT,
  @i_plstage    INT,  
  @i_version    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_roy_pct_RUP
**  Desc: P&L - Stage/Gross Royalty % for Rutgers.
**        This divides the Royalty Advance by the Royalty Earned    
**
**  Auth: SLB
**  Date: February 24, 2011
*******************************************************************************************/

DECLARE
  @v_royalty_adv FLOAT,  
  @v_royalty_earned FLOAT,
  @v_royalty_percent FLOAT


BEGIN

  SET @o_result = NULL
 
  -- Version - Royalty Advance
  EXEC qpl_calc_ver_roy_adv @i_projectkey, @i_plstage, @i_version, @v_royalty_adv OUTPUT

  IF @v_royalty_adv IS NULL
    SET @v_royalty_adv = 0
    
 -- Version - Royalty Earned
  EXEC qpl_calc_ver_roy_ern @i_projectkey, @i_plstage, @i_version, 0, @v_royalty_earned OUTPUT

  IF @v_royalty_earned IS NULL
    SET @v_royalty_earned = 0
  
  IF @v_royalty_earned = 0
    SET @v_royalty_percent= 0
  ELSE
    SET @v_royalty_percent= @v_royalty_adv / @v_royalty_earned

  SET @o_result = @v_royalty_percent
  
END
GO

GRANT EXEC ON qpl_calc_ver_roy_pct_RUP TO PUBLIC
GO
