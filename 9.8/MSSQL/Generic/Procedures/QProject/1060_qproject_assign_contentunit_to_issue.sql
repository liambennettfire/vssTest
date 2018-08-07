if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_assign_contentunit_to_issue') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_assign_contentunit_to_issue
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_assign_contentunit_to_issue
 (@i_journalkey                integer,
  @i_issuekey                  integer,
  @i_contentunitkey            integer,
  @i_userid                    varchar(30),
  @o_error_code                integer output,
  @o_error_desc                varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qproject_assign_contentunit_to_issue
**  Desc: This stored procedure takes an existing journal to contentunit
**        relationship and creates an issue to contentunit relationship
**        as well as the necessary journal to volume and volume to issue 
**        relationships.
**              
**
**    Auth: Alan Katzen
**    Date: 18 July 2008
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------       -------------------------------------------
**    08/25/17    Colman         46710 - Content Unit Error on a Volume
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_count INT,
          @v_qsicode INT,
          @v_contentunit_relationshipcode INT,
          @v_issue_relationshipcode INT,
          @v_volume_relationshipcode INT,
          @v_journal_relationshipcode INT,
          @v_volumekey INT
          
  IF (@i_issuekey is null OR @i_issuekey = 0) BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Issuekey is empty'
    RETURN  
  END
  
  SET @v_qsicode = 1  -- journal
  SELECT @v_journal_relationshipcode = datacode 
    FROM gentables
   WHERE tableid = 582
     AND qsicode = @v_qsicode
     
  SET @v_qsicode = 2  -- volume
  SELECT @v_volume_relationshipcode = datacode 
    FROM gentables
   WHERE tableid = 582
     AND qsicode = @v_qsicode

  SET @v_qsicode = 3  -- issue
  SELECT @v_issue_relationshipcode = datacode 
    FROM gentables
   WHERE tableid = 582
     AND qsicode = @v_qsicode

  SET @v_qsicode = 4  -- content unit
  SELECT @v_contentunit_relationshipcode = datacode 
    FROM gentables
   WHERE tableid = 582
     AND qsicode = @v_qsicode

  -- get volumekey from issuekey
  SELECT @v_volumekey = volumekey
    FROM dbo.qproject_get_issue()
   WHERE issuekey = @i_issuekey

  -- add new issue to content unit relationship
	exec qproject_copy_project_insert_relationship @i_contentunitkey, @i_issuekey, @v_issue_relationshipcode, 
		@v_contentunit_relationshipcode, @i_userid, @o_error_code output, @o_error_desc output
	
	IF @o_error_code <> 0 BEGIN
		RETURN
	END 	

  -- if the content unit is already related to a different volume, delete the relationship
  IF EXISTS (
      SELECT 1 FROM taqprojectrelationship 
      WHERE taqprojectkey2 = @i_contentunitkey 
        AND relationshipcode1 = @v_volume_relationshipcode
        AND relationshipcode2 = @v_contentunit_relationshipcode
        AND taqprojectkey1 <> @v_volumekey)
  BEGIN
    DELETE FROM taqprojectrelationship 
    WHERE taqprojectkey2 = @i_contentunitkey 
      AND relationshipcode1 = @v_volume_relationshipcode
      AND relationshipcode2 = @v_contentunit_relationshipcode
  END
  
  -- add new volume to content unit relationship
	exec qproject_copy_project_insert_relationship @i_contentunitkey, @v_volumekey, @v_volume_relationshipcode, 
		@v_contentunit_relationshipcode, @i_userid, @o_error_code output, @o_error_desc output
	
	IF @o_error_code <> 0 BEGIN
		RETURN
	END 	
GO
GRANT EXEC ON qproject_assign_contentunit_to_issue TO PUBLIC
GO
