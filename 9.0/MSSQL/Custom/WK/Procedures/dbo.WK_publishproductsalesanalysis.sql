if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_publishproductsalesanalysis') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_publishproductsalesanalysis
GO
CREATE PROCEDURE [dbo].[WK_publishproductsalesanalysis]
@bookkey int
AS
BEGIN

--DECLARE @categorycode int,
--		@categorysubcode int,
--		@categorysub2code int
--
--IF EXISTS (Select * FROM booksubjectcategory where categorytableid = 412 and bookkey = @bookkey and categorysub2code IS NOT NULL OR categorysub2code <> 0)
--	BEGIN
--
--		Select TOP 1 @categorycode = @categorycode, @categorysubcode= categorysubcode,  
--		@categorysub2code = categorysub2code FROM booksubjectcategory where categorytableid = 412 and bookkey = @bookkey and categorysub2code IS NOT NULL OR categorysub2code <> 0
--		ORDER BY sortorder 
--
--		Select 
--		dbo.rpt_get_subgentables_field(412, @categorycode, @categorysubcode, 'D') as codesummaryvalue,
--		dbo.rpt_get_subgentables_field(412, @categorycode, @categorysubcode, '1') as codesummarydescription,
--		dbo.rpt_get_sub2gentables_field(412, @categorycode, @categorysubcode, @categorysub2code, '1') as codedescription,
--		dbo.rpt_get_sub2gentables_field(412, @categorycode, @categorysubcode, @categorysub2code, 'D') as codevalue,
--		@categorysub2code as [id]
--	END

/*
[dbo].[WK_publishproductsalesanalysis] 909096

Select * FROM booksubjectcategory
where categorytableid = 412
*/
Select TOP 1
dbo.rpt_get_subgentables_field(412, categorycode, categorysubcode, 'S') as codesummaryvalueField,
dbo.rpt_get_subgentables_field(412, categorycode, categorysubcode, '1') as codesummarydescriptionField,
dbo.rpt_get_sub2gentables_field(412, categorycode, categorysubcode, categorysub2code, '1') as codedescriptionField,
dbo.rpt_get_sub2gentables_field(412, categorycode, categorysubcode, categorysub2code, 'S') as codevalueField,
/* DON'T USE TM datacodes if these are used in other systems as well
SAC codes might be created from Advantage and we might need to store the id generated from Advantage in TM. 
We are going to use the externalcode field instead so we can manually input that value if needed. 
categorysub2code as [idField]
*/
dbo.rpt_get_sub2gentables_field(412, categorycode, categorysubcode, categorysub2code, 'E') as [idField]
FROM booksubjectcategory bsc
WHERE categorytableid = 412
and bookkey = @bookkey
and categorysub2code IS NOT NULL AND categorysub2code <> 0
ORDER BY bsc.sortorder 
END








