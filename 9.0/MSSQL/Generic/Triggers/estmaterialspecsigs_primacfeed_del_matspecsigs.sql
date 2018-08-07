CREATE TRIGGER primacfeed_del_matspecsigs ON estmaterialspecsigs 
FOR DELETE 
AS 

DECLARE @err_msg varchar(100), @estkey int, @versionkey int

SELECT @estkey = d.estkey, @versionkey = d.versionkey
      FROM deleted d

IF @@error != 0
BEGIN
	ROLLBACK TRANSACTION
	select @err_msg = "Could not select from estmaterialspecsigs table (trigger)."
	print @err_msg
END
ELSE
BEGIN
   EXEC feed_out_primac_data_incr @estkey, @versionkey

      IF @@error != 0
      BEGIN
	     ROLLBACK TRANSACTION
	     select @err_msg = "Could not delete FEEDOUTPRIMACDATA table (trigger)."
	     print @err_msg
      END
END


