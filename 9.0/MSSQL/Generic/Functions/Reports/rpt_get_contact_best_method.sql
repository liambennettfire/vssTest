SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_contact_best_method') and xtype in (N'FN', N'IF', N'TF'))
  drop function rpt_get_contact_best_method
GO

CREATE FUNCTION rpt_get_contact_best_method (
		@i_globalcontactkey	INT,
		@i_contactmethodcode INT)
	RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @RETURN			VARCHAR(100)

	Select @RETURN = contactmethodvalue
	  from globalcontactmethod
	 where primaryind = 1
	   and contactmethodcode = @i_contactmethodcode
	   and globalcontactkey = @i_globalcontactkey


	If @RETURN is null or @RETURN = ''
	begin
		Select @RETURN = contactmethodvalue
		  from globalcontactmethod
		 where contactmethodcode = @i_contactmethodcode
		   and globalcontactkey = @i_globalcontactkey
	end
  RETURN @RETURN
END
GO

grant execute on rpt_get_contact_best_method to public
go