if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc048') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc048
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_bulk_sales') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_bulk_sales
GO

CREATE PROCEDURE qpl_calc_yr_bulk_sales (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_bulk_sales
**  Desc: P&L Item 48 - Year/Bulk Sales.
**
**  Auth: Kate
**  Date: November 20 2009
*******************************************************************************************/

DECLARE
  @v_discountpercent FLOAT,
  @v_format_bulksales FLOAT,
  @v_format_salesunits INT,
  @v_format_price FLOAT,
  @v_total_bulksales FLOAT

BEGIN

  SET @o_result = NULL

  -- Loop through all sales unit records to calculate Bulk Sales
  DECLARE salesunit_cur CURSOR FOR  
    SELECT COALESCE(activeprice, 0), COALESCE(discountpercent, 0) / 100, SUM(netsalesunits)
    FROM taqversionsalesunit u, taqversionsaleschannel c, taqversionformat f
    WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
        c.taqprojectformatkey = f.taqprojectformatkey AND
        c.taqprojectkey = @i_projectkey AND
        c.plstagecode = @i_plstage AND
        c.taqversionkey = @i_plversion AND
        u.yearcode = @i_yearcode AND
        c.saleschannelcode IN (SELECT datacode 
                               FROM gentables
                               WHERE tableid = 118 AND gen2ind = 1)        
    GROUP BY activeprice, discountpercent
    
  OPEN salesunit_cur
  
  FETCH salesunit_cur INTO @v_format_price, @v_discountpercent, @v_format_salesunits

  SET @v_total_bulksales = 0
  WHILE (@@FETCH_STATUS=0)
  BEGIN
  
    SET @v_format_bulksales = @v_format_price * (1 - @v_discountpercent) * @v_format_salesunits
    
    SET @v_total_bulksales = @v_total_bulksales + @v_format_bulksales
    
    FETCH salesunit_cur INTO @v_format_price, @v_discountpercent, @v_format_salesunits
  END
  
  CLOSE salesunit_cur
  DEALLOCATE salesunit_cur

  SET @o_result = @v_total_bulksales
  
END
GO

GRANT EXEC ON qpl_calc_yr_bulk_sales TO PUBLIC
GO
