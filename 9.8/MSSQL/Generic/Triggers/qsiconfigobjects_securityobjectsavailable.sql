IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.qsiconfigobjects_securityobjectsavailable') AND type = 'TR')
  DROP TRIGGER dbo.qsiconfigobjects_securityobjectsavailable
GO

CREATE TRIGGER qsiconfigobjects_securityobjectsavailable ON qsiconfigobjects  
FOR UPDATE AS

	DECLARE @availablesecurityobjectskey  INT,
                  @old_defaultlabeldesc VARCHAR(80),
                  @new_defaultlabeldesc VARCHAR(80),
                  @v_count INT,
                  @windowid INT,
                  @err_msg VARCHAR(100)


   IF NOT UPDATE(defaultlabeldesc) 
    BEGIN 
		RETURN 
    END

 /*** Get all current and previous values ***/
  SELECT @windowid = i.windowid, 
    @old_defaultlabeldesc = d.defaultlabeldesc, @new_defaultlabeldesc = i.defaultlabeldesc
  FROM inserted i, deleted d
  WHERE i.windowid = d.windowid

  SELECT @v_count = count(*)
     FROM securityobjectsavailable
  WHERE availobjectdesc = @old_defaultlabeldesc

 
  IF @v_count = 1
  BEGIN
          SELECT @availablesecurityobjectskey = availablesecurityobjectskey
              FROM securityobjectsavailable
  WHERE availobjectdesc = @old_defaultlabeldesc

		 UPDATE securityobjectsavailable
                SET availobjectdesc = @new_defaultlabeldesc
            WHERE availablesecurityobjectskey = @availablesecurityobjectskey
                AND availobjectdesc = @old_defaultlabeldesc

            IF @@error != 0
		  BEGIN
			 ROLLBACK TRANSACTION
			 SET @err_msg = 'Could not update AVAILOBJCTDESC on qsiconfigobjects_securityobjectsavailable table (trigger).'
			 PRINT @err_msg
		  END
   END

GO