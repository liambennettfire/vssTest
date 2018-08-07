if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qweb_ecf_get_product_id') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qweb_ecf_get_product_id
GO


Create function qweb_ecf_get_product_id (@i_bookkey int)

Returns int

as

Begin

Declare @RETURN as int

Select @RETURN = productid 
from product
where code = cast(@i_bookkey as varchar)

Return @Return

END
