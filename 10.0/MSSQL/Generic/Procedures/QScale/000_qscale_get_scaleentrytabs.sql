if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_scaleentrytabs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_scaleentrytabs
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_scaleentrytabs
 (@i_scaletypecode				integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_scaleentrytabs
**  Desc: This procedure gets the relevent scale entry tab rows based on scaletypecode
**
**	Auth: Dustin Miller
**	Date: February 23 2012
*******************************************************************************/

  DECLARE @v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
       
  SELECT scaletabkey, tablabel 
  FROM taqscaleadmintab 
  WHERE scaletypecode=@i_scaletypecode

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning scale entry tab information (scaletypecode=' + cast(@i_scaletypecode as varchar) + ')'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_get_scaleentrytabs TO PUBLIC
GO