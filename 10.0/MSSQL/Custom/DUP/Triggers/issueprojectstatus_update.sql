SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================================================================================================
-- Author: Uday A. Khisty
-- Create date: 6/5/15
-- Description:When the task "Issue Mailed" is checked actual on issue records, change the value of the Status field in the Detail section *of issue records* to be "Mailed".
-- Author" Jason Donovan 
-- Create Date: 05/11/2017
-- scription:When the task "Send POD files to Sheridan_J" is checked actual on issue records, change the value of the Status field in the Detail section *of issue records* to be "Mailed". 
-- ==========================================================================================================================================================================


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.issueprojectstatus_update') AND type = 'TR')
	DROP TRIGGER dbo.issueprojectstatus_update
GO

CREATE TRIGGER issueprojectstatus_update ON taqprojecttask
AFTER INSERT, UPDATE AS

IF UPDATE (actualind)
BEGIN
  DECLARE @v_taqprojectkey		INT,
		  @v_datetypecode		INT,
		  @v_taqtaskkey			INT,
		  @v_actualind			TINYINT,
		  @v_itemtype			INT,
		  @v_usageclass			INT,
		  @v_itemtype_issue		INT,
		  @v_usageclass_issue	INT,
		  @v_projectstatus_Mailed INT		  
		  
	SET @v_taqprojectkey = 0
	SET @v_datetypecode = 0	  
	SET @v_itemtype = 0
	SET @v_usageclass = 0

    SELECT @v_taqtaskkey = i.taqtaskkey,
           @v_taqprojectkey = i.taqprojectkey,
           @v_datetypecode = i.datetypecode,
           @v_actualind	 = i.actualind
    FROM Inserted i
    
    IF COALESCE(@v_taqtaskkey, 0) > 0 AND COALESCE(@v_taqprojectkey, 0) = 0 BEGIN
		SELECT @v_taqprojectkey = taqprojectkey 
		FROM taqprojecttask WHERE taqtaskkey = @v_taqtaskkey
    END    
    
    IF COALESCE(@v_taqprojectkey, 0) > 0 BEGIN
		SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode 
		FROM coreprojectinfo  
		WHERE projectkey = @v_taqprojectkey	
    END
    ELSE BEGIN
		RETURN
    END
    
    SELECT @v_itemtype_issue = datacode, @v_usageclass_issue = datasubcode 
    FROM subgentables
    WHERE tableid = 550 AND qsicode = 5
    
    IF @v_itemtype = @v_itemtype_issue AND @v_usageclass = @v_usageclass_issue AND @v_actualind = 1 AND @v_datetypecode = 333 BEGIN
		SELECT @v_projectstatus_Mailed = datacode 
		FROM gentables 
		WHERE tableid = 522 AND datacode = 7
		
		UPDATE taqproject SET taqprojectstatuscode = @v_projectstatus_Mailed WHERE taqprojectkey = @v_taqprojectkey
    END

	IF @v_itemtype = @v_itemtype_issue AND @v_usageclass = @v_usageclass_issue AND @v_actualind = 1 AND @v_datetypecode = 2260 BEGIN
		SELECT @v_projectstatus_Mailed = datacode 
		FROM gentables 
		WHERE tableid = 522 AND datacode = 7
		
		UPDATE taqproject SET taqprojectstatuscode = @v_projectstatus_Mailed WHERE taqprojectkey = @v_taqprojectkey
	END
END
GO