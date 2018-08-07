IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.insertgenext') AND type = 'TR')
  DROP TRIGGER dbo.insertgenext
GO

CREATE TRIGGER insertgenext ON gentables 
FOR INSERT AS 

  DECLARE 
    @tableid INT, 
    @datacode INT,
    @lastuserid VARCHAR(30),
    @count  INT,
    @rowcount  INT,
    @err_msg VARCHAR(100)

  /*** Get all current values ***/
  SELECT @tableid = i.tableid, @lastuserid = i.lastuserid,
    @datacode = i.datacode  
  FROM inserted i

  SELECT @count = COUNT(*) 
  FROM gentables_ext
  WHERE tableid = @tableid 
    AND datacode = @datacode
  
  IF @count = 0 BEGIN
    INSERT INTO gentables_ext 
		(tableid,datacode,onixcode,onixcodedefault,onixversion,lastuserid,lastmaintdate)
	VALUES
		(@tableid, @datacode, null,0,null,'FB_INSERT',getdate())
  END
  
  
  IF @@error != 0
  BEGIN
    ROLLBACK TRANSACTION
    SET @err_msg = 'Could not insert into gentables_ext table (trigger).'
    PRINT @err_msg
  END
 

GO