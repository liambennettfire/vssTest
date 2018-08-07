call set_connection.bat

SQLCMD -U%userid% -P%password% -S%server% -d%database% -i000_qweb_ecf_get_product_metakeywords.sql >import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i000_qweb_ecf_get_sku_awards.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i01_qweb_ecf_get_Category_ID.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i02_qweb_ecf_get_MetaClassID.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i03_qweb_ecf_get_product_id.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i04_qweb_ecf_get_sku_id.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i05_qweb_ecf_Insert_Products.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i05_qweb_ecf_Insert_Journal_Products.sql>>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i06_qweb_ecf_ProductEx_Titles.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i06_qweb_ecf_ProductEx_Journals.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i07_qweb_ecf_Insert_SKUs.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i07_qweb_ecf_Insert_Journal_SKUs.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i08_qweb_ecf_SKUEx_Title_by_format.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i08_qweb_ecf_SKUEx_Jounral_by_price.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i09_qweb_ecf_Categorization_Insert_Products.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i12_qweb_ecf_Category_Insert_UNP_Category.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i13_qweb_ecf_Categorization_Insert_UNP_Category.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i14_qweb_ecf_Category_Insert_WebFeature.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i145_qweb_ecf_associated_crosselling_titles_vw.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i15_qweb_ecf_Categorization_Insert_WebFeature.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i16_qweb_ecf_Insert_CrossSelling_Products.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i17_qweb_ecf_get_MetaFieldID.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i175_qweb_ecf_UpdateImageData.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i18_qweb_ecf_insert_product_images.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i19_qweb_ecf_insert_sku_images.sql >>import.log 
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i19_qweb_ecf_insert_sku_digitalpresskit.sql
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i19_qweb_ecf_insert_sku_excerpts.sql
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i20_qweb_ecf_CategoryExHome_Update.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i97_qweb_ecf_Insert_Product_Object_Access.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i98_qweb_ecf_Insert_Category_Object_Access.sql >>import.log
SQLCMD -U%userid% -P%password% -S%server% -d%database% -i999_qweb_ecf_import.sql >>import.log


