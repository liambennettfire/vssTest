DECLARE
  @v_contactkey  INT,
  @v_searchfield VARCHAR(2000)
  
BEGIN

	DECLARE cur_corecontact CURSOR FOR
	SELECT contactkey FROM corecontactinfo 
	FOR READ ONLY
  
	OPEN cur_corecontact

	FETCH NEXT FROM cur_corecontact INTO @v_contactkey
	WHILE (@@FETCH_STATUS <> -1) 	BEGIN
		/* Get searchfield data*/
		exec dbo.qcontact_get_corecontactinfo_searchfield @v_contactkey, @v_searchfield OUTPUT

		UPDATE corecontactinfo
		SET searchfield = @v_searchfield
		WHERE contactkey = @v_contactkey

		FETCH NEXT FROM cur_corecontact INTO @v_contactkey
	END

	CLOSE cur_corecontact 
	DEALLOCATE cur_corecontact

END
go