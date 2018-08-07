if EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.bookorgentry_update_project_HMH') AND type = 'TR')
	DROP TRIGGER dbo.bookorgentry_update_project_HMH
GO

CREATE TRIGGER dbo.bookorgentry_update_project_HMH ON bookorgentry
FOR INSERT, UPDATE, DELETE AS

--IF UPDATE (orgentrykey)

DECLARE @v_bookkey INT,
        @v_orglevelkey INT,
        @v_orgentrykey INT,
        @v_projectkey INT,
        @v_userid VARCHAR(30),
        @v_usageclass_marketing INT,
        @v_usageclass_publicity INT,
        @o_errorcode INT,
        @o_errordesc VARCHAR(1000)

SELECT @v_usageclass_marketing = datasubcode FROM subgentables WHERE qsicode = 9
SELECT @v_usageclass_publicity = datasubcode FROM subgentables WHERE qsicode = 54

IF EXISTS (SELECT * FROM inserted)
  SELECT @v_bookkey = i.bookkey, @v_orglevelkey = i.orglevelkey, @v_orgentrykey = i.orgentrykey, @v_userid = i.lastuserid
  FROM inserted i
ELSE IF EXISTS (SELECT * FROM deleted)
  SELECT @v_bookkey = d.bookkey, @v_orglevelkey = d.orglevelkey, @v_orgentrykey = d.orgentrykey, @v_userid = d.lastuserid
  FROM deleted d

-- Update orgentry of all related Marketing/Publicity Campaigns
DECLARE campaign_cur CURSOR FOR
SELECT pt.taqprojectkey 
FROM taqprojecttitle pt 
  INNER JOIN taqproject p ON p.taqprojectkey = pt.taqprojectkey AND p.searchitemcode = 3 AND p.usageclasscode IN (@v_usageclass_marketing, @v_usageclass_publicity)
WHERE pt.bookkey = @v_bookkey

OPEN campaign_cur
FETCH NEXT FROM campaign_cur INTO @v_projectkey 

WHILE (@@FETCH_STATUS = 0)
BEGIN
  -- Replace all project orgentries no matter what changed. We do not know the state of the target project orgentries.
  DELETE FROM taqprojectorgentry WHERE taqprojectkey = @v_projectkey

  INSERT INTO taqprojectorgentry (taqprojectkey, orglevelkey, orgentrykey, lastuserid, lastmaintdate)
  SELECT @v_projectkey as taqprojectkey, orglevelkey, orgentrykey, @v_userid as lastuserid, getdate() as lastmaintdate
  FROM bookorgentry 
  WHERE bookkey = @v_bookkey
  
  EXEC CoreProjectInfo_Row_Refresh @v_projectkey
  --EXEC qproject_relate_mktg_plans_HMH @v_projectkey, @v_userid, @o_errorcode OUTPUT, @o_errordesc OUTPUT
  
  FETCH NEXT FROM campaign_cur INTO @v_projectkey 
END

CLOSE campaign_cur
DEALLOCATE campaign_cur

GO
