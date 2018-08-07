if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_generate_cost_for_version') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_generate_cost_for_version
GO

CREATE PROCEDURE qpl_generate_cost_for_version
 (@i_projectkey     integer,
  @i_plstage        integer,
  @i_versionkey     integer,
  @i_processtype		integer,
  @i_userid					varchar(30),
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*********************************************************************************
**  Name: qpl_generate_cost_for_version
**  Desc: Calls the cost generation routine for each unique format/yr for the version that has a printing number
**
**  Auth: Dustin Miller
**  Date: March 19, 2012
**********************************************************************************/
  
DECLARE
	@v_formatkey			INT,
	@v_formatyearkey	INT,
  @v_error					INT,
  @v_rowcount				INT,
  @v_datetime				DATETIME

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
	DECLARE formats_cursor CURSOR FAST_FORWARD FOR
	SELECT taqprojectformatkey
	FROM taqversionformat
	WHERE taqprojectkey = @i_projectkey 
		AND plstagecode = @i_plstage 
		AND taqversionkey = @i_versionkey
	
	OPEN formats_cursor
	
	FETCH formats_cursor
	INTO @v_formatkey
  
  WHILE (@@FETCH_STATUS = 0)
	BEGIN
		DECLARE printings_cursor CURSOR FAST_FORWARD FOR
		SELECT taqversionformatyearkey
		FROM taqversionformatyear 
		WHERE taqprojectkey = @i_projectkey 
			AND plstagecode = @i_plstage 
			AND taqversionkey = @i_versionkey 
			AND taqprojectformatkey = @v_formatkey 
			AND printingnumber IS NOT NULL
			
		OPEN printings_cursor
		
		FETCH printings_cursor
		INTO @v_formatyearkey
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			IF @v_formatyearkey IS NOT NULL AND @v_formatyearkey > 0
			BEGIN
				SET @v_datetime = getdate()
				EXEC qpl_generate_costs_main @v_formatyearkey, @v_datetime, @i_processtype, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
				--IF @o_error_code < 0 OR @@ERROR <> 0
				--BEGIN
				--	GOTO RETURN_ERROR
				--END
			END
			
			FETCH printings_cursor
			INTO @v_formatyearkey
		END
		CLOSE printings_cursor
		DEALLOCATE printings_cursor
		
		FETCH formats_cursor
		INTO @v_formatkey
	END
	CLOSE formats_cursor
	DEALLOCATE formats_cursor
  
  RETURN
  
  RETURN_ERROR:
    SET @o_error_code = -1
    RETURN
  
END
go

GRANT EXEC ON qpl_generate_cost_for_version TO PUBLIC
go
