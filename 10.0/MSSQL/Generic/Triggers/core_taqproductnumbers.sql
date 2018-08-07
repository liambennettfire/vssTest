IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_taqproductnumbers') AND type = 'TR')
	DROP TRIGGER dbo.core_taqproductnumbers
GO

CREATE TRIGGER core_taqproductnumbers ON taqproductnumbers
FOR INSERT, UPDATE AS
IF UPDATE (productnumber)

BEGIN

  DECLARE @v_projectkey INT
  SELECT @v_projectkey = i.taqprojectkey
  FROM inserted i

  EXEC CoreProjectInfo_Row_Refresh @v_projectkey 	

END


