IF EXISTS (
    SELECT 1
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[qutl_run_tmwebprocess]')
      AND type IN (N'P', N'PC')
    )
  DROP PROCEDURE [dbo].[qutl_run_tmwebprocess]
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[qutl_run_tmwebprocess] 
(
  @i_webprocesstypecode integer
)

AS
/*************************************************************************************************************************
**  Name: qutl_run_tmwebprocess
**  Desc: This stored procedure is run periodically via a SQL Server Agent Job and checks for tmwebprocess requests.
**
**    Auth: Colman
**    Date: 3/1/2018
**************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**************************************************************************************************************************/

BEGIN
  DECLARE @o_error_code INT
  DECLARE @o_error_desc VARCHAR(MAX)
  DECLARE @v_procedure NVARCHAR(MAX)
  DECLARE @v_sqlstring NVARCHAR(MAX)
  DECLARE @v_qsicode INT

  -- Is there anything to do?
  IF EXISTS (SELECT 1 FROM tmwebprocessinstance WHERE processcode = @i_webprocesstypecode)
  BEGIN
    SELECT @v_qsicode = qsicode 
    FROM gentables 
    WHERE tableid = 669 
      AND datacode = @i_webprocesstypecode
      
    IF @v_qsicode <> 1 -- Copy printings has its own job
    BEGIN
      SELECT @v_procedure = gentext3
      FROM gentables_ext 
      WHERE tableid = 669
        AND datacode = @i_webprocesstypecode
        
      IF ISNULL(@v_procedure, '') <> ''
      BEGIN
        SET @v_sqlstring = N'EXEC ' + @v_procedure + N' ' + CAST(@i_webprocesstypecode AS NVARCHAR) + ', @o_error_code OUTPUT, @o_error_desc OUTPUT'
        EXEC sp_executesql @v_sqlstring, N'@o_error_code INT OUTPUT, @o_error_desc VARCHAR(2000) OUTPUT', @o_error_code OUTPUT, @o_error_desc OUTPUT
      END
    END
  END
END

GO

GRANT EXEC ON qutl_run_tmwebprocess TO PUBLIC
GO


