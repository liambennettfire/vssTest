if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_bulk_sales') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_bulk_sales
GO


CREATE PROCEDURE dbo.qpl_calc_ver_bulk_sales (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_bulk_sales
**  Desc: Island Press Item 20 - Version/Bulk Sales.
**
**  Auth: Kate
**  Date: January 30 2008
*******************************************************************************************/
/**  Change History
**********************************************************************************************
**  Date:        Author:       Description:
**  ----------   -----------   ---------------------------------------------------------------
**  4/12/17      Tolga	        SUM(netsalesunits) missing Coalesce 
**********************************************************************************************/

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
    SELECT COALESCE(activeprice, 0), COALESCE(discountpercent, 0) / 100, COALESCE(SUM(netsalesunits),0)
    FROM taqversionsalesunit u, taqversionsaleschannel c, taqversionformat f
    WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
        c.taqprojectformatkey = f.taqprojectformatkey AND
        c.taqprojectkey = @i_projectkey AND
        c.plstagecode = @i_plstage AND
        c.taqversionkey = @i_plversion AND 
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

	--Print 'Format Bulk sales' + Cast(@v_format_bulksales as varchar(100))
    
    SET @v_total_bulksales = @v_total_bulksales + @v_format_bulksales

	--Print 'Total Bulk Sales' + Cast(@v_total_bulksales as varchar(100))
    
    FETCH salesunit_cur INTO @v_format_price, @v_discountpercent, @v_format_salesunits
  END
  
  CLOSE salesunit_cur
  DEALLOCATE salesunit_cur

  SET @o_result = @v_total_bulksales
  
END
GO

GRANT EXECUTE ON dbo.qpl_calc_ver_bulk_sales TO PUBLIC 
