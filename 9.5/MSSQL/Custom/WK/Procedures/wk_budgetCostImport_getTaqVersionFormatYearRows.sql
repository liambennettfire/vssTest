IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.wk_budgetCostImport_getTaqVersionFormatYearRows'))
  DROP PROCEDURE dbo.wk_budgetCostImport_getTaqVersionFormatYearRows
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.wk_budgetCostImport_getTaqVersionFormatYearRows
(
  @i_projectkey INTEGER,
  @i_mediatypecode INTEGER,
  @i_mediatypesubcode INTEGER,
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

/******************************************************************************
**  Name: wk_budgetCostImport_getTaqVersionFormatYearRows
**  Desc: This stored procedure ...
**
**    Auth: Jonathan Hess
**    Date: 05/09/2012
**
**    Initial Case: 14626
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var         INT,
          @rowcount_var      INT,
          @plstagecode_var   INT,
          @taqversionkey_var INT,
          @datacode_var      INT

  SET @datacode_var = (
                       SELECT datacode
                         FROM gentables g
                         WHERE g.tableid = 565
                           AND externalcode IN (
                                                SELECT w.versionstatusexternalcode
                                                  FROM wkbudgetimportcodes w
                                               )
                      )

  SELECT @plstagecode_var = v.plstagecode,
         @taqversionkey_var = v.taqversionkey
    FROM taqversion v
    WHERE taqprojectkey = @i_projectkey
      AND plstatuscode = @datacode_var

  SELECT *
    FROM taqversionformatyear
    WHERE taqprojectformatkey IN (
                                  SELECT taqprojectformatkey
                                    FROM taqversionformat
                                    WHERE taqprojectkey = @i_projectkey
                                      AND mediatypecode = @i_mediatypecode
                                      AND mediatypesubcode = @i_mediatypesubcode
                                      AND taqversionformatyear.plstagecode = @plstagecode_var
                                      AND taqversionformatyear.taqversionkey = @taqversionkey_var
                                      AND taqversionformatyear.yearcode <> 5
                                 )

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0
    BEGIN
      SET @o_error_code = 1
      SET @o_error_desc =
      'An error occurred getting data, gentables, taqversion, taqversionformatyear were all referenced... '
    END
GO

GRANT EXEC ON wk_budgetCostImport_getTaqVersionFormatYearRows TO PUBLIC
GO