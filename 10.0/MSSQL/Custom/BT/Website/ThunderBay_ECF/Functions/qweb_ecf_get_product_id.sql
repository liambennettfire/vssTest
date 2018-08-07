USE [BT_TB_ECF]
GO
/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_product_id]    Script Date: 01/27/2010 16:53:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER function [dbo].[qweb_ecf_get_product_id] (@i_bookkey int)

Returns int

as

Begin

Declare @RETURN as int

Select @RETURN = productid 
from product
where code = cast(@i_bookkey as varchar)

Return @Return

END

