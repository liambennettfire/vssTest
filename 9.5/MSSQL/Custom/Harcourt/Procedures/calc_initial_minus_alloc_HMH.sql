IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'calc_initial_minus_alloc_HMH' ) 
     DROP PROCEDURE calc_initial_minus_alloc_HMH 
GO


CREATE PROCEDURE [dbo].[calc_initial_minus_alloc_HMH] (
  @projectkey INT,
  @result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: calc_initial_minus_alloc_HMH
**  Desc: Misc item calculation - Initial Minus Variance 
**        This subtracts the total campaign allocated from the initial campsign budget
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
  @v_actual_cost  float
  
BEGIN

  SET @result = 0
  SET @v_budget_cost = 0
  SET @v_actual_cost = 0
   
  SELECT @v_budget_cost = COALESCE(floatvalue,0)
		  FROM taqprojectmisc
		  WHERE taqprojectkey = @projectkey AND
			  misckey IN (SELECT misckey 
						  FROM bookmiscitems 
						  WHERE firedistkey IN (135))
                    
  EXEC calc_total_cost_actual @projectkey, @v_actual_cost OUTPUT
  
  SET @result = @v_actual_cost - @v_budget_cost
   
  
END

GO


GRANT EXEC ON calc_initial_minus_alloc_HMH TO PUBLIC
GO
