
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_next_key_range]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[get_next_key_range]
GO

CREATE PROCEDURE [dbo].[get_next_key_range]
    @userid VARCHAR(30), 
    @keyCount INT, 
    @lastKey INT OUTPUT
AS
BEGIN
  if ltrim(rtrim(lower(@userid))) = 'taqprojecttask' begin 
	  WHILE 1=1
	  BEGIN
      SELECT TOP 1 @lastKey=taqtaskkey+@keyCount FROM keys
 
      if @lastKey > 428683000 begin
          -- hit top of gap, try using generickey
          SELECT TOP 1 @lastKey=generickey+@keyCount FROM keys
        
          UPDATE keys 
          SET generickey=@lastKey, 
              lastuserid=@userid, 
              lastmaintdate=GETDATE()
          WHERE generickey=@lastKey-@keyCount
      end
      else begin          
          UPDATE keys 
          SET taqtaskkey=@lastKey, 
              lastuserid=@userid, 
              lastmaintdate=GETDATE()
          WHERE taqtaskkey=@lastKey-@keyCount
      end

      IF @@ROWCOUNT=1
          RETURN
	  END
  end
  else if ltrim(rtrim(lower(@userid))) = 'csdistribution' begin 
	  WHILE 1=1
	  BEGIN
      SELECT TOP 1 @lastKey=transactionkey+@keyCount FROM keys

      if @lastKey > 428683000 begin
          -- hit top of gap, try using generickey
          SELECT TOP 1 @lastKey=generickey+@keyCount FROM keys
        
          UPDATE keys 
          SET generickey=@lastKey, 
              lastuserid=@userid, 
              lastmaintdate=GETDATE()
          WHERE generickey=@lastKey-@keyCount
      end
      else begin                  
          UPDATE keys 
          SET transactionkey=@lastKey, 
              lastuserid=@userid, 
              lastmaintdate=GETDATE()
          WHERE transactionkey=@lastKey-@keyCount
      end

      IF @@ROWCOUNT=1
          RETURN
	  END
  end
  else begin
    DECLARE @range_first_value sql_variant , 
            @range_first_value_output sql_variant ,
            @range_last_value sql_variant , 
            @range_last_value_output sql_variant 

    SET @keyCount  = 5

    EXEC sp_sequence_get_range
      @sequence_name = N'dbo.qutl_generickey'
    , @range_size = @keyCount
    , @range_first_value = @range_first_value_output OUTPUT 
    , @range_last_value = @range_last_value_output OUTPUT 

    SELECT @lastKey = cast(@range_last_value_output as int)   

	  --WHILE 1=1
	  --BEGIN
   --   SELECT TOP 1 @lastKey=generickey+@keyCount FROM keys
        
   --   UPDATE keys 
   --   SET generickey=@lastKey, 
   --       lastuserid=@userid, 
   --       lastmaintdate=GETDATE()
   --   WHERE generickey=@lastKey-@keyCount
      
   --   IF @@ROWCOUNT=1
   --       RETURN
	  --END
  end
END
GO

GRANT EXEC ON [dbo].[get_next_key_range] TO PUBLIC
GO
