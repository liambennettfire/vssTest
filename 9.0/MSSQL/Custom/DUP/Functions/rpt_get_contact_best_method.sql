 
/****** Object:  UserDefinedFunction [dbo].[rpt_get_contact_best_method]    Script Date: 08/06/2015 12:24:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_contact_best_method]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_contact_best_method]
GO
 
/****** Object:  UserDefinedFunction [dbo].[rpt_get_contact_best_method]    Script Date: 08/06/2015 12:24:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[rpt_get_contact_best_method] (
		@i_globalcontactkey	INT,
		@i_contactmethodcode INT)
	RETURNS VARCHAR(100)
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
sp_refreshview 'dbo.rpt_contact_view'

