IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 8 AND searchcriteriakey = 330) BEGIN
	INSERT INTO qse_searchtypecriteria  -- WEB Contacts
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(8, 330, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 8 AND searchcriteriakey = 331) BEGIN
	INSERT INTO qse_searchtypecriteria   -- WEB Contacts
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(8, 331, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 7 AND searchcriteriakey = 331) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Projects
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(7, 331, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 18 AND searchcriteriakey = 331) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Journals
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(18, 331, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 22 AND searchcriteriakey = 331) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Works
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(22, 331, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 24 AND searchcriteriakey = 331) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Scales
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(24, 331, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 25 AND searchcriteriakey = 331) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Contracts
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(25, 331, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 28 AND searchcriteriakey = 331) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Printings
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(28, 331, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 29 AND searchcriteriakey = 331) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Purchase Orders
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(29, 331, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 6 AND searchcriteriakey = 331) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Titles
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(6, 331, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 7 AND searchcriteriakey = 332) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Projects
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(7, 332, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 18 AND searchcriteriakey = 332) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Journals
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(18, 332, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 22 AND searchcriteriakey = 332) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Works
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(22, 332, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 24 AND searchcriteriakey = 332) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Scales
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(24, 332, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 25 AND searchcriteriakey = 332) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Contracts
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(25, 332, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 28 AND searchcriteriakey = 332) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Printings
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(28, 332, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 29 AND searchcriteriakey = 332) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Purchase Orders
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(29, 332, 'globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 7 AND searchcriteriakey = 333) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Projects
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(7, 333, 'temp_globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 22 AND searchcriteriakey = 333) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Works
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(22, 333, 'temp_globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 24 AND searchcriteriakey = 333) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Scales
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(24, 333, 'temp_globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 28 AND searchcriteriakey = 333) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Printings
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(28, 333, 'temp_globalcontact', 'firstname')
END
go

IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 29 AND searchcriteriakey = 333) BEGIN
	INSERT INTO qse_searchtypecriteria -- WEB Purchase Orders
	  (searchtypecode, searchcriteriakey, tablename, columnname)
	VALUES(29, 333, 'temp_globalcontact', 'firstname')
END
go


IF NOT EXISTS(SELECT * FROM qse_searchtypecriteria WHERE searchtypecode = 6 AND searchcriteriakey = 334) BEGIN
INSERT INTO qse_searchtypecriteria  -- WEB Titles
  (searchtypecode, searchcriteriakey, tablename, columnname)
VALUES(6, 334, 'UPPER(author', 'firstname)')
END
go