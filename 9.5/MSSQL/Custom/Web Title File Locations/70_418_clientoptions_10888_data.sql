INSERT INTO clientoptions
	(optionid,
	optionname,
	optioncomment,
	optionvalue,
	lastuserid,
	lastmaintdate,
	optionmessage)
VALUES
	(77,
	'Use Web Title File Locations',
	'0 (default) TMM Desktop File Locations Only / 1 Title File Locations on Web',
	1,
	'QSIDBA',
	getdate(),
	NULL)
go
