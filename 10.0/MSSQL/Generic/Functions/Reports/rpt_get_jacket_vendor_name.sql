
/****** Object:  UserDefinedFunction [dbo].[rpt_get_jacket_vendor_name]    Script Date: 03/24/2009 13:11:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_jacket_vendor_name') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_jacket_vendor_name
GO
CREATE FUNCTION [dbo].[rpt_get_jacket_vendor_name](@i_bookkey INT)

/* returns the Jacket Vendor from the jacketspecs table */

RETURNS VARCHAR(75)

AS
BEGIN
	DECLARE @RETURN VARCHAR(75)

	SELECT @RETURN = v.name
	FROM		vendor v, jacketspecs c
	WHERE	@i_bookkey = c.bookkey
		AND v.vendorkey = c.vendorkey

	RETURN @RETURN
END

go
Grant All on dbo.rpt_get_jacket_vendor_name to Public
go