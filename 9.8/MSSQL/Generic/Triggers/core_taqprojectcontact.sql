IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_taqprojectcontact') AND type = 'TR')
	DROP TRIGGER dbo.core_taqprojectcontact
GO

CREATE TRIGGER core_taqprojectcontact ON taqprojectcontact 
FOR INSERT, UPDATE AS

BEGIN

  DECLARE @v_projectkey INT
  SELECT @v_projectkey = i.taqprojectkey
    FROM inserted i

  exec CoreProjectInfo_Row_Refresh @v_projectkey 	

END


