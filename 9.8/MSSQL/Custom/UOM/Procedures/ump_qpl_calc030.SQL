/****** Object:  StoredProcedure [dbo].[ump_qpl_calc030]    Script Date: 5/23/2018 11:43:57 AM ******/
IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.ump_qpl_calc030') )
DROP PROCEDURE dbo.ump_qpl_calc030
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ump_qpl_calc030] (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc030
**  Desc: Island Press Item 30 - Version/Gross Margin %.
**
**  Auth: Kate
**  Date: February 4 2008
*******************************************************************************************/

DECLARE
  @v_gross_margin FLOAT,
  @v_gross_margin_percent FLOAT,
  @v_prodsubsidy_income FLOAT,
  @v_total_income FLOAT

BEGIN

  SET @o_result = NULL
 
  -- Version - TOTAL Income
  EXEC qpl_calc_ver_tot_inc @i_projectkey, @i_plstage, @i_plversion, @v_total_income OUTPUT

  IF @v_total_income IS NULL
    SET @v_total_income = 0
  
  -- Version - Production Subsidy
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MISCINC', 'PRODSUB', 1, @v_prodsubsidy_income OUTPUT
  
  IF @v_prodsubsidy_income IS NULL
    SET @v_prodsubsidy_income = 0

  -- Version - Gross Margin
  EXEC qpl_calc_ver_gross_marg @i_projectkey, @i_plstage, @i_plversion, @v_gross_margin OUTPUT

  IF @v_gross_margin IS NULL
    SET @v_gross_margin = 0
  
  IF @v_total_income = 0 or @v_total_income - @v_prodsubsidy_income = 0
    SET @v_gross_margin_percent = 0
  ELSE
    SET @v_gross_margin_percent = @v_gross_margin / (@v_total_income - @v_prodsubsidy_income)

  SET @o_result = @v_gross_margin_percent
  
END
GO

GRANT EXEC ON dbo.ump_qpl_calc030 TO PUBLIC
GO
