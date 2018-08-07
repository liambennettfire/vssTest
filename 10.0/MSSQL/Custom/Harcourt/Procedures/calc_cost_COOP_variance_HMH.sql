IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'calc_cost_COOP_variance_HMH' ) 
     DROP PROCEDURE calc_cost_COOP_variance_HMH 
GO



CREATE PROCEDURE [dbo].[calc_cost_COOP_variance_HMH] (  
  @projectkey         INT,
  @result             FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: calc_cost_COOP_variance_HMH
**  Desc: Misc item calculation - Cost Variance for Coop Advertising on HMH.
**
**  Auth: SLB
**  Date: July 27, 2016
*******************************************************************************************/

DECLARE
  @v_budget_cost  float,
  @v_actual_cost  float,
  @v_variance float
  
BEGIN

  SET @result = NULL

  EXEC calc_cost_campaign @projectkey,146, @v_budget_cost OUTPUT
  EXEC calc_cost_campaign @projectkey,147, @v_actual_cost OUTPUT						  
	
  SET @v_budget_cost = COALESCE(@v_budget_cost,0)
  SET @v_actual_cost = COALESCE(@v_actual_cost,0)
   
  SET @v_variance = @v_actual_cost - @v_budget_cost
    
  SET @result = @v_variance
  
END

GO



GRANT EXEC ON calc_cost_COOP_variance_HMH TO PUBLIC
GO