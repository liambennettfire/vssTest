SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_contact_primary_zip') and xtype in (N'FN', N'IF', N'TF'))
  drop function rpt_get_contact_primary_zip
GO

CREATE FUNCTION rpt_get_contact_primary_zip (@i_globalcontactkey INT)
	RETURNS VARCHAR(10)

AS
BEGIN
	DECLARE @RETURN			VARCHAR(10)

	Select @RETURN = zipcode
	  from globalcontactaddress
	 where primaryind = 1
	   and globalcontactkey = @i_globalcontactkey

  RETURN @RETURN
END
GO

grant execute on rpt_get_contact_primary_zip to public
go