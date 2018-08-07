if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_scaleadminparameters') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_scaleadminparameters
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_scaleadminparameters
 (@i_scaletypecode        integer,
	@i_parametertypecode		integer,
	@i_excludebyparamtype		tinyint,	--whether to get all but the provided parametertype, or to get only (0 for false or 1 for true)
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_scaleadminparameters
**  Desc: This procedure returns rows for the scale type admin parameters tab based on the indicated scale type, 
**		and optionally based on parametertypecode (if greater than 0)
**
**	Auth: Dustin Miller
**	Date: February 22 2012
*******************************************************************************/

  DECLARE @v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_parametertypecode > 0
  BEGIN
		IF @i_excludebyparamtype <> 1
		BEGIN
			SELECT * 
			FROM taqscaleadminspecitem 
			WHERE parametertypecode=@i_parametertypecode 
				AND scaletypecode=@i_scaletypecode
		END
		ELSE BEGIN
			SELECT * 
			FROM taqscaleadminspecitem 
			WHERE parametertypecode <> @i_parametertypecode 
				AND scaletypecode=@i_scaletypecode
		END
	END
	ELSE BEGIN
		SELECT * 
		FROM taqscaleadminspecitem 
		WHERE scaletypecode=@i_scaletypecode
	END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning scaleadmin parameters information (scaletypecode=' + cast(@i_scaletypecode as varchar) + ')'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_get_scaleadminparameters TO PUBLIC
GO