if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_latest_stg_gross_marg_pct') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_latest_stg_gross_marg_pct
GO

CREATE PROCEDURE qpl_calc_latest_stg_gross_marg_pct (  
  @i_projectkey INT,
  @o_result     VARCHAR(255) OUTPUT)
AS

/********************************************************************************************************
**  Name: qpl_calc_latest_stg_gross_marg_pct
**  Desc: Returns the Gross Margin % from the latest stage on the project which has a selected version.
**
**  Auth: Kate
**  Date: January 24 2014
********************************************************************************************************/

DECLARE
  @v_count INT,
  @v_gross_margin_pct DECIMAL(9,4),
  @v_latest_stage	INT,
  @v_return_value	VARCHAR(255)
  
BEGIN

  SELECT @v_count = COUNT(*)
  FROM taqplstage
  WHERE taqprojectkey = @i_projectkey AND selectedversionkey > 0

  IF @v_count > 0
    SELECT @v_latest_stage = MAX(plstagecode) 
    FROM taqplstage 
    WHERE taqprojectkey = @i_projectkey AND selectedversionkey > 0
  ELSE
    SET @v_latest_stage = 0
  
  -- Stage - Gross Margin Percent
  EXEC qpl_calc_stg_gross_marg_pct @i_projectkey, @v_latest_stage, @v_gross_margin_pct OUTPUT

  IF @v_gross_margin_pct IS NULL
    SET @v_gross_margin_pct = 0

  SET @v_return_value = CONVERT(VARCHAR, ROUND(CONVERT(MONEY, @v_gross_margin_pct * 100), 2)) + '%'

  --PRINT @v_return_value

  SET @o_result = @v_return_value
  
END
GO

GRANT EXEC ON qpl_calc_latest_stg_gross_marg_pct TO PUBLIC
GO