if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_all_chargecodes') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_all_chargecodes
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_all_chargecodes
  (@o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_all_chargecodes
**  Desc: This procedure returns all charge codes (internal code, external, and desc) on cdlist
**
**	Auth: Dustin Miller
**	Date: February 20 2012
*******************************************************************************/

  DECLARE @v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  SELECT internalcode, externalcode, externaldesc FROM cdlist

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning charge codes'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_get_all_chargecodes TO PUBLIC
GO