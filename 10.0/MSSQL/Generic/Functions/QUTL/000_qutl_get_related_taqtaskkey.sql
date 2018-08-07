SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS (
    SELECT *
    FROM sys.objects
    WHERE type = 'fn'
      AND name = 'qutl_get_related_taqtaskkey'
    )
  DROP FUNCTION qutl_get_related_taqtaskkey
GO

CREATE FUNCTION [dbo].[qutl_get_related_taqtaskkey] (
  @i_datetypecode INT
  ,@i_taqprojectcontactrolekey INT
  ,@i_globalcontactkey INT
  ,@i_rolecode INT
  ,@i_projectkey INT
  ,@i_bookkey INT
  ,@i_printingkey INT
  )
RETURNS INTEGER

/**************************************************************************************
**  Name: qutl_get_related_taqtaskkey
**  Desc: Try to find a taqprojecttask of the specified datetypecode with decreasing 
**        levels of specificity:
**        Match on (globalcontactkey AND rolecode) ELSE rolecode ELSE globalcontactkey 
**        ELSE any task of that type
**  Case: 50348
**
**  Auth: Colman
**  Date: 04/06/2018
****************************************************************************************
**  Change History
****************************************************************************************
**  Date:     Author:      Description:
**  --------  ---------    -------------------------------------------------------------
**    
****************************************************************************************/
BEGIN
  DECLARE @v_return INTEGER

  SET @v_return = NULL

  SELECT @v_return = CASE 
      WHEN ISNULL(@i_projectkey, 0) > 0
        THEN (
            SELECT COALESCE((
                SELECT TOP 1 taqtaskkey
                FROM taqprojecttask
                WHERE taqprojectkey = @i_projectkey
                  AND datetypecode = @i_datetypecode
                  AND transactionkey = @i_taqprojectcontactrolekey
                ), (
                SELECT TOP 1 taqtaskkey
                FROM taqprojecttask
                WHERE taqprojectkey = @i_projectkey
                  AND datetypecode = @i_datetypecode
                  AND ISNULL(transactionkey, 0) = 0
                  AND (
                    (
                      globalcontactkey = @i_globalcontactkey
                      AND rolecode = @i_rolecode
                      )
                    )
                ), (
                SELECT TOP 1 taqtaskkey
                FROM taqprojecttask
                WHERE taqprojectkey = @i_projectkey
                  AND datetypecode = @i_datetypecode
                  AND ISNULL(transactionkey, 0) = 0
                  AND (
                    (
                      ISNULL(globalcontactkey, 0) = 0
                      AND rolecode = @i_rolecode
                      )
                    )
                ), (
                SELECT TOP 1 taqtaskkey
                FROM taqprojecttask
                WHERE taqprojectkey = @i_projectkey
                  AND datetypecode = @i_datetypecode
                  AND ISNULL(transactionkey, 0) = 0
                  AND (
                    (
                      globalcontactkey = @i_globalcontactkey
                      AND ISNULL(rolecode, 0) = 0
                      )
                    )
                ), (
                SELECT TOP 1 taqtaskkey
                FROM taqprojecttask
                WHERE taqprojectkey = @i_projectkey
                  AND datetypecode = @i_datetypecode
                  AND ISNULL(transactionkey, 0) = 0
                  AND (
                    (
                      ISNULL(globalcontactkey, 0) = 0
                      AND ISNULL(rolecode, 0) = 0
                      )
                    )
                ))
            )
      ELSE (
          SELECT COALESCE((
                SELECT TOP 1 taqtaskkey
                FROM taqprojecttask
                WHERE bookkey = @i_bookkey
                  AND printingkey = @i_printingkey
                  AND datetypecode = @i_datetypecode
                  AND transactionkey = @i_taqprojectcontactrolekey
                ), (
                SELECT TOP 1 taqtaskkey
                FROM taqprojecttask
                WHERE bookkey = @i_bookkey
                  AND printingkey = @i_printingkey
                  AND datetypecode = @i_datetypecode
                  AND ISNULL(transactionkey, 0) = 0
                  AND (
                    (
                      globalcontactkey = @i_globalcontactkey
                      AND rolecode = @i_rolecode
                      )
                    )
                ), (
                SELECT TOP 1 taqtaskkey
                FROM taqprojecttask
                WHERE bookkey = @i_bookkey
                  AND printingkey = @i_printingkey
                  AND datetypecode = @i_datetypecode
                  AND ISNULL(transactionkey, 0) = 0
                  AND (
                    (
                      ISNULL(globalcontactkey, 0) = 0
                      AND rolecode = @i_rolecode
                      )
                    )
                ), (
                SELECT TOP 1 taqtaskkey
                FROM taqprojecttask
                WHERE bookkey = @i_bookkey
                  AND printingkey = @i_printingkey
                  AND datetypecode = @i_datetypecode
                  AND ISNULL(transactionkey, 0) = 0
                  AND (
                    (
                      globalcontactkey = @i_globalcontactkey
                      AND ISNULL(rolecode, 0) = 0
                      )
                    )
                ), (
                SELECT TOP 1 taqtaskkey
                FROM taqprojecttask
                WHERE bookkey = @i_bookkey
                  AND printingkey = @i_printingkey
                  AND datetypecode = @i_datetypecode
                  AND ISNULL(transactionkey, 0) = 0
                  AND (
                    (
                      ISNULL(globalcontactkey, 0) = 0
                      AND ISNULL(rolecode, 0) = 0
                      )
                    )
                ))
          )
      END

  RETURN @v_return
END
GO

GRANT EXEC ON dbo.qutl_get_related_taqtaskkey TO PUBLIC
GO

