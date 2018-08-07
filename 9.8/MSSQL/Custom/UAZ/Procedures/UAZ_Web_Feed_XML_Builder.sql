USE [UAZ]
GO
/****** Object:  StoredProcedure [dbo].[UAZ_Web_Feed_XML_Builder]    Script Date: 6/6/2016 2:09:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Bill A.
-- Create date: 05/16/16
-- Description:	Web Feed XML build and booktracker loader
-- =============================================
ALTER PROCEDURE [dbo].[UAZ_Web_Feed_XML_Builder]
-- Add the parameters for the stored procedure here
@v_bookkey INT, @productxml XML OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--SET @v_bookkey=597660

	--select distinct @v_targetdate=CONVERT (date,lastmaintdate,10)
	--     from uaz_title_last_maint 
	--     WHERE bookkey=@v_bookkey

	SELECT
		@productxml = (SELECT
			t.BookKey AS BookKey,
			dbo.rpt_get_filepath(t.BookKey, 2) AS cover,
			t.title AS FullTitle,
			t.SubTitle AS SubTitle,
			t.Format,
			t.ISBN,
			t.PubDate,
			t.TrimSize,
			t.PageCount,
			t.AuthorDisplayName AS AuthorDisplayName,
			t.AuthorBio,
			t.BriefDescription AS BriefDescription,
			t.Description
			--,CAST(t.Quote1 as XML) AS Quote1
			,
			CAST(ISNULL(REPLACE(CAST(t.Quote1 AS NVARCHAR(MAX)), ':', '/:'), '') AS XML) Quote1,
			CAST(ISNULL(REPLACE(CAST(t.Quote2 AS NVARCHAR(MAX)), ':', '/:'), '') AS XML) Quote2,
			CAST(ISNULL(REPLACE(CAST(t.Quote3 AS NVARCHAR(MAX)), ':', '/:'), '') AS XML) Quote3
			--,t.Quote2
			--,t.Quote3

			,
			CAST(ISNULL(REPLACE(CAST(t.Awards AS NVARCHAR(MAX)), ':', '/:'), '') AS XML) Awards,
			CAST(ISNULL(REPLACE(CAST(t.TableOfContents AS NVARCHAR(MAX)), ':', '/:'), '') AS XML) TableOfContents,
			CAST(ISNULL(REPLACE(CAST(t.Excerpt AS NVARCHAR(MAX)), ':', '/:'), '') AS XML) Excerpt
			--,t.Awards
			--,t.TableofContents
			--,t.Excerpt
			,
			dbo.rpt_get_filepath(t.BookKey, 7) AS AuthorLink,
			t.Events,
			dbo.rpt_get_filepath(t.BookKey, 21) AS CopyrightClearanceCenterLink,
			(SELECT
				a.authorsort SortOrder,
				a.authorid ID,
				a.authorrole Role,
				a.authorsuffix Suffix,
				a.authorfirstname FirstName,
				a.authormiddlename MiddleName,
				a.authorlastname LastName,
				a.authordegree Degree,
				a.AuthorFullName AuthorFullName,
				dbo.rpt_cdata(dbo.rpt_get_qsi_comment(a.authorid, 2, 0)) AS AuthorBioContact
			FROM uaz_rpt_author_info_view a
			WHERE a.BookKey = t.BookKey
			AND t.BookKey = @v_bookkey
			ORDER BY a.authorsort
			FOR XML PATH ('author'), ROOT ('authors'), TYPE),
			(SELECT
				SortOrder SortOrder,
				globalcontactkey AS ID,
				datadesc AS Role,
				FirstName FirstName,
				middlename,
				LastName LastName,
				DisplayName AS DisplayName
			FROM participants_view --ORDER BY bookkey

			WHERE BookKey = t.BookKey
			AND t.BookKey = @v_bookkey

			ORDER BY SortOrder
			FOR XML PATH ('participant'), ROOT ('participants'), TYPE)
			--(
			--SELECT
			--	b.categorysort,
			--	b.categorycode,
			--	b.categorydesc
			--FROM uaz_rpt_bisac_category_view b
			--WHERE b.bookkey = t.bookkey and t.bookkey = @v_bookkey
			--ORDER by b.categorysort
			--FOR XML PATH ('category'), ROOT('categories'), TYPE
			--),
			,
			(SELECT
				p.pricetype,
				p.pricetypeelotag AS pricetypecode,
				p.currencytype AS currency,
				p.pricefinal,
				--CONVERT(VARCHAR(24),effectivedate,113) AS effectivedate,
				p.effectivedate
			FROM uaz_rpt_price_view p
			WHERE p.BookKey = t.BookKey
			AND t.BookKey = @v_bookkey
			ORDER BY sortorder
			FOR XML PATH ('price'), ROOT ('prices'), TYPE),
			(SELECT

				av.associatetitlebookkey,
				av.associationtype,
				av.associationtypecode,
				isbn,
				title,
				SubTitle
			FROM uaz_associatedtitles_view av
			WHERE av.BookKey = t.BookKey
			AND t.BookKey = @v_bookkey
			AND av.associationtypecode IN (2, 8) --8 is Web Related Titles, may need to be changed
			ORDER BY sortorder
			FOR XML PATH ('title'), ROOT ('relatedtitles'), TYPE)
			--(
			--SELECT
			--	[dbo].[remove_control_chars](c.description) as description,
			--	[dbo].[remove_control_chars](c.authorbio) as authorbio,
			--	[dbo].[remove_control_chars](c.seriesdescription) as seriesdescription,
			--	[dbo].[remove_control_chars](c.reviewquote1) as reviewquote1,
			--	[dbo].[remove_control_chars](c.reviewquote2) as reviewquote2,
			--	[dbo].[remove_control_chars](c.reviewquote3) as reviewquote3,
			--	[dbo].[remove_control_chars](c.reviewquote4) as reviewquote4,
			--	[dbo].[remove_control_chars](c.reviewquote5) as reviewquote5,
			--	[dbo].[remove_control_chars](c.reviewquote6) as reviewquote6,
			--	[dbo].[remove_control_chars](c.reviewquote7) as reviewquote7
			--FROM uaz_rpt_title_comments c
			--WHERE c.bookkey = t.bookkey and t.bookkey = @v_bookkey
			--FOR XML PATH ('comments'), TYPE
			--),
			--dbo.rpt_get_last_user_id (t.bookkey,1) as lastuserid,
			,
			CONVERT(VARCHAR(255), h.lastmaintdate, 112) AS lastmaintdate
		FROM	uaz_rpt_title_webfeed_view t,
				uaz_title_last_maint h
		WHERE --CONVERT (date,h.lastmaintdate,10)=@v_targetdate and
		t.BookKey = h.BookKey
		AND t.BookKey = @v_bookkey
		FOR XML PATH ('product'))


		--SELECT 	t.bookkey
		--		,t.title
		--		,t.subtitle
		--		,t.Format
		--		,t.ISBN
		--		,t.PubDate
		--		,t.TrimSize
		--		,t.PageCount
		--		,t.authordisplayname
		--		,t.AuthorBio
		--		,t.Briefdescription
		--		,t.Description
		--		,t.Quote1
		--		,t.Quote2
		--		,t.Quote3
		--		,t.Awards
		--		,t.TableofContents
		--		,t.Excerpt
		--		,t.Events FROM uaz_rpt_title_webfeed_view t

		--SELECT * FROM bookauthor b where bookkey=597804

		--SELECT * FROM authorty_view av

		--		SELECT * FROM filelocation f WHERE f.filetypecode in (2)
		--		SELECT* FROM filelocationtable f
		--		SELECT dbo.[rpt_get_filepath](597653,2)
		--		SELECT * FROM gentables g where g.tableid=354

		--		21	Copyright Link
		--		7	Author Web Site
		--		1	Jacket/Cover Art Thumbnail
		--		2	Jacket/Cover Art High Res

	--	)

	IF EXISTS (SELECT
			1
		FROM webfeedxmlbinary
		WHERE bookkey = @v_bookkey)
	BEGIN
		UPDATE webfeedxmlbinary
		SET	productxml = @productxml,
			checkbinaryold = checkbinarynew
		WHERE bookkey = @v_bookkey
	END
	ELSE
	BEGIN
		INSERT INTO webfeedxmlbinary (bookkey, productxml)
			VALUES (@v_bookkey, @productxml);
	END

	DECLARE	@checksum INT,
			@oldbinary INT

	SELECT
		@checksum = ISNULL(BINARY_CHECKSUM(CONVERT(VARCHAR(MAX), @productxml)), 0)

	SELECT
		@oldbinary = ISNULL(checkbinaryold, 0)
	FROM webfeedxmlbinary
	WHERE bookkey = @v_bookkey

	UPDATE webfeedxmlbinary
	SET checkbinarynew = @checksum
	WHERE bookkey = @v_bookkey

	IF @checksum <> @oldbinary
		AND @productxml IS NOT NULL
	BEGIN
		DECLARE @date DATETIME
		SET @date = GETDATE()
	END

--TRUNCATE table webfeedxmlbinary
--SELECT * FROM webfeedxmlbinary
--SELECT * FROM booktracker

END