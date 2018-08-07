IF NOT EXISTS (SELECT [name] FROM sys.tables WHERE [name] = 'gentablesusersettings')
BEGIN
	CREATE TABLE gentablesusersettings
	(
		tableid INT NOT NULL,
		userkey INT NOT NULL,
		favoriteind TINYINT NOT NULL DEFAULT(0),
		lastaccessdate DATETIME,
		hiddenind TINYINT NOT NULL DEFAULT(0),
		lastuserid VARCHAR(30),
		lastmaintdate DATETIME,
		PRIMARY KEY (tableid)
	)

	CREATE INDEX gentablesusersettings_tableid
	ON gentablesusersettings (tableid)

	CREATE INDEX gentablesusersettings_userkey
	ON gentablesusersettings (userkey)
END