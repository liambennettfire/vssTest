if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_all_thresholdtypes') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_all_thresholdtypes
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_all_thresholdtypes
  (@o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_all_thresholdtypes
**  Desc: This procedure returns relevant threshold types to be used for the scale
**
**	Auth: Dustin Miller
**	Date: February 20 2012
*******************************************************************************/

  DECLARE @v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  SELECT datacode, datasubcode, datadesc, coalesce(deletestatus, 'N') AS deletestatus
  FROM subgentables 
  WHERE tableid=616 
		AND subgen2ind=1

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning thresholdtypes'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_get_all_thresholdtypes TO PUBLIC
GO