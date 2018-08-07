  
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_gross_print_sales_Discount_Calc_For_Fullfillment_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_gross_print_sales_Discount_Calc_For_Fullfillment_HMH
GO

CREATE PROCEDURE qpl_calc_stg_gross_print_sales_Discount_Calc_For_Fullfillment_HMH (    
  @i_projectkey INT,  
  @i_plstage    INT,  
  @o_result     FLOAT OUTPUT)  
AS  
  
/******************************************************************************************  
**  Name: qpl_calc_stg_gross_print_sales_HMH  
**  Desc: HMH - Stage/Gross Pring Sales $ (per Michelle at HMH, any format other than e-book).  
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
  @v_actuals_stage  INT,  
  @v_count  INT,  
  @v_selected_versionkey  INT  
  
BEGIN  
  
  SET @o_result = NULL  
  
  -- Get the Actuals stage code  
  SELECT @v_count = COUNT(*)  
  FROM gentables  
  WHERE tableid = 562 AND qsicode = 1  
    
  IF @v_count > 0  
    SELECT @v_actuals_stage = datacode  
    FROM gentables  
    WHERE tableid = 562 AND qsicode = 1  
  ELSE  
    SET @v_actuals_stage = 0  
    
  IF @i_plstage = @v_actuals_stage  
    BEGIN  
      SELECT @o_result = SUM(grosssalesdollars)  
      FROM taqplsales_actual  
      WHERE taqprojectkey = @i_projectkey  
    END  
  ELSE  
    BEGIN  
      -- Get the selected versionkey for this stage  
      SELECT @v_selected_versionkey = selectedversionkey  
      FROM taqplstage  
      WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage  
  
      -- If there is no selected version for this stage, return NULL  
      IF @v_selected_versionkey = 0 OR @v_selected_versionkey IS NULL  
        RETURN  
  
      -- Version/Gross Print Sales $  
      EXEC qpl_calc_ver_gross_print_sales_Discount_Calc_For_Fullfillment_HMH @i_projectkey, @i_plstage, @v_selected_versionkey, @o_result OUTPUT  
    END  
    
END  

Go
Grant all on qpl_calc_stg_gross_print_sales_Discount_Calc_For_Fullfillment_HMH to Public