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
		-- Item type for TIB: IF FORMAT IS DISPLAYS / PREPACKS / SETS THEN Non-Book 
		-- Per hachette these should be B as well, commenting out 08/25/2017
		--INSERT INTO @generic_misc
		--SELECT TOP 1 
		---- NEWID() AS Id,
		--@productTag + '-' + 'HBGITEMTYPE' AS Tag,
		--'DPIDXBIZHBGITEMTYPE' AS 'Key', 
		--'HBGITEMTYPE' AS AlternateKey, 
		--(Case WHEN externalcode = '57' THEN 'N' ELSE 'B' END) as Value
		--FROM booksubjectcategory bsc 
		--join gentables g on bsc.categorytableid = g.tableid and bsc.categorycode = g.datacode 
		--where bookkey = @bookkey and g.tableid = 414 and g.deletestatus = 'N' and ISNULL(externalcode, '') <> ''
		--ORDER BY bsc.sortorder 


		-- hachette family code, stored in alternatedesc1 of sub2gentables 412
		INSERT INTO @generic_misc
		SElect TOP 1 
         -- NEWID() AS Id,
		 @productTag + '-' + 'CID1FAMLYCODE' AS Tag,
		 'DPIDXBIZCID1FAMLYCODE' AS 'Key', 
		 'CID1FAMLYCODE' AS AlternateKey, 
		s2.alternatedesc1 as Value
		 
		FROm booksubjectcategory bcs
		JOIN sub2gentables s2
		on bcs.categorycode = s2.datacode and bcs.categorysubcode = s2.datasubcode and bcs.categorysub2code = s2.datasub2code and bcs.categorytableid = s2.tableid
		JOIN subgentables s
		on s2.datasubcode = s.datasubcode and s2.datacode = s.datacode and s2.tableid = s.tableid 
		JOIN gentables g
		on s.datacode = g.datacode and s.tableid = g.tableid 
		where bcs.categorytableid = 412 and bcs.bookkey = @bookkey 
		and s2.deletestatus = 'N' and s.deletestatus = 'N' and g.deletestatus = 'N'
		and ISNULL(s2.alternatedesc1, '') <> '' and LEN(s2.alternatedesc1) = 8 

		-- hachette format codes, stored in externalcode of gentables 414 
		Insert into @generic_misc
		Select  
		-- NEWID() AS Id,
		@productTag + '-' + 'HBGFORMAT' AS Tag, 
		'DPIDXBIZHBGFORMAT' AS 'Key', 
		'HBGFORMAT' AS AlternateKey, 
		g.externalcode as Value 
		FROM booksubjectcategory bsc 
		join gentables g on bsc.categorytableid = g.tableid and bsc.categorycode = g.datacode 
		where bookkey = @bookkey and g.tableid = 414 and g.deletestatus = 'N' and ISNULL(externalcode, '') <> ''


		-- Hachette sub format codes, stored in externalcode of subgentables 414 

		Insert into @generic_misc
		Select  
		-- NEWID() AS Id,
		@productTag + '-' + 'SUBFORMAT' AS Tag, 
		'DPIDXBIZSUBFORMAT' AS 'Key', 
		'SUBFORMAT' AS AlternateKey, 
		s.externalcode as Value 
		FROM booksubjectcategory bsc 
		JOIN subgentables s 
		ON bsc.categorytableid = s.tableid and bsc.categorycode = s.datacode and bsc.categorysubcode = s.datasubcode 
		join gentables g 
		on s.tableid = g.tableid and s.datacode = g.datacode 
		where bookkey = @bookkey and s.tableid = 414 and g.deletestatus = 'N' 
		and s.deletestatus = 'N'
		and ISNULL(s.externalcode, '') <> ''

		-- NO CHARGE FLAG: if media is prepack then Y otherwise N
		-- Do not use per meeting with Kristina, Larry and Ian on 3/8/17
		--INSERT INTO @generic_misc
		--SELECT 
		---- NEWID() AS Id,
		--@productTag + '-' + 'NOCHARGEFLG' AS Tag, 
		--'DPIDXBIZNOCHARGEFLG' AS 'Key', 
		--'NOCHARGEFLG' AS AlternateKey, 
		--(Case when ISNULL(g.eloquencefieldtag, '') = 'P' THEN 'Y' ELSE 'N' END) AS Value
		--FROM
		--bookdetail  bd
		--JOIN gentables g
		--ON bd.mediatypecode = g.datacode 
		--WHERE bookkey = @bookkey AND g.tableid = 312 

		-- New logic as of 3/14/17, if media format is Other--> catalog/promotional then Y o/w N
		INSERT INTO @generic_misc
		SELECT 
		-- NEWID() AS Id,
		@productTag + '-' + 'NOCHARGEFLG' AS Tag, 
		'DPIDXBIZNOCHARGEFLG' AS 'Key', 
		'NOCHARGEFLG' AS AlternateKey, 
		(Case when mediatypecode = 15 and mediatypesubcode in (1,2) THEN 'Y' ELSE '' END) AS Value
		FROM
		bookdetail  bd
		--JOIN gentables g
		--ON bd.mediatypecode = g.datacode 
		WHERE bookkey = @bookkey --AND g.tableid = 312 





		-- AltItemID - stored in isbn.isbn10 field, need to send it to Hachette 
		-- isbn10 goes to cloud but to make template maintenance easier we will be using the same eloquence field id within this function. 
			--Insert into @generic_misc
			--Select  
			---- NEWID() AS Id,
			--@productTag + '-' + 'ALTITEMID' AS Tag, 
			--'DPIDXBIZALTITEMID' AS 'Key', 
			--'ALTITEMID' AS AlternateKey, 
			--isbn10 as Value 
			--FROM isbn 
			--WHERE bookkey = @bookkey and ISNULL(isbn10, '') <> ''



		-- PRODUCT PROFILE: Derive from BISAC subjects 
		-- Per Kristina on 03/09/17, the following two should remain Non-Fiction
		-- LIT004260 -- Literary Criticism --> Science Fiction & Fantasy
		-- ART050060 -- Art --> Subjects & Themes/Science Fiction & Fantasy
		-- this returns nothing if there's no value in bookbisaccategory
		  IF exists (Select 1 from bookbisaccategory bbc
						join gentables g 
						on bbc.bisaccategorycode = g.datacode 
						where bbc.bookkey = @bookkey and bbc.printingkey = 1
						and g.tableid = 339 and g.deletestatus = 'N' and g.eloquencefieldtag in ('FIC','JUV', 'YAF'))
			OR EXISTS (Select 1 from bookbisaccategory bbc
						join subgentables s 
						on bbc.bisaccategorycode = s.datacode and s.datasubcode = bbc.bisaccategorysubcode
						where bbc.bookkey = @bookkey and bbc.printingkey = 1
						and s.tableid = 339 and s.deletestatus = 'N' and 
						(s.datadesc like '% Fiction%' OR s.datadesc like 'Fiction%')
						and s.eloquencefieldtag not in ('LIT004260', 'ART050060'))
				BEGIN
					INSERT INTO @generic_misc
					SELECT 
					-- NEWID() AS Id,
					@productTag + '-' + 'ZPRDPROF' AS Tag,
					'DPIDXBIZPRDPROF' AS 'Key', 
					'ZPRDPROF' AS AlternateKey, 
					'1' as Value  -- Default to Non-fiction
				END
			ELSE
				BEGIN
					INSERT INTO @generic_misc
					SELECT 
					-- NEWID() AS Id,
					@productTag + '-' + 'ZPRDPROF' AS Tag,
					'DPIDXBIZPRDPROF' AS 'Key', 
					'ZPRDPROF' AS AlternateKey, 
					'2' as Value  -- Default to Non-fiction
				
				END



			-- OLD IMPLEMENTATION - was returning nothing when no bisac existed OR multiple rows if multiple bisacs are on the title
			--BEGIN
			--	INSERT INTO @generic_misc
			--	SELECT 
			--	-- NEWID() AS Id,
			--	@productTag + '-' + 'ZPRDPROF' AS Tag,
			--	'DPIDXBIZPRDPROF' AS 'Key', 
			--	'ZPRDPROF' AS AlternateKey, 
			--	(Case when exists (Select 1 from gentables g where g.tableid = 339 and datacode = bbc.bisaccategorycode and g.deletestatus = 'N' and g.eloquencefieldtag in ('FIC','JUV', 'YAF'))
			--	OR exists (select 1 from subgentables s where s.tableid = 339 and s.datacode = bbc.bisaccategorycode and s.datasubcode = bbc.bisaccategorysubcode and s.deletestatus = 'N'
			--	and (s.datadesc like '% Fiction%' OR s.datadesc like 'Fiction%')
			--	and s.eloquencefieldtag not in ('LIT004260', 'ART050060')) THEN '1'
			--	ELSE '2' END) as Value 
			--	FROM bookbisaccategory bbc 
			--	where bookkey = @bookkey and printingkey = 1
			--END


		-- Send Hachette verification status to the cloud
			-- we will use it to filter out failed titles
			-- by creating a filter expression on the channel
			-- 05/22/17
			Insert into @generic_misc
			Select  
			-- NEWID() AS Id,
			@productTag + '-' + 'ZHBGVERSTATUS' AS Tag, 
			'DPIDXBIZHBGVERSTATUS' AS 'Key', 
			'ZHBGVERSTATUS' AS AlternateKey, 
			g.datadesc as Value 
			FROM bookverification bv
			JOIN gentables g 
			ON bv.titleverifystatuscode = g.datacode 
			WHERE bv.bookkey = @bookkey 
			and g.tableid = 513 
			and bv.verificationtypecode = 8 -- Hachette


			-- associated format code
			-- is the format of the primary component of the set 
			if exists (Select 1 from book where bookkey = @bookkey and usageclasscode = 2)
				BEGIN
					-- hachette format codes, stored in externalcode of gentables 414 
					Insert into @generic_misc
					Select --TOP 1 
					-- NEWID() AS Id,
					@productTag + '-' + 'ZASSCFORMAT' AS Tag, 
					'DPIDXBIZASSCFORMAT' AS 'Key', 
					'ZASSCFORMAT' AS AlternateKey, 
					g.externalcode as Value 
					FROM associatedtitles a 
					JOIN booksubjectcategory bsc
					ON a.associatetitlebookkey = bsc.bookkey  
					join gentables g on bsc.categorytableid = g.tableid and bsc.categorycode = g.datacode 
					where a.bookkey = @bookkey 
					and a.associationtypecode = 6 -- titles in sets
					and a.associationtypesubcode = 1 -- set component
					and g.tableid = 414 
					and g.deletestatus = 'N' 
					and ISNULL(externalcode, '') <> ''
					and a.sortorder = 1 -- first component is considered primary
					--ORDER BY a.sortorder


					-- Hachette sub format codes, stored in externalcode of subgentables 414 

					Insert into @generic_misc
					Select  --TOP 1
					-- NEWID() AS Id,
					@productTag + '-' + 'ZASSCSUBFORMAT' AS Tag, 
					'DPIDXBIZASSCSUBFORMAT' AS 'Key', 
					'ZASSCSUBFORMAT' AS AlternateKey, 
					s.externalcode as Value 
					FROM associatedtitles a 
					JOIN booksubjectcategory bsc 
					ON a.associatetitlebookkey = bsc.bookkey
					JOIN subgentables s 
					ON bsc.categorytableid = s.tableid and bsc.categorycode = s.datacode and bsc.categorysubcode = s.datasubcode 
					join gentables g 
					on s.tableid = g.tableid and s.datacode = g.datacode 
					where a.bookkey = @bookkey 
					and a.associationtypecode = 6 -- titles in sets
					and a.associationtypesubcode = 1 -- set component
					and a.sortorder = 1 -- first component is considered primary
					and s.tableid = 414 
					and g.deletestatus = 'N' 
					and s.deletestatus = 'N'
					and ISNULL(s.externalcode, '') <> ''
					
					--ORDER BY a.sortorder




				END

			-- 09/11/17
			-- EDI Catalog / Send to ONIX  will derived from HBG Only Flag in TM
			-- If this flag is checked, it is an HBG only title so we will feed 'N' O/w Y

			If exists (Select 1 from bookmisc where bookkey = @bookkey and misckey = 272 and longvalue = 1)
				BEGIN
					Insert into @generic_misc
					Select  --TOP 1
					-- NEWID() AS Id,
					@productTag + '-' + 'ZSENDTOONIX' AS Tag, 
					'DPIDXBIZSENDTOONIX' AS 'Key', 
					'ZSENDTOONIX' AS AlternateKey, 
					'N' as Value 
				END
			ELSE
				BEGIN
					Insert into @generic_misc
					Select  --TOP 1
					-- NEWID() AS Id,
					@productTag + '-' + 'ZSENDTOONIX' AS Tag, 
					'DPIDXBIZSENDTOONIX' AS 'Key', 
					'ZSENDTOONIX' AS AlternateKey, 
					'Y' as Value 
				END



				


	 RETURN
END
GO
GRANT SELECT ON dbo.qcs_get_misc_generic TO PUBLIC


