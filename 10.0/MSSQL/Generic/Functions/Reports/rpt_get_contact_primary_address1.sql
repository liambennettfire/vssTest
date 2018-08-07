SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_contact_primary_address1') and xtype in (N'FN', N'IF', N'TF'))
  drop function rpt_get_contact_primary_address1
GO

CREATE FUNCTION rpt_get_contact_primary_address1 (@i_globalcontactkey INT)
	RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @RETURN			VARCHAR(255)

	Select @RETURN = 	address1
	  from globalcontactaddress
	 where primaryind = 1
	   and globalcontactkey = @i_globalcontactkey

  RETURN @RETURN
END
GO

grant execute on rpt_get_contact_primary_address1 to public
go
