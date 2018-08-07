IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'calc_total_cost_variance_HMH' ) 
     DROP PROCEDURE calc_total_cost_variance_HMH 
GO


CREATE PROCEDURE [dbo].[calc_total_cost_variance_HMH] (
  @projectkey INT,
  @result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: calc_total_cost_variance_HMH
**  Desc: Misc item calculation - Total Variance 
**        This uses the total budget for related projects and the total actual costs for 
**        related projects to create the variance.  This differs from the calc_total_variance
**        procedure which uses the budget for current project, not total budget for related 
**        projects   
**
**  Auth: Susan
**  Date: July 27, 2016
********************************************************************************************
**    Change History
********************************************************************************************
**    Date:    Author:          Description:
**    --------  --------        -----------------------------------------------------------
********************************************************************************************/
  
DECLARE
  @v_budget_cost  float,
  @v_actual_cost  float,
  @v_variance float
  
BEGIN

  EXEC calc_total_cost_budget_HMH @projectkey, @v_budget_cost OUTPUT
                    
  EXEC calc_total_cost_actual @projectkey, @v_actual_cost OUTPUT
  
  SET @v_variance = @v_actual_cost - @v_budget_cost
    
  SET @result = @v_variance
  
END

GO


GRANT EXEC ON calc_total_cost_variance_HMH TO PUBLIC
GO
