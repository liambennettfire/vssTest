IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('dbo.get_next_key') and (type = 'P' or type = 'RF'))
BEGIN
	DROP PROCEDURE dbo.get_next_key
END
GO

CREATE PROCEDURE dbo.get_next_key
	@userid VARCHAR(30), 
	@nextkey INT OUTPUT 
AS
BEGIN
    if ltrim(rtrim(lower(@userid))) = 'taqprojecttask' begin 
      WHILE 1=1
      BEGIN
          SELECT TOP 1 @nextkey=taqtaskkey+1 FROM keys

          if @nextkey > 428683000 begin
              -- hit top of gap, try using generickey
              SELECT TOP 1 @nextkey=generickey+1 FROM keys
        
              UPDATE keys 
              SET generickey=@nextkey, 
                  lastuserid=@userid, 
                  lastmaintdate=GETDATE()
              WHERE generickey=@nextkey-1
          end
          else begin        
              UPDATE keys 
              SET taqtaskkey=@nextkey, 
                  lastuserid=@userid, 
                  lastmaintdate=GETDATE()
              WHERE taqtaskkey=@nextkey-1
          end

          IF @@ROWCOUNT=1
              RETURN
      END
    end
    else if ltrim(rtrim(lower(@userid))) = 'csdistribution' begin 
      WHILE 1=1
      BEGIN
          SELECT TOP 1 @nextkey=transactionkey+1 FROM keys
        
          if @nextkey > 428683000 begin
              -- hit top of gap, try using generickey
              SELECT TOP 1 @nextkey=generickey+1 FROM keys
        
              UPDATE keys 
              SET generickey=@nextkey, 
                  lastuserid=@userid, 
                  lastmaintdate=GETDATE()
              WHERE generickey=@nextkey-1
          end
          else begin        
              UPDATE keys 
              SET transactionkey=@nextkey, 
                  lastuserid=@userid, 
                  lastmaintdate=GETDATE()
              WHERE transactionkey=@nextkey-1
          end

          IF @@ROWCOUNT=1
              RETURN
      END
    end
    else begin
      WHILE 1=1
      BEGIN
          SELECT TOP 1 @nextkey=generickey+1 FROM keys
        
          UPDATE keys 
          SET generickey=@nextkey, 
              lastuserid=@userid, 
              lastmaintdate=GETDATE()
          WHERE generickey=@nextkey-1

          IF @@ROWCOUNT=1
              RETURN
      END
    end
END
GO

GRANT EXECUTE ON dbo.get_next_key TO PUBLIC
GO
