IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_stg_Unearned_Advance_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_stg_Unearned_Advance_IP]
GO



CREATE PROCEDURE qpl_calc_stg_Unearned_Advance_IP (  

  @i_projectkey INT,

  @i_plstage    INT,

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_calc_stg_Unearned_Advance_IP

**  Desc:       Royalty Advance - Royalties Earned - Royalty Write Offs 

**

**  Auth: Jason

**  Date: August 2014

*******************************************************************************************/



DECLARE

  @v_Royalty_Advance FLOAT,
  @v_Royalty_Earned FLOAT,
  @v_Royalty_Write_Off FLOAT,
  @v_Unearned_Advance FLOAT


BEGIN



  SET @o_result = NULL

  

  -- Stage - Royalty Advance
  
  EXEC qpl_calc_stg_roy_adv   @i_projectkey, @i_plstage, @v_Royalty_Advance OUTPUT
  

  IF @v_Royalty_Advance IS NULL

    SET @v_Royalty_Advance = 0

    
  -- Stage - Royalty Earned
  
  EXEC qpl_calc_stg_roy_ern   @i_projectkey, @i_plstage, @v_Royalty_Earned OUTPUT
  



  IF @v_Royalty_Earned IS NULL

    SET @v_Royalty_Earned = 0

  -- Stage - Royalty Write off
  
  EXEC qpl_Calc_stg_Royalty_Write_Off_IP   @i_projectkey, @i_plstage, @v_Royalty_Write_Off OUTPUT
  



  IF @v_Royalty_Write_Off IS NULL

    SET @v_Royalty_Write_Off = 0

  

  SET @v_Unearned_Advance = @v_Royalty_Advance - @v_Royalty_Earned - @v_Royalty_Write_Off

  SET @o_result = @v_Unearned_Advance

  

END

Go
Grant all on qpl_calc_stg_Unearned_Advance_IP to public