IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.insertsub2genext') AND type = 'TR')
  DROP TRIGGER dbo.insertsub2genext
GO

CREATE TRIGGER insertsub2genext ON sub2gentables 
FOR INSERT AS 

  DECLARE 
    @tableid INT, 
    @datacode INT,
    @datasubcode	INT,
	@datasub2code	INT,
    @lastuserid VARCHAR(30),
    @count  INT,
    @rowcount  INT,
    @err_msg VARCHAR(100)

  /*** Get all current values ***/
  SELECT @tableid = i.tableid, @lastuserid = i.lastuserid,
    @datacode = i.datacode,@datasubcode=i.datasubcode,@datasub2code= i.datasub2code  
  FROM inserted i

  SELECT @count = COUNT(*) 
  FROM sub2gentables_ext
  WHERE tableid = @tableid 
    AND datacode = @datacode
	AND datasubcode = @datasubcode
    AND datasub2code = @datasub2code
  
  IF @count = 0 BEGIN
    INSERT INTO sub2gentables_ext 
		(tableid,datacode,datasubcode,datasub2code,lastuserid,lastmaintdate)
	VALUES
		(@tableid, @datacode, @datasubcode,@datasub2code,'FB_INSERT',getdate())
  END
  
  
  IF @@error != 0
  BEGIN
    ROLLBACK TRANSACTION
    SET @err_msg = 'Could not insert into sub2gentables_ext table (trigger).'
    PRINT @err_msg
  END
GO