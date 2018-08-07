/****** Object:  StoredProcedure [dbo].[feed_out_author_info]    Script Date: 03/24/2010 11:13:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[feed_out_author_info]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[feed_out_author_info]

/****** Object:  StoredProcedure [dbo].[feed_out_author_info]    Script Date: 05/04/2009 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[feed_out_author_info]
AS
DECLARE @v_isbn			VARCHAR(15)
DECLARE @i_bookkey		INT
DECLARE @i_authorkey		INT
DECLARE	@i_primaryind		INT
DECLARE	@i_authortypecode	INT
DECLARE @i_sortorder		INT
DECLARE @i_roleorder		INT
DECLARE @i_mainind		INT

DECLARE @v_feedout_lastname	VARCHAR(75)
DECLARE @v_feedout_firstname	VARCHAR(75)
DECLARE @v_feedout_role		VARCHAR(40)

DECLARE @feedkey		INT
DECLARE @feed_last_processdate	DATETIME
DECLARE @feed_system_date	DATETIME

DECLARE @i_count		INT
DECLARE @i_fostatus		INT
DECLARE @i_austatus		INT


SELECT @feed_system_date = getdate()


SELECT @feedkey = max(feedkey) 
FROM	feedout

SELECT @feed_last_processdate = dateprocessed
FROM	feedout
WHERE	feedkey = @feedkey

delete from feedout_authors

DECLARE feedout_authors INSENSITIVE CURSOR FOR
	SELECT DISTINCT i.isbn10
		FROM 	titlehistory ti LEFT OUTER JOIN isbn i ON ti.bookkey = i.bookkey
					LEFT OUTER JOIN bookverification bv ON ti.bookkey = bv.bookkey
		WHERE	ti.lastmaintdate > @feed_last_processdate
			AND ti.lastuserid <> 'CISPUB-2-TMM UPDATES'
			AND bv.titleverifystatuscode in (7,9)
			AND bv.verificationtypecode=1
		UNION
		SELECT DISTINCT i.isbn10
		FROM 	datehistory ti LEFT OUTER JOIN isbn i ON ti.bookkey = i.bookkey
					LEFT OUTER JOIN bookverification bv ON ti.bookkey = bv.bookkey
		WHERE	ti.lastmaintdate > @feed_last_processdate
			and ti.datetypecode in (8, 32, 47, 399)			--pub date, release date, warehouse date, return by date
			AND ti.lastuserid <> 'CISPUB-2-TMM UPDATES'
			AND bv.titleverifystatuscode in (7,9)
			AND bv.verificationtypecode=1

		ORDER BY i.isbn10

OPEN feedout_authors

FETCH NEXT FROM feedout_authors
INTO @v_isbn

SELECT @i_fostatus = @@FETCH_STATUS

WHILE @i_fostatus <> -1
	BEGIN
		IF @i_fostatus <>-2
			BEGIN
				DECLARE c_author INSENSITIVE CURSOR FOR
					SELECT ba.bookkey,ba.authorkey,ba.primaryind,ba.authortypecode,ba.sortorder,
							dbo.PERS_authorrole_sort(ba.bookkey,ba.authorkey),a.lastname,a.firstname
					FROM bookauthor ba, isbn i, author a
					WHERE ba.bookkey = i.bookkey
								AND i.isbn10 = @v_isbn
								AND ba.authorkey = a.authorkey
					ORDER BY ba.primaryind desc,dbo.pers_authorrole_sort(ba.bookkey,ba.authorkey), ba.sortorder
				FOR READ ONLY

				OPEN c_author

				FETCH NEXT FROM c_author 
				INTO  @i_bookkey,@i_authorkey,@i_primaryind,@i_authortypecode,@i_sortorder,@i_roleorder,@v_feedout_lastname,@v_feedout_firstname
				
				SELECT @i_austatus = @@FETCH_STATUS
				SELECT @i_mainind = 0

				WHILE  @i_austatus <> -1
					BEGIN
						IF @i_austatus <>-2
							BEGIN
								SELECT @v_feedout_role = ''

								SELECT @i_count = COUNT(*)
								FROM 	bookauthor 
								WHERE bookkey = @i_bookkey


								IF @i_count = 1								/*  If there is only 1 contributor = Main	*/
									BEGIN
										SELECT @v_feedout_role = 'Main'
									END
								ELSE
									BEGIN

										IF @i_primaryind = 1 and @i_roleorder = 1 and @i_mainind <> 1    /* Checks to if Role = Author and Primary Ind = 1 the Main Contrbritor */
											BEGIN
												SELECT @v_feedout_role = 'Main'
												SELECT @i_mainind = 1
											END

										ELSE IF @i_primaryind = 1 and @i_roleorder = 2 and @i_mainind <> 1  /* Checks to if there is no Author and 
																			Role = Editor and Primary Ind = 1 the Main */
											BEGIN
												SELECT @v_feedout_role = 'Main'
												SELECT @i_mainind = 1
											END
										ELSE								/* Else must be secondary contributors	*/
											BEGIN
												SELECT @v_feedout_role = datadesc
												FROM gentables
												WHERE tableid = 134
													AND datacode = @i_authortypecode
											END
			
									END

									select @v_feedout_lastname = dbo.replace_xchars(@v_feedout_lastname)
									select @v_feedout_firstname = dbo.replace_xchars(@v_feedout_firstname)

									INSERT INTO feedout_authors (isbn,authlastname,authfirstname,authrole)
									VALUES (@v_isbn,@v_feedout_lastname,@v_feedout_firstname,@v_feedout_role)
							END
								
								
		
							FETCH NEXT FROM c_author 
							INTO  @i_bookkey,@i_authorkey,@i_primaryind,@i_authortypecode,@i_sortorder,@i_roleorder,
									@v_feedout_lastname,@v_feedout_firstname

			
							SELECT @i_austatus = @@FETCH_STATUS

						END
							
					CLOSE c_author
					DEALLOCATE c_author
					
				END

				FETCH NEXT FROM feedout_authors
				INTO @v_isbn

				SELECT @i_fostatus = @@FETCH_STATUS

			END

CLOSE feedout_authors
DEALLOCATE feedout_authors


