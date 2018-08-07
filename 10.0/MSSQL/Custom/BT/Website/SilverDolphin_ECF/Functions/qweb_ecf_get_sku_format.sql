USE [BT_SD_ECF]
GO
/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_sku_format]    Script Date: 01/27/2010 16:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER function [dbo].[qweb_ecf_get_sku_format]
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




