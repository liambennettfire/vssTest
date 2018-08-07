if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_postage') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_postage
GO

CREATE PROCEDURE qpl_calc_ver_postage (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_postage_percent  FLOAT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************************
**  Name: qpl_calc_ver_postage
**  Desc: This stored procedure returns the Postage expense calculated as percentage of Print revenue.
**
**  Auth: Kate
**  Date: October 17 2013
******************************************************************************************************/

DECLARE
  @v_total_netsales FLOAT

BEGIN

  SET @o_result = NULL

  -- Version - Total Print Net Sales
  EXEC qpl_calc_ver_total_net_sales @i_projectkey, @i_plstage, @i_plversion, 'OTHER', @v_total_netsales OUTPUT
  
  IF @v_total_netsales IS NULL
    SET @v_total_netsales = 0
    
  SET @o_result = @v_total_netsales * COALESCE(@i_postage_percent,0) / 100
  
END
GO

GRANT EXEC ON qpl_calc_ver_postage TO PUBLIC
GO
