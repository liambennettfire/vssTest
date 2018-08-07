IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_globalcontactmethod_del') AND type = 'TR')
	DROP TRIGGER dbo.core_globalcontactmethod_del
GO

CREATE TRIGGER core_globalcontactmethod_del ON globalcontactmethod
FOR DELETE AS

BEGIN

  DECLARE @v_contactkey INT
  SELECT @v_contactkey = d.globalcontactkey
    FROM deleted d

  exec CoreContactInfo_Row_Refresh @v_contactkey 	

END


