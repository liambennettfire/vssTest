SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'generate_doi')
  BEGIN
    DROP PROCEDURE generate_doi
  END
GO

CREATE PROCEDURE dbo.generate_doi
  @i_projectkey         INT,
  @i_elementkey         INT,
  @i_related_journalkey	INT,
  @i_productidcode      INT,
  @o_result             VARCHAR(50) OUTPUT,
  @o_error_code         INT OUTPUT,
  @o_error_desc         VARCHAR(2000) OUTPUT
AS

/*********************************************************************************************
Duke Project Detail enhancements
Case 5461 - DOI

DUKE DOI components:
    Publisher ID: 10.1215 
    After publisher ID, a forward slash ( / ) 
    ISSN: Data on journal record. Use 8 characters in string with no hyphenation. 
    Hyphen after ISSN string 
    4-digit item code assigned by TM system (at least 4 digits)
    
    Example: 10.1215/15476715-2136
    
    DOIs apply to Content Units or Elements
******************************************************************************************/

DECLARE
  @v_count  INT,
  @v_issn  VARCHAR(20),
  @v_itemtype INT,
  @v_journal_rel_qsicode  INT,
  @v_journalkey INT,
  @v_keystr VARCHAR(20),
  @v_projectkey INT,
  @v_pubID  VARCHAR(10),
  @v_this_rel_qsicode INT,
  @v_usageclass INT
  
BEGIN
 
  SET @o_error_code = 0
  SET @o_error_desc = ''  
  SET @o_result = ''  
  SET @v_pubID = '10.1215'
  
  IF @i_projectkey > 0  --Project or Journal
  BEGIN
    SET @v_keystr = CONVERT(VARCHAR, @i_projectkey)
    
    -- Check itemtype/usageclass of this project/journal
    SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
    FROM taqproject 
    WHERE taqprojectkey = @i_projectkey      
    
    IF @v_itemtype = 3  --Project
    BEGIN
      SET @o_error_code = -2 --warning for dbchange_request procedure
      SET @o_error_desc = 'Missing DOI generation algorithm for projects.'
      RETURN      
    END
    
    IF @v_itemtype = 6  --Journal
    BEGIN
      IF @i_related_journalkey > 0
        SET @v_journalkey = @i_related_journalkey
      ELSE
        BEGIN
          -- If the current project is a journal, use the projectkey
          IF @v_usageclass = 1
            SET @v_journalkey = @i_projectkey
          ELSE
            BEGIN
              -- Get the related Journal
              -- NOTE: Relationship qsicode for journals (gentable 582) corresponds to Usage Class datacode (subgentable 550)
              SET @v_this_rel_qsicode = @v_usageclass
              SET @v_journal_rel_qsicode = 1
              SET @v_journalkey = COALESCE(dbo.qproject_get_otherprojectkey(@i_projectkey, @v_this_rel_qsicode, @v_journal_rel_qsicode),0)
            END
        END      
    END --@v_itemtype = 6 (Journal)      
  END --@i_projectkey > 0
    
  ELSE IF @i_elementkey > 0 --Element
  BEGIN
    SET @v_keystr = CONVERT(VARCHAR, @i_elementkey)
          
    -- Check itemtype/usageclass of the project/journal this element is on
    SELECT @v_projectkey = taqprojectkey, @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
    FROM taqproject 
    WHERE taqprojectkey = (SELECT taqprojectkey
                          FROM taqprojectelement
                          WHERE taqelementkey = @i_elementkey)
    
    IF @v_itemtype = 3  --Project
    BEGIN
      -- Get the journal related to this project
      SET @v_this_rel_qsicode = 10  --Project - gentable 582
      SET @v_journal_rel_qsicode = 11 --Journal (for Project)
      SET @v_journalkey = COALESCE(dbo.qproject_get_otherprojectkey(@v_projectkey, @v_this_rel_qsicode, @v_journal_rel_qsicode),0)
    END
    
    IF @v_itemtype = 6  --Journal
    BEGIN
      -- If the project this element is on is a journal, use the projectkey
      IF @v_usageclass = 1
        SET @v_journalkey = @v_projectkey
      ELSE
        BEGIN
          -- Get the related Journal
          -- NOTE: Relationship qsicode for journals (gentable 582) corresponds to Usage Class datacode (subgentable 550)
          SET @v_this_rel_qsicode = @v_usageclass
          SET @v_journal_rel_qsicode = 1
          SET @v_journalkey = COALESCE(dbo.qproject_get_otherprojectkey(@v_projectkey, @v_this_rel_qsicode, @v_journal_rel_qsicode),0)
        END
    END      
  END --IF @i_elementkey > 0

  PRINT '@v_journalkey: ' + CONVERT(VARCHAR, @v_journalkey)

  -- Get the journal's ISSN
  SELECT @v_count = COUNT(*)
  FROM taqproductnumbers
  WHERE taqprojectkey = @v_journalkey AND
      productidcode = (SELECT datacode FROM gentables WHERE tableid = 594 AND qsicode = 2)
      
  IF @v_count > 0
    BEGIN
      SELECT @v_issn = productnumber
      FROM taqproductnumbers
      WHERE taqprojectkey = @v_journalkey AND
          productidcode = (SELECT datacode FROM gentables WHERE tableid = 594 AND qsicode = 2)
          
      IF @v_issn IS NULL OR LTRIM(RTRIM(@v_issn)) = ''
      BEGIN
        SET @o_error_code = -2 --warning for dbchange_request procedure
        SET @o_error_desc = 'Could not generate DOI - no ISSN exists on the journal.'
        RETURN            
      END
    END
  ELSE
    BEGIN
      SET @o_error_code = -2 --warning for dbchange_request procedure
      SET @o_error_desc = 'Could not generate DOI - no ISSN exists on the journal.'
      RETURN
    END
        
  SET @o_result = @v_pubID + '/' + REPLACE(@v_issn, '-', '') + '-' + @v_keystr
    
END
GO

GRANT EXEC ON dbo.generate_doi TO PUBLIC
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO