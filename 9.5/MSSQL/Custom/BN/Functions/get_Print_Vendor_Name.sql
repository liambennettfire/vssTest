if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_Print_Vendor_Name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[get_Print_Vendor_Name]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE FUNCTION dbo.get_Print_Vendor_Name(@i_bookkey INT)

RETURNS VARCHAR(75)

AS
BEGIN
	DECLARE @RETURN VARCHAR(75)

	SELECT @RETURN = v.name
	FROM		vendor v, textspecs t
	WHERE	@i_bookkey = t.bookkey
		AND v.vendorkey = t.vendorkey

	RETURN @RETURN
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON [dbo].[get_Print_Vendor_Name]  TO [public]
GO

