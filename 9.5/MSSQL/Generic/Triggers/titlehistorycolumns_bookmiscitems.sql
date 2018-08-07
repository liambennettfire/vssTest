IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'titlehistorycolumns_bookmiscitems')
	BEGIN
		DROP  Trigger dbo.titlehistorycolumns_bookmiscitems
	END
GO

/******************************************************************************
**  Name: titlehistorycolumns_bookmiscitems
**  Desc: Set the propagateind to true/false for all misc items if propagation  
**        is changed to true/false for misc item title history column
**        Case 35718
**  Auth: Kusum 
**  Date: 06/08/2016
** 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------------
**  
*******************************************************************************/

CREATE TRIGGER [dbo].titlehistorycolumns_bookmiscitems ON [dbo].titlehistorycolumns
FOR INSERT, UPDATE AS

BEGIN

	DECLARE 
		@v_workfieldind TINYINT,
		@v_columnkey INT,
		@v_columndescription VARCHAR(40),
		@v_tablename VARCHAR(30),
		@v_columnname VARCHAR(30),
		@v_activeind TINYINT,
		@v_misctype INT
		
		
		SELECT @v_columnkey = i.columnkey, @v_columndescription = i.columndescription,
			@v_tablename = i.tablename, @v_columnname = i.columnname, @v_activeind = i.activeind, 
			@v_workfieldind = workfieldind
	      FROM inserted i
	
	
		IF @v_tablename <> 'bookmisc' RETURN
		IF @v_columnkey = 270 RETURN  -- Misc. Item Send to Eloquence
		
		IF @v_columnkey = 225 BEGIN --Miscellaneous Item (Numeric)
			SELECT @v_misctype = datacode FROM gentables WHERE tableid = 464 AND datadesc = 'Numeric'
			UPDATE bookmiscitems SET propagatemiscitemind = @v_workfieldind WHERE misctype = @v_misctype
		END
		IF @v_columnkey = 226 BEGIN --Miscellaneous Item (Float)
			SELECT @v_misctype = datacode FROM gentables WHERE tableid = 464 AND datadesc = 'Float'
			UPDATE bookmiscitems SET propagatemiscitemind = @v_workfieldind WHERE misctype = @v_misctype
		END
		IF @v_columnkey = 227 BEGIN --Miscellaneous Item (Text)
			SELECT @v_misctype = datacode FROM gentables WHERE tableid = 464 AND datadesc = 'Text'
			UPDATE bookmiscitems SET propagatemiscitemind = @v_workfieldind WHERE misctype = @v_misctype
		END
		IF @v_columnkey = 247 BEGIN --Miscellaneous Item (Checkbox)
			SELECT @v_misctype = datacode FROM gentables WHERE tableid = 464 AND datadesc = 'Checkbox'
			UPDATE bookmiscitems SET propagatemiscitemind = @v_workfieldind WHERE misctype = @v_misctype
		END
		IF @v_columnkey = 248 BEGIN --Miscellaneous Item (Gentable)
			SELECT @v_misctype = datacode FROM gentables WHERE tableid = 464 AND datadesc = 'Gentable'
			UPDATE bookmiscitems SET propagatemiscitemind = @v_workfieldind WHERE misctype = @v_misctype
		END
END
GO