IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_globalcontactrole_del') AND type = 'TR')
	DROP TRIGGER dbo.core_globalcontactrole_del
GO

CREATE TRIGGER core_globalcontactrole_del ON globalcontactrole
FOR DELETE AS

BEGIN

  DECLARE @v_contactkey INT
  SELECT @v_contactkey = d.globalcontactkey
    FROM deleted d

  exec CoreContactInfo_Row_Refresh @v_contactkey 	

END


