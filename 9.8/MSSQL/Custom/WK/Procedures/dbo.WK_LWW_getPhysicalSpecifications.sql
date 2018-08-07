if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_LWW_getPhysicalSpecifications') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_LWW_getPhysicalSpecifications
GO

CREATE PROCEDURE dbo.WK_LWW_getPhysicalSpecifications
--@bookkey int
/*
(

SELECT product_id,weight, animation_count, has_sound, video_length, software_version,
       system_requirements, target_platform
  FROM physical_specifications
 WHERE product_id IN (SELECT intproductid
                        FROM tblloadproduct_spl));

SELECT product_id,weight, animation_count, has_sound, video_length, software_version,
       system_requirements, target_platform, *
  FROM WK_ORA.WKDBA.physical_specifications

Select Distinct software_version FROM WK_ORA.WKDBA.physical_specifications

Select * FROM  WK_ORA.WKDBA.physical_specifications
WHERE software_version IS NOT NULL

Select Distinct system_requirements FROM WK_ORA.WKDBA.physical_specifications

Select * FROM  WK_ORA.WKDBA.physical_specifications
WHERE system_requirements IS NOT NULL

Select LEN(system_requirements) FROM WK_ORA.WKDBA.physical_specifications
WHERE system_requirements IS NOT NULL
ORDER BY LEN(system_requirements) DESC

Select Distinct target_platform FROM WK_ORA.WKDBA.physical_specifications

Select * FROM  WK_ORA.WKDBA.physical_specifications
WHERE target_platform IS NOT NULL

Select DISTINCT VOLUME_SET_TYPE FROM  WK_ORA.WKDBA.physical_specifications

Select LEN(VOLUME_SET_TYPE) FROM WK_ORA.WKDBA.physical_specifications
WHERE VOLUME_SET_TYPE IS NOT NULL
ORDER BY LEN(VOLUME_SET_TYPE) DESC


SELECT product_id,weight, animation_count, has_sound, video_length, software_version,
       system_requirements, target_platform, *
  FROM WK_ORA.WKDBA.physical_specifications

Select *  FROM WK_ORA.WKDBA.physical_specifications

dbo.WK_LWW_getPhysicalSpecifications 584482

Select * FROM wk..book

*/
AS
BEGIN

Select
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') IS NULL OR [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') = '' THEN @bookkey
--ELSE (
--CASE WHEN EXISTS (Select * FROM dbo.WK_PHYSICAL_SPECIFICATIONS ps WHERE ps.PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 1, 'long'))
--	 THEN (Select PHYSICAL_SPECIFICATIONS_ID FROM dbo.WK_PHYSICAL_SPECIFICATIONS ps WHERE ps.PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 1, 'long'))
--    ELSE @bookkey END)
--END) as physical_specifications_id,
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') IS NULL 
--OR [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') = '' THEN @bookkey
--ELSE [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') END) as intproductid, --p.product_id intproductid,

--dbo.WK_getProductId(p.bookkey) as intproductid,
p.bookkey as intproductid,
(Select bookweight from booksimon where bookkey = p.bookkey) as strweight,
[dbo].[rpt_get_misc_value](p.bookkey, 33, 'long') as intanimationcount,
(CASE WHEN [dbo].[rpt_get_misc_value](p.bookkey, 34, 'long') = 'Yes' THEN 1
          ELSE 0 END)  as inthassound,
[dbo].[rpt_get_misc_value](p.bookkey, 35, 'long') as intvideolenght,
[dbo].[rpt_get_misc_value](p.bookkey, 38, 'long') as strsoftwareversion,
[dbo].[rpt_get_book_comment](p.bookkey, 3, 66, 3) as strsystemRequirements,
[dbo].[rpt_get_misc_value](p.bookkey, 39, 'long') as strtargetplatform 
FROM printing p
WHERE 
--bookkey = @bookkey
dbo.WK_IsEligibleforLWW(p.bookkey) = 'Y'
ORDER BY p.bookkey
END


