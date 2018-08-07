if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc150') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc150
GO
 
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_sales_comm_KAP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_sales_comm_KAP
GO

CREATE PROCEDURE qpl_calc_yr_sales_comm_KAP (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_sales_comm_KAP
**  Desc: Kaplan Item 150 - Year/Sales Commission.
**
**  Auth: Kate
**  Date: November 5 2010
*******************************************************************************************/

DECLARE
  @v_salescoms_amount  FLOAT,
  @v_salescoms_percent FLOAT,
  @v_net_sales FLOAT

BEGIN

  -- First check if amount has been entered for the corresponding chargecode
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 'MISCEXP', 'SALESCOMSEXP', 0, @o_result OUTPUT
  
  -- Calculate if override amount does not exist
  IF @o_result IS NULL
  BEGIN

    EXEC qpl_calc_yr_net_sales @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_net_sales OUTPUT

    IF @v_net_sales IS NULL
      SET @v_net_sales = 0
    
    SELECT @v_salescoms_percent = v.clientvalue
    FROM gentables g 
      LEFT OUTER JOIN taqversionclientvalues v ON v.clientvaluecode = g.datacode AND 
        v.taqprojectkey = @i_projectkey AND
        v.plstagecode = @i_plstage AND
        v.taqversionkey = @i_plversion
    WHERE g.tableid = 614 AND g.datacode = 3

    IF @v_salescoms_percent IS NULL
      SET @v_salescoms_percent = 0
      
    SET @v_salescoms_amount = (@v_salescoms_percent / 100) * @v_net_sales
    
    SET @o_result = @v_salescoms_amount
  END
  
END
GO

GRANT EXEC ON qpl_calc_yr_sales_comm_KAP TO PUBLIC
GO