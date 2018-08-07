DECLARE
	@v_resultsviewkey_title INT

	SELECT @v_resultsviewkey_title = resultsviewkey
	FROM qse_searchresultsview 
	WHERE searchtypecode = 6 AND
		  itemtypecode = 1 AND
		  userkey = -1
		  
	UPDATE qse_searchresultsviewlayout
	SET columnorder = 40 
	WHERE columnnumber = 40 AND
	  resultsviewkey  = @v_resultsviewkey_title		 
GO	   
		  