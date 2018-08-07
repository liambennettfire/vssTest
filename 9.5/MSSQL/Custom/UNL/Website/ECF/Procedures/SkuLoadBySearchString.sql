USE [UNP_ECF]
GO
/****** Object:  StoredProcedure [dbo].[SkuLoadBySearchString]    Script Date: 02/11/2011 11:19:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SkuLoadBySearchString]
	@search nvarchar(500),
	@LanguageId int,
	@Page           Integer = 1, 
	@RecsPerPage    Integer = 10, 
	@TotalRecords Integer output
AS
BEGIN
	/*
	Searches by sku name, description, code, metadata (if fulltext search is active) as well as by product name
	*/

	SET NOCOUNT ON
	DECLARE @Err int
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
	declare @IsFulltextEnabled bit
	SELECT @IsFulltextEnabled = DatabaseProperty (DB_NAME(DB_ID()),  'IsFulltextEnabled' )
	IF @IsFulltextEnabled = 0
	begin
		insert into #PageIndex
		SELECT DISTINCT
			S.[SkuId], '100' Rank
		FROM [SKU] S
		INNER JOIN [Product] P ON P.ProductId=S.ProductId
		WHERE
		(
			(S.[Name] like '%'+@search+'%') or
			(S.[Code] like '%'+@search+'%') or
			(S.[Description] like '%'+@search+'%') or
			(P.[Name] like '%'+@search+'%')
		) 
		AND
		(S.Visible = 1) AND (P.Visible=1)
		set @TotalRecords = @@rowcount
	end
	else
	begin
		-- 1. Cycle through all the available sku meta classes

		-- 1a. Add sku meta classes that are in full-text catalog to #PageIndex table
		DECLARE MetaClassCursor CURSOR
		READ_ONLY
		FOR select TableName from MetaClass where ParentClassId=(select MetaClassId from MetaClass where [Name]='Sku') and OBJECTPROPERTY(object_id(TableName), 'TableHasActiveFulltextIndex')=1
		
		DECLARE @TableName nvarchar(255)
		DECLARE @TableFulltextCatalogId int -- used to store the id of the table in full-text catalog, id=0 if table is not in catalog
		OPEN MetaClassCursor
		set @TotalRecords = 0
		FETCH NEXT FROM MetaClassCursor INTO @TableName
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				EXEC('INSERT INTO #PageIndex SELECT ObjectId, ''100'' Rank FROM [' + @TableName + '] AS FT_TBL INNER JOIN Sku S ON S.SkuId = FT_TBL.ObjectId INNER JOIN [Product] P ON P.ProductId=S.ProductId
					WHERE (S.Visible = 1) and (P.Visible=1) 
						and ((S.[Name] like ''%'+@search+'%'') or
						(S.[Code] like ''%'+@search+'%'') or
						(S.[Description] like ''%'+@search+'%'') or 
						(P.[Name] like ''%'+@search+'%''))')
				SET @TotalRecords = @TotalRecords + @@rowcount
			END
			FETCH NEXT FROM MetaClassCursor INTO @TableName
		END
				
		CLOSE MetaClassCursor
		DEALLOCATE MetaClassCursor

		-- 1b. Add sku meta classes that are NOT in full-text catalog to #PageIndex table
		declare @stmt nvarchar(4000)
		DECLARE MetaClassCursor2 CURSOR
		READ_ONLY
		FOR select TableName from MetaClass where ParentClassId=(select MetaClassId from MetaClass where [Name]='Sku') and OBJECTPROPERTY(object_id(TableName), 'TableHasActiveFulltextIndex')=0
		
		OPEN MetaClassCursor2
		FETCH NEXT FROM MetaClassCursor2 INTO @TableName
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				exec ('INSERT INTO #PageIndex
					SELECT DISTINCT
					S.[SkuId], ''100'' Rank
					FROM [SKU] S 
					INNER JOIN [Product] p ON P.ProductId=S.ProductId
					WHERE (S.Visible = 1) and (P.Visible=1) and
					(

						(S.[Name] like ''%'+@search+N'%'') or
						(S.[Code] like ''%'+@search+N'%'') or
						(S.[Description] like ''%'+@search+N'%'') or
						(P.[Name] like ''%'+@search+N'%'')
					) 
					AND EXISTS(select null from ['+@TableName+N'] where ObjectId=S.SkuId)')
				set @TotalRecords = @TotalRecords + @@rowcount
			END
			FETCH NEXT FROM MetaClassCursor2 INTO @TableName
		END
		CLOSE MetaClassCursor2
		DEALLOCATE MetaClassCursor2
	end

-- 2. Return paged data back
	declare @sku_type as int
	set @sku_type= 2
	SELECT S.*, OL.*
	FROM [SKU] S INNER JOIN #PageIndex I ON I.ObjectId = S.SkuId LEFT OUTER JOIN ObjectLanguage OL ON S.SkuId = OL.ObjectId and OL.ObjectTypeId = @sku_type
	WHERE (@LanguageId = OL.LanguageId or OL.LanguageId is null or @LanguageId = 0) and S.Visible = 1 and 
	S.SkuId in 
	(
		select ObjectId from #PageIndex where IndexId > @FirstRec AND IndexId < @LastRec
	)

	SELECT * FROM #PageIndex
	DROP TABLE #PageIndex

	SET @Err = @@Error
	RETURN @Err
END
