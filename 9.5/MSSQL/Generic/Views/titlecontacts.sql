if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[titlecontacts]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[titlecontacts]
GO

CREATE VIEW [dbo].[titlecontacts] AS
SELECT bookcontact.bookkey bookkey,   
    bookcontact.printingkey printingkey,   
    bookcontact.globalcontactkey contactkey,   
    bookcontactrole.rolecode roletypecode,   
    bookcontact.lastuserid lastuserid,   
    bookcontact.lastmaintdate lastmaintdate
FROM bookcontact,   
    bookcontactrole
WHERE bookcontact.bookcontactkey = bookcontactrole.bookcontactkey 
UNION
SELECT bookauthor.bookkey bookkey,
    1 printingkey,
    bookauthor.authorkey contactkey,
    CASE (SELECT COUNT(*) FROM gentablesrelationshipdetail WHERE gentablesrelationshipkey = 1 AND code1 = bookauthor.authortypecode)
      WHEN 0 THEN (SELECT datacode FROM gentables WHERE tableid = 285 AND qsicode = 4)
      ELSE (SELECT code2 FROM gentablesrelationshipdetail WHERE gentablesrelationshipkey = 1 AND code1 = bookauthor.authortypecode AND defaultind = 1)
    END roletypecode,
    bookauthor.lastuserid lastuserid,
    bookauthor.lastmaintdate lastmaintdate
FROM bookauthor
go

GRANT SELECT ON [dbo].[titlecontacts] TO PUBLIC
go
