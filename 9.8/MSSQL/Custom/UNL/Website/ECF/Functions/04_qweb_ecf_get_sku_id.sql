if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qweb_ecf_get_sku_id') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qweb_ecf_get_sku_id
GO


Create function qweb_ecf_get_sku_id (@i_bookkey int)

Returns int

as

Begin

Declare @RETURN as int

Select @RETURN = skuid
from sku
where code = Cast(@i_bookkey as varchar)

Return @Return

END
