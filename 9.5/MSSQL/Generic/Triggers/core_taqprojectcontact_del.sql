IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_taqprojectcontact_del') AND type = 'TR')
	DROP TRIGGER dbo.core_taqprojectcontact_del
GO

CREATE TRIGGER core_taqprojectcontact_del ON taqprojectcontact 
FOR DELETE AS

BEGIN

  DECLARE @v_projectkey INT
  SELECT @v_projectkey = d.taqprojectkey
    FROM deleted d

  exec CoreProjectInfo_Row_Refresh @v_projectkey 	

END


