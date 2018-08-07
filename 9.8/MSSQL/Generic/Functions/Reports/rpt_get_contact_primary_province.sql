SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_contact_primary_province') and xtype in (N'FN', N'IF', N'TF'))
  drop function rpt_get_contact_primary_province
GO

CREATE FUNCTION rpt_get_contact_primary_province (@i_globalcontactkey INT)
	RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @RETURN			VARCHAR(25)

	Select @RETURN = province
	  from globalcontactaddress
	 where primaryind = 1
	   and globalcontactkey = @i_globalcontactkey
  RETURN @RETURN
END
GO

grant execute on rpt_get_contact_primary_province to public
go