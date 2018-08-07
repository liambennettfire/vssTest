IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.wk_budgetCostImport_getVersionSpecItemKey'))
  DROP PROCEDURE dbo.wk_budgetCostImport_getVersionSpecItemKey
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.wk_budgetCostImport_getVersionSpecItemKey
(
  @i_speccategorykey INTEGER,
  @i_itemcode INTEGER,
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

  /******************************************************************************
**  Name: wk_budgetCostImport_getVersionSpecItemKey
**  Desc: This stored procedure ...
**
**    Auth: Jonathan Hess
**    Date: 04/12/2012
**
**    Initial Case: 14626
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var          INT,
          @rowcount_var       INT,
          @versionspecitemkey INT

  SET @versionspecitemkey = 0

  SET @versionspecitemkey = (SELECT taqversionspecitemkey
                               FROM taqversionspecitems
                               WHERE (taqversionspecategorykey = @i_speccategorykey)
                                 AND (itemcode = @i_itemcode))

  IF @versionspecitemkey > 0
    BEGIN
      SELECT @versionspecitemkey AS taqversionspecitemkey,
             '1' AS [exists]
    END

  ELSE
    BEGIN
      SELECT @versionspecitemkey AS taqversionspecitemkey,
             '0' AS [exists]
    END


  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0
    BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'no data found on taqversionspecitems ('
      + cast(@error_var AS VARCHAR) + '): taqversionspecategorykey = ' + cast(@i_speccategorykey AS VARCHAR)
      + ' itemcode = ' + cast(@i_itemcode AS VARCHAR)
    END
GO

GRANT EXEC ON wk_budgetCostImport_getVersionSpecItemKey TO PUBLIC
GO

-- Sample usage from wkTrain
--EXEC dbo.wk_budgetCostImport_getVersionSpecItemKey 2702674, 2, 0,0