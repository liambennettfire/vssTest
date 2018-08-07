USE [UAP_ECF]
GO

/****** Object:  View [dbo].[qweb_ecf_associated_crosselling_titles_vw]    Script Date: 03/08/2013 16:11:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER view [dbo].[qweb_ecf_associated_crosselling_titles_vw] as
SELECT     CAST(bookkey AS varchar) AS bookkey, CAST(dbo.qweb_ecf_get_product_bookkey(associatetitlebookkey) AS varchar) AS associatedtitlebookkey, sortorder
FROM         uap.dbo.associatedtitles
WHERE     (associationtypecode = 5) AND (COALESCE(dbo.qweb_ecf_get_product_bookkey(associatetitlebookkey), 0) <> 0) AND (bookkey IN
                          (SELECT     bookkey
                            FROM          uap.dbo.bookdetail
                            WHERE      (publishtowebind = 1))) AND (associatetitlebookkey IN
                          (SELECT     bookkey
                            FROM          uap.dbo.bookdetail AS bookdetail_1
                            WHERE      (publishtowebind = 1))) AND (bookkey IN
                          (SELECT     Code
                            FROM          dbo.Product
                            WHERE      (isnumeric(Code) = 1))) /*AND (associatetitlebookkey IN
                          (SELECT     Code
                            FROM          dbo.Product AS Product_1
                            WHERE      (isNumeric(Code) = 1)))*/
UNION
SELECT     p1.Code AS bookkey, p2.Code AS associatedtitlebookkey, 99 AS sortorder
FROM         dbo.Categorization AS c1 INNER JOIN
                      dbo.Categorization AS c2 ON c1.CategoryId = c2.CategoryId AND c1.ObjectId <> c2.ObjectId INNER JOIN
                      dbo.Product AS p1 ON c1.ObjectId = p1.ProductId INNER JOIN
                      dbo.Product AS p2 ON c2.ObjectId = p2.ProductId
WHERE     (c1.CategoryId IN
                          (SELECT     CategoryId
                            FROM          dbo.Category
                            WHERE      (ParentCategoryId = dbo.qweb_ecf_get_Category_ID('Subjects'))))

GO


