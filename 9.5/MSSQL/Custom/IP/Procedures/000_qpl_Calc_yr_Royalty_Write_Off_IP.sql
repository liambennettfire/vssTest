

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_Calc_yr_Royalty_Write_Off_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_Calc_yr_Royalty_Write_Off_IP]
GO


CREATE PROCEDURE [dbo].[qpl_Calc_yr_Royalty_Write_Off_IP] (  

  @i_projectkey INT,

  @i_plstage    INT,

  @i_plversion INT,

  @i_yearcode   INT, 

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_Calc_ver_Royalty_Write_Off_IP

**  Royalty Expense - Royalty Earnings

**  Auth: Jason

**  Date: August  2014

*******************************************************************************************/



DECLARE

 @v_Royalty_Expense FLOAT,

 @v_Royalty_Earned  FLOAT,

 @v_Royalty_Write_Off  FLOAT



BEGIN

  SET @o_result = NULL



  --Year Royalty Expense

 EXEC qpl_calc_yr_roy_exp @i_projectkey, @i_plstage, @i_plversion,@i_yearcode, 0, @v_Royalty_Expense OUTPUT

  
  If @v_Royalty_Expense is null

  SET @v_Royalty_Expense=0



    -- Year - Royalty Earned

  EXEC qpl_calc_yr_roy_ern @i_projectkey, @i_plstage, @i_plversion,@i_yearcode, 0, @v_Royalty_Earned OUTPUT



  IF @v_Royalty_Earned is null

  SET @v_Royalty_Earned=0

  
    --Calculate Year Royalty Write-OFF

  SET @v_Royalty_Write_Off = @v_Royalty_Expense - @v_Royalty_Earned

  SET @o_result = @v_Royalty_Write_Off

  

END


Go
Grant all on qpl_Calc_yr_Royalty_Write_Off_IP to Public