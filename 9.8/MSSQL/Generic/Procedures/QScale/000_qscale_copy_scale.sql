if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_copy_scale') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qscale_copy_scale
GO

CREATE PROCEDURE qscale_copy_scale (  
  @i_from_scaletype	INT,
  @i_to_scaletype		INT,
  @o_error_code			INT OUTPUT,
  @o_error_desc			VARCHAR(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qscale_copy_scale
**  Desc: This stored procedure deletes everything in taqscaleadminspecitem and taqscaleadmintab for the 'To' scale,
**		and replaes it with all the data from the 'From' scale.
**
**  Auth: Dustin Miller
**  Date: January 25 2012
*******************************************************************************************/
DECLARE
	@v_scaleadminspeckey	INT,
	@v_scaletypecode			INT,
	@v_itemcategorycode		INT,
	@v_itemcode						INT,
	@v_parametertypecode	INT,
	@v_parametervaluecode	INT,
	@v_messagetypecode		INT,
	@v_scaletabkey				INT,
	@v_fixedcostlabel			VARCHAR(20),
	@v_varcostlabel				VARCHAR(20),
	@v_lastuserid					VARCHAR(20),
	@v_lastmaintdate			DATETIME,
	@v_tabsectiontype			INT,
	@v_tablabel						VARCHAR(20),
	@v_rowspeckey					INT,
	@v_columnspeckey			INT,
	@v_newkey							INT,
	@v_newscaletabkey			INT,
	@v_oldscaletabkey			INT
    
BEGIN
	--taqscaleadmintab
	DELETE FROM taqscaleadmintab
	WHERE scaletypecode=@i_to_scaletype
	
	CREATE TABLE #tab_keychanges
	(
		scaletabkey_old	INT,
		scaletabkey_new INT
	)
	
	DECLARE tab_cur	CURSOR FOR
		SELECT scaletabkey, tabsectiontype, tablabel, rowspeckey, columnspeckey, lastuserid, lastmaintdate
		FROM taqscaleadmintab
		WHERE scaletypecode=@i_from_scaletype
	
	OPEN tab_cur
	FETCH tab_cur INTO @v_scaletabkey, @v_tabsectiontype, @v_tablabel, @v_rowspeckey, @v_columnspeckey,
		@v_lastuserid, @v_lastmaintdate
	
	WHILE @@fetch_status = 0
	BEGIN
		execute get_next_key @v_lastuserid, @v_newkey OUTPUT
	
		INSERT INTO taqscaleadmintab
		(scaletabkey, scaletypecode, tabsectiontype, tablabel, rowspeckey, columnspeckey, lastuserid, lastmaintdate)
		VALUES
		(@v_newkey, @i_to_scaletype, @v_tabsectiontype, @v_tablabel, @v_rowspeckey, @v_columnspeckey, @v_lastuserid, @v_lastmaintdate)
		
		INSERT INTO #tab_keychanges
		(scaletabkey_old, scaletabkey_new)
		VALUES
		(@v_scaletabkey, @v_newkey)
		
		FETCH tab_cur INTO @v_scaletabkey, @v_tabsectiontype, @v_tablabel, @v_rowspeckey, @v_columnspeckey,
			@v_lastuserid, @v_lastmaintdate
	END
	
	CLOSE tab_cur
	DEALLOCATE tab_cur

	--taqscaleadminspecitem
	DELETE FROM taqscaleadminspecitem
	WHERE scaletypecode=@i_to_scaletype
	
	DECLARE specitem_cur CURSOR FOR
		SELECT scaleadminspeckey, itemcategorycode, itemcode, parametertypecode, parametervaluecode,
			messagetypecode, scaletabkey, fixedcostlabel, varcostlabel, lastuserid, lastmaintdate
		FROM taqscaleadminspecitem
		WHERE scaletypecode=@i_from_scaletype
	
	OPEN specitem_cur
	FETCH specitem_cur INTO @v_scaleadminspeckey, @v_itemcategorycode, @v_itemcode, @v_parametertypecode, @v_parametervaluecode,
		@v_messagetypecode, @v_scaletabkey, @v_fixedcostlabel, @v_varcostlabel, @v_lastuserid, @v_lastmaintdate
  
  WHILE @@fetch_status = 0
  BEGIN
		execute get_next_key @v_lastuserid,@v_newkey OUTPUT
  
		INSERT INTO taqscaleadminspecitem
		(scaleadminspeckey, scaletypecode, itemcategorycode, itemcode, parametertypecode, parametervaluecode,
			messagetypecode, scaletabkey, fixedcostlabel, varcostlabel, lastuserid, lastmaintdate)
		VALUES
		(@v_newkey, @i_to_scaletype, @v_itemcategorycode, @v_itemcode, @v_parametertypecode, @v_parametervaluecode,
			@v_messagetypecode, @v_scaletabkey, @v_fixedcostlabel, @v_varcostlabel, @v_lastuserid, @v_lastmaintdate)
			
		UPDATE taqscaleadmintab
		SET rowspeckey=@v_newkey
		WHERE rowspeckey=@v_scaleadminspeckey AND scaletypecode=@i_to_scaletype
		
		UPDATE taqscaleadmintab
		SET columnspeckey=@v_newkey
		WHERE columnspeckey=@v_scaleadminspeckey AND scaletypecode=@i_to_scaletype
		
		SELECT @v_newscaletabkey=scaletabkey_new FROM #tab_keychanges WHERE scaletabkey_old=@v_scaletabkey
		IF @v_newscaletabkey IS NULL
		BEGIN
			SET @v_newscaletabkey = 0
		END
		
		UPDATE taqscaleadminspecitem
		SET scaletabkey=@v_newscaletabkey
		WHERE scaleadminspeckey=@v_newkey
		
		FETCH specitem_cur INTO @v_scaleadminspeckey, @v_itemcategorycode, @v_itemcode, @v_parametertypecode, @v_parametervaluecode,
			@v_messagetypecode, @v_scaletabkey, @v_fixedcostlabel, @v_varcostlabel, @v_lastuserid, @v_lastmaintdate
	END
	
	CLOSE specitem_cur
	DEALLOCATE specitem_cur
  
  RETURN  

  RETURN_ERROR:
    SET @o_error_code = -1
    RETURN
  
END
GO

GRANT EXEC ON qscale_copy_scale TO PUBLIC
GO
