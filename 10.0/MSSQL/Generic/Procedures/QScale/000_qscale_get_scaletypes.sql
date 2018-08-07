if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_scaletypes') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_scaletypes
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_scaletypes
  (@o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_scaletypes
**  Desc: This procedure returns all scale types and their corresponding datacodes
**
**	Auth: Dustin Miller
**	Date: February 22 2012
*******************************************************************************/

  DECLARE @v_tableid	INT,
					@v_itemtypecode INT,
					@v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SET @v_tableid=521
  SET @v_itemtypecode=11
       
  SELECT datacode, datadesc 
  FROM gentables 
  WHERE tableid=@v_tableid 
	AND datacode IN (SELECT datacode FROM gentablesitemtype WHERE tableid=@v_tableid AND itemtypecode=@v_itemtypecode)

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning scale type information'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_get_scaletypes TO PUBLIC
GO