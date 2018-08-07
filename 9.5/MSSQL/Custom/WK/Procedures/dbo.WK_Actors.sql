if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_Actors') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_Actors
GO
CREATE PROCEDURE dbo.WK_Actors
@bookkey int
AS
/*
firstNameField	CSIString	
idField	CSIString	
lastNameField	CSIString	
middleNameField	CSIString	
organizationsField	Organization	
	idField	CSIString
	sequenceField	CSIShort
	textField	CSIString
roleField	CSIString	
sequenceField	CSIShort	
succeedingTitleField	CSIString	



Select * FROM bookauthor

dbo.WK_Actors 575924

select * FROM globalcontact
where firstname like 'Tolga%'

Select * FROM bookauthor
where authorkey = 745554

*/

BEGIN

Select
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') IS NULL OR [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') = '' THEN gc.globalcontactkey
--ELSE (
--CASE WHEN EXISTS (Select * FROM dbo.WK_PRODUCT_ACTOR WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and pssglobalcontactkey = gc.globalcontactkey)
--	 THEN ( Select TOP 1 PRODUCT_ACTOR_ID FROM dbo.WK_PRODUCT_ACTOR WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and pssglobalcontactkey = gc.globalcontactkey ORDER BY DISPLAY_SEQUENCE )
--    ELSE gc.globalcontactkey END)
--END) as [idField],
gc.globalcontactkey as [idField], 
gc.firstname as firstNameField,
gc.middlename as middleNameField,
gc.lastname as lastNameField,
ba.sortorder as [sequenceField],
[dbo].[rpt_get_contact_role_minkey_OR_minsort](gc.globalcontactkey, 'D') as [roleField],
gc.degree as [succeedingTitleField] 
FROM 
bookauthor ba
JOIN globalcontact gc
ON ba.authorkey = gc.globalcontactkey
WHERE ba.bookkey = @bookkey
ORDER BY ba.sortorder
END