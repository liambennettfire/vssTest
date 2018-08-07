if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_net_unt_by_type') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_net_unt_by_type
GO

CREATE PROCEDURE dbo.qpl_calc_stg_net_unt_by_type (  
  @i_projectkey INT,
  @i_plstage    INT,
  --@i_plversion	INT,
  @i_formattype  VARCHAR(50),    
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_net_unt_by_type
**  Desc: Generic Routine that allows the client to get net units by "type".  This type is 
**        determined by the summary item code stored on the format subgentable.  If no type
**        exists on the format subgentable, use the default summary item type on the media    
**        gentable.  If neither exists, assume 'OTHER'
**        - Stage/Net Units - By Format Type.
**
**  Auth: TT
**  Date: March 09 2012

Select * FROM taqplsales_actual

Select * FROM taqversionformat


*******************************************************************************************/
BEGIN

DECLARE
  @v_actuals_stage  INT,
  @v_count  INT,
  @v_selected_versionkey  INT,
  @v_net_units  INT


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

		DECLARE 
		@v_built_clause	varchar(2000),
		@SQLString_var NVARCHAR(4000),
		@v_whereclause NVARCHAR(4000),
		@SQLparams_var NVARCHAR(4000)

		SET @v_built_clause = ''

		-- Now get the where clause for media and format based on the @i_formattype parameter
		Select @v_built_clause = dbo.qpl_calc_get_unit_by_type_clause(@i_formattype)

		SET @v_whereclause = 'a.taqprojectkey = ' +  convert(varchar,@i_projectkey)  + ' AND tvf.plstagecode = ' + convert(varchar,@i_plstage) 
		  +  ' AND (' + @v_built_clause + ')'


		SET @SQLString_var = N'SELECT @netunits = SUM(grosssalesunits) - SUM(returnsalesunits) FROM taqplsales_actual a JOIN taqversionformat tvf on a.taqprojectformatkey = tvf.taqprojectformatkey' +
						   N' WHERE ' + @v_whereclause

		set @SQLparams_var = N'@netunits INT OUTPUT' 
		EXECUTE sp_executesql @SQLString_var, @SQLparams_var, @v_net_units OUTPUT

		SET @o_result = @v_net_units

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

      -- Version/Net Sales Units
      EXEC dbo.qpl_calc_ver_net_unt_by_type @i_projectkey, @i_plstage, @v_selected_versionkey, @i_formattype, @o_result OUTPUT
    END
  
END
GO
GRANT EXEC ON dbo.qpl_calc_stg_net_unt_by_type TO PUBLIC
GO
