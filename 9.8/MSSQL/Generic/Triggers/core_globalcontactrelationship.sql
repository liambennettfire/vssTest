IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_globalcontactrelationship') AND type = 'TR')
	DROP TRIGGER dbo.core_globalcontactrelationship
GO

CREATE TRIGGER core_globalcontactrelationship ON globalcontactrelationship
FOR INSERT, UPDATE AS

BEGIN
  DECLARE @v_contactkey1 INT,
    @v_contactkey2 INT

  DECLARE contactkey_cur CURSOR FOR  
    SELECT i.globalcontactkey1, i.globalcontactkey2
    FROM inserted i

  OPEN contactkey_cur

  FETCH NEXT FROM contactkey_cur INTO @v_contactkey1, @v_contactkey2

  WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
  BEGIN

    EXEC CoreContactInfo_Row_Refresh @v_contactkey1    
    EXEC CoreContactInfo_Row_Refresh @v_contactkey2

    FETCH NEXT FROM contactkey_cur INTO @v_contactkey1, @v_contactkey2
  END

  CLOSE contactkey_cur
  DEALLOCATE contactkey_cur  

END
