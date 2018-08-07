DECLARE @v_searchcriteriakey INT,
		@v_misckey INT 
 
 
  DECLARE crBookMiscItems CURSOR FOR
	SELECT searchcriteriakey 
	FROM bookmiscitems 
	WHERE searchcriteriakey is not null AND COALESCE(misckey, 0) > 0 
	GROUP BY searchcriteriakey
	HAVING count(searchcriteriakey) > 1 

  OPEN crBookMiscItems 

  FETCH NEXT FROM crBookMiscItems INTO @v_searchcriteriakey

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN  
    SELECT @v_misckey = misckey from qse_searchcriteria WHERE searchcriteriakey = @v_searchcriteriakey
    
    UPDATE bookmiscitems SET searchcriteriakey = NULL WHERE searchcriteriakey = @v_searchcriteriakey AND misckey <> @v_misckey
    
    FETCH NEXT FROM crBookMiscItems INTO @v_searchcriteriakey
  END /* WHILE FECTHING */

  CLOSE crBookMiscItems 
  DEALLOCATE crBookMiscItems   