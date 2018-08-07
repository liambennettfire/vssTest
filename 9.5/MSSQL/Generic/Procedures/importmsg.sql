IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.importmsg') AND (type = 'P' OR type = 'RF'))
  BEGIN
    DROP proc dbo.importmsg 
  END

GO

CREATE PROCEDURE  dbo.importmsg 
  (@importsrckey INT, @batchkey INT, @msgtype INT, @severity INT, 
  @msg VARCHAR(255), @userid VARCHAR(30))

AS

  DECLARE @msgkey INT

  SELECT @msgkey = ISNULL(MAX(importmsgkey) , 0)
    FROM importmessages
   WHERE importbatchkey = @batchkey AND
         importmsgtype = @msgtype AND
         importsrckey = @importsrckey

  SELECT @msgkey = @msgkey + 1

  INSERT INTO importmessages VALUES (@importsrckey, @batchkey, @msgtype, @msgkey, @msg, @severity, @userid, getdate()) 

  RETURN

GO

GRANT EXECUTE ON dbo.importmsg TO PUBLIC

GO