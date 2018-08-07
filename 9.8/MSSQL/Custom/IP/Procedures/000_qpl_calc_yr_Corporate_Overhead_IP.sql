IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_yr_Corporate_Overhead_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_yr_Corporate_Overhead_IP]
GO




CREATE PROCEDURE qpl_calc_yr_Corporate_Overhead_IP (  

  @i_projectkey INT,

  @i_plstage    INT,

  @i_plversion  INT,

  @i_yearcode INT,

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_calc_yr_Corporate_Overhead_IP

**  Desc: 	 (Development Activities + G&A Operations ) - Subvention Income 


**

**  Auth: Jason

**  Date: August 4 2014

*******************************************************************************************/



DECLARE

  @v_Development_Activities FLOAT,
  @v_G_and_A_Operations FLOAT,
  @v_Subvention_Income FLOAT,
  @v_Corporate_overhead FLOAT



BEGIN



  SET @v_Corporate_overhead = 0

  SET @o_result = NULL

  

  -- Year Development Activities

   EXEC qpl_calc_year @i_projectkey, @i_plstage,@i_plversion,@i_yearcode, 'MISCExp', 'DevAct', 0, @v_Development_Activities OUTPUT


  IF @v_Development_Activities IS NULL

    SET @v_Development_Activities = 0



  -- Year G&A Operations

  EXEC qpl_calc_year @i_projectkey, @i_plstage,@i_plversion,@i_yearcode, 'MISCExp', 'GAOp', 0, @v_G_and_A_Operations OUTPUT



  IF @v_G_and_A_Operations IS NULL

    SET @v_G_and_A_Operations = 0

  

  -- Year Subvention Income

  EXEC qpl_calc_year @i_projectkey, @i_plstage,@i_plversion,@i_yearcode, 'MISCINC', 'SubIncome', 0, @v_Subvention_Income OUTPUT



  IF @v_Subvention_Income IS NULL

    SET @v_Subvention_Income = 0


  

  SET @v_Corporate_overhead = (@v_Development_Activities + @v_G_and_A_Operations) - @v_Subvention_Income
   

  SET @o_result = @v_Corporate_overhead

  

END
Go
Grant all on qpl_calc_yr_Corporate_Overhead_IP to public