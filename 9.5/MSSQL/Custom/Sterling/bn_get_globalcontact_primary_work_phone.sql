/****** Object:  UserDefinedFunction [dbo].[bn_get_globalcontact_primary_work_phone]    Script Date: 04/19/2010 22:13:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



create FUNCTION [dbo].[bn_get_globalcontact_primary_work_phone]
		(@i_globalcontactkey	INT)

RETURNS VARCHAR(255)

/*	The purpose of the get_globalcontact_primary_phone function 
is to return a the primary phone type and number for a contact*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(255)
	DECLARE @v_desc				VARCHAR(255)
		
	SELECT 	@v_desc = ltrim(rtrim(contactmethodvalue))					

	FROM	globalcontactmethod
	WHERE	globalcontactkey = @i_globalcontactkey 
		and contactmethodcode = 1 and contactmethodsubcode=2
		and primaryind = 1


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END
go
grant all on dbo.bn_get_globalcontact_primary_work_phone to public
go

