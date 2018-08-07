if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_delete_rightstemplate') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_delete_rightstemplate
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_delete_rightstemplate
 (@i_projectkey						integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_delete_rightstemplate
**  Desc: This procedure deletes the rights template with the specified projectkey and all associated rows
**
**	Auth: Dustin Miller
**	Date: June 15 2012
*******************************************************************************/

  DECLARE @v_rightskey	INT,
					@v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_rightskey = NULL
	
	SELECT @v_rightskey = rightskey
  FROM taqprojectrights
  WHERE taqprojectkey = @i_projectkey
  
  DELETE FROM taqproject
  WHERE taqprojectkey = @i_projectkey
  
  DELETE FROM taqprojectrights
	WHERE taqprojectkey = @i_projectkey
  
  IF @v_rightskey IS NOT NULL
  BEGIN
		DELETE FROM taqprojectrightsformat
		WHERE rightskey = @v_rightskey
		
		DELETE FROM taqprojectrightslanguage
		WHERE rightskey = @v_rightskey
		
		DELETE FROM territoryrights
		WHERE rightskey = @v_rightskey
		
		DELETE FROM territoryrightcountries
		WHERE rightskey = @v_rightskey
  END
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error deleting rights template rows (projectkey=' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_delete_rightstemplate TO PUBLIC
GO