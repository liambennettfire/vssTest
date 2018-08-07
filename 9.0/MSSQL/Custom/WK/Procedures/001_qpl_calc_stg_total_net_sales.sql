if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_total_net_sales') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_total_net_sales
GO

CREATE PROCEDURE qpl_calc_stg_total_net_sales (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_formattype  VARCHAR(50),   
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_total_net_sales
**  Desc: This stored procedure gets Total Net Sales by format grouping.
**        Format is determined by gentext1 string stored on gentables_ext/subgentables_ext 312.
**
**  Auth: Kate W.
**  Date: October 17 2013
*******************************************************************************************/

DECLARE
  @v_actuals_stage  INT,
  @v_netsales FLOAT,
  @v_count  INT,
  @v_formats_clause	VARCHAR(4000),
  @v_selected_versionkey  INT,
  @v_sqlstring NVARCHAR(4000)
  
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
    -- Get the where clause for media and format based on the @i_formattype parameter
    SET @v_formats_clause = dbo.qpl_calc_get_unit_by_type_clause(@i_formattype)

    SET @v_sqlstring = N'SELECT @netsales = COALESCE(SUM(grosssalesdollars),0) - COALESCE(SUM(returnsalesdollars),0) ' +
      'FROM taqplsales_actual a, taqversionformat f ' +
      'WHERE a.taqprojectformatkey = f.taqprojectformatkey' + 
      ' AND f.taqprojectkey = ' + CONVERT(VARCHAR, @i_projectkey) +
      ' AND f.plstagecode = ' + CONVERT(VARCHAR, @i_plstage) +
      ' AND (' + @v_formats_clause + ') '

    EXECUTE sp_executesql @v_sqlstring, N'@netsales FLOAT OUTPUT', @v_netsales OUTPUT

    SET @o_result = @v_netsales
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

      -- Version/Total Net Sales
      EXEC dbo.qpl_calc_ver_total_net_sales @i_projectkey, @i_plstage, @v_selected_versionkey, @i_formattype, @o_result OUTPUT

  END
   
END
go

GRANT EXEC ON dbo.qpl_calc_stg_total_net_sales TO PUBLIC
GO

