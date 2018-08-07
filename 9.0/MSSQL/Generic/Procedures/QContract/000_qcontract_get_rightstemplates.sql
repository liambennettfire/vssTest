if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_rightstemplates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_rightstemplates
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_rightstemplates
 (@o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_rightstemplates
**  Desc: This procedure returns data for the contracts rights format rows
**
**	Auth: Dustin Miller
**	Date: June 7 2012
*******************************************************************************/

  DECLARE @v_searchitemcode	INT,
					@v_usageclasscode	INT,
					@v_error					INT,
          @v_rowcount				INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_searchitemcode = null
  SET @v_usageclasscode = null
	
  SELECT @v_searchitemcode=datacode FROM gentables
	WHERE tableid=550
		AND qsicode=5
		AND upper(deletestatus) <> 'Y'
		
	SELECT @v_usageclasscode=datacode FROM gentables
	WHERE tableid=521
		AND qsicode=3
		AND upper(deletestatus) <> 'Y'
		
	IF @v_searchitemcode IS NOT NULL AND @v_usageclasscode IS NOT NULL
	BEGIN
		SELECT taqprojectkey, taqprojecttitle FROM taqproject
		WHERE searchitemcode=@v_searchitemcode
			AND usageclasscode=@v_usageclasscode
		ORDER BY taqprojectkey
	END
	ELSE BEGIN
		SET @o_error_code = -1
    SET @o_error_desc = 'Error obtaining search item code/usage class code for rights templates.'
    RETURN 
	END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning rights templates.'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_get_rightstemplates TO PUBLIC
GO