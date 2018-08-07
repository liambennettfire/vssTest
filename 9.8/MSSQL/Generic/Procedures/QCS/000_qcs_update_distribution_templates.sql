IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_update_distribution_templates')
DROP PROCEDURE  qcs_update_distribution_templates
GO

CREATE PROCEDURE qcs_update_distribution_templates
(
  @i_templateinfo_xml   NVARCHAR(max),
  @o_error_code         INT OUT,
  @o_error_desc         VARCHAR(2000) OUT 
)
AS

BEGIN
  DECLARE 
    @AccessInd INT,
    @DocNum	INT,
    @IsOpen BIT,
    @Quote VARCHAR(3),
    @ErrorVar	INT,
    @RowcountVar INT,
    @CountVar INT,
    @SequenceNum INT,
    @UserID	VARCHAR(30),
    @UserKey TINYINT,
    @XMLSearchString VARCHAR(120),
    @UpdatedAt DATETIME,
    @Tag VARCHAR(25),
    @TemplateName VARCHAR(255),
    @AlternateName VARCHAR(255),
    @LastMaintDate DATETIME,
    @TemplateKey INT,
    @TemplateId VARCHAR(255),
    @DistributionTypeTag VARCHAR(25),
    @PartnerTag VARCHAR(25),
    @InactiveString VARCHAR(5),
    @DistributionTypeCode INT,
    @GlobalContactKey INT,
    @PartnerKey INT
  
  SET ARITHABORT ON 
  SET QUOTED_IDENTIFIER ON
  SET NOCOUNT ON

  SET @IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
  --SET @TemplateinfoXml = cast(@i_templateinfo_xml as xml)
  
  SELECT * INTO #tempdist
  FROM csdistributiontemplate

  -- clear out existing templates
  DELETE FROM csdistributiontemplate
  
  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
  IF @ErrorVar <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not delete from csdistributiontemplate'
    GOTO ExitHandler
  END       
  
  DELETE FROM csdistributiontemplatepartner

  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
  IF @ErrorVar <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not delete from csdistributiontemplatepartner'
    GOTO ExitHandler
  END       
  
  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @DocNum OUTPUT, @i_templateinfo_xml,'<Test xmlns:x="http://cloud.firebrandtech.com/"/>'

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the xml record'
    GOTO ExitHandler
  END
  SET @IsOpen = 1
                
  -- Loop to get all elements from the passed XML document
  DECLARE template_cursor CURSOR LOCAL FOR 
    SELECT Tag,TemplateName,AlternateName,Id
    FROM OPENXML(@DocNum,  '/x:distribution-templates/x:template')
    WITH (Tag VARCHAR(25) 'x:tag',
          TemplateName VARCHAR(255) 'x:name',
          AlternateName VARCHAR(255) 'x:alternate-name',
          Id VARCHAR(255) 'x:id')

  OPEN template_cursor

  FETCH NEXT FROM template_cursor
  INTO @Tag, @TemplateName, @AlternateName,@TemplateId

  IF @@FETCH_STATUS <> 0	BEGIN -- no distribution templates - return  
    SET @o_error_code = 1
    SET @o_error_desc = 'No Distribution Templates'
    GOTO ExitHandler
  END
  
  WHILE @@FETCH_STATUS = 0 BEGIN
    --DEBUG
    PRINT '-----------------------------------------------'
    PRINT '@TemplateName: ' + isnull(@TemplateName,'NULL')
    PRINT '@Tag: ' +  isnull(@Tag,'NULL')
    PRINT '@AlternateName: ' +  isnull(@AlternateName,'NULL')
    PRINT '@TemplateId: ' +  isnull(@TemplateId,'NULL')    
    
    IF @TemplateName is null OR ltrim(rtrim(@TemplateName)) = '' BEGIN
      goto GetNextRow
    END

    IF @Tag is null OR ltrim(rtrim(@Tag)) = '' BEGIN
      goto GetNextRow
    END

    IF @TemplateId is null OR ltrim(rtrim(@TemplateId)) = '' BEGIN
      goto GetNextRow
    END

	SET @TemplateKey = NULL
    SELECT @TemplateKey = templatekey
    FROM #tempdist WHERE eloquencefieldtag = @Tag
    
	PRINT '@TemplateKey: ' + isnull(CAST(@TemplateKey AS VARCHAR(20)),'NULL')

    IF @TemplateKey IS NULL
		exec dbo.get_next_key 'Cloud', @TemplateKey output         
             
    IF @TemplateKey > 0 BEGIN
      INSERT INTO csdistributiontemplate (templatekey,eloquencefieldtag,templatename,lastuserid,lastmaintdate)
      VALUES (@TemplateKey,@Tag,COALESCE(@AlternateName,@TemplateName),'Cloud',getdate())
      
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not insert into csdistributiontemplate'
        GOTO ExitHandler
      END       
    END
    ELSE BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to generate new templatekey'
      GOTO ExitHandler
    END
    
    -- insert into csdistributiontemplatepartner   
    SET @XMLSearchString = '/x:distribution-templates/x:template[x:id=''' + @TemplateId + ''']/x:items/x:item'    

    -- Loop to get all <Search/Criteria/Item> elements from the passed XML document
    DECLARE item_cursor CURSOR LOCAL FOR 
      SELECT DistributionTypeTag, PartnerTag, Inactive
      FROM OPENXML(@DocNum,  @XMLSearchString)
      WITH (DistributionTypeTag VARCHAR(25) 'x:distribution-type-tag',
            PartnerTag VARCHAR(25) 'x:partner-tag',
            Inactive VARCHAR(5) 'x:inactive')
           
    OPEN item_cursor

    FETCH NEXT FROM item_cursor
    INTO @DistributionTypeTag, @PartnerTag, @InactiveString

    IF @@FETCH_STATUS <> 0	BEGIN -- no distribution template partners  
      GOTO GetNextRow
    END
    
    WHILE @@FETCH_STATUS = 0 BEGIN
      PRINT '@DistributionTypeTag: ' + isnull(@DistributionTypeTag,'NULL')
      PRINT '@PartnerTag: ' + isnull(@PartnerTag,'NULL')
      PRINT '@Inactive: ' + isnull(@InactiveString, 'NULL')

      IF lower(@InactiveString) = 'true' BEGIN
        GOTO GetNextItemRow
      END

      SET @DistributionTypeCode = 0
      IF @DistributionTypeTag is not null AND ltrim(rtrim(@DistributionTypeTag)) <> '' BEGIN
        SELECT @CountVar = count(*)
          FROM gentables
         WHERE tableid = 619
           AND upper(eloquencefieldtag) = upper(@DistributionTypeTag)
         
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Could not access distribution type gentable for Tag: ' + @DistributionTypeTag
          GOTO ExitHandler
        END        

        IF @CountVar = 0 BEGIN
          print 'Could not find distribution type on gentables for Tag: ' + @DistributionTypeTag
          GOTO GetNextItemRow
        END

        SELECT @DistributionTypeCode = datacode
          FROM gentables
         WHERE tableid = 619
           AND upper(eloquencefieldtag) = upper(@DistributionTypeTag)
         
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Could not access distribution type gentable for Tag: ' + @DistributionTypeTag
          GOTO ExitHandler
        END        
      END

      SET @GlobalContactKey = 0
      IF @PartnerTag is not null AND ltrim(rtrim(@PartnerTag)) <> '' BEGIN
        IF isnumeric(@PartnerTag) <> 1 BEGIN
          GOTO GetNextItemRow
        END
        SET @PartnerKey = cast(@PartnerTag as int)
        
        SELECT @CountVar = count(*)
          FROM globalcontact
         WHERE partnerkey = @PartnerKey
           AND activeind = 1

        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Could not access globalcontact table for Tag: ' + @PartnerTag
          GOTO ExitHandler
        END        
        
        IF @CountVar = 0 BEGIN
          print 'Could not find an active globalcontact for Tag: ' + @PartnerTag
          GOTO GetNextItemRow
        END
        
        SELECT @GlobalContactKey = globalcontactkey
          FROM globalcontact
         WHERE partnerkey = @PartnerKey
           AND activeind = 1
         
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Could not access globalcontact table for Tag: ' + @PartnerTag
          GOTO ExitHandler
        END        
      END
      
      INSERT INTO csdistributiontemplatepartner (templatekey, distributiontypecode, partnercontactkey, lastuserid, lastmaintdate)
      VALUES (@TemplateKey,@DistributionTypeCode,@GlobalContactKey,'Cloud',getdate())

      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not insert into csdistributiontemplatepartner'
        GOTO ExitHandler
      END       
      
      GetNextItemRow:

      FETCH NEXT FROM item_cursor
      INTO @DistributionTypeTag, @PartnerTag, @InactiveString
    END
             
    GetNextRow:

    IF CURSOR_STATUS('local', 'item_cursor') >= 0
    BEGIN
      CLOSE item_cursor
      DEALLOCATE item_cursor
    END

    FETCH NEXT FROM template_cursor
    INTO @Tag, @TemplateName, @AlternateName, @TemplateId
  END

  CLOSE template_cursor
  DEALLOCATE template_cursor

  DROP TABLE #tempdist

------------
ExitHandler:
------------

  IF CURSOR_STATUS('local', 'item_cursor') >= 0
  BEGIN
    CLOSE item_cursor
    DEALLOCATE item_cursor
  END

  IF CURSOR_STATUS('local', 'template_cursor') >= 0
  BEGIN
    CLOSE template_cursor
    DEALLOCATE template_cursor
  END

  IF @IsOpen = 1
    EXEC sp_xml_removedocument @DocNum

  IF @o_error_desc IS NOT NULL AND LTRIM(@o_error_desc) <> ''
    PRINT 'ERROR: ' + @o_error_desc  
END
GO

GRANT EXEC ON qcs_update_distribution_templates TO PUBLIC
GO
