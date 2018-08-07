SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_contact_addresstype') and xtype in (N'FN', N'IF', N'TF'))
  drop function rpt_get_contact_addresstype
GO

CREATE FUNCTION rpt_get_contact_addresstype (@i_globalcontactkey INT)
	RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @RETURN			VARCHAR(40)

	Select @RETURN = 
	dbo.get_gentables_desc(207,"globalcontactaddress"."addresstypecode",'long')
	from globalcontactaddress
	where globalcontactkey = @i_globalcontactkey

  RETURN @RETURN
END
GO

grant execute on rpt_get_contact_addresstype to public
go