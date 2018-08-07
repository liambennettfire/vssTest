IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_ver_tot_exp_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_ver_tot_exp_IP]
GO





CREATE PROCEDURE qpl_calc_ver_tot_exp_IP (  

  @i_projectkey INT,

  @i_plstage    INT,

  @i_plversion  INT, 

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_calc_ver_tot_exp_IP

**  Desc:  
	(Editorial Operations + Discretionary Marketing + Allocated Marketing + Marketing Operations + Production Operations + 
	President Operations + Shared Expenses + Fulfillment Costs)
	
**

**  Auth: Jason

**  Date: August 4 2014

*******************************************************************************************/



DECLARE

  @v_Allocated_Marketing FLOAT,
  @v_Editorial_Operations FLOAT,
  @v_Discretioanry_Marketing FLOAT,
  @v_Marketing_Operations FLOAT,
  @v_Production_Operations FLOAT,
  @v_President_Operations FLOAT,
  @v_Shared_Expenses FLOAT,
  @v_Fullfillment_Costs FLOAT,
  @v_total_expenses FLOAT



BEGIN



  SET @v_total_expenses = 0

  SET @o_result = NULL

  

  -- Stage Allocated marketing

   EXEC qpl_calc_version @i_projectkey, @i_plstage,@i_plversion, 'MISCExp', 'MktgAllo', 0, @v_Allocated_Marketing OUTPUT


  IF @v_Allocated_Marketing IS NULL

    SET @v_Allocated_Marketing = 0

	

  -- Editorial Operations

  EXEC qpl_calc_version @i_projectkey, @i_plstage,@i_plversion, 'MISCExp', 'EdOp', 0, @v_Editorial_Operations OUTPUT



  IF @v_Editorial_Operations IS NULL

    SET @v_Editorial_Operations = 0

  

  -- Discretionary Marketing

  EXEC qpl_calc_version @i_projectkey, @i_plstage,@i_plversion, 'MISCExp', 'MktgDisc', 0, @v_Discretioanry_Marketing OUTPUT



  IF @v_Discretioanry_Marketing IS NULL

    SET @v_Discretioanry_Marketing = 0

  	

  -- Marketing operations

  EXEC qpl_calc_version @i_projectkey, @i_plstage,@i_plversion, 'MISCExp', 'MktgOp', 0, @v_Marketing_Operations OUTPUT



  IF @v_Marketing_Operations IS NULL

    SET @v_Marketing_Operations = 0    

    

  -- Production Operations

   EXEC qpl_calc_version @i_projectkey, @i_plstage,@i_plversion, 'MISCExp', 'ProdOp', 0, @v_Production_Operations OUTPUT

  

  IF @v_Production_Operations IS NULL

    SET @v_Production_Operations = 0


	 -- President Operations

	EXEC qpl_calc_version @i_projectkey, @i_plstage,@i_plversion, 'MISCExp', 'PresidentO', 0, @v_President_Operations OUTPUT

  
  IF @v_President_Operations IS NULL

    SET @v_President_Operations = 0

	-- Shared Expenses

	EXEC qpl_calc_version @i_projectkey, @i_plstage,@i_plversion, 'MISCExp', 'SharedExp', 0, @v_Shared_Expenses OUTPUT

  
  IF @v_Shared_Expenses IS NULL

    SET @v_Shared_Expenses = 0

	--Fullfillment Costs
	EXEC qpl_calc_ver_fulfill @i_projectkey, @i_plstage,@i_plversion, @v_Fullfillment_Costs OUTPUT

	IF @v_Fullfillment_Costs IS NULL

    SET @v_Fullfillment_Costs = 0
  

  SET @v_total_expenses = @v_Allocated_Marketing + @v_Editorial_Operations + @v_Discretioanry_Marketing + 
						  @v_Marketing_Operations + @v_Production_Operations + @v_President_Operations + @v_Shared_Expenses +
						  @v_Fullfillment_Costs
   

  SET @o_result = @v_total_expenses

  

END
Go
Grant all on qpl_calc_ver_tot_exp_IP to public