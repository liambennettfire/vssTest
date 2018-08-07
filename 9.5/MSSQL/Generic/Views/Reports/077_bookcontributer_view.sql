SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[bookcontributor]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[bookcontributor]
GO

CREATE VIEW bookcontributor AS
SELECT bookcontact.bookkey bookkey,   
    bookcontact.printingkey printingkey,   
    bookcontact.globalcontactkey contributorkey,   
    bookcontactrole.rolecode roletypecode,   
    bookcontactrole.departmentcode depttypecode,   
    bookcontact.participantnote resourcedesc,   
    bookcontact.lastuserid lastuserid,   
    bookcontact.lastmaintdate lastmaintdate,   
    bookcontact.sortorder sortorder 
FROM bookcontact,   
    bookcontactrole, 
    globalcontact
WHERE bookcontact.bookcontactkey = bookcontactrole.bookcontactkey AND
    bookcontact.globalcontactkey = globalcontact.globalcontactkey AND
    globalcontact.personnelind = 1
    
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[bookcontributor]  TO [public]
GO



