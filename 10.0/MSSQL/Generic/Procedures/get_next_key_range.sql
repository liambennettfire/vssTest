
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_next_key_range]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[get_next_key_range]
GO

CREATE PROCEDURE [dbo].[get_next_key_range]
    @userid VARCHAR(30), 
    @keyCount INT, 
    @lastKey INT OUTPUT
AS
BEGIN
	WHILE 1=1
	BEGIN
        SELECT TOP 1 @lastKey=generickey+@keyCount FROM keys
        
        UPDATE keys 
        SET generickey=@lastKey, 
            lastuserid=@userid, 
            lastmaintdate=GETDATE()
        WHERE generickey=@lastKey-@keyCount

        IF @@ROWCOUNT=1
            RETURN
	END
END
GO

GRANT EXEC ON [dbo].[get_next_key_range] TO PUBLIC
GO
