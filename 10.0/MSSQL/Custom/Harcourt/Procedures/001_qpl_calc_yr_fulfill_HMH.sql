if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc054') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc054
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_fulfill') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_fulfill
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_fulfill_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_fulfill_HMH
GO

CREATE PROCEDURE qpl_calc_yr_fulfill_HMH (    
  @i_projectkey INT,  
  @i_plstage    INT,  
  @i_plversion  INT,  
  @i_yearcode   INT,  
  @o_result     FLOAT OUTPUT)  
AS  
  
/******************************************************************************************  
**  Name: qpl_calc_yr_fulfill_HMH  
**  Desc: HMH - Year/Fulfillment Costs (% of Gross Print sales).  
**  
**  Auth: Kate  
**  Date: March 10 2014  

**  Auth Revised: Jason September 17 2014
**  Case # 29130 
**  Per Michelle Vu
**  Please ignore previous responses and use this one (with the assumption that sales = all formats that is not an ebook).
**  (Price * sales units * (1 - discount)) * fulfillment %

**  Example, taqprojectkey = 23117409 - database HMH_801 on MontyQC:
**  30 * 52,000 * (1-50%) = 780,000 * 3% = 23,400  
*******************************************************************************************/  
  
DECLARE  
  @v_count INT,    
  @v_fulfillment_costs FLOAT,  
  @v_fulfillment_percent FLOAT,  
  @v_gross_print_sales FLOAT  
  
BEGIN  
  
  SET @o_result = NULL  
    
  -- Get Fulfillment Percent from client defaults  
  SELECT @v_count = COUNT(*)  
  FROM clientdefaults  
  WHERE clientdefaultid = 39  
    
  IF @v_count > 0  
    SELECT @v_fulfillment_percent = clientdefaultvalue  
    FROM clientdefaults  
    WHERE clientdefaultid = 39  
    
  IF @v_fulfillment_percent IS NULL  
    SET @v_fulfillment_percent = 0    
           
  -- Year - Gross Print Sales  
  EXEC qpl_calc_yr_gross_print_sales_Discount_Calc_For_Fullfillment_HMH @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_gross_print_sales OUTPUT  
    
  IF @v_gross_print_sales IS NULL  
    SET @v_gross_print_sales = 0  
    
  SET @v_fulfillment_costs = @v_gross_print_sales * @v_fulfillment_percent  
  SET @o_result = @v_fulfillment_costs  
    
END  

Go
Grant all on qpl_calc_yr_fulfill_HMH to public