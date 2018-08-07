if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc151') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc151
GO
 
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_fgt_dlvry_KAP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_fgt_dlvry_KAP
GO
 
CREATE PROCEDURE qpl_calc_yr_fgt_dlvry_KAP (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_fgt_dlvry_KAP
**  Desc: Kaplan Item 151 - Year/Freight & Delivery.
**
**  Auth: Kate
**  Date: November 5 2010
*******************************************************************************************/

DECLARE
  @v_freightdeliv_amount  FLOAT,
  @v_freightdeliv_percent FLOAT,
  @v_gross_sales FLOAT

BEGIN

  -- First check if amount has been entered for the corresponding chargecode
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 'MISCEXP', 'FREIGHTDELEXP', 0, @o_result OUTPUT
  
  -- Calculate if override amount does not exist
  IF @o_result IS NULL
  BEGIN

    EXEC qpl_calc_yr_gross_sales @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_gross_sales OUTPUT

    IF @v_gross_sales IS NULL
      SET @v_gross_sales = 0
    
    SELECT @v_freightdeliv_percent = v.clientvalue
    FROM gentables g 
      LEFT OUTER JOIN taqversionclientvalues v ON v.clientvaluecode = g.datacode AND 
        v.taqprojectkey = @i_projectkey AND
        v.plstagecode = @i_plstage AND
        v.taqversionkey = @i_plversion
    WHERE g.tableid = 614 AND g.datacode = 4

    IF @v_freightdeliv_percent IS NULL
      SET @v_freightdeliv_percent = 0
      
    SET @v_freightdeliv_amount = (@v_freightdeliv_percent / 100) * @v_gross_sales
    
    SET @o_result = @v_freightdeliv_amount
  END
  
END
GO

GRANT EXEC ON qpl_calc_yr_fgt_dlvry_KAP TO PUBLIC
GO