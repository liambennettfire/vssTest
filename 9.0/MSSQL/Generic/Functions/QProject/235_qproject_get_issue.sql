if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qproject_get_issue') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qproject_get_issue
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION qproject_get_issue()

RETURNS		@issueinfo TABLE(
			journalkey INT,
			volumekey INT,
			issuekey INT,
			quantity1 INT,
			quantity2 INT,
			indicator1 INT,
			indicator2 INT,
			taqprojectrelationshipkey INT,
			keyind INT,
			relationshipaddtldesc VARCHAR(100),
			templateind INT
)
AS
BEGIN

  DECLARE	@v_journalkey integer,
			@v_volumekey integer,
			@v_issuekey integer,
			@v_itemtypecode integer,
			@v_usageclasscode integer,
			@v_thisrelationship_qsicode integer,
			@v_otherrelationship_qsicode integer,
			@v_count1 INT,
			@v_count2 INT,
			@v_quantity1 INT,
			@v_quantity2 INT,
			@v_indicator1 INT,
			@v_indicator2 INT,
			@v_taqprojectrelationshipkey INT,
			@v_keyind INT,
			@v_relationshipaddtldesc VARCHAR(100),
			@v_templateind INT

          
  -- get usageclass and itemtype based on qsicode
  SELECT @v_itemtypecode = datacode,
         @v_usageclasscode = datasubcode
    FROM subgentables
   WHERE tableid = 550
     AND qsicode = 5  -- issue
     
  IF @v_itemtypecode > 0 AND @v_usageclasscode > 0 BEGIN
    DECLARE temp_cur CURSOR fast_forward FOR
     SELECT taqprojectkey,COALESCE(templateind,0)
       FROM taqproject
      WHERE searchitemcode = @v_itemtypecode
        AND usageclasscode = @v_usageclasscode

    OPEN temp_cur

    FETCH from temp_cur INTO @v_issuekey,@v_templateind

    WHILE @@fetch_status = 0 BEGIN
      -- get volumekey from relationship
      SET @v_thisrelationship_qsicode = 3 -- Issue
      SET @v_otherrelationship_qsicode = 2 -- Volume
    	SELECT @v_volumekey = dbo.qproject_get_otherprojectkey(@v_issuekey,@v_thisrelationship_qsicode,@v_otherrelationship_qsicode)

      -- get journalkey from relationship
      SET @v_thisrelationship_qsicode = 3 -- Issue
      SET @v_otherrelationship_qsicode = 1 -- Journal
    	SELECT @v_journalkey = dbo.qproject_get_otherprojectkey(@v_issuekey,@v_thisrelationship_qsicode,@v_otherrelationship_qsicode)


		  -- setup variables and pull the data from taqprojectrelationship...
		  -- reinitialize the variable each iteration
		  SET @v_count1 = 0
		  SET @v_count2 = 0
  	
		  SELECT @v_count1 = COUNT(*)
			  FROM taqprojectrelationship
		  WHERE taqprojectkey2 = @v_volumekey AND taqprojectkey1 = @v_issuekey
		  
			--volume to issue
		  SELECT @v_count2 = COUNT(*)
			  FROM taqprojectrelationship
		  WHERE taqprojectkey1 = @v_volumekey AND taqprojectkey2 = @v_issuekey
  		
  	  -- Based on the rowcount above for this iteration, pull what we need and fill local variables then INSERT
	    IF @v_count1 > 0  
		    BEGIN
			    SELECT @v_quantity1 = quantity1, @v_quantity2 = quantity2, @v_indicator1 = indicator1, @v_indicator2 = indicator2, 
					       @v_taqprojectrelationshipkey = taqprojectrelationshipkey, @v_keyind = keyind, @v_relationshipaddtldesc = relationshipaddtldesc
				    FROM taqprojectrelationship
		       WHERE taqprojectkey2 = @v_volumekey AND taqprojectkey1 = @v_issuekey
		    END
	    ELSE IF @v_count2 > 0  
		    BEGIN
			    SELECT @v_quantity1 = quantity1, @v_quantity2 = quantity2, @v_indicator1 = indicator1, @v_indicator2 = indicator2, 
					    @v_taqprojectrelationshipkey = taqprojectrelationshipkey, @v_keyind = keyind, @v_relationshipaddtldesc = relationshipaddtldesc
				    FROM taqprojectrelationship
		    WHERE taqprojectkey1 = @v_volumekey AND taqprojectkey2 = @v_issuekey
		    END
	    ELSE
		    BEGIN
			    SET @v_quantity1 = NULL
			    SET @v_quantity2 = NULL
			    SET @v_indicator1 = NULL
			    SET @v_indicator2 = NULL
			    SET @v_taqprojectrelationshipkey = NULL
			    SET @v_keyind = NULL
			    SET @v_relationshipaddtldesc = NULL
		    END

    
      INSERT INTO @issueinfo (journalkey,volumekey,issuekey, quantity1, quantity2, indicator1, indicator2, taqprojectrelationshipkey, keyind, relationshipaddtldesc, templateind)
      VALUES (@v_journalkey,@v_volumekey,@v_issuekey, @v_quantity1, @v_quantity2, @v_indicator1, @v_indicator2, @v_taqprojectrelationshipkey, @v_keyind, @v_relationshipaddtldesc,@v_templateind)

    
      FETCH NEXT from temp_cur INTO @v_issuekey,@v_templateind
    END
    
    CLOSE temp_cur
    DEALLOCATE temp_cur
  END    

  RETURN
END


