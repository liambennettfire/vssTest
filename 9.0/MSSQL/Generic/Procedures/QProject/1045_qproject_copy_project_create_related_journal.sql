IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_create_related_journal]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_create_related_journal]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_create_related_journal]    Script Date: 07/16/2008 10:34:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[qproject_copy_project_create_related_journal]
		(@i_copy_projectkey     integer,
		@i_new_projectkey		integer,
		@i_userid				varchar(30),
		@i_copydatagroups_list	varchar(max),
		@i_cleardatagroups_list	varchar(max),
		@i_itemtype_qsicode		integer,
		@i_usageclass_qsicode	integer,
		@o_error_code			integer output,
		@o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: [qproject_copy_project_create_related_journal]
**  Desc: This stored procedure is called at the end of copy project.  It is
**        used to create a Journal Record for a Journal Acquisition.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Alan Katzen
**    Date: 12 August 2008
*******************************************************************************/

DECLARE @error_var	int,
        @v_journal_itemtype int,
        @v_journal_usageclass int,
        @v_default_template_projectkey int,
        @v_count int,
        @v_journal_projectkey int,
        @v_journal_relationshipcode int,
        @v_journal_acquisition_relationshipcode int,
        @v_new_projecttitle varchar(255),
       	@templateind    int

SET @o_error_code = 0
SET @o_error_desc = ''

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to copy project create related journal: taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
	RETURN
end

IF (@i_itemtype_qsicode = 3 and @i_usageclass_qsicode = 11) BEGIN
  SELECT @templateind = COALESCE(templateind, 0) 
    FROM taqproject 
   WHERE taqprojectkey = @i_new_projectkey 
   
  IF ( @templateind > 0 ) BEGIN
	  -- new project is a template, do not create journal record 
	  -- see NetSuite cases #10733 & #10973
	  RETURN
  END

  -- this is a Journal Acquisition - try to create a related Journal Record from default template
  SET @v_journal_itemtype = 0
  SET @v_journal_usageclass = 0
 
  -- get journal item type and journal usage class from qsicodes
  SELECT @v_journal_itemtype = datacode
    FROM gentables
   WHERE tableid = 550
     AND qsicode = 6
  
  IF @v_journal_itemtype > 0 BEGIN
    SELECT @v_journal_usageclass = datasubcode
      FROM subgentables
     WHERE tableid = 550
       AND datacode = @v_journal_itemtype
       AND qsicode = 4
  END
  
  IF (@v_journal_itemtype > 0 AND @v_journal_usageclass > 0) BEGIN
    -- look for default template
    SELECT @v_count = count(*)
      FROM coreprojectinfo
     WHERE searchitemcode = @v_journal_itemtype
       AND usageclasscode = @v_journal_usageclass
       AND templateind = 1
       AND defaulttemplateind = 1
       
    IF @v_count > 0 BEGIN    
      SELECT @v_default_template_projectkey = projectkey
        FROM coreprojectinfo
       WHERE searchitemcode = @v_journal_itemtype
         AND usageclasscode = @v_journal_usageclass
         AND templateind = 1
         AND defaulttemplateind = 1
         
      -- create journal with same name as Journal Acquisition
      SELECT @v_new_projecttitle = projecttitle
        FROM coreprojectinfo
       WHERE projectkey = @i_new_projectkey
            
      exec qproject_copy_project @v_default_template_projectkey, 0, 0, null, null, 0, 0, 0, @i_userid, 
		       @v_new_projecttitle, @v_journal_projectkey output, @o_error_code output, @o_error_desc output

      IF @o_error_code <> 0 BEGIN
	      RETURN
      END 
      
      -- relate journal to journal acquisition
      IF @v_journal_projectkey > 0 BEGIN      
        SELECT @v_journal_relationshipcode = datacode
          FROM gentables
         WHERE tableid = 582
           and qsicode = 6

        SELECT @v_journal_acquisition_relationshipcode = datacode
          FROM gentables
         WHERE tableid = 582
           and qsicode = 5
            
	      exec qproject_copy_project_insert_relationship @v_journal_projectkey, @i_new_projectkey, @v_journal_acquisition_relationshipcode, 
		         @v_journal_relationshipcode, @i_userid, @o_error_code output, @o_error_desc output
	
        IF @o_error_code <> 0 BEGIN
		      RETURN
	      END 	
      END
    END   
  END
END

RETURN
GO

GRANT EXEC ON qproject_copy_project_create_related_journal TO PUBLIC
GO
