if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_printing_qty]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[get_printing_qty]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO







CREATE FUNCTION dbo.get_printing_qty(@i_bookkey INT, @i_printingkey INT, @i_qtyoutletcode INT, @i_qtyoutletsubcode INT)

RETURNS VARCHAR(255)

AS
BEGIN
	DECLARE @RETURN VARCHAR(255)

select @RETURN = qty
	from bookqtybreakdown where bookkey = @i_bookkey and 
				    printingkey = @i_printingkey and
				    qtyoutletcode = @i_qtyoutletcode and
				    qtyoutletsubcode = @i_qtyoutletsubcode

	RETURN @RETURN
END






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

