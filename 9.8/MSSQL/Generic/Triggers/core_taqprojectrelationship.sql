IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_taqprojectrelationship') AND type = 'TR')
	DROP TRIGGER dbo.core_taqprojectrelationship
GO

CREATE TRIGGER core_taqprojectrelationship ON taqprojectrelationship
FOR INSERT, UPDATE, DELETE AS

BEGIN

  DECLARE @v_projectkey INT,
          @v_insert_row_count INT,
          @v_delete_row_count INT
          
  SELECT @v_delete_row_count=COUNT(*) FROM deleted
  SELECT @v_insert_row_count=COUNT(*) FROM inserted
 
  IF @v_delete_row_count > 0 AND @v_insert_row_count = 0 -- delete, not update
  BEGIN
    SELECT @v_projectkey = d.taqprojectkey1
    FROM deleted d

    EXEC CoreProjectInfo_Row_Refresh @v_projectkey 	

    SELECT @v_projectkey = d.taqprojectkey2
    FROM deleted d

    EXEC CoreProjectInfo_Row_Refresh @v_projectkey 	
  END

  IF @v_insert_row_count > 0 -- insert or update
  BEGIN
    SELECT @v_projectkey = i.taqprojectkey1
    FROM inserted i

    EXEC CoreProjectInfo_Row_Refresh @v_projectkey 	

    SELECT @v_projectkey = i.taqprojectkey2
    FROM inserted i

    EXEC CoreProjectInfo_Row_Refresh @v_projectkey 	
  END
END


