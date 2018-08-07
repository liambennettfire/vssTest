if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getAcqEditorGCKeyByLastName') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getAcqEditorGCKeyByLastName
GO

CREATE PROCEDURE dbo.WK_getAcqEditorGCKeyByLastName
@lastName varchar(512)
AS

BEGIN

SELECT        globalcontactrole.globalcontactkey, globalcontact.firstname, globalcontact.lastname
FROM            globalcontactrole INNER JOIN globalcontact ON globalcontactrole.globalcontactkey = globalcontact.globalcontactkey
WHERE        (globalcontactrole.rolecode = 18) AND 
			 (globalcontact.lastname LIKE '%' + @lastName + '%') AND 
			 (globalcontact.activeind = 1)

END
