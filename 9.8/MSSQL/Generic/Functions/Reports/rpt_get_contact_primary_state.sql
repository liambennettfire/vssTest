SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_contact_primary_state') and xtype in (N'FN', N'IF', N'TF'))
  drop function rpt_get_contact_primary_state
GO

CREATE FUNCTION rpt_get_contact_primary_state (@i_globalcontactkey INT)
	RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @RETURN			VARCHAR(2)

	Select @RETURN = 
	s.datadesc
	from globalcontactaddress a, stateabb_view s
	where primaryind = 1
	and a.statecode = s.datacode
	and globalcontactkey = @i_globalcontactkey

  RETURN @RETURN
END
GO

grant execute on rpt_get_contact_primary_state to public
go