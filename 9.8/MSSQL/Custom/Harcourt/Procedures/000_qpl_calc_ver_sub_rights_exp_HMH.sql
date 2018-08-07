if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc040') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc040
GO
 
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_sub_rights_exp_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_sub_rights_exp_HMH
GO

CREATE PROCEDURE qpl_calc_ver_sub_rights_exp_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_sub_rights_exp_HMH
**  Desc: Houghton Mifflin Item 40 - Version/Subsidiary Rights Expense.
**
**  Auth: Kate
**  Date: November 10 2009
*******************************************************************************************/

DECLARE
  @v_subright_amount FLOAT,
  @v_total_amount  FLOAT

BEGIN

  SET @o_result = NULL

  -- Loop through all subright year records to calculate the Author portion of the Subright Total
  DECLARE subright_cur CURSOR FOR  
    SELECT (CONVERT(FLOAT, s.authorpercent) / 100 ) * (SUM(y.amount)) authoramount
    FROM taqversionsubrights s, taqversionsubrightsyear y
    WHERE s.subrightskey = y.subrightskey AND
        s.taqprojectkey = @i_projectkey AND
        s.plstagecode = @i_plstage AND
        s.taqversionkey = @i_plversion
    GROUP BY s.subrightskey, s.authorpercent
    
  OPEN subright_cur
  
  FETCH subright_cur INTO @v_subright_amount

  SET @v_total_amount = 0
  WHILE (@@FETCH_STATUS=0)
  BEGIN
      
    SET @v_total_amount = @v_total_amount + @v_subright_amount
    
    FETCH subright_cur INTO @v_subright_amount
  END
  
  CLOSE subright_cur
  DEALLOCATE subright_cur

  SET @o_result = @v_total_amount
  
END
GO

GRANT EXEC ON qpl_calc_ver_sub_rights_exp_HMH TO PUBLIC
GO
