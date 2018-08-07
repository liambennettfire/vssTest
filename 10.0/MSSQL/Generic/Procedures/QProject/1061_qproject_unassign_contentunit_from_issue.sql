if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_unassign_contentunit_from_issue') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_unassign_contentunit_from_issue
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_unassign_contentunit_from_issue
 (@i_issuekey                  integer,
  @i_contentunitkey            integer,
  @i_userid                    varchar(30),
  @o_error_code                integer output,
  @o_error_desc                varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qproject_unassign_contentunit_from_issue
**  Desc: This stored procedure removes an issue to contentunit relationship.
**        (The contentunit will remained assigned to its Journal)
**
**    Auth: Alan Katzen
**    Date: 3 October 2008
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
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

  IF (@i_contentunitkey is null OR @i_contentunitkey = 0) BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Contentunitkey is empty'
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
   
  -- remove issue to contentunit relationship
  SELECT @v_count = count(*)
    FROM taqprojectrelationship
   WHERE relationshipcode1 = @v_issue_relationshipcode
     AND relationshipcode2 = @v_contentunit_relationshipcode
     AND taqprojectkey1 = @i_issuekey
     AND taqprojectkey2 = @i_contentunitkey
     
  IF (@v_count > 0) BEGIN
    DELETE FROM taqprojectrelationship
     WHERE relationshipcode1 = @v_issue_relationshipcode
       AND relationshipcode2 = @v_contentunit_relationshipcode
       AND taqprojectkey1 = @i_issuekey
       AND taqprojectkey2 = @i_contentunitkey
  END
  ELSE BEGIN
    DELETE FROM taqprojectrelationship
     WHERE relationshipcode2 = @v_issue_relationshipcode
       AND relationshipcode1 = @v_contentunit_relationshipcode
       AND taqprojectkey2 = @i_issuekey
       AND taqprojectkey1 = @i_contentunitkey
  END

  -- remove volume to contentunit relationship
  SELECT @v_count = count(*)
    FROM taqprojectrelationship
   WHERE relationshipcode1 = @v_volume_relationshipcode
     AND relationshipcode2 = @v_contentunit_relationshipcode
     AND taqprojectkey1 = @v_volumekey
     AND taqprojectkey2 = @i_contentunitkey
     
  IF (@v_count > 0) BEGIN
    DELETE FROM taqprojectrelationship
     WHERE relationshipcode1 = @v_volume_relationshipcode
       AND relationshipcode2 = @v_contentunit_relationshipcode
       AND taqprojectkey1 = @v_volumekey
       AND taqprojectkey2 = @i_contentunitkey
  END
  ELSE BEGIN
    DELETE FROM taqprojectrelationship
     WHERE relationshipcode2 = @v_volume_relationshipcode
       AND relationshipcode1 = @v_contentunit_relationshipcode
       AND taqprojectkey2 = @v_volumekey
       AND taqprojectkey1 = @i_contentunitkey
  END
  
GO
GRANT EXEC ON qproject_unassign_contentunit_from_issue TO PUBLIC
GO


