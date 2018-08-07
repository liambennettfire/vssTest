DECLARE
	@v_taqprojectkey INT  
  
  DECLARE crTaqproject CURSOR FOR
	SELECT taqprojectkey
	FROM taqproject 
	WHERE searchitemcode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) AND 
		  templateind = 1 AND workkey IS NOT NULL
		  
  OPEN crTaqproject 

  FETCH NEXT FROM crTaqproject INTO @v_taqprojectkey

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
	UPDATE taqproject SET workkey = NULL 
	WHERE taqprojectkey = @v_taqprojectkey

    FETCH NEXT FROM crTaqproject INTO @v_taqprojectkey
  END /* WHILE FECTHING */

  CLOSE crTaqproject 
  DEALLOCATE crTaqproject 
