if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc138') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc138
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_gross_sales') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_gross_sales
GO

CREATE PROCEDURE qpl_calc_ver_gross_sales (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,  
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_gross_sales
**  Desc: P&L Item 138 - Version/Gross Sales $.
**
**  Auth: Kate
**  Date: November 5 2010
*******************************************************************************************/

DECLARE
  @v_format_grosssales FLOAT,
  @v_format_salesunits INT,
  @v_format_price FLOAT,
  @v_total_grosssales FLOAT

BEGIN

  SET @o_result = NULL

  -- Loop through all sales unit records to calculate Gross Sales $ for this Version
  DECLARE salesunit_cur CURSOR FOR  
    SELECT COALESCE(f.activeprice, 0), SUM(u.grosssalesunits)
    FROM taqversionsalesunit u, taqversionsaleschannel c, taqversionformat f
    WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
        c.taqprojectformatkey = f.taqprojectformatkey AND
        c.taqprojectkey = @i_projectkey AND
        c.plstagecode = @i_plstage AND
        c.taqversionkey = @i_plversion
    GROUP BY f.taqprojectformatkey, f.activeprice
    
  OPEN salesunit_cur
  
  FETCH salesunit_cur INTO @v_format_price, @v_format_salesunits

  SET @v_total_grosssales = 0
  WHILE (@@FETCH_STATUS=0)
  BEGIN
  
    SET @v_format_grosssales = @v_format_price * @v_format_salesunits
    
    SET @v_total_grosssales = @v_total_grosssales + @v_format_grosssales
    
    FETCH salesunit_cur INTO @v_format_price, @v_format_salesunits
  END
  
  CLOSE salesunit_cur
  DEALLOCATE salesunit_cur

  SET @o_result = @v_total_grosssales
  
END
GO

GRANT EXEC ON qpl_calc_ver_gross_sales TO PUBLIC
GO
