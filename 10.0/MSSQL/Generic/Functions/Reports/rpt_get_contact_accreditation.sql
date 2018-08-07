SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_contact_accreditation') and xtype in (N'FN', N'IF', N'TF'))
  drop function rpt_get_contact_accreditation
GO

CREATE FUNCTION rpt_get_contact_accreditation (@i_globalcontactkey INT)
	RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @RETURN			VARCHAR(40)

	Select @RETURN = 
	dbo.get_gentables_desc(210,"globalcontact"."accreditationcode",'D')
	from globalcontact
	where globalcontactkey = @i_globalcontactkey

  RETURN @RETURN
END
GO

grant execute on rpt_get_contact_accreditation to public
go