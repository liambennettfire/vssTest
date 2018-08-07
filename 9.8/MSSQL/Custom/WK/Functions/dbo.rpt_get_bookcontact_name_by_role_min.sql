if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[rpt_get_bookcontact_name_by_role_min]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.[rpt_get_bookcontact_name_by_role_min]
GO

CREATE FUNCTION [dbo].[rpt_get_bookcontact_name_by_role_min]
		(@i_bookkey	INT,
		@i_rolecode INT,
		 @v_column	VARCHAR(1))
	RETURNS VARCHAR(255)

/*	The purpose of the [rpt_get_contact_name_by_role] function is to return 
the name of the contact for a given role code. 
A title can have multiple participants assigned to it with the same role type. 
e.g. Multiple Reviewers

This function returns the name of the first contact (min sort order)
for the given role code and 
specific description column from gentables for a Role assigned to a 


	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	
AS
BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @globalcontactkey	INT

	SET @globalcontactkey = NULL
	SET @RETURN = ''

	Select TOP 1 @globalcontactkey = bc.globalcontactkey FROM bookcontact bc
	JOIN bookcontactrole bcr
	ON bc.bookcontactkey = bcr.bookcontactkey
	where bc.bookkey = @i_bookkey
	and bcr.rolecode = @i_rolecode
	ORDER BY sortorder

	IF @globalcontactkey = NULL
		RETURN ''

	SET @RETURN = [dbo].[rpt_get_contact_name](@globalcontactkey, @v_column)

	RETURN @RETURN

END
