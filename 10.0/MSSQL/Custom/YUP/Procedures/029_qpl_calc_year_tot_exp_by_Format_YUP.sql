IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_year_tot_exp_by_Format_YUP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_year_tot_exp_by_Format_YUP]
GO

CREATE PROCEDURE qpl_calc_year_tot_exp_by_Format_YUP (                    

  @i_projectkey INT,                  

  @i_plstage    INT,                  

  @i_plversion  INT,

  @i_yearcode	INT,  

  @i_formattype  VARCHAR(50),                  

  @o_result     FLOAT OUTPUT)                  

AS                  

                  

/******************************************************************************************                  

**  Name: qpl_calc_year_tot_exp_by_Format_YUP                  

**  Desc: P&L Item 28 - Version/TOTAL Expenses.                  

**                  

**  Auth: Jason                  

**  Date: May 1 2014                  

*******************************************************************************************    
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:     Description:
**    -------- --------    -------------------------------------------
**   01-26-2016
**   Jason Donovan
** Year Plant Cost and PP&B cost were using the wrong 
** procedure for calculation, needed to replace them with qpl_calc_Production_Expense_year_by_format_YUP
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

                    

  -- Year - Plant Cost         

        

  EXEC qpl_calc_Production_Expense_year_by_format_YUP @i_projectkey, @i_plstage, @i_plversion,@i_yearcode, @i_formattype, 'PRODEXP', 'PLANT', 0, @v_Plant_Cost OUTPUT  

                  

  IF @v_Plant_Cost IS NULL                  

    SET @v_Plant_Cost = 0                      

                    

 -- Year - PP&B Cost    

               

  EXEC qpl_calc_Production_Expense_year_by_format_YUP @i_projectkey, @i_plstage, @i_plversion,@i_yearcode, @i_formattype, 'PRODEXP', 'PPB', 0, @v_PPB_Cost OUTPUT  

                  

  IF @v_PPB_Cost IS NULL                  

    SET @v_PPB_Cost = 0                       

                    

   -- year - Subsidy 

                    

  EXEC qpl_calc_year_by_format_YUP @i_projectkey, @i_plstage, @i_plversion,@i_yearcode, @i_formattype, 'MISCINC', 'PRODSUB', 0, @v_Subsidy OUTPUT  

                  

  IF @v_Subsidy IS NULL                  

    SET @v_Subsidy = 0                   

                    

  -- Year - Royalty Expense     

          

  EXEC qpl_calc_yr_roy_exp @i_projectkey, @i_plstage, @i_plversion,@i_yearcode,0, @v_Royalty_Expense OUTPUT      

              

  IF @v_Royalty_Expense IS NULL                  

    SET @v_Royalty_Expense = 0                      

                      

  -- Version - Freight In             

      

  EXEC qpl_calc_yr_cv_pct_of_netsales_by_format_YUP  @i_projectkey, @i_plstage, @i_plversion,@i_yearcode, @i_formattype, 1, @v_Freight_In OUTPUT                

                       

  IF @v_Freight_In IS NULL                  

    SET @v_Freight_In = 0     

             

                  

  SET @v_total_expenses = @v_Plant_Cost + @v_PPB_Cost + @v_Subsidy + @v_Royalty_Expense + @v_Freight_In                   

                      

  SET @o_result = @v_total_expenses                  

                    

END   

GO
GRANT ALL ON qpl_calc_year_tot_exp_by_Format_YUP TO PUBLIC  