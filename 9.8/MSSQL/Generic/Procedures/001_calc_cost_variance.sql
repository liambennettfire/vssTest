if exists (select * from dbo.sysobjects where id = object_id(N'dbo.calc_cost_variance') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.calc_cost_variance
GO

CREATE PROCEDURE calc_cost_variance (  
  @projectkey         INT,
  @budget_firedistkey INT,
  @actual_firedistkey INT,
  @result             FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: calc_cost_variance
**  Desc: Misc item calculation - Cost Variance of given type.
**
**  Auth: Kate
**  Date: March 4 2009
*******************************************************************************************/

DECLARE
  @v_budget_cost  float,
  @v_actual_cost  float,
  @v_variance float
  
BEGIN

  SET @result = NULL

  SELECT @v_budget_cost = COALESCE(floatvalue,0)
  FROM taqprojectmisc
  WHERE taqprojectkey = @projectkey AND
      misckey IN (SELECT misckey FROM bookmiscitems
                  WHERE firedistkey = @budget_firedistkey)
                  
  EXEC calc_cost_actual @projectkey, @actual_firedistkey, @v_actual_cost OUTPUT
  
  SET @v_actual_cost = COALESCE(@v_actual_cost,0)
  
  SET @v_variance = @v_actual_cost - @v_budget_cost
    
  SET @result = @v_variance
  
END
GO

GRANT EXEC ON calc_cost_variance TO PUBLIC
GO
