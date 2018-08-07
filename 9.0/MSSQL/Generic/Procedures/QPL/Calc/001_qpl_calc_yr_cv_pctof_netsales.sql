if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_cv_pctof_netsales') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_cv_pctof_netsales
GO


CREATE PROCEDURE [dbo].[qpl_calc_yr_cv_pctof_netsales] (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT,
  @i_clientvalue VARCHAR(50),
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_cv_pctof_netsales

**  Desc: Generic Year calculation which multiples a client value * net sales 

**
**  Auth: SLB
**  Date: 2/22/2011
*******************************************************************************************/
 
DECLARE
  @v_clientvalue_amount  FLOAT,
  @v_clientvalue_percent FLOAT,
  @v_net_sales FLOAT

BEGIN
 -- Get Year Net Sales 
  EXEC qpl_calc_yr_net_sales @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_net_sales OUTPUT

    IF @v_net_sales IS NULL
      SET @v_net_sales = 0
    
  -- Get client value percent
   SELECT @v_clientvalue_percent = v.clientvalue
    FROM gentables g 
      LEFT OUTER JOIN taqversionclientvalues v ON v.clientvaluecode = g.datacode AND 
        v.taqprojectkey = @i_projectkey AND
        v.plstagecode = @i_plstage AND
        v.taqversionkey = @i_plversion
    WHERE g.tableid = 614 AND g.datacode IN (SELECT datacode FROM gentables 
             WHERE tableid = 614 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_clientvalue)

    IF @v_clientvalue_percent IS NULL
      SET @v_clientvalue_percent = 0
      
    SET @v_clientvalue_amount = (@v_clientvalue_percent / 100) * @v_net_sales
    
    SET @o_result = @v_clientvalue_amount
  
END
GO

GRANT EXEC ON qpl_calc_yr_cv_pctof_netsales TO PUBLIC
GO