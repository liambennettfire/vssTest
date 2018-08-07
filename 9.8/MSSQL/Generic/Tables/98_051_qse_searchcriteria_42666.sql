IF NOT EXISTS(SELECT * FROM qse_searchcriteria WHERE searchcriteriakey = 330) BEGIN

	INSERT INTO qse_searchcriteria
	  (searchcriteriakey, description, datatypecode, defaultoperator, detailcriteriaind, gentableid, allowmultiplerowsind)
	VALUES
	  (330, 'First Name', 1, 3, 0, NULL, 0)
END

IF NOT EXISTS(SELECT * FROM qse_searchcriteria WHERE searchcriteriakey = 331) BEGIN

	INSERT INTO qse_searchcriteria
	  (searchcriteriakey, description, datatypecode, defaultoperator, detailcriteriaind, gentableid, allowmultiplerowsind)
	VALUES
	  (331, 'First Name', 1, 3, 1, NULL, 0)
END

IF NOT EXISTS(SELECT * FROM qse_searchcriteria WHERE searchcriteriakey = 332) BEGIN

	INSERT INTO qse_searchcriteria
	  (searchcriteriakey, description, datatypecode, defaultoperator, detailcriteriaind, gentableid, allowmultiplerowsind)
	VALUES
	  (332, 'Participant First Name', 1, 3, 0, NULL, 0)
END

IF NOT EXISTS(SELECT * FROM qse_searchcriteria WHERE searchcriteriakey = 333) BEGIN

	INSERT INTO qse_searchcriteria
	  (searchcriteriakey, description, datatypecode, defaultoperator, detailcriteriaind, gentableid, allowmultiplerowsind)
	VALUES
	  (333, 'Author/Participant First Name', 1, 3, 1, NULL, 0)
END

IF NOT EXISTS(SELECT * FROM qse_searchcriteria WHERE searchcriteriakey = 334) BEGIN

	INSERT INTO qse_searchcriteria
	  (searchcriteriakey, description, datatypecode, defaultoperator, detailcriteriaind, gentableid, allowmultiplerowsind)
	VALUES
	  (334, 'Author First Name', 1, 3, 0, NULL, 1)
END

GO