USE [UAP_ECF]
GO
/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_crossselling_products]    Script Date: 03/08/2013 12:32:01 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[qweb_ecf_get_crossselling_products](
  @i_bookkey        integer)
RETURNS @CrossSellingProductList TABLE(
	bookkey NVARCHAR(50),
	associatedtitlebookkey NVARCHAR(50),
	sortorder INT
)
AS
BEGIN
  DECLARE @v_bookkey INT,
          @v_categoryid INT,
          @v_productid INT,
          @v_count INT,
          @error_var  INT,
          @rowcount_var INT
      

  INSERT INTO @CrossSellingProductList (bookkey,associatedtitlebookkey,sortorder)
  SELECT CAST(bookkey AS varchar) AS bookkey, CAST(dbo.qweb_ecf_get_product_bookkey(associatetitlebookkey) AS varchar) AS associatedtitlebookkey, sortorder
    FROM uap.dbo.associatedtitles
   WHERE (associationtypecode = 5) AND (COALESCE(dbo.qweb_ecf_get_product_bookkey(associatetitlebookkey), 0) <> 0) AND (bookkey IN
         (SELECT bookkey
            FROM uap.dbo.bookdetail
           WHERE (publishtowebind = 1))) AND (associatetitlebookkey IN
         (SELECT bookkey
            FROM uap.dbo.bookdetail AS bookdetail_1
           WHERE (publishtowebind = 1))) AND (bookkey IN
         (SELECT Code
            FROM dbo.Product
           WHERE (isnumeric(Code) = 1))) /*AND (associatetitlebookkey IN
         (SELECT Code
            FROM dbo.Product AS Product_1
           WHERE (isNumeric(Code) = 1)))*/
     AND bookkey = @v_bookkey
      
      
  SELECT @v_productid = ObjectId
    FROM ProductEx_Titles
   WHERE pss_product_bookkey = @i_bookkey
   
  INSERT INTO @CrossSellingProductList (bookkey,associatedtitlebookkey,sortorder)
  SELECT DISTINCT @i_bookkey, p.pss_product_bookkey, 99
    FROM Categorization c, ProductEx_Titles p, Product
   WHERE c.objectid = p.objectid
     and p.objectid = Product.ProductId
     and c.categoryid in (SELECT categoryid FROM Categorization WHERE objectid = @v_productid 
                             and categoryid <> dbo.qweb_ecf_get_Category_ID('Titles'))
     and p.pss_product_bookkey <> @i_bookkey
     and Product.visible > 0
            
  RETURN
END
