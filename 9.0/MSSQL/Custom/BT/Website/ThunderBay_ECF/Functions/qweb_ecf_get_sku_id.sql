USE [BT_TB_ECF]
GO
/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_sku_id]    Script Date: 01/27/2010 16:54:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER function [dbo].[qweb_ecf_get_sku_id] (@i_bookkey int)

Returns int

as

Begin

Declare @RETURN as int

Select @RETURN = skuid
from sku
where code = Cast(@i_bookkey as varchar)

Return @Return

END
