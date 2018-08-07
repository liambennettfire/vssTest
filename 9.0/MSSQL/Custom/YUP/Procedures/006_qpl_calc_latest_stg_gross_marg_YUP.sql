if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_latest_stg_gross_marg') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_latest_stg_gross_marg
GO

CREATE PROCEDURE qpl_calc_latest_stg_gross_marg (  
  @i_projectkey INT,
  @o_result     VARCHAR(255) OUTPUT)
AS

/****************************************************************************************************
**  Name: qpl_calc_latest_stg_gross_marg
**  Desc: Returns the Gross Margin from the latest stage on the project which has a selected version.
**
**  Auth: Kate
**  Date: January 24 2014
*****************************************************************************************************/

DECLARE
  @v_count INT,
  @v_currency_symbol VARCHAR(1),
  @v_error  INT,
  @v_errordesc  VARCHAR(2000),
  @v_exchangerateitemkey  INT,
  @v_exchangerate DECIMAL(18,4),
  @v_gross_margin DECIMAL(18,4),
  @v_latest_stage	INT,
  @v_plapprovalcurrency INT,
  @v_plinputcurrency  INT,
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
  
  -- Stage - Gross Margin
  EXEC qpl_calc_stg_gross_marg @i_projectkey, @v_latest_stage, @v_gross_margin OUTPUT

  IF @v_gross_margin IS NULL
    SET @v_gross_margin = 0
    
  -- Check input and approval currency
  SELECT @v_plinputcurrency = plenteredcurrency, @v_plapprovalcurrency = plapprovalcurrency
  FROM taqproject
  WHERE taqprojectkey = @i_projectkey
  
  IF @v_plinputcurrency <> @v_plapprovalcurrency
  BEGIN
    -- Get the Exchange Rate p&l summary item key
    SELECT @v_exchangerateitemkey = plsummaryitemkey
    FROM plsummaryitemdefinition
    WHERE qsicode = 1
    
    -- Get the currency format for approval currency
    SELECT @v_currency_symbol = SUBSTRING(alternatedesc1, 1, 1)
    FROM gentables
    WHERE tableid = 122 AND datacode = @v_plapprovalcurrency

    -- If the first character of the currency format is a number, then clear the currency symbol
    IF @v_currency_symbol NOT LIKE '%[^0-9]%'
      SET @v_currency_symbol = ''
       
    EXEC qpl_run_pl_calcsql @i_projectkey, @v_latest_stage, 0, 0, @v_exchangerateitemkey, @v_plapprovalcurrency,
      @v_exchangerate OUTPUT, @v_error OUTPUT, @v_errordesc OUTPUT
      
    IF @v_exchangerate IS NOT NULL
      SET @v_gross_margin = @v_gross_margin * @v_exchangerate
  END
  
  SET @v_return_value = CONVERT(VARCHAR, ROUND(CONVERT(MONEY, @v_gross_margin),0), 1)
  SET @v_return_value = SUBSTRING(@v_return_value, 1, CHARINDEX('.', @v_return_value) -1)
  IF @v_currency_symbol <> ''
    SET @v_return_value = @v_currency_symbol + @v_return_value

  --PRINT @v_return_value

  SET @o_result = @v_return_value
  
END
GO

GRANT EXEC ON qpl_calc_latest_stg_gross_marg TO PUBLIC
GO