SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_contact_primary_country') and xtype in (N'FN', N'IF', N'TF'))
  drop function rpt_get_contact_primary_country
GO

CREATE FUNCTION rpt_get_contact_primary_country (@i_globalcontactkey INT)
	RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @RETURN			VARCHAR(50)

	Select @RETURN = s.datadesc
	 from globalcontactaddress a, gentables s
	where primaryind = 1
	  and s.tableid = 114
	  and a.countrycode = s.datacode
	  and globalcontactkey = @i_globalcontactkey

  RETURN @RETURN
END
GO

grant execute on rpt_get_contact_primary_country to public
go