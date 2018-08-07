IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_taqprojectformat') AND type = 'TR')
	DROP TRIGGER dbo.core_taqprojectformat
GO

CREATE TRIGGER core_taqprojectformat ON taqprojecttitle 
FOR INSERT, UPDATE AS

BEGIN

  DECLARE @v_projectkey INT, @v_primaryformatind INT
  SELECT @v_projectkey = i.taqprojectkey, @v_primaryformatind = i.primaryformatind
    FROM inserted i

  IF @v_primaryformatind = 1 BEGIN
    exec CoreProjectInfo_Row_Refresh @v_projectkey 	
  END
END


