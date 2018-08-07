IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.insertsubgenext') AND type = 'TR')
  DROP TRIGGER dbo.insertsubgenext
GO

CREATE TRIGGER insertsubgenext ON subgentables 
FOR INSERT AS 

  DECLARE 
    @tableid INT, 
    @datacode INT,
    @datasubcode	INT,
    @lastuserid VARCHAR(30),
    @count  INT,
    @rowcount  INT,
    @err_msg VARCHAR(100)

  /*** Get all current values ***/
  SELECT @tableid = i.tableid, @lastuserid = i.lastuserid,
    @datacode = i.datacode,@datasubcode=i.datasubcode  
  FROM inserted i

  SELECT @count = COUNT(*) 
  FROM subgentables_ext
  WHERE tableid = @tableid 
    AND datacode = @datacode
	AND datasubcode = @datasubcode
  
  IF @count = 0 BEGIN
    INSERT INTO subgentables_ext 
		(tableid,datacode,datasubcode,onixsubcode,onixsubcodedefault,onixversion,lastuserid,lastmaintdate)
	VALUES
		(@tableid, @datacode, @datasubcode,null,0,null,'FB_INSERT',getdate())
  END
  
  
  IF @@error != 0
  BEGIN
    ROLLBACK TRANSACTION
    SET @err_msg = 'Could not insert into subgentables_ext table (trigger).'
    PRINT @err_msg
  END
GO