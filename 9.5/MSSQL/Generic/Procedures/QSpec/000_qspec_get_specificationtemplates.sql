if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qspec_get_specificationtemplates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qspec_get_specificationtemplates
GO

CREATE PROCEDURE qspec_get_specificationtemplates
 (@i_mediatypecode     integer,
  @i_mediatypesubcode    integer,
  @i_showalltemplates  integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*********************************************************************************
**  Name: qspec_get_specificationtemplates
**  Desc: This stored procedure gets the P&L spec templates for given media/format.
**
**  Auth: Uday A. Khisty
**  Date: June 2, 2014
**********************************************************************************/
  
DECLARE
  @v_error    INT,
  @v_rowcount INT,
  @v_datacode INT,
  @v_datasubcode INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode 
  FROM subgentables 
  WHERE tableid = 550 AND qsicode = 44    
   
  IF @i_showalltemplates = 1
  BEGIN		

	SELECT c.*, t.mediatypecode, t.mediatypesubcode
	FROM coreprojectinfo c
	JOIN taqversionformat t ON c.projectkey = t.taqprojectkey
	WHERE c.searchitemcode = @v_datacode
		AND c.usageclasscode = @v_datasubcode
		AND t.mediatypecode IN (@i_mediatypecode, 0)
		AND t.mediatypesubcode IN (@i_mediatypesubcode, 0)
	ORDER BY t.mediatypesubcode DESC, t.mediatypecode DESC 	

  END
  ELSE IF @i_showalltemplates = 2
  BEGIN	
	
	SELECT *
	FROM coreprojectinfo
	WHERE searchitemcode = @v_datacode
		AND usageclasscode = @v_datasubcode

  END
  ELSE 
  BEGIN	

	SELECT *
	FROM coreprojectinfo
	WHERE projectkey IN (
			SELECT DISTINCT taqprojectkey
			FROM taqversionformat
			WHERE mediatypecode = @i_mediatypecode
				AND mediatypesubcode IN (@i_mediatypesubcode, 0)
			)
		AND searchitemcode = @v_datacode
		AND usageclasscode = @v_datasubcode
  
  END

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionformat table (mediatypecode=' + CAST(@i_mediatypecode AS VARCHAR) + 
      ', mediatypesubcode=' + CAST(@i_mediatypesubcode AS VARCHAR) + ').'
  END
  
END
go

GRANT EXEC ON qspec_get_specificationtemplates TO PUBLIC
go
