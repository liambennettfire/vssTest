IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.wk_budgetCostImport_getVersionDataCode'))
  DROP PROCEDURE dbo.wk_budgetCostImport_getVersionDataCode
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.wk_budgetCostImport_getVersionDataCode
(
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

  /******************************************************************************
**  Name: wk_budgetCostImport_getVersionDataCode
**  Desc: This stored procedure ...
**
**    Auth: Jonathan Hess
**    Date: 05/08/2012
**
**    Initial Case: 14626
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var      INT,
          @rowcount_var   INT,
          @datacode_var INT

  SET @datacode_var = (
                         SELECT datacode
                           FROM gentables g
                           WHERE g.tableid = 565
                             AND externalcode IN (SELECT w.versionstatusexternalcode
                                                    FROM wkbudgetimportcodes w))

  SELECT @datacode_var AS [budgetversiondatacode]


  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0
    BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 
        'An error occurred getting data, gentables and wkbudgetimportcodes are tables referenced.'
    END
GO

GRANT EXEC ON wk_budgetCostImport_getVersionDataCode TO PUBLIC
GO