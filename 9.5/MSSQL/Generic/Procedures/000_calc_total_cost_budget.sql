if exists (select * from dbo.sysobjects where id = object_id(N'dbo.calc_total_cost_budget') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.calc_total_cost_budget
GO

CREATE PROCEDURE calc_total_cost_budget (
  @projectkey INT,
  @result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: calc_total_cost_budget
**  Desc: Misc item calculation - Total Budget.
**
**  Auth: Kate
**  Date: March 3 2009
*******************************************************************************************/
  
BEGIN

  SELECT @result = COALESCE(SUM(floatvalue),0)
  FROM taqprojectmisc
  WHERE taqprojectkey = @projectkey AND
      misckey IN (SELECT misckey 
                  FROM bookmiscitems 
                  WHERE firedistkey IN (57,58,59,60,61,62,63,76,77,78,79,80))
  
END
GO

GRANT EXEC ON calc_total_cost_budget TO PUBLIC
GO
