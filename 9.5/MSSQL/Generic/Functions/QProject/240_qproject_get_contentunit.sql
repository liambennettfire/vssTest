if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qproject_get_contentunit') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qproject_get_contentunit
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION qproject_get_contentunit()

RETURNS @contentunitinfo TABLE(
		journalkey INT,
		volumekey INT,
		issuekey INT,
		contentunitkey INT,
		doi varchar(75),
		issuename varchar(80),
		authorname varchar(255),
		authoremail varchar(100),
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

  DECLARE @v_journalkey integer,
		@v_volumekey integer,
		@v_issuekey integer,
		@v_contentunitkey integer,
		@v_itemtypecode integer,
		@v_usageclasscode integer,
		@v_thisrelationship_qsicode integer,
		@v_otherrelationship_qsicode integer,
		@v_doi varchar(255),
		@v_issuename varchar(80),
		@v_authorname varchar(255),
		@v_authoremail varchar(100),
		@v_authorrolecode integer,
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
     AND qsicode = 6  -- content unit
     
  IF @v_itemtypecode > 0 AND @v_usageclasscode > 0 BEGIN
    SELECT @v_authorrolecode = datacode
      FROM gentables
     WHERE tableid = 285
       AND qsicode = 4  -- author
  
    DECLARE temp_cur CURSOR fast_forward FOR
     SELECT taqprojectkey,COALESCE(templateind,0)
       FROM taqproject
      WHERE searchitemcode = @v_itemtypecode
        AND usageclasscode = @v_usageclasscode

    OPEN temp_cur

    FETCH from temp_cur INTO @v_contentunitkey,@v_templateind

    WHILE @@fetch_status = 0 BEGIN
      -- get issuekey from relationship
      SET @v_thisrelationship_qsicode = 4 -- Content Unit
      SET @v_otherrelationship_qsicode = 3 -- Issue
    	SELECT @v_issuekey = dbo.qproject_get_otherprojectkey(@v_contentunitkey,@v_thisrelationship_qsicode,@v_otherrelationship_qsicode)

      -- get volumekey from relationship
      SET @v_thisrelationship_qsicode = 4 -- Content Unit
      SET @v_otherrelationship_qsicode = 2 -- Volume
    	SELECT @v_volumekey = dbo.qproject_get_otherprojectkey(@v_contentunitkey,@v_thisrelationship_qsicode,@v_otherrelationship_qsicode)

      -- get journalkey from relationship
      SET @v_thisrelationship_qsicode = 4 -- Content Unit
      SET @v_otherrelationship_qsicode = 1 -- Journal
    	SELECT @v_journalkey = dbo.qproject_get_otherprojectkey(@v_contentunitkey,@v_thisrelationship_qsicode,@v_otherrelationship_qsicode)
            
      SELECT @v_doi = substring(dbo.qproject_get_misc_value(@v_contentunitkey,26),1,75)

      -- get issuename if contentunit is connected to an issue
      SET @v_issuename = null
      IF @v_issuekey > 0 BEGIN
        SELECT @v_issuename = projecttitle
          FROM coreprojectinfo c
         WHERE c.projectkey = @v_issuekey
      END
      
      -- first author name and email (qsicode = 4)
      SET @v_authorname = null
      SET @v_authoremail = null
      IF @v_authorrolecode > 0 BEGIN
        -- Get all participants of this Role, sorted 
        DECLARE contact_cur CURSOR fast_forward FOR 
         SELECT gc.displayname, gc.email
           FROM taqprojectcontact c, taqprojectcontactrole r, corecontactinfo gc
          WHERE c.taqprojectcontactkey = r.taqprojectcontactkey 
            and c.globalcontactkey = gc.contactkey 
            and c.taqprojectkey = @v_contentunitkey 
            and r.rolecode = @v_authorrolecode
       ORDER by c.sortorder ASC, gc.displayname ASC

        OPEN contact_cur
        
        /* Fetch and return the first participant of this role */
        FETCH contact_cur INTO @v_authorname,@v_authoremail

        CLOSE contact_cur 
        DEALLOCATE contact_cur    
      END 

		  -- setup variables and pull the data from taqprojectrelationship...
	    -- reinitialize the variable each iteration

		  SET @v_count1 = 0
		  SET @v_count2 = 0
  	
		  SELECT @v_count1 = COUNT(*)
			  FROM taqprojectrelationship
		  WHERE taqprojectkey2 = @v_contentunitkey AND taqprojectkey1 = @v_issuekey

		  SELECT @v_count2 = COUNT(*)
			  FROM taqprojectrelationship
		  WHERE taqprojectkey1 = @v_contentunitkey AND taqprojectkey2 = @v_issuekey
		
	    -- Based on the rowcount above for this iteration, pull what we need and fill local variables then INSERT

	    IF @v_count1 > 0  
		    BEGIN
			    SELECT @v_quantity1 = quantity1, @v_quantity2 = quantity2, @v_indicator1 = indicator1, @v_indicator2 = indicator2, 
					    @v_taqprojectrelationshipkey = taqprojectrelationshipkey, @v_keyind = keyind, @v_relationshipaddtldesc = relationshipaddtldesc
				    FROM taqprojectrelationship
		       WHERE taqprojectkey2 = @v_contentunitkey AND taqprojectkey1 = @v_issuekey
		    END

	    ELSE IF @v_count2 > 0  
		    BEGIN
			    SELECT @v_quantity1 = quantity1, @v_quantity2 = quantity2, @v_indicator1 = indicator1, @v_indicator2 = indicator2, 
					    @v_taqprojectrelationshipkey = taqprojectrelationshipkey, @v_keyind = keyind, @v_relationshipaddtldesc = relationshipaddtldesc
				    FROM taqprojectrelationship
		       WHERE taqprojectkey1 = @v_contentunitkey AND taqprojectkey2 = @v_issuekey
		    END

	    ELSE
		    BEGIN
    		
		      SET @v_count1 = 0
		      SET @v_count2 = 0
      	
		      SELECT @v_count1 = COUNT(*)
			      FROM taqprojectrelationship
		       WHERE taqprojectkey2 = @v_journalkey AND taqprojectkey1 = @v_contentunitkey

		      SELECT @v_count2 = COUNT(*)
			      FROM taqprojectrelationship
		       WHERE taqprojectkey1 = @v_journalkey AND taqprojectkey2 = @v_contentunitkey
    		
	        -- Based on the rowcount above for this iteration, pull what we need and fill local variables then INSERT

			    IF @v_count1 > 0  BEGIN
					    SELECT @v_quantity1 = quantity1, @v_quantity2 = quantity2, @v_indicator1 = indicator1, @v_indicator2 = indicator2, 
						    @v_taqprojectrelationshipkey = taqprojectrelationshipkey, @v_keyind = keyind, @v_relationshipaddtldesc = relationshipaddtldesc
					    FROM taqprojectrelationship
				    WHERE taqprojectkey2 = @v_journalkey AND taqprojectkey1 = @v_contentunitkey
				    END

				    ELSE IF @v_count2 > 0  
				    BEGIN
					    SELECT @v_quantity1 = quantity1, @v_quantity2 = quantity2, @v_indicator1 = indicator1, @v_indicator2 = indicator2, 
						    @v_taqprojectrelationshipkey = taqprojectrelationshipkey, @v_keyind = keyind, @v_relationshipaddtldesc = relationshipaddtldesc
					    FROM taqprojectrelationship
				    WHERE taqprojectkey1 = @v_journalkey AND taqprojectkey2 = @v_contentunitkey
			    END
		    END

      INSERT INTO @contentunitinfo (journalkey, volumekey, issuekey, contentunitkey, doi, issuename, authorname, authoremail, quantity1, quantity2, indicator1, indicator2, taqprojectrelationshipkey, keyind, relationshipaddtldesc, templateind )
      VALUES (@v_journalkey,@v_volumekey, @v_issuekey,@v_contentunitkey,@v_doi,@v_issuename,@v_authorname,@v_authoremail, @v_quantity1, @v_quantity2, @v_indicator1, @v_indicator2, @v_taqprojectrelationshipkey, @v_keyind, @v_relationshipaddtldesc, @v_templateind )

      FETCH NEXT from temp_cur INTO @v_contentunitkey,@v_templateind
    END

    CLOSE temp_cur
    DEALLOCATE temp_cur
  END    

  RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

