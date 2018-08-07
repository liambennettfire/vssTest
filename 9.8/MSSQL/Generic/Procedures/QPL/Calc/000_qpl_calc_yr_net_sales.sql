if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc045') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc045
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_net_sales') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_net_sales
GO

CREATE PROCEDURE qpl_calc_yr_net_sales (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,  
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_net_sales
**  Desc: P&L Item 45 - Year/Net Sales $.
**
**  Auth: Kate
**  Date: November 20 2009
*******************************************************************************************/

DECLARE
  @v_discountpercent FLOAT,
  @v_format_netsales FLOAT,
  @v_format_salesunits INT,
  @v_format_price FLOAT,
  @v_total_netsales FLOAT

BEGIN

  SET @o_result = NULL

  -- Loop through all sales unit records to calculate Net Sales $ (all sales except Bulk Sales)
  DECLARE salesunit_cur CURSOR FOR  
    SELECT COALESCE(activeprice, 0), COALESCE(discountpercent, 0) / 100, COALESCE(SUM(netsalesunits),0)
    FROM taqversionsalesunit u, taqversionsaleschannel c, taqversionformat f
    WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
        c.taqprojectformatkey = f.taqprojectformatkey AND
        c.taqprojectkey = @i_projectkey AND
        c.plstagecode = @i_plstage AND
        c.taqversionkey = @i_plversion AND 
        u.yearcode = @i_yearcode AND
        c.saleschannelcode NOT IN (SELECT datacode 
                                   FROM gentables
                                   WHERE tableid = 118 AND gen2ind = 1)
    GROUP BY activeprice, discountpercent
    
  OPEN salesunit_cur
  
  FETCH salesunit_cur INTO @v_format_price, @v_discountpercent, @v_format_salesunits

  SET @v_total_netsales = 0
  WHILE (@@FETCH_STATUS=0)
  BEGIN
  
    SET @v_format_netsales = @v_format_price * (1 - @v_discountpercent) * @v_format_salesunits
    
    SET @v_total_netsales = @v_total_netsales + @v_format_netsales
    
    FETCH salesunit_cur INTO @v_format_price, @v_discountpercent, @v_format_salesunits
  END
  
  CLOSE salesunit_cur
  DEALLOCATE salesunit_cur

  SET @o_result = @v_total_netsales
  
END
GO

GRANT EXEC ON qpl_calc_yr_net_sales TO PUBLIC
GO
