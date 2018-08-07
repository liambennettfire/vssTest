IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.wk_budgetCostImport_getVersionSpecCategoryKey'))
  DROP PROCEDURE dbo.wk_budgetCostImport_getVersionSpecCategoryKey
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.wk_budgetCostImport_getVersionSpecCategoryKey
(
  @i_projectkey INTEGER,
  @i_plstagecode INTEGER,
  @i_taqversionkey INTEGER,
  @i_itemcategorycode INTEGER,
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

  /******************************************************************************
**  Name: wk_budgetCostImport_getVersionSpecCategoryKey
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
  DECLARE @error_var                 INT,
          @rowcount_var              INT,
          @versionspeccategorykey    INT,
          @ApprovedProjectStatusCode INT

  SET @versionspeccategorykey = 0

  SET @versionspeccategorykey = ( SELECT taqversionspecategorykey
                                   FROM taqversionspeccategory
                                   WHERE (taqprojectkey = @i_projectkey)
                                     AND (plstagecode = @i_plstagecode)
                                     AND (taqversionkey = @i_taqversionkey)
                                     AND (itemcategorycode = @i_itemcategorycode))

  IF @versionspeccategorykey > 0
    BEGIN
      SELECT @versionspeccategorykey AS taqversionspecategorykey,
             '1' AS [exists]
    END

  ELSE
    BEGIN
      SELECT @versionspeccategorykey AS taqversionspecategorykey,
             '0' AS [exists]
    END


  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0
    BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'no data found on taqversionspeccategory (' 
      + cast(@error_var AS VARCHAR) + '): projectkey = ' + cast(@i_projectkey AS VARCHAR)
      + ' plstagecode = ' + cast(@i_plstagecode AS VARCHAR)
      + ' taqversionkey = ' + cast(@i_taqversionkey AS VARCHAR)
      + ' itemcategorycode = ' + cast(@i_itemcategorycode AS VARCHAR)
    END
GO

GRANT EXEC ON wk_budgetCostImport_getVersionSpecCategoryKey TO PUBLIC
GO

-- Sample usage from wkTrain
--EXEC dbo.wk_budgetCostImport_getVersionSpecCategoryKey 2702674, 2, 2, 2, 0, 0