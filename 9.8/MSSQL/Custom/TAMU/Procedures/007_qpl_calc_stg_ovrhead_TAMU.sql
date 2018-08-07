if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc164') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc164
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_ovrhead_TAMU') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_ovrhead_TAMU
GO


CREATE PROCEDURE qpl_calc_stg_ovrhead_TAMU (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_ovrhead_TAMU
**  Desc: Texas A&M Item 164 - Stage/$ to Overhead.
**
**  Auth: Kate
**  Date: January 21 2011
*******************************************************************************************/

DECLARE
  @v_count	INT,
  @v_dollar_to_overhead FLOAT,
  @v_gross_margin FLOAT,
  @v_percent_to_series  FLOAT,
  @v_selected_versionkey  INT

BEGIN

  SET @o_result = NULL
  
  -- Get the selected versionkey for this stage
  SELECT @v_selected_versionkey = selectedversionkey
  FROM taqplstage
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage

  -- If there is no selected version for this stage, return NULL
  IF @v_selected_versionkey = 0 OR @v_selected_versionkey IS NULL
    RETURN
    
  -- Get the % to Series for the selected version on this stage
  SELECT @v_count = COUNT(*)
  FROM taqversionclientvalues 
  WHERE taqprojectkey = @i_projectkey AND 
      plstagecode = @i_plstage AND
      taqversionkey = @v_selected_versionkey AND
      clientvaluecode = 1 --% to Series
  
  SET @v_percent_to_series = 0
  IF @v_count > 0
    SELECT @v_percent_to_series = clientvalue 
    FROM taqversionclientvalues
    WHERE taqprojectkey = @i_projectkey AND 
        plstagecode = @i_plstage AND
        taqversionkey = @v_selected_versionkey AND
        clientvaluecode = 1
        
  -- Stage - Gross Margin
  EXEC qpl_calc_stg_gross_marg_TAMU @i_projectkey, @i_plstage, @v_gross_margin OUTPUT

  IF @v_gross_margin IS NULL
    SET @v_gross_margin = 0
    
  SET @v_dollar_to_overhead = (100 - @v_percent_to_series) * @v_gross_margin / 100

  SET @o_result = @v_dollar_to_overhead
  
END
GO

GRANT EXEC ON qpl_calc_stg_ovrhead_TAMU TO PUBLIC
GO
