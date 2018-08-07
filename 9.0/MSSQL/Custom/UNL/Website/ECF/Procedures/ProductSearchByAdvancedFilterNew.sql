if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ProductSearchByAdvancedFilterNew]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ProductSearchByAdvancedFilterNew]
GO
 
CREATE PROCEDURE [dbo].[ProductSearchByAdvancedFilterNew]
	@search nvarchar(500),
	@PriceLow money = NULL,
	@PriceHigh money = NULL,
	@MetaClassName nvarchar(100) = NULL, -- meta class
	@LanguageId int,
	@Page           Integer = 1, 
	@RecsPerPage    Integer = 10, 
	@TotalRecords Integer output,
	@CustomerId int,
	@AccessLevel int = 1,
	@ShowHidden bit = 0,
	@sort nvarchar(50) = N'Rank',
	@asc_order bit = 1,  -- new parameter
	@CategoryId int = 0,
	@IncSubDirProducts bit = 0,
	@Fields nvarchar(256) = N'*', -- meta fields within which the search will be performed or * - only by the enabled fulltext search (to search within all meta fields) 
	@filter nvarchar(1024) = N'', -- filter collection (metafield1|sign1|value1;metafield2|sign2|value2;...) 
	@sku_filter nvarchar(1024) = N'', -- sku filter collection (metafield1|sign1|value1;metafield2|sign2|value2;...) 
	@where_st nvarchar(1024) = N''
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Err int

	declare @product_type as int
	declare @pricefilter as nvarchar(250)

	-- Define price filter
	IF @PriceLow is NULL AND @PriceHigh is NULL
		SET @pricefilter = ''
	
	ELSE IF @PriceLow < 0 SET @PriceLow = 0
	ELSE IF @PriceHigh < 0 SET @PriceHigh = 0
		
	IF @PriceLow > 0 AND @PriceHigh > 0
		SET @pricefilter = '(S.Price BETWEEN ' + CAST(@PriceLow as nvarchar(50)) + ' and ' + CAST(@PriceHigh as nvarchar(50)) + ') AND '
	ELSE IF @PriceLow > 0
		SET @pricefilter = '(S.Price >= ' + CAST(@PriceLow as nvarchar(50)) + ') AND '
	ELSE IF @PriceHigh > 0
		SET @pricefilter = '(S.Price <= ' + CAST(@PriceHigh as nvarchar(50)) + ') AND '	
	ELSE
		SET @pricefilter = ''
		
	SET @product_type = 1
	-- Find out where we will start our records from
	DECLARE @RecCount int
	-- Find out the first and last record we want
	DECLARE @FirstRec int, @LastRec int
	SELECT @FirstRec = (@Page-1) * @RecsPerPage
	SELECT @LastRec = (@Page * @RecsPerPage + 1)
	-- Create a temp table to store the select results
	CREATE TABLE #PageIndex
	(
	    IndexId int IDENTITY (1, 1) NOT NULL,
	    ObjectId int,
	    Rank int
	)

	CREATE TABLE #PageIndexFiltered
	(
	    IndexId int IDENTITY (1, 1) NOT NULL,
	    ObjectId int,
	    Rank int,
		Price money
	)

	CREATE TABLE #PageIndexAdvanceFiltered
	(
	    IndexId int IDENTITY (1, 1) NOT NULL,
	    ObjectId int,
	    Rank int,
		Price money
	)

	CREATE TABLE #PageIndexSorted
	(
	    IndexId int IDENTITY (1, 1) NOT NULL,
	    ObjectId int
	)

	-- Define product system meta class ID
	DECLARE @ProductClassId int, @SkuClassId int, @MetaClassId int, @MetaClassLimit bit
	SELECT @ProductClassId = MetaClassId FROM MetaClass WHERE [Name]='Product'
	SELECT @SkuClassId = MetaClassId FROM MetaClass WHERE [Name]='Sku'

	SET @MetaClassId = -1
	IF(@MetaClassName IS NULL OR @MetaClassName=N'') BEGIN
		SET @MetaClassLimit = 0
		SET @MetaClassId = 0
	END	
	ELSE BEGIN
		SET @MetaClassLimit = 1
		SELECT @MetaClassId = MetaClassId FROM MetaClass WHERE [Name] = @MetaClassName AND ParentClassId = @ProductClassId
	END

	-- FieldLimit is used to determine whether to limit product search by specified meta fields
	DECLARE @FieldLimit bit
	SET @FieldLimit = 0

	IF NOT(@Fields IS NULL OR @Fields=N'' OR @Fields=N'*') --AND @MetaClassLimit = 1
		SET @FieldLimit = 1

	-- statement that holds category filter
	declare @stmtcategory nvarchar(500)
	IF @CategoryId=0 -- search within all categories
		SET @stmtCategory = N'1=1'
	ELSE BEGIN
		IF @CategoryId IS NULL
			SET @stmtCategory = N'C.CategoryId is NULL'
		ELSE BEGIN
			IF @IncSubDirProducts = 0
				SET @stmtCategory = N'C.CategoryId = ' + CAST(@CategoryId as nvarchar(20))
			ELSE  BEGIN
				SELECT @stmtCategory = Path FROM Category WHERE CategoryId = @CategoryId
				IF LEN(@stmtCategory) > 0
					SET @stmtCategory = N'Ct.Path LIKE ''' + @stmtCategory + '%'''
			END
		END
	END

	DECLARE @stmt nvarchar(4000), @stmt1 nvarchar(4000), @TableName nvarchar(255)
	IF NOT (@search IS NULL) and LEN(@search)>0 BEGIN

		-- 1. Cycle through all the available product meta classes
		DECLARE MetaClassCursor CURSOR READ_ONLY
		FOR SELECT TableName FROM MetaClass 
			WHERE (@MetaClassId = 0 OR MetaClassId = @MetaClassId) AND ParentClassId = @ProductClassId

		DECLARE @b int, @e int, @field nvarchar(255)			

		OPEN MetaClassCursor
		FETCH NEXT FROM MetaClassCursor INTO @TableName
		WHILE (@@fetch_status = 0)
		BEGIN 
			IF @FieldLimit = 0 BEGIN
				IF OBJECTPROPERTY(object_id(@TableName), 'TableHasActiveFulltextIndex') = 1
					exec ('INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT [Key], Rank FROM CONTAINSTABLE ([' + @TableName + N'], *, ''"*' + @search + N'*"'')')  
			END
			ELSE BEGIN
				-- Create statement to search within specified meta fields
				SET @e = 0
				WHILE @e < LEN(@Fields)
				BEGIN
					SET @b = @e + 1
					SET @e = CHARINDEX(',', @Fields, @b) 
					IF @e = 0 SET @e = LEN(@Fields) + 1 

					SET @field = LTRIM(RTRIM(SUBSTRING(@Fields, @b, @e - @b)))
					IF COLUMNPROPERTY (object_id(@TableName), @field, 'IsFulltextIndexed') = 1 BEGIN
						exec ('INSERT INTO #PageIndex (ObjectId, Rank)
							SELECT [Key], Rank FROM CONTAINSTABLE ([' + @TableName + N'], [' + @field + '], ''"*' + @search + N'*"'')') 
					END
					ELSE BEGIN
						IF dbo.ColumnAlreadyExists(@TableName, @field) = 1
							exec ('INSERT INTO #PageIndex (ObjectId, Rank)
								SELECT ObjectId, 100 as Rank FROM [' + @TableName + N'] WHERE [' + @field + '] LIKE ''%' + @search + N'%''') 
					END
				END
			END	
		FETCH NEXT FROM MetaClassCursor INTO @TableName
		END
		CLOSE MetaClassCursor
		DEALLOCATE MetaClassCursor

		IF OBJECTPROPERTY(object_id('Product'), 'TableHasActiveFulltextIndex') = 1
			exec ('INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT [Key], Rank FROM CONTAINSTABLE ([Product], *, ''"*' + @search + N'*"'')')
		ELSE BEGIN
			SET @stmt = 'INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT P.ProductId, 100 Rank FROM Product P 
						WHERE (' + LTRIM(STR(@MetaClassId)) + ' = 0 OR P.MetaClassId = ' + LTRIM(STR(@MetaClassId)) + ')
							AND (
								(P.[Name] LIKE ''%'+@search+N'%'') or (P.[Code] LIKE ''%'+@search+N'%'')) '
			exec(@stmt)
		END	

		IF OBJECTPROPERTY(object_id('Sku'), 'TableHasActiveFulltextIndex') = 1
			exec ('INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT ProductId, KEY_TBL.Rank FROM Sku AS FT_TBL INNER JOIN
						CONTAINSTABLE([Sku], *, ''"*' + @search + N'*"'') AS KEY_TBL
						ON FT_TBL.SkuId = KEY_TBL.[KEY]')
		ELSE BEGIN
			SET @stmt = 'INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT P.ProductId, 100 Rank FROM Product P 
						LEFT OUTER JOIN SKU S ON S.ProductId = P.ProductId 
						WHERE (' + LTRIM(STR(@MetaClassId)) + ' = 0 OR P.MetaClassId = ' + LTRIM(STR(@MetaClassId)) + ')
							AND (
								(S.[Name] LIKE ''%'+@search+N'%'') or (S.[Code] LIKE ''%'+@search+N'%'') or (S.[Description] LIKE ''%'+@search+N'%'')) '
			exec(@stmt)	
		END
	END

	-- filter statement
	IF (@search IS NOT NULL) and LEN(@search) > 0 
		SET @stmt = 'INSERT INTO #PageIndexFiltered (ObjectId, Rank, Price)
			SELECT P.ProductId, MAX(Rank), MIN(S.[Price]) as SkuPrice FROM #PageIndex FT_TBL
			LEFT OUTER JOIN SKU S ON S.ProductId = FT_TBL.ObjectId
			INNER JOIN Product P ON P.ProductId = FT_TBL.ObjectId '
	ELSE
		SET @stmt = 'INSERT INTO #PageIndexFiltered (ObjectId, Rank, Price)
			SELECT P.ProductId, 100 as Rank, MIN(S.[Price]) as SkuPrice FROM Product P
			LEFT OUTER JOIN SKU S ON S.ProductId = P.ProductId '

	IF(LEN(@where_st) = 0)
		SET @where_st = '1=1'

	SET @stmt1 = '
			LEFT OUTER JOIN ObjectLanguage OL ON P.ProductId = OL.ObjectId and OL.ObjectTypeId = 1 
			LEFT OUTER JOIN Categorization C ON C.ObjectId = P.ProductId
			LEFT OUTER JOIN Category Ct ON C.CategoryId = Ct.CategoryId
			WHERE (' + @where_st + ') AND (' + LTRIM(STR(@MetaClassId)) + ' = 0 OR P.MetaClassId = ' + LTRIM(STR(@MetaClassId)) + ') 
					AND ' + @pricefilter
					+ N'(' + CAST(@LanguageId as nvarchar(20)) + N'= OL.LanguageId or OL.LanguageId is null or ' + CAST(@LanguageId as nvarchar(20)) + N' = 0) 
					AND (' + @stmtCategory + ') 
					AND ((P.Visible = 1 
							AND  [dbo].[IsObjectAccessGranted](P.ProductId,' + CAST(@product_type as nvarchar(20)) + ',' + CAST(@CustomerId as nvarchar(20)) + ',' + CAST(@AccessLevel as nvarchar(20)) + N') = 1
						 ) 
						OR ' + CAST(@ShowHidden as nvarchar(20)) + ' = 1
						)
			GROUP BY P.ProductId '
	exec (@stmt + @stmt1)

	CREATE TABLE #KeyValueCollection(
		[key] nvarchar(255) NOT NULL,
		[operator] nvarchar(255) NULL, 
		[value] nvarchar(255) NULL
	)

	-- advanced filter
	IF (@filter IS NOT NULL) and LEN(@filter) > 0 BEGIN
		DECLARE @MClassId int
		
		INSERT #KeyValueCollection SELECT [key], [operator], [value] FROM dbo.ParseFilterString(@filter)
		
		DECLARE @key nvarchar(255), @operator nvarchar(255), @value nvarchar(255), @wherest nvarchar(2048)
		DECLARE KeyValueCursor CURSOR
			FOR SELECT [key], [operator], [value] FROM #KeyValueCollection

		DECLARE MetaClassCursor CURSOR READ_ONLY
			FOR SELECT DISTINCT MC.MetaClassId, MC.TableName FROM #PageIndexFiltered PIF
				INNER JOIN Product P ON PIF.ObjectId = P.ProductId
				INNER JOIN MetaClass MC ON MC.MetaClassId = P.MetaClassId

		OPEN MetaClassCursor
		FETCH NEXT FROM MetaClassCursor INTO @MClassId, @TableName
		WHILE (@@fetch_status = 0) BEGIN
			SET @wherest = ''

			OPEN KeyValueCursor
			FETCH NEXT FROM KeyValueCursor INTO @key, @operator, @value
			WHILE (@@fetch_status = 0) BEGIN
				IF LEN(@key) > 0 AND LEN(@operator) > 0 AND LEN(@value) > 0 AND dbo.ColumnAlreadyExists(@TableName, @key) = 1 BEGIN
					IF LEN(@wherest) > 0 
						SET @wherest = @wherest + ' AND '
					SET @wherest = @wherest + '(MCT.[' + @key + '] ' + @operator + ' ' + @value + ')'
				END
				FETCH NEXT FROM KeyValueCursor INTO @key, @operator, @value	
			END
			CLOSE KeyValueCursor

			IF LEN(@wherest) > 0
			BEGIN
				SET @wherest = 'P.MetaClassId = '+LTRIM(STR(@MClassId)) + ' AND ('+@wherest+')'
				exec('INSERT INTO #PageIndexAdvanceFiltered (ObjectId, Rank, Price)
					SELECT PIF.ObjectId, Rank, Price FROM #PageIndexFiltered PIF
					LEFT JOIN Product P ON PIF.ObjectId = P.ProductId
					LEFT JOIN ['+@TableName+'] MCT ON MCT.ObjectId = PIF.ObjectId
					WHERE '+@wherest)
			END
			FETCH NEXT FROM MetaClassCursor INTO @MClassId, @TableName
		END
		CLOSE MetaClassCursor
		DEALLOCATE MetaClassCursor
		DEALLOCATE KeyValueCursor

		exec('DELETE #PageIndexFiltered WHERE ObjectId NOT IN (SELECT ObjectId FROM #PageIndexAdvanceFiltered)')
	END

	-- sku advanced filter
	IF (@sku_filter IS NOT NULL) and LEN(@sku_filter) > 0 BEGIN
		DECLARE @SkuMetaClassId int
		
		INSERT #KeyValueCollection SELECT [key], [operator], [value] FROM dbo.ParseFilterString(@sku_filter)

		DECLARE KeyValueCursor CURSOR
			FOR SELECT [key], [operator], [value] FROM #KeyValueCollection

		DECLARE MetaClassCursor CURSOR READ_ONLY
			FOR SELECT MetaClassId, TableName FROM MetaClass WHERE ParentClassId = @SkuClassId

		OPEN MetaClassCursor
		FETCH NEXT FROM MetaClassCursor INTO @SkuMetaClassId, @TableName
		WHILE (@@fetch_status = 0) BEGIN
			SET @wherest = ''

			OPEN KeyValueCursor
			FETCH NEXT FROM KeyValueCursor INTO @key, @operator, @value
			WHILE (@@fetch_status = 0) BEGIN
				IF LEN(@key) > 0 AND LEN(@operator) > 0 AND LEN(@value) > 0 AND dbo.ColumnAlreadyExists(@TableName, @key) = 1 BEGIN
					IF LEN(@wherest) > 0 
						SET @wherest = @wherest + ' AND '
					SET @wherest = @wherest + '(MCT.[' + @key + '] ' + @operator + ' ' + @value + ')'
				END
				FETCH NEXT FROM KeyValueCursor INTO @key, @operator, @value	
			END
			CLOSE KeyValueCursor

			IF LEN(@wherest) > 0
			BEGIN
				SET @wherest = 'S.MetaClassId = '+LTRIM(STR(@SkuMetaClassId)) + ' AND ('+@wherest+')'
				exec('INSERT INTO #PageIndexAdvanceFiltered (ObjectId, Rank, Price)
					SELECT S.ProductId, Rank, S.Price FROM #PageIndexFiltered PIF
					LEFT JOIN Sku S ON PIF.ObjectId = S.ProductId
					LEFT JOIN ['+@TableName+'] MCT ON MCT.ObjectId = S.SkuId
					WHERE '+@wherest)
			END
			FETCH NEXT FROM MetaClassCursor INTO @SkuMetaClassId, @TableName
		END
		CLOSE MetaClassCursor
		DEALLOCATE MetaClassCursor
		DEALLOCATE KeyValueCursor

		exec('DELETE #PageIndexFiltered WHERE ObjectId NOT IN (SELECT ObjectId FROM #PageIndexAdvanceFiltered)')
	END

	-- sort statement
	DECLARE @sortorder nvarchar(500)
	
	IF @asc_order = 0 SET @sortorder = ' DESC'
	ELSE SET @sortorder = N' ASC'	

	SET @stmt = N''
	IF (@sort IS NOT NULL) AND LEN(@sort) > 0 BEGIN

		IF (@sort LIKE 'Price') OR (@sort LIKE 'Rank')
			SET @stmt = 'INSERT INTO #PageIndexSorted (ObjectId)
				SELECT FT_TBL.ObjectId FROM #PageIndexFiltered FT_TBL
				ORDER BY FT_TBL.' + @sort + @sortorder
		ELSE IF dbo.ColumnAlreadyExists('Product', @sort) = 1
			SET @stmt = 'INSERT INTO #PageIndexSorted (ObjectId)
				SELECT FT_TBL.ObjectId FROM #PageIndexFiltered FT_TBL
				INNER JOIN Product P ON P.ProductId = FT_TBL.ObjectId
				ORDER BY P.' + @sort + @sortorder
		ELSE IF(@MetaClassLimit = 1) BEGIN
			SELECT @TableName = TableName FROM MetaClass WHERE ParentClassId = @ProductClassId AND [Name] = @MetaClassName
			IF dbo.ColumnAlreadyExists(@TableName, @sort) = 1 BEGIN
				SET @stmt = 'INSERT INTO #PageIndexSorted (ObjectId)
					SELECT FT_TBL.ObjectId FROM #PageIndexFiltered FT_TBL
					INNER JOIN ' + @TableName + ' MT ON MT.ObjectId = FT_TBL.ObjectId
					ORDER BY MT.' + @sort + @sortorder
			END		
	
		END
	END


	IF LEN(@stmt) = 0
		BEGIN
			If @sort = 'PubDate'
				Begin
					SET @stmt = 'INSERT INTO #PageIndexSorted (ObjectId)
						SELECT  ObjectId FROM #PageIndexFiltered pif
						JOIN dbo.qweb_ecf_ProductsBySortCriteria sc
						ON pif.ObjectID = sc.ProductId
						ORDER BY sc.PubYear DESC'
				End
			ELSE IF @sort = 'author_last'
				BEGIN
					SET @stmt = 'INSERT INTO #PageIndexSorted (ObjectId)
						SELECT  ObjectId FROM #PageIndexFiltered pif
						JOIN dbo.qweb_ecf_ProductsBySortCriteria sc
						ON pif.ObjectID = sc.ProductId
						ORDER BY sc.author_last'
				END
			ELSE
			SET @stmt = 'INSERT INTO #PageIndexSorted (ObjectId)
						SELECT ObjectId FROM #PageIndexFiltered ORDER BY ObjectId'

		END
	
	exec (@stmt)
	SET @TotalRecords = @@rowcount
	
	SELECT PR.*, OL.*, I.IndexId
	FROM #PageIndexSorted I INNER JOIN [Product] PR ON I.ObjectId = PR.ProductId 
	LEFT OUTER JOIN ObjectLanguage OL ON PR.ProductId = OL.ObjectId and OL.ObjectTypeId = @product_type
	WHERE /*(@LanguageId = OL.LanguageId or OL.LanguageId is null or @LanguageId = 0) and PR.Visible = 1 and */
	PR.ProductId in 
	(
		select ObjectId from #PageIndexSorted where IndexId > @FirstRec AND IndexId < @LastRec
	)
	ORDER BY I.IndexId

	DROP TABLE #PageIndex
	DROP TABLE #PageIndexFiltered
	DROP TABLE #PageIndexAdvanceFiltered
	DROP TABLE #PageIndexSorted
	
fin:
	SET @Err = @@Error
	RETURN @Err
END
 
GO
Grant execute on dbo.ProductSearchByAdvancedFilterNew to Public
go