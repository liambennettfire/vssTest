DECLARE @v_authorkey int, @v_bookkey int , @v_optionvalue int

  PRINT '-------- Authors fix --------'

  -- Get the optionvalue for clientoption for 'Use Contact Orgentry'
  SELECT @v_optionvalue = optionvalue
  FROM clientoptions
  WHERE optionid = 59

  IF @v_optionvalue = 1 BEGIN
	  DECLARE authors_cursor CURSOR FOR 
		 select authorkey,bookkey
		 from bookauthor
	
	  OPEN authors_cursor
	
	  FETCH NEXT FROM authors_cursor INTO @v_authorkey, @v_bookkey
	
	  PRINT '-------- updating --------'
	
	  WHILE @@FETCH_STATUS = 0
	  BEGIN
	
		  exec set_globalcontact_org @v_authorkey, @v_bookkey
	
		  -- Get the next author fix.
		  FETCH NEXT FROM authors_cursor INTO @v_authorkey, @v_bookkey
	
		END
	
		PRINT '-------- complete --------'
	
		CLOSE authors_cursor
		DEALLOCATE authors_cursor
	END
GO


