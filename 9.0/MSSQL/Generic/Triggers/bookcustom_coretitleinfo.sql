IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_bookcustom') AND type = 'TR')
  DROP TRIGGER dbo.core_bookcustom
GO

CREATE TRIGGER core_bookcustom ON bookcustom
FOR INSERT, UPDATE AS

DECLARE @v_bookkey INT,
  @v_columnname VARCHAR(20),
  @v_corecolumn VARCHAR(20),
  @v_customcolumn VARCHAR(20),
  @v_format VARCHAR(15),
  @v_columnnumber TINYINT,
  @v_oldvalue FLOAT,
  @v_newvalue FLOAT,
  @v_tableid INT,
  @v_oldvalue_str VARCHAR(40),
  @v_newvalue_str VARCHAR(40),  
  @v_coltype CHAR(9),
  @v_num CHAR(2),
  @v_quote CHAR(1),
  @v_valuesclause VARCHAR(2000),
  @v_sqlstring NVARCHAR(4000)

SET @v_valuesclause = ''
SET @v_quote = CHAR(39)

/** Declare customfieldsetup cursor for custom fields that should be displayed in search results **/
DECLARE customfieldsetup_cur CURSOR FOR
  SELECT customfieldname, customfieldformat, corecustomcolnumber
  FROM customfieldsetup
  WHERE corecustomcolnumber IS NOT NULL
  ORDER BY corecustomcolnumber
		
OPEN customfieldsetup_cur 

/** Get the column name, format, and assigned coretitleinfo column number for each customfieldsetup record ***/
FETCH NEXT FROM customfieldsetup_cur
INTO @v_columnname, @v_format, @v_columnnumber
		
WHILE (@@FETCH_STATUS = 0)  /*customfieldsetup cursor LOOP*/
  BEGIN
	SET @v_coltype = SUBSTRING(@v_columnname, 1, 9)
	SET @v_num = RIGHT(@v_columnname, 2)

	/***** 10 columns of type Indicator *****/
	IF @v_coltype = 'customind' 
	  IF @v_num = '01'
		BEGIN
		  SET @v_customcolumn = 'customind01'

		  SELECT @v_oldvalue = d.customind01, @v_newvalue = i.customind01, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '02'
		BEGIN
		  SET @v_customcolumn = 'customind02'

		  SELECT @v_oldvalue = d.customind02, @v_newvalue = i.customind02, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '03'
		BEGIN
		  SET @v_customcolumn = 'customind03'

		  SELECT @v_oldvalue = d.customind03, @v_newvalue = i.customind03, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '04'
		BEGIN
		  SET @v_customcolumn = 'customind04'

		  SELECT @v_oldvalue = d.customind04, @v_newvalue = i.customind04, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '05'
		BEGIN
		  SET @v_customcolumn = 'customind05'

		  SELECT @v_oldvalue = d.customind05, @v_newvalue = i.customind05, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '06'
		BEGIN
		  SET @v_customcolumn = 'customind06'

		  SELECT @v_oldvalue = d.customind06, @v_newvalue = i.customind06, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '07'
		BEGIN
		  SET @v_customcolumn = 'customind07'

		  SELECT @v_oldvalue = d.customind07, @v_newvalue = i.customind07, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '08'
		BEGIN
		  SET @v_customcolumn = 'customind08'

		  SELECT @v_oldvalue = d.customind08, @v_newvalue = i.customind08, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '09'
		BEGIN
		  SET @v_customcolumn = 'customind09'

		  SELECT @v_oldvalue = d.customind09, @v_newvalue = i.customind09, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '10'
		BEGIN
		  SET @v_customcolumn = 'customind10'

		  SELECT @v_oldvalue = d.customind10, @v_newvalue = i.customind10, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END

	/***** 10 columns of type Drop-Down ****/
	IF @v_coltype = 'customcod'
	  IF @v_num = '01'
		BEGIN
		  SET @v_customcolumn = 'customcode01'
		  SET @v_tableid = 417

		  SELECT @v_oldvalue = d.customcode01, @v_newvalue = i.customcode01, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '02'
		BEGIN
		  SET @v_customcolumn = 'customcode02'
		  SET @v_tableid = 418

		  SELECT @v_oldvalue = d.customcode02, @v_newvalue = i.customcode02, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '03'
		BEGIN
		  SET @v_customcolumn = 'customcode03'
		  SET @v_tableid = 419

		  SELECT @v_oldvalue = d.customcode03, @v_newvalue = i.customcode03, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '04'
		BEGIN
		  SET @v_customcolumn = 'customcode04'
		  SET @v_tableid = 420

		  SELECT @v_oldvalue = d.customcode04, @v_newvalue = i.customcode04, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '05'
		BEGIN
		  SET @v_customcolumn = 'customcode05'
		  SET @v_tableid = 421

		  SELECT @v_oldvalue = d.customcode05, @v_newvalue = i.customcode05, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '06'
		BEGIN
		  SET @v_customcolumn = 'customcode06'
		  SET @v_tableid = 422

		  SELECT @v_oldvalue = d.customcode06, @v_newvalue = i.customcode06, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '07'
		BEGIN
		  SET @v_customcolumn = 'customcode07'
		  SET @v_tableid = 423

		  SELECT @v_oldvalue = d.customcode07, @v_newvalue = i.customcode07, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '08'
		BEGIN
		  SET @v_customcolumn = 'customcode08'
		  SET @v_tableid = 424

		  SELECT @v_oldvalue = d.customcode08, @v_newvalue = i.customcode08, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '09'
		BEGIN
		  SET @v_customcolumn = 'customcode09'
		  SET @v_tableid = 425

		  SELECT @v_oldvalue = d.customcode09, @v_newvalue = i.customcode09, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '10'
		BEGIN
		  SET @v_customcolumn = 'customcode10'
		  SET @v_tableid = 426

		  SELECT @v_oldvalue = d.customcode10, @v_newvalue = i.customcode10, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END

	/***** 10 columns of type Integer *****/
	IF @v_coltype = 'customint'
	  IF @v_num = '01'
		BEGIN
		  SET @v_customcolumn = 'customint01'

		  SELECT @v_oldvalue = d.customint01, @v_newvalue = i.customint01, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '02'
		BEGIN
		  SET @v_customcolumn = 'customint02'

		  SELECT @v_oldvalue = d.customint02, @v_newvalue = i.customint02, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '03'
		BEGIN
		  SET @v_customcolumn = 'customint03'

		  SELECT @v_oldvalue = d.customint03, @v_newvalue = i.customint03, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '04'
		BEGIN
		  SET @v_customcolumn = 'customint04'

		  SELECT @v_oldvalue = d.customint04, @v_newvalue = i.customint04, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '05'
		BEGIN
		  SET @v_customcolumn = 'customint05'

		  SELECT @v_oldvalue = d.customint05, @v_newvalue = i.customint05, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '06'
		BEGIN
		  SET @v_customcolumn = 'customint06'

		  SELECT @v_oldvalue = d.customint06, @v_newvalue = i.customint06, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '07'
		BEGIN
		  SET @v_customcolumn = 'customint07'

		  SELECT @v_oldvalue = d.customint07, @v_newvalue = i.customint07, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '08'
		BEGIN
		  SET @v_customcolumn = 'customint08'

		  SELECT @v_oldvalue = d.customint08, @v_newvalue = i.customint08, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '09'
		BEGIN
		  SET @v_customcolumn = 'customint09'

		  SELECT @v_oldvalue = d.customint09, @v_newvalue = i.customint09, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '10'
		BEGIN
		  SET @v_customcolumn = 'customint10'

		  SELECT @v_oldvalue = d.customint10, @v_newvalue = i.customint10, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END

	/***** 10 columns of type Float *****/
	IF @v_coltype = 'customflo'
	  IF @v_num = '01'
		BEGIN
		  SET @v_customcolumn = 'customfloat01'

		  SELECT @v_oldvalue = d.customfloat01, @v_newvalue = i.customfloat01, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '02'
		BEGIN
		  SET @v_customcolumn = 'customfloat02'

		  SELECT @v_oldvalue = d.customfloat02, @v_newvalue = i.customfloat02, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '03'
		BEGIN
		  SET @v_customcolumn = 'customfloat03'

		  SELECT @v_oldvalue = d.customfloat03, @v_newvalue = i.customfloat03, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '04'
		BEGIN
		  SET @v_customcolumn = 'customfloat04'

		  SELECT @v_oldvalue = d.customfloat04, @v_newvalue = i.customfloat04, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '05'
		BEGIN
		  SET @v_customcolumn = 'customfloat05'

		  SELECT @v_oldvalue = d.customfloat05, @v_newvalue = i.customfloat05, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '06'
		BEGIN
		  SET @v_customcolumn = 'customfloat06'

		  SELECT @v_oldvalue = d.customfloat06, @v_newvalue = i.customfloat06, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '07'
		BEGIN
		  SET @v_customcolumn = 'customfloat07'

		  SELECT @v_oldvalue = d.customfloat07, @v_newvalue = i.customfloat07, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '08'
		BEGIN
		  SET @v_customcolumn = 'customfloat08'

		  SELECT @v_oldvalue = d.customfloat08, @v_newvalue = i.customfloat08, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '09'
		BEGIN
		  SET @v_customcolumn = 'customfloat09'

		  SELECT @v_oldvalue = d.customfloat09, @v_newvalue = i.customfloat09, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END
	  ELSE IF @v_num = '10'
		BEGIN
		  SET @v_customcolumn = 'customfloat10'

		  SELECT @v_oldvalue = d.customfloat10, @v_newvalue = i.customfloat10, @v_bookkey = i.bookkey
		  FROM inserted i FULL OUTER JOIN deleted d ON i.bookkey = d.bookkey
		END


	/*** Compare new bookcustom value with the old value. If values are different, ***/
	/*** build the update statement for coretitleinfo table. If both values are the same ***/
	/*** (or NULL), continue to the next customfieldsetup row - nothing to do. ***/
	IF (@v_oldvalue IS NULL AND @v_newvalue IS NULL) OR (@v_oldvalue = @v_newvalue)
	  BEGIN
		FETCH NEXT FROM customfieldsetup_cur
		INTO @v_columnname, @v_format, @v_columnnumber
		
		CONTINUE
	  END
	ELSE
	  BEGIN
		/*** Check if new bookcustom value is different from that on coretitleinfo. ***/
		/*** To do that, bookcustom value must be converted to string in the exact format ***/
		/*** as stored on coretitleinfo search results (format provided by customfieldsetup) ***/
		SET @v_corecolumn = 'customfield' + CAST(@v_columnnumber AS VARCHAR(5))
		SET @v_sqlstring = N'SELECT @p_oldvalue_str = ' + @v_corecolumn +
			' FROM coretitleinfo ' +
			' WHERE bookkey = @p_bookkey AND printingkey = 1'
		
		EXECUTE sp_executesql @v_sqlstring, 
			N'@p_oldvalue_str VARCHAR(40) OUTPUT,@p_bookkey INT', 
			@v_oldvalue_str OUTPUT, @v_bookkey
		
		/*** For Drop-downs, get the gentables description as the new string value. ***/
		IF @v_coltype = 'customcod'	/*** Drop-Down ***/
		BEGIN
		  SET @v_sqlstring = N'SELECT @p_newvalue_str = datadesc' +
			' FROM gentables ' +
			' WHERE tableid = @p_tableid AND datacode = @p_datacode'

		  EXECUTE sp_executesql @v_sqlstring,
			N'@p_newvalue_str VARCHAR(40) OUTPUT,@p_tableid INT,@p_datacode FLOAT',
			@v_newvalue_str OUTPUT, @v_tableid, @v_newvalue
		END

		/*** For Indicators, set 'Yes' or 'No' on coretitle. ***/
		ELSE IF @v_coltype = 'customind'	/*** Indicator ***/
		  IF @v_newvalue = 1
			SET @v_newvalue_str = 'Yes'
		  ELSE
			SET @v_newvalue_str = 'No'

		/*** For all other numeric columns, call the qutl_format_string function ***/
		/*** to format the new bookcustom value to string the same was as coretitleinfo ***/
		/*** NOTE that @v_newvalue_str is an OUTPUT parameter ***/
		ELSE
		  SET @v_newvalue_str = dbo.qutl_format_string(@v_newvalue, @v_format)
				

		/*** If new value string differs from current coretitleinfo value, we must update - ***/
		/*** - build SQL update statement. If both values are the same (or NULL), ***/
		/*** continue to the next customfieldsetup row - nothing to do. ***/
		IF (@v_oldvalue_str IS NULL AND @v_newvalue_str IS NULL) OR (@v_oldvalue_str = @v_newvalue_str)
		  BEGIN
			FETCH NEXT FROM customfieldsetup_cur
			INTO @v_columnname, @v_format, @v_columnnumber
		
			CONTINUE
		  END
		ELSE
		  BEGIN
			SET @v_corecolumn = 'customfield' + CAST(@v_columnnumber AS VARCHAR(5))
			SET @v_newvalue_str = REPLACE(@v_newvalue_str, @v_quote, @v_quote + @v_quote)
		
			IF @v_valuesclause = ''
			  SET @v_valuesclause = @v_corecolumn + ' = ' + @v_quote + @v_newvalue_str + @v_quote
			ELSE
			  SET @v_valuesclause = @v_valuesclause + 
				', ' + @v_corecolumn + ' = ' + @v_quote + @v_newvalue_str + @v_quote
		  END
	END			
		
	FETCH NEXT FROM customfieldsetup_cur
	INTO @v_columnname, @v_format, @v_columnnumber

  END  /*customfieldsetup cursor LOOP*/

/** Close the cursor **/
CLOSE customfieldsetup_cur
DEALLOCATE customfieldsetup_cur		

/*** Build the update statement ***/
IF @v_valuesclause IS NOT NULL AND @v_valuesclause <> ''
  BEGIN
	SET @v_sqlstring = N'UPDATE coretitleinfo SET ' + @v_valuesclause + ' WHERE bookkey = @p_bookkey'

	EXECUTE sp_executesql @v_sqlstring, N'@p_bookkey INT', @v_bookkey
  END
	
GO
