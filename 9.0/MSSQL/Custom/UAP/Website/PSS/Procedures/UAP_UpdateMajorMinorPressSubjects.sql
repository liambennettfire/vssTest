if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Insert_Products_Authors]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UAP_UpdateMajorMinorPressSubjects]

CREATE procedure dbo.UAP_UpdateMajorMinorPressSubjects
AS
BEGIN
WITH uapMajorMinorPressSubjects(bookkey, categorytableid, categorycode, categorysubcode, sortorder, categorysub2code)
AS
(
Select  ci.bookkey, categorytableid, categorycode, categorysubcode, bsc.sortorder, categorysub2code
FROM uap..booksubjectcategory bsc
JOIN uap..isbn i
ON bsc.bookkey = i.bookkey
JOIN cdc..isbn ci
ON i.ean13 = ci.ean13
where bsc.categorytableid in (413,414)
and i.bookkey is NOT NULL
and ci.bookkey is NOT NULL
and ci.bookkey in (Select * FROM cdc..uap_bookkeys())
)

Select * INTO #temp FROM uapMajorMinorPressSubjects
--LEFT OUTER JOIN cdc..booksubjectcategory cbsc
--ON u.bookkey = cbsc.bookkey and u.categorytableid = cbsc.categorytableid and
--u.categorycode = cbsc.categorycode and u.categorysubcode = cbsc.categorysubcode
--and u.categorysub2code = cbsc.categorysub2code
--WHERE cdc.

DECLARE @bookkey int,
@categorytableid int,
@categorycode int,
@categorysubcode int,
@sortorder int,
@categorysub2code int,
@i_titlefetchstatus int

DECLARE c_majorminorPS INSENSITIVE CURSOR
	FOR
	Select * FROM #temp

	FOR READ ONLY
			
	OPEN c_majorminorPS 

	FETCH NEXT FROM c_majorminorPS 
		INTO @bookkey ,@categorytableid ,@categorycode ,@categorysubcode,@sortorder ,@categorysub2code 



	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
			IF (@i_titlefetchstatus <>-2) 
			begin
				
				DECLARE @sql nvarchar(4000)
				SET @sql = N'Select * FROM cdc..booksubjectcategory where bookkey = ' + Cast(@bookkey as nvarchar(20))
				IF @categorytableid IS NOT NULL 
					BEGIN
						SET @sql = @sql + N' and categorytableid =  ' + Cast(@categorytableid as nvarchar(20))
					END
				ELSE
					BEGIN
						SET @sql = @sql + N' and categorytableid IS NULL'
					END
				IF @categorycode IS NOT NULL 
					BEGIN
						SET @sql = @sql + N' and categorycode = ' + Cast(@categorycode as nvarchar(20))
					END
				ELSE
					BEGIN
						SET @sql = @sql + N' and categorycode IS NULL'
					END

				IF @categorysubcode IS NOT NULL 
					BEGIN
						SET @sql = @sql + N' and categorysubcode = ' + Cast(@categorysubcode as nvarchar(20))
					END
				ELSE
					BEGIN
						SET @sql = @sql + N' and categorysubcode IS NULL'
					END

				IF @categorysub2code IS NOT NULL 
					BEGIN
						SET @sql = @sql + N' and categorysub2code = ' + Cast(@categorysub2code as nvarchar(20))
					END
				ELSE
					BEGIN
						SET @sql = @sql + N' and categorysub2code IS NULL'
					END


				--IF NOT EXISTS(Select * FROM cdc..booksubjectcategory where bookkey = @bookkey and categorytableid = @categorytableid and categorycode = @categorycode and @categorysubcode = @categorysubcode and categorysub2code = @categorysub2code)
				EXEC sp_executesql @sql
				IF @@ROWCOUNT = 0
					BEGIN

						DECLARE @key int
						EXEC cdc.dbo.get_next_key 'qsiadmin', @key OUTPUT
						Insert into cdc..booksubjectcategory
						VALUES(@bookkey, @key,@categorytableid ,@categorycode ,@categorysubcode,@sortorder,'qsiadmin', getdate(), @categorysub2code)
						Print 'Inserting press subject bookkey = ' + Cast(@bookkey as varchar(20)) + ' categorytableid= ' + Cast(@categorytableid as varchar(20)) + ' categorycode= ' + Cast(@categorycode as varchar(20)) + ' categorysubcode = ' + Cast(@categorysubcode as varchar(20)) + ' categorysub2code = ' + Cast(@categorysub2code as varchar(20))

					END
			end
			FETCH NEXT FROM c_majorminorPS
				INTO @bookkey ,@categorytableid ,@categorycode ,@categorysubcode,@sortorder ,@categorysub2code 
					select  @i_titlefetchstatus  = @@FETCH_STATUS
		end
			

close c_majorminorPS
deallocate c_majorminorPS

DROP TABLE #temp

--NOW DELETE ORPHANT RECORDS FROM CDC

DECLARE @cdcbookkey int,
@bookkey1 int,
@categorytableid1 int,
@categorycode1 int,
@categorysubcode1 int,
@sortorder1 int,
@categorysub2code1 int,
@i_titlefetchstatus1 int

DECLARE c_majorminorPSCDC INSENSITIVE CURSOR
	FOR
	Select  i.bookkey, ci.bookkey, categorytableid, categorycode, categorysubcode, bsc.sortorder, categorysub2code
	FROM cdc..booksubjectcategory bsc
	JOIN cdc..isbn i
	ON bsc.bookkey = i.bookkey
	JOIN uap..isbn ci
	ON i.ean13 = ci.ean13
	where bsc.categorytableid in (413,414)
	and i.bookkey is NOT NULL
	and ci.bookkey is NOT NULL
	and i.bookkey in (Select * FROM cdc..uap_bookkeys())

	FOR READ ONLY
			
	OPEN c_majorminorPSCDC 

	FETCH NEXT FROM c_majorminorPSCDC 
		INTO @cdcbookkey, @bookkey1 ,@categorytableid1 ,@categorycode1 ,@categorysubcode1,@sortorder1 ,@categorysub2code1



	select  @i_titlefetchstatus1  = @@FETCH_STATUS

	 while (@i_titlefetchstatus1 >-1 )
		begin
			IF (@i_titlefetchstatus1 <>-2) 
			begin
				
				DECLARE @sql_select nvarchar(4000)
				DECLARE @sql1 as nvarchar(4000)
				SET @sql_select = N'Select * FROM uap..booksubjectcategory where bookkey = ' + Cast(@bookkey1 as nvarchar(20))
				SET @sql1 = N'Delete FROM cdc..booksubjectcategory where bookkey = ' + Cast(@cdcbookkey as nvarchar(20))
				IF @categorytableid1 IS NOT NULL 
					BEGIN
						SET @sql_select = @sql_select + N' and categorytableid =  ' + Cast(@categorytableid1 as nvarchar(20))
						SET @sql1 = @sql1 + N' and categorytableid =  ' + Cast(@categorytableid1 as nvarchar(20))
					END
				ELSE
					BEGIN
						SET @sql_select = @sql_select + N' and categorytableid IS NULL'
						SET @sql1 = @sql1 + N' and categorytableid IS NULL'
					END
				IF @categorycode1 IS NOT NULL 
					BEGIN
						SET @sql_select = @sql_select + N' and categorycode = ' + Cast(@categorycode1 as nvarchar(20))
						SET @sql1 = @sql1 + N' and categorycode = ' + Cast(@categorycode1 as nvarchar(20))
					END
				ELSE
					BEGIN
						SET @sql_select = @sql_select + N' and categorycode IS NULL'
						SET @sql1 = @sql1 + N' and categorycode IS NULL'

					END

				IF @categorysubcode1 IS NOT NULL 
					BEGIN
						SET @sql_select = @sql_select + N' and categorysubcode = ' + Cast(@categorysubcode1 as nvarchar(20))
						SET @sql1 = @sql1 + N' and categorysubcode = ' + Cast(@categorysubcode1 as nvarchar(20))
					END
				ELSE

					BEGIN
						SET @sql_select = @sql_select + N' and categorysubcode IS NULL'
						SET @sql1 = @sql1 + N' and categorysubcode IS NULL'
					END

				IF @categorysub2code1 IS NOT NULL 
					BEGIN
						SET @sql_select = @sql_select + N' and categorysub2code = ' + Cast(@categorysub2code1 as nvarchar(20))
						SET @sql1 = @sql1 + N' and categorysub2code = ' + Cast(@categorysub2code1 as nvarchar(20))
					END
				ELSE
					BEGIN
						SET @sql_select = @sql_select + N' and categorysub2code IS NULL'
						SET @sql1 = @sql1 + N' and categorysub2code IS NULL'
					END


				--IF NOT EXISTS(Select * FROM cdc..booksubjectcategory where bookkey = @bookkey and categorytableid = @categorytableid and categorycode = @categorycode and @categorysubcode = @categorysubcode and categorysub2code = @categorysub2code)
				EXEC sp_executesql @sql_select
				IF @@ROWCOUNT = 0
					BEGIN
						EXEC sp_executesql @sql1
						Print 'Deleted press subject bookkey = ' + Cast(@cdcbookkey as varchar(20)) + ' categorytableid= ' + Cast(@categorytableid1 as varchar(20)) + ' categorycode= ' + Cast(@categorycode1 as varchar(20)) + ' categorysubcode = ' + Cast(@categorysubcode1 as varchar(20)) + ' categorysub2code = ' + Cast(@categorysub2code1 as varchar(20))
					END
			end
			FETCH NEXT FROM c_majorminorPSCDC
				INTO @cdcbookkey, @bookkey1 ,@categorytableid1 ,@categorycode1 ,@categorysubcode1,@sortorder1 ,@categorysub2code1
					select  @i_titlefetchstatus1  = @@FETCH_STATUS
		end
			

close c_majorminorPSCDC
deallocate c_majorminorPSCDC
END

GO
Grant execute on dbo.UAP_UpdateMajorMinorPressSubjects to Public
GO