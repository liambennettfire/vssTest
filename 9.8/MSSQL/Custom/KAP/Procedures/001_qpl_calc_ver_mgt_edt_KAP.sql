if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc144') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc144
GO
 
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_mgt_edt_KAP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_mgt_edt_KAP
GO

CREATE PROCEDURE qpl_calc_ver_mgt_edt_KAP (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_mgt_edt_KAP
**  Desc: Kaplan Item 144 - Version/Management/Editorial.
**
**  Auth: Kate
**  Date: November 5 2010
*******************************************************************************************/

DECLARE
  @v_yearcode INT,
  @v_yeartotal  FLOAT,
  @v_total  FLOAT

BEGIN

  DECLARE year_cur CURSOR FOR  
    SELECT DISTINCT yearcode 
    FROM taqversionformatyear 
    WHERE taqprojectkey = @i_projectkey
    
  OPEN year_cur
  
  FETCH year_cur INTO @v_yearcode

  SET @v_total = 0
  WHILE (@@FETCH_STATUS=0)
  BEGIN

    EXEC qpl_calc_yr_mgt_edt_KAP @i_projectkey, @i_plstage, @i_plversion, @v_yearcode, @v_yeartotal OUTPUT
    
    IF @v_yeartotal IS NULL
      SET @v_yeartotal = 0
      
    SET @v_total = @v_total + @v_yeartotal
  
    FETCH year_cur INTO @v_yearcode
  END
  
  CLOSE year_cur
  DEALLOCATE year_cur
  
  SET @o_result = @v_total
 
END
GO

GRANT EXEC ON qpl_calc_ver_mgt_edt_KAP TO PUBLIC
GO