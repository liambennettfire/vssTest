IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_globalcontactrelationship_del') AND type = 'TR')
	DROP TRIGGER dbo.core_globalcontactrelationship_del
GO

CREATE TRIGGER core_globalcontactrelationship_del ON globalcontactrelationship
FOR DELETE AS

BEGIN

  DECLARE @v_contactkey1 INT, 
    @v_contactkey2 INT

  SELECT @v_contactkey1 = d.globalcontactkey1, @v_contactkey2 = d.globalcontactkey2
  FROM deleted d

  EXEC CoreContactInfo_Row_Refresh @v_contactkey1	
  EXEC CoreContactInfo_Row_Refresh @v_contactkey2

END


