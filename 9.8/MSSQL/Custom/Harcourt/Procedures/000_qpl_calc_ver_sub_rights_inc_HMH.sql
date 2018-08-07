if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc019') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc019
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_sub_rights_inc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_sub_rights_inc
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_sub_rights_inc_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_sub_rights_inc_HMH
GO

CREATE PROCEDURE qpl_calc_ver_sub_rights_inc_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_sub_rights_inc_HMH
**  Desc: Houghton Mifflin Item 19 - Version/Subsidiary Rights Income.
**
**  Auth: Kate
**  Date: November 3 2009
*******************************************************************************************/

DECLARE
  @v_subright_total FLOAT,
  @v_grand_total  FLOAT

BEGIN

  SET @o_result = NULL

  -- Loop through all subright year records to calculate the TOTAL Subsidiary Rights Income
  DECLARE subright_cur CURSOR FOR  
    SELECT SUM(y.amount)
    FROM taqversionsubrights s, taqversionsubrightsyear y
    WHERE s.subrightskey = y.subrightskey AND
        s.taqprojectkey = @i_projectkey AND
        s.plstagecode = @i_plstage AND
        s.taqversionkey = @i_plversion
    GROUP BY s.subrightskey, s.authorpercent
    
  OPEN subright_cur
  
  FETCH subright_cur INTO @v_subright_total

  SET @v_grand_total = 0
  WHILE (@@FETCH_STATUS=0)
  BEGIN
      
    SET @v_grand_total = @v_grand_total + @v_subright_total
    
    FETCH subright_cur INTO @v_subright_total
  END
  
  CLOSE subright_cur
  DEALLOCATE subright_cur

  SET @o_result = @v_grand_total
  
END
GO

GRANT EXEC ON qpl_calc_ver_sub_rights_inc_HMH TO PUBLIC
GO
