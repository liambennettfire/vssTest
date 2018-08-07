IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_ver_tot_exp_by_Format_YUP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_ver_tot_exp_by_Format_YUP]
GO                

CREATE PROCEDURE qpl_calc_ver_tot_exp_by_Format_YUP (                  

  @i_projectkey INT,                

  @i_plstage    INT,                

  @i_plversion  INT,

  @i_formattype  VARCHAR(50),                

  @o_result     FLOAT OUTPUT)                

AS                

                

/******************************************************************************************                

**  Name: qpl_calc_ver_tot_exp                

**  Desc: P&L Item 28 - Version/TOTAL Expenses.                

**                

**  Auth: Jason                

**  Date: May 1 2014                

*******************************************************************************************/   


/*
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:     Description:
**    -------- --------    -------------------------------------------
**   01-26-2016
**   Jason Donovan
** Version Plant Cost and PP&B cost were using the wrong 
** procedure for calculation, needed to replace them with qpl_calc_Production_Expense_version_by_format_YUP
*******************************************************************************/             

DECLARE          

  @v_Plant_Cost Float,    

  @v_PPB_Cost Float,  

  @v_Subsidy Float,  

  @v_Royalty_Expense Float,  

  @v_Freight_In FLOAT,                

  @v_total_expenses FLOAT       

                   

                  

BEGIN                  

                  

  SET @v_total_expenses = 0                  

  SET @o_result = NULL     

    

  BEGIN  

      -- If 0 is passed in for the version Get the selected versionkey for this stage  

      If @i_plversion=0  

  SELECT @i_plversion = selectedversionkey  

  FROM taqplstage  

  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage  

  END               

                    

  -- Version - Plant Cost                  

  EXEC qpl_calc_Production_Expense_version_by_format_YUP @i_projectkey, @i_plstage, @i_plversion, @i_formattype, 'PRODEXP', 'PLANT', 0, @v_Plant_Cost OUTPUT  

                  

  IF @v_Plant_Cost IS NULL                  

    SET @v_Plant_Cost = 0                      

                    

 -- Version - PP&B Cost                  

  EXEC qpl_calc_Production_Expense_version_by_format_YUP @i_projectkey, @i_plstage, @i_plversion, @i_formattype, 'PRODEXP', 'PPB', 0, @v_PPB_Cost OUTPUT  

                  

  IF @v_PPB_Cost IS NULL                  

    SET @v_PPB_Cost = 0                       

                    

   -- Version - Subsidy                 

  EXEC qpl_calc_version_by_format_YUP @i_projectkey, @i_plstage, @i_plversion, @i_formattype, 'MISCINC', 'PRODSUB', 1, @v_Subsidy OUTPUT  

                  

  IF @v_Subsidy IS NULL                  

    SET @v_Subsidy = 0                   

                    

  -- Version - Royalty Expense     

  --EXEC qpl_calc_ver_roy_exp @i_projectkey, @i_plstage, @i_plversion,0, @v_Royalty_Expense OUTPUT              

  EXEC qpl_calc_ver_roy_exp_By_Format_YUP @i_projectkey, @i_plstage, @i_plversion,@i_formattype,0, @v_Royalty_Expense OUTPUT      

              

  IF @v_Royalty_Expense IS NULL                  

    SET @v_Royalty_Expense = 0                      

                      

  -- Version - Freight In                   

  EXEC qpl_calc_ver_cv_pct_of_netsales_by_format_YUP  @i_projectkey, @i_plstage, @i_plversion, @i_formattype, 1, @v_Freight_In OUTPUT                

                       

  IF @v_Freight_In IS NULL                  

    SET @v_Freight_In = 0     

             

                  

  SET @v_total_expenses = (@v_Plant_Cost + @v_PPB_Cost +   @v_Royalty_Expense + @v_Freight_In) - @v_Subsidy                  

                      

  SET @o_result = @v_total_expenses                  

                    

END    




Go
Grant all on qpl_calc_ver_tot_exp_by_Format_YUP to Public