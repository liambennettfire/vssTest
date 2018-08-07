if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_scaleadminparameter_by_key') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_scaleadminparameter_by_key
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_scaleadminparameter_by_key
 (@i_scaletabkey					integer,
	@i_parametertypecode		integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_scaleadminparameter_by_key
**  Desc: This procedure returns rows for the scale type admin parameters tab based on the indicated scale type, 
**		and optionally based on parametertypecode (if greater than 0)
**
**	Auth: Dustin Miller
**	Date: February 23 2012
*******************************************************************************/

  DECLARE @v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT scaletabkey, itemcategorycode, itemcode 
  FROM taqscaleadminspecitem 
  WHERE scaletabkey=@i_scaletabkey
		AND parametertypecode=@i_parametertypecode

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning scaleadmin parameters information (scaletabkey=' + cast(@i_scaletabkey as varchar) + ')'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_get_scaleadminparameter_by_key TO PUBLIC
GO