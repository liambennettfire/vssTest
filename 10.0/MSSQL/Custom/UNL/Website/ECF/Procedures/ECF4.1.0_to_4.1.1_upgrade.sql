/********************************************************************
             ECF4.0_Release_upgrade.sql
    Mediachase ECF 4.0 Release 4.1.0 to Release 4.1.1 Upgrade Script
*********************************************************************/

----2007/10/22 ------------------------------------
DECLARE @Major int, @Minor int, @Patch int, @Installed DateTime

Set @Major = 4;
Set @Minor = 1;
Set @Patch = 9;

Select @Installed = InstallDate  from SchemaVersion where Major=@Major and Minor=@Minor and Patch=@Patch

If(@Installed is null)
BEGIN

--## Schema Patch ##
exec sp_ExecuteSQL N'CREATE NONCLUSTERED INDEX IX_CategoryCode ON dbo.Category (Code) ON [PRIMARY]'

IF dbo.ColumnAlreadyExists('Category', 'Path') = 0 BEGIN
exec sp_ExecuteSQL N'ALTER TABLE dbo.Category ADD Path varchar(255) NULL'
END

exec sp_ExecuteSQL N'CREATE PROCEDURE CategoryUpdatePath
	@Id int
AS
DECLARE @path varchar(255), @categoryId int, @parentCategoryId int
SET @categoryId = @Id
SET @path = ''.'' 
WHILE @categoryId > 0
BEGIN
	SET @parentCategoryId = @categoryId 
	SELECT @categoryId = ParentCategoryId FROM Category WHERE CategoryId = @parentCategoryId
	SET @path =  ''.'' + LTRIM(STR(@parentCategoryId)) + @path
END
UPDATE Category SET Path = @path WHERE CategoryId = @Id'

exec sp_ExecuteSQL N'CREATE TRIGGER CategoryUpdateTrigger ON [dbo].[Category] 
FOR INSERT, UPDATE
AS
IF UPDATE ( ParentCategoryId )
BEGIN 
	DECLARE @CategoryId int
	DECLARE category_cursor CURSOR LOCAL FOR SELECT CategoryId FROM inserted
	OPEN category_cursor
	FETCH NEXT FROM category_cursor INTO @CategoryId
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		EXEC CategoryUpdatePath @CategoryId 
		UPDATE Category SET ParentCategoryId = ParentCategoryId WHERE ParentCategoryId = @CategoryId
		if @@error!=0 goto errCategoryUpdate
		FETCH NEXT FROM category_cursor INTO @CategoryId
	END
	errCategoryUpdate:
	CLOSE category_cursor
	DEALLOCATE category_cursor
END'

exec sp_ExecuteSQL N'UPDATE Category SET ParentCategoryId = ParentCategoryId'

exec sp_ExecuteSQL N'ALTER PROCEDURE [dbo].[ProductSearchByAdvancedFilter]
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
	@sort nvarchar(50) = N''Rank'',
	@asc_order bit = 1,  -- new parameter
	@CategoryId int = 0,
	@IncSubDirProducts bit = 0,
	@Fields nvarchar(256) = N''*'', -- meta fields within which the search will be performed or * - only by the enabled fulltext search (to search within all meta fields) 
	@filter nvarchar(1024) = N'''', -- filter collection (metafield1|sign1|value1;metafield2|sign2|value2;...) 
	@where_st nvarchar(1024) = N''''
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Err int

	declare @product_type as int
	declare @pricefilter as nvarchar(250)

	-- Define price filter
	IF @PriceLow is NULL AND @PriceHigh is NULL
		SET @pricefilter = ''''
	
	ELSE IF @PriceLow < 0 SET @PriceLow = 0
	ELSE IF @PriceHigh < 0 SET @PriceHigh = 0
		
	IF @PriceLow > 0 AND @PriceHigh > 0
		SET @pricefilter = ''(S.Price BETWEEN '' + CAST(@PriceLow as nvarchar(50)) + '' and '' + CAST(@PriceHigh as nvarchar(50)) + '') AND ''
	ELSE IF @PriceLow > 0
		SET @pricefilter = ''(S.Price >= '' + CAST(@PriceLow as nvarchar(50)) + '') AND ''
	ELSE IF @PriceHigh > 0
		SET @pricefilter = ''(S.Price <= '' + CAST(@PriceHigh as nvarchar(50)) + '') AND ''	
	ELSE
		SET @pricefilter = ''''
		
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
	DECLARE @ProductClassId int, @MetaClassId int, @MetaClassLimit bit
	SELECT @ProductClassId = MetaClassId FROM MetaClass WHERE [Name]=''Product''

	SET @MetaClassId = -1
	IF(@MetaClassName IS NULL OR @MetaClassName=N'''') BEGIN
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

	IF NOT(@Fields IS NULL OR @Fields=N'''' OR @Fields=N''*'') --AND @MetaClassLimit = 1
		SET @FieldLimit = 1

	-- statement that holds category filter
	declare @stmtcategory nvarchar(500)
	IF @CategoryId=0 -- search within all categories
		SET @stmtCategory = N''1=1''
	ELSE BEGIN
		IF @CategoryId IS NULL
			SET @stmtCategory = N''C.CategoryId is NULL''
		ELSE BEGIN
			IF @IncSubDirProducts = 0
				SET @stmtCategory = N''C.CategoryId = '' + CAST(@CategoryId as nvarchar(20))
			ELSE  BEGIN
				SELECT @stmtCategory = Path FROM Category WHERE CategoryId = @CategoryId
				IF LEN(@stmtCategory) > 0
					SET @stmtCategory = N''Ct.Path LIKE '''''' + @stmtCategory + ''%''''''
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
				IF OBJECTPROPERTY(object_id(@TableName), ''TableHasActiveFulltextIndex'') = 1
					exec (''INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT [Key], Rank FROM CONTAINSTABLE (['' + @TableName + N''], *, ''''"*'' + @search + N''*"'''')'')  
			END
			ELSE BEGIN
				-- Create statement to search within specified meta fields
				SET @e = 0
				WHILE @e < LEN(@Fields)
				BEGIN
					SET @b = @e + 1
					SET @e = CHARINDEX('','', @Fields, @b) 
					IF @e = 0 SET @e = LEN(@Fields) + 1 

					SET @field = LTRIM(RTRIM(SUBSTRING(@Fields, @b, @e - @b)))
					IF COLUMNPROPERTY (object_id(@TableName), @field, ''IsFulltextIndexed'') = 1 BEGIN
						exec (''INSERT INTO #PageIndex (ObjectId, Rank)
							SELECT [Key], Rank FROM CONTAINSTABLE (['' + @TableName + N''], ['' + @field + ''], ''''"*'' + @search + N''*"'''')'') 
					END
					ELSE BEGIN
						IF dbo.ColumnAlreadyExists(@TableName, @field) = 1
							exec (''INSERT INTO #PageIndex (ObjectId, Rank)
								SELECT ObjectId, 100 as Rank FROM ['' + @TableName + N''] WHERE ['' + @field + ''] LIKE ''''%'' + @search + N''%'''''') 
					END
				END
			END	
		FETCH NEXT FROM MetaClassCursor INTO @TableName
		END
		CLOSE MetaClassCursor
		DEALLOCATE MetaClassCursor

		IF OBJECTPROPERTY(object_id(''Product''), ''TableHasActiveFulltextIndex'') = 1
			exec (''INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT [Key], Rank FROM CONTAINSTABLE ([Product], *, ''''"*'' + @search + N''*"'''')'')
		ELSE BEGIN
			SET @stmt = ''INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT P.ProductId, 100 Rank FROM Product P 
						WHERE ('' + LTRIM(STR(@MetaClassId)) + '' = 0 OR P.MetaClassId = '' + LTRIM(STR(@MetaClassId)) + '')
							AND (
								(P.[Name] LIKE ''''%''+@search+N''%'''') or (P.[Code] LIKE ''''%''+@search+N''%'''')) ''
			exec(@stmt)
		END	

		IF OBJECTPROPERTY(object_id(''Sku''), ''TableHasActiveFulltextIndex'') = 1
			exec (''INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT ProductId, KEY_TBL.Rank FROM Sku AS FT_TBL INNER JOIN
						CONTAINSTABLE([Sku], *, ''''"*'' + @search + N''*"'''') AS KEY_TBL
						ON FT_TBL.SkuId = KEY_TBL.[KEY]'')
		ELSE BEGIN
			SET @stmt = ''INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT P.ProductId, 100 Rank FROM Product P 
						LEFT OUTER JOIN SKU S ON S.ProductId = P.ProductId 
						WHERE ('' + LTRIM(STR(@MetaClassId)) + '' = 0 OR P.MetaClassId = '' + LTRIM(STR(@MetaClassId)) + '')
							AND (
								(S.[Name] LIKE ''''%''+@search+N''%'''') or (S.[Code] LIKE ''''%''+@search+N''%'''') or (S.[Description] LIKE ''''%''+@search+N''%'''')) ''
			exec(@stmt)	
		END
	END

	-- filter statement
	IF (@search IS NOT NULL) and LEN(@search) > 0 
		SET @stmt = ''INSERT INTO #PageIndexFiltered (ObjectId, Rank, Price)
			SELECT P.ProductId, MAX(Rank), MIN(S.[Price]) as SkuPrice FROM #PageIndex FT_TBL
			LEFT OUTER JOIN SKU S ON S.ProductId = FT_TBL.ObjectId
			INNER JOIN Product P ON P.ProductId = FT_TBL.ObjectId ''
	ELSE
		SET @stmt = ''INSERT INTO #PageIndexFiltered (ObjectId, Rank, Price)
			SELECT P.ProductId, 100 as Rank, MIN(S.[Price]) as SkuPrice FROM Product P
			LEFT OUTER JOIN SKU S ON S.ProductId = P.ProductId ''

	IF(LEN(@where_st) = 0)
		SET @where_st = ''1=1''

	SET @stmt1 = ''
			LEFT OUTER JOIN ObjectLanguage OL ON P.ProductId = OL.ObjectId and OL.ObjectTypeId = 1 
			LEFT OUTER JOIN Categorization C ON C.ObjectId = P.ProductId
			LEFT OUTER JOIN Category Ct ON C.CategoryId = Ct.CategoryId
			WHERE ('' + @where_st + '') AND ('' + LTRIM(STR(@MetaClassId)) + '' = 0 OR P.MetaClassId = '' + LTRIM(STR(@MetaClassId)) + '') 
					AND '' + @pricefilter
					+ N''('' + CAST(@LanguageId as nvarchar(20)) + N''= OL.LanguageId or OL.LanguageId is null or '' + CAST(@LanguageId as nvarchar(20)) + N'' = 0) 
					AND ('' + @stmtCategory + '') 
					AND ((P.Visible = 1 
							AND  [dbo].[IsObjectAccessGranted](P.ProductId,'' + CAST(@product_type as nvarchar(20)) + '','' + CAST(@CustomerId as nvarchar(20)) + '','' + CAST(@AccessLevel as nvarchar(20)) + N'') = 1
						 ) 
						OR '' + CAST(@ShowHidden as nvarchar(20)) + '' = 1
						)
			GROUP BY P.ProductId ''
	exec (@stmt + @stmt1)

	-- advanced filter
	IF (@filter IS NOT NULL) and LEN(@filter) > 0 BEGIN
		DECLARE @MClassId int

		CREATE TABLE #KeyValueCollection(
			[key] nvarchar(255) NOT NULL,
			[operator] nvarchar(255) NULL, 
			[value] nvarchar(255) NULL
		)
		
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
			SET @wherest = ''''

			OPEN KeyValueCursor
			FETCH NEXT FROM KeyValueCursor INTO @key, @operator, @value
			WHILE (@@fetch_status = 0) BEGIN
				IF LEN(@key) > 0 AND LEN(@operator) > 0 AND LEN(@value) > 0 AND dbo.ColumnAlreadyExists(@TableName, @key) = 1 BEGIN
					IF LEN(@wherest) > 0 
						SET @wherest = @wherest + '' AND ''
					SET @wherest = @wherest + ''(MCT.['' + @key + ''] '' + @operator + '' '' + @value + '')''
				END
				FETCH NEXT FROM KeyValueCursor INTO @key, @operator, @value	
			END
			CLOSE KeyValueCursor

			IF LEN(@wherest) > 0
			BEGIN
				SET @wherest = ''P.MetaClassId = ''+LTRIM(STR(@MClassId)) + '' AND (''+@wherest+'')''
				exec(''INSERT INTO #PageIndexAdvanceFiltered (ObjectId, Rank, Price)
					SELECT PIF.ObjectId, Rank, Price FROM #PageIndexFiltered PIF
					LEFT JOIN Product P ON PIF.ObjectId = P.ProductId
					LEFT JOIN [''+@TableName+''] MCT ON MCT.ObjectId = PIF.ObjectId
					WHERE ''+@wherest)
			END
			FETCH NEXT FROM MetaClassCursor INTO @MClassId, @TableName
		END
		CLOSE MetaClassCursor
		DEALLOCATE MetaClassCursor
		DEALLOCATE KeyValueCursor

		exec(''DELETE #PageIndexFiltered WHERE ObjectId NOT IN (SELECT ObjectId FROM #PageIndexAdvanceFiltered)'')
	END

	-- sort statement
	DECLARE @sortorder nvarchar(500)
	
	IF @asc_order = 0 SET @sortorder = '' DESC''
	ELSE SET @sortorder = N'' ASC''	

	SET @stmt = N''''
	IF (@sort IS NOT NULL) AND LEN(@sort) > 0 BEGIN

		IF (@sort LIKE ''Price'') OR (@sort LIKE ''Rank'')
			SET @stmt = ''INSERT INTO #PageIndexSorted (ObjectId)
				SELECT FT_TBL.ObjectId FROM #PageIndexFiltered FT_TBL
				ORDER BY FT_TBL.'' + @sort + @sortorder
		ELSE IF dbo.ColumnAlreadyExists(''Product'', @sort) = 1
			SET @stmt = ''INSERT INTO #PageIndexSorted (ObjectId)
				SELECT FT_TBL.ObjectId FROM #PageIndexFiltered FT_TBL
				INNER JOIN Product P ON P.ProductId = FT_TBL.ObjectId
				ORDER BY P.'' + @sort + @sortorder
		ELSE IF(@MetaClassLimit = 1) BEGIN
			SELECT @TableName = TableName FROM MetaClass WHERE ParentClassId = @ProductClassId AND [Name] = @MetaClassName
			IF dbo.ColumnAlreadyExists(@TableName, @sort) = 1 BEGIN
				SET @stmt = ''INSERT INTO #PageIndexSorted (ObjectId)
					SELECT FT_TBL.ObjectId FROM #PageIndexFiltered FT_TBL
					INNER JOIN '' + @TableName + '' MT ON MT.ObjectId = FT_TBL.ObjectId
					ORDER BY MT.'' + @sort + @sortorder
			END		
	
		END
	END

	IF LEN(@stmt) = 0
		SET @stmt = ''INSERT INTO #PageIndexSorted (ObjectId)
					SELECT ObjectId FROM #PageIndexFiltered ORDER BY ObjectId''
	
	exec (@stmt)
	SET @TotalRecords = @@rowcount
	
	SELECT DISTINCT PR.*, OL.*, I.IndexId
	FROM #PageIndexSorted I INNER JOIN [Product] PR ON I.ObjectId = PR.ProductId 
	LEFT OUTER JOIN ObjectLanguage OL ON PR.ProductId = OL.ObjectId and OL.ObjectTypeId = @product_type
	WHERE (@LanguageId = OL.LanguageId or OL.LanguageId is null or @LanguageId = 0) and PR.Visible = 1 and 
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
END'

--## END Schema Patch ##
Insert into SchemaVersion(Major, Minor, Patch, InstallDate) values (@Major, @Minor, @Patch, GetDate())

Print 'Schema Patch v' + Convert(Varchar(2),@Major) + '.' + Convert(Varchar(2),@Minor) + '.' +  Convert(Varchar(3),@Patch) + ' was applied successfully '

END
GO


----2007/10/22 ------------------------------------
DECLARE @Major int, @Minor int, @Patch int, @Installed DateTime

Set @Major = 4;
Set @Minor = 1;
Set @Patch = 10;

Select @Installed = InstallDate  from SchemaVersion where Major=@Major and Minor=@Minor and Patch=@Patch

If(@Installed is null)
BEGIN

--## Schema Patch ##

exec sp_ExecuteSQL N'ALTER PROCEDURE [dbo].[VersionLoadByCustomerProductKey]
(
	@CustomerId int,
	@CategoryId int,
	@ObjectId int,
	@ObjectType int
)
AS
CREATE TABLE #temp (
	[ProductId] [int] NULL,
	[DownloadId] [int]  NULL,
	[Name] [nvarchar] (100) NOT NULL ,
	[VersionId] [int] NOT NULL ,
	[Version] [nvarchar] (10) NOT NULL
)
INSERT #temp exec dbo.VersionLoadByCustomerProduct @CustomerId, @CategoryId, @ObjectId, @ObjectType
-- now filter out older version, they will have same downloadid''s
SELECT * from #temp T
	WHERE T.VersionId = (SELECT TOP 1 VersionId FROM #temp TT WHERE T.DownloadId = TT.DownloadId)
DROP TABLE #temp'

exec sp_ExecuteSQL N'ALTER PROCEDURE [dbo].[VersionLoadByCustomerProduct]
(
	@CustomerId int,
	@CategoryId int = 0,
	@ObjectId int = 0,
	@ObjectType int = 1
)
AS

DECLARE @product_type as int
SET @product_type = 1
DECLARE @sku_type as int
SET @sku_type = 2
DECLARE @download_type as int
SET @download_type = 5

DECLARE @AccessLevel int
SET @AccessLevel = 1

DECLARE @OneTime int 
SET @OneTime = 1
DECLARE @YearSubscription int
SET @YearSubscription = 2
DECLARE @MonthSubscription int
SET @MonthSubscription = 3 

IF @ObjectId > 0 BEGIN
	SELECT TBL.* FROM 
	(
	-- select all downloads that belong to the product|sku and have a type ''none''|''trial''
	SELECT DISTINCT P.ProductId, D.DownloadId, D.[Name], V.VersionId, V.Version
			FROM Product P, Sku S, Version V 
				INNER JOIN Download D ON V.DownloadId = D.DownloadId 
				INNER JOIN Policy P1 ON P1.PolicyId = D.PolicyId 
				LEFT OUTER JOIN ObjectDownload OD ON D.DownloadId = OD.DownloadId 
			WHERE 
			(P1.SystemKeyword = ''none'' or P1.SystemKeyword = ''trial'') and
			S.Visible = 1 and P.Visible=1 
			and (OD.ObjectId = @ObjectId and OD.ObjectTypeId = @ObjectType)
			and P.ProductId = S.ProductId
	UNION
		-- 3. select ''release''|''beta'' downloads that belong to the product|sku
		SELECT ProductId, D.DownloadId, D.[Name], V.VersionId, V.Version
			FROM OrderSku OS, Sku S, [Order] O, Version V 
				INNER JOIN Download D ON V.DownloadId = D.DownloadId 
				INNER JOIN Policy P ON P.PolicyId = D.PolicyId 
				LEFT OUTER JOIN ObjectDownload OD ON D.DownloadId = OD.DownloadId 
			WHERE
				(P.SystemKeyword = ''release'' OR P.SystemKeyword = ''beta'') and
				O.Processed = 1 and 
				O.CustomerId = @CustomerId and 
				S.Visible = 1
				and (OD.ObjectId = @ObjectId and OD.ObjectTypeId = @ObjectType)
				and OS.SkuId = S.SkuId
				and OS.OrderId = O.OrderId
				and
				(
					EXISTS(SELECT null FROM DownloadPolicy DP1 INNER JOIN 
						PolicyVariable PV ON PV.VariableId = DP1.VariableId
						WHERE DP1.DownloadId = D.DownloadId
							AND
							(
								([Name] = ''SubscriptionPeriod'' AND V.Created <= DATEADD(month, CAST(ISNULL(DP1.Value, PV.DefaultValue) AS int), O.ExpirationDate) AND S.SkuType = @YearSubscription)
								OR				
								([Name] = ''UpgradesPeriod'' AND V.Created <= DATEADD(month, CAST(ISNULL(DP1.Value, PV.DefaultValue) AS int), O.ExpirationDate))
			
							))
					AND
					EXISTS(SELECT null FROM DownloadPolicy DP1 INNER JOIN 
						PolicyVariable PV ON PV.VariableId = DP1.VariableId
						WHERE DP1.DownloadId = D.DownloadId
							AND ([Name] = ''DownloadDelay'' AND getdate() >= DATEADD(minute, CAST(ISNULL(DP1.Value, PV.DefaultValue) AS int), O.Completed)))
					AND
					EXISTS(SELECT null FROM DownloadPolicy DP1 INNER JOIN 
						PolicyVariable PV ON PV.VariableId = DP1.VariableId
						WHERE DP1.DownloadId = D.DownloadId
							AND ([Name] = ''RelationOrderStatus'' AND (O.OrderStatusId = CAST(ISNULL(DP1.Value, PV.DefaultValue) AS int) OR CAST(ISNULL(DP1.Value, PV.DefaultValue) AS int) = 0)))
				)
		) TBL
		WHERE
			(
				(ProductId = 0 AND [dbo].[IsObjectAccessGranted](DownloadId, @download_type, @CustomerId, @AccessLevel) = 1)
				OR
				(ProductId > 0 AND [dbo].[IsObjectAccessGranted](ProductId, @product_type, @CustomerId, @AccessLevel) = 1)
			)
		ORDER BY ProductId, DownloadId, Version DESC
END ELSE
---- do not filter by ObjectId --------------------------------------------------------------------------------------
BEGIN -- select all available downloads for customer ans category
		SELECT TBL.* FROM 
		(
		-- 1. select all downloads that don''t belong to a product and have a type ''none''|''trial''
		SELECT DISTINCT 0 ''ProductId'', D.DownloadId, D.[Name], V.VersionId, V.Version
			FROM Version V
				INNER JOIN Download D ON V.DownloadId = D.DownloadId 
				INNER JOIN Policy P1 ON P1.PolicyId = D.PolicyId
				LEFT OUTER JOIN ObjectDownload OD ON D.DownloadId = OD.DownloadId 
			WHERE 
			(OD.ObjectTypeId IS NULL) AND
			(@CustomerId > 0 OR (@CustomerId = 0 and (P1.SystemKeyword = ''none'' or P1.SystemKeyword = ''trial''))) 
		UNION
		-- 2. select all downloads that belong to a product and have a type ''none''|''trial''
		SELECT DISTINCT P.ProductId, D.DownloadId, D.[Name], V.VersionId, V.Version
			FROM Product P, Sku S, Version V 
				INNER JOIN Download D ON V.DownloadId = D.DownloadId 
				INNER JOIN Policy P1 ON P1.PolicyId = D.PolicyId 
				LEFT OUTER JOIN ObjectDownload OD ON D.DownloadId = OD.DownloadId 
			WHERE 
			(P1.SystemKeyword = ''none'' or P1.SystemKeyword = ''trial'') and
			S.Visible = 1
			and ((OD.ObjectId = S.SkuId and OD.ObjectTypeId = @sku_type) OR (OD.ObjectId = P.ProductId and OD.ObjectTypeId = @product_type))
			and P.ProductId = S.ProductId
		UNION
		-- 3. select ''release''|''beta'' downloads that belong to a product
		SELECT ProductId, D.DownloadId, D.[Name], V.VersionId, V.Version
			FROM OrderSku OS,  Sku S, [Order] O, Version V 
				INNER JOIN Download D ON V.DownloadId = D.DownloadId 
				INNER JOIN Policy P ON P.PolicyId = D.PolicyId 
				LEFT OUTER JOIN ObjectDownload OD ON D.DownloadId = OD.DownloadId 
			WHERE
				(P.SystemKeyword = ''release'' OR P.SystemKeyword = ''beta'') and
				O.Processed = 1 and 
				O.CustomerId = @CustomerId and 
				S.Visible = 1
				and ((OD.ObjectId = OS.SkuId and OD.ObjectTypeId = 2) OR (OD.ObjectId = S.ProductId and OD.ObjectTypeId = 1))
				and OS.SkuId = S.SkuId
				and OS.OrderId = O.OrderId
				and
				(
					EXISTS(SELECT null FROM DownloadPolicy DP1 INNER JOIN 
						PolicyVariable PV ON PV.VariableId = DP1.VariableId
						WHERE DP1.DownloadId = D.DownloadId
							AND
							(
								([Name] = ''SubscriptionPeriod'' AND V.Created <= DATEADD(month, CAST(ISNULL(DP1.Value, PV.DefaultValue) AS int), O.ExpirationDate) AND S.SkuType = @YearSubscription)
								OR				
								([Name] = ''UpgradesPeriod'' AND V.Created <= DATEADD(month, CAST(ISNULL(DP1.Value, PV.DefaultValue) AS int), O.ExpirationDate))
			
							))
					AND
					EXISTS(SELECT null FROM DownloadPolicy DP1 INNER JOIN 
						PolicyVariable PV ON PV.VariableId = DP1.VariableId
						WHERE DP1.DownloadId = D.DownloadId
							AND ([Name] = ''DownloadDelay'' AND getdate() >= DATEADD(minute, CAST(ISNULL(DP1.Value, PV.DefaultValue) AS int), O.Completed)))
					AND
					EXISTS(SELECT null FROM DownloadPolicy DP1 INNER JOIN 
						PolicyVariable PV ON PV.VariableId = DP1.VariableId
						WHERE DP1.DownloadId = D.DownloadId
							AND ([Name] = ''RelationOrderStatus'' AND (O.OrderStatusId = CAST(ISNULL(DP1.Value, PV.DefaultValue) AS int) OR CAST(ISNULL(DP1.Value, PV.DefaultValue) AS int) = 0)))
				) 
		) TBL 
		LEFT OUTER JOIN Categorization C ON C.ObjectId = DownloadId and C.ObjectTypeId = @download_type
		WHERE
			(	
				@CategoryId = 0
				OR
				(@CategoryId > 0 AND C.CategoryId = @CategoryId)
			)
			AND
			(
				(ProductId = 0 AND [dbo].[IsObjectAccessGranted](DownloadId, @download_type, @CustomerId, @AccessLevel) = 1)
				OR
				(ProductId > 0 AND [dbo].[IsObjectAccessGranted](ProductId, @product_type, @CustomerId, @AccessLevel) = 1)
			)
		ORDER BY ProductId, DownloadId, Version DESC
END'

--## END Schema Patch ##
Insert into SchemaVersion(Major, Minor, Patch, InstallDate) values (@Major, @Minor, @Patch, GetDate())

Print 'Schema Patch v' + Convert(Varchar(2),@Major) + '.' + Convert(Varchar(2),@Minor) + '.' +  Convert(Varchar(3),@Patch) + ' was applied successfully '

END
GO

----2007/12/19 ------------------------------------
DECLARE @Major int, @Minor int, @Patch int, @Installed DateTime

Set @Major = 4;
Set @Minor = 1;
Set @Patch = 11;

Select @Installed = InstallDate  from SchemaVersion where Major=@Major and Minor=@Minor and Patch=@Patch

If(@Installed is null)
BEGIN

--## Schema Patch ##
/* update [SKU_OrderSku_FK1] constraint */
exec sp_ExecuteSQL N'ALTER TABLE [dbo].[OrderSku] DROP CONSTRAINT [SKU_OrderSku_FK1]'
exec sp_ExecuteSQL N'ALTER TABLE [dbo].[OrderSku]  WITH CHECK ADD  CONSTRAINT [SKU_OrderSku_FK1] FOREIGN KEY([SkuId]) 
	REFERENCES [dbo].[SKU] ([SkuId]) ON UPDATE CASCADE ON DELETE NO ACTION'
exec sp_ExecuteSQL N'ALTER TABLE [dbo].[OrderSku] CHECK CONSTRAINT [SKU_OrderSku_FK1]'

/* update [SKU_ShoppingCartItem_FK1] constraint */
exec sp_ExecuteSQL N'ALTER TABLE [dbo].[ShoppingCartItem] DROP CONSTRAINT [SKU_ShoppingCartItem_FK1]'
exec sp_ExecuteSQL N'ALTER TABLE [dbo].[ShoppingCartItem]  WITH CHECK ADD  CONSTRAINT [SKU_ShoppingCartItem_FK1] FOREIGN KEY([SkuId])
	REFERENCES [dbo].[SKU] ([SkuId]) ON UPDATE CASCADE ON DELETE NO ACTION'
exec sp_ExecuteSQL N'ALTER TABLE [dbo].[ShoppingCartItem] CHECK CONSTRAINT [SKU_ShoppingCartItem_FK1]'

/* update SP [CustomerAccountLoadByRoles] */
exec sp_ExecuteSQL N'IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[CustomerAccountLoadByRoles]'') AND type in (N''P'', N''PC''))
	DROP PROCEDURE [dbo].[CustomerAccountLoadByRoles]'

exec sp_ExecuteSQL N'CREATE PROCEDURE [dbo].[CustomerAccountLoadByRoles]
(
	@RoleIdList nvarchar(255)
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Err int
	
	declare @stmt nvarchar(1000)
	
	set @stmt = ''select distinct CA.* from customeraccount CA
		inner join CustomerRole CR ON CR.CustomerId = CA.CustomerId
		where CA.contact = 1 and CR.RoleId in ('' + @RoleIdList + '')''
	exec(@stmt)
	
	SET @Err = @@Error
	RETURN @Err
END'

--## END Schema Patch ##
Insert into SchemaVersion(Major, Minor, Patch, InstallDate) values (@Major, @Minor, @Patch, GetDate())

Print 'Schema Patch v' + Convert(Varchar(2),@Major) + '.' + Convert(Varchar(2),@Minor) + '.' +  Convert(Varchar(3),@Patch) + ' was applied successfully '

END
GO

----2007/12/21 ------------------------------------
DECLARE @Major int, @Minor int, @Patch int, @Installed DateTime

Set @Major = 4;
Set @Minor = 1;
Set @Patch = 12;

Select @Installed = InstallDate  from SchemaVersion where Major=@Major and Minor=@Minor and Patch=@Patch

If(@Installed is null)
BEGIN

--## Schema Patch ##
exec sp_ExecuteSQL N'ALTER TABLE [Product] ADD [SerializedData] image NULL 

DECLARE @ProductMetaClassId int, @MetaFieldId int
SELECT @ProductMetaClassId = MetaClassId FROM [MetaClass] WHERE [Name] = ''Product''

INSERT INTO [MetaField]
	([Name], [SystemMetaClassId], [FriendlyName], [Description], [DataTypeId], [Length], [AllowNulls], [SaveHistory], [MultiLanguageValue], [AllowSearch], [Tag], [Namespace])
	VALUES
	(''SerializedData'', @ProductMetaClassId, ''SerializedData'', NULL, 7, 16, 1, 0, 0, 0, NULL, ''Mediachase.MetaDataPlus.System.Product'');

SET @MetaFieldId = ident_current(''[MetaField]'')

INSERT INTO [MetaClassMetaFieldRelation] (MetaClassId, MetaFieldId)	VALUES (@ProductMetaClassId, @MetaFieldId)

INSERT INTO [MetaClassMetaFieldRelation] (MetaClassId, MetaFieldId)
	SELECT MetaClassId, @MetaFieldId  FROM [MetaClass] WHERE ParentClassId = @ProductMetaClassId'

exec sp_ExecuteSQL N'ALTER PROCEDURE [dbo].[ProductSearchByAdvancedFilter]
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
	@sort nvarchar(50) = N''Rank'',
	@asc_order bit = 1,  -- new parameter
	@CategoryId int = 0,
	@IncSubDirProducts bit = 0,
	@Fields nvarchar(256) = N''*'', -- meta fields within which the search will be performed or * - only by the enabled fulltext search (to search within all meta fields) 
	@filter nvarchar(1024) = N'''', -- filter collection (metafield1|sign1|value1;metafield2|sign2|value2;...) 
	@where_st nvarchar(1024) = N''''
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Err int

	declare @product_type as int
	declare @pricefilter as nvarchar(250)

	-- Define price filter
	IF @PriceLow is NULL AND @PriceHigh is NULL
		SET @pricefilter = ''''
	
	ELSE IF @PriceLow < 0 SET @PriceLow = 0
	ELSE IF @PriceHigh < 0 SET @PriceHigh = 0
		
	IF @PriceLow > 0 AND @PriceHigh > 0
		SET @pricefilter = ''(S.Price BETWEEN '' + CAST(@PriceLow as nvarchar(50)) + '' and '' + CAST(@PriceHigh as nvarchar(50)) + '') AND ''
	ELSE IF @PriceLow > 0
		SET @pricefilter = ''(S.Price >= '' + CAST(@PriceLow as nvarchar(50)) + '') AND ''
	ELSE IF @PriceHigh > 0
		SET @pricefilter = ''(S.Price <= '' + CAST(@PriceHigh as nvarchar(50)) + '') AND ''	
	ELSE
		SET @pricefilter = ''''
		
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
	DECLARE @ProductClassId int, @MetaClassId int, @MetaClassLimit bit
	SELECT @ProductClassId = MetaClassId FROM MetaClass WHERE [Name]=''Product''

	SET @MetaClassId = -1
	IF(@MetaClassName IS NULL OR @MetaClassName=N'''') BEGIN
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

	IF NOT(@Fields IS NULL OR @Fields=N'''' OR @Fields=N''*'') --AND @MetaClassLimit = 1
		SET @FieldLimit = 1

	-- statement that holds category filter
	declare @stmtcategory nvarchar(500)
	IF @CategoryId=0 -- search within all categories
		SET @stmtCategory = N''1=1''
	ELSE BEGIN
		IF @CategoryId IS NULL
			SET @stmtCategory = N''C.CategoryId is NULL''
		ELSE BEGIN
			IF @IncSubDirProducts = 0
				SET @stmtCategory = N''C.CategoryId = '' + CAST(@CategoryId as nvarchar(20))
			ELSE  BEGIN
				SELECT @stmtCategory = Path FROM Category WHERE CategoryId = @CategoryId
				IF LEN(@stmtCategory) > 0
					SET @stmtCategory = N''Ct.Path LIKE '''''' + @stmtCategory + ''%''''''
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
				IF OBJECTPROPERTY(object_id(@TableName), ''TableHasActiveFulltextIndex'') = 1
					exec (''INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT [Key], Rank FROM CONTAINSTABLE (['' + @TableName + N''], *, ''''"*'' + @search + N''*"'''')'')  
			END
			ELSE BEGIN
				-- Create statement to search within specified meta fields
				SET @e = 0
				WHILE @e < LEN(@Fields)
				BEGIN
					SET @b = @e + 1
					SET @e = CHARINDEX('','', @Fields, @b) 
					IF @e = 0 SET @e = LEN(@Fields) + 1 

					SET @field = LTRIM(RTRIM(SUBSTRING(@Fields, @b, @e - @b)))
					IF COLUMNPROPERTY (object_id(@TableName), @field, ''IsFulltextIndexed'') = 1 BEGIN
						exec (''INSERT INTO #PageIndex (ObjectId, Rank)
							SELECT [Key], Rank FROM CONTAINSTABLE (['' + @TableName + N''], ['' + @field + ''], ''''"*'' + @search + N''*"'''')'') 
					END
					ELSE BEGIN
						IF dbo.ColumnAlreadyExists(@TableName, @field) = 1
							exec (''INSERT INTO #PageIndex (ObjectId, Rank)
								SELECT ObjectId, 100 as Rank FROM ['' + @TableName + N''] WHERE ['' + @field + ''] LIKE ''''%'' + @search + N''%'''''') 
					END
				END
			END	
		FETCH NEXT FROM MetaClassCursor INTO @TableName
		END
		CLOSE MetaClassCursor
		DEALLOCATE MetaClassCursor

		IF OBJECTPROPERTY(object_id(''Product''), ''TableHasActiveFulltextIndex'') = 1
			exec (''INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT [Key], Rank FROM CONTAINSTABLE ([Product], *, ''''"*'' + @search + N''*"'''')'')
		ELSE BEGIN
			SET @stmt = ''INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT P.ProductId, 100 Rank FROM Product P 
						WHERE ('' + LTRIM(STR(@MetaClassId)) + '' = 0 OR P.MetaClassId = '' + LTRIM(STR(@MetaClassId)) + '')
							AND (
								(P.[Name] LIKE ''''%''+@search+N''%'''') or (P.[Code] LIKE ''''%''+@search+N''%'''')) ''
			exec(@stmt)
		END	

		IF OBJECTPROPERTY(object_id(''Sku''), ''TableHasActiveFulltextIndex'') = 1
			exec (''INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT ProductId, KEY_TBL.Rank FROM Sku AS FT_TBL INNER JOIN
						CONTAINSTABLE([Sku], *, ''''"*'' + @search + N''*"'''') AS KEY_TBL
						ON FT_TBL.SkuId = KEY_TBL.[KEY]'')
		ELSE BEGIN
			SET @stmt = ''INSERT INTO #PageIndex (ObjectId, Rank)
						SELECT P.ProductId, 100 Rank FROM Product P 
						LEFT OUTER JOIN SKU S ON S.ProductId = P.ProductId 
						WHERE ('' + LTRIM(STR(@MetaClassId)) + '' = 0 OR P.MetaClassId = '' + LTRIM(STR(@MetaClassId)) + '')
							AND (
								(S.[Name] LIKE ''''%''+@search+N''%'''') or (S.[Code] LIKE ''''%''+@search+N''%'''') or (S.[Description] LIKE ''''%''+@search+N''%'''')) ''
			exec(@stmt)	
		END
	END

	-- filter statement
	IF (@search IS NOT NULL) and LEN(@search) > 0 
		SET @stmt = ''INSERT INTO #PageIndexFiltered (ObjectId, Rank, Price)
			SELECT P.ProductId, MAX(Rank), MIN(S.[Price]) as SkuPrice FROM #PageIndex FT_TBL
			LEFT OUTER JOIN SKU S ON S.ProductId = FT_TBL.ObjectId
			INNER JOIN Product P ON P.ProductId = FT_TBL.ObjectId ''
	ELSE
		SET @stmt = ''INSERT INTO #PageIndexFiltered (ObjectId, Rank, Price)
			SELECT P.ProductId, 100 as Rank, MIN(S.[Price]) as SkuPrice FROM Product P
			LEFT OUTER JOIN SKU S ON S.ProductId = P.ProductId ''

	IF(LEN(@where_st) = 0)
		SET @where_st = ''1=1''

	SET @stmt1 = ''
			LEFT OUTER JOIN ObjectLanguage OL ON P.ProductId = OL.ObjectId and OL.ObjectTypeId = 1 
			LEFT OUTER JOIN Categorization C ON C.ObjectId = P.ProductId
			LEFT OUTER JOIN Category Ct ON C.CategoryId = Ct.CategoryId
			WHERE ('' + @where_st + '') AND ('' + LTRIM(STR(@MetaClassId)) + '' = 0 OR P.MetaClassId = '' + LTRIM(STR(@MetaClassId)) + '') 
					AND '' + @pricefilter
					+ N''('' + CAST(@LanguageId as nvarchar(20)) + N''= OL.LanguageId or OL.LanguageId is null or '' + CAST(@LanguageId as nvarchar(20)) + N'' = 0) 
					AND ('' + @stmtCategory + '') 
					AND ((P.Visible = 1 
							AND  [dbo].[IsObjectAccessGranted](P.ProductId,'' + CAST(@product_type as nvarchar(20)) + '','' + CAST(@CustomerId as nvarchar(20)) + '','' + CAST(@AccessLevel as nvarchar(20)) + N'') = 1
						 ) 
						OR '' + CAST(@ShowHidden as nvarchar(20)) + '' = 1
						)
			GROUP BY P.ProductId ''
	exec (@stmt + @stmt1)

	-- advanced filter
	IF (@filter IS NOT NULL) and LEN(@filter) > 0 BEGIN
		DECLARE @MClassId int

		CREATE TABLE #KeyValueCollection(
			[key] nvarchar(255) NOT NULL,
			[operator] nvarchar(255) NULL, 
			[value] nvarchar(255) NULL
		)
		
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
			SET @wherest = ''''

			OPEN KeyValueCursor
			FETCH NEXT FROM KeyValueCursor INTO @key, @operator, @value
			WHILE (@@fetch_status = 0) BEGIN
				IF LEN(@key) > 0 AND LEN(@operator) > 0 AND LEN(@value) > 0 AND dbo.ColumnAlreadyExists(@TableName, @key) = 1 BEGIN
					IF LEN(@wherest) > 0 
						SET @wherest = @wherest + '' AND ''
					SET @wherest = @wherest + ''(MCT.['' + @key + ''] '' + @operator + '' '' + @value + '')''
				END
				FETCH NEXT FROM KeyValueCursor INTO @key, @operator, @value	
			END
			CLOSE KeyValueCursor

			IF LEN(@wherest) > 0
			BEGIN
				SET @wherest = ''P.MetaClassId = ''+LTRIM(STR(@MClassId)) + '' AND (''+@wherest+'')''
				exec(''INSERT INTO #PageIndexAdvanceFiltered (ObjectId, Rank, Price)
					SELECT PIF.ObjectId, Rank, Price FROM #PageIndexFiltered PIF
					LEFT JOIN Product P ON PIF.ObjectId = P.ProductId
					LEFT JOIN [''+@TableName+''] MCT ON MCT.ObjectId = PIF.ObjectId
					WHERE ''+@wherest)
			END
			FETCH NEXT FROM MetaClassCursor INTO @MClassId, @TableName
		END
		CLOSE MetaClassCursor
		DEALLOCATE MetaClassCursor
		DEALLOCATE KeyValueCursor

		exec(''DELETE #PageIndexFiltered WHERE ObjectId NOT IN (SELECT ObjectId FROM #PageIndexAdvanceFiltered)'')
	END

	-- sort statement
	DECLARE @sortorder nvarchar(500)
	
	IF @asc_order = 0 SET @sortorder = '' DESC''
	ELSE SET @sortorder = N'' ASC''	

	SET @stmt = N''''
	IF (@sort IS NOT NULL) AND LEN(@sort) > 0 BEGIN

		IF (@sort LIKE ''Price'') OR (@sort LIKE ''Rank'')
			SET @stmt = ''INSERT INTO #PageIndexSorted (ObjectId)
				SELECT FT_TBL.ObjectId FROM #PageIndexFiltered FT_TBL
				ORDER BY FT_TBL.'' + @sort + @sortorder
		ELSE IF dbo.ColumnAlreadyExists(''Product'', @sort) = 1
			SET @stmt = ''INSERT INTO #PageIndexSorted (ObjectId)
				SELECT FT_TBL.ObjectId FROM #PageIndexFiltered FT_TBL
				INNER JOIN Product P ON P.ProductId = FT_TBL.ObjectId
				ORDER BY P.'' + @sort + @sortorder
		ELSE IF(@MetaClassLimit = 1) BEGIN
			SELECT @TableName = TableName FROM MetaClass WHERE ParentClassId = @ProductClassId AND [Name] = @MetaClassName
			IF dbo.ColumnAlreadyExists(@TableName, @sort) = 1 BEGIN
				SET @stmt = ''INSERT INTO #PageIndexSorted (ObjectId)
					SELECT FT_TBL.ObjectId FROM #PageIndexFiltered FT_TBL
					INNER JOIN '' + @TableName + '' MT ON MT.ObjectId = FT_TBL.ObjectId
					ORDER BY MT.'' + @sort + @sortorder
			END		
	
		END
	END

	IF LEN(@stmt) = 0
		SET @stmt = ''INSERT INTO #PageIndexSorted (ObjectId)
					SELECT ObjectId FROM #PageIndexFiltered ORDER BY ObjectId''
	
	exec (@stmt)
	SET @TotalRecords = @@rowcount
	
	SELECT PR.*, OL.*, I.IndexId
	FROM #PageIndexSorted I INNER JOIN [Product] PR ON I.ObjectId = PR.ProductId 
	LEFT OUTER JOIN ObjectLanguage OL ON PR.ProductId = OL.ObjectId and OL.ObjectTypeId = @product_type
	WHERE (@LanguageId = OL.LanguageId or OL.LanguageId is null or @LanguageId = 0) and PR.Visible = 1 and 
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
END'

--## END Schema Patch ##
Insert into SchemaVersion(Major, Minor, Patch, InstallDate) values (@Major, @Minor, @Patch, GetDate())

Print 'Schema Patch v' + Convert(Varchar(2),@Major) + '.' + Convert(Varchar(2),@Minor) + '.' +  Convert(Varchar(3),@Patch) + ' was applied successfully '

END
GO