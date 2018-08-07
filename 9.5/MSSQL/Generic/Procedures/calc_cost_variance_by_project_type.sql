IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'calc_cost_variance_by_project_type' ) 
     DROP PROCEDURE calc_cost_variance_by_project_type 
GO

CREATE PROCEDURE [dbo].[calc_cost_variance_by_project_type] (  
  @projectkey         INT,
  @budget_firedistkey INT,
  @actual_firedistkey INT,
  @result             FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: calc_cost_variance_by_project_type
**  Desc: Misc item calculation - Cost Variance  based on Campaign budget numbers minus
**        $ summed from Projects and Exhibits by project type.  
**
**  Auth: SLB
**  Date: April 14 2015
**------------------------------------------------------------------------
**  Revised July 27, 2016 -  SLB
**  Change Desc:  Changed Budget to sum directly from Campaign rather than sum Projects which 
**  no longer have budget costs
*******************************************************************************************/

DECLARE
  @v_budget_cost  float,
  @v_actual_cost  float,
  @v_variance float
  
BEGIN

  SET @result = NULL

  EXEC calc_cost_campaign @projectkey,@budget_firedistkey, @v_budget_cost OUTPUT
                                    
  EXEC calc_cost_actual_by_project_type @projectkey, @actual_firedistkey, @v_actual_cost OUTPUT

  SET @v_actual_cost = COALESCE(@v_actual_cost,0)
  
  SET @v_variance = @v_actual_cost - @v_budget_cost
    
  SET @result = @v_variance
  
END


GO


GRANT EXEC ON calc_cost_variance_by_project_type TO PUBLIC
GO
