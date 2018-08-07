if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_delete_rightformats_and_rightlanguages') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_delete_rightformats_and_rightlanguages
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_delete_rightformats_and_rightlanguages
 (@i_rightskey						integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_delete_rightformats_and_rightlanguages
**  Desc: This procedure deletes all rows on taqprojectrightsformat and taqprojectrightslanguage associated with rightskey
**
**	Auth: Dustin Miller
**	Date: June 14 2012
*******************************************************************************/

  DECLARE @v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
	BEGIN TRAN
		DELETE
		FROM taqprojectrightsformat
		WHERE rightskey = @i_rightskey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Error deleting rights format details (rightskey=' + cast(@i_rightskey as varchar) + ')'
			ROLLBACK TRAN
			RETURN  
		END
	  
		DELETE
		FROM taqprojectrightslanguage
		WHERE rightskey = @i_rightskey
		
		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Error deleting rights format languages (rightskey=' + cast(@i_rightskey as varchar) + ')'
			ROLLBACK TRAN
			RETURN  
		END
  COMMIT TRAN
GO

GRANT EXEC ON qcontract_delete_rightformats_and_rightlanguages TO PUBLIC
GO