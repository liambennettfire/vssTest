if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_gross_print_sales_Discount_Calc_For_Fullfillment_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_gross_print_sales_Discount_Calc_For_Fullfillment_HMH
GO
  


CREATE PROCEDURE qpl_calc_yr_gross_print_sales_Discount_Calc_For_Fullfillment_HMH (    
  @i_projectkey INT,  
  @i_plstage    INT,  
  @i_plversion INT,    
  @i_yearcode   INT,  
  @o_result     FLOAT OUTPUT)  
AS  
  
/******************************************************************************************  
**  Name: qpl_calc_yr_gross_print_sales_Discount_Calc_For_Fullfillment_HMH  
**  Desc: HMH - Year/Gross Print Sales $ (per Michelle at HMH, any format other than e-book).  
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
  @v_format_grosssales FLOAT,  
  @v_format_salesunits INT,  
  @v_format_price FLOAT,  
  @v_total_grosssales FLOAT,
  @v_Discount Decimal(19,2)  
  
BEGIN  
  
  SET @o_result = NULL  
  
  -- Loop through all sales unit records to calculate Gross Print Sales $  
  DECLARE salesunit_cur CURSOR FOR    
    SELECT COALESCE(f.activeprice, 0), SUM(u.grosssalesunits),c.discountpercent   
    FROM taqversionsalesunit u, taqversionsaleschannel c, taqversionformat f  
    WHERE u.taqversionsaleskey = c.taqversionsaleskey AND  
        c.taqprojectformatkey = f.taqprojectformatkey AND  
        c.taqprojectkey = @i_projectkey AND  
        c.plstagecode = @i_plstage AND  
        c.taqversionkey = @i_plversion AND   
        u.yearcode = @i_yearcode AND  
        f.mediatypecode <> 14  --not e-book  
    GROUP BY f.taqprojectformatkey, f.activeprice,c.discountpercent    
      
  OPEN salesunit_cur  
    
  FETCH salesunit_cur INTO @v_format_price, @v_format_salesunits ,@v_Discount 
  
  SET @v_total_grosssales = 0  
  WHILE (@@FETCH_STATUS=0)  
  BEGIN  
    
    SET @v_Discount=(@v_Discount  / 100)
	
	SET @v_format_grosssales = @v_format_price * @v_format_salesunits * (1-@v_Discount)   
      
    SET @v_total_grosssales = @v_total_grosssales + @v_format_grosssales  
      
    FETCH salesunit_cur INTO @v_format_price, @v_format_salesunits,@v_Discount  
  END  
    
  CLOSE salesunit_cur  
  DEALLOCATE salesunit_cur  
  
  SET @o_result = @v_total_grosssales  
    
END  

Go
Grant All on qpl_calc_yr_gross_print_sales_Discount_Calc_For_Fullfillment_HMH to Public