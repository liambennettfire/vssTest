IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_taqproject') AND type = 'TR')
	DROP TRIGGER dbo.core_taqproject
GO

CREATE TRIGGER core_taqproject ON taqproject
FOR INSERT, UPDATE AS
IF UPDATE (taqprojecttitle) OR 
   UPDATE (taqprojectstatuscode) OR 
   UPDATE (taqprojectownerkey) OR 
   UPDATE (taqprojecttype) OR
   UPDATE (taqprojectseriescode) OR
   UPDATE (subsidyind) OR
   UPDATE (usageclasscode) OR
   UPDATE (searchitemcode) OR
   UPDATE (templateind) OR
   UPDATE (defaulttemplateind)

BEGIN

  DECLARE @v_projectkey INT
  SELECT @v_projectkey = i.taqprojectkey
  FROM inserted i

  EXEC CoreProjectInfo_Row_Refresh @v_projectkey 	

END


