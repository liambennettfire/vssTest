DECLARE 
		@v_workfieldind TINYINT,
		@v_columnkey INT,
		@v_columndescription VARCHAR(40),
		@v_tablename VARCHAR(30),
		@v_columnname VARCHAR(30),
		@v_activeind TINYINT,
		@v_misctype INT
		
BEGIN
	DECLARE titlehistorycolumns_cur CURSOR FOR
		SELECT columnkey, workfieldind
		  FROM titlehistorycolumns
		 WHERE tablename = 'bookmisc' AND columnkey in (225,226,227,247,248)
		ORDER BY columnkey
		
	OPEN titlehistorycolumns_cur
	
	FETCH NEXT FROM titlehistorycolumns_cur INTO @v_columnkey, @v_workfieldind
	
	WHILE (@@FETCH_STATUS <> -1) BEGIN
		IF @v_columnkey = 225 BEGIN --Miscellaneous Item (Numeric)
			SELECT @v_misctype = datacode FROM gentables WHERE tableid = 464 AND datadesc = 'Numeric'
			UPDATE bookmiscitems 
			   SET propagatemiscitemind = @v_workfieldind,
			       lastmaintdate = GETDATE(),
			       lastuserid = 'FB_UPDATE_35718' 
			 WHERE misctype = @v_misctype
		END
		IF @v_columnkey = 226 BEGIN --Miscellaneous Item (Float)
			SELECT @v_misctype = datacode FROM gentables WHERE tableid = 464 AND datadesc = 'Float'
			UPDATE bookmiscitems 
			   SET propagatemiscitemind = @v_workfieldind,
			       lastmaintdate = GETDATE(),
			       lastuserid = 'FB_UPDATE_35718' 
			 WHERE misctype = @v_misctype
		END
		IF @v_columnkey = 227 BEGIN --Miscellaneous Item (Text)
			SELECT @v_misctype = datacode FROM gentables WHERE tableid = 464 AND datadesc = 'Text'
			UPDATE bookmiscitems 
			   SET propagatemiscitemind = @v_workfieldind,
			       lastmaintdate = GETDATE(),
			       lastuserid = 'FB_UPDATE_35718' 
			 WHERE misctype = @v_misctype
		END
		IF @v_columnkey = 247 BEGIN --Miscellaneous Item (Checkbox)
			SELECT @v_misctype = datacode FROM gentables WHERE tableid = 464 AND datadesc = 'Checkbox'
			UPDATE bookmiscitems 
			   SET propagatemiscitemind = @v_workfieldind,
			       lastmaintdate = GETDATE(),
			       lastuserid = 'FB_UPDATE_35718' 
			 WHERE misctype = @v_misctype
		END
		IF @v_columnkey = 248 BEGIN --Miscellaneous Item (Gentable)
			SELECT @v_misctype = datacode FROM gentables WHERE tableid = 464 AND datadesc = 'Gentable'
			UPDATE bookmiscitems 
			   SET propagatemiscitemind = @v_workfieldind,
			       lastmaintdate = GETDATE(),
			       lastuserid = 'FB_UPDATE_35718' 
			 WHERE misctype = @v_misctype
		END

		FETCH NEXT FROM titlehistorycolumns_cur INTO @v_columnkey, @v_workfieldind
	END
	
	CLOSE titlehistorycolumns_cur
	DEALLOCATE titlehistorycolumns_cur
END
go