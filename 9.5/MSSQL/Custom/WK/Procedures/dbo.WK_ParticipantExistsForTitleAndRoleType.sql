if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_ParticipantExistsForTitleAndRoleType') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_ParticipantExistsForTitleAndRoleType
GO

CREATE PROCEDURE dbo.WK_ParticipantExistsForTitleAndRoleType
@bookkey int,
@rolecode int

as
BEGIN

SELECT     bookcontact.globalcontactkey, bookcontact.bookcontactkey, globalcontact.lastname, globalcontact.firstname
FROM         bookcontact INNER JOIN
                      bookcontactrole ON bookcontact.bookcontactkey = bookcontactrole.bookcontactkey INNER JOIN
                      globalcontact ON bookcontact.globalcontactkey = globalcontact.globalcontactkey
WHERE     (bookcontact.bookkey = @bookkey) AND (bookcontactrole.rolecode = @roleCode)

END

