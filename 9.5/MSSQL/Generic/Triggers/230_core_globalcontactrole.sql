IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_globalcontactrole') AND type = 'TR')
	DROP TRIGGER dbo.core_globalcontactrole
GO

CREATE TRIGGER core_globalcontactrole ON globalcontactrole
FOR INSERT, UPDATE AS

BEGIN
  DECLARE @v_contactkey INT

  DECLARE contactkey_cur CURSOR FOR  
    SELECT i.globalcontactkey 
    FROM inserted i

  OPEN contactkey_cur

  FETCH NEXT FROM contactkey_cur 
  INTO @v_contactkey

  WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
  BEGIN

    EXEC CoreContactInfo_Row_Refresh @v_contactkey 	

    FETCH NEXT FROM contactkey_cur 
    INTO @v_contactkey
  END

  CLOSE contactkey_cur
  DEALLOCATE contactkey_cur  

END
