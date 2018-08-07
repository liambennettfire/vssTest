IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_filterorglevel') AND type = 'TR')
	DROP TRIGGER dbo.core_filterorglevel
GO

CREATE TRIGGER core_filterorglevel ON filterorglevel
FOR UPDATE AS
IF UPDATE (filterorglevelkey)
BEGIN
	DECLARE @v_filterkey		INT,
		@v_filterorglevelkey 	INT,
		@v_bookkey		INT,
		@v_orgentrykey		INT,
		@v_orgentrydesc		VARCHAR(40)

	-- Get modified filterorglevel row's values
	SELECT @v_filterkey = i.filterkey,
	       @v_filterorglevelkey = i.filterorglevelkey
	FROM inserted i

	-- IMPRINT
	IF @v_filterkey = 15  
	  BEGIN
	    -- ALL titles on coretitle info need to be updated
	    DECLARE coretitle_cur CURSOR FOR
	      SELECT DISTINCT bookkey
	      FROM coretitleinfo

	    OPEN coretitle_cur
	    FETCH NEXT FROM coretitle_cur INTO @v_bookkey 

	    WHILE (@@FETCH_STATUS = 0)
	      BEGIN
			SELECT @v_orgentrykey = o.orgentrykey, 
				@v_orgentrydesc = o.orgentrydesc
			FROM bookorgentry bo, orgentry o
	    	WHERE bo.orgentrykey = o.orgentrykey AND
				bo.bookkey = @v_bookkey AND
				bo.orglevelkey = @v_filterorglevelkey

	      	UPDATE coretitleinfo
			SET imprintkey = @v_orgentrykey,
			    imprintname = @v_orgentrydesc
			WHERE bookkey = @v_bookkey

			FETCH NEXT FROM coretitle_cur INTO @v_bookkey 
	      END

	    CLOSE coretitle_cur 
	    DEALLOCATE coretitle_cur 
	  END


	-- TMM HEADER ORGLEVEL 1
	IF @v_filterkey = 16
	  BEGIN
	    -- ALL titles on coretitle info need to be updated
	    DECLARE coretitle_cur CURSOR FOR
	      SELECT DISTINCT bookkey
	      FROM coretitleinfo

	    OPEN coretitle_cur
	    FETCH NEXT FROM coretitle_cur INTO @v_bookkey 

	    WHILE (@@FETCH_STATUS= 0)
	      BEGIN
			SELECT @v_orgentrykey = o.orgentrykey, 
				@v_orgentrydesc = o.orgentrydesc
		 	FROM bookorgentry bo, orgentry o
			WHERE bo.orgentrykey = o.orgentrykey AND
				bo.bookkey = @v_bookkey AND
			  	bo.orglevelkey = @v_filterorglevelkey
   	      	
			UPDATE coretitleinfo
			SET tmmheaderorg1key = @v_orgentrykey,
			    tmmheaderorg1desc = @v_orgentrydesc
			WHERE bookkey = @v_bookkey

			FETCH NEXT FROM coretitle_cur INTO @v_bookkey 
	      END

	    CLOSE coretitle_cur 
	    DEALLOCATE coretitle_cur 
	  END


	-- TMM HEADER ORGLEVEL 2
	IF @v_filterkey = 17
	  BEGIN
	    -- ALL titles on coretitle info need to be updated
	    DECLARE coretitle_cur CURSOR FOR
	      SELECT DISTINCT bookkey
	      FROM coretitleinfo

	    OPEN coretitle_cur
	    FETCH NEXT FROM coretitle_cur INTO @v_bookkey 

	    WHILE (@@FETCH_STATUS = 0)
	      BEGIN
	      	SELECT @v_orgentrykey = o.orgentrykey, 
				@v_orgentrydesc = o.orgentrydesc
			FROM bookorgentry bo, orgentry o
		   	WHERE bo.orgentrykey = o.orgentrykey AND
				bo.bookkey = @v_bookkey AND
	  		bo.orglevelkey = @v_filterorglevelkey

			UPDATE coretitleinfo
			SET tmmheaderorg2key = @v_orgentrykey,
	       	    tmmheaderorg2desc = @v_orgentrydesc 
			WHERE bookkey = @v_bookkey

	      	FETCH NEXT FROM coretitle_cur INTO @v_bookkey 
	      END

	    CLOSE coretitle_cur 
	    DEALLOCATE coretitle_cur 
	  END

END
GO