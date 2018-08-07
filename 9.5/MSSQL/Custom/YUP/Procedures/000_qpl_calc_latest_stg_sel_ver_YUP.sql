if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_latest_stg_sel_ver') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_latest_stg_sel_ver
GO

CREATE PROCEDURE qpl_calc_latest_stg_sel_ver (  
  @i_projectkey INT,
  @o_result     VARCHAR(255) OUTPUT)
AS

/********************************************************************************************************
**  Name: qpl_calc_latest_stg_sel_ver
**  Desc: Returns the description of the latest stage on the project which has a selected version.
**
**  Auth: Kate
**  Date: January 24 2014
********************************************************************************************************/

DECLARE
  @v_count INT,
  @v_latest_stage	INT,
  @v_stage_desc VARCHAR(255)
  
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
  
  IF @v_latest_stage > 0
    SELECT @v_stage_desc = datadesc
    FROM gentables
    WHERE tableid = 562 AND datacode = @v_latest_stage
  ELSE
    SET @v_stage_desc = 'NONE'
    
  SET @o_result = @v_stage_desc
  
END
GO

GRANT EXEC ON qpl_calc_latest_stg_sel_ver TO PUBLIC
GO