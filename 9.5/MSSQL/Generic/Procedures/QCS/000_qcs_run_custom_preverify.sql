if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_run_custom_preverify') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcs_run_custom_preverify
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qcs_run_custom_preverify]
(@i_bookkey				int,
 @i_preverifyproc	nvarchar(255),
 @o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	DECLARE @v_error  INT,
					@v_sql	NVARCHAR(2000)

	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	IF @i_preverifyproc IS NOT NULL AND LEN(@i_preverifyproc) > 0
	BEGIN
		SET @v_sql = 'EXEC ' + @i_preverifyproc + ' ' + CAST(@i_bookkey as nvarchar)

		EXECUTE sp_executesql @v_sql

		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Error executing custom preverification stored procedure: ' + @i_preverifyproc
		END
  END
	
GO

GRANT EXEC ON qcs_run_custom_preverify TO PUBLIC
GO

