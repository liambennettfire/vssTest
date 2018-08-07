if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_exchange_rate') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_exchange_rate
GO

CREATE PROCEDURE qpl_calc_exchange_rate (  
  @i_projectkey INT,
  @i_plstage  INT,
  @i_display_currency INT,
  @o_result     VARCHAR(255) OUTPUT)
AS

/********************************************************************************************************
**  Name: qpl_calc_exchange_rate
**  Desc: Returns the current currency Exchange Rate from the input currency to selected display currency.
**
**  Auth: Kate
**  Date: February 15 2014
********************************************************************************************************/

DECLARE
  @v_approval_currency  INT,
  @v_count INT,  
  @v_input_currency INT,
  @v_exchangerate DECIMAL(9,4),
  @v_ratelockind TINYINT
  
BEGIN
  
  SELECT @v_ratelockind = exchangeratelockind
  FROM taqplstage
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage
  
  IF @v_ratelockind = 1
    SELECT @v_exchangerate = exchangerate
    FROM taqplstage
    WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage
  ELSE
  BEGIN
    SELECT @v_input_currency = COALESCE(plenteredcurrency,0), @v_approval_currency = COALESCE(plapprovalcurrency,0)
    FROM taqproject
    WHERE taqprojectkey = @i_projectkey

    IF @v_input_currency = @v_approval_currency
      UPDATE taqplstage
      SET exchangerate = NULL
      WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage
    ELSE
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 27 AND code1 = @v_input_currency AND code2 = @v_approval_currency

      IF @v_count > 0
      BEGIN
        SELECT @v_exchangerate = decimal1
        FROM gentablesrelationshipdetail
        WHERE gentablesrelationshipkey = 27 AND code1 = @v_input_currency AND code2 = @v_approval_currency
      
        UPDATE taqplstage
        SET exchangerate = @v_exchangerate
        WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage
      END
    END
    
    IF @i_display_currency = @v_input_currency
    BEGIN
      SET @o_result = -99
      RETURN
    END
    ELSE
    BEGIN
      IF @i_display_currency != @v_approval_currency
      BEGIN
        SELECT @v_count = COUNT(*)
        FROM gentablesrelationshipdetail
        WHERE gentablesrelationshipkey = 27 AND code1 = @v_input_currency AND code2 = @i_display_currency

        IF @v_count > 0
          SELECT @v_exchangerate = decimal1
          FROM gentablesrelationshipdetail
          WHERE gentablesrelationshipkey = 27 AND code1 = @v_input_currency AND code2 = @i_display_currency
      END
    END 
  END
  
  SET @o_result = @v_exchangerate
  
END
GO

GRANT EXEC ON qpl_calc_exchange_rate TO PUBLIC
GO