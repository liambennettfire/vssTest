if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_delete_specitems_from_category') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_delete_specitems_from_category
GO

CREATE PROCEDURE qpl_delete_specitems_from_category
 (@i_categorykey	integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*********************************************************************************
**  Name: qpl_delete_specitems_from_category
**  Desc: Deletes all spec items associated with the given category
**
**  Auth: Dustin Miller
**  Date: March 1, 2012
**********************************************************************************/
  
DECLARE
  @v_error    INT,
  @v_rowcount INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
	DELETE FROM taqversionspecitems
	WHERE taqversionspecategorykey=@i_categorykey

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionspecitems table (taqversionspecategorykey=' + CAST(@i_categorykey AS VARCHAR) + ').'
  END
  
  DELETE FROM taqversionspecnotes
  WHERE taqversionspecategorykey=@i_categorykey

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionspecnotes table (taqversionspecategorykey=' + CAST(@i_categorykey AS VARCHAR) + ').'
  END  
  
  IF EXISTS(SELECT * FROM taqversionspeccategory WHERE relatedspeccategorykey = @i_categorykey AND relatedspeccategorykey IS NOT NULL) BEGIN 
	  DELETE FROM taqversionspecitems
	  WHERE taqversionspecategorykey IN (SELECT taqversionspecategorykey FROM taqversionspeccategory WHERE relatedspeccategorykey = @i_categorykey AND relatedspeccategorykey IS NOT NULL)
	  
	  SELECT @v_error = @@ERROR
	  IF @v_error <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Could not access taqversionspecitems table (taqversionspecategorykey=' + CAST(@i_categorykey AS VARCHAR) + ').'
	  END  	  
	  
	  DELETE FROM taqversionspecnotes
	  WHERE taqversionspecategorykey IN (SELECT taqversionspecategorykey FROM taqversionspeccategory WHERE relatedspeccategorykey = @i_categorykey AND relatedspeccategorykey IS NOT NULL)
	  
	  SELECT @v_error = @@ERROR
	  IF @v_error <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Could not access taqversionspecnotes table (taqversionspecategorykey=' + CAST(@i_categorykey AS VARCHAR) + ').'
	  END  	  
  END  
  
END
go

GRANT EXEC ON qpl_delete_specitems_from_category TO PUBLIC
go
