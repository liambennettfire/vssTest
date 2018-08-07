if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionspecnotes') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionspecnotes
GO

CREATE PROCEDURE qpl_get_taqversionspecnotes
 (@i_categorykey		integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*********************************************************************************
**  Name: qpl_get_taqversionspecnotes
**  Desc: This stored procedure gets specs notes for the given spec category.
**
**  Auth: Kate
**  Date: May 19 2014
**********************************************************************************/
  
DECLARE
  @v_error    INT,
  @v_rowcount INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
  SELECT * FROM taqversionspecnotes
  WHERE taqversionspecategorykey = @i_categorykey
  ORDER BY sortorder ASC
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionspecnotes table (taqversionspecategorykey=' + CONVERT(VARCHAR, @i_categorykey) + ').'
  END
  
END
go

GRANT EXEC ON qpl_get_taqversionspecnotes TO PUBLIC
go
