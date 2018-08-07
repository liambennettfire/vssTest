/*drops*/

USE [BARB_ECF2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MetaFileValue_MetaKey]') AND parent_object_id = OBJECT_ID(N'[dbo].[MetaFileValue]'))
ALTER TABLE [dbo].[MetaFileValue] DROP CONSTRAINT [FK_MetaFileValue_MetaKey]

USE [BARB_ECF2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MetaMultiValueDictionary_MetaKey]') AND parent_object_id = OBJECT_ID(N'[dbo].[MetaMultiValueDictionary]'))
ALTER TABLE [dbo].[MetaMultiValueDictionary] DROP CONSTRAINT [FK_MetaMultiValueDictionary_MetaKey]


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[Order_OrderSku_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[OrderSku]'))
ALTER TABLE [dbo].[OrderSku] DROP CONSTRAINT [Order_OrderSku_FK1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[SKU_OrderSku_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[OrderSku]'))
ALTER TABLE [dbo].[OrderSku] DROP CONSTRAINT [SKU_OrderSku_FK1]
USE [BARB_ECF2]
GO

USE [BARB_ECF2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[DiscountRestriction_RestrictionSku_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[RestrictionSku]'))
ALTER TABLE [dbo].[RestrictionSku] DROP CONSTRAINT [DiscountRestriction_RestrictionSku_FK1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[SKU_RestrictionSku_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[RestrictionSku]'))
ALTER TABLE [dbo].[RestrictionSku] DROP CONSTRAINT [SKU_RestrictionSku_FK1]
USE [BARB_ECF2]
GO
/****** Object:  Index [SKU_PK]    Script Date: 10/09/2008 12:08:48 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SKU]') AND name = N'SKU_PK')
ALTER TABLE [dbo].[SKU] DROP CONSTRAINT [SKU_PK]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[Currency_SKU_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[SKU]'))
ALTER TABLE [dbo].[SKU] DROP CONSTRAINT [Currency_SKU_FK1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SKU_Warehouse]') AND parent_object_id = OBJECT_ID(N'[dbo].[SKU]'))
ALTER TABLE [dbo].[SKU] DROP CONSTRAINT [FK_SKU_Warehouse]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[LicenseAgreement_SKU_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[SKU]'))
ALTER TABLE [dbo].[SKU] DROP CONSTRAINT [LicenseAgreement_SKU_FK1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[Package_SKU_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[SKU]'))
ALTER TABLE [dbo].[SKU] DROP CONSTRAINT [Package_SKU_FK1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[Product_SKU_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[SKU]'))
ALTER TABLE [dbo].[SKU] DROP CONSTRAINT [Product_SKU_FK1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[SkuTemplate_SKU_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[SKU]'))
ALTER TABLE [dbo].[SKU] DROP CONSTRAINT [SkuTemplate_SKU_FK1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[SNPackage_SKU_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[SKU]'))
ALTER TABLE [dbo].[SKU] DROP CONSTRAINT [SNPackage_SKU_FK1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[TaxCategory_SKU_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[SKU]'))
ALTER TABLE [dbo].[SKU] DROP CONSTRAINT [TaxCategory_SKU_FK1]

USE [BARB_ECF2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[ProductTemplate_Product_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[Product]'))
ALTER TABLE [dbo].[Product] DROP CONSTRAINT [ProductTemplate_Product_FK1]

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[Product_CrossSelling_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[CrossSelling]'))
ALTER TABLE [dbo].[CrossSelling] DROP CONSTRAINT [Product_CrossSelling_FK1]

USE [BARB_ECF2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ProductAccessory_Product]') AND parent_object_id = OBJECT_ID(N'[dbo].[ProductAccessory]'))
ALTER TABLE [dbo].[ProductAccessory] DROP CONSTRAINT [FK_ProductAccessory_Product]

USE [BARB_ECF2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ProductEditorialReview_Product]') AND parent_object_id = OBJECT_ID(N'[dbo].[ProductEditorialReview]'))
ALTER TABLE [dbo].[ProductEditorialReview] DROP CONSTRAINT [FK_ProductEditorialReview_Product]


USE [BARB_ECF2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ReviewRating_CustomerAccount]') AND parent_object_id = OBJECT_ID(N'[dbo].[ReviewRating]'))
ALTER TABLE [dbo].[ReviewRating] DROP CONSTRAINT [FK_ReviewRating_CustomerAccount]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ReviewRating_Product]') AND parent_object_id = OBJECT_ID(N'[dbo].[ReviewRating]'))
ALTER TABLE [dbo].[ReviewRating] DROP CONSTRAINT [FK_ReviewRating_Product]
USE [BARB_ECF2]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[Discount_SkuDiscount_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[SkuDiscount]'))
ALTER TABLE [dbo].[SkuDiscount] DROP CONSTRAINT [Discount_SkuDiscount_FK1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[SKU_SkuDiscount_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[SkuDiscount]'))
ALTER TABLE [dbo].[SkuDiscount] DROP CONSTRAINT [SKU_SkuDiscount_FK1]

USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[SKU] DROP CONSTRAINT [DF_SKU_Created]
GO
ALTER TABLE [dbo].[SKU] DROP CONSTRAINT [DF_SKU_LicenseAgreementId]
GO
ALTER TABLE [dbo].[SKU] DROP CONSTRAINT [DF_SKU_Updated]

USE [BARB_ECF2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[SKU_ShoppingCartItem_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[ShoppingCartItem]'))
ALTER TABLE [dbo].[ShoppingCartItem] DROP CONSTRAINT [SKU_ShoppingCartItem_FK1]
USE [BARB_ECF2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[CustomerSession_ShoppingCartItem_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[ShoppingCartItem]'))
ALTER TABLE [dbo].[ShoppingCartItem] DROP CONSTRAINT [CustomerSession_ShoppingCartItem_FK1]

truncate table skuex_journal_by_pricetype
truncate table skuex_journal_by_pricetype_history
truncate table skuex_title_by_format
truncate table skuex_title_by_format_history

truncate table productex_contributors
truncate table productex_contributors_history
truncate table productex_journals
truncate table productex_journals_history
truncate table productex_titles
truncate table productex_titles_history

truncate table pageex_page_content_class

set nocount on
go

truncate table sku
truncate table product
delete from [order]
delete from ordershipment
delete from ordershipmentstatus
delete from ordersku
delete from orderskushipment
--delete from category
set nocount off
go
truncate table categorization
truncate table categoryex_contributor
truncate table categoryex_contributor_history
truncate table categoryex_contributor_type_category
truncate table categoryex_contributor_type_category_history
--truncate table categoryex_home
--truncate table categoryex_home_history
--truncate table categoryex_journals_home
--truncate table categoryex_journals_home_history
truncate table categoryex_title_subject
truncate table categoryex_title_subject_history
truncate table categoryex_title_subject_subcategory
truncate table categoryex_title_subject_subcategory_history
truncate table categoryex_title_catalogs
truncate table categoryex_title_catalogs_history
truncate table categoryex_title_distributors
truncate table categoryex_title_distributors_history
--truncate table categoryex_web_feature
--truncate table categoryex_web_feature_history
truncate table metafilevalue

--do customers!

delete from customeraccount
truncate table customeraddress
truncate table customerattribute
truncate table customerdiscount
truncate table customerrole
delete from customersession
go

-- clean up object access
delete from objectaccess
where objecttypeid = 1
and objectid not in (select productid from product)

delete from objectaccess
where objecttypeid = 2
and objectid not in (select skuid from sku)

delete from objectaccess
where objecttypeid = 3
and objectid not in (select categoryid from category)

delete from ObjectLanguage
where objecttypeid = 1
and objectid not in (select productid from product)

delete from ObjectLanguage
where objecttypeid = 2
and objectid not in (select skuid from sku)

delete from ObjectLanguage
where objecttypeid = 3
and objectid not in (select categoryid from category)

/*adds*/

USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[CrossSelling]  WITH CHECK ADD  CONSTRAINT [Product_CrossSelling_FK1] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([ProductId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CrossSelling] CHECK CONSTRAINT [Product_CrossSelling_FK1]



USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[ProductAccessory]  WITH CHECK ADD  CONSTRAINT [FK_ProductAccessory_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([ProductId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ProductAccessory] CHECK CONSTRAINT [FK_ProductAccessory_Product]



USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[ProductEditorialReview]  WITH CHECK ADD  CONSTRAINT [FK_ProductEditorialReview_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([ProductId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ProductEditorialReview] CHECK CONSTRAINT [FK_ProductEditorialReview_Product]


USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[ReviewRating]  WITH CHECK ADD  CONSTRAINT [FK_ReviewRating_CustomerAccount] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[CustomerAccount] ([CustomerId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ReviewRating] CHECK CONSTRAINT [FK_ReviewRating_CustomerAccount]
GO
ALTER TABLE [dbo].[ReviewRating]  WITH CHECK ADD  CONSTRAINT [FK_ReviewRating_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([ProductId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ReviewRating] CHECK CONSTRAINT [FK_ReviewRating_Product]

USE [BARB_ECF2]
GO
/****** Object:  Index [SKU_PK]    Script Date: 10/09/2008 11:38:51 ******/
ALTER TABLE [dbo].[SKU] ADD  CONSTRAINT [SKU_PK] PRIMARY KEY CLUSTERED 
(
	[SkuId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [Currency_SKU_FK1] FOREIGN KEY([CurrencyId])
REFERENCES [dbo].[Currency] ([CurrencyId])
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [Currency_SKU_FK1]
GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [FK_SKU_Warehouse] FOREIGN KEY([WarehouseId])
REFERENCES [dbo].[Warehouse] ([WarehouseId])
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [FK_SKU_Warehouse]
GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [LicenseAgreement_SKU_FK1] FOREIGN KEY([LicenseAgreementId])
REFERENCES [dbo].[LicenseAgreement] ([LicenseAgreementId])
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [LicenseAgreement_SKU_FK1]
GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [Package_SKU_FK1] FOREIGN KEY([PackageId])
REFERENCES [dbo].[Package] ([PackageId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [Package_SKU_FK1]
GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [Product_SKU_FK1] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([ProductId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [Product_SKU_FK1]
GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [SkuTemplate_SKU_FK1] FOREIGN KEY([SkuTemplateId])
REFERENCES [dbo].[SkuTemplate] ([SkuTemplateId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [SkuTemplate_SKU_FK1]
GO
ALTER TABLE [dbo].[SKU]  WITH NOCHECK ADD  CONSTRAINT [SNPackage_SKU_FK1] FOREIGN KEY([SNPackageId])
REFERENCES [dbo].[SNPackage] ([SNPackageId])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[SKU] NOCHECK CONSTRAINT [SNPackage_SKU_FK1]
GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [TaxCategory_SKU_FK1] FOREIGN KEY([TaxCategoryId])
REFERENCES [dbo].[TaxCategory] ([TaxCategoryId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [TaxCategory_SKU_FK1]

USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[SKU] ADD  CONSTRAINT [DF_SKU_Created]  DEFAULT (getdate()) FOR [Created]
GO
ALTER TABLE [dbo].[SKU] ADD  CONSTRAINT [DF_SKU_LicenseAgreementId]  DEFAULT ((0)) FOR [LicenseAgreementId]
GO
ALTER TABLE [dbo].[SKU] ADD  CONSTRAINT [DF_SKU_Updated]  DEFAULT (getdate()) FOR [Updated]

USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [ProductTemplate_Product_FK1] FOREIGN KEY([ProductTemplateId])
REFERENCES [dbo].[ProductTemplate] ([ProductTemplateId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [ProductTemplate_Product_FK1]

USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[Product] ADD  CONSTRAINT [DF_Product_Created]  DEFAULT (getdate()) FOR [Created]
GO
ALTER TABLE [dbo].[Product] ADD  CONSTRAINT [DF_Product_Updated]  DEFAULT (getdate()) FOR [Updated]

USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[SkuDiscount]  WITH CHECK ADD  CONSTRAINT [Discount_SkuDiscount_FK1] FOREIGN KEY([DiscountId])
REFERENCES [dbo].[Discount] ([DiscountId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SkuDiscount] CHECK CONSTRAINT [Discount_SkuDiscount_FK1]
GO
ALTER TABLE [dbo].[SkuDiscount]  WITH CHECK ADD  CONSTRAINT [SKU_SkuDiscount_FK1] FOREIGN KEY([SkuId])
REFERENCES [dbo].[SKU] ([SkuId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SkuDiscount] CHECK CONSTRAINT [SKU_SkuDiscount_FK1]

USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[ShoppingCartItem]  WITH CHECK ADD  CONSTRAINT [SKU_ShoppingCartItem_FK1] FOREIGN KEY([SkuId])
REFERENCES [dbo].[SKU] ([SkuId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ShoppingCartItem] CHECK CONSTRAINT [SKU_ShoppingCartItem_FK1]
USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[ShoppingCartItem]  WITH NOCHECK ADD  CONSTRAINT [CustomerSession_ShoppingCartItem_FK1] FOREIGN KEY([CustomerSessionId])
REFERENCES [dbo].[CustomerSession] ([CustomerSessionId])
GO
ALTER TABLE [dbo].[ShoppingCartItem] NOCHECK CONSTRAINT [CustomerSession_ShoppingCartItem_FK1]

USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[RestrictionSku]  WITH CHECK ADD  CONSTRAINT [DiscountRestriction_RestrictionSku_FK1] FOREIGN KEY([DiscountRestrictionId])
REFERENCES [dbo].[DiscountRestriction] ([DiscountRestrictionId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RestrictionSku] CHECK CONSTRAINT [DiscountRestriction_RestrictionSku_FK1]
GO
ALTER TABLE [dbo].[RestrictionSku]  WITH CHECK ADD  CONSTRAINT [SKU_RestrictionSku_FK1] FOREIGN KEY([SkuId])
REFERENCES [dbo].[SKU] ([SkuId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RestrictionSku] CHECK CONSTRAINT [SKU_RestrictionSku_FK1]

USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[OrderSku]  WITH CHECK ADD  CONSTRAINT [Order_OrderSku_FK1] FOREIGN KEY([OrderId])
REFERENCES [dbo].[Order] ([OrderId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[OrderSku] CHECK CONSTRAINT [Order_OrderSku_FK1]
GO
ALTER TABLE [dbo].[OrderSku]  WITH CHECK ADD  CONSTRAINT [SKU_OrderSku_FK1] FOREIGN KEY([SkuId])
REFERENCES [dbo].[SKU] ([SkuId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[OrderSku] CHECK CONSTRAINT [SKU_OrderSku_FK1]

/****** Object:  Table [dbo].[Product]    Script Date: 10/09/2008 12:20:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Product](
	[ProductId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Visible] [bit] NULL,
	[ProductTemplateId] [int] NULL,
	[MetaClassId] [int] NULL,
	[Updated] [datetime] NOT NULL CONSTRAINT [DF_Product_Updated]  DEFAULT (getdate()),
	[Created] [datetime] NOT NULL CONSTRAINT [DF_Product_Created]  DEFAULT (getdate()),
	[IsInherited] [bit] NOT NULL,
	[Code] [nvarchar](50) NULL,
 CONSTRAINT [Product_PK] PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [ProductTemplate_Product_FK1] FOREIGN KEY([ProductTemplateId])
REFERENCES [dbo].[ProductTemplate] ([ProductTemplateId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [ProductTemplate_Product_FK1]



/****** Object:  Table [dbo].[SKU]    Script Date: 10/09/2008 12:19:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
drop table sku
go
CREATE TABLE [dbo].[SKU](
	[SkuId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Price] [money] NULL,
	[Visible] [bit] NULL,
	[ProductId] [int] NULL,
	[MetaClassId] [int] NULL,
	[CurrencyId] [nchar](3) NULL,
	[TaxCategoryId] [int] NULL,
	[SkuType] [int] NULL,
	[Description] [ntext] NULL,
	[LicenseAgreementId] [int] NULL CONSTRAINT [DF_SKU_LicenseAgreementId]  DEFAULT ((0)),
	[Code] [nvarchar](50) NULL,
	[Weight] [float] NULL,
	[PackageId] [int] NULL,
	[ShipEnabled] [bit] NULL,
	[SkuTemplateId] [int] NULL,
	[Created] [datetime] NOT NULL CONSTRAINT [DF_SKU_Created]  DEFAULT (getdate()),
	[Updated] [datetime] NOT NULL CONSTRAINT [DF_SKU_Updated]  DEFAULT (getdate()),
	[ReorderMinQty] [int] NULL,
	[StockQty] [int] NULL,
	[ReservedQty] [int] NULL,
	[OutOfStockVisible] [bit] NULL,
	[SNPackageId] [int] NULL,
	[CycleMode] [int] NOT NULL,
	[CycleLength] [int] NOT NULL,
	[MaxCyclesCount] [int] NOT NULL,
	[WarehouseId] [int] NULL,
	[Ordering] [int] NULL,
 CONSTRAINT [SKU_PK] PRIMARY KEY CLUSTERED 
(
	[SkuId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [Currency_SKU_FK1] FOREIGN KEY([CurrencyId])
REFERENCES [dbo].[Currency] ([CurrencyId])
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [Currency_SKU_FK1]
GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [FK_SKU_Warehouse] FOREIGN KEY([WarehouseId])
REFERENCES [dbo].[Warehouse] ([WarehouseId])
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [FK_SKU_Warehouse]
GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [LicenseAgreement_SKU_FK1] FOREIGN KEY([LicenseAgreementId])
REFERENCES [dbo].[LicenseAgreement] ([LicenseAgreementId])
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [LicenseAgreement_SKU_FK1]
GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [Package_SKU_FK1] FOREIGN KEY([PackageId])
REFERENCES [dbo].[Package] ([PackageId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [Package_SKU_FK1]
GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [Product_SKU_FK1] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([ProductId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [Product_SKU_FK1]
GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [SkuTemplate_SKU_FK1] FOREIGN KEY([SkuTemplateId])
REFERENCES [dbo].[SkuTemplate] ([SkuTemplateId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [SkuTemplate_SKU_FK1]
GO
ALTER TABLE [dbo].[SKU]  WITH NOCHECK ADD  CONSTRAINT [SNPackage_SKU_FK1] FOREIGN KEY([SNPackageId])
REFERENCES [dbo].[SNPackage] ([SNPackageId])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[SKU] NOCHECK CONSTRAINT [SNPackage_SKU_FK1]
GO
ALTER TABLE [dbo].[SKU]  WITH CHECK ADD  CONSTRAINT [TaxCategory_SKU_FK1] FOREIGN KEY([TaxCategoryId])
REFERENCES [dbo].[TaxCategory] ([TaxCategoryId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SKU] CHECK CONSTRAINT [TaxCategory_SKU_FK1]


USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[MetaFileValue]  WITH CHECK ADD  CONSTRAINT [FK_MetaFileValue_MetaKey] FOREIGN KEY([MetaKey])
REFERENCES [dbo].[MetaKey] ([MetaKey])
GO
ALTER TABLE [dbo].[MetaFileValue] CHECK CONSTRAINT [FK_MetaFileValue_MetaKey]

USE [BARB_ECF2]
GO
ALTER TABLE [dbo].[MetaMultiValueDictionary]  WITH CHECK ADD  CONSTRAINT [FK_MetaMultiValueDictionary_MetaKey] FOREIGN KEY([MetaKey])
REFERENCES [dbo].[MetaKey] ([MetaKey])
GO
ALTER TABLE [dbo].[MetaMultiValueDictionary] CHECK CONSTRAINT [FK_MetaMultiValueDictionary_MetaKey]

