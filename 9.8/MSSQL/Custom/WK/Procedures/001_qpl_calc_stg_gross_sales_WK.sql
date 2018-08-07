if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_gross_sales_WK') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_gross_sales_WK
GO

CREATE PROCEDURE qpl_calc_stg_gross_sales_WK (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_saleschanneltype  VARCHAR(50),    
  @i_formattype  VARCHAR(50),   
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_gross_sales_WK
**  Desc: This stored procedure gets Gross Sales dollars by sales channel and format grouping.
**        Sales channel is determined by gentext1 string stored on gentables_ext 118.
**        Format is determined by gentext1 string stored on gentables_ext/subgentables_ext 312.
**
**  Auth: Kate W.
**  Date: October 10 2013
*******************************************************************************************/

DECLARE
  @v_actuals_stage  INT,
  @v_grosssales FLOAT,
  @v_count  INT,
  @v_formats_clause	VARCHAR(4000),
  @v_saleschannelcode INT,
  @v_selected_versionkey  INT,
  @v_sqlstring NVARCHAR(4000)
  
BEGIN
  
  SET @o_result = NULL  

  SELECT @v_saleschannelcode = g.datacode 
  FROM gentables_ext ge
    JOIN gentables g ON ge.tableid = g.tableid AND ge.datacode = g.datacode
  WHERE ge.tableid = 118 AND g.deletestatus = 'N' AND ge.gentext1 = @i_saleschanneltype

  IF @@ROWCOUNT <> 1 
  BEGIN
    --Could not find a matching entry, maybe the setup is not done yet - return 0 
    SET @o_result = 0
    RETURN
  END

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

    SET @v_sqlstring = N'SELECT @grosssales = SUM(grosssalesdollars)' +
      'FROM taqplsales_actual a, taqversionformat f ' +
      'WHERE a.taqprojectformatkey = f.taqprojectformatkey' + 
      ' AND f.taqprojectkey = ' + CONVERT(VARCHAR, @i_projectkey) +
      ' AND f.plstagecode = ' + CONVERT(VARCHAR, @i_plstage) +
      ' AND a.saleschannelcode = ' + CONVERT(VARCHAR, @v_saleschannelcode) +
      ' AND (' + @v_formats_clause + ') '

    EXECUTE sp_executesql @v_sqlstring, N'@grosssales FLOAT OUTPUT', @v_grosssales OUTPUT

    SET @o_result = @v_grosssales
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

      -- Version/Gross Sales Units
      EXEC dbo.qpl_calc_ver_gross_sales_WK @i_projectkey, @i_plstage, @v_selected_versionkey, @i_saleschanneltype, @i_formattype, @o_result OUTPUT

  END
   
END
go

GRANT EXEC ON dbo.qpl_calc_stg_gross_sales_WK TO PUBLIC
GO

