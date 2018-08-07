DECLARE 
@v_error_code INT,
@v_initstatus INT,
@V_error_desc VARCHAR (4000)

BEGIN

SET @v_error_code = 0

exec qutl_insert_clientdefaults_value 91,'Initial Status for Contract Prtgs','This is the status that a printing should be set to when selected in a Contract as Printing for a Right that includes  Production (such as a co-edition right)',NULL,NULL,'',522,5,'This status will be used to pass off the printings from contracts rights sales team to production when the right includes the physical production of the book',8,1, @v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'clientdefaultidid = ' + CAST(91 AS varchar)+ ',  error message =' + @v_error_desc

--Set Status to  Pending Production Input if it exists, if not set to Pending
SELECT @v_initstatus = ISNULL (datacode,0) 
   FROM gentables
WHERE datadesc = 'Pending Production Input'
 
IF @v_initstatus = 0  BEGIN --set to pending 
  SELECT @v_initstatus = ISNULL (datacode,0) 
    FROM gentables
  WHERE qsicode = 4
  END

UPDATE clientdefaults
  SET clientdefaultvalue = @v_initstatus
WHERE clientdefaultid = 91

PRINT @v_error_desc

END
GO
