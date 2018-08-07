if exists (select * from dbo.sysobjects where id = object_id(N'dbo.calc_total_cost_variance') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.calc_total_cost_variance
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE calc_total_cost_variance (  
  @projectkey         INT,
  @result             FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: calc_total_cost_variance
**  Desc: Misc item calculation - Total Cost Variance.
**
**  Auth: Kate
**  Date: March 4 2009
*******************************************************************************************/

DECLARE
  @v_budget_cost  float,
  @v_actual_cost  float,
  @v_variance float
  
BEGIN

  EXEC calc_total_cost_budget @projectkey, @v_budget_cost OUTPUT
                    
  EXEC calc_total_cost_actual @projectkey, @v_actual_cost OUTPUT
  
  SET @v_variance = @v_actual_cost - @v_budget_cost
    
  SET @result = @v_variance
  
END
GO

GRANT EXEC ON calc_total_cost_variance TO PUBLIC
GO
