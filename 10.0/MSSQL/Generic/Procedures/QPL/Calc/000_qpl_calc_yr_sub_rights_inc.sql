if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc047') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc047
GO
 
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_sub_rights_inc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_sub_rights_inc
GO

CREATE PROCEDURE qpl_calc_yr_sub_rights_inc (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_sub_rights_inc
**  Desc: P&L Item 47 - Year/Subsidiary Rights Income.
**
**  Auth: Kate
**  Date: November 20 2009
*******************************************************************************************/

DECLARE
  @v_subright_pubamount FLOAT,
  @v_total_pubacount  FLOAT

BEGIN

  SET @o_result = NULL

  -- Loop through all subright year records to calculate the Publisher portion of the Subright Total
  DECLARE subright_pubamt_cur CURSOR FOR  
    SELECT (CONVERT(FLOAT, (100 - s.authorpercent)) / 100 ) * (SUM(COALESCE(y.amount,0))) publisheramount
    FROM taqversionsubrights s, taqversionsubrightsyear y
    WHERE s.subrightskey = y.subrightskey AND
        s.taqprojectkey = @i_projectkey AND
        s.plstagecode = @i_plstage AND
        s.taqversionkey = @i_plversion AND
        y.yearcode = @i_yearcode
    GROUP BY s.subrightskey, s.authorpercent
    
  OPEN subright_pubamt_cur
  
  FETCH subright_pubamt_cur INTO @v_subright_pubamount

  SET @v_total_pubacount = 0
  WHILE (@@FETCH_STATUS=0)
  BEGIN
      
    SET @v_total_pubacount = @v_total_pubacount + @v_subright_pubamount
    
    FETCH subright_pubamt_cur INTO @v_subright_pubamount
  END
  
  CLOSE subright_pubamt_cur
  DEALLOCATE subright_pubamt_cur

  SET @o_result = @v_total_pubacount
  
END
GO

GRANT EXEC ON qpl_calc_yr_sub_rights_inc TO PUBLIC
GO
