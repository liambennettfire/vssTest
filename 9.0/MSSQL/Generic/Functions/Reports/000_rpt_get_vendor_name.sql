IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_vendor_name') )
DROP FUNCTION dbo.rpt_get_vendor_name
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_vendor_name]    Script Date: 05/12/2009 19:43:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[rpt_get_vendor_name](
	@i_vendorkey	INT
)
RETURNS VARCHAR(75)
AS
/*  	
Returns the name field from the vendor table for the 
vendorkey passed
 
Parameter Options
		@i_vendorkey
												*/

BEGIN

	DECLARE @RETURN			VARCHAR(75)
	DECLARE @v_desc			VARCHAR(255)

	SELECT @v_desc = RTRIM(LTRIM(name))
		FROM vendor
 	 WHERE vendorkey = @i_vendorkey

	IF LEN(@v_desc)> 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


  RETURN @RETURN
END
GO


grant execute on [dbo].[rpt_get_vendor_name] to public
go


