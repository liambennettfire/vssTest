USE [UAP_ECF]
GO
/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_product_bookkey]    Script Date: 03/08/2013 13:32:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


--Returns the bookkey for whatever Product this bookkey is associated with (may be the one you passed if it is the primary)
ALTER function [dbo].[qweb_ecf_get_product_bookkey] (@i_bookkey int)

Returns int

as

Begin

Declare @RETURN as int,
		@cnt as int,
		@productId as int

Select @cnt = COUNT(*) 
from Product
where Code = cast(@i_bookkey as varchar)

If @cnt > 0
Begin
	Set @RETURN = @i_bookkey
End
Else Begin
	Select distinct @productId = ProductId
	from SKU
	where Code = CAST(@i_bookkey as varchar)
	
	If COALESCE(@productId, -1) > 0
	Begin
		Select @RETURN = CAST(Code as int)
		from Product
		where ProductId = @productId
			AND Visible = 1
	End
End

Return @RETURN

END

