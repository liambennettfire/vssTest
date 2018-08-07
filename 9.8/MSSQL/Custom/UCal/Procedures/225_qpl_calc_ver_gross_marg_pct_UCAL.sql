if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_gross_marg_pct_UCAL') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_gross_marg_pct_UCAL
GO  

CREATE PROCEDURE dbo.qpl_calc_ver_gross_marg_pct_UCAL (    
  @i_projectkey INT,  
  @i_plstage    INT,  
  @i_plversion  INT,  
  @o_result     FLOAT OUTPUT)  
AS  
  
/******************************************************************************************  
**  Name: qpl_calc_ver_gross_marg_pct_UCAL  
**  Desc: Ucal Version/Gross Margin %.  
**  
**  Auth: slb  
**  Date: October 25,2011  
*******************************************************************************************/  
  
DECLARE  
  @v_gross_margin FLOAT,  
  @v_gross_margin_percent FLOAT,  
  @v_net_sales_dollars FLOAT,  
  @v_bulk_sales_dollars FLOAT,  
  @v_total_sales_dollars FLOAT  
  
BEGIN  
  
  SET @o_result = NULL  
   
  --Version - Net Sales Dollars  
  EXEC qpl_calc_ver_net_sales @i_projectkey, @i_plstage, @i_plversion,  @v_net_sales_dollars OUTPUT   
  
  IF @v_net_sales_dollars IS NULL  
    SET @v_net_sales_dollars = 0  
      
    -- Version - Bulk Sales Dollars  
  EXEC qpl_calc_ver_bulk_sales @i_projectkey, @i_plstage, @i_plversion, @v_bulk_sales_dollars OUTPUT  
  
  IF @v_bulk_sales_dollars IS NULL  
    SET @v_bulk_sales_dollars = 0  
      
  SET @v_total_sales_dollars = @v_net_sales_dollars + @v_bulk_sales_dollars  
    
    -- Version - Gross Margin  
  EXEC qpl_calc_ver_gross_marg_UCAL @i_projectkey, @i_plstage, @i_plversion, @v_gross_margin OUTPUT  
  
  IF @v_gross_margin IS NULL  
    SET @v_gross_margin = 0  
    
  IF @v_total_sales_dollars= 0  
    SET @v_gross_margin_percent = 0  
  ELSE  
    SET @v_gross_margin_percent = @v_gross_margin / @v_total_sales_dollars  
  
  SET @o_result = @v_gross_margin_percent  
    
END  
GO
GRANT EXECUTE ON dbo.qpl_calc_ver_gross_marg_pct_UCAL TO PUBLIC