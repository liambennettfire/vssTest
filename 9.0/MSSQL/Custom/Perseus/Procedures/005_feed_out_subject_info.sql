/****** Object:  StoredProcedure [dbo].[feed_out_subject_info]    Script Date: 03/24/2010 11:14:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[feed_out_subject_info]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[feed_out_subject_info]

/****** Object:  StoredProcedure [dbo].[feed_out_subject_info]    Script Date: 05/04/2009 11:46:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[feed_out_subject_info]
AS

DECLARE @v_isbn				VARCHAR(20)
DECLARE @i_count			INT
DECLARE @cstatus			INT
DECLARE @i_bookkey			INT
DECLARE @i_majorsubj_count		INT
/*DECLARE @i_minorsubj_count		INT*/
DECLARE @i_bisac_count			INT
DECLARE @i_max_count			INT
DECLARE @rows				INT

DECLARE @v_majorsubject			VARCHAR(25)
/*DECLARE @v_minorsubject			VARCHAR(25)*/
DECLARE @i_tableid			INT
DECLARE @i_major_categorycode		INT
DECLARE @i_major_categorysubcode	INT
/*DECLARE @i_minor_categorycode		INT*/
/*DECLARE @i_minor_categorysubcode	INT*/
DECLARE @i_sortorder			INT

DECLARE @v_bisacsubject			VARCHAR(25)
DECLARE	@i_bisaccategorycode		INT
DECLARE @i_bisaccategorysubcode		INT

DECLARE @feed_system_date 		DATETIME
DECLARE @feedkey			INT
DECLARE @feed_last_processdate		DATETIME
DECLARE @v_bisacsubjectmajordesc	varchar(25)
DECLARE @v_bisacsubjectminordesc	varchar(25)




SELECT @feed_system_date = getdate()
SELECT @feedkey = max(feedkey) 
FROM	feedout


SELECT @feed_last_processdate = dateprocessed
FROM	feedout
WHERE	feedkey = @feedkey

TRUNCATE TABLE feedout_subjects


	SELECT @rows = count(distinct(ti.bookkey))
	FROM 	titlehistory ti, book b
	WHERE	ti.lastmaintdate > @feed_last_processdate
			AND ti.lastuserid <> 'CISPUB-2-TMM UPDATES'
			AND ti.bookkey = b.bookkey
			AND b.standardind = 'N'

	DECLARE c_title INSENSITIVE CURSOR FOR
		SELECT	DISTINCT  i.isbn10,ti.bookkey
		FROM	titlehistory ti LEFT OUTER JOIN isbn i ON ti.bookkey = i.bookkey 
					LEFT OUTER JOIN bookverification bv ON ti.bookkey = bv.bookkey
		WHERE    bv.titleverifystatuscode in (7,9)
				AND bv.verificationtypecode=1 
				AND ti.lastmaintdate > @feed_last_processdate
				AND ti.lastuserid <> 'CISPUB-2-TMM UPDATES'
		UNION
		SELECT	DISTINCT  i.isbn10,ti.bookkey
		FROM	datehistory ti LEFT OUTER JOIN isbn i ON ti.bookkey = i.bookkey 
					LEFT OUTER JOIN bookverification bv ON ti.bookkey = bv.bookkey
		WHERE    bv.titleverifystatuscode in (7,9)
				and ti.datetypecode in (8, 32, 47, 399)			--pub date, release date, warehouse date, return by date
				AND bv.verificationtypecode=1 
				AND ti.lastmaintdate > @feed_last_processdate
				AND ti.lastuserid <> 'CISPUB-2-TMM UPDATES'
		ORDER BY i.isbn10


OPEN c_title

FETCH NEXT FROM c_title
INTO @v_isbn,@i_bookkey


SELECT @cstatus = @@FETCH_STATUS

WHILE @cstatus <>-1
	BEGIN
		IF @cstatus <>-2
			BEGIN
/* Initialize Counters		*/
		SELECT @i_bisac_count = COUNT(*)
		FROM bookbisaccategory
		WHERE bookkey = @i_bookkey

		SELECT @i_majorsubj_count = COUNT(*)
		FROM bookcategory
		WHERE bookkey = @i_bookkey /*and categorytableid = 317*/

		/*SELECT @i_minorsubj_count = COUNT(*)
		FROM booksubjectcategory
		WHERE bookkey = @i_bookkey and categorytableid = 432*/

/*  Find number of iterations for loop - max number of rows between bisac and subject tables	*/
		SELECT @i_max_count = 0
		SELECT @i_count = 1

		IF @i_bisac_count >= @i_majorsubj_count
			BEGIN
				SELECT @i_max_count = @i_bisac_count
			END
		ELSE
			BEGIN
				SELECT @i_max_count = @i_majorsubj_count
			END

		/*IF @i_minorsubj_count > @i_max_count
			BEGIN
				SELECT @i_max_count = @i_minorsubj_count
			END*/

				
/* GET BISAC Subject Codes	*/
				DECLARE c_bisac INSENSITIVE CURSOR FOR
					SELECT	bisaccategorycode,bisaccategorysubcode
					FROM 	bookbisaccategory
					WHERE 	bookkey = @i_bookkey
					ORDER BY sortorder
				FOR READ ONLY

				OPEN c_bisac

				FETCH NEXT FROM c_bisac
				INTO @i_bisaccategorycode,@i_bisaccategorysubcode

/* GET Major Subject Codes		*/
				DECLARE c_majorsubject INSENSITIVE CURSOR FOR
					SELECT	categorycode,sortorder
					FROM	bookcategory
					WHERE 	bookkey = @i_bookkey /*and categorytableid = 431*/
					ORDER BY sortorder
				FOR READ ONLY

				OPEN c_majorsubject

				FETCH NEXT FROM c_majorsubject
				INTO @i_major_categorycode,@i_sortorder


/*
/* GET Minor Subject Codes		*/
				DECLARE c_minorsubject INSENSITIVE CURSOR FOR
					SELECT	categorytableid,categorycode,categorysubcode,sortorder
					FROM	booksubjectcategory
					WHERE 	bookkey = @i_bookkey and categorytableid = 432
					ORDER BY sortorder
				FOR READ ONLY

				OPEN c_minorsubject

				FETCH NEXT FROM c_minorsubject
				INTO @i_tableid,@i_minor_categorycode,@i_minor_categorysubcode,@i_sortorder
*/

/* Initailize description variables	*/			
				SELECT @v_bisacsubject = ''
				SELECT @v_majorsubject = ''
				/*SELECT @v_minorsubject = ''*/


				IF @i_max_count = 0
					BEGIN
						INSERT INTO feedout_subjects(isbn,majorsubjects,/*minorsubjects,*/bisacsubjects)
						VALUES (@v_isbn,'',/*'',*/'')
					END

				WHILE @i_count <= @i_max_count
					BEGIN

/* Resolve BISAC Subject Code INTo Description Code	*/

						IF @i_count <= @i_bisac_count
							BEGIN
								SELECT @v_bisacsubject = bisacdatacode
								FROM subgentables
								WHERE tableid = 339
									AND datacode = @i_bisaccategorycode
									AND datasubcode = @i_bisaccategorysubcode
							END
						ELSE
							BEGIN
								SELECT @v_bisacsubject = ''
							END

/*new 10-14-07*/
/* Resolve Major BISAC Subject Code INTo desc	*/

						IF @i_count <= @i_bisac_count
							BEGIN
								SELECT @v_bisacsubjectmajordesc = datadesc
								FROM gentables
								WHERE tableid = 339
									AND datacode = @i_bisaccategorycode
									
							END
						ELSE
							BEGIN
								SELECT @v_bisacsubjectmajordesc = ''
							END

/*new 10-14-07*/
/* Resolve Major minor Subject Code INTo desc	*/

						IF @i_count <= @i_bisac_count
							BEGIN
								SELECT @v_bisacsubjectminordesc = datadesc
								FROM subgentables
								WHERE tableid = 339
									AND datacode = @i_bisaccategorycode
									AND datasubcode = @i_bisaccategorysubcode
							END
						ELSE
							BEGIN
								SELECT @v_bisacsubjectminordesc = ''
							END




/* Resolve Major Subject Code into Description Code	*/
						IF @i_count <= @i_majorsubj_count
							BEGIN
								/*IF @i_major_categorycode = 0 OR @i_major_categorycode IS NULL
									BEGIN
										SELECT @v_majorsubject = externalcode
										FROM 	gentables
										WHERE 	tableid = 317
												AND datacode = @i_major_categorycode
									END*/
								/*ELSE*/ 
								IF @i_major_categorycode > 0
									BEGIN
										SELECT @v_majorsubject = datadesc
										FROM 	gentables
										WHERE 	tableid = 317
												AND datacode = @i_major_categorycode
												
									END
							END
						ELSE
							BEGIN
								SELECT @v_majorsubject = ''
							END

/*	
   /* Resolve Minor Subject Code into Description Code	*/
						IF @i_count <= @i_minorsubj_count
							BEGIN
								IF @i_minor_categorysubcode = 0 OR @i_minor_categorysubcode IS NULL
									BEGIN
										SELECT @v_minorsubject = externalcode
										FROM 	gentables
										WHERE 	tableid = 414
												AND datacode = @i_minor_categorycode
									END
								ELSE IF @i_minor_categorysubcode > 0
									BEGIN
										SELECT @v_minorsubject = externalcode
										FROM 	subgentables
										WHERE 	tableid = 414
												AND datacode = @i_minor_categorycode
												AND datasubcode = @i_minor_categorysubcode
									END
							END
						ELSE
							BEGIN
								SELECT @v_minorsubject = ''
							END
*/



						INSERT INTO feedout_subjects(isbn,majorsubjects,/*minorsubjects,*/bisacsubjects,bisacsubjectmajordesc,bisacsubjectminordesc)
						VALUES(@v_isbn,@v_majorsubject,/*@v_minorsubject,*/@v_bisacsubject,@v_bisacsubjectmajordesc,@v_bisacsubjectminordesc)
				
						SELECT @i_count = @i_count+1

						SELECT @v_bisacsubject = ''
						SELECT @v_majorsubject = ''
						/*SELECT @v_minorsubject = ''*/

						FETCH NEXT FROM c_bisac
						INTO @i_bisaccategorycode,@i_bisaccategorysubcode		

						FETCH NEXT FROM c_majorsubject
						INTO /*@i_tableid,*/@i_major_categorycode,/*@i_major_categorysubcode*,*/@i_sortorder

						/*
						/*FETCH NEXT FROM c_minorsubject
						INTO @i_tableid,@i_minor_categorycode,@i_minor_categorysubcode,@i_sortorder*/
						*/


					END
			

				CLOSE c_bisac
				DEALLOCATE c_bisac

				CLOSE c_majorsubject
				DEALLOCATE c_majorsubject

				/*CLOSE c_minorsubject
				DEALLOCATE c_minorsubject*/

			END

		FETCH NEXT FROM c_title
		INTO @v_isbn,@i_bookkey

		SELECT @cstatus = @@FETCH_STATUS

	END

CLOSE c_title
DEALLOCATE c_title

