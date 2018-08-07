if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_AuthorEditorPrimary]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[qweb_get_AuthorEditorPrimary]
GO

CREATE FUNCTION [dbo].[qweb_get_AuthorEditorPrimary] 
			(@bookkey	INT)

RETURNS	VARCHAR(512)
/*
Quick fix for UAP. Returns author names first followed by Editors by bookkey
Will be used for the website
If no primary is seleted, it will ignore
author type and return the min sort order record.

*/
AS

BEGIN

		DECLARE @v_fulldisplayname VARCHAR(512),
		@a_firstname varchar(75),
		@a_middlename varchar(75),
		@a_lastname varchar(75),
		@a_suffix varchar(25),
		@e_firstname varchar(75),
		@e_middlename varchar(75),
		@e_lastname varchar(75),
		@e_suffix varchar(25),
		@a_counter int,
		@e_counter int,
		@i_titlefetchstatus int,
		@e_titlefetchstatus int,
		@fullauthordisplayname varchar(255)

		
		--If 
		
		select @fullauthordisplayname = fullauthordisplayname FROM cbd..bookdetail
		where bookkey = @bookkey
		IF @fullauthordisplayname IS NOT NULL and @fullauthordisplayname <> ''
			BEGIN
				RETURN @fullauthordisplayname
			END

		--IF THIS RETURNS NOTHING JUST SELECT THE ONE WITH MINIMUM SORTORDER
		IF NOT EXISTS (Select * FROM cbd..bookauthor 
						WHERE bookkey = @bookkey 
						--and primaryind = 1 
						and authortypecode in (12, 16)
					  )
			BEGIN
				IF EXISTS (Select * FROM cbd..bookauthor WHERE bookkey = @bookkey)
					BEGIN
						DECLARE @firstname varchar(75),
						@middlename varchar(75),
						@lastname varchar(75),
						@fullname  varchar(512),
						@suffix varchar(25)
						
						SET @fullname = ''
						
						Select TOP 1 @firstname = a.firstname, @middlename = a.middlename,  
						@lastname = a.lastname, @suffix = gc.suffix FROM cbd..bookauthor ba
						JOIN cbd..author a
						ON ba.authorkey = a.authorkey
						JOIN cbd..globalcontact gc
						ON a.authorkey = gc.globalcontactkey
						WHERE bookkey = @bookkey
						ORDER BY ba.sortorder

						Select @fullname = CASE 
									WHEN @firstname IS  NULL THEN ''
	            							ELSE @firstname
	          						END
	          						+ CASE 
									WHEN @middlename IS NULL and @firstname is NOT NULL THEN ' '
									WHEN @middlename IS NULL and @firstname is NULL THEN ''
									WHEN @middlename is NOT NULL and @firstname is NOT NULL THEN ' '+@middlename+ ' '
        	    							ELSE ''
        	  						END
	          						+ @lastname

--						IF @suffix is not null
--							If @fullname <> ''
--								SET @fullname = @fullname + ', ' + @suffix

						RETURN @fullname

					END
				ELSE
					return ''
				

			END

		SET @a_counter = 0
		SET @e_counter = 0 
		SET @v_fulldisplayname = ''

		DECLARE c_authors CURSOR FOR

			Select a.firstname, a.middlename, a.lastname,
			gc.suffix FROM cbd..bookauthor ba
			JOIN cbd..author a
			ON ba.authorkey = a.authorkey
			JOIN cbd..globalcontact gc
			ON a.authorkey = gc.globalcontactkey
			WHERE --ba.primaryind = 1 and
			ba.authortypecode = 12
			and ba.bookkey = @bookkey
			ORDER BY ba.sortorder

			FOR READ ONLY
					
			OPEN c_authors 

			FETCH NEXT FROM c_authors 
				INTO @a_firstname, @a_middlename, @a_lastname, @a_suffix

			select  @i_titlefetchstatus  = @@FETCH_STATUS

			 while (@i_titlefetchstatus >-1 )
				begin
					IF (@i_titlefetchstatus <>-2) 
						begin
								DECLARE @a_fullname  varchar(512)
								SET @a_fullname = ''

								SET @a_counter = @a_counter + 1
								
								
								Select @a_fullname = CASE 
											WHEN @a_firstname IS  NULL THEN ''
	            									ELSE @a_firstname
	          								END
	          								+ CASE 
											WHEN @a_middlename IS NULL and @a_firstname is NOT NULL THEN ' '
											WHEN @a_middlename IS NULL and @a_firstname is NULL THEN ''
											WHEN @a_middlename is NOT NULL and @a_firstname is NOT NULL THEN ' '+@a_middlename+ ' '
        	    									ELSE ''
        	  								END
	          								+ @a_lastname
--
--								IF @a_suffix is not null AND @a_suffix <> ''
--									If @a_fullname <> ''
--										SET @a_fullname = @a_fullname + ', ' + @a_suffix
									
								If @a_fullname <> ''
										BEGIN
											If @a_counter = 1
												SET @v_fulldisplayname = @v_fulldisplayname + 'by ' + @a_fullname + ', '
											Else
												SET @v_fulldisplayname = @v_fulldisplayname +  @a_fullname + ', '
										END	
						END
					FETCH NEXT FROM c_authors
						INTO @a_firstname, @a_middlename, @a_lastname,@a_suffix 
							select  @i_titlefetchstatus  = @@FETCH_STATUS
				end
					

		close c_authors
		deallocate c_authors

		--STRIP OUT THE LAST ', '

		IF @v_fulldisplayname <> '' AND @a_counter > 0
			BEGIN
				SET @v_fulldisplayname = LTRIM(RTRIM(@v_fulldisplayname))
				SET @v_fulldisplayname = SUBSTRING(@v_fulldisplayname, 1, LEN(@v_fulldisplayname) -1)
			END

		--NOW DO THE SAME FOR EDITORS
		DECLARE c_editors CURSOR FOR

			Select a.firstname, a.middlename, a.lastname, gc.suffix 
			FROM cbd..bookauthor ba
			JOIN cbd..author a
			ON ba.authorkey = a.authorkey
			JOIN cbd..globalcontact gc
			ON a.authorkey = gc.globalcontactkey
			WHERE --ba.primaryind = 1 and
			ba.authortypecode = 16
			and ba.bookkey = @bookkey
			ORDER BY ba.sortorder

			FOR READ ONLY
					
			OPEN c_editors 

			FETCH NEXT FROM c_editors 
				INTO @e_firstname, @e_middlename, @e_lastname, @e_suffix

			select  @e_titlefetchstatus  = @@FETCH_STATUS

			 while (@e_titlefetchstatus >-1 )
				begin
					IF (@e_titlefetchstatus <>-2) 
						begin
								DECLARE @e_fullname  varchar(512)
								SET @e_fullname = ''

								SET @e_counter = @e_counter + 1
								
								
								Select @e_fullname = CASE 
											WHEN @e_firstname IS  NULL THEN ''
	            									ELSE @e_firstname
	          								END
	          								+ CASE 
											WHEN @e_middlename IS NULL and @e_firstname is NOT NULL THEN ' '
											WHEN @e_middlename IS NULL and @e_firstname is NULL THEN ''
											WHEN @e_middlename is NOT NULL and @e_firstname is NOT NULL THEN ' '+@e_middlename+ ' '
        	    									ELSE ''
        	  								END
	          								+ @e_lastname

--								IF @e_suffix is not null AND @e_suffix <> ''
--									If @e_fullname <> ''
--										SET @e_fullname = @e_fullname + ', ' + @e_suffix

									
								If @e_fullname <> ''
										BEGIN
											If @e_counter = 1
													BEGIN
														IF LEN(@v_fulldisplayname) > 2 and @a_counter > 0
															SET @v_fulldisplayname = @v_fulldisplayname + '<br />Edited by ' + @e_fullname + ', '
														ELSE
															SET @v_fulldisplayname = @v_fulldisplayname + 'Edited by ' + @e_fullname + ', '
													END
														
											Else
												SET @v_fulldisplayname = @v_fulldisplayname +  @e_fullname + ', '
										END	
							END
					FETCH NEXT FROM c_editors
						INTO @e_firstname, @e_middlename, @e_lastname, @e_suffix
							select  @e_titlefetchstatus  = @@FETCH_STATUS
				end
					

		close c_editors
		deallocate c_editors

		IF @v_fulldisplayname <> '' AND @e_counter > 0
			BEGIN
				SET @v_fulldisplayname = LTRIM(RTRIM(@v_fulldisplayname))
				SET @v_fulldisplayname = SUBSTRING(@v_fulldisplayname, 1, LEN(@v_fulldisplayname) -1)
			END

		RETURN @v_fulldisplayname

END

GO
Grant execute on dbo.qweb_get_AuthorEditorPrimary to Public
GO