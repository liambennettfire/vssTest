if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_scaleadmintabs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_scaleadmintabs
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_scaleadmintabs
 (@i_scaletypecode        integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_scaleadmintabs
**  Desc: This procedure returns rows for the scale admin tabs tab
**
**	Auth: Dustin Miller
**	Date: February 22 2012
*******************************************************************************/

  DECLARE @v_scaletabkey	INT,
					@v_tabsectiontype	INT,
					@v_tablabel	VARCHAR(255),
					@v_rowspeckey	INT,
					@v_columnspeckey	INT,
					@v_rowscaleadminspeckey	INT,
					@v_rowitemcategorycode	INT,
					@v_rowitemcode	INT,
					@v_rowparametertypecode	INT,
					@v_rowparametervaluecode	INT,
					@v_columnscaleadminspeckey	INT,
					@v_columnitemcategorycode	INT,
					@v_columnitemcode	INT, 
					@v_columnparametertypecode	INT,
					@v_columnparametervaluecode	INT,
					@v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @tabs_results_table TABLE
	(
		scaletabkey	INT,
		tabsectiontype	INT,
		tablabel	VARCHAR(255),
		rowspeckey	INT,
		columnspeckey	INT,
		rowscaleadminspeckey	INT,
		rowitemcategorycode	INT, 
		rowitemcode	INT,
		rowparametertypecode	INT,
		rowparametervaluecode	INT,
		columnscaleadminspeckey	INT,
		columnitemcategorycode	INT,
		columnitemcode	INT, 
		columnparametertypecode	INT,
		columnparametervaluecode	INT
	)
  
  DECLARE tab_cursor CURSOR FOR
	SELECT scaletabkey, tabsectiontype, tablabel, rowspeckey, columnspeckey
	FROM taqscaleadmintab
	WHERE scaletypecode=@i_scaletypecode

	OPEN tab_cursor

	FETCH tab_cursor
	INTO @v_scaletabkey, @v_tabsectiontype, @v_tablabel, @v_rowspeckey, @v_columnspeckey

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		IF @v_tabsectiontype = 1
		BEGIN
			SELECT @v_rowscaleadminspeckey=r.scaleadminspeckey, 
			@v_rowitemcategorycode=r.itemcategorycode, 
			@v_rowitemcode=r.itemcode, 
			@v_rowparametertypecode=r.parametertypecode, 
			@v_rowparametervaluecode=r.parametervaluecode,
			@v_columnscaleadminspeckey=c.scaleadminspeckey, 
			@v_columnitemcategorycode=c.itemcategorycode, 
			@v_columnitemcode=c.itemcode, 
			@v_columnparametertypecode=c.parametertypecode, 
			@v_columnparametervaluecode=c.parametervaluecode
			FROM taqscaleadmintab t, taqscaleadminspecitem r, taqscaleadminspecitem c
			WHERE t.scaletabkey=@v_scaletabkey
			AND t.scaletabkey=r.scaletabkey AND t.scaletabkey=c.scaletabkey
			AND r.parametertypecode=2 AND c.parametertypecode=r.parametertypecode
			AND (t.rowspeckey=r.scaleadminspeckey AND t.columnspeckey=c.scaleadminspeckey)
			AND t.scaletypecode=@i_scaletypecode
			
			INSERT INTO @tabs_results_table
			VALUES
			(@v_scaletabkey, @v_tabsectiontype, @v_tablabel, @v_rowspeckey, @v_columnspeckey,
			@v_rowscaleadminspeckey, @v_rowitemcategorycode, @v_rowitemcode, @v_rowparametertypecode,
			@v_rowparametervaluecode, @v_columnscaleadminspeckey, @v_columnitemcategorycode, @v_columnitemcode,
			@v_columnparametertypecode, @v_columnparametervaluecode)
			
		END
		ELSE BEGIN
			INSERT INTO @tabs_results_table
			(scaletabkey, tabsectiontype, tablabel, rowspeckey, columnspeckey)
			VALUES
			(@v_scaletabkey, @v_tabsectiontype, @v_tablabel, @v_rowspeckey, @v_columnspeckey)
		END
	
		FETCH tab_cursor
		INTO @v_scaletabkey, @v_tabsectiontype, @v_tablabel, @v_rowspeckey, @v_columnspeckey
	END
	
	CLOSE tab_cursor
	DEALLOCATE tab_cursor 
	
	SELECT *
	FROM @tabs_results_table

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning scale admin tabs information (scaletypecode=' + cast(@i_scaletypecode as varchar) + ')'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_get_scaleadmintabs TO PUBLIC
GO