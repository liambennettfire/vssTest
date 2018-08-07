CREATE TRIGGER primacfeed_run_miscspecs ON estmiscspecs  
FOR INSERT, UPDATE 
AS 

DECLARE  @err_msg varchar(100), @estkey int, @versionkey int

SELECT @estkey = i.estkey, @versionkey = i.versionkey
      FROM inserted i

IF @@error != 0
BEGIN
	ROLLBACK TRANSACTION
	select @err_msg = "Could not select from estmiscspecs table (trigger)."
	print @err_msg
END
ELSE
BEGIN
   EXEC feed_out_primac_data_incr @estkey, @versionkey

      IF @@error != 0
      BEGIN
	     ROLLBACK TRANSACTION
	     select @err_msg = "Could not update FEEDOUTPRIMACDATA table (trigger)."
	     print @err_msg
      END
END


