if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_payments_calculated_from') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_get_payments_calculated_from
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_payments_calculated_from
 (@i_projectkey			integer,
	@i_datetypecode   integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_payments_calculated_from
**  Desc: This stored procedure gets all titles related to the given contract.
**
**  Auth: Dustin Miller
**  Date: July 23, 2012
*******************************************************************************/

DECLARE
	@v_taqtaskkey	INT,
	@v_taqprojectkey	INT,
	@v_bookkey	INT,
	@v_desc	VARCHAR(500),
	@v_subdesc	VARCHAR(120),
	@v_sub2desc	VARCHAR(120),
  @v_error INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @related_titles_table TABLE
  (
		bookkey	INT
  )
  
  INSERT @related_titles_table
  SELECT bookkey
  FROM contractstitlesview
  WHERE contractprojectkey = @i_projectkey
  
  DECLARE @task_table TABLE
  (
		taqtaskkey	INT,
		fromtitle	VARCHAR(255)
  )
  
  DECLARE payments_from_cursor CURSOR FOR
	SELECT taqtaskkey, taqprojectkey, bookkey
  FROM taqprojecttask t
  WHERE t.datetypecode = @i_datetypecode
		AND t.bookkey IN (SELECT bookkey FROM @related_titles_table)
	
	OPEN payments_from_cursor
	
	SET @v_taqprojectkey = NULL
	SET @v_bookkey = NULL
	FETCH payments_from_cursor
	INTO @v_taqtaskkey, @v_taqprojectkey, @v_bookkey
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SET @v_desc = NULL
		SET @v_subdesc = NULL
		SET @v_sub2desc = NULL
		
		--IF @v_taqprojectkey IS NOT NULL
		--BEGIN
		--	SELECT @v_desc = taqprojecttitle + '/Contract'
		--	FROM taqproject
		--	WHERE taqprojectkey = @v_taqprojectkey
		--END
		--ELSE
		IF @v_bookkey IS NOT NULL
		BEGIN
			SELECT @v_desc = title
			FROM book
			WHERE bookkey = @v_bookkey
			
			IF @v_desc IS NOT NULL AND LEN(@v_desc) > 0
			BEGIN
				SELECT @v_subdesc = g.datadesc
				FROM gentables g
				JOIN bookdetail d
				ON (d.bookkey = @v_bookkey AND g.datacode = d.mediatypecode)
				WHERE g.tableid=312
				
				IF @v_subdesc IS NOT NULL AND LEN(@v_subdesc) > 0
				BEGIN
					SELECT @v_sub2desc = g.datadesc
					FROM subgentables g
					JOIN bookdetail d
					ON (d.bookkey = @v_bookkey AND g.datacode = d.mediatypecode AND g.datasubcode = d.mediatypesubcode)
					WHERE g.tableid=312
				END
				
				IF @v_sub2desc IS NOT NULL AND LEN(@v_sub2desc) > 0
				BEGIN
					SET @v_desc = @v_desc + '/' + @v_sub2desc
				END
				ELSE IF @v_subdesc IS NOT NULL AND LEN(@v_subdesc) > 0
				BEGIN
					SET @v_desc = @v_desc + '/' + @v_subdesc
				END
			END
		END
		
		IF @v_desc IS NOT NULL
		BEGIN
			INSERT INTO @task_table
			(taqtaskkey, fromtitle)
			VALUES
			(@v_taqtaskkey, @v_desc)
		END
		
		SET @v_taqprojectkey = NULL
		SET @v_bookkey = NULL
		FETCH payments_from_cursor
		INTO @v_taqtaskkey, @v_taqprojectkey, @v_bookkey
	END
  
  CLOSE payments_from_cursor
	DEALLOCATE payments_from_cursor 
	
	SET @v_taqtaskkey = NULL
	SET @v_desc = NULL

	SELECT @v_taqtaskkey = t.taqtaskkey, @v_desc = p.taqprojecttitle
	FROM taqprojecttask t, taqproject p
	WHERE t.datetypecode = @i_datetypecode
		AND t.taqprojectkey = @i_projectkey
		AND p.taqprojectkey = t.taqprojectkey
		
	IF @v_taqtaskkey IS NOT NULL AND @v_desc IS NOT NULL
	BEGIN
		SET @v_desc = @v_desc + '/Contract'
		
		INSERT INTO @task_table
		(taqtaskkey, fromtitle)
		VALUES
		(@v_taqtaskkey, @v_desc)
	END
  
  SELECT DISTINCT *
  FROM @task_table
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error getting calculated from info for contracts (' + cast(@v_error AS VARCHAR) + '): taqtaskkey=' + cast(@i_datetypecode AS VARCHAR)   
  END
    
END
go

GRANT EXEC ON qcontract_get_payments_calculated_from TO PUBLIC
GO

