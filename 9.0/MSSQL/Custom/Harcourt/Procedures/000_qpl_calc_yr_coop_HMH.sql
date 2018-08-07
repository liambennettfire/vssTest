if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc063') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc063
GO
 
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_coop_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_coop_HMH
GO

CREATE PROCEDURE qpl_calc_yr_coop_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_coop_HMH
**  Desc: Houghton Mifflin Item 63 - Year/Coop.
**
**  Auth: Kate
**  Date: December 16 2009
*******************************************************************************************/

DECLARE
  @v_coop_amount  FLOAT,
  @v_coop_percent FLOAT,
  @v_net_sales FLOAT

BEGIN

  SET @o_result = NULL

  EXEC qpl_calc_yr_net_sales @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_net_sales OUTPUT

  IF @v_net_sales IS NULL
    SET @v_net_sales = 0
  
  SELECT @v_coop_percent = v.clientvalue
  FROM gentables g 
    LEFT OUTER JOIN taqversionclientvalues v ON v.clientvaluecode = g.datacode AND 
      v.taqprojectkey = @i_projectkey AND
      v.plstagecode = @i_plstage AND
      v.taqversionkey = @i_plversion
  WHERE g.tableid = 614 AND g.datacode = 2

  IF @v_coop_percent IS NULL
    SET @v_coop_percent = 0
    
  SET @v_coop_amount = (@v_coop_percent / 100) * @v_net_sales
  
  SET @o_result = @v_coop_amount
  
END
GO

GRANT EXEC ON qpl_calc_yr_coop_HMH TO PUBLIC
GO
