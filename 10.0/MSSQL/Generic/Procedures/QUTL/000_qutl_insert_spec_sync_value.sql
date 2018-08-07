SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_insert_spec_sync_value')
  DROP  Procedure  qutl_insert_spec_sync_value
GO

CREATE PROCEDURE qutl_insert_spec_sync_value 
(@i_speccategorycode			INTEGER,
@i_specitemcode				INTEGER,
@i_itemtypecode				INTEGER,
@i_classcode				INTEGER,
@i_multicomptypekey			INTEGER,
@i_exceptioncode			INTEGER,
@i_syncfromspecsind			INTEGER,
@i_synctospecsind			INTEGER,
@i_specitemtype				VARCHAR (2),
@i_datatype					VARCHAR (10),
@i_tablename				VARCHAR (255),
@i_columnname				VARCHAR (255),
@i_mappingkey				INTEGER,
@i_parentspecitemcategory	INTEGER,
@i_firstprintonly			INTEGER,
@i_defaultuomvalue			INTEGER,
@o_error_code				INTEGER OUTPUT,
@o_error_desc				VARCHAR(2000) OUTPUT)

AS

/**********************************************************************************
**  Name: qutl_insert_spec_sync_value
**              
**    This procedure will check to see if the spec value row exists already on 
**    qsicinfigspecsync for the spec category/item, item type/class and table/column.               
**    If a row exists already, it is updated.  Otherwise it is inserted.  
**
**  Auth: SLB
**  Date: 08/11/2015
***********************************************************************************
**  Change History
***********************************************************************************
**  Date:     Author:   Description:
**  --------  -------   ------------
**  
***********************************************************************************/

DECLARE
@v_count				 INTEGER,
@v_max_code				 INTEGER,
@v_keycolumn1			 VARCHAR (255),
@v_keycolumn2			 VARCHAR (255),
@v_keycolumn3			 VARCHAR (255),
@v_qsiconfigspecsynckey  INTEGER


BEGIN

SET @v_count = 0	
SET @o_error_code = 0
SET @o_error_desc = ''

	
	/*check to see if the subgentables value exists*/
	SELECT @v_count = COUNT (*) 
	FROM subgentables
	WHERE tableid = 616 AND datacode = @i_speccategorycode AND datasubcode = @i_specitemcode

	IF @v_count = 0 BEGIN
		 SET @o_error_code = -1
		 SET @i_speccategorycode = COALESCE (@i_speccategorycode, 0)
		 SET @i_specitemcode = COALESCE (@i_specitemcode, 0)
		 SET @o_error_desc = 'Value does not exist on subgentables for tableid 616, datacode=' + CAST(@i_speccategorycode AS VARCHAR) + 
							' AND datasubcode=' + CAST(@i_specitemcode AS VARCHAR) 
		 RETURN
		 END

	SET @v_count = 0

	/* Set keycolumns based on tablename; almost all tables have key column 1 = bookkey and keycolumn2 = printingkey */
	SET @v_keycolumn1 = 'bookkey'

	IF @i_tablename IN ('bookdetail', 'booksimon')
		SET @v_keycolumn2 = NULL
	ELSE 
		SET @v_keycolumn2 = 'printingkey'	

	IF @i_tablename IN ('bindcolor', 'covercolor', 'covinsertcolor', 'endpcolor', 'jackcolor', 'secondcovcolor', 'textcolor')
		SET @v_keycolumn3  = 'colorkey'
	ELSE IF @i_tablename = 'component'
		SET @v_keycolumn3 = 'compkey'
	ELSE IF @i_tablename = 'jacketfoilcolors'
		SET @v_keycolumn3 = 'foilcolorkey'
	ELSE IF @i_tablename = 'illus'
		SET @v_keycolumn3 = 'groupnum'
	ELSE IF @i_tablename = 'materialspecs'
		SET @v_keycolumn3 = 'materialkey'
	ELSE
		SET @v_keycolumn3 = NULL


	/*check to see if the qsiconfigspecsync record exists*/
	SELECT @v_count = COUNT(*) FROM qsiconfigspecsync WHERE specitemcategory = @i_speccategorycode AND specitemcode = @i_specitemcode
		AND itemtype = @i_itemtypecode AND usageclass = @i_classcode AND tablename = @i_tablename AND columnname = @i_columnname

	IF @v_count > 0 
		UPDATE qsiconfigspecsync
		SET multicomptypekey = @i_multicomptypekey,exceptioncode = @i_exceptioncode,syncfromspecsind = @i_syncfromspecsind,
			synctospecsind = @i_synctospecsind, specitemtype = @i_specitemtype, datatype = @i_datatype,keycolumn1 = @v_keycolumn1,
			keycolumn2 = @v_keycolumn2,keycolumn3 = @v_keycolumn3, mappingkey = @i_mappingkey, lastuserid = 'qsiadmin', 
			lastmaintdate = GETDATE(), parentspecitemcategory = @i_parentspecitemcategory, firstprintonly = @i_firstprintonly,
			defaultuomvalue = @i_defaultuomvalue	
		WHERE specitemcategory = @i_speccategorycode AND specitemcode = @i_specitemcode
		AND itemtype = @i_itemtypecode AND usageclass = @i_classcode AND tablename = @i_tablename AND columnname = @i_columnname
	ELSE BEGIN
		INSERT INTO qsiconfigspecsync
			(specitemcategory, specitemcode, multicomptypekey, itemtype, usageclass, exceptioncode,
			 syncfromspecsind,synctospecsind, specitemtype, datatype,tablename, columnname, keycolumn1,keycolumn2, keycolumn3, 
			 mappingkey, activeind, lastuserid, lastmaintdate, parentspecitemcategory,firstprintonly, defaultuomvalue)
		VALUES 
			(@i_speccategorycode, @i_specitemcode, @i_multicomptypekey, @i_itemtypecode, @i_classcode, @i_exceptioncode,
			 @i_syncfromspecsind,@i_synctospecsind, @i_specitemtype, @i_datatype,@i_tablename, @i_columnname, @v_keycolumn1,@v_keycolumn2, @v_keycolumn3, 
			 @i_mappingkey, 1,'qsiadmin', GETDATE(),@i_parentspecitemcategory,@i_firstprintonly, @i_defaultuomvalue )
		END

	SELECT @o_error_code = @@ERROR
	IF @o_error_code <> 0 BEGIN
		 SET @i_speccategorycode = COALESCE (@i_speccategorycode, 0)
		 SET @i_specitemcode = COALESCE (@i_specitemcode, 0)
		 SET @o_error_desc = 'Error inserting/updating qsiconfigspecsync for spec category =' + CAST(@i_speccategorycode AS VARCHAR) + 
							' AND spec item =' + CAST(@i_specitemcode AS VARCHAR) 
		 RETURN
		 END   
END

GO
GRANT EXEC ON qutl_insert_spec_sync_value TO PUBLIC
GO