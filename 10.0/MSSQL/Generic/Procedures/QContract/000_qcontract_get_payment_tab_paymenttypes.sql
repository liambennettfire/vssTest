if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_payment_tab_paymenttypes') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_get_payment_tab_paymenttypes
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_payment_tab_paymenttypes
 (@i_tabcode				integer,
	@i_tabsubcode			integer,
	@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************
**  Name: qcontract_get_payment_tab_paymenttypes
**  Desc: This stored procedure returns the payment types displayed by the given tab
**
**  Auth: Dustin Miller
**  Date: 7/16/12
*************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT,
    @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

	SELECT code1 as paymenttype
	FROM gentablesrelationshipdetail
	WHERE gentablesrelationshipkey = 25
		AND code2 = @i_tabcode
		AND subcode2 = @i_tabsubcode

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not get contract types from gentablesrelationshipdetail.'
  END
  
END
GO

GRANT EXEC ON qcontract_get_payment_tab_paymenttypes TO PUBLIC
GO
