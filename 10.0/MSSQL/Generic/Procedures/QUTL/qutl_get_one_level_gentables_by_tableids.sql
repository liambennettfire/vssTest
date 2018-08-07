 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_one_level_gentables_by_tableids')
	BEGIN
		PRINT 'Dropping Procedure qutl_get_one_level_gentables_by_tableids'
		DROP  Procedure  qutl_get_one_level_gentables_by_tableids
	END

GO

-- Remove this file after version 6.1 has been installed at all locations.