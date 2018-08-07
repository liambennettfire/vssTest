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
END
GO

GRANT EXECUTE ON dbo.get_next_key TO PUBLIC
GO
