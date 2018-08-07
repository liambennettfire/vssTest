SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ucp_get_langley_discount]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ucp_get_langley_discount]
GO



CREATE FUNCTION ucp_get_langley_discount(
        @i_bookkey INT)
RETURNS VARCHAR(40)
AS
BEGIN
    DECLARE @discountExternalCode VARCHAR(40),
                    @mediaTypeCode INT,
                    @formatTypeCode INT,
                    @langleyDiscountCode VARCHAR(40)

    SELECT @discountExternalCode = discount.externalcode,
            @mediaTypecode = mediaTypeCode,
            @formatTypeCode = mediaTypeSubcode
        FROM bookdetail bd
            LEFT JOIN gentables discount
                ON discount.tableid = 459 
                    AND bd.discountcode = discount.datacode
        WHERE bd.bookkey = @i_bookkey

    IF @mediaTypeCode IN (3) 
        SELECT @langleyDiscountCode = 'CAL'  --Calendar
    ELSE IF @mediaTypeCode IN (13) AND @formatTypeCode IN (1,2) 
        SELECT @langleyDiscountCode = 'DIS'  --Other/Display
    ELSE IF @discountExternalCode = 'TX' AND @mediaTypeCode = 2 AND @formatTypeCode IN (6,20)
        IF @formatTypeCode = 6
            SELECT @langleyDiscountCode = 'SC'  --Short Cloth
        ELSE
            SELECT @langleyDiscountCode = 'SP'  --Short Paper
    ELSE IF LEN(COALESCE(@discountExternalCode,'')) = 0 
        SELECT @langleyDiscountCode = 'CND'      --Chicago No Discount 
    ELSE
        SELECT @langleyDiscountCode = @discountExternalCode

  RETURN @langleyDiscountCode
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
