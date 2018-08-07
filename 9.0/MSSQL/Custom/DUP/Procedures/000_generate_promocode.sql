
ALTER PROCEDURE [dbo].[generate_promocode]
  @i_projectkey         INT,
  @i_elementkey         INT,
  @i_related_journalkey	INT,
  @i_productidcode      INT,
  @o_result             VARCHAR(50) OUTPUT,
  @o_error_code         INT OUTPUT,
  @o_error_desc         VARCHAR(2000) OUTPUT
AS



/*********************************************************************************************
BL: 11/22/10: removing related journal logic, now will get the acronym directly from the project itself.  leaving the @i_related_journalkey parameter so tmmweb code
doesnt have to change
Duke Project Detail enhancements
Case 5461 - Promotional Code

DUKE Promotional Code components:
    1. a two-digit abbreviation of the journal - take the acronym (tableid=594, datacode=4) - changed to orgentry
    2. abbreviation of the fiscal year, - last two digits of fiscal year
    3. a letter (usually single but sometimes two) indicating the type of project,  -  take from project type shortdesc (tableid=521)
    4. a # for the count of this type of project created for the year,  - will need to do a count of existing projects that fiscal year, for that project type (tableid=521)
    5. and a sixth digit for a letter
    
NOTE: Based on Duke setup, Promotional Code is valid on Marketing Project.
******************************************************************************************/

DECLARE
  @v_acronym  VARCHAR(20),
  @v_char CHAR(1),
  @v_count  INT,
  @v_datacode INT,
  @v_fiscalyear VARCHAR(40),
  @v_itemtype INT,
  @v_journal_rel_qsicode  INT,
  @v_journalkey INT,
  @v_number INT,
  @v_projectkey INT,
  @v_projecttypecode INT,
  @v_projecttype  VARCHAR(40),
  @v_shortdesc  VARCHAR(20),
  @v_this_rel_qsicode INT,
  @v_usageclass INT,
  @v_yearcode INT,
  @v_journal_rel_qsicode_issue INT	
  
BEGIN
 
  SET @v_char ='J'	
  SET @o_error_code = 0
  SET @o_error_desc = ''  
  SET @o_result = ''  
  
  IF @i_projectkey > 0  --Project or Journal
  BEGIN
   
   --Get the Acronym for the related Journal
  SELECT @v_count = COUNT(*)
  FROM orgentry o, taqprojectorgentry t
  WHERE o.orgentrykey = t.orgentrykey 
  and t.taqprojectkey=@i_projectkey AND t.orglevelkey=3
      
      
  IF @v_count > 0
    BEGIN
      SELECT @v_acronym = coalesce(orgentryshortdesc,'')
      FROM orgentry o, taqprojectorgentry t
	  WHERE o.orgentrykey = t.orgentrykey 
	  and t.taqprojectkey=@i_projectkey AND t.orglevelkey=3
      
          
      IF @v_acronym IS NULL OR LTRIM(RTRIM(@v_acronym)) = ''
      BEGIN
        SET @o_error_code = -2 --warning for dbchange_request procedure
        SET @o_error_desc = 'Could not generate Promotional Code - Acronym not found on the related Journal.'
        RETURN            
      END
    END
  ELSE
    BEGIN
      SET @o_error_code = -2 --warning for dbchange_request procedure
      SET @o_error_desc = 'Could not generate Promotional Code - Acronym not found on the related Journal.'
      RETURN
    END


  SELECT @v_count = COUNT(*)
  FROM taqproductnumbers
  WHERE taqprojectkey = @i_projectkey AND productidcode = 15

  IF @v_count > 0  
    SELECT @v_fiscalyear = substring(productnumber,len(productnumber),1)
    FROM taqproductnumbers 
    WHERE taqprojectkey = @i_projectkey AND productidcode = 15


  ELSE
    BEGIN
      SET @o_error_code = -2 --warning for dbchange_request procedure
      SET @o_error_desc = 'Could not generate Promotional Code - Fiscal Year does not exist on project.'
      RETURN    
    END
  
  
  -- Get short description of the Project Type
  SELECT @v_projecttypecode = taqprojecttype
  FROM taqproject
  WHERE taqprojectkey = @i_projectkey
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 521 AND datacode = @v_projecttypecode

  IF @v_count > 0  
    SELECT @v_projecttype = datadesc, @v_shortdesc = datadescshort
    FROM gentables
    WHERE tableid = 521 AND datacode = @v_projecttypecode
  ELSE
    BEGIN
      SET @o_error_code = -2 --warning for dbchange_request procedure
      SET @o_error_desc = 'Could not generate Promotional Code - unknown Project Type.'
      RETURN    
    END  
  
  IF @v_shortdesc IS NULL OR LTRIM(RTRIM(@v_shortdesc)) = ''
    SET @v_projecttype = LEFT(@v_projecttype, 2)
  ELSE
    SET @v_projecttype = LEFT(@v_shortdesc, 2)
  
  --PRINT '@v_projecttype: ' + @v_projecttype
  
  -- Get the current number of projects of this type for the current fiscal year
  SELECT @v_number = COUNT(*)
  FROM taqproject p 
  WHERE p.taqprojectkey <> @i_projectkey AND
      p.taqprojecttype = @v_projecttypecode AND
      EXISTS (SELECT * FROM taqproductnumbers m
      WHERE m.taqprojectkey = p.taqprojectkey AND
            m.productidcode = 15 AND
            substring(m.productnumber,len(m.productnumber),1) = @v_fiscalyear)
  
  SET @v_number = @v_number + 1
  
  SET @o_result =  @v_projecttype + @v_acronym + @v_fiscalyear + CONVERT(VARCHAR, @v_number) + @v_char
    
  --PRINT @o_result
  
 END
END

----    -- Check itemtype/usageclass of this project/journal
----    SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
----    FROM taqproject 
----    WHERE taqprojectkey = @i_projectkey
----	 
----    IF @v_itemtype = 6  --Journal
----    BEGIN
----      IF @i_related_journalkey > 0
----        SET @v_journalkey = @i_related_journalkey
----      ELSE
----        BEGIN
----          -- If the current project is a journal, use the projectkey
----          IF @v_usageclass = 1
----            SET @v_journalkey = @i_projectkey
----          ELSE
----            BEGIN
----              -- Get the related Journal
----              -- NOTE: Relationship qsicode for journals (gentable 582) corresponds to Usage Class datacode (subgentable 550)
----              SET @v_this_rel_qsicode = @v_usageclass
----              SET @v_journal_rel_qsicode = 1
----              SET @v_journalkey = COALESCE(dbo.qproject_get_otherprojectkey(@i_projectkey, @v_this_rel_qsicode, @v_journal_rel_qsicode),0)
----            END
----        END      
----    END
----    
----    IF @v_itemtype = 3 and @v_usageclass<>19 --Project but not mailing list
----    BEGIN
----      IF @i_related_journalkey > 0
----        SET @v_journalkey = @i_related_journalkey
----      ELSE
----        BEGIN
----          -- Get the related Journal
----          SET @v_this_rel_qsicode = 12    --Project 1/5/10: changed to marketing project
----          SET @v_journal_rel_qsicode = 11 --Journal (for Project)
----		  SET @v_journal_rel_qsicode_issue = 14 -- issue (for project)	
----          SET @v_journalkey = COALESCE(dbo.qproject_get_otherprojectkey(@i_projectkey, @v_this_rel_qsicode, @v_journal_rel_qsicode),0)
----		  IF @v_journalkey <1
----			begin
----				SET @v_journalkey = COALESCE(dbo.qproject_get_otherprojectkey(@i_projectkey, @v_this_rel_qsicode, @v_journal_rel_qsicode_issue),0)
----			end
----        END   
----		
----    END
----	IF @v_itemtype = 3 and @v_usageclass=19 --mailing list
----    BEGIN
----      IF @i_related_journalkey > 0
----        SET @v_journalkey = @i_related_journalkey
----      ELSE
----        BEGIN
----          -- Get the related Journal
----          SET @v_this_rel_qsicode = 13    --Project 1/5/10: changed to mailing list
----          SET @v_journal_rel_qsicode = 11 --Journal (for Project)
----          SET @v_journal_rel_qsicode_issue = 14 -- issue (for project)	
----          SET @v_journalkey = COALESCE(dbo.qproject_get_otherprojectkey(@i_projectkey, @v_this_rel_qsicode, @v_journal_rel_qsicode),0)
----		  IF @v_journalkey <1
----			begin
----				SET @v_journalkey = COALESCE(dbo.qproject_get_otherprojectkey(@i_projectkey, @v_this_rel_qsicode, @v_journal_rel_qsicode_issue),0)
----			end
----		END      
----    END
----
----
----  END --@i_projectkey > 0
----
----
------select COALESCE(dbo.qproject_get_otherprojectkey(600195, 10, 11),0)
----
----
----    
----  ELSE IF @i_elementkey > 0 --Element
----  BEGIN
----    SET @o_error_code = -2 --warning for dbchange_request procedure
----    SET @o_error_desc = 'Missing Promotional Code generation algorithm for Elements.'
----    RETURN
----  END --IF @i_elementkey > 0
----
----
----  --PRINT '@v_journalkey: ' + CONVERT(VARCHAR, @v_journalkey)
----
----  -- Get the Acronym for the related Journal
------  SELECT @v_count = COUNT(*)
------  FROM taqproductnumbers
------  WHERE taqprojectkey = @v_journalkey AND
------      productidcode = (SELECT datacode FROM gentables WHERE tableid = 594 AND qsicode = 4)
------      
------  IF @v_count > 0
------    BEGIN
------      SELECT @v_acronym = productnumber
------      FROM taqproductnumbers
------      WHERE taqprojectkey = @v_journalkey AND
------          productidcode = (SELECT datacode FROM gentables WHERE tableid = 594 AND qsicode = 4)
------          
------      IF @v_acronym IS NULL OR LTRIM(RTRIM(@v_acronym)) = ''
------      BEGIN
------        SET @o_error_code = -2 --warning for dbchange_request procedure
------        SET @o_error_desc = 'Could not generate Promotional Code - Acronym not found on the related Journal.'
------        RETURN            
------      END
------    END
------  ELSE
------    BEGIN
------      SET @o_error_code = -2 --warning for dbchange_request procedure
------      SET @o_error_desc = 'Could not generate Promotional Code - Acronym not found on the related Journal.'
------      RETURN
------    END
--
--   --Get the Acronym for the related Journal
--  SELECT @v_count = COUNT(*)
--  FROM orgentry o, taqprojectorgentry t
--  WHERE o.orgentrykey = t.orgentrykey 
--  and t.taqprojectkey=@v_journalkey AND t.orglevelkey=3
--      
--      
--  IF @v_count > 0
--    BEGIN
--      SELECT @v_acronym = coalesce(orgentryshortdesc,'')
--      FROM orgentry o, taqprojectorgentry t
--	  WHERE o.orgentrykey = t.orgentrykey 
--	  and t.taqprojectkey=@v_journalkey AND t.orglevelkey=3
--      
--          
--      IF @v_acronym IS NULL OR LTRIM(RTRIM(@v_acronym)) = ''
--      BEGIN
--        SET @o_error_code = -2 --warning for dbchange_request procedure
--        SET @o_error_desc = 'Could not generate Promotional Code - Acronym not found on the related Journal.'
--        RETURN            
--      END
--    END
--  ELSE
--    BEGIN
--      SET @o_error_code = -2 --warning for dbchange_request procedure
--      SET @o_error_desc = 'Could not generate Promotional Code - Acronym not found on the related Journal.'
--      RETURN
--    END
--
--
--  -- Get the Fiscal Year misc value for this project
--  -- this was changed to get from the productid table
----  SELECT @v_count = COUNT(*)
----  FROM taqprojectmisc
----  WHERE taqprojectkey = @i_projectkey AND misckey = 18
----
----  IF @v_count > 0  
----    SELECT @v_datacode = i.datacode, @v_yearcode = m.longvalue
----    FROM taqprojectmisc m, bookmiscitems i
----    WHERE m.misckey = i.misckey AND
----        m.taqprojectkey = @i_projectkey AND 
----        m.misckey = 18
--
--  SELECT @v_count = COUNT(*)
--  FROM taqproductnumbers
--  WHERE taqprojectkey = @i_projectkey AND productidcode = 15
--
--  IF @v_count > 0  
--    SELECT @v_fiscalyear = substring(productnumber,3,2)
--    FROM taqproductnumbers 
--    WHERE taqprojectkey = @i_projectkey AND productidcode = 15
--
--
--  ELSE
--    BEGIN
--      SET @o_error_code = -2 --warning for dbchange_request procedure
--      SET @o_error_desc = 'Could not generate Promotional Code - Fiscal Year does not exist on project.'
--      RETURN    
--    END
--  
----  SELECT @v_fiscalyear = datadesc
----  FROM subgentables
----  WHERE tableid = 525 AND datacode = @v_datacode AND datasubcode = @v_yearcode
----  
----  SET @v_fiscalyear = RIGHT(@v_fiscalyear, 2)
--  
--  --PRINT '@v_fiscalyear: ' + @v_fiscalyear
--  
--  -- Get short description of the Project Type
--  SELECT @v_projecttypecode = taqprojecttype
--  FROM taqproject
--  WHERE taqprojectkey = @i_projectkey
--  
--  SELECT @v_count = COUNT(*)
--  FROM gentables
--  WHERE tableid = 521 AND datacode = @v_projecttypecode
--
--  IF @v_count > 0  
--    SELECT @v_projecttype = datadesc, @v_shortdesc = datadescshort
--    FROM gentables
--    WHERE tableid = 521 AND datacode = @v_projecttypecode
--  ELSE
--    BEGIN
--      SET @o_error_code = -2 --warning for dbchange_request procedure
--      SET @o_error_desc = 'Could not generate Promotional Code - unknown Project Type.'
--      RETURN    
--    END  
--  
--  IF @v_shortdesc IS NULL OR LTRIM(RTRIM(@v_shortdesc)) = ''
--    SET @v_projecttype = LEFT(@v_projecttype, 2)
--  ELSE
--    SET @v_projecttype = LEFT(@v_shortdesc, 2)
--  
--  --PRINT '@v_projecttype: ' + @v_projecttype
--  
--  -- Get the current number of projects of this type for the current fiscal year
--  SELECT @v_number = COUNT(*)
--  FROM taqproject p 
--  WHERE p.taqprojectkey <> @i_projectkey AND
--      p.taqprojecttype = @v_projecttypecode AND
--      EXISTS (SELECT * FROM taqproductnumbers m
--      WHERE m.taqprojectkey = p.taqprojectkey AND
--            m.productidcode = 15 AND
--            substring(m.productnumber,3,2) = @v_fiscalyear)
--  
--  SET @v_number = @v_number + 1
--  
--  --PRINT '@v_number: ' + CONVERT(VARCHAR, @v_number)
--  
--/*commented out by BAL on 1/11/10 per Jocelyn's request*/
--  -- Need random string value
----  SELECT @v_count = COUNT(*)
----  FROM clientdefaults
----  WHERE clientdefaultid = 10
----  
----  IF @v_count > 0  
----    SELECT @v_char = stringvalue
----    FROM clientdefaults
----    WHERE clientdefaultid = 10
----  ELSE
----    BEGIN
----      SET @o_error_code = -2 --warning for dbchange_request procedure
----      SET @o_error_desc = 'Could not generate Promotional Code - missing clientdefaults row for clientdefaultid=10.'
----      RETURN    
----    END  
--
--  --PRINT '@v_char: ' + @v_char
--  
--  SET @o_result =  @v_projecttype + @v_acronym + @v_fiscalyear + CONVERT(VARCHAR, @v_number) + @v_char
--    
--  --PRINT @o_result
--  
--END