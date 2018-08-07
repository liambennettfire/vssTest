IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.wk_budgetCostImport_getAcctgCodeForExternalCode'))
  DROP PROCEDURE dbo.wk_budgetCostImport_getAcctgCodeForExternalCode
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.wk_budgetCostImport_getAcctgCodeForExternalCode
(
  @i_externalCode VARCHAR(2000),
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

/******************************************************************************
**  Name: wk_budgetCostImport_getAcctgCodeForExternalCode
**  Desc: This stored procedure ...
**
**    Auth: Jonathan Hess
**    Date: 05/18/2012
**
**    Initial Case: 14626
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var        INT,
          @rowcount_var     INT,
          @internalCode_var INT


  SET @internalCode_var = (SELECT internalcode
                             FROM cdlist c
                             WHERE lower(c.externalcode) = lower(@i_externalCode))

  SELECT @internalCode_var AS [acctgcode]

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0
    BEGIN
      SET @o_error_code = 1
      SET @o_error_desc =
      'An error occurred getting data, Table(s) referenced: cdlist'
    END
GO

GRANT EXEC ON wk_budgetCostImport_getAcctgCodeForExternalCode TO PUBLIC
GO