if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_get_sku_format]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[qweb_ecf_get_sku_format]
GO

CREATE FUNCTION [dbo].[qweb_ecf_get_sku_format]
		(@i_productid	INT)

RETURNS nvarchar(512)

AS

begin

  DECLARE @RETURN nvarchar(512)


  Select @RETURN = SKU_Format
  from skuex_title_by_format se, sku
  where se.objectid = sku.skuid
    and sku.productid = @i_productid


  RETURN @RETURN


END
GO
Grant execute on dbo.qweb_ecf_get_sku_format to Public
GO