USE [MIZ]
GO

/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_author_metakeywords]    Script Date: 03/02/2011 15:36:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create function [dbo].[qweb_ecf_get_author_metakeywords] (@i_workkey int) 

RETURNS varchar(512)

as

BEGIN

DECLARE @v_metakeywords varchar(512),
		@i_bookkey int,
		@i_titlefetchstatus int

	Select @v_metakeywords = siu.dbo.qweb_get_Title(@i_workkey,'F') + ', '

	DECLARE c_pss_titles CURSOR
	FOR

	Select b.bookkey
	from siu..book b
	where b.workkey = @i_workkey
	
	FOR READ ONLY
			
	OPEN c_pss_titles
	
	FETCH NEXT FROM c_pss_titles
		INTO @i_bookkey

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin

		Select @v_metakeywords = ISNULL(@v_metakeywords,'') +
		siu.dbo.qweb_get_Isbn(@i_bookkey,10) + ', ' +
		siu.dbo.qweb_get_Isbn(@i_bookkey,13) + ', ' +
		siu.dbo.qweb_get_Isbn(@i_bookkey,16) + ', ' +
		siu.dbo.qweb_get_Isbn(@i_bookkey,17) + ', ' 

		end


	FETCH NEXT FROM c_pss_titles
		INTO @i_bookkey
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_pss_titles
deallocate c_pss_titles

Select @v_metakeywords = SUBSTRING(@v_metakeywords,1,len(@v_metakeywords)-1)

RETURN @v_metakeywords

END



GO

/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_product_metakeywords]    Script Date: 03/02/2011 15:36:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[qweb_ecf_get_product_metakeywords] (@i_workkey int) 

RETURNS varchar(512)

as

BEGIN

DECLARE @v_metakeywords varchar(512),
		@i_bookkey int,
		@i_titlefetchstatus int,
		@v_authorbylineprepro varchar (8000),
		@v_unformatted_metakeywords varchar(512)

	Select @v_metakeywords = siu.dbo.qweb_get_Title(@i_workkey,'F')
	select @v_unformatted_metakeywords = siu.dbo.replace_xchars (@v_metakeywords) 
	
	DECLARE c_pss_titles CURSOR
	FOR

	Select b.bookkey
	from siu..book b
	where b.workkey = @i_workkey
	
	FOR READ ONLY
			
	OPEN c_pss_titles
	
	FETCH NEXT FROM c_pss_titles
		INTO @i_bookkey

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin

		Select @v_authorbylineprepro = commenttext from siu..bookcomments where commenttypecode = 3 
		and commenttypesubcode = 73 and bookkey = @i_bookkey

		Select @v_metakeywords = ISNULL(@v_metakeywords,'') + ', '+
		@v_unformatted_metakeywords + ', ' +
		siu.dbo.qweb_get_Isbn(@i_bookkey,10) + ', ' +
		siu.dbo.qweb_get_Isbn(@i_bookkey,13) + ', ' +
		siu.dbo.qweb_get_Isbn(@i_bookkey,16) + ', ' +
		siu.dbo.qweb_get_Isbn(@i_bookkey,17) + ', ' +
		ISNULL (@v_authorbylineprepro,'') + ', ' + 
		siu.dbo.qweb_get_series(@i_bookkey,'1')

		end


	FETCH NEXT FROM c_pss_titles
		INTO @i_bookkey
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_pss_titles
deallocate c_pss_titles

Select @v_metakeywords = SUBSTRING(@v_metakeywords,1,len(@v_metakeywords)-1)

RETURN @v_metakeywords

END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_sku_awards]    Script Date: 03/02/2011 15:36:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[qweb_ecf_get_sku_awards] (@i_bookkey int) 

RETURNS varchar(512)

as

BEGIN

DECLARE @v_awards varchar(512),
		@i_titlefetchstatus int,
		@v_awardsList varchar(8000)
		

	DECLARE c_pss_awards CURSOR
	FOR

	
	Select dbo.get_gentables_desc(303,speccode,'D') + ' ' + siu.dbo.get_gentables_desc(545,awardyearcode,'D')
	from siu..productspecs
	where specid = 303
	and bookkey = @i_bookkey
	order by awardyearcode desc
	
	FOR READ ONLY
			
	OPEN c_pss_awards
	
	FETCH NEXT FROM c_pss_awards
		INTO @v_awards

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin

		Select @v_awardsList = ISNULL(@v_awardsList,'') + ISNULL(@v_awards,'') + '<BR>' 

		end


	FETCH NEXT FROM c_pss_awards
		INTO @v_awards
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_pss_awards
deallocate c_pss_awards

Select @v_awardsList = SUBSTRING(@v_awardsList,1,len(@v_awardsList)-4)

RETURN @v_awardsList

END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AssocTitleAuthor]    Script Date: 03/02/2011 15:36:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_AssocTitleAuthor]
		(@i_bookkey	INT,
		@i_order	INT,
		@i_type		INT)

RETURNS VARCHAR(80)

/*	The purpose of the qweb_get_AssocTitleAuthor function is to return a the first Author  from associated title table
	for the row specified by the @i_order (sort order) parameter.  

	Parameter Options
		bookkey


		Order
			1 = Returns first Associate Title Type
			2 = Returns second Associate Title Type
			3 = Returns third Associate Title Type
			4
			5
			.
			.
			.
			n	

		Type
			1 = Competitive Titles
			2 = Comparative Titles
			3 = Author Sales Track		


*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(80)
	DECLARE @v_author		VARCHAR(80)
	DECLARE @i_assocbookkey		INT

	SELECT @i_assocbookkey = associatetitlebookkey
	FROM	associatedtitles
	WHERE	bookkey = @i_bookkey 
			AND sortorder = @i_order	
			AND associationtypecode = @i_type


	IF @i_assocbookkey > 0
		BEGIN
			SELECT @v_author = dbo.qweb_get_Author(@i_assocbookkey,1,0,'D')
			FROM book
			WHERE bookkey = @i_assocbookkey
		END
	ELSE
		BEGIN
			SELECT @v_author = authorname
			FROM	associatedtitles
			WHERE	bookkey = @i_bookkey 
					AND sortorder = @i_order
					AND associationtypecode = @i_type
		END

	IF LEN(@v_author) > 0
		BEGIN
			SELECT @RETURN = @v_author
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AssocTitleISBN]    Script Date: 03/02/2011 15:36:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





CREATE FUNCTION [dbo].[qweb_get_AssocTitleISBN]
		(@i_bookkey	INT,
		@i_order	INT,
		@i_type		INT)

RETURNS VARCHAR(20)

/*	The purpose of the qweb_get_AssocTitleISBN function is to return a the ISBN column from associated title table
	for the row specified by the @i_order (sort order) parameter.  

	Parameter Options
		bookkey


		Order
			1 = Returns first Associate Title Type
			2 = Returns second Associate Title Type
			3 = Returns third Associate Title Type
			4
			5
			.
			.
			.
			n			
		Type
			1 = Competitive Titles
			2 = Comparative Titles
			3 = Author Sales Track		

*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(20)
	DECLARE @v_isbn			VARCHAR(20)
	DECLARE @i_assocbookkey		INT

	SELECT @i_assocbookkey = associatetitlebookkey
	FROM	associatedtitles
	WHERE	bookkey = @i_bookkey 
			AND sortorder = @i_order	
			AND associationtypecode = @i_type

	IF @i_assocbookkey > 0
		BEGIN
			SELECT @v_isbn = isbn10
			FROM isbn
			WHERE bookkey = @i_assocbookkey
		END
	ELSE
		BEGIN
			SELECT @v_isbn = isbn
			FROM	associatedtitles
			WHERE	bookkey = @i_bookkey 
					AND sortorder = @i_order
					AND associationtypecode = @i_type
		END

	IF LEN(@v_isbn) > 0
		BEGIN
			SELECT @RETURN = @v_isbn
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AssocTitlePrice]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_AssocTitlePrice]
		(@i_bookkey	INT,
		@i_order	INT,
		@i_type		INT)

RETURNS VARCHAR(10)

/*	The purpose of the qweb_get_AssocTitleAuthor function is to return a the Price  from associated title table
	for the row specified by the @i_order (sort order) parameter.  

	Parameter Options
		bookkey


		Order
			1 = Returns first Associate Title Type
			2 = Returns second Associate Title Type
			3 = Returns third Associate Title Type
			4
			5
			.
			.
			.
			n	

		Type
			1 = Competitive Titles
			2 = Comparative Titles
			3 = Author Sales Track		


*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(10)
	DECLARE @v_price		VARCHAR(10)
	DECLARE @i_assocbookkey		INT

	SELECT @i_assocbookkey = associatetitlebookkey
	FROM	associatedtitles
	WHERE	bookkey = @i_bookkey 
			AND sortorder = @i_order	
			AND associationtypecode = @i_type


	IF @i_assocbookkey > 0
		BEGIN
			SELECT @v_price = dbo.qweb_get_BestUSPrice(@i_assocbookkey,8)
			FROM book
			WHERE bookkey = @i_assocbookkey
		END
	ELSE
		BEGIN
			SELECT @v_price = CONVERT(VARCHAR,price)
			FROM	associatedtitles
			WHERE	bookkey = @i_bookkey 
					AND sortorder = @i_order
					AND associationtypecode = @i_type
		END

	IF LEN(@v_price) > 0
		BEGIN
			SELECT @RETURN = @v_price
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AssocTitlePubDate]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_AssocTitlePubDate]
		(@i_bookkey	INT,
		@i_order	INT,
		@i_type		INT)

RETURNS VARCHAR(10)

/*	The purpose of the qweb_get_AssocTitleAuthor function is to return a the Price  from associated title table
	for the row specified by the @i_order (sort order) parameter.  

	Parameter Options
		bookkey


		Order
			1 = Returns first Associate Title Type
			2 = Returns second Associate Title Type
			3 = Returns third Associate Title Type
			4
			5
			.
			.
			.
			n	

		Type
			1 = Competitive Titles
			2 = Comparative Titles
			3 = Author Sales Track		


*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(10)
	DECLARE @v_pubdate		VARCHAR(10)
	DECLARE @i_assocbookkey		INT

	SELECT @i_assocbookkey = associatetitlebookkey
	FROM	associatedtitles
	WHERE	bookkey = @i_bookkey 
			AND sortorder = @i_order	
			AND associationtypecode = @i_type


	IF @i_assocbookkey > 0
		BEGIN
			SELECT @v_pubdate = dbo.qweb_get_BestPubDate(@i_assocbookkey,1)
			FROM book
			WHERE bookkey = @i_assocbookkey
		END
	ELSE
		BEGIN
			SELECT @v_pubdate = CONVERT(VARCHAR,pubdate,101)
			FROM	associatedtitles
			WHERE	bookkey = @i_bookkey 
					AND sortorder = @i_order
					AND associationtypecode = @i_type
		END

	IF LEN(@v_pubdate) > 0
		BEGIN
			SELECT @RETURN = @v_pubdate
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AssocTitleTitle]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_AssocTitleTitle]
		(@i_bookkey	INT,
		@i_order	INT,
		@i_type		INT)

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_AssocTitleTitle function is to return a the Title  from associated title table
	for the row specified by the @i_order (sort order) parameter.  

	Parameter Options
		bookkey


		Order
			1 = Returns first Associate Title Type
			2 = Returns second Associate Title Type
			3 = Returns third Associate Title Type
			4
			5
			.
			.
			.
			n	

		Type
			1 = Competitive Titles
			2 = Comparative Titles
			3 = Author Sales Track		


*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_title		VARCHAR(255)
	DECLARE @i_assocbookkey		INT

	SELECT @i_assocbookkey = associatetitlebookkey
	FROM	associatedtitles
	WHERE	bookkey = @i_bookkey 
			AND sortorder = @i_order	
			AND associationtypecode = @i_type


	IF @i_assocbookkey > 0
		BEGIN
			SELECT @v_title = title
			FROM book
			WHERE bookkey = @i_assocbookkey
		END
	ELSE
		BEGIN
			SELECT @v_title = title
			FROM	associatedtitles
			WHERE	bookkey = @i_bookkey 
					AND sortorder = @i_order
					AND associationtypecode = @i_type
		END

	IF LEN(@v_title) > 0
		BEGIN
			SELECT @RETURN = @v_title
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AssocTitleType]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_AssocTitleType]
		(@i_bookkey	INT,
		@i_order	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_AssocTitleType function is to return a specific descriptive column from gentables for the associated
	title type.  

	Parameter Options
		bookkey


		Order
			1 = Returns first Associate Title Type
			2 = Returns second Associate Title Type
			3 = Returns third Associate Title Type
			4
			5
			.
			.
			.
			n			

		Column
			D = Data Description
			E = External code
			S = Short Description
			B = BISAC Data Code
			T = Eloquence Field Tag
			1 = Alternative Description 1
			2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_associationtypecode	INT


	SELECT @i_associationtypecode = associationtypecode
	FROM	associatedtitles
	WHERE	bookkey = @i_bookkey and sortorder = @i_order


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(g.datadesc))
			FROM gentables g
			WHERE g.tableid = 440
					AND g.datacode = @i_associationtypecode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM gentables g
			WHERE g.tableid = 440
					AND g.datacode = @i_associationtypecode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM gentables g
			WHERE g.tableid = 440
					AND g.datacode = @i_associationtypecode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM gentables g
			WHERE g.tableid = 440
					AND g.datacode = @i_associationtypecode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM gentables g
			WHERE g.tableid = 440
					AND g.datacode = @i_associationtypecode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM gentables g
			WHERE g.tableid = 440
					AND g.datacode = @i_associationtypecode
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Audience]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_Audience]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1),
		@i_sortorder	INT)

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Audience function is to return a specific description column from gentables for an Audience Code

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_audiencecode		INT

	SELECT @v_desc = ''
	
	SELECT @i_audiencecode = audiencecode
	FROM	bookaudience
	WHERE	bookkey = @i_bookkey
	AND 	sortorder = @i_sortorder

IF @i_audiencecode > 0
	BEGIN
	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 460
					AND datacode = @i_audiencecode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 460
					AND datacode = @i_audiencecode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 460
					AND datacode = @i_audiencecode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 460
					AND datacode = @i_audiencecode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 460
					AND datacode = @i_audiencecode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 460
					AND datacode = @i_audiencecode
		END
	END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END











GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Author]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[qweb_get_Author] 
			(@i_bookkey	INT,
			@i_order	INT,
			@i_type		INT,
			@v_name		VARCHAR(1))

RETURNS	VARCHAR(120)

/*  The purpose of the qweb_get_Author functions is to return a specific author name from the author table based upon the bookkey.

	PARAMETER OPTIONS

		@i_Order
			1 = Returns first Author
			2 = Returns second Author
			3 = Returns third Author
			4
			5
			.
			.
			.
			n
		

		@i_type = roltype codes to include
			0 = Include all Contributor Role types
			12 = Include just Author Role types (pulls from gentables.tableid=134 for roletypecode


		@v_name = author name field (if corporate indicator = 1, then any options will always pull the lastname)
			D = Display Name
			C = Complete Name (nameabbrev + firstname + mi + lastname + suffix)
			F = First Name
			M = Middle Name
			L = Last Name
			S = Suffix
			
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(120)
	DECLARE @v_desc			VARCHAR(80)
	DECLARE @i_count		INT		
	DECLARE @i_authorkey		INT
	DECLARE @v_firstname		VARCHAR(40)
	DECLARE @v_middlename		VARCHAR(20)
	DECLARE @v_lastname		VARCHAR(40)
	DECLARE @v_nameabbrev		VARCHAR(10)
	DECLARE @v_suffix		VARCHAR(10)
	DECLARE @i_corporatename	INT

/*  GET AUTHOR KEY FOR AUTHOR TYPE and ORDER 	*/
	IF @i_type = 0
		BEGIN

			SELECT 	@i_authorkey = authorkey
			FROM	bookauthor
			WHERE	bookkey = @i_bookkey
					AND sortorder = @i_order
	
		END

	IF @i_type = 0 and @i_order=0

		BEGIN

			SELECT 	@i_authorkey = authorkey 
			FROM    bookauthor
			WHERE	bookkey = @i_bookkey
			AND		primaryind=1
			
				
		END


	IF @i_type > 0 
		BEGIN
			SELECT 	@i_authorkey = authorkey				
			FROM	bookauthor
			WHERE	bookkey = @i_bookkey
					AND sortorder = @i_order
					AND authortypecode = @i_type
					
		END

	IF @i_type > 0 and @i_order=0
		BEGIN
			SELECT 	@i_authorkey = authorkey
			FROM	bookauthor
			WHERE	bookkey = @i_bookkey
			AND		authortypecode = @i_type
			AND		primaryind=1
			
					
					
		END


/* GET AUTHOR NAME		*/

	SELECT @i_corporatename = corporatecontributorind
	FROM author
	WHERE authorkey = @i_authorkey


	IF @i_corporatename = 1	
		BEGIN
			SELECT @v_desc = lastname
			FROM	author
			WHERE authorkey = @i_authorkey
		END

	ELSE
		BEGIN

			IF @v_name = 'D' 
				BEGIN
					SELECT @v_desc = displayname
					FROM author
					WHERE authorkey = @i_authorkey
				END

			ELSE IF @v_name = 'L' 
				BEGIN
					SELECT @v_desc = lastname
					FROM author
					WHERE authorkey = @i_authorkey
				END

			ELSE IF @v_name = 'F' 
				BEGIN
					SELECT @v_desc = firstname
					FROM author
					WHERE authorkey = @i_authorkey
				END

			ELSE IF @v_name = 'M' 
				BEGIN
					SELECT @v_desc = middlename
					FROM author
					WHERE authorkey = @i_authorkey
				END

			ELSE IF @v_name = 'S' 
				BEGIN
					SELECT @v_desc = authorsuffix
					FROM author
					WHERE authorkey = @i_authorkey
				END

			ELSE IF @v_name = 'C' 
				BEGIN
					SELECT @v_nameabbrev = g.datadesc
					FROM	gentables g, author a
					WHERE	g.tableid = 210
						AND a.authorkey = @i_authorkey
						AND a.nameabbrcode = g.datacode

	
					SELECT @v_firstname = firstname,
						@v_middlename = middlename,
						@v_lastname = lastname,
						@v_suffix = authorsuffix
					FROM author
					WHERE authorkey = @i_authorkey
		 
					SELECT @v_desc =  
						CASE 
							WHEN @v_nameabbrev IS NULL THEN  ''
							WHEN @v_nameabbrev IS NOT NULL THEN @v_nameabbrev + ' '
            						ELSE ''
          					END

						+CASE 
							WHEN @v_firstname IS  NULL THEN ''
	            					ELSE @v_firstname
	          				END

	          				+CASE 
							WHEN @v_middlename IS NULL and @v_firstname is NOT NULL THEN ' '
							WHEN @v_middlename IS NULL and @v_firstname is NULL THEN ''
							WHEN @v_middlename is NOT NULL and @v_firstname is NOT NULL THEN ' '+@v_middlename+ ' '
        	    					ELSE ''
        	  				END

	          				+ @v_lastname

	          				+ CASE 
							WHEN @v_suffix IS NOT NULL THEN ' ' + @v_suffix
					        	ELSE ''
          					END
			
				END

			END


		IF LEN(@v_desc) > 0
			BEGIN
				SELECT @RETURN = LTRIM(RTRIM(@v_desc))
			END

			ELSE
				BEGIN
					SELECT @RETURN = ''
				END




RETURN @RETURN


END









GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AuthorBio]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_AuthorBio] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_AuthorBio function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 3
	SELECT @i_commenttypesubcode = 10
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END










GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AuthorBioUnique]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






CREATE FUNCTION [dbo].[qweb_get_AuthorBioUnique] 
            	(@i_bookkey 	INT,
		@i_order	INT)

		

 
/*      The qweb_get_AuthorBioUnique function is used to retrieve the best Author Bio Available.  If the Author Bio is present on the Author record,
	it pulls that one.  If not, it looks on the book record, if not, it returns nothing.
	This procedure can only return plain text.
        The parameters are for the book key and author order.  


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_authorkey		INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  Get the Author key		*/
	SELECT @i_authorkey = dbo.qweb_get_AuthorKey(@i_bookkey, @i_order)
	SELECT @v_text = ''

	IF @i_authorkey > 0
		BEGIN
			SELECT @v_text = CAST(biography AS VARCHAR(8000))
			FROM author
			WHERE authorkey = @i_authorkey 
 		END

/*  If it doesn't exist, get the author bio for the title	*/
	IF LEN(@v_text) > 0
		BEGIN
			SELECT @RETURN = ltrim(rtrim(@v_text)) 
		END
	ELSE IF @i_authorkey > 0
		BEGIN
			SELECT @RETURN = dbo.qweb_get_AuthorBio(@i_bookkey,1)
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN

END












GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AuthorCorpInd]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






--drop FUNCTION dbo.qweb_get_AuthorCorpInd
--go

CREATE FUNCTION [dbo].[qweb_get_AuthorCorpInd] 
			(@i_bookkey	INT,
			@i_order 	INT)


RETURNS	VARCHAR (1)

/*  The purpose of the qweb_get_AuthorCorpInd function is to return a specific author name 
    formatted correctly for the Borders e-cat spreadsheet.  Borders likes their authors formatted as lastname-space-firstname
    with no punctuation of any kind and in an all uppercase form.

	
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(1)
	DECLARE @v_desc			VARCHAR(1)
	DECLARE @i_authorkey		INT
	DECLARE @i_corporatename	INT



/*  GET  AUTHOR KEY 	*/
	
	SELECT 	 @i_authorkey = dbo.qweb_get_AuthorKey(@i_bookkey, @i_order)

	IF @i_authorkey = 0
		BEGIN
			SELECT @v_desc = ''
		END
	ELSE
		BEGIN
		/* GET AUTHOR NAME		*/

			SELECT @i_corporatename = corporatecontributorind
			FROM author
			WHERE authorkey = @i_authorkey


			IF @i_corporatename = 1	
				BEGIN
					SELECT @v_desc = 'Y'
				END

			ELSE
				BEGIN

					SELECT @v_desc = 'N'

				END
		END
	
	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END

	ELSE
		BEGIN
			SELECT @RETURN = ''
		END




RETURN @RETURN


END









GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AuthorKey]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_AuthorKey] 
			(@i_bookkey	INT,
			@i_order 	INT)


RETURNS	INT

/*  The purpose of the qweb_get_AuthorKey function is to return a specific author key for the bookkey and order number specified.


	returns a 0 if there is no author for the order requested
*/
AS

BEGIN

	DECLARE @RETURN			INT
	DECLARE @i_count		INT		
	DECLARE @i_authorkey		INT
	DECLARE @i_sortorder		INT



/* FIND OUT HOW MANY AUTHORS THERE ARE */

	SELECT	@i_count=count(*)
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
	IF @i_count< @i_order -- there are less authors than what is requested, return a 0
		BEGIN
			SELECT @RETURN = 0
		END
	ELSE
		BEGIN
			SELECT 	@i_authorkey = authorkey
					FROM bookauthor
					WHERE	bookkey = @i_bookkey
					AND sortorder = @i_order
					
			IF @i_authorkey > 0
				BEGIN
					SELECT @RETURN = @i_authorkey
				END
			ELSE
				BEGIN
					SELECT @RETURN = 0
				END
		END



RETURN @RETURN


END











GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AuthorNameBorders]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_AuthorNameBorders] 
			(@i_bookkey	INT,
			@i_order 	INT)


RETURNS	VARCHAR (120)

/*  The purpose of the qweb_get_AuthorNameBorders function is to return a specific author name 
    formatted correctly for the Borders e-cat spreadsheet.  Borders likes their authors formatted as lastname-space-firstname
    with no punctuation of any kind and in an all uppercase form.

	
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(120)
	DECLARE @v_desc			VARCHAR(80)
	DECLARE @i_authorkey		INT
	DECLARE @v_firstname		VARCHAR(40)
	DECLARE @v_lastname		VARCHAR(40)
	DECLARE @i_corporatename	INT



/*  GET  AUTHOR KEY 	*/
	
	SELECT 	 @i_authorkey = dbo.qweb_get_AuthorPrimaryKey(@i_bookkey, @i_order)

	IF @i_authorkey = 0
		BEGIN
			SELECT @v_desc = ''
		END
	ELSE
		BEGIN
		/* GET AUTHOR NAME		*/

			SELECT @i_corporatename = corporatecontributorind
			FROM author
			WHERE authorkey = @i_authorkey


			IF @i_corporatename = 1	
				BEGIN
					SELECT @v_desc = lastname
					FROM	author
					WHERE authorkey = @i_authorkey
				END

			ELSE
				BEGIN

					SELECT @v_firstname = firstname,
						@v_desc = lastname
					FROM author
					WHERE authorkey = @i_authorkey
		 
					IF @v_firstname IS  NOT NULL 
						BEGIN
							SELECT @v_desc = @v_desc + ' ' + @v_firstname
							SELECT @v_desc = REPLACE(@v_desc,'.','')
							SELECT @v_desc = REPLACE(@v_desc,',','')
							SELECT @v_desc = REPLACE(@v_desc,'-','')
				            	END

				END
		END
	
	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = UPPER(LTRIM(RTRIM(@v_desc)))
		END

	ELSE
		BEGIN
			SELECT @RETURN = ''
		END




RETURN @RETURN


END









GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AuthorPrimaryInd]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO






CREATE FUNCTION [dbo].[qweb_get_AuthorPrimaryInd]
		(@i_bookkey		INT,
		@i_order		INT)

/*  	The qweb_get_AuthorPrimaryInd function returns a Y/N (or yes/no) value depending upon whether or not a specfic author
	has the primary indicator set on the book author table.
	if the author doesn't exist, then set the primary indicator to null
	The parameters for the function are the book key and author sort order number
*/

RETURNS	VARCHAR(1)

AS

BEGIN 
	DECLARE @i_primaryind 	INT
	DECLARE @i_authorkey 	INT
	DECLARE @v_desc		VARCHAR(1)
	DECLARE @RETURN		VARCHAR(1)

	SELECT @i_primaryind = primaryind, @i_authorkey=authorkey
	FROM bookauthor
	WHERE bookkey = @i_bookkey
		AND sortorder = @i_order

	IF @i_primaryind = 1
		BEGIN
			SELECT @v_desc = 'Y'
		END

	ELSE
		BEGIN
			IF @i_authorkey > 0
				BEGIN
					SELECT @v_desc = 'N'
				END
			ELSE
				BEGIN
					SELECT @v_desc = ''
				END
		END


	SELECT @RETURN = @v_desc


RETURN @RETURN

END







GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AuthorPrimaryKey]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_AuthorPrimaryKey] 
			(@i_bookkey	INT,
			@i_order 	INT)


RETURNS	INT

/*  The purpose of the qweb_get_AuthorPrimaryKey function is to return a specific author key for the bookkey and order number specified.
	The use of this is to get the first primary authorkey or the second or so on so that other functions can call this one
	when they need to format names, types, etc.

	returns a 0 if there is no author for the order requested
*/
AS

BEGIN

	DECLARE @RETURN			INT
	DECLARE @i_count		INT		
	DECLARE @i_primarycount		INT		
	DECLARE @i_authorkey		INT
	DECLARE @i_sortorder		INT



/* FIND OUT HOW MANY PRIMARY AUTHORS THERE ARE */

	SELECT	@i_primarycount=count(*)
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
			AND primaryind = 1
	IF @i_primarycount< @i_order -- there are less primary authors than what is requested, return a 0
		BEGIN
			SELECT @RETURN = 0
		END
	ELSE
		BEGIN

		/*  GET FIRST AUTHOR KEY 	the reason we order these descending is that the authorkey variable will be filled by the
						last in the list received
		*/
	
			SELECT 	@i_authorkey = authorkey, @i_sortorder=sortorder
					FROM bookauthor
					WHERE	bookkey = @i_bookkey
					AND primaryind = 1
					ORDER BY sortorder DESC

		
			IF @i_order =1 -- if we need to get the first author
				BEGIN
					SELECT @RETURN = @i_authorkey
		
				END
			ELSE -- if we need a subsequent author key, loop through them until you find the primary author you need
				BEGIN

					SELECT @i_count=1
					WHILE @i_count < @i_order
						BEGIN
							SELECT 	@i_authorkey = authorkey, @i_sortorder=sortorder
								FROM bookauthor
								WHERE	bookkey = @i_bookkey
								AND primaryind = 1
								AND sortorder>@i_sortorder
								ORDER BY sortorder DESC
							SELECT @i_count=@i_count+1
						END
					SELECT @RETURN = @i_authorkey

				END

		END



RETURN @RETURN


END









GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Authortype]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_Authortype]
		(@i_bookkey		INT,
		@i_order		INT,
		@v_column		VARCHAR(1))

/*  	The qweb_get_AuthorType function returns a role description for a specfic author.  The parameters for the function 
	are the book key, author sort order, and gentable descriptive column


	@v_column OPTIONS
		D = Data Description
 		E = External code
  		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/

RETURNS	VARCHAR(255)

AS

BEGIN 
	DECLARE @i_type		INT
	DECLARE @RETURN		VARCHAR(255)
	DECLARE @v_desc		VARCHAR(255)

	SELECT @i_type = authortypecode
	FROM bookauthor
	WHERE bookkey = @i_bookkey
		AND sortorder = @i_order


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 134
					AND datacode = @i_type
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 134
					AND datacode = @i_type
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 134
					AND datacode = @i_type
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 134
					AND datacode = @i_type
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 134
					AND datacode = @i_type
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 134
					AND datacode = @i_type
		END



IF LEN(@v_desc) > 0
	BEGIN
		SELECT @RETURN = @v_desc
	END
ELSE
	BEGIN
		SELECT @RETURN = ''
	END



RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_AuthorTypeBorders]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_AuthorTypeBorders] 
			(@i_bookkey	INT,
			@i_order 	INT)


RETURNS	VARCHAR (1)

/*  The purpose of the qweb_get_AuthorTypeBorders function is to return a specIFic author type for a specIFic author 
    formatted correctly for the Borders e-cat spreadsheet.  


	
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(1)
	DECLARE @v_desc			VARCHAR(1)
	DECLARE @i_authorkey		INT
	DECLARE @i_authortypecode	INT
	DECLARE @v_authortypedesc	VARCHAR(40)



/*  GET  AUTHOR KEY 	*/
	
	SELECT 	 @i_authorkey = dbo.qweb_get_AuthorPrimaryKey(@i_bookkey, @i_order)

	IF @i_authorkey = 0
		BEGIN
			SELECT @v_desc = ''
		END
	ELSE
		BEGIN
		/* GET AUTHOR TYPE		*/

			SELECT @i_authortypecode = authortypecode
			FROM bookauthor
			WHERE bookkey = @i_bookkey
			AND   authorkey = @i_authorkey

		/* GET AUTHOR TYPE DESCRIPTION FROM GENTABLES */

			SELECT @v_authortypedesc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 134
			AND datacode = @i_authortypecode

		/* TRANSLATE TO BORDERS SPECS */

			IF (RTRIM(LTRIM(@v_authortypedesc)) = 'Editor')
			OR (RTRIM(LTRIM(@v_authortypedesc)) = 'Selected by')
			OR (RTRIM(LTRIM(@v_authortypedesc)) = 'Produced by')
			   BEGIN
				SELECT @v_desc = 'E'
			   END
			ELSE IF (RTRIM(LTRIM(@v_authortypedesc)) = 'Narrated by')
				OR (RTRIM(LTRIM(@v_authortypedesc)) = 'Read by')
				   BEGIN
					SELECT @v_desc = 'R'
				   END
			ELSE IF (RTRIM(LTRIM(@v_authortypedesc)) = 'Illustrator')
				   BEGIN
					SELECT @v_desc = 'I'
				   END
			ELSE IF (RTRIM(LTRIM(@v_authortypedesc)) = 'Translator')
				   BEGIN
					SELECT @v_desc = 'T'
				   END
			ELSE IF (RTRIM(LTRIM(@v_authortypedesc)) = 'Photographer')
				   BEGIN
					SELECT @v_desc = 'P'
				   END
			ELSE IF (RTRIM(LTRIM(@v_authortypedesc)) is NULL)
				   BEGIN
					SELECT @v_desc = ''
				   END
			ELSE -- any other valid author type will be determined as an author
				   BEGIN
					SELECT @v_desc = 'A'
				   END



		END
	
	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = UPPER(LTRIM(RTRIM(@v_desc)))
		END

	ELSE
		BEGIN
			SELECT @RETURN = ''
		END




RETURN @RETURN


END









GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BackPanelCopy]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_BackPanelCopy] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_BackPanelCopy function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 3
	SELECT @i_commenttypesubcode = 3
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END










GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestAnncd1stPrint]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





CREATE FUNCTION [dbo].[qweb_get_BestAnncd1stPrint] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The qweb_get_BestAnncd1stPrint function is used to retrieve the best Announcded First Print Quantity from the printing
            table.  It returns the actual announced first print, siuess these columns are blank
             or NULL, and will use the estimated announced first print. 

            The parameters are for the book key and printing key.  

*/

RETURNS INT

AS  

BEGIN 

DECLARE @i_actfirstprint	INT
DECLARE @i_estfirstprint	INT
DECLARE @RETURN			INT





	SELECT @i_actfirstprint = announcedfirstprint,
		@i_estfirstprint = estannouncedfirstprint
	FROM   printing
	WHERE  bookkey = @i_bookkey and printingkey = @i_printingkey

		
	IF @i_actfirstprint > 0  
                BEGIN
                      SELECT @RETURN = @i_actfirstprint
                END
 	ELSE
                BEGIN
                      SELECT @RETURN = @i_estfirstprint
                END



            RETURN @RETURN

END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestDate]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_BestDate]
		(@i_bookkey	INT,
		@i_printingkey	INT,
		@i_datetype	INT)

RETURNS VARCHAR(10)

/*	The purpose of the get Best  Date function is to return the date from the Best Date column on book dates
		This function returns a character date.

	The parameters for the get Best Date are the book key and the printing key and the datetypecode from Gentables
	
*/	

AS

BEGIN

	DECLARE @RETURN		VARCHAR(10)
	DECLARE @d_date	DATETIME
	DECLARE @v_char_date	VARCHAR(10)
	
	SELECT @v_char_date = ''

	SELECT @d_date = bestdate
	FROM	bookdates
	WHERE	bookkey = @i_bookkey 
			AND printingkey = @i_printingkey
			AND datetypecode = @i_datetype


	IF COALESCE(@d_date,0) <> 0
		BEGIN
			SELECT @v_char_date = CONVERT(VARCHAR,@d_date,101)
		END
	ELSE
		BEGIN
			SELECT @v_char_date = ''
		END	


	
	SELECT @RETURN = @v_char_date	

RETURN @RETURN


END








GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestInsertIllus]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





CREATE FUNCTION [dbo].[qweb_get_BestInsertIllus] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The qweb_get_BestInsertIllus function is used to retrieve the best Announcded First Print Quantity from the printing
            table.  It returns the actual insert/illus, siuess these columns are blank
             or NULL, and will use the estimated insert/illus. 

            The parameters are for the book key and printing key.  

*/

RETURNS VARCHAR(255)

AS  

BEGIN 

DECLARE @v_actInsertIllus	VARCHAR(255)
DECLARE @v_estInsertIllus	VARCHAR(255)
DECLARE @RETURN			VARCHAR(255)





	SELECT @v_actInsertIllus = actualinsertillus,
		@v_estInsertIllus = estimatedinsertillus
	FROM   printing
	WHERE  bookkey = @i_bookkey and printingkey = @i_printingkey

		
	IF len(@v_actInsertIllus) > 0  
                BEGIN
                      SELECT @RETURN = @v_actInsertIllus
                END
 	ELSE
                BEGIN
                      SELECT @RETURN = @v_estInsertIllus
                END



            RETURN @RETURN

END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestPageCount]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





CREATE FUNCTION [dbo].[qweb_get_BestPageCount] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The qweb_get_BestPageCount function is used to retrieve the best page count from the printing
            table.  The function first checks the client options and determine where the actual page
            count is stored - either the pagecount colum or the tmmpagecount columns.  It returns the
	    actual pagecount, siuess these columns are blank, 0,or NULL - it then will use the tentativepagecount. 

            The parameters are for the book key and printing key.  

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @s_pagecount  SMALLINT   -- actual page count
DECLARE @i_options    INT           -- Variable to get where actual trim size is stored
DECLARE @RETURN       VARCHAR(23)

 
/*  Get Page Count Configuration Option: 0 set Actual Page count to pagecount column; 1 sets Actual Page Count to tmmactualpagecount column	*/
	SELECT @i_options = optionvalue
        FROM   clientoptions
        WHERE  optionid = 4

 

	IF @i_options = 0
		BEGIN
			SELECT @s_pagecount = pagecount
                	FROM   printing
                	WHERE  bookkey = @i_bookkey 
						AND printingkey = @i_printingkey
	        END

            ELSE
                BEGIN
                      SELECT @s_pagecount = tmmpagecount
                      FROM   printing
                      WHERE  bookkey = @i_bookkey 
					AND printingkey = @i_printingkey
                END
 		

	IF @s_pagecount is NULL or @s_pagecount = 0
                BEGIN
                	SELECT @s_pagecount = tentativepagecount
                        FROM   printing
                        WHERE	bookkey = @i_bookkey
                        		AND printingkey = @i_printingkey
                END


	IF @s_pagecount > 0 
	  BEGIN
		SELECT @RETURN = CAST(@s_pagecount AS VARCHAR(23))
	  END
	ELSE
	  BEGIN
		SELECT @RETURN = ''
	  END


       RETURN @RETURN

END








GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestPubDate]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_BestPubDate]
		(@i_bookkey	INT,
		@i_printingkey	INT)

RETURNS VARCHAR(10)

/*	The purpose of the get Best Pub Date function is to return the date from the Best Date column on book dates
		This function returns a character date.

	The parameters for the get Best Pub Date are the book key and the printing key	
	
*/	

AS

BEGIN

	DECLARE @RETURN		VARCHAR(10)
	DECLARE @d_pubdate	DATETIME
	DECLARE @v_char_date	VARCHAR(10)
	
	SELECT @v_char_date = ''

	SELECT @d_pubdate = bestdate
	FROM	bookdates
	WHERE	bookkey = @i_bookkey 
			AND printingkey = @i_printingkey
			AND datetypecode = 8


	IF COALESCE(@d_pubdate,0) <> 0
		BEGIN
			SELECT @v_char_date = CONVERT(VARCHAR,@d_pubdate,101)
		END
	ELSE
		BEGIN
			SELECT @v_char_date = ''
		END	


	
	SELECT @RETURN = @v_char_date	

RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestPubDate_datetime]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_BestPubDate_datetime]
		(@i_bookkey	INT,
		@i_printingkey	INT)

RETURNS DATETIME

/*	The purpose of the get Best Pub Date function is to return the date from the Best Date column on book dates
		This function returns a datetime.

	The parameters for the get Best Pub Date are the book key and the printing key	
	
*/	

AS

BEGIN

	DECLARE @RETURN		DATETIME
	DECLARE @d_pubdate	DATETIME
	DECLARE @v_char_date	DATETIME
	
	SELECT @v_char_date = ''

	SELECT @d_pubdate = bestdate
	FROM	bookdates
	WHERE	bookkey = @i_bookkey 
			AND printingkey = @i_printingkey
			AND datetypecode = 8


	IF COALESCE(@d_pubdate,0) <> 0
		BEGIN
			SELECT @v_char_date = @d_pubdate
		END
	ELSE
		BEGIN
			SELECT @v_char_date = NULL
		END	


	
	SELECT @RETURN = @v_char_date	

RETURN @RETURN


END







GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestPubDateBorders]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_BestPubDateBorders]
		(@i_bookkey	INT,
		@i_printingkey	INT)

RETURNS VARCHAR(10)

/*	The purpose of the get Best Pub Date function is to return the date from the Best Date column on book dates
		This function returns a character date.

	The parameters for the get Best Pub Date are the book key and the printing key	
	Returns date in MM/DD/YY format NOT mm/dd/yyyy
	
*/	

AS

BEGIN

	DECLARE @RETURN		VARCHAR(10)
	DECLARE @d_pubdate	DATETIME
	DECLARE @v_char_date	VARCHAR(10)
	
	SELECT @v_char_date = ''

	SELECT @d_pubdate = bestdate
	FROM	bookdates
	WHERE	bookkey = @i_bookkey 
			AND printingkey = @i_printingkey
			AND datetypecode = 8


	IF COALESCE(@d_pubdate,0) <> 0
		BEGIN
			SELECT @v_char_date = CONVERT(VARCHAR,@d_pubdate,1)
		END
	ELSE
		BEGIN
			SELECT @v_char_date = ''
		END	


	
	SELECT @RETURN = @v_char_date	

RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestReleaseDate]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_BestReleaseDate]
		(@i_bookkey	INT,
		@i_printingkey	INT)

RETURNS VARCHAR(10)

/*	The purpose of the get Best Release Date function is to return the date from the Best Date column on book dates
		This function returns a character date.

	The parameters for the get Best Pub Date are the book key and the printing key	
	
*/	

AS

BEGIN

	DECLARE @RETURN		VARCHAR(10)
	DECLARE @d_releasedate	DATETIME
	DECLARE @v_char_date	VARCHAR(10)
	
	SELECT @v_char_date = ''

	SELECT @d_releasedate = bestdate
	FROM	bookdates
	WHERE	bookkey = @i_bookkey 
			AND printingkey = @i_printingkey
			AND datetypecode = 32


	IF COALESCE(@d_releasedate,0) <> 0
		BEGIN
			SELECT @v_char_date = CONVERT(VARCHAR,@d_releasedate,101)
		END
	ELSE
		BEGIN
			SELECT @v_char_date = ''
		END	


	
	SELECT @RETURN = @v_char_date	

RETURN @RETURN


END








GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestReleaseQty]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_BestReleaseQty] 
            (@i_bookkey INT)
		

 
/*          The qweb_get_BestReleaseQty looks to the printing table and gets either the FirstPrintQuantity(actual release qty) or the 
		tentative release quantity (estimated) whichever is 'best'

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @i_actreleaseqty      INT   -- actual release quantity
DECLARE @i_estreleaseqty      INT   -- estimated release quantity
DECLARE @RETURN       VARCHAR(23)

 

       	SELECT @i_estreleaseqty = tentativeqty, @i_actreleaseqty = firstprintingqty
                FROM   printing
                WHERE  bookkey = @i_bookkey and printingkey = 1

		
            IF @i_actreleaseqty > 0
                BEGIN
 			SELECT @RETURN = CAST(@i_actreleaseqty as varchar (23)) 
                END
	    ELSE IF @i_estreleaseqty > 0
		BEGIN
			SELECT @RETURN = CAST(@i_estreleaseqty as varchar (23))
		END
	    ELSE
		BEGIN
			SELECT @RETURN = ''
		END
            RETURN @RETURN

END





GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestShipDate]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_BestShipDate]
		(@i_bookkey	INT,
		@i_printingkey	INT,
		@i_yearchars	INT)

RETURNS VARCHAR(10)

/*	The purpose of the get Best Ship Date function is to create a date type that typically doesn't exist in our client's minds.
	This is specifically necessary for the Borders spreadsheet, but has other uses as well.  The rules for creating the ship date are:
	1.  The ship date is the Release Date if the release date exists, and it is not equal to the pub date
	2.  If the release date does not exist or is the same as the Pub date, then the ship date will be the pub date - 30 days
	3.  If the Pub Date doesn't exist, then the ship date can't exist either.

	The parameters for the get Best Pub Date are the book key and the printing key and the # of characters in the Year.

	Note: Borders requires MM/DD/YY and most other applications will want MM/DD/YYYY
	


*/	

AS

BEGIN

	DECLARE @RETURN		VARCHAR(10)
	DECLARE @d_releasedate	DATETIME
	DECLARE @v_char_date	VARCHAR(10)
	DECLARE @v_releasedate	VARCHAR(10)
	DECLARE @v_pubdate	VARCHAR(10)
	DECLARE @v_pubdateYYYYMMDD VARCHAR (8)
	DECLARE @v_shipdateYYYYMMDD VARCHAR (8)
	DECLARE @d_shipdate 	DATETIME
	DECLARE @i_startpos	INT
	
	IF @i_yearchars = 2
		BEGIN
			SELECT @i_startpos = 3
		END
	ELSE -- if it's 4
		BEGIN
			SELECT @i_startpos = 1
		END

/* Get Pub Date and Release Date */

	SELECT @v_pubdate=dbo.qweb_get_BestPubDate(@i_bookkey, @i_printingkey)
	SELECT @v_releasedate=dbo.qweb_get_BestReleaseDate(@i_bookkey, @i_printingkey)



	IF @v_pubdate = ''
		BEGIN
			SELECT @v_char_date = ''
		END
	ELSE IF (@v_releasedate = '')
	     OR (@v_releasedate = @v_pubdate)  -- set ship date (Pub date -30)
		BEGIN
			SELECT @v_pubdateYYYYMMDD = SUBSTRING(@v_pubdate,7,4) + SUBSTRING (@v_pubdate,1,2) + SUBSTRING (@v_pubdate,4,2)
			SELECT @d_shipdate = DATEADD(day, -30, @v_pubdateYYYYMMDD) 
			SELECT @v_char_date = CAST(MONTH(@d_shipdate) as VARCHAR (2)) + '/' +
						CAST(DAY(@d_shipdate) as VARCHAR (2)) + '/' +
						SUBSTRING (CAST(YEAR(@d_shipdate) as VARCHAR(4)),@i_startpos,@i_yearchars) 
		END
	ELSE
		BEGIN
			SELECT @v_char_date = @v_releasedate
		END


	IF LEN(@v_char_date) > 0
		BEGIN
			SELECT @RETURN = @v_char_date	
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END	


	


RETURN @RETURN


END








GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestStockDueDate]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_BestStockDueDate]
		(@i_bookkey	INT,
		@i_printingkey	INT)

RETURNS VARCHAR(10)

/*	The purpose of the get Best Stock Due Date function is to return the date from the Best Date column on book dates
		This function returns a character date.

	The parameters for the get Best Stock Due Date are the book key and the printing key	
	
*/	

AS

BEGIN

	DECLARE @RETURN		VARCHAR(10)
	DECLARE @d_stockdue	DATETIME
	DECLARE @v_char_date	VARCHAR(10)
	
	SELECT @v_char_date = ''

	SELECT @d_stockdue = bestdate
	FROM	bookdates
	WHERE	bookkey = @i_bookkey 
			AND printingkey = @i_printingkey
			AND datetypecode = 419


	IF @d_stockdue is NOT NULL
		BEGIN
			SELECT @v_char_date = CONVERT(VARCHAR,@d_stockdue,101)
		END
	ELSE
		BEGIN
			SELECT @v_char_date = ''
		END	


	
	SELECT @RETURN = @v_char_date	

RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestTrimDimension]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_BestTrimDimension] 
           (@i_bookkey INT,
            @i_printingkey INT,
		@v_dimension varchar(1)) 

		

 
/*          The qweb_get_BestTrimDimension function is used to retrieve the best trim Length or Width from the printing
            table.  The function first checks the client options and determine where the actual trim
            size is stored - either the trim width/length colums or the tmm actual width/length 
            columns.  It returns the  the actual trim, siuess these columns are blank
             or NULL, and will use the estimated trim. 

            The parameters are for the book key and printing key and dimension where the valid values are:
		'W' - Width
		'L' - Height or length
		'S' - Spine Size

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @v_width      VARCHAR(10)   --  trim width
DECLARE @v_length     VARCHAR(10)   --  trim length
DECLARE @v_spine      VARCHAR(15)   -- spine size
DECLARE @i_options    INT           -- Variable to get where actual trim size is stored
DECLARE @RETURN       VARCHAR(23)


 	SET @v_width = ''
	SET @v_length=''
	SET @v_spine=''

	SELECT @i_options = optionvalue
        FROM   clientoptions
        WHERE  optionid = 7

 

	IF @i_options = 0
            BEGIN
            	SELECT @v_width = ltrim(rtrim(trimsizewidth)),
			@v_length = ltrim(rtrim(trimsizelength))
                FROM   printing
                WHERE  bookkey = @i_bookkey and printingkey = @i_printingkey

		
            END

         ELSE
             BEGIN
                  SELECT @v_width = ltrim(rtrim(tmmactualtrimwidth)),
                             @v_length = ltrim(rtrim(tmmactualtrimlength))
                  FROM   printing
                  WHERE  bookkey = @i_bookkey 
					AND printingkey = @i_printingkey
             END
 		

         IF (@v_width= '')or (@v_width is null) OR (@v_length='') or (@v_length is null) -- get estimated columns
             BEGIN
               	SELECT @v_width = ltrim(rtrim(esttrimsizewidth)),
                             	@v_length = ltrim(rtrim(esttrimsizelength))
                FROM   printing
                WHERE	bookkey = @i_bookkey
                        		AND printingkey = @i_printingkey
             END



        IF @v_dimension = 'W'
		BEGIN
			SELECT @RETURN = @v_width 
		END
	ELSE IF @v_dimension = 'L'
		BEGIN
			SELECT @RETURN = @v_length 
		END
	ELSE IF @v_dimension = 'S'
		BEGIN
 
 	               	SELECT @v_spine = ltrim(rtrim(spinesize))
		                        FROM   printing
 		                       WHERE	bookkey = @i_bookkey
 		                       		AND printingkey = @i_printingkey
			SELECT @RETURN = @v_spine 
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'invalid parameter' 
		END
 
            RETURN @RETURN


END















GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestTrimSize]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





CREATE FUNCTION [dbo].[qweb_get_BestTrimSize] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The qweb_get_BestTrimSize function is used to retrieve the best trim size from the printing
            table.  The function first checks the client options and determine where the actual trim
            size is stored - either the trim width/length colums or the tmm actual width/length 
            columns.  It returns the  the actual trim, siuess these columns are blank
             or NULL, and will use the estimated trim. 

            The parameters are for the book key and printing key.  

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @v_width      VARCHAR(10)   -- actual trim width
DECLARE @v_length     VARCHAR(10)   -- actual trim length
DECLARE @v_x          VARCHAR(3)    -- Constant ' x ' for concatenating width and length
DECLARE @i_options    INT           -- Variable to get where actual trim size is stored
DECLARE @RETURN       VARCHAR(23)

 

	SELECT @v_x = ' x '

	SELECT @i_options = optionvalue
        FROM   clientoptions
        WHERE  optionid = 7

 

	IF @i_options = 0
            BEGIN
            	SELECT @v_width = ltrim(rtrim(trimsizewidth)),
			@v_length = ltrim(rtrim(trimsizelength))
                FROM   printing
                WHERE  bookkey = @i_bookkey and printingkey = @i_printingkey

		
            END

            ELSE
                BEGIN
                      SELECT @v_width = ltrim(rtrim(tmmactualtrimwidth)),
                             @v_length = ltrim(rtrim(tmmactualtrimlength))
                      FROM   printing
                      WHERE  bookkey = @i_bookkey 
					AND printingkey = @i_printingkey
                END
 		

            IF @v_width<> '' OR @v_length<>''
                BEGIN
                	SELECT @RETURN = @v_width + ' x ' +@v_length
                END

            ELSE
                BEGIN
                	SELECT @RETURN = ltrim(rtrim(esttrimsizewidth))+ @v_x + ltrim(rtrim(esttrimsizelength))
                        FROM   printing
                        WHERE	bookkey = @i_bookkey
                        		AND printingkey = @i_printingkey
                END

            RETURN @RETURN

END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestUSPrice]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_BestUSPrice] 
            	(@i_bookkey 	INT,
            	@i_pricetype	INT)
		

 
/*      The qweb_get_BestUSPrice function is used to retrieve the best price size from the book price
        table.  The function first determines if an actual price is stored, it will return the actual 
	if greater than zero, otherwise it will return the estimated.

            The parameters are for the book key and printing key.  

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @f_budgetprice      	FLOAT
DECLARE @f_finalprice     	FLOAT
DECLARE @RETURN       		VARCHAR(23)

 

SELECT @f_budgetprice = budgetprice,
	@f_finalprice = finalprice
FROM bookprice
WHERE bookkey = @i_bookkey 
	AND pricetypecode = @i_pricetype 
	AND currencytypecode = 6  -- US Dollars
	AND activeind = 1


 

	IF @f_finalprice > 0
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_finalprice) AS VARCHAR(23))
		END	
	ELSE IF @f_budgetprice > 0
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_budgetprice) AS VARCHAR(23))
		END	
	ELSE -- IF @f_budgetprice = NULL OR @f_budgetprice = 0
		BEGIN
			SELECT @RETURN = ''
		END	
		

RETURN @RETURN

END










GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestUSPrice_EffDate]    Script Date: 03/02/2011 15:36:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO










CREATE FUNCTION [dbo].[qweb_get_BestUSPrice_EffDate] 
            	(@i_bookkey 	INT,
            	@i_pricetype	INT)
		

 
/*      The qweb_get_BestUSPrice function is used to retrieve the best price size from the book price
        table.  The function first determines if an actual price is stored, it will return the actual 
	if greater than zero, otherwise it will return the estimated.

            The parameters are for the book key and price type.  

*/

RETURNS VARCHAR(10)

AS  

BEGIN 

DECLARE @d_effectivedate	DATETIME
DECLARE @RETURN       		VARCHAR(10)

 

SELECT @d_effectivedate = effectivedate
FROM bookprice
WHERE bookkey = @i_bookkey 
	AND pricetypecode = @i_pricetype 
	AND currencytypecode = 6  -- US Dollars
	AND activeind = 1


 

	IF COALESCE(@d_effectivedate,0)<> 0
		BEGIN
			SELECT @RETURN = CONVERT(VARCHAR,@d_effectivedate,101)
		END	
	ELSE 
		BEGIN
			SELECT @RETURN = ''
		END

		

RETURN @RETURN

END











GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestUSPriceAndType]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






CREATE FUNCTION [dbo].[qweb_get_BestUSPriceAndType] 
            	(@i_bookkey 	INT)
          
		

 
/*      The qweb_get_BestUSPriceAndType function is used to retrieve the best price  from the book price
        table that is in US Dollars.  The function first determines if an actual price is stored, it will return the actual 
	if greater than zero, otherwise it will return the estimated.  
	It is assumed by the user of this function that there will only be 1 US Price type, but it may differ by publisher

            The parameters are for the book key.  

*/

RETURNS FLOAT

AS  

BEGIN 

DECLARE @f_budgetprice      	FLOAT

DECLARE @f_finalprice     	FLOAT
DECLARE @RETURN       		NUMERIC(9,2)

 

SELECT @f_budgetprice = budgetprice,
	@f_finalprice = finalprice
FROM bookprice
WHERE bookkey = @i_bookkey 
	AND currencytypecode = 6  -- US Dollars
	AND activeind = 1


 

	IF @f_finalprice > 0
		BEGIN
			SELECT @RETURN = CONVERT(NUMERIC(9,2),@f_finalprice)
		END	
	ELSE IF @f_budgetprice > 0
		BEGIN
			SELECT @RETURN = @f_budgetprice
		END	
	ELSE IF @f_budgetprice = NULL OR @f_budgetprice = 0
		BEGIN
			SELECT @RETURN = 0
		END	
		

RETURN @RETURN

END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BisacStatus]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_BisacStatus]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_BisacStatus function is to return a specific description column from gentables for a BisacStatus

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_BisacStatusCode	INT
	
	SELECT @i_BisacStatusCode = bisacstatuscode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 314
					AND datacode = @i_BisacStatusCode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 314
					AND datacode = @i_BisacStatusCode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 314
					AND datacode = @i_BisacStatusCode
		
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 314
					AND datacode = @i_BisacStatusCode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 314
					AND datacode = @i_BisacStatusCode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 314
					AND datacode = @i_BisacStatusCode
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BisacStatus_SubGentableLevel]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[qweb_get_BisacStatus_SubGentableLevel]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1) )

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_BisacStatus function is to return a specific description column from gentables for a BisacStatus

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_BisacStatusCode	INT
	DECLARE @i_BisacStatusSubCode INT
	
	SELECT @i_BisacStatusCode = bisacstatuscode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey

	SELECT @i_BisacStatusSubCode = prodavailability
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey

	IF LEN(@i_BisacStatusSubCode) > 0
		BEGIN

			IF @v_column = 'D'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	subgentables  
					WHERE  tableid = 314
							AND datacode = @i_BisacStatusCode
							AND datasubcode = @i_BisacStatusSubCode
				END

			ELSE IF @v_column = 'E'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(externalcode))
					FROM	subgentables  
					WHERE  tableid = 314
							AND datacode = @i_BisacStatusCode
							AND datasubcode = @i_BisacStatusSubCode
				END

			ELSE IF @v_column = 'S'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadescshort))
					FROM	subgentables  
					WHERE  tableid = 314
							AND datacode = @i_BisacStatusCode
							AND datasubcode = @i_BisacStatusSubCode
				END

			ELSE IF @v_column = 'B'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
					FROM	subgentables  
					WHERE  tableid = 314
							AND datacode = @i_BisacStatusCode
							AND datasubcode = @i_BisacStatusSubCode
				END

			ELSE IF @v_column = '1'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
					FROM	subgentables  
					WHERE  tableid = 314
							AND datacode = @i_BisacStatusCode
							AND datasubcode = @i_BisacStatusSubCode
				END

			ELSE IF @v_column = '2'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	subgentables  
					WHERE  tableid = 314
							AND datacode = @i_BisacStatusCode
							AND datasubcode = @i_BisacStatusSubCode
				END

		END
	ELSE
		BEGIN

					IF @v_column = 'D'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(datadesc))
				FROM	gentables  
				WHERE  tableid = 314
						AND datacode = @i_BisacStatusCode
			END

		ELSE IF @v_column = 'E'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(externalcode))
				FROM	gentables  
				WHERE  tableid = 314
						AND datacode = @i_BisacStatusCode
			END

		ELSE IF @v_column = 'S'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(datadescshort))
				FROM	gentables  
				WHERE  tableid = 314
						AND datacode = @i_BisacStatusCode
			END

		ELSE IF @v_column = 'B'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
				FROM	gentables  
				WHERE  tableid = 314
						AND datacode = @i_BisacStatusCode
			END

		ELSE IF @v_column = '1'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
				FROM	gentables  
				WHERE  tableid = 314
						AND datacode = @i_BisacStatusCode
			END

		ELSE IF @v_column = '2'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(datadesc))
				FROM	gentables  
				WHERE  tableid = 314
						AND datacode = @i_BisacStatusCode
			END
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END







GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BisacSubject]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_BisacSubject]
		(@i_bookkey	INT,
		@i_order	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(510)

/*	The purpose of the qweb_get_BisacSubject function is to return a specific descriptive column from gentables/subgentables for a BISAC Subject.  
	When the @v_column = 'D', then the function will build the description from the gentable/subgentable combination.  All other options will 
	only return the subgentables values.

	Parameter Options

		Order
			1 = Returns first BISAC Subject
			2 = Returns second BISAC Subject
			3 = Returns third BISAC Subject
			4
			5
			.
			.
			.
			n			

		Column
			D = Data Description
			E = External code
			S = Short Description
			B = BISAC Data Code
			T = Eloquence Field Tag
			1 = Alternative Description 1
			2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(500)
	DECLARE @v_desc			VARCHAR(500)
	DECLARE @i_bisaccode		INT
	DECLARE @i_bisacsubcode		INT

	SELECT @i_bisaccode = bisaccategorycode,
		@i_bisacsubcode = bisaccategorysubcode
	FROM	bookbisaccategory
	WHERE	bookkey = @i_bookkey and sortorder = @i_order


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(dbo.proper_case(g.datadesc)))+'/'+LTRIM(RTRIM(s.datadesc))
			FROM gentables g, subgentables s
			WHERE g.tableid = 339 
					AND s.tableid = 339 
					AND g.datacode = @i_bisaccode
					AND s.datacode = @i_bisaccode
					AND s.datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	subgentables  
			WHERE  tableid = 339
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	subgentables  
			WHERE  tableid = 339
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	subgentables  
			WHERE  tableid = 339
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	subgentables  
			WHERE  tableid = 339
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	subgentables  
			WHERE  tableid = 339
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END







GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BNAuthor]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






CREATE FUNCTION [dbo].[qweb_get_BNAuthor] 
			(@i_bookkey	INT)


RETURNS	VARCHAR(120)

/*  The purpose of the qweb_get_BNAuthor functions is to return a specific author name 
    formatted correctly for the BN buy sheet.  It gets the first author on the bookauthor that is primary
	and checks the author type.  if the author type is anything other than an author, then it 
	will append the author type in '()' to the author name, which will be formatted as Lastname, Firstname, MI

	
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(120)
	DECLARE @v_desc			VARCHAR(80)
	DECLARE @v_authortypedesc	VARCHAR(40)
	DECLARE @i_count		INT		
	DECLARE @i_authorkey		INT
	DECLARE @i_authortypecode	INT
	DECLARE @v_firstname		VARCHAR(40)
	DECLARE @v_middlename		VARCHAR(20)
	DECLARE @v_lastname		VARCHAR(40)
	DECLARE @v_nameabbrev		VARCHAR(10)
	DECLARE @v_suffix		VARCHAR(10)
	DECLARE @i_corporatename	INT


/*  GET AUTHOR KEY FOR AUTHOR TYPE and ORDER 	*/
	
	SELECT 	distinct @i_authorkey = authorkey, @i_authortypecode = authortypecode
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
			AND primaryind = 1

		


/* GET AUTHOR NAME		*/

	SELECT @i_corporatename = corporatecontributorind
	FROM author
	WHERE authorkey = @i_authorkey


	IF @i_corporatename = 1	
		BEGIN
			SELECT @v_desc = lastname
			FROM	author
			WHERE authorkey = @i_authorkey
		END

	ELSE
		BEGIN

			SELECT @v_firstname = firstname,
				@v_middlename = middlename,
				@v_desc = lastname,
				@v_suffix = authorsuffix
			FROM author
			WHERE authorkey = @i_authorkey
		 
			IF @v_firstname IS  NOT NULL 
				BEGIN
					SELECT @v_desc = @v_desc + ', ' + @v_firstname
	            		END

			IF @v_middlename IS  NOT NULL 
				BEGIN
					SELECT @v_desc = @v_desc + ' ' + @v_middlename
	            		END

			IF @i_authortypecode <> 12 -- If the author type is not an 'Author' then put it in parenthesis 
				BEGIN
					SELECT @v_authortypedesc = LTRIM(RTRIM(datadesc))
					FROM	gentables  
					WHERE  tableid = 134
					AND datacode = @i_authortypecode

					SELECT @v_desc = @v_desc + ' (' + @v_authortypedesc + ')'
	            		END



		END


		IF LEN(@v_desc) > 0
			BEGIN
				SELECT @RETURN = LTRIM(RTRIM(@v_desc))
			END

			ELSE
				BEGIN
					SELECT @RETURN = ''
				END




RETURN @RETURN


END







GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_book_lastmaintdate]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[qweb_get_book_lastmaintdate] (
    @i_bookkey  INT)
  
  RETURNS datetime
  
AS
BEGIN
  DECLARE 
    @v_lastmaintdate  datetime,
    @v_returndate  datetime
    

  select @v_returndate=lastmaintdate from book where bookkey=@i_bookkey  

  select @v_lastmaintdate=lastmaintdate from bookdetail where bookkey=@i_bookkey  
  if @v_lastmaintdate>@v_returndate and @v_lastmaintdate is not null
    begin
      set @v_returndate=@v_lastmaintdate
    end 

  select top 1 @v_lastmaintdate =  lastmaintdate from bookcomments where bookkey=@i_bookkey order by lastmaintdate desc
  if @v_lastmaintdate>@v_returndate and @v_lastmaintdate is not null
    begin
      set @v_returndate=@v_lastmaintdate
    end 

  select top 1 @v_lastmaintdate =  lastmaintdate from bookbisaccategory  where bookkey=@i_bookkey order by lastmaintdate desc
  if @v_lastmaintdate>@v_returndate and @v_lastmaintdate is not null
    begin
      set @v_returndate=@v_lastmaintdate
    end 

  select top 1 @v_lastmaintdate =  lastmaintdate from bookprice where bookkey=@i_bookkey order by lastmaintdate desc
  if @v_lastmaintdate>@v_returndate and @v_lastmaintdate is not null
    begin
      set @v_returndate=@v_lastmaintdate
    end 

  select top 1 @v_lastmaintdate =  lastmaintdate from bookauthor where bookkey=@i_bookkey order by lastmaintdate desc
  if @v_lastmaintdate>@v_returndate and @v_lastmaintdate is not null
    begin
      set @v_returndate=@v_lastmaintdate
    end 

  select top 1 @v_lastmaintdate =  a.lastmaintdate
    from bookauthor ba, author a
    where ba.bookkey=@i_bookkey
      and ba.authorkey=a.authorkey
    order by a.lastmaintdate desc
  if @v_lastmaintdate>@v_returndate and @v_lastmaintdate is not null
    begin
      set @v_returndate=@v_lastmaintdate
    end 

  RETURN @v_returndate 
END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BookCategory_List]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_BookCategory_List]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(512)

/*	The purpose of the qweb_get_BookCategory_List function is to return a specific description column from gentables for a BisacStatus

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(512)
	DECLARE @v_desc			VARCHAR(512)
	DECLARE @v_CategoryDesc			VARCHAR(512)
	DECLARE @i_CategoryCode	INT
	DECLARE @i_fetchstatus	INT
	
  DECLARE c_bookcategory CURSOR fast_forward FOR

	select categorycode
	from bookcategory
	where bookkey = @i_bookkey
			
	OPEN c_bookcategory 

	FETCH NEXT FROM c_bookcategory 
		INTO @i_CategoryCode

	 select  @i_fetchstatus  = @@FETCH_STATUS

	 while (@i_fetchstatus >-1 ) begin
		IF (@i_fetchstatus <>-2) begin		 
	    IF @v_column = 'D'
		    BEGIN
			    SELECT @v_desc = LTRIM(RTRIM(datadesc))
			    FROM	gentables  
			    WHERE  tableid = 317
					    AND datacode = @i_CategoryCode
				END

	    ELSE IF @v_column = 'E'
		    BEGIN
			    SELECT @v_desc = LTRIM(RTRIM(externalcode))
			    FROM	gentables  
			    WHERE  tableid = 317
					    AND datacode = @i_CategoryCode
		    END

	    ELSE IF @v_column = 'S'
		    BEGIN
			    SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			    FROM	gentables  
			    WHERE  tableid = 317
					    AND datacode = @i_CategoryCode
    		
		    END

	    ELSE IF @v_column = 'B'
		    BEGIN
			    SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			    FROM	gentables  
			    WHERE  tableid = 317
					    AND datacode = @i_CategoryCode
		    END

	    ELSE IF @v_column = '1'
		    BEGIN
			    SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			    FROM	gentables  
			    WHERE  tableid = 317
					    AND datacode = @i_CategoryCode
		    END

	    ELSE IF @v_column = '2'
		    BEGIN
			    SELECT @v_desc = LTRIM(RTRIM(datadesc))
			    FROM	gentables  
			    WHERE  tableid = 317
					    AND datacode = @i_CategoryCode
		    END
      
      if @v_CategoryDesc is null OR ltrim(rtrim(@v_CategoryDesc)) = '' begin
        SET @v_CategoryDesc = @v_desc
      end
      else begin
        SET @v_CategoryDesc = @v_CategoryDesc + ',' + @v_desc
      end
    END
      
  	FETCH NEXT FROM c_bookcategory 
	    INTO @i_CategoryCode

    select  @i_fetchstatus  = @@FETCH_STATUS
  end

	close c_bookcategory
	deallocate c_bookcategory



	IF LEN(@v_CategoryDesc) > 0
		BEGIN
			SELECT @RETURN = @v_CategoryDesc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END





GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BordersTitle]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO






CREATE FUNCTION [dbo].[qweb_get_BordersTitle] (
		@i_bookkey	INT)
	
/*	Creates the title field the way that Borders wants to see it, with the formatting and abbreviating in place
*/
	RETURNS VARCHAR(255)
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(80)
	DECLARE @in_formatbisaccode 	VARCHAR(10)
	DECLARE @in_titlewithoutprefix 	VARCHAR(255)
	DECLARE @out_title		VARCHAR(80)
	DECLARE @in_editionnumber 	DECIMAL(10, 2)
	DECLARE @out_edition 	VARCHAR (5)

select @out_title = ''
select @out_edition = ''

select @in_titlewithoutprefix=dbo.qweb_get_Title(@i_bookkey, 'T')


select @in_formatbisaccode=dbo.qweb_get_Format(@i_bookkey, 'T')


-- set prefix
		if (@in_formatbisaccode = 'BX')
		or (@in_formatbisaccode = 'WX')
		   begin
			select @out_title = 'BOXED/ '
		   end
		else if (@in_formatbisaccode = 'PD')
	             or (@in_formatbisaccode = 'WL')
	             or (@in_formatbisaccode = 'DK')
		        begin
         		 	select @out_title = 'CAL '
		        end
		else if (@in_formatbisaccode = 'DA')
	             or (@in_formatbisaccode = 'AA')
		        begin
         		 	select @out_title = 'CAS '
		        end
		else if (@in_formatbisaccode = 'CD')
		        begin
         		 	select @out_title = 'CD '
		        end
		else 
		        begin
         		 	select @out_title = ''
		        end

		if substring(@in_titlewithoutprefix, 1, 4) = 'The '
			begin
				select @in_titlewithoutprefix = substring(@in_titlewithoutprefix, 5, 251)
			end

-- set title abbreviations

		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,',','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'?','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'.','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,':','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,';','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'"','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'/',' ')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'-',' ')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'(','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,')','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'!','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,' and ',' & ')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,' And ',' & ')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Book','BK')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Artificial Intelligence','AI')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Adventures','ADV')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Adventure','ADV')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Americans','AMER')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'American','AMER')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Americas','AMER')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'America','AMER')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Assorted','ASST')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Austrailia','AUST')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Autobiographical','AUTOB')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Autobiography','AUTOB')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Bed & Breakfast','B&B')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Better Homes & Gardens','BHG')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Collection','COLL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Collected','COLL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Complete','COMPL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Dungeons & Dragons','D&D')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Department','DEPT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Dictionary','DICT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Doctor','DR')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Encyclopedia','ENCY')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Encyclopedic','ENCY')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Field Guide','F GD')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Official Price Guide','OPG')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Price Guide','P GD')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Guide','GD')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Housekeeping','HSKG')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Government','GOVT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'History','HIST')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Histories','HIST')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'How To','HT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Illustrated','ILLUS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Illustration','ILLUS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Illustrator','ILLUS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'International','INTL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Introduction','INTRO')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Keyboard','KEYBD')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Literature','LIT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Metropolitan','MET')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Management','MGMT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Mystery','MYST')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Microsoft','MS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'National','NATL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'New York Times','NYT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Orchestra','ORCH')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Pictures','PICT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Picture','PICT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Pictoral','PICT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Organ','ORG')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Overture','OVT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Percussion','PERC')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Philharmonic','PHIL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Piano','PNO')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Prelude','PRE')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Qustions & Answers','Q&A')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Quintet','QNT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Quartet','QRT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Rhapsody','RHAPS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Simon & Schuster','S&S')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Saxophone','SAX')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Science Fiction & Fantasy','SF&F')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Science Fiction','SCI FI')

		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Selections','SEL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Selection','SEL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Selective','SEL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Selected','SEL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Select','SEL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Suite','STE')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Symphony','SYM')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Transcriptions','TRANS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Teach Yourself','TYS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Unaccompanied','UNACCOMP')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'United States','US')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'World War','WW')

		select @out_title = @out_title + UPPER (@in_titlewithoutprefix)

-- set post fix
		if (@in_formatbisaccode = 'H3')
		   begin
			select @out_title = @out_title + '-DOS'
		   end
		else if (@in_formatbisaccode = 'MH')
		        begin
         		 	select @out_title = @out_title + '-MAC'
		        end

/*		if @in_editionnumber > 0
		   begin
			select @out_edition = CAST(@in_editionnumber as varchar(5))
			select @out_edition = RTRIM(REPLACE(@out_edition, '.00', ''))
			select @out_title = @out_title + '-E' + SUBSTRING(@out_edition, 1, 2)
		   end
*/


	select @RETURN = @out_title



  RETURN @RETURN
END










GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BriefDescription]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





CREATE FUNCTION [dbo].[qweb_get_BriefDescription] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_BriefDescription function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 3
	SELECT @i_commenttypesubcode = 7
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CanadianRestriction]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_CanadianRestriction]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_CanadianRestriction function is to restriction a specific description column from gentables for a  Canadian restriction Code

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_canadianrestrictioncode		INT

	SELECT @v_desc = ''
	
	SELECT @i_canadianrestrictioncode = canadianrestrictioncode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey
	

IF @i_canadianrestrictioncode > 0
	BEGIN
	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 428
					AND datacode = @i_canadianrestrictioncode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 428
					AND datacode = @i_canadianrestrictioncode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 428
					AND datacode = @i_canadianrestrictioncode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 428
					AND datacode = @i_canadianrestrictioncode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 428
					AND datacode = @i_canadianrestrictioncode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 428
					AND datacode = @i_canadianrestrictioncode
		END
	END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END











GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CartonQty]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO






CREATE FUNCTION [dbo].[qweb_get_CartonQty] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The qweb_get_CartonQty function is used to retrieve the Carton Quantity from the Binding Specs
            table.   

            The parameters are for the book key and printing key.  

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @i_cartonqty  	INT
DECLARE @RETURN		VARCHAR(23)




	
	SELECT @i_cartonqty = cartonqty1
	FROM   bindingspecs
	WHERE  bookkey = @i_bookkey and printingkey = @i_printingkey

		
	IF @i_cartonqty > 0  
                BEGIN
                      SELECT @RETURN = CAST(@i_cartonqty AS VARCHAR(23))
                END
 	ELSE
                BEGIN
                      SELECT @RETURN = ''
                END



            RETURN @RETURN

END







GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Comment_TitleError]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






CREATE FUNCTION [dbo].[qweb_get_Comment_TitleError] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The Comment_TitleError function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 4
	SELECT @i_commenttypesubcode = 9
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END











GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomCode01]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_CustomCode01]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_CustomCode01 function is to return a specific description column from gentables for a CustomCode01

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_CustomCode01		INT
	
	SELECT @i_CustomCode01 = CustomCode01
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 417
					AND datacode = @i_CustomCode01
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 417
					AND datacode = @i_CustomCode01
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 417
					AND datacode = @i_CustomCode01
		
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 417
					AND datacode = @i_CustomCode01
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 417
					AND datacode = @i_CustomCode01
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 417
					AND datacode = @i_CustomCode01
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomCode02]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_CustomCode02]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_CustomCode02 function is to return a specific description column from gentables for a CustomCode02

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_CustomCode02		INT
	
	SELECT @i_CustomCode02 = CustomCode02
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 418
					AND datacode = @i_CustomCode02
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 418
					AND datacode = @i_CustomCode02
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 418
					AND datacode = @i_CustomCode02
		
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 418
					AND datacode = @i_CustomCode02
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 418
					AND datacode = @i_CustomCode02
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 418
					AND datacode = @i_CustomCode02
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomCode03]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_CustomCode03]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_CustomCode03 function is to return a specific description column from gentables for a CustomCode03

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_CustomCode03		INT
	
	SELECT @i_CustomCode03 = CustomCode03
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 419
					AND datacode = @i_CustomCode03
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 419
					AND datacode = @i_CustomCode03
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 419
					AND datacode = @i_CustomCode03
		
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 419
					AND datacode = @i_CustomCode03
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 419
					AND datacode = @i_CustomCode03
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 419
					AND datacode = @i_CustomCode03
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomCode04]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_CustomCode04]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_CustomCode04 function is to return a specific description column from gentables for a CustomCode04

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_CustomCode04		INT
	
	SELECT @i_CustomCode04 = CustomCode04
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 420
					AND datacode = @i_CustomCode04
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 420
					AND datacode = @i_CustomCode04
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 420
					AND datacode = @i_CustomCode04
		
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 420
					AND datacode = @i_CustomCode04
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 420
					AND datacode = @i_CustomCode04
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 420
					AND datacode = @i_CustomCode04
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomCode05]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_CustomCode05]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_CustomCode05 function is to return a specific description column from gentables for a CustomCode05

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_CustomCode05		INT
	
	SELECT @i_CustomCode05 = CustomCode05
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 421
					AND datacode = @i_CustomCode05
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 421
					AND datacode = @i_CustomCode05
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 421
					AND datacode = @i_CustomCode05
		
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 421
					AND datacode = @i_CustomCode05
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 421
					AND datacode = @i_CustomCode05
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 421
					AND datacode = @i_CustomCode05
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomCode06]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_CustomCode06]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_CustomCode06 function is to return a specific description column from gentables for a CustomCode06

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_CustomCode06		INT
	
	SELECT @i_CustomCode06 = CustomCode06
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 422
					AND datacode = @i_CustomCode06
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 422
					AND datacode = @i_CustomCode06
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 422
					AND datacode = @i_CustomCode06
		
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 422
					AND datacode = @i_CustomCode06
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 422
					AND datacode = @i_CustomCode06
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 422
					AND datacode = @i_CustomCode06
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomCode07]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_CustomCode07]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_CustomCode07 function is to return a specific description column from gentables for a CustomCode07

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_CustomCode07		INT
	
	SELECT @i_CustomCode07 = CustomCode07
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 423
					AND datacode = @i_CustomCode07
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 423
					AND datacode = @i_CustomCode07
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 423
					AND datacode = @i_CustomCode07
		
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 423
					AND datacode = @i_CustomCode07
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 423
					AND datacode = @i_CustomCode07
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 423
					AND datacode = @i_CustomCode07
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomCode08]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_CustomCode08]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_CustomCode08 function is to return a specific description column from gentables for a CustomCode08

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_CustomCode08		INT
	
	SELECT @i_CustomCode08 = CustomCode08
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 424
					AND datacode = @i_CustomCode08
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 424
					AND datacode = @i_CustomCode08
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 424
					AND datacode = @i_CustomCode08
		
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 424
					AND datacode = @i_CustomCode08
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 424
					AND datacode = @i_CustomCode08
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 424
					AND datacode = @i_CustomCode08
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomCode09]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_CustomCode09]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_CustomCode09 function is to return a specific description column from gentables for a CustomCode09

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_CustomCode09		INT
	
	SELECT @i_CustomCode09 = CustomCode09
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 425
					AND datacode = @i_CustomCode09
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 425
					AND datacode = @i_CustomCode09
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 425
					AND datacode = @i_CustomCode09
		
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 425
					AND datacode = @i_CustomCode09
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 425
					AND datacode = @i_CustomCode09
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 425
					AND datacode = @i_CustomCode09
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomCode10]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_CustomCode10]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_CustomCode10 function is to return a specific description column from gentables for a CustomCode10

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_CustomCode10		INT
	
	SELECT @i_CustomCode10 = CustomCode10
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 426
					AND datacode = @i_CustomCode10
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 426
					AND datacode = @i_CustomCode10
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 426
					AND datacode = @i_CustomCode10
		
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 426
					AND datacode = @i_CustomCode10
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 426
					AND datacode = @i_CustomCode10
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 426
					AND datacode = @i_CustomCode10
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomFloat01]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [dbo].[qweb_get_CustomFloat01]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomFloat01 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @f_float			FLOAT
	
	SELECT @f_float = customfloat01
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @f_float > 0
		BEGIN
			SELECT @RETURN = CAST(CAST(@f_float as  NUMERIC (9,2)) as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomFloat02]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomFloat02]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomFloat02 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @f_float			FLOAT
	
	SELECT @f_float = customfloat02
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @f_float > 0
		BEGIN
			SELECT @RETURN = CAST(CAST(@f_float as  NUMERIC (9,2)) as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomFloat03]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomFloat03]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomFloat03 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @f_float			FLOAT
	
	SELECT @f_float = customfloat03
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @f_float > 0
		BEGIN
			SELECT @RETURN = CAST(CAST(@f_float as  NUMERIC (9,2)) as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomFloat04]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomFloat04]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomFloat04 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @f_float			FLOAT
	
	SELECT @f_float = customfloat04
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @f_float > 0
		BEGIN
			SELECT @RETURN = CAST(CAST(@f_float as  NUMERIC (9,2)) as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomFloat05]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomFloat05]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomFloat05 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @f_float			FLOAT
	
	SELECT @f_float = customfloat05
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @f_float > 0
		BEGIN
			SELECT @RETURN = CAST(CAST(@f_float as  NUMERIC (9,2)) as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomFloat06]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomFloat06]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomFloat06 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @f_float			FLOAT
	
	SELECT @f_float = customfloat06
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @f_float > 0
		BEGIN
			SELECT @RETURN = CAST(CAST(@f_float as  NUMERIC (9,2)) as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomFloat07]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomFloat07]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomFloat07 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @f_float			FLOAT
	
	SELECT @f_float = customfloat07
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @f_float > 0
		BEGIN
			SELECT @RETURN = CAST(CAST(@f_float as  NUMERIC (9,2)) as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomFloat08]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomFloat08]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomFloat08 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @f_float			FLOAT
	
	SELECT @f_float = customfloat08
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @f_float > 0
		BEGIN
			SELECT @RETURN = CAST(CAST(@f_float as  NUMERIC (9,2)) as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomFloat09]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomFloat09]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomFloat09 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @f_float			FLOAT
	
	SELECT @f_float = customfloat09
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @f_float > 0
		BEGIN
			SELECT @RETURN = CAST(CAST(@f_float as  NUMERIC (9,2)) as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomFloat10]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomFloat10]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomFloat10 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @f_float			FLOAT
	
	SELECT @f_float = customfloat10
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @f_float > 0
		BEGIN
			SELECT @RETURN = CAST(CAST(@f_float as  NUMERIC (9,2)) as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInd01]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_CustomInd01]
		(@i_bookkey	INT)

RETURNS VARCHAR(1)

/*	The purpose of the qweb_get_CustomInd01 function is to return a 'Y' or 'N' for this indicator on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(1)
	DECLARE @v_desc				VARCHAR(1)
	DECLARE @i_indicator			INT
	
	SELECT @i_indicator = customind01
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 


	IF @i_indicator = 1
		BEGIN
			SELECT @RETURN = 'Y'
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'N'
		END


RETURN @RETURN


END











GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInd02]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_CustomInd02]
		(@i_bookkey	INT)

RETURNS VARCHAR(1)

/*	The purpose of the qweb_get_CustomInd01 function is to return a 'Y' or 'N' for this indicator on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(1)
	DECLARE @v_desc				VARCHAR(1)
	DECLARE @i_indicator			INT
	
	SELECT @i_indicator = customind02
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 


	IF @i_indicator = 1
		BEGIN
			SELECT @RETURN = 'Y'
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'N'
		END


RETURN @RETURN


END












GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInd03]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_CustomInd03]
		(@i_bookkey	INT)

RETURNS VARCHAR(1)

/*	The purpose of the qweb_get_CustomInd01 function is to return a 'Y' or 'N' for this indicator on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(1)
	DECLARE @v_desc				VARCHAR(1)
	DECLARE @i_indicator			INT
	
	SELECT @i_indicator = customind03
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 


	IF @i_indicator = 1
		BEGIN
			SELECT @RETURN = 'Y'
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'N'
		END


RETURN @RETURN


END












GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInd04]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_CustomInd04]
		(@i_bookkey	INT)

RETURNS VARCHAR(1)

/*	The purpose of the qweb_get_CustomInd01 function is to return a 'Y' or 'N' for this indicator on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(1)
	DECLARE @v_desc				VARCHAR(1)
	DECLARE @i_indicator			INT
	
	SELECT @i_indicator = customind04
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 


	IF @i_indicator = 1
		BEGIN
			SELECT @RETURN = 'Y'
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'N'
		END


RETURN @RETURN


END












GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInd05]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_CustomInd05]
		(@i_bookkey	INT)

RETURNS VARCHAR(1)

/*	The purpose of the qweb_get_CustomInd01 function is to return a 'Y' or 'N' for this indicator on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(1)
	DECLARE @v_desc				VARCHAR(1)
	DECLARE @i_indicator			INT
	
	SELECT @i_indicator = customind05
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 


	IF @i_indicator = 1
		BEGIN
			SELECT @RETURN = 'Y'
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'N'
		END


RETURN @RETURN


END












GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInd06]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_CustomInd06]
		(@i_bookkey	INT)

RETURNS VARCHAR(1)

/*	The purpose of the qweb_get_CustomInd01 function is to return a 'Y' or 'N' for this indicator on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(1)
	DECLARE @v_desc				VARCHAR(1)
	DECLARE @i_indicator			INT
	
	SELECT @i_indicator = customind06
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 


	IF @i_indicator = 1
		BEGIN
			SELECT @RETURN = 'Y'
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'N'
		END


RETURN @RETURN


END












GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInd07]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_CustomInd07]
		(@i_bookkey	INT)

RETURNS VARCHAR(1)

/*	The purpose of the qweb_get_CustomInd01 function is to return a 'Y' or 'N' for this indicator on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(1)
	DECLARE @v_desc				VARCHAR(1)
	DECLARE @i_indicator			INT
	
	SELECT @i_indicator = customind07
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 


	IF @i_indicator = 1
		BEGIN
			SELECT @RETURN = 'Y'
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'N'
		END


RETURN @RETURN


END












GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInd08]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_CustomInd08]
		(@i_bookkey	INT)

RETURNS VARCHAR(1)

/*	The purpose of the qweb_get_CustomInd01 function is to return a 'Y' or 'N' for this indicator on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(1)
	DECLARE @v_desc				VARCHAR(1)
	DECLARE @i_indicator			INT
	
	SELECT @i_indicator = customind08
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 


	IF @i_indicator = 1
		BEGIN
			SELECT @RETURN = 'Y'
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'N'
		END


RETURN @RETURN


END












GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInd09]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_CustomInd09]
		(@i_bookkey	INT)

RETURNS VARCHAR(1)

/*	The purpose of the qweb_get_CustomInd01 function is to return a 'Y' or 'N' for this indicator on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(1)
	DECLARE @v_desc				VARCHAR(1)
	DECLARE @i_indicator			INT
	
	SELECT @i_indicator = customind09
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 


	IF @i_indicator = 1
		BEGIN
			SELECT @RETURN = 'Y'
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'N'
		END


RETURN @RETURN


END












GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInd10]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_CustomInd10]
		(@i_bookkey	INT)

RETURNS VARCHAR(1)

/*	The purpose of the qweb_get_CustomInd01 function is to return a 'Y' or 'N' for this indicator on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(1)
	DECLARE @v_desc				VARCHAR(1)
	DECLARE @i_indicator			INT
	
	SELECT @i_indicator = customind10
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 


	IF @i_indicator = 1
		BEGIN
			SELECT @RETURN = 'Y'
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'N'
		END


RETURN @RETURN


END












GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInt01]    Script Date: 03/02/2011 15:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomInt01]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomInt01 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @i_integer			INT
	
	SELECT @i_integer = customint01
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @i_integer > 0
		BEGIN
			SELECT @RETURN = CAST(@i_integer as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInt02]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomInt02]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomInt02 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @i_integer			INT
	
	SELECT @i_integer = customint02
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @i_integer > 0
		BEGIN
			SELECT @RETURN = CAST(@i_integer as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInt03]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomInt03]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomInt03 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @i_integer			INT
	
	SELECT @i_integer = customint03
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @i_integer > 0
		BEGIN
			SELECT @RETURN = CAST(@i_integer as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInt04]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomInt04]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomInt04 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @i_integer			INT
	
	SELECT @i_integer = customint04
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @i_integer > 0
		BEGIN
			SELECT @RETURN = CAST(@i_integer as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInt05]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomInt05]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomInt05 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @i_integer			INT
	
	SELECT @i_integer = customint05
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @i_integer > 0
		BEGIN
			SELECT @RETURN = CAST(@i_integer as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInt06]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomInt06]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomInt06 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @i_integer			INT
	
	SELECT @i_integer = customint06
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @i_integer > 0
		BEGIN
			SELECT @RETURN = CAST(@i_integer as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInt07]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomInt07]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomInt07 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @i_integer			INT
	
	SELECT @i_integer = customint07
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @i_integer > 0
		BEGIN
			SELECT @RETURN = CAST(@i_integer as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInt08]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomInt08]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomInt08 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @i_integer			INT
	
	SELECT @i_integer = customint08
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @i_integer > 0
		BEGIN
			SELECT @RETURN = CAST(@i_integer as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInt09]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomInt09]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomInt09 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @i_integer			INT
	
	SELECT @i_integer = customint09
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @i_integer > 0
		BEGIN
			SELECT @RETURN = CAST(@i_integer as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_CustomInt10]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_CustomInt10]
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomInt10 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @i_integer			INT
	
	SELECT @i_integer = customint10
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @i_integer > 0
		BEGIN
			SELECT @RETURN = CAST(@i_integer as VARCHAR(23))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END




GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Description]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO








CREATE FUNCTION [dbo].[qweb_get_Description] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_Description function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 3
	SELECT @i_commenttypesubcode = 8
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END









GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Discount]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_Discount]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Discount function is to return a specific description column from gentables for a Discount

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_discountcode		INT
	
	SELECT @i_discountcode = discountcode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadesc))
			FROM	gentables  
			WHERE  tableid = 459
					AND datacode = @i_discountcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(externalcode))
			FROM	gentables  
			WHERE  tableid = 459
					AND datacode = @i_discountcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadescshort))
			FROM	gentables  
			WHERE  tableid = 459
					AND datacode = @i_discountcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 459
					AND datacode = @i_discountcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 459
					AND datacode = @i_discountcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadesc))
			FROM	gentables  
			WHERE  tableid = 459
					AND datacode = @i_discountcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Edition]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_Edition]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Edition function is to return a specific description column from gentables for a Edition

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_editioncode		INT
	
	SELECT @i_editioncode = editioncode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 200
					AND datacode = @i_editioncode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 200
					AND datacode = @i_editioncode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 200
					AND datacode = @i_editioncode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 200
					AND datacode = @i_editioncode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 200
					AND datacode = @i_editioncode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 200
					AND datacode = @i_editioncode
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_estmessage_errorseverity]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE FUNCTION [dbo].[qweb_get_estmessage_errorseverity]
    ( @i_estkey as integer,@i_versionkey as integer) 

RETURNS smallint

/******************************************************************************
**  File: 
**  Name: qweb_get_estmessage_errorseverity
**  Desc: This function returns the most severe message error code 
**        (based on tableid 539) for an individual estimate version. 
**
**        Message Severity Order:
**          Error (datacode = 2)
**          Warning (datacode = 3)
**          Information/Notes (datacode = 4)
**
**    Auth: Alan Katzen
**    Date: 10 August 2005
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_count      INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_count = 0

  IF @i_estkey is null OR @i_estkey <= 0 OR
     @i_versionkey is null OR @i_versionkey <= 0 BEGIN
     RETURN -1
  END

  -- look for errors
  SELECT @i_count = count(*) 
    FROM estmessage
   WHERE estkey = @i_estkey and 
         version = @i_versionkey and
         severity = 1

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    RETURN -1
  END 

  IF @i_count > 0 BEGIN
    -- error message found
    RETURN 2
  END

  -- look for warnings
  SELECT @i_count = count(*) 
    FROM estmessage
   WHERE estkey = @i_estkey and 
         version = @i_versionkey and
         severity = 2

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    RETURN -1
  END 

  IF @i_count > 0 BEGIN
    -- warning message found
    RETURN 3
  END

  -- look for information/notes
  SELECT @i_count = count(*) 
    FROM estmessage
   WHERE estkey = @i_estkey and 
         version = @i_versionkey and
         severity in (3,4)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    RETURN -1
  END 

  IF @i_count > 0 BEGIN
    -- information/notes message found
    RETURN 4
  END
 
  -- no errors,warnings,info,notes messages found
  RETURN 0
END



GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Format]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [dbo].[qweb_get_Format]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Format function is to return a specific description column from gentables for a Format

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(255)
	DECLARE @v_desc				VARCHAR(255)
	DECLARE @i_mediatypecode		INT
	DECLARE @i_mediatypesubcode		INT
	
	SELECT @i_mediatypecode = mediatypecode,
		@i_mediatypesubcode = mediatypesubcode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey and mediatypecode <> 0


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadesc))
			FROM	subgentables  
			WHERE  tableid = 312

					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(externalcode))
			FROM	subgentables  
			WHERE  tableid = 312
					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadescshort))
			FROM	subgentables  
			WHERE  tableid = 312
					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(bisacdatacode))
			FROM	subgentables  
			WHERE  tableid = 312
					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc1))
			FROM	subgentables  
			WHERE  tableid = 312
					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
		
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc2))
			FROM	subgentables  
			WHERE  tableid = 312
					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
	ELSE IF @v_column = 'T'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(eloquencefieldtag))
			FROM	subgentables  
			WHERE  tableid = 312
					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

RETURN @RETURN


END








GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_FormatBorders]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_FormatBorders] 
			(@i_bookkey	INT)


RETURNS	VARCHAR (2)

/*  The purpose of the qweb_get_FormatBorders function is to return a specific format for the BORDERS e-cat spreadsheet
     the results of this function will be placed in the 'category' column on the spreadsheet  


	
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(2)
	DECLARE @v_desc			VARCHAR(2)
	DECLARE @v_formatdesc		VARCHAR(40)



/*  GET  format 	*/
	
	SELECT 	 @v_formatdesc = dbo.qweb_get_Format(@i_bookkey, 'B')

	IF @v_formatdesc is NULL
		BEGIN
			SELECT @v_desc = ''
		END
	ELSE
		BEGIN

		/* TRANSLATE TO BORDERS SPECS */

		IF (LTRIM(RTRIM(@v_formatdesc)) = 'SS')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'TC')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'SC')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'LB')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'LE')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'RL')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'BL')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'CT')
		   BEGIN
			SELECT @v_desc = 'CL'
		   END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'TP')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'PT')
		        BEGIN
         		 	SELECT @v_desc = 'QP'
		        END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'ST')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'MI')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'FB')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'BD')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'PO')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'BA')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'WC')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'VB')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'DE')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'FF')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'CB')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'FU')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'SP')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'MO')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'BI')
		        BEGIN
         		 	SELECT @v_desc = 'JU'
		        END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'MM')
		        BEGIN
         		 	SELECT @v_desc = 'MM'
		        END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'TY')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'MU')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'PL')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'OO')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'DL')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'MX')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'BZ')
		        BEGIN
         		 	SELECT @v_desc = 'MU'
		        END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'BG')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'ZZ')
		        BEGIN
         		 	SELECT @v_desc = 'SL'
		        END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'DA')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'AA')
		        BEGIN
         		 	SELECT @v_desc = 'TA'
		        END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'CD')
		        BEGIN
         		 	SELECT @v_desc = 'CD'
		        END
		ELSE 
		        BEGIN
         		 	SELECT @v_desc = ''
		        END



		END
	
	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = UPPER(LTRIM(RTRIM(@v_desc)))
		END

	ELSE
		BEGIN
			SELECT @RETURN = ''
		END




RETURN @RETURN


END









GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_FullAuthorDisplayName]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO






CREATE FUNCTION [dbo].[qweb_get_FullAuthorDisplayName]
		(@i_bookkey	INT)

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_FullAuthorDisplayName function is to return a the author display name on bookdetail

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(255)
	DECLARE @v_desc				VARCHAR(255)
	
	SELECT @v_desc = ltrim(rtrim(fullauthordisplayname))
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey 


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = null
		END


RETURN @RETURN


END












GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_GentableFilterkey]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [dbo].[qweb_get_GentableFilterkey](@i_tableid	INT)

RETURNS INT

AS
BEGIN
	DECLARE @i_filterorglevelkey		INT

	SELECT @i_filterorglevelkey = filterorglevelkey
	FROM gentablesdesc
	WHERE tableid = @i_tableid


RETURN @i_filterorglevelkey

END



GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_gentables_desc]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE FUNCTION [dbo].[qweb_get_gentables_desc]
    ( @i_tableid as integer,@i_datacode as integer,@i_desctype as varchar) 

RETURNS varchar(255)

/******************************************************************************
**  File: 
**  Name: qweb_get_gentables_desc
**  Desc: This function returns the datadesc or datadescshort depending on
**        i_desctype. 
**
**        i_desctype = 'long' or empty --> return datadesc
**        i_desctype = 'short' --> return datadescshort
**
**    Auth: Alan Katzen
**    Date: 25 August 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_desc       VARCHAR(255)
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_desc = ''

  IF @i_tableid is null OR @i_tableid <= 0 OR
     @i_datacode is null OR @i_datacode <= 0 BEGIN
     RETURN ''
  END

  IF lower(rtrim(ltrim(@i_desctype))) = 'short' BEGIN
    -- get datadescshort
    SELECT @i_desc = datadescshort
      FROM gentables
     WHERE tableid = @i_tableid and
           datacode = @i_datacode
  END
  ELSE BEGIN
    -- get datadesc
    SELECT @i_desc = datadesc
      FROM gentables
     WHERE tableid = @i_tableid and
           datacode = @i_datacode
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @i_desc = 'error'
    --SET @o_error_desc = 'no data found: subjectcategories on gentablesdesc.'   
  END 

  RETURN @i_desc
END



GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_GroupLevel1]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_GroupLevel1]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Series function is to return a specific description column from gentables for a series

	Parameter Options
		F = Group Level Description
		S = Group Level Short Description
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_orgentrykey		INT	


	SELECT @i_orgentrykey = orgentrykey
	FROM	bookorgentry
	WHERE	bookkey = @i_bookkey
				AND orglevelkey = 1


	IF @v_column = 'F'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(orgentrydesc))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(orgentryshortdesc))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
			
			
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(altdesc1))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
			
			
		END

		ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(altdesc2))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
			
			
		END

RETURN @RETURN


END







GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_GroupLevel2]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






CREATE FUNCTION [dbo].[qweb_get_GroupLevel2]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Series function is to return a specific description column from gentables for a series

	Parameter Options
		F = Group Level Description
		S = Group Level Short Description
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_orgentrykey		INT	


	SELECT @i_orgentrykey = orgentrykey
	FROM	bookorgentry
	WHERE	bookkey = @i_bookkey
				AND orglevelkey = 2


	IF @v_column = 'F'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(orgentrydesc))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(orgentryshortdesc))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
			
			
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(altdesc1))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE --  get the full description and return that
					BEGIN
						SELECT @v_desc = ltrim(rtrim(orgentrydesc))
						FROM	orgentry
						WHERE	orgentrykey = @i_orgentrykey
			
						IF datalength(@v_desc) > 0
							BEGIN
								SELECT @RETURN = @v_desc
							END
						ELSE
							BEGIN
								SELECT @RETURN = ''
							END
					END
			
			
		END

		ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(altdesc2))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
			
			
		END

RETURN @RETURN


END








GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_GroupLevel3]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE FUNCTION [dbo].[qweb_get_GroupLevel3]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Series function is to return a specific description column from gentables for a series

	Parameter Options
		F = Group Level Description
		S = Group Level Short Description
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_orgentrykey		INT	


	SELECT @i_orgentrykey = orgentrykey
	FROM	bookorgentry
	WHERE	bookkey = @i_bookkey
				AND orglevelkey = 3


	IF @v_column = 'F'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(orgentrydesc))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(orgentryshortdesc))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
			
			
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(altdesc1))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			
			ELSE --  do NOT get the full description and return that
				BEGIN
					SELECT @v_desc = ltrim(rtrim(orgentrydesc))
						FROM	orgentry
						WHERE	orgentrykey = @i_orgentrykey
			
						IF datalength(@v_desc) > 0
							BEGIN
								SELECT @RETURN = ''
							END
						ELSE
							BEGIN
								SELECT @RETURN = ''
							END
			        END
			
			
		END

		ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(altdesc2))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
			
			
		END

RETURN @RETURN


END








GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_InsideFlapCopy]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_InsideFlapCopy] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_InsideFlapCopy function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 3
	SELECT @i_commenttypesubcode = 2
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END










GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Isbn]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_Isbn](
		@i_bookkey	INT,
		@i_isbn_type	INT)

/*	PARAMETER @i_isbn_type
		10 = ISBN10
		13 = ISBN 13
		16 = EAN
		17 = EAN (no dashes)
		18 = GTIN
		19 = GTIN (no dashes)
		20 = LCCN
		21 = UPC
*/
	RETURNS VARCHAR(50)
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(50)
	DECLARE @v_desc			VARCHAR(50)

	IF @i_isbn_type = 10
		BEGIN
			SELECT @v_desc = isbn10
			FROM isbn
			WHERE bookkey = @i_bookkey
		END
	
	ELSE IF @i_isbn_type = 13
		BEGIN
			SELECT @v_desc = isbn
			FROM isbn
			WHERE bookkey = @i_bookkey
		END

	ELSE IF @i_isbn_type = 16
		BEGIN
			SELECT @v_desc = ean
			FROM isbn
			WHERE bookkey = @i_bookkey
		END
	ELSE IF @i_isbn_type = 17
		BEGIN
			SELECT @v_desc = ean13
			FROM isbn
			WHERE bookkey = @i_bookkey
		END
	ELSE IF @i_isbn_type = 18
		BEGIN
			SELECT @v_desc = gtin
			FROM isbn
			WHERE bookkey = @i_bookkey
		END
	ELSE IF @i_isbn_type = 19
		BEGIN
			SELECT @v_desc = gtin14
			FROM isbn
			WHERE bookkey = @i_bookkey
		END
	ELSE IF @i_isbn_type = 20
		BEGIN
			SELECT @v_desc = lccn
			FROM isbn
			WHERE bookkey = @i_bookkey
		END
	ELSE IF @i_isbn_type = 21
		BEGIN
			SELECT @v_desc = upc
			FROM isbn
			WHERE bookkey = @i_bookkey
		END
	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_desc))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

  RETURN @RETURN
END





GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Language]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_Language]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Language function is to return a specific description column from gentables for a language

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_languagecode		INT
	
	SELECT @i_languagecode = languagecode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 318
					AND datacode = @i_languagecode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 318
					AND datacode = @i_languagecode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 318
					AND datacode = @i_languagecode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 318
					AND datacode = @i_languagecode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 318
					AND datacode = @i_languagecode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 318
					AND datacode = @i_languagecode
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END









GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_LastKeyDateChanged]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_LastKeyDateChanged](
			@i_bookkey INT,
			@i_datetypecode INT)

RETURNS DATETIME

AS
BEGIN
	DECLARE @RETURN DATETIME

	SELECT @RETURN = MAX(lastmaintdate)
	FROM	datehistory
	WHERE	@i_bookkey = bookkey
		AND @i_datetypecode = datetypecode

	RETURN @RETURN
END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_LastTitleFieldChanged]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_LastTitleFieldChanged] (
		@bookkey INT, 
		@printingkey INT,
		@i_columnkey INT)
	RETURNS DATETIME
AS
BEGIN
	DECLARE @return DATETIME
	SELECT @return = MAX(lastmaintdate)
		FROM titlehistory
		WHERE bookkey = @bookkey
			AND printingkey = @printingkey
			AND columnkey = @i_columnkey
  RETURN @return
END

/*  History Column Key
	1	Title
	2	Internal Status
	3	Subtitle
	4	BISAC Status
	6	Author
	7	Price Type
	8	Estimated Price
	9	Actual Price
	10	Media
	11	Format
	12	Estimated Season
	13	Actual Season
	15	Estimated Page Count
	16	Actual Page Count
	17	Estimated Quantity
	18	Actual Quantity
	19	Estimated Trim Size Width
	20	Estimated Trim Size Length
	21	Trim Size Width
	22	Trim Size Length
	23	Group Level
	24	Task Estimated Date
	25	Task Actual Date
	26	Jacket Vendor
	27	Binding Vendor
	28	Language
	29	Grade Low
	30	Grade High
	31	Currency
	32	Age Low
	33	Age High
	34	Restriction Code
	35	Return Code
	36	Active Date
	37	Estimated Date
	38	Bisac Heading
	39	Bisac Sub Heading
	40	Author Type
	41	Short Title
	42	Title Prefix
	43	ISBN
	44	UPC
	45	EAN
	46	LCCN
	47	Edition
	48	Sales Division
	49	Origin
	50	Series
	51	User Level
	52	Volume
	53	Software Platform
	54	Type
	55	Territory
	56	Author Display Name
	57	Author Last Name
	58	Author First Name
	59	Author Middle Name
	60	Author Primary Ind
	61	Age High 'and up' Ind
	62	Age Low 'and up' Ind
	63	Grade High 'and up' Ind
	64	Grade Low 'and up' Ind
	65	Personnel
	66	Personnel Type
	67	Citation Source
	68	Citation Author
	69	Citation Date
	70	Comment
	71	Author Citation
	72	Author Biography
	73	File Type
	74	File Format
	75	File and Path Name
	76	Pub Month
	80	Estimated Announced First Ptg
	81	Actual Announced First Ptg
	82	Estimated Insert/Illus
	83	Actual Insert/Illus
	84	Publish To Web
	85	TMM Sales Forecast
	86	TMM Actual Trim Width
	87	TMM Actual Trim Length
	88	TMM Page Count
	90	Discount Code
	91	Audience Code
	92	All Ages Indicator
	96	Book Weight
	97	Release to Eloquence
	100	Price Effective Date
	101	Full Author Display Name
	102	Budget Forecast
	103	Book Category
	104	Send To Eloquence
	105	Set Type
	106	Set Available Date
	107	Set Prefix
	108	Set Name	
	109	Set Subtitle
	110	Set Short Title
	111	Set Media
	112	Set Format
	113	Title Verification
	114	Number of Cassettes
	115	Total Run Time
	116	Citation Note
	117	Citation Proofed.
	118	Citation Web
	119	Citation Send to Elo
	124	Canadian Restriction

*/






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Media]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_Media]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Format function is to return a specific description column from gentables for a Format

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(255)
	DECLARE @v_desc				VARCHAR(255)
	DECLARE @i_mediatypecode		INT
	
	SELECT @i_mediatypecode = mediatypecode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey and mediatypecode <> 0


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadesc))
			FROM	gentables  
			WHERE  tableid = 312
			AND datacode = @i_mediatypecode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(externalcode))
			FROM	gentables  
			WHERE  tableid = 312
			AND datacode = @i_mediatypecode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadescshort))
			FROM	gentables  
			WHERE  tableid = 312
			AND datacode = @i_mediatypecode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 312
			AND datacode = @i_mediatypecode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 312
			AND datacode = @i_mediatypecode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc2))
			FROM	gentables  
			WHERE  tableid = 312
			AND datacode = @i_mediatypecode
		END

	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END











GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_MktStrategy]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO








CREATE FUNCTION [dbo].[qweb_get_MktStrategy] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_MktStrategy function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 1
	SELECT @i_commenttypesubcode = 43
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END











GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_namepart]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






CREATE FUNCTION [dbo].[qweb_get_namepart] (
	@v_displayname	VARCHAR(80),
	@v_namepart	VARCHAR(1))

RETURNS	VARCHAR(40)

BEGIN

DECLARE @i_indexcount	INT
DECLARE @i_wordlen	INT
DECLARE @v_firstname	VARCHAR(40)
DECLARE @v_middlename	VARCHAR(40)
DECLARE @v_lastname	VARCHAR(40)
DECLARE @v_name		VARCHAR(80)
DECLARE @v_ReturnName	VARCHAR(40)




	SELECT @v_displayname = ltrim(rtrim(dbo.proper_case(@v_displayname)))
	SELECT @i_indexcount = PATINDEX ( '% %' , @v_displayname )
	

-- The section gets a one word name and sets it as a Last Name

	IF @i_indexcount < 1

		SELECT @v_LastName = @v_displayname
	


--This section gets the first name

	IF @i_indexcount > 0
   		BEGIN
   			SELECT @i_WordLen = Datalength(rtrim(ltrim(@v_displayname)))
   			SELECT @v_FirstName = Left(@v_displayname , (@i_indexcount - 1))
   			SELECT @v_name = (Right(@v_displayname,@i_wordlen - (@i_indexcount)))
		
   		

--This section gets the Middle name

			SELECT @i_indexcount = PATINDEX ( '% %' , @v_name )
			IF @i_indexcount > 0
				BEGIN
	       
					SELECT @i_wordlen = Datalength(rtrim(ltrim(@v_name)))
					SELECT @v_middlename = Left(@v_name , (@i_indexcount - 1))
					SELECT @v_lastname = Rtrim(LTrim(Right(@v_name,@i_wordlen - (@i_indexcount - 1))))

		  		END
			

				ELSE
   		-- If No Middle Name set Last Name
   					BEGIN
		       				SELECT @v_middlename = ''
		       				SELECT @v_lastname = lTrim(Rtrim(@v_name))

					END

		END


	IF @v_NamePart = 'F'

		SELECT @v_ReturnName = @v_FirstName

	IF @v_NamePart = 'M'

		SELECT @v_ReturnName = @v_MiddleName

	IF @v_NamePart = 'L'

		SELECT @v_ReturnName = @v_LastName


RETURN @v_ReturnName

END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_NULLPlaceholder]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





CREATE FUNCTION [dbo].[qweb_get_NULLPlaceholder]()
		

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_NULLPlaceholder function is to simply return a NULL value so that when picking a list of fields, you can include 
		a placeholder
*/	

AS

BEGIN

DECLARE @RETURN			VARCHAR(23)
SELECT @RETURN = ''

RETURN @RETURN


END












GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Publicity]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO










CREATE FUNCTION [dbo].[qweb_get_Publicity] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_Publicity function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 1
	SELECT @i_commenttypesubcode = 21
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END











GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_PubMonth]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





CREATE FUNCTION [dbo].[qweb_get_PubMonth] 
            (@i_bookkey INT,
            @i_printingkey INT,
		@v_datepart varchar(1))
		

 
/*          The qweb_get_PubMonth function is used to retrieve the either the Pub Month or Year depending on the datepart specified.
		This function does not pull from the pub date but is the rough equivalent to the Pub Month & Year found in TMM 

            The parameters are for the book key and printing key and datepart where the valid values are:
		'M' - Month
		'Y' - Year

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @i_pubmonthcode    	INT   
DECLARE	@d_pubmonth		DATETIME     
DECLARE @RETURN       		VARCHAR(23)

 

       	SELECT @i_pubmonthcode = pubmonthcode,
		@d_pubmonth=pubmonth
        FROM   printing
        WHERE  bookkey = @i_bookkey and printingkey = @i_printingkey

	IF @v_datepart = 'M' -- get pubmonth
		BEGIN
			IF @i_pubmonthcode = 1
				BEGIN
					SELECT @RETURN = 'January'
				END
			ELSE IF @i_pubmonthcode = 2	
				BEGIN
					SELECT @RETURN = 'February'
				END
			ELSE IF @i_pubmonthcode = 3	
				BEGIN
					SELECT @RETURN = 'March'
				END
			ELSE IF @i_pubmonthcode = 4	
				BEGIN
					SELECT @RETURN = 'April'
				END
			ELSE IF @i_pubmonthcode = 5	
				BEGIN
					SELECT @RETURN = 'May'
				END
			ELSE IF @i_pubmonthcode = 6	
				BEGIN
					SELECT @RETURN = 'June'
				END
			ELSE IF @i_pubmonthcode = 7	
				BEGIN
					SELECT @RETURN = 'July'
				END
			ELSE IF @i_pubmonthcode = 8	
				BEGIN
					SELECT @RETURN = 'August'
				END
			ELSE IF @i_pubmonthcode = 9	
				BEGIN
					SELECT @RETURN = 'September'
				END
			ELSE IF @i_pubmonthcode = 10	
				BEGIN
					SELECT @RETURN = 'October'
				END
			ELSE IF @i_pubmonthcode = 11	
				BEGIN
					SELECT @RETURN = 'November'
				END
			ELSE IF @i_pubmonthcode = 12	
				BEGIN
					SELECT @RETURN = 'December'
				END
			ELSE 	
				BEGIN
					SELECT @RETURN = ''
				END
            	END

	ELSE IF @v_datepart = 'Y' -- get pubyear
                BEGIN
                      SELECT @RETURN = CAST(YEAR(@d_pubmonth) as varchar (4))
                END
	ELSE 
                BEGIN
                      SELECT @RETURN = 'invalid parameter'
                END

	IF @RETURN is NULL
	  BEGIN
	         SELECT @RETURN=''
	  END

	RETURN @RETURN

END












GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Quote1]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_Quote1] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_Quote1 function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 3
	SELECT @i_commenttypesubcode = 4
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END










GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Quote2]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_Quote2] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_Quote2 function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 3
	SELECT @i_commenttypesubcode = 5
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END










GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Quote3]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_Quote3] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_Quote3 function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 3
	SELECT @i_commenttypesubcode = 6
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END










GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Quote4]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_Quote4] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_Quote4 function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 3
	SELECT @i_commenttypesubcode = 45
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END










GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Quote5]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_Quote5] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_Quote5 function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 3
	SELECT @i_commenttypesubcode = 46
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END










GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_ReturnInd]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






CREATE FUNCTION [dbo].[qweb_get_ReturnInd]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_ReturnInd function is to return a specific description column from gentables for a Return Code

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_returncode		INT

	SELECT @v_desc = ''
	
	SELECT @i_returncode = returncode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey
	

IF @i_returncode > 0
	BEGIN
	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END

	ELSE IF @v_column = 'T'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(eloquencefieldtag))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END
	END



	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END













GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_ReturnRestriction]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






CREATE FUNCTION [dbo].[qweb_get_ReturnRestriction]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_ReturnRestriction function is to restriction a specific description column from gentables for a restriction Code

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_restrictioncode		INT

	SELECT @v_desc = ''
	
	SELECT @i_restrictioncode = restrictioncode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey
	

IF @i_restrictioncode > 0
	BEGIN
	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 320
					AND datacode = @i_restrictioncode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 320
					AND datacode = @i_restrictioncode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 320
					AND datacode = @i_restrictioncode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 320
					AND datacode = @i_restrictioncode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 320
					AND datacode = @i_restrictioncode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 320
					AND datacode = @i_restrictioncode
		END
	ELSE IF @v_column = 'T'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(eloquencefieldtag))
			FROM	gentables  
			WHERE  tableid = 320
					AND datacode = @i_restrictioncode
		END

	END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END














GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_SalesHandle]    Script Date: 03/02/2011 15:36:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





CREATE FUNCTION [dbo].[qweb_get_SalesHandle] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_BriefDescription function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 1
	SELECT @i_commenttypesubcode = 25
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_SendToEloquenceInd]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_SendToEloquenceInd]
		(@i_bookkey	INT)

RETURNS VARCHAR(1)

/*	The purpose of the qweb_get_SendToEloquenceInd function is to return a 'Y' or 'N' for this indicator on the Book table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(1)
	DECLARE @v_desc				VARCHAR(1)
	DECLARE @i_indicator			INT
	
	SELECT @i_indicator = sendtoeloind
	FROM	book
	WHERE	bookkey = @i_bookkey 


	IF @i_indicator = 1
		BEGIN
			SELECT @RETURN = 'Y'
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'N'
		END


RETURN @RETURN


END













GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Series]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[qweb_get_Series]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Series function is to return a specific description column from gentables for a series

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
		X = Best - take alt desc2, then alt desc 1, then datadesc
*/	

AS

BEGIN

	DECLARE @RETURN		VARCHAR(255)
	DECLARE @v_desc		VARCHAR(255)
	DECLARE @i_seriescode	INT
	
	SELECT @i_seriescode = seriescode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadesc))
			FROM	gentables  
			WHERE  tableid = 327
					AND datacode = @i_seriescode
			
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(externalcode))
			FROM	gentables  
			WHERE  tableid = 327
					AND datacode = @i_seriescode
			

		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadescshort))
			FROM	gentables  
			WHERE  tableid = 327
					AND datacode = @i_seriescode
			

		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 327
					AND datacode = @i_seriescode
			
	
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 327
					AND datacode = @i_seriescode
			

		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc2))
			FROM	gentables  
			WHERE  tableid = 327
					AND datacode = @i_seriescode
			

		END
	ELSE IF @v_column = 'X'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc2))
			FROM	gentables  
			WHERE  tableid = 327
					AND datacode = @i_seriescode
		IF LEN(@v_desc) > 0
			BEGIN
				SELECT @RETURN = @v_desc
			END
		ELSE
			BEGIN
				SELECT @v_desc = ltrim(rtrim(alternatedesc1))
				FROM	gentables  
				WHERE  tableid = 327
					AND datacode = @i_seriescode
				IF LEN(@v_desc) > 0
					BEGIN
						SELECT @RETURN = @v_desc
					END
				ELSE
					BEGIN
						SELECT @v_desc = ltrim(rtrim(datadesc))
						FROM	gentables  
						WHERE  tableid = 327
							AND datacode = @i_seriescode
					END
			END

		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END








GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_SeriesVolume]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_SeriesVolume]
		(@i_bookkey	INT)

RETURNS VARCHAR(5)

/*	The purpose of the qweb_get_Series Volume is to pull the volume number in the series and return it if it exists.  If it doesn't, then return a space
*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(5)
	DECLARE @v_desc				VARCHAR(5)
	DECLARE @i_volumenumber			INT
	
	SELECT @i_volumenumber = volumenumber
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey and volumenumber <> 0


	IF @i_volumenumber > 0
		BEGIN
			SELECT @RETURN = CAST(@i_volumenumber as varchar(5))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END











GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_ShortTitle]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_ShortTitle] (
		@i_bookkey	INT)
	
	RETURNS VARCHAR(50)
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(50)
		

	SELECT @RETURN = ltrim(rtrim(shorttitle))
	FROM book
	WHERE bookkey = @i_bookkey


  RETURN @RETURN
END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_statuscode]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO





CREATE FUNCTION [dbo].[qweb_get_statuscode]
    ( @i_bookkey as int ) 

RETURNS int

BEGIN 
   DECLARE @i_statuscode int

  select @i_statuscode = bisacstatuscode from bookdetail  where bookkey = @i_bookkey 

  RETURN  @i_statuscode 
END








GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_subgentables_desc]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE FUNCTION [dbo].[qweb_get_subgentables_desc]
    (@i_tableid as integer,@i_datacode as integer,@i_datasubcode as integer,@i_desctype as varchar) 

RETURNS varchar(255)

/******************************************************************************
**  File: 
**  Name: qweb_get_subgentables_desc
**  Desc: This function returns the datadesc or datadescshort depending on
**        i_desctype. 
**
**        i_desctype = 'long' or empty --> return datadesc
**        i_desctype = 'short' --> return datadescshort
**
**    Auth: Alan Katzen
**    Date: 1 March 2006
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_desc       VARCHAR(255)
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_desc = ''

  IF @i_tableid is null OR @i_tableid <= 0 OR
     @i_datacode is null OR @i_datacode <= 0  OR
     @i_datasubcode is null OR @i_datasubcode <= 0 BEGIN
     RETURN ''
  END

  IF lower(rtrim(ltrim(@i_desctype))) = 'short' BEGIN
    -- get datadescshort
    SELECT @i_desc = datadescshort
      FROM subgentables
     WHERE tableid = @i_tableid and
           datacode = @i_datacode and
           datasubcode = @i_datasubcode
  END
  ELSE BEGIN
    -- get datadesc
    SELECT @i_desc = datadesc
      FROM subgentables
     WHERE tableid = @i_tableid and
           datacode = @i_datacode and
           datasubcode = @i_datasubcode
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @i_desc = 'error'
    --SET @o_error_desc = 'no data found: datadesc on subgentables.'   
  END 

  RETURN @i_desc
END



GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Subjects]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_Subjects](
		@i_bookkey	INT,
		@i_subjectnum	INT,
		@i_order	INT,
		@v_column	VARCHAR(1)
)

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Subject function is to return a specific description column from gentables for any of the 
	configurable subject categories

	Parameter Options
		@i_subjectnum
			1-10	Returns the respective subject category

		@i_order	-> Each book may have multipe subjects - enter the sort order number to pull
			1...n

		@v_column  (column from gentables)
			D = Data Description
			E = External code
			S = Short Description
			B = BISAC Data Code
			T = Eloquence Field Tag
			1 = Alternative Description 1
			2 = Alternative Deccription 2
*/	

AS

BEGIN


	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_tableid		INT
	DECLARE @i_categorycode		INT
	DECLARE @i_categorysubcode	INT
	DECLARE @i_categorysub2code	INT

	SELECT @i_tableid =   CASE @i_subjectnum    
			WHEN 1 	THEN  	412
			WHEN 2	THEN	413
			WHEN 3 	THEN  	414
			WHEN 4	THEN	431
			WHEN 5 	THEN  	432
			WHEN 6	THEN	433
			WHEN 7 	THEN  	434
			WHEN 8	THEN	435
			WHEN 9 	THEN  	436
			WHEN 10	THEN	437
		END

	
	SELECT @i_categorycode = categorycode,
		@i_categorysubcode = categorysubcode,
		@i_categorysub2code = categorysub2code
	FROM	booksubjectcategory
	WHERE	bookkey = @i_bookkey
			AND sortorder = @i_order



	IF @i_categorycode IS NOT NULL 
			AND (@i_categorysubcode = 0 OR @i_categorysubcode IS NULL)
			AND (@i_categorysub2code = 0 OR @i_categorysub2code IS NULL)
		BEGIN
			IF @v_column = 'D'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	gentables  
					WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END

			ELSE IF @v_column = 'E'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(externalcode))
					FROM	gentables  
					WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END

			ELSE IF @v_column = 'S'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadescshort))
					FROM	gentables  
					WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END

			ELSE IF @v_column = 'B'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
					FROM	gentables  
					WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END

			ELSE IF @v_column = '1'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
					FROM	gentables  
					WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END

			ELSE IF @v_column = '2'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	gentables  
					WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END
		END

	IF @i_categorycode IS NOT NULL 
			AND (@i_categorysubcode > 0 OR @i_categorysubcode IS NOT NULL)
			AND (@i_categorysub2code = 0 OR @i_categorysub2code IS NULL)

		BEGIN
			IF @v_column = 'D'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	subgentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
				END

			ELSE IF @v_column = 'E'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(externalcode))
					FROM	subgentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
				END

			ELSE IF @v_column = 'S'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadescshort))
					FROM	subgentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
				END

			ELSE IF @v_column = 'B'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
					FROM	subgentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
				END

			ELSE IF @v_column = '1'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))

					FROM	subgentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
				END

			ELSE IF @v_column = '2'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	subgentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
				END
		END

	IF @i_categorycode IS NOT NULL 
			AND (@i_categorysubcode > 0 OR @i_categorysubcode IS NOT NULL)
			AND (@i_categorysub2code > 0 OR @i_categorysub2code IS NOT NULL)

		BEGIN
			IF @v_column = 'D'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	sub2gentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
							AND datasub2code = @i_categorysub2code
				END

			ELSE IF @v_column = 'E'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(externalcode))
					FROM	sub2gentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
							AND datasub2code = @i_categorysub2code
				END

			ELSE IF @v_column = 'S'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadescshort))
					FROM	sub2gentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
							AND datasub2code = @i_categorysub2code
				END

			ELSE IF @v_column = 'B'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
					FROM	sub2gentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
							AND datasub2code = @i_categorysub2code
				END

			ELSE IF @v_column = '1'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
					FROM	sub2gentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
							AND datasub2code = @i_categorysub2code
				END

			ELSE IF @v_column = '2'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	sub2gentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
							AND datasub2code = @i_categorysub2code
				END
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_subordinate_max_web]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[qweb_get_subordinate_max_web] 
            	(@i_workkey 	INT)
		

 
/*     will return the max bookkey for a workkey that is marked published to web 

*/

RETURNS int

AS  

BEGIN 

DECLARE @i_maxsubordinate int
DECLARE @RETURN   	int

 

SELECT @i_maxsubordinate=max(bookkey) 
FROM bookdetail
WHERE bookkey in (select bookkey from book where workkey=@i_workkey)
	AND publishtowebind=1


 

	IF COALESCE (@i_maxsubordinate,0) > 0
		BEGIN
			SELECT @RETURN = @i_maxsubordinate
		END	
	
	ELSE -- IF NULL
		BEGIN
			SELECT @RETURN = NULL
		END	
		

RETURN @RETURN

END











GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_SubTitle]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





CREATE FUNCTION [dbo].[qweb_get_SubTitle] (
		@i_bookkey	INT)
	
RETURNS VARCHAR(255)

	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_subtitle 			VARCHAR(255)
		

	SELECT @v_subtitle = ltrim(rtrim(subtitle))
	FROM book
	WHERE bookkey = @i_bookkey
	
	IF LEN(@v_subtitle) > 0
		BEGIN	
			SELECT @RETURN = @v_subtitle
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

  RETURN @RETURN
END







GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Territory]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[qweb_get_Territory]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_territory function is to return a specific description column from gentables for a territory

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_territorycode	INT
	
	SELECT @i_territorycode = territoriescode
	FROM	book
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadesc))
			FROM	gentables  
			WHERE  tableid = 131
					AND datacode = @i_territorycode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(externalcode))
			FROM	gentables  
			WHERE  tableid = 131
					AND datacode = @i_territorycode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadescshort))
			FROM	gentables  
			WHERE  tableid = 131
					AND datacode = @i_territorycode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 131
					AND datacode = @i_territorycode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 131
					AND datacode = @i_territorycode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadesc))
			FROM	gentables  
			WHERE  tableid = 131
					AND datacode = @i_territorycode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

RETURN @RETURN


END






GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Title]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





CREATE FUNCTION [dbo].[qweb_get_Title] (
		@i_bookkey	INT,
		@v_part		VARCHAR(1))
	
/*	PARAMETER @v_part
		F = Full Title = Title Prefix + Title
		S = Title Search = Title + ' , ' + Title Prefix
		T = Title
		P = Title Prefix
		U = Title Upper
		C = Concatenated with SubTitle --- added by fpt 7/11/05
*/
	RETURNS VARCHAR(255)
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_title		VARCHAR(255)
	DECLARE @v_subtitle		VARCHAR(255)
	DECLARE @v_title_prefix		VARCHAR(3)

	IF @v_part = 'F'
		BEGIN
			SELECT @v_title_prefix = ltrim(rtrim(titleprefix))
			FROM bookdetail
			WHERE bookkey = @i_bookkey

			IF @v_title_prefix <> ''
				BEGIN
					SELECT @RETURN = @v_title_prefix +' '+ ltrim(rtrim(b.title))
					FROM book b LEFT OUTER JOIN bookdetail bd ON b.bookkey = bd.bookkey
					WHERE b.bookkey = @i_bookkey
				END
			ELSE
				BEGIN
					SELECT @RETURN = ltrim(rtrim(b.title))
					FROM book b 
					WHERE b.bookkey = @i_bookkey
				END
					

		END
	
	IF @v_part = 'S'
		BEGIN

			SELECT @v_title_prefix = ltrim(rtrim(titleprefix))
			FROM bookdetail
			WHERE bookkey = @i_bookkey

			IF @v_title_prefix <> ''
				BEGIN
					SELECT @RETURN = ltrim(rtrim(b.title))+', '+ ltrim(rtrim(bd.titleprefix))
					FROM book b LEFT OUTER JOIN bookdetail bd ON b.bookkey = bd.bookkey
					WHERE b.bookkey = @i_bookkey
				END


			ELSE
				BEGIN
					SELECT @RETURN = ltrim(rtrim(b.title))
					FROM book b 
					WHERE b.bookkey = @i_bookkey
				END
		END

	IF @v_part = 'T'
		BEGIN
			SELECT @RETURN = title
			FROM book
			WHERE bookkey = @i_bookkey
		END


	IF @v_part = 'P'
		BEGIN
			SELECT @RETURN = titleprefix
			FROM bookdetail
			WHERE bookkey = @i_bookkey
		END

	IF @v_part = 'U'
		BEGIN
			SELECT @RETURN = titleupper
			FROM book
			WHERE bookkey = @i_bookkey
		END

	IF @v_part = 'C'
		BEGIN
			SELECT @v_title_prefix = ltrim(rtrim(titleprefix))
			FROM bookdetail
			WHERE bookkey = @i_bookkey

			IF @v_title_prefix <> ''
				BEGIN
					SELECT @RETURN = @v_title_prefix +' '+ ltrim(rtrim(b.title))
					FROM book b LEFT OUTER JOIN bookdetail bd ON b.bookkey = bd.bookkey
					WHERE b.bookkey = @i_bookkey
				END
			ELSE
				BEGIN
					SELECT @RETURN = ltrim(rtrim(b.title))
					FROM book b 
					WHERE b.bookkey = @i_bookkey
				END
				
			SELECT @v_subtitle = dbo.qweb_get_SubTitle(@i_bookkey)	
			IF @v_subtitle <> ''
				BEGIN
					SELECT @RETURN = @RETURN + ': ' + @v_subtitle
				END
			

		END


	IF @v_part NOT IN('F','S','T','P','U','C')
		BEGIN
			SELECT @RETURN = '-1'
		END

  RETURN @RETURN
END





GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_TitlePrefix]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_TitlePrefix]
		(@i_bookkey	INT)

RETURNS VARCHAR(10)

/*	The purpose of the qweb_get_TitlePrefix function is to return a the title prefix for the book

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(10)
	DECLARE @v_desc				VARCHAR(10)
	
	SELECT @v_desc = ltrim(rtrim(titleprefix))
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey 


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END











GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_TitleVerifyStatus]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[qweb_get_TitleVerifyStatus]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_TitleVerifyStatus function is to return a specific description column from gentables for a TitleVerifyStatus

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_titleverifycode	INT
	
	SELECT @i_titleverifycode = titleverifycode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 513
					AND datacode = @i_titleverifycode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 513
					AND datacode = @i_titleverifycode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 513
					AND datacode = @i_titleverifycode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 513
					AND datacode = @i_titleverifycode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 513
					AND datacode = @i_titleverifycode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 513
					AND datacode = @i_titleverifycode
		END
			
	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

RETURN @RETURN


END










GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_TOC]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[qweb_get_TOC] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The qweb_get_TOC function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 3
	SELECT @i_commenttypesubcode = 23
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END


	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END



RETURN @RETURN

END



GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_www_events]    Script Date: 03/02/2011 15:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE function [dbo].[qweb_get_www_events] (@i_bookkey int) 

RETURNS varchar(8000)
as
BEGIN

  DECLARE @v_event_text varchar (8000),
  @i_www_event_fetchstatus int,
  @v_all_events varchar (8000),
  @v_authorbylineprepro varchar (255)

  select @v_authorbylineprepro =commenthtmllite from siu..bookcomments where commenttypecode = 3 and commenttypesubcode = 73 and bookkey = 
@i_bookkey	

  select @v_all_events = (isnull(@v_authorbylineprepro,'')) + 
  dbo.qweb_get_isbn (@i_bookkey,16) + ',' + ' ' + '$' + dbo.qweb_get_bestUSPrice (@i_bookkey,8) + ', ' + ' '+ 
  dbo.qweb_get_Format (@i_bookkey,'E') + '<BR><BR>' 
  from qweb_www_events_view	
			where bookkey=@i_bookkey
			and eventdate>=getdate()
			order by eventdate		
  

  DECLARE c_qweb_www_events CURSOR 
	FOR	 
	  select (CASE when eventdate is not null and edate is not null and eventdate<>edate then
	       '<B>' + cast (DATENAME (m, eventdate) as varchar) +'' + 
			cast (DATENAME (d, eventdate)as varchar) +','+ cast(DATEPART(yyyy, eventdate) as varchar) + 
	       '-' + cast(DATENAME(m, edate) as varchar) +' '+ cast(DATENAME(d, edate) as varchar) +', '+ cast(DATEPART(yyyy, edate) as varchar)+ '</B><BR>' ELSE '' end + 
	       CASE when eventdate is not null and (edate is null or edate=eventdate) then
	       '<B>' + cast(DATENAME(m, eventdate) as varchar) +' '+ cast(DATENAME(d, eventdate) as varchar) +', '+ cast(DATEPART(yyyy, eventdate) as varchar) + 
	       '</B><BR>' ELSE '' end +  
			CASE WHEN stime is not null and etime is not null 
			Then substring (Isnull(stime,''),12,8) + '-' + substring (isnull(etime,''),12,8) + '<BR>' ELSE '' END +
			CASE WHEN stime is not null and etime is null
			then substring (Isnull(stime,''),12,8) + '<BR>' ELSE '' END +
			CASE WHEN companyname is not null Then (isnull(companyname,'')) + '<BR>'  ELSE '' END + 
			CASE WHEN addressln1 is not null Then (isnull(addressln1,'')) + '<BR>' ELSE '' END + 
			CASE WHEN addressln2 is not null Then (isnull(addressln2,'')) + '<BR>'  ELSE '' END +
			CASE WHEN addressln3 is not null Then (isnull(addressln3,'')) + '<BR>'  ELSE '' END +
			CASE WHEN deptname is not null Then (isnull(deptname,'')) + '<BR>'  ELSE '' END +
			CASE WHEN city is not null then (isnull(city,'')) + ', ' ELSE '' END +
			CASE WHEN state is not null then (isnull(state,'')) + ' ' ELSE '' END + 
			CASE WHEN zip is not null then (isnull(zip,'')) + '<BR>' ELSE '' + '<BR>' END + 
			CASE WHEN eventnotes is not null then (isnull(eventnotes,'')) ELSE '' END + '<BR>')
			from qweb_www_events_view	
			where bookkey=@i_bookkey
			and eventdate>=getdate()
			order by eventdate	
			
	FOR READ ONLY
			
	OPEN c_qweb_www_events 

	FETCH NEXT FROM c_qweb_www_events 
		INTO @v_event_text

	select  @i_www_event_fetchstatus  = @@FETCH_STATUS

	 while (@i_www_event_fetchstatus >-1 )
		begin
		 IF (@i_www_event_fetchstatus <>-2) 
		 begin
			Select @v_all_events = ISNULL(@v_all_events,'') + ISNULL(@v_event_text,'') + '<BR>'
		 end
	 
	FETCH NEXT FROM c_qweb_www_events
		INTO @v_event_text
	        select  @i_www_event_fetchstatus  = @@FETCH_STATUS
		end

	close c_qweb_www_events
	deallocate c_qweb_www_events
   	
    If ltrim(rtrim(@v_all_events)) = '' 
	begin
		select @v_all_events = null
	end
	
	return '<DIV>' + @v_all_events + '</DIV>'
end


GO


