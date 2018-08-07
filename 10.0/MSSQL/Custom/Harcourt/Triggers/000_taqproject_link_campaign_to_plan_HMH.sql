IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.taqproject_link_campaign_to_plan_HMH') AND type = 'TR')
	DROP TRIGGER dbo.taqproject_link_campaign_to_plan_HMH
GO

CREATE TRIGGER dbo.taqproject_link_campaign_to_plan_HMH ON taqproject
FOR INSERT, UPDATE AS

DECLARE @v_projectkey INT,
        @v_itemtypecode INT,
        @v_itemtypesubcode INT,
        @v_userid VARCHAR(30),
        @o_errorcode INT,
        @o_errordesc VARCHAR(1000)

SELECT @v_projectkey = i.taqprojectkey, @v_itemtypecode = i.searchitemcode, @v_itemtypesubcode = i.usageclasscode, @v_userid = i.lastuserid
FROM inserted i

IF @v_itemtypecode = 3 AND @v_itemtypesubcode = 15 -- Mktg Campaign
  EXEC qproject_relate_mktg_plans_HMH @v_projectkey, 0, @v_userid, @o_errorcode output, @o_errordesc output
GO
