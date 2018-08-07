IF NOT EXISTS (SELECT * FROM bookorgentry WHERE bookkey = 1153308) BEGIN
	INSERT INTO bookorgentry (bookkey, orgentrykey, orglevelkey, lastuserid, lastmaintdate)
	SELECT 1153308, orgentrykey, orglevelkey, 'Case 41626', getdate()
	FROM orgentry
	WHERE orgentrykey = 1

	INSERT INTO bookorgentry (bookkey, orgentrykey, orglevelkey, lastuserid, lastmaintdate)
	SELECT 1153308, orgentrykey, orglevelkey, 'Case 41626', getdate()
	FROM orgentry
	WHERE orgentrykey = 6

	INSERT INTO bookorgentry (bookkey, orgentrykey, orglevelkey, lastuserid, lastmaintdate)
	SELECT 1153308, orgentrykey, orglevelkey, 'Case 41626', getdate()
	FROM orgentry
	WHERE orgentrykey = 21
END