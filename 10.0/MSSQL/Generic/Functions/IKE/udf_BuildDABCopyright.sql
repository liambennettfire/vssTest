/******************************************************************************
**  Name: udf_BuildDABCopyright
**  Desc: IKE 
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[dbo].[udf_BuildDABCopyright]')
			AND type IN (N'FN',N'IF',N'TF',N'FS',N'FT')
		)
	DROP FUNCTION [dbo].[udf_BuildDABCopyright]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf_BuildDABCopyright] (@i_bookkey AS INT)
RETURNS NVARCHAR(4000)
AS
BEGIN

	DECLARE @s_retval NVARCHAR(4000)
		,@s_authorDesc NVARCHAR(500) = ''
		,@Null as Varchar(6)

	SET @Null=''	
	
	SELECT	@s_authorDesc += ', ' + COALESCE(a.firstname,@Null) + ' ' + COALESCE(a.lastname,@Null)
	FROM	book b
			JOIN bookauthor ba ON ba.bookkey = b.bookkey
			JOIN author a ON ba.authorkey = a.authorkey
	WHERE	b.bookkey = @i_bookkey
			AND ba.primaryind = 1
	--and ba.authortypecode=12 --only pull authors
	ORDER BY ba.sortorder
	IF (@s_authorDesc != '')
	BEGIN
		SET @s_authorDesc = ' by <b>'+ SUBSTRING(@s_authorDesc, 3, LEN(@s_authorDesc))+'</b>'
	END

	SELECT	@s_retval = '<blockquote><hr noshade size="1"><font size="-2">' + 'Excerpted from <b>' + CASE 
				WHEN bd.titleprefix IS NOT NULL
					AND bd.titleprefix != ''
					THEN bd.titleprefix + ' '
				ELSE ''
			END +
			COALESCE(b.title,@Null) + '</b>' + @s_authorDesc + '. ' + 'Copyright &copy; ' + CASE 
				WHEN bd.copyrightyear IS NOT NULL
					AND bd.copyrightyear != ''
					THEN COALESCE(CONVERT(NVARCHAR(4), bd.copyrightyear),@Null) + ' '
				ELSE COALESCE(CONVERT(NVARCHAR(4), YEAR(pubdate.bestdate)),@Null) + ' '
				END + 
			'by ' + CASE 
				WHEN bm.textvalue IS NOT NULL
					AND bm.textvalue != ''
					THEN bm.textvalue + '. '
				WHEN a.firstname IS NOT NULL 
					AND a.lastname IS NOT NULL
					THEN COALESCE(a.firstname,@Null) + ' ' + COALESCE(a.lastname,@Null) + '. '
				ELSE COALESCE(pub.orgentrydesc,@Null)+'. '
				END + 
			'Excerpted by permission of ' + COALESCE(pub.orgentrydesc,@Null)+ CASE 
				WHEN i.ean13 LIKE '9780307%' 
					OR i.ean13 LIKE '9780345%' 
					OR i.ean13 LIKE '9780375%' 
					OR i.ean13 LIKE '9780385%' 
					OR i.ean13 LIKE '9780394%' 
					OR i.ean13 LIKE '9780440%' 
					OR i.ean13 LIKE '9780552%' 
					OR i.ean13 LIKE '9780553%' 
					OR i.ean13 LIKE '9780609%' 
					OR i.ean13 LIKE '9780676%' 
					OR i.ean13 LIKE '97814000%'
					THEN ', a division of Random House, Inc.<br/>'
				ELSE '.<br/>'
			END+
			'All rights reserved. No part of this excerpt may be reproduced or reprinted without permission in writing from the publisher.<br/>' + 
			'Excerpts are provided by Dial-A-Book Inc. solely for the personal use of visitors to this web site.' + 
			'</font><hr noshade size="1"></blockquote>'
	FROM	book b
			JOIN bookdetail bd ON bd.bookkey = b.bookkey
			JOIN isbn i ON i.bookkey=b.bookkey
			LEFT OUTER JOIN bookorgentry bo2 ON b.bookkey = bo2.bookkey AND bo2.orglevelkey = 2
			LEFT OUTER JOIN orgentry pub ON pub.orgentrykey = bo2.orgentrykey AND pub.orglevelkey = bo2.orglevelkey
			LEFT OUTER JOIN bookdates pubdate ON b.bookkey = pubdate.bookkey AND pubdate.datetypecode = 8
			LEFT OUTER JOIN bookmisc bm ON bm.bookkey = b.bookkey AND bm.misckey = 114
			LEFT OUTER JOIN bookauthor ba ON ba.bookkey = b.bookkey AND ba.primaryind = 1 AND ba.sortorder = 1
			LEFT OUTER JOIN author a ON ba.authorkey = a.authorkey
	WHERE	b.bookkey = @i_bookkey

	RETURN	@s_retval
END
