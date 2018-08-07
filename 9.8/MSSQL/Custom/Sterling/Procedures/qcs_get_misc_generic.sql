if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_get_misc_generic') and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop function dbo.qcs_get_misc_generic
GO

CREATE FUNCTION dbo.qcs_get_misc_generic (@bookkey INT,
@productTag VARCHAR(50))

RETURNS @generic_misc TABLE(
    --[Id] [uniqueidentifier] NOT NULL,
    Tag  VARCHAR(50),
    [Key] VARCHAR(25),
    AlternateKey VARCHAR(25),
	Value VARCHAR(4000) NULL
	)
AS
BEGIN

		  

			-- B&N unit cost 
			-- Get current unit cost if it exists O/W get the estimated
			-- First printing only 
			INSERT INTO @generic_misc
			SELECT 
			@productTag + '-' + 'BNUCST' AS Tag, 
			'DPIDXBIZBNUCST' AS 'Key', 
			'ZBNUCST' AS AlternateKey, 
			case when exists (Select 1 from bookmisc where bookkey = @bookkey and misckey = 36 and ISNULL(floatvalue, 0) > 0 
						and exists (Select 1 from maxprintingnum_view where bookkey = @bookkey and maxprintingnum = 1))
			THEN (Select floatvalue from bookmisc where bookkey = @bookkey and misckey = 36 and ISNULL(floatvalue, 0) > 0)
			ELSE (Select floatvalue from bookmisc where bookkey = @bookkey and misckey = 26 and ISNULL(floatvalue, 0) > 0 
				and exists (Select 1 from maxprintingnum_view where bookkey = @bookkey and maxprintingnum = 1))
			END as Value 
			-- The following section is not need if returning a row with a blank value is acceptable
			-- If there's no data, we should not return anything
			FROM book 
			where bookkey = @bookkey 
			and 
			(
			exists (Select 1 from bookmisc where bookkey = @bookkey and misckey = 36 and ISNULL(floatvalue, 0) > 0 
			and exists (Select 1 from maxprintingnum_view where bookkey = @bookkey and maxprintingnum = 1))
			OR exists (Select 1 from bookmisc where bookkey = @bookkey and misckey = 26 and ISNULL(floatvalue, 0) > 0 
			and exists (Select 1 from maxprintingnum_view where bookkey = @bookkey and maxprintingnum = 1))
			)  
			

			-- B&N Subject Code 
			-- TOP 1 
			INSERT INTO @generic_misc
			SELECT TOP 1 
			@productTag + '-' + 'BNSUBC' AS Tag, 
			'DPIDXBIZBNSUBC' AS 'Key', 
			'ZBNSUBC' AS AlternateKey, 
			 (Case WHEN ISNULL(bs.categorysubcode, 0) = 0 THEN g.externalcode 
			 ELSE s.externalcode END)
			 as Value 
			FROM booksubjectcategory bs
			JOIN gentables g 
			on bs.categorytableid = g.tableid and bs.categorycode = g.datacode 
			LEFT OUTER JOIN subgentables s 
			ON bs.categorytableid = s.tableid and bs.categorycode = s.datacode and bs.categorysubcode = s.datasubcode 
			where bookkey = @bookkey and bs.categorytableid = 437
			ORDER BY bs.sortorder 


			-- B&N Subject Desc 
			-- TOP 1 
			INSERT INTO @generic_misc
			SELECT TOP 1 
			
			@productTag + '-' + 'BNSUBD' AS Tag, 
			'DPIDXBIZBNSUBD' AS 'Key', 
			'ZBNSUBD' AS AlternateKey, 
			 (Case WHEN ISNULL(bs.categorysubcode, 0) = 0 THEN g.datadesc 
			 ELSE g.datadesc + ' - ' + s.datadesc END)
			 as Value 
			FROM booksubjectcategory bs
			JOIN gentables g 
			on bs.categorytableid = g.tableid and bs.categorycode = g.datacode 
			LEFT OUTER JOIN subgentables s 
			ON bs.categorytableid = s.tableid and bs.categorycode = s.datacode and bs.categorysubcode = s.datasubcode 
			where bookkey = @bookkey and bs.categorytableid = 437
			ORDER BY bs.sortorder 




	 RETURN
END
GO
GRANT SELECT ON dbo.qcs_get_misc_generic TO PUBLIC
