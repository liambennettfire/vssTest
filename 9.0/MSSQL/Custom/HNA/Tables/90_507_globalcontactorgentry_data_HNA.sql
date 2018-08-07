DECLARE 
	@v_count INT,
	@v_globalcontactkey INT,
	@v_orgentrykey INT


BEGIN

    SELECT TOP 1 @v_orgentrykey = orgentrykey FROM orgentry WHERE orglevelkey = 1
	
	DECLARE globalcontactorgentry_cur CURSOR FOR
		SELECT DISTINCT globalcontactkey FROM globalcontactorgentry WHERE orglevelkey>1 
		AND globalcontactkey NOT IN 
			(SELECT globalcontactkey FROM globalcontactorgentry WHERE orglevelkey=1)
		 ORDER BY globalcontactkey

	OPEN globalcontactorgentry_cur 
    FETCH NEXT FROM globalcontactorgentry_cur INTO @v_globalcontactkey

	WHILE (@@FETCH_STATUS <> -1) BEGIN
		IF NOT EXISTS (SELECT * FROM globalcontactorgentry WHERE globalcontactkey = @v_globalcontactkey
			AND orglevelkey = 1) BEGIN
			
			INSERT INTO globalcontactorgentry (globalcontactkey,orglevelkey,orgentrykey,lastuserid,lastmaintdate)
				VALUES (@v_globalcontactkey,1,@v_orgentrykey,'FB_INSERT_38468',getdate())	
				
			print 'insert into globalcontacorgentry for globalcontackey: ' + CONVERT(VARCHAR,@v_globalcontactkey)
			
		END
		FETCH NEXT FROM globalcontactorgentry_cur INTO @v_globalcontactkey
	END
	
	CLOSE globalcontactorgentry_cur
	DEALLOCATE globalcontactorgentry_cur
	
END 
go