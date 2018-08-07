if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_territory_by_formatlanguage') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_territory_by_formatlanguage
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_territory_by_formatlanguage
 (@i_projectkey						integer,
	@i_mediacode						integer,
	@i_formatcode						integer,
	@i_languagecode					integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_territory_by_formatlanguage
**  Desc: This procedure returns data from the get_territorycounty_by_formatlanguage function
**
**	Auth: Dustin Miller
**	Date: May 18 2012
*******************************************************************************/

  DECLARE @v_rows				INT,
					@v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
			
	SELECT @v_rows = count(DISTINCT rightskey)
	FROM dbo.get_territorycounty_by_formatlanguage(@i_projectkey)
	WHERE mediacode = @i_mediacode
		AND formatcode = @i_formatcode
		AND languagecode = @i_languagecode
	
	IF (@v_rows <= 1)
	BEGIN
		IF (@i_formatcode > 0)
		BEGIN
			SELECT *
			FROM dbo.get_territorycounty_by_formatlanguage(@i_projectkey)
			WHERE mediacode = @i_mediacode
				AND (formatcode = @i_formatcode OR formatcode = 0)
				AND languagecode = @i_languagecode				
		END
		ELSE BEGIN
			SELECT *
			FROM dbo.get_territorycounty_by_formatlanguage(@i_projectkey)
			WHERE mediacode = @i_mediacode
				AND languagecode = @i_languagecode
		END
	END
	ELSE BEGIN
		SET @o_error_code = -1
    SET @o_error_desc = 'More than one contract rights record exists for this format and language on this contract.'
    RETURN 
	END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning territory by formatlanguage details (projectkey=' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_get_territory_by_formatlanguage TO PUBLIC
GO