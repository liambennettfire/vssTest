if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_publishprepubproduct') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_publishprepubproduct
GO

CREATE PROCEDURE dbo.WK_publishprepubproduct
AS
/*

Select * FROM bookmisc
WHERE misckey = 48

BELOW ARE THE REQUIRED FIELDS

-          Item Number ( ISBN )

-          Product Tracking ID ( SAC Code)

-          Product Search Type

-          Product Sub Type

-          Publication Status

-          Author

-          Publication Date

-          Title 


*/

BEGIN


/*

First we check for required fields. The logic will be slightly different for some 
of the fields. e.g. pub date, title status, product type are required 
for a title to qualify as a prepub title. If these fields are blank we will
report for a "possible" error. The logic might be easily updated after go-live
if WK would like to change it for some of the fields. 
Better to report and see how it works then not 
reporting at all. 


*/


--TRUNCATE ALL error messages before processing every night 
--UPDATE bookmisc
--SET textvalue = NULL 
--WHERE misckey = 48

DELETE FROM bookmisc
WHERE misckey = 48



--ITEMNUMBER

IF EXISTS (Select * FROM bookdetail bd where dbo.wk_isPrepub_Not_Published_to_Adv_Yet(bd.bookkey) = 'Y' and dbo.WK_get_itemnumber(bd.bookkey) = '')
	BEGIN
		DECLARE @bookkey_itemnumber int
		DECLARE @i_titlefetchstatus_itemnumber int


			DECLARE c_itemnumber INSENSITIVE CURSOR
					FOR
					Select bookkey FROM bookdetail bd 
					where dbo.wk_isPrepub_Not_Published_to_Adv_Yet(bd.bookkey) = 'Y' 
					and dbo.WK_get_itemnumber(bd.bookkey) = ''

					FOR READ ONLY
							
					OPEN c_itemnumber 

					FETCH NEXT FROM c_itemnumber 
						INTO @bookkey_itemnumber
						select  @i_titlefetchstatus_itemnumber  = @@FETCH_STATUS

								 while (@i_titlefetchstatus_itemnumber >-1 )
									begin
										IF (@i_titlefetchstatus_itemnumber <>-2) 
										begin
												If EXISTS (Select * FROM bookmisc where bookkey = @bookkey_itemnumber and misckey = 48)
													BEGIN
														UPDATE bookmisc
														SET textvalue = COALESCE(textvalue, '') + ', ITEMNUMBER' , lastmaintdate = getdate()
														WHERE bookkey = @bookkey_itemnumber and misckey = 48
													END
												ELSE
													BEGIN
														INSERT INTO bookmisc
														Select @bookkey_itemnumber, 48, NULL, NULL, 'MISSING: ITEMNUMBER', 'qsiadmin', getdate(), 0
													END

										end
										FETCH NEXT FROM c_itemnumber
											INTO @bookkey_itemnumber
												select  @i_titlefetchstatus_itemnumber  = @@FETCH_STATUS
									end
							

				close c_itemnumber
				deallocate c_itemnumber

	END



--Product Tracking ID

IF EXISTS (Select * FROM book b where dbo.wk_isPrepub_Not_Published_to_Adv_Yet(b.bookkey) = 'Y' and bookkey not in (Select bookkey FROM booksubjectcategory where categorytableid = 412 and (categorysub2code IS NOT NULL OR categorysub2code <> '')))
	BEGIN
		DECLARE @bookkey_SAC int
		DECLARE @i_titlefetchstatus_SAC int


			DECLARE c_SAC INSENSITIVE CURSOR
					FOR
					Select b.bookkey FROM book b 
					where dbo.wk_isPrepub_Not_Published_to_Adv_Yet(b.bookkey) = 'Y' and 
					b.bookkey not in (Select bookkey FROM booksubjectcategory where categorytableid = 412 and (categorysub2code IS NOT NULL OR categorysub2code <> ''))

					FOR READ ONLY
							
					OPEN c_SAC 

					FETCH NEXT FROM c_SAC 
						INTO @bookkey_SAC
						select  @i_titlefetchstatus_SAC  = @@FETCH_STATUS

								 while (@i_titlefetchstatus_SAC >-1 )
									begin
										IF (@i_titlefetchstatus_SAC <>-2) 
										begin
											--
											If EXISTS (Select * FROM bookmisc where bookkey = @bookkey_SAC and misckey = 48)
												BEGIN
													UPDATE bookmisc
													SET textvalue = COALESCE(textvalue, '') + ', SAC' , lastmaintdate = getdate()
													WHERE bookkey = @bookkey_SAC and misckey = 48
												END
											ELSE
												BEGIN
													INSERT INTO bookmisc
													Select @bookkey_SAC, 48, NULL, NULL, 'MISSING: SAC', 'qsiadmin', getdate(), 0
												END

										end
										FETCH NEXT FROM c_SAC
											INTO @bookkey_SAC
												select  @i_titlefetchstatus_SAC  = @@FETCH_STATUS
									end
							

				close c_SAC
				deallocate c_SAC

	END

--Product Search Type

IF EXISTS (
Select * FROM bookdetail bd where 
[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') IN ('ED', 'PR') 
AND [dbo].[rpt_get_best_pub_date](bd.bookkey, 1) <> '' 
AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) <= 14
AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) > 0
AND (dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) IS NULL 
OR dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) = '')
AND ([dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') IS NULL 
OR [dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') = '')
)

	BEGIN
		DECLARE @bookkey_producttype int
		DECLARE @i_titlefetchstatus_producttype int


			DECLARE c_producttype INSENSITIVE CURSOR
					FOR
					Select bookkey FROM bookdetail bd where 
					[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') IN ('ED', 'PR') 
					AND [dbo].[rpt_get_best_pub_date](bd.bookkey, 1) <> '' 
					AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) <= 14
					AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) > 0
					AND (dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) IS NULL 
					OR dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) = '')
					AND ([dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') IS NULL 
					OR [dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') = '')

					FOR READ ONLY
							
					OPEN c_producttype 

					FETCH NEXT FROM c_producttype 
						INTO @bookkey_producttype
						select  @i_titlefetchstatus_producttype  = @@FETCH_STATUS

								 while (@i_titlefetchstatus_producttype >-1 )
									begin
										IF (@i_titlefetchstatus_producttype <>-2) 
										begin
											--
											If EXISTS (Select * FROM bookmisc where bookkey = @bookkey_producttype and misckey = 48)
												BEGIN
													UPDATE bookmisc
													SET textvalue = COALESCE(textvalue, '') +', PRODUCT TYPE' , lastmaintdate = getdate()
													WHERE bookkey = @bookkey_producttype and misckey = 48
												END
											ELSE
												BEGIN
													INSERT INTO bookmisc
													Select @bookkey_producttype, 48, NULL, NULL, 'MISSING: PRODUCT TYPE', 'qsiadmin', getdate(), 0
												END

										end
										FETCH NEXT FROM c_producttype
											INTO @bookkey_producttype
												select  @i_titlefetchstatus_producttype  = @@FETCH_STATUS
									end
							

				close c_producttype
				deallocate c_producttype

	END



--Product Sub Type

IF EXISTS (Select * FROM bookdetail bd where [dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') IN ('ED', 'PR') 
AND [dbo].[rpt_get_best_pub_date](bd.bookkey, 1) <> '' 
AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) <= 14
AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) > 0
AND --either product type or sub type is missing
(
(dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) IS NULL 
OR dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) = '')
OR
(dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',2) IS NULL 
OR dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',2) = '')
)
AND ([dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') IS NULL 
OR [dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') = '')
)
	BEGIN
		DECLARE @bookkey_productsubtype int
		DECLARE @i_titlefetchstatus_productsubtype int


			DECLARE c_productsubtype INSENSITIVE CURSOR
					FOR
						Select bookkey FROM bookdetail bd where 
						[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') IN ('ED', 'PR') 
						AND [dbo].[rpt_get_best_pub_date](bd.bookkey, 1) <> '' 
						AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) <= 14
						AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) > 0
						AND --either product type or sub type is missing
						(
						(dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) IS NULL 
						OR dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) = '')
						OR
						(dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',2) IS NULL 
						OR dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',2) = '')
						)
						AND ([dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') IS NULL 
						OR [dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') = '')

					FOR READ ONLY
							
					OPEN c_productsubtype 

					FETCH NEXT FROM c_productsubtype 
						INTO @bookkey_productsubtype
						select  @i_titlefetchstatus_productsubtype  = @@FETCH_STATUS

								 while (@i_titlefetchstatus_productsubtype >-1 )
									begin
										IF (@i_titlefetchstatus_productsubtype <>-2) 
										begin
											--
											If EXISTS (Select * FROM bookmisc where bookkey = @bookkey_productsubtype and misckey = 48)
												BEGIN
													UPDATE bookmisc
													SET textvalue = COALESCE(textvalue, '') + ', PRODUCT SUB TYPE' , lastmaintdate = getdate()
													WHERE bookkey = @bookkey_productsubtype and misckey = 48
												END
											ELSE
												BEGIN
													INSERT INTO bookmisc
													Select @bookkey_productsubtype, 48, NULL, NULL, 'MISSING: SUB PRODUCT TYPE', 'qsiadmin', getdate(), 0
												END

										end
										FETCH NEXT FROM c_productsubtype
											INTO @bookkey_productsubtype
												select  @i_titlefetchstatus_productsubtype  = @@FETCH_STATUS
									end
							

				close c_productsubtype
				deallocate c_productsubtype

	END



--PUBLICATION STATUS

IF EXISTS (
Select * FROM bookdetail bd where 
(
[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') IS NULL OR 
[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') = ''
)
AND [dbo].[rpt_get_best_pub_date](bd.bookkey, 1) <> '' 
AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) <= 14
AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) > 0
AND (
[dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') IS NULL 
OR [dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') = '')
AND dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) NOT LIKE 'sub%'

)

	BEGIN
		DECLARE @bookkey_pubstatus int
		DECLARE @i_titlefetchstatus_pubstatus int


			DECLARE c_pubstatus INSENSITIVE CURSOR
					FOR
						Select bookkey FROM bookdetail bd where 
						(
						[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') IS NULL OR 
						[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') = ''
						)
						AND [dbo].[rpt_get_best_pub_date](bd.bookkey, 1) <> '' 
						AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) <= 14
						AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) > 0
						AND (
						[dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') IS NULL 
						OR [dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') = '')
						AND dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) NOT LIKE 'sub%'


					FOR READ ONLY
							
					OPEN c_pubstatus 

					FETCH NEXT FROM c_pubstatus 
						INTO @bookkey_pubstatus
						select  @i_titlefetchstatus_pubstatus  = @@FETCH_STATUS

								 while (@i_titlefetchstatus_pubstatus >-1 )
									begin
										IF (@i_titlefetchstatus_pubstatus <>-2) 
										begin
											--
											If EXISTS (Select * FROM bookmisc where bookkey = @bookkey_pubstatus and misckey = 48)
												BEGIN
													UPDATE bookmisc
													SET textvalue = COALESCE(textvalue, '') + ', TITLE STATUS' , lastmaintdate = getdate()
													WHERE bookkey = @bookkey_pubstatus and misckey = 48
												END
											ELSE
												BEGIN
													INSERT INTO bookmisc
													Select @bookkey_pubstatus, 48, NULL, NULL, 'MISSING: TITLE STATUS', 'qsiadmin', getdate(), 0
												END

										end
										FETCH NEXT FROM c_pubstatus
											INTO @bookkey_pubstatus
												select  @i_titlefetchstatus_pubstatus  = @@FETCH_STATUS
									end
							

				close c_pubstatus
				deallocate c_pubstatus

	END


--AUTHOR

IF EXISTS (Select * FROM bookdetail bd where dbo.wk_isPrepub_Not_Published_to_Adv_Yet(bd.bookkey) = 'Y' and NOT EXISTS(Select * FROM bookauthor ba where ba.bookkey = bd.bookkey))
	BEGIN
		DECLARE @bookkey_author int
		DECLARE @i_titlefetchstatus_author int


			DECLARE c_author INSENSITIVE CURSOR
					FOR
					Select bd.bookkey FROM bookdetail bd where dbo.wk_isPrepub_Not_Published_to_Adv_Yet(bd.bookkey) = 'Y' 
					and NOT EXISTS(Select * FROM bookauthor ba where ba.bookkey = bd.bookkey)

					FOR READ ONLY
							
					OPEN c_author 

					FETCH NEXT FROM c_author
						INTO @bookkey_author
						select  @i_titlefetchstatus_author  = @@FETCH_STATUS

								 while (@i_titlefetchstatus_author >-1 )
									begin
										IF (@i_titlefetchstatus_author <>-2) 
										begin
											--
											If EXISTS (Select * FROM bookmisc where bookkey = @bookkey_author and misckey = 48)
												BEGIN
													UPDATE bookmisc
													SET textvalue = COALESCE(textvalue, '') + ', AUTHOR' , lastmaintdate = getdate()
													WHERE bookkey = @bookkey_author and misckey = 48
												END
											ELSE
												BEGIN
													INSERT INTO bookmisc
													Select @bookkey_author, 48, NULL, NULL, 'MISSING: AUTHOR', 'qsiadmin', getdate(), 0
												END
										end
										FETCH NEXT FROM c_author
											INTO @bookkey_author
												select  @i_titlefetchstatus_author  = @@FETCH_STATUS
									end
							

				close c_author
				deallocate c_author

	END


--TITLE

IF EXISTS (Select * FROM bookdetail bd where dbo.wk_isPrepub_Not_Published_to_Adv_Yet(bd.bookkey) = 'Y' and (dbo.rpt_get_title(bd.bookkey, 'F') IS NULL OR dbo.rpt_get_title(bd.bookkey, 'F') = ''))
	BEGIN
		DECLARE @bookkey_title int
		DECLARE @i_titlefetchstatus_title int


			DECLARE c_title INSENSITIVE CURSOR
					FOR
					Select bookkey FROM bookdetail bd 
					where dbo.wk_isPrepub_Not_Published_to_Adv_Yet(bd.bookkey) = 'Y' and 
					((dbo.rpt_get_title(bd.bookkey, 'F') IS NULL OR dbo.rpt_get_title(bd.bookkey, 'F') = ''))

					FOR READ ONLY
							
					OPEN c_title 

					FETCH NEXT FROM c_title 
						INTO @bookkey_title
						select  @i_titlefetchstatus_title  = @@FETCH_STATUS

								 while (@i_titlefetchstatus_title >-1 )
									begin
										IF (@i_titlefetchstatus_title <>-2) 
										begin
											--
											If EXISTS (Select * FROM bookmisc where bookkey = @bookkey_title and misckey = 48)
												BEGIN
													UPDATE bookmisc
													SET textvalue = COALESCE(textvalue, '') + ', TITLE' , lastmaintdate = getdate()
													WHERE bookkey = @bookkey_title and misckey = 48
												END
											ELSE
												BEGIN
													INSERT INTO bookmisc
													Select @bookkey_title, 48, NULL, NULL, 'MISSING: TITLE', 'qsiadmin', getdate(), 0
												END

										end
										FETCH NEXT FROM c_title
											INTO @bookkey_title
												select  @i_titlefetchstatus_title  = @@FETCH_STATUS
									end
							

				close c_title
				deallocate c_title

	END

--PUBLICATION DATE

IF EXISTS (
Select * FROM bookdetail bd where 
[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') IN ('ED', 'PR') 
AND [dbo].[rpt_get_best_pub_date](bd.bookkey, 1) = '' 
AND ([dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') IS NULL 
OR [dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') = '')
AND dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) NOT LIKE 'sub%'
)

	BEGIN
		DECLARE @bookkey_pubdate int
		DECLARE @i_titlefetchstatus_pubdate int


			DECLARE c_pubdate INSENSITIVE CURSOR
					FOR
						Select bookkey FROM bookdetail bd where 
						[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') IN ('ED', 'PR') 
						AND [dbo].[rpt_get_best_pub_date](bd.bookkey, 1) = '' 
						AND ([dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') IS NULL 
						OR [dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') = '')
						AND dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) NOT LIKE 'sub%'


					FOR READ ONLY
							
					OPEN c_pubdate 

					FETCH NEXT FROM c_pubdate 
						INTO @bookkey_pubdate
						select  @i_titlefetchstatus_pubdate  = @@FETCH_STATUS

								 while (@i_titlefetchstatus_pubdate >-1 )
									begin
										IF (@i_titlefetchstatus_pubdate <>-2) 
										begin
											--
											If EXISTS (Select * FROM bookmisc where bookkey = @bookkey_pubdate and misckey = 48)
												BEGIN
													UPDATE bookmisc
													SET textvalue = COALESCE(textvalue, '') + ', PUB DATE' , lastmaintdate = getdate()
													WHERE bookkey = @bookkey_pubdate and misckey = 48
												END
											ELSE
												BEGIN
													INSERT INTO bookmisc
													Select @bookkey_pubdate, 48, NULL, NULL, 'MISSING: PUB DATE', 'qsiadmin', getdate(), 0
												END

										end
										FETCH NEXT FROM c_pubdate
											INTO @bookkey_pubdate
												select  @i_titlefetchstatus_pubdate  = @@FETCH_STATUS
									end
							

				close c_pubdate
				deallocate c_pubdate

	END




/*
FINAL SELECT FOR TITLES GOING TO ADV/SLX
Return titles that qualify as a prepub title and don't have any error messages


*/
Select bookkey,
dbo.WK_get_itemnumber(bookkey) as itemnumber
FROM book
where dbo.wk_isPrepub_Not_Published_to_Adv_Yet(bookkey) = 'Y' 
and 
(
[dbo].[rpt_get_misc_value](bookkey, 48, 'long') IS NULL 
OR [dbo].[rpt_get_misc_value](bookkey, 48, 'long') = ''
)

END


