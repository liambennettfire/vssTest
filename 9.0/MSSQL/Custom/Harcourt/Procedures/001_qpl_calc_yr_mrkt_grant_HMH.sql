if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc133') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc133
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_mrkt_grant_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_mrkt_grant_HMH
GO

CREATE PROCEDURE qpl_calc_yr_mrkt_grant_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_mrkt_grant_HMH
**  Desc: Houghton Mifflin Item 133 - Year/Marketing & Grants.
**
**  Auth: Kate
**  Date: March 15 2010
*******************************************************************************************/

DECLARE
  @v_coop	  FLOAT,
  @v_marketing	FLOAT,
  @v_total	FLOAT

BEGIN

  SET @o_result = NULL

  -- Year - Marketing Expenses
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 'MKTGEXP', NULL, 0, @v_marketing OUTPUT

  IF @v_marketing IS NULL
    SET @v_marketing = 0    
  
  -- HMH only: Coop Expense
  EXEC qpl_calc_yr_coop_HMH @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_coop OUTPUT

  IF @v_coop IS NULL
    SET @v_coop = 0
    
  SET @v_total = @v_marketing + @v_coop
  SET @o_result = @v_total
  
END
GO

GRANT EXEC ON qpl_calc_yr_mrkt_grant_HMH TO PUBLIC
GO
