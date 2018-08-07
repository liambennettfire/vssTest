CREATE TRIGGER primacfeed_del ON estversion  
FOR DELETE 
AS 

DECLARE @err_msg varchar(100), @estkey int, @versionkey int

SELECT @estkey = d.estkey, @versionkey = d.versionkey
      FROM deleted d

IF @@error != 0
BEGIN
	ROLLBACK TRANSACTION
	select @err_msg = "Could not select from estversion table (trigger)."
	print @err_msg
END
ELSE
BEGIN
    delete from FEEDOUTPRIMACDATA where @estkey = @estkey and versionkey = @versionkey

      IF @@error != 0
      BEGIN
	     ROLLBACK TRANSACTION
	     select @err_msg = "Could not delete FEEDOUTPRIMACDATA table (trigger)."
	     print @err_msg
      END
END


