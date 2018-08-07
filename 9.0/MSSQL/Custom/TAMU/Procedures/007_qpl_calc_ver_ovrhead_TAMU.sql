if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc165') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc165
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_ovrhead_TAMU') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_ovrhead_TAMU
GO

CREATE PROCEDURE qpl_calc_ver_ovrhead_TAMU (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_ovrhead_TAMU
**  Desc: Texas A&M Item 165 - Version/$ to Overhead.
**
**  Auth: Kate
**  Date: January 21 2011
*******************************************************************************************/

DECLARE
  @v_count	INT,
  @v_dollar_to_overhead FLOAT,
  @v_gross_margin FLOAT,
  @v_percent_to_series  FLOAT

BEGIN

  SET @o_result = NULL
  
  -- Get the % to Series for this version
  SELECT @v_count = COUNT(*)
  FROM taqversionclientvalues 
  WHERE taqprojectkey = @i_projectkey AND 
      plstagecode = @i_plstage AND
      taqversionkey = @i_plversion AND
      clientvaluecode = 1 --% to Series
  
  SET @v_percent_to_series = 0
  IF @v_count > 0
    SELECT @v_percent_to_series = clientvalue 
    FROM taqversionclientvalues
    WHERE taqprojectkey = @i_projectkey AND 
        plstagecode = @i_plstage AND
        taqversionkey = @i_plversion AND
        clientvaluecode = 1
          
  -- Version - Gross Margin
  EXEC qpl_calc_ver_gross_marg_TAMU @i_projectkey, @i_plstage, @i_plversion, @v_gross_margin OUTPUT

  IF @v_gross_margin IS NULL
    SET @v_gross_margin = 0
    
  SET @v_dollar_to_overhead = (100 - @v_percent_to_series) * @v_gross_margin / 100

  SET @o_result = @v_dollar_to_overhead
  
END
GO

GRANT EXEC ON qpl_calc_ver_ovrhead_TAMU TO PUBLIC
GO
