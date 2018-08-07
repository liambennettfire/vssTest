IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.qutl_get_titlerequestdate')
               AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qutl_get_titlerequestdate
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE qutl_get_titlerequestdate
(
  @i_projectkey INTEGER,
  @i_bookkey INTEGER,
  @i_printingkey INTEGER,
  @i_datetypecode INTEGER,
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

  /******************************************************************************
  **  File: 
  **  Name: qutl_get_titlerequestdate
  **  Desc: This stored procedure finds the date value for a given datetypecode 
  **        and projectkey and bookkey, search project first then title level.
  **         
  **
  **    Auth: Jon Hess
  **    Date: 02/07/2012
  *******************************************************************************
  **    Change History
  *******************************************************************************
  **    Date:    Author:        Description:
  **    --------    --------        -------------------------------------------
  **    
  *******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var INTEGER
  DECLARE @rowcount_var INTEGER

  IF @i_projectkey > 0 
    BEGIN
      SELECT *
        FROM taqprojecttask t
        WHERE datetypecode = @i_datetypecode
          AND taqprojectkey = @i_projectkey
    END
  ELSE IF @i_bookkey > 0  
    BEGIN
      SELECT *
        FROM taqprojecttask t
        WHERE datetypecode = @i_datetypecode
          AND bookkey = @i_bookkey
          AND printingkey = @i_printingkey
    END

  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0
    BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'no data found on taqprojecttask'
    END

GO
GRANT EXEC ON qutl_get_titlerequestdate TO PUBLIC
GO