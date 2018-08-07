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
*******************************************************************************************/
DECLARE
  @v_actuals_stage  INT,
  @v_count  INT,
  @v_selected_versionkey  INT

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
	  -- HOW DO WE RETRIEVE BY TAQPROJECTFORMATKEY ??? -- The following select needs to be fixed!! We need to dynamically determine which format 
	  --to use if actuals are requested
      SELECT @o_result = SUM(grosssalesunits) - SUM(returnsalesunits)
      FROM taqplsales_actual
      WHERE taqprojectkey = @i_projectkey
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
