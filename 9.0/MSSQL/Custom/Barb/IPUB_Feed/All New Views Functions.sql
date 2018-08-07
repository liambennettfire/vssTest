--****************** TABLES FIRST **********************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IPUB_title_updated]') and OBJECTPROPERTY(id, N'IsTable') = 1)
drop table [dbo].[IPUB_title_updated]
GO

CREATE TABLE [dbo].[IPUB_title_updated](
	[bookkey] [int] NOT NULL
) ON [PRIMARY]

GO

--**************** STORED PROCEDURES ****************************************

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IPUB_LoadUpdatedTitles]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[IPUB_LoadUpdatedTitles]
GO

CREATE PROCEDURE dbo.IPUB_LoadUpdatedTitles
@duration int

/*
This stored procedure truncates [IPUB_title_updated] table first and loads the most recently
updated title bookkeys into the same table. 
@duration parameter controls how many minutes the proc looks back into the history
e.g. if 60 is passed, the proc will return bookkeys of titles that were updated within the last hour 

*/
AS 

BEGIN


DECLARE @mins as decimal(20,7)
Select @mins = (@duration / 60) / 24.000000001
--Print Cast(@mins as varchar(500))

TRUNCATE TABLE dbo.IPUB_title_updated

Insert into dbo.IPUB_title_updated
SELECT Distinct
b.bookkey
From book b 
FULL OUTER JOIN printing AS p ON (b.bookkey = p.bookkey) 
WHERE p.printingkey=1
AND b.standardind <> 'Y'
and
(
(
b.bookkey in (Select dh.bookkey from datehistory dh where dh.datetypecode in (8,47) -- 8 pubdate, 47 warehouse date
and dh.lastmaintdate > getdate() - @mins) --.04167) --last one hour
)
OR
(b.bookkey in (Select th.bookkey from titlehistory th join titlechangedinfo tci on th.bookkey = tci.bookkey
where tci.lastchangedate > getdate() - @mins --.04167 --last one hour
and
( 
(
th.columnkey in
( 45, --ISBN-13
  42, -- Prefix
   1, --Title
  41, --Short Title
  43, --ISBN 10
 235, --CopyRight Year
  54, --Type
   4, --Bisac Status
 245, -- Product Availability
   6, --Author
  40, --Author Type
  84, --Publish To Web
  10, --Media
  55, --Territory
 210, --Sales restrictions
  11, --Format
  89, --Carton Qty
  15, --Actual page Count
  16, --Estimated Page Count
  19, 20, 21, 22, --(Est vs Actual Trim Width and Length)
  23, --Publisher, Imprint, Division
 103, --Book Categories
  50, --Series 
  47, --Edition
  29, 30, --Grade Levels
  32, 33, --Age Levels
  52, --Volume
  38,39, --Bisac Heading Subheading
  7, 9, 100 --Price Type = 7, Actual Price: 9, Price Eff Date: 100
))
OR
(th.columnkey = 248 AND th.fielddesc = 'Country Of Origin')
OR 
(th.columnkey = 70 AND th.fielddesc like '%100-word front list catalog copy%')
)
)))	


END
GO
Grant execute on dbo.IPUB_LoadUpdatedTitles to Public
GO

--******************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IPUB_titles_updated_proc]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[IPUB_titles_updated_proc]
GO
CREATE PROCEDURE [dbo].[IPUB_titles_updated_proc] 
@duration int
as
BEGIN

DECLARE @mins as decimal(20,7)
Select @mins = (@duration / 60) / 24.000000001 --to force decimal division

SELECT
b.bookkey,
p.printingkey,
i.ean13 as isbn13,
titleprefixandtitle = 
	CASE 
		WHEN (bd.titleprefix IS NOT NULL AND  bd.titleprefix <> '')
			 THEN bd.titleprefix + ' ' + b.title
		WHEN (bd.titleprefix IS NULL OR bd.titleprefix = ' ') 
			 THEN b.title
	 END,
b.shorttitle as shorttitle,
itemnumber =
  CASE
   WHEN (i.isbn is null)
     THEN i.itemnumber
   END,
i.isbn10 as isbn10,
bd.copyrightyear as copyrightyear,
pubdate = COALESCE(pubdate_view.activedate,pubdate_view.bestdate),
warehousedate = COALESCE(whdate_view.activedate,whdate_view.bestdate),
(select datadesc from gentables where tableid = 132 and datacode = b.titletypecode) as typedesc,
(select externalcode from gentables where tableid = 132 and datacode = b.titletypecode) as typecode,

--officialoutofprintdate = COALESCE(officialoutofprintdate_view.activedate,officialoutofprintdate_view.bestdate),
--titlehistorytitle_created_view.minlastmaintdate as title,
--distrbuted =
--	CASE
--		WHEN bookdivision_view.orgentrydesc = 'Discovery House Publishers'
--			THEN 'Distributed'
--	END,
outofprint =
	CASE
		WHEN bd.bisacstatuscode = 2 OR b.titletypecode = 30
			THEN 'Out of Print'
		END,
outofprintcode =
	CASE
		WHEN bd.bisacstatuscode = 2 OR b.titletypecode = 30
			THEN 'P'
		END,
(dbo.get_author_all_name (b.bookkey, 10,0,'C', '|')) as authors,
--(select datadesc from gentables where tableid = 459 and datacode = bd.discountcode) as discount,
bd.publishtowebind as publishtoweb,
--Is this a set? media = prepack yes, otherwise no
IsSet = Case when bd.mediatypecode = 13 THEN 'Yes' ELSE 'No' End,
PrepackCode = Case when bd.mediatypecode = 13 THEN 
(Select externalcode from subgentables where tableid=312 and datacode=13 and datasubcode = bd.mediatypesubcode)
End,

(dbo.get_bookcategory_all_categories (b.bookkey, 3, ';')) as categories,
(dbo.get_bookcategory_all_category_externalcodes (b.bookkey, 3,';')) as category_codes,
--returncode = 
--	CASE 
--     WHEN (bd.returncode = 2)
--      THEN 'Y'
--   END,
--rtnrestriction =
--	CASE
--		WHEN (bd.restrictioncode = 1)
-- 			THEN 'N'
--   END,
(select datadesc from gentables where tableid = 131 and datacode = b.territoriescode) as territories,
(select datadesc from gentables where tableid = 428 and datacode = bd.canadianrestrictioncode) as salesrestrictions,
(select datadesc from subgentables where tableid = 312 and datacode = bd.mediatypecode and datasubcode = bd.mediatypesubcode) as titleformat,
(select externalcode from subgentables where tableid = 312 and datacode = bd.mediatypecode and datasubcode = bd.mediatypesubcode) as titleformatcode,
(select datadesc from gentables where tableid = 312 and datacode = bd.mediatypecode) as media,
(select externalcode from gentables where tableid = 312 and datacode = bd.mediatypecode) as mediacode,
cartonqty = bindingspecs.cartonqty1,
pagecount = COALESCE(p.pagecount,p.tmmpagecount,p.tentativepagecount),
trimwidth = COALESCE(p.trimsizewidth,p.tmmactualtrimwidth,p.esttrimsizewidth),
trimlength = COALESCE(p.trimsizelength,p.tmmactualtrimlength,p.esttrimsizelength),
bookpublisher_view.orgentrydesc as publisher,
bookdivision_view.orgentrydesc as division,
bookimprint_view.orgentrydesc as imprint,
dbo.qweb_get_Series(b.bookkey, 'D') as Series,
dbo.qweb_get_Series(b.bookkey, 'E') as SeriesCode,
dbo.get_Edition(b.bookkey, 'D') as Edition,
bd.gradelow as gradelevellow,
bd.gradehigh as gradelevelhigh,
bd.agelow as agelevellow,
bd.agehigh as agelevelhigh,
bd.volumenumber as volume,
(dbo.get_BookMiscDesc(b.bookkey, 525,4, 9)) as CountryOfOrigin,
(dbo.get_bisac_heading_sub_heading (b.bookkey, 5, ';')) as bisacheadingsubheading,
(dbo.get_bisac_heading_sub_heading_bisacdatacode (b.bookkey, 5, ';')) as bisacheadingsubheading_code,
([dbo].[get_allpricetype_final_effdate] (b.bookkey,5,';')) as pricetype_final_effdate,
(dbo.get_allpricetype_externalcode(b.bookkey, 5,';')) as pricetype_code,
--dbo.get_Comment_HTMLLITE(b.bookkey, 3,8) as [100WordFrontListCopy]
[dbo].[rpt_get_book_comment] (b.bookkey, 3, 8, 1) as [100WordFrontListCopy]
From book b 
 FULL OUTER JOIN printing AS p ON (b.bookkey = p.bookkey) 
 FULL OUTER JOIN isbn AS i ON (b.bookkey = i.bookkey) 
 FULL OUTER JOIN bookdetail AS bd  ON (b.bookkey = bd.bookkey) 
LEFT OUTER JOIN pubdate_view ON p.bookkey = pubdate_view.bookkey AND p.printingkey = pubdate_view.printingkey 
LEFT OUTER JOIN whdate_view ON p.bookkey = whdate_view.bookkey AND p.printingkey = whdate_view.printingkey 
--LEFT OUTER JOIN officialoutofprintdate_view ON p.bookkey = officialoutofprintdate_view.bookkey AND p.printingkey = officialoutofprintdate_view.printingkey
--FULL OUTER JOIN titlehistorytitle_created_view ON p.bookkey = titlehistorytitle_created_view.bookkey AND p.printingkey = titlehistorytitle_created_view.printingkey 
FULL OUTER JOIN bindingspecs ON p.bookkey = bindingspecs.bookkey AND p.printingkey = bindingspecs.printingkey 
LEFT OUTER JOIN bookdivision_view ON p.bookkey = bookdivision_view.bookkey 
LEFT OUTER JOIN bookimprint_view ON p.bookkey = bookimprint_view.bookkey
LEFT OUTER JOIN bookpublisher_view ON p.bookkey = bookpublisher_view.bookkey
--LEFT OUTER JOIN datehistory dh on p.bookkey = dh.bookkey 
WHERE p.printingkey=1
AND b.standardind <> 'Y'
and
(
(
b.bookkey in (Select dh.bookkey from datehistory dh where dh.datetypecode in (8,47) -- 8 pubdate, 47 warehouse date
and dh.lastmaintdate > getdate() - @mins) --.04167) --last one hour
)
OR
(b.bookkey in (Select th.bookkey from titlehistory th join titlechangedinfo tci on th.bookkey = tci.bookkey
where tci.lastchangedate > getdate() - @mins --.04167 --last one hour
and
( 
(
th.columnkey in
( 45, --ISBN-13
  42, -- Prefix
   1, --Title
  41, --Short Title
  43, --ISBN 10
 235, --CopyRight Year
  54, --Type
   4, --Bisac Status
 245, -- Product Availability
   6, --Author
  40, --Author Type
  84, --Publish To Web
  10, --Media
  55, --Territory
 210, --Sales restrictions
  11, --Format
  89, --Carton Qty
  15, --Actual page Count
  16, --Estimated Page Count
  19, 20, 21, 22, --(Est vs Actual Trim Width and Length)
  23, --Publisher, Imprint, Division
 103, --Book Categories
  50, --Series 
  47, --Edition
  29, 30, --Grade Levels
  32, 33, --Age Levels
  52, --Volume
  38,39, --Bisac Heading Subheading
  7, 9, 100 --Price Type = 7, Actual Price: 9, Price Eff Date: 100
))
OR
(th.columnkey = 248 AND th.fielddesc = 'Country Of Origin')
OR 
(th.columnkey = 70 AND th.fielddesc like '%100-word front list catalog copy%')
)
)))

END
GO
Grant execute on dbo.IPUB_titles_updated_proc to Public
GO

--*************** NOW CREATE VIEWS ********************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[whdate_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[whdate_view]
GO
CREATE VIEW [dbo].[whdate_view] 
	(bookkey,printingkey,datetypecode,
	 activedate,actualind,recentchangeind,
	 lastuserid,lastmaintdate,estdate,
	 sortorder,bestdate)
as
select bookdates.bookkey,bookdates.printingkey,bookdates.datetypecode,
       bookdates.activedate,bookdates.actualind,bookdates.recentchangeind,
       bookdates.lastuserid,bookdates.lastmaintdate,
       bookdates.estdate,bookdates.sortorder,bookdates.bestdate from bookdates where datetypecode = 47

GO



--*************************************************************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[bookpublisher_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[bookpublisher_view]
GO
CREATE VIEW [dbo].[bookpublisher_view] 
(bookkey,orgentrydesc) 
AS 
select bookkey, orgentrydesc from orgentry o, bookorgentry b
where b.orgentrykey = o.orgentrykey and b.orglevelkey = o.orglevelkey
and b.orglevelkey = 1
GO

--*************************************************************************************
--NOW ADD FUNCTIONS




if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_author_pipe]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_author_pipe]
GO

CREATE FUNCTION [dbo].[get_author_pipe] 
			(@i_bookkey	INT,
			@i_order	INT,
			@i_type		INT,
			@v_name		VARCHAR(1))

RETURNS	VARCHAR(120)

/*  The purpose of the get_author functions is to return a specific author name from the author table based upon the bookkey.

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
			C = Complete Name (Authorkey1, Authortype1, Author First Name 1, Author Last Name 1)
			
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
	DECLARE @i_individualind	INT
   DECLARE @i_authortype 		INT
   DECLARE @v_authortypedesc 	VARCHAR (80) 


/*  GET AUTHOR KEY FOR AUTHOR TYPE and ORDER 	*/
	IF @i_type = 0
		BEGIN

			SELECT 	@i_authorkey = authorkey, @i_authortype = authortypecode
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
					AND sortorder = @i_order

		END

	IF @i_type > 0 
		BEGIN
			SELECT 	@i_authorkey = authorkey, @i_authortype = authortypecode				
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
					AND sortorder = @i_order
					AND authortypecode = @i_type
		END

/* GET AUTHOR NAME		*/

	SELECT @i_individualind = individualind
	FROM globalcontact
	WHERE globalcontactkey = @i_authorkey


	IF @i_individualind = 0	
		BEGIN
			SELECT @v_desc = lastname
			FROM	globalcontact
			WHERE globalcontactkey = @i_authorkey
		END

	ELSE
		BEGIN
			IF @v_name = 'C' 
				BEGIN
					SELECT @v_authortypedesc = g.datadesc
					FROM	gentables g
					WHERE	g.tableid = 134
						AND datacode = @i_authortype
						
	
					SELECT @v_firstname = firstname,
						@v_middlename = middlename,
						@v_lastname = lastname,
						@v_suffix = suffix
					FROM globalcontact
					WHERE globalcontactkey = @i_authorkey
		 
					SELECT @v_desc =  
						convert(varchar(12),@i_authorkey)  + '| '
                        				
						+CASE 
							WHEN @v_authortypedesc IS NULL THEN  '|'
							WHEN @v_authortypedesc IS NOT NULL THEN @v_authortypedesc + '| '
            						ELSE ''
          					END
						

						+CASE 
							WHEN @v_firstname IS  NULL THEN ''
	            					ELSE @v_firstname + ', '
	          				END

	          				

	          			+ @v_lastname
			
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
Grant execute on dbo.get_author_pipe to Public
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_author_all_name]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_author_all_name]
GO

CREATE FUNCTION [dbo].[get_author_all_name] 
			(@i_bookkey	INT,
			@i_numberofauthors	INT,
			@i_type		INT,
			@v_name varchar (1),
			@v_separator varchar (1))

RETURNS	VARCHAR(800)

/*  The purpose of the get_author_all_name function is to return names for 
each of the first n authors based upon the bookkey passed and number requested. 
The names wil be separated as a list with the separator specified
This functions uses the globalcontact table.

	PARAMETER OPTIONS

		@i_numberofauthors - number from 1-50 - the number of authors desired in the list. This will allow the user
to limit the number of authors - i.e. they may only want the first 4 authors in the returned string to 
limit the size.

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
		
		@v_separator = a single character to be added between multiple names i.e. ';' or ','.
		A single space will be added after the separator in the final result
		i.e. 'LastName1; LastName2; LastName3'

RETURN = varchar (8000)

EXAMPLE:
select dbo.get_author_all_name (b.bookkey, 5,0,'L', ';') as allauthorlastname
from book

REVISIONS:
1/8/2009 written by Doug Lessing
			
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(8000)
	DECLARE @v_desc			VARCHAR(8000)
	DECLARE @v_namedesc		VARCHAR(8000)
	DECLARE @i_order		int

/* parameter validations */
if @i_numberofauthors is null or @i_numberofauthors =0 or @i_numberofauthors > 50
	begin
	select @RETURN = 'invalid parameter number of authors: valid = 1-50'
	end

if @v_name not in ('D', 'C', 'F', 'M', 'L', 'S')
	begin
	select @RETURN = 'invalid parameter name type: valid = D, C, F, M, L, S'
	end


/** exit with error message if parameters not accepted **/
if len (@return) > 0
	begin
	return @return
	end

if @v_separator is null
	begin
	select @v_separator = ''
	end


	select @i_order =1
	while @i_order <= @i_numberofauthors
	begin

		select @v_namedesc = dbo.get_author_pipe (@i_bookkey,@i_order,@i_type,@v_name)
		
		if len (@v_namedesc) > 0
			begin
				IF LEN(@v_desc) > 0
					BEGIN
						SELECT @v_desc = @v_desc + @v_separator + ' ' + @v_namedesc
					END
				ELSE
					BEGIN
						SELECT @v_desc =  @v_namedesc
					END
		END
		
		select @i_order = @i_order + 1

end /*end while */

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
Grant execute on dbo.get_author_all_name to Public
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_allpricetype_final_effdate]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_allpricetype_final_effdate]
GO
CREATE FUNCTION [dbo].[get_allpricetype_final_effdate] 
			(@i_bookkey	INT,
			@i_numberofpricetypes	INT,
			@v_separator varchar (1))

RETURNS	VARCHAR(120)

AS

BEGIN

	DECLARE @RETURN			VARCHAR(8000)
	DECLARE @v_desc			VARCHAR(8000)
	DECLARE @v_namedesc		VARCHAR(8000)
	DECLARE @v_heading		VARCHAR(120)
	DECLARE @v_subheading	VARCHAR(120)
	DECLARE @i_order		int

/* parameter validations */
if @i_numberofpricetypes is null or @i_numberofpricetypes =0 or @i_numberofpricetypes > 50
	begin
	select @RETURN = 'invalid parameter number of categories: valid = 1-50'
	end


/** exit with error message if parameters not accepted **/
if len (@return) > 0
	begin
	return @return
	end

if @v_separator is null
	begin
	select @v_separator = ''
	end


	select @i_order =1
	while @i_order <= @i_numberofpricetypes
	begin

		select @v_namedesc = dbo.get_pricetype_final_effdate (@i_bookkey,@i_order)
		
		if len (@v_namedesc) > 0
			begin
				IF LEN(@v_desc) > 0
					BEGIN
						SELECT @v_desc = @v_desc + @v_separator + ' ' + @v_namedesc
					END
				ELSE
					BEGIN
						SELECT @v_desc =  @v_namedesc
					END
		END
		
		select @i_order = @i_order + 1

end /*end while */

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
Grant execute on dbo.get_allpricetype_final_effdate to Public
GO

--**********************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_orgentry_alt2]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_orgentry_alt2]
GO
CREATE FUNCTION [dbo].[get_orgentry_alt2]
    ( @bookkey as integer, @orglevelkey as smallint) 

RETURNS varchar(255)

/******************************************************************************
**  File: 
**  Name: [get_orgentry_alt2]
**  Desc: This function returns the alternate desc 2 from orgentry table

**
**
**    Auth: Tolga Tuncer
**    Date: 07 Jan 2010
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
	DECLARE @altdesc2 varchar(255)
	DECLARE @Return varchar(255)

	select @altdesc2 = o.altdesc2 FROM bookorgentry bo
	JOIN orgentry o
	ON bo.orgentrykey = o.orgentrykey and bo.orglevelkey = o.orglevelkey
	WHERE bo.orglevelkey = @orglevelkey
	and bo.bookkey = @bookkey

	If @altdesc2 is NULL
	SET @RETURN = ''
	Else
	SET @Return = @altdesc2

	RETURN @Return

END
GO
Grant execute on [dbo].[get_orgentry_alt2] to Public
GO


--********************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_bisac_heading_sub_heading_bisacdatacode]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_bisac_heading_sub_heading_bisacdatacode]
GO
CREATE FUNCTION [dbo].[get_bisac_heading_sub_heading_bisacdatacode] 
			(@i_bookkey	INT,
			@i_numberofcategories	INT,
			@v_separator varchar (1))

RETURNS	VARCHAR(120)


AS

BEGIN

	DECLARE @RETURN			VARCHAR(8000)
	DECLARE @v_desc			VARCHAR(8000)
	DECLARE @v_namedesc		VARCHAR(8000)
	DECLARE @v_heading		VARCHAR(120)
	DECLARE @v_subheading	VARCHAR(120)
	DECLARE @i_order		int

/* parameter validations */
if @i_numberofcategories is null or @i_numberofcategories =0 or @i_numberofcategories > 50
	begin
	select @RETURN = 'invalid parameter number of categories: valid = 1-50'
	end


/** exit with error message if parameters not accepted **/
if len (@return) > 0
	begin
	return @return
	end

if @v_separator is null
	begin
	select @v_separator = ''
	end


	select @i_order =1
	while @i_order <= @i_numberofcategories
	begin

		select @v_namedesc = dbo.get_bisaccategory_bisacdatacode (@i_bookkey,@i_order)
		
		if len (@v_namedesc) > 0
			begin
				IF LEN(@v_desc) > 0
					BEGIN
						SELECT @v_desc = @v_desc + @v_separator + ' ' + @v_namedesc
					END
				ELSE
					BEGIN
						SELECT @v_desc =  @v_namedesc
					END
		END
		
		select @i_order = @i_order + 1

end /*end while */

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
Grant execute on dbo.get_bisac_heading_sub_heading_bisacdatacode to Public
GO
--********************************************************************************




--**********************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_bisaccategory_bisacdatacode]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_bisaccategory_bisacdatacode]
GO
CREATE FUNCTION [dbo].[get_bisaccategory_bisacdatacode] 
			(@i_bookkey	INT,
			@i_order	INT)

RETURNS	VARCHAR(120)


AS

BEGIN

	DECLARE @RETURN			VARCHAR(240)
	DECLARE @v_bisacheading	VARCHAR(120)
	DECLARE @v_bisacsubheading VARCHAR(120)
   DECLARE @v_desc			VARCHAR(240)
	DECLARE @v_count		INT
   DECLARE @v_bisaccategorycode INT
   DECLARE @v_bisaccategorysubcode INT		
	


/*  GET bisaccategorycode and bisaccategorysubcode from bookbisaccategory 	*/
	SELECT @v_count = count(*)
     FROM bookbisaccategory
    WHERE bookkey = @i_bookkey
      AND sortorder = @i_order

	IF @v_count > 0 
   BEGIN
		SELECT @v_bisaccategorycode = bisaccategorycode, @v_bisaccategorysubcode = bisaccategorysubcode
		  FROM bookbisaccategory
		 WHERE bookkey = @i_bookkey
			AND sortorder = @i_order
		
		SELECT @v_bisacheading = bisacdatacode
        FROM gentables
       WHERE tableid = 339 and datacode = @v_bisaccategorycode

      IF @v_bisaccategorysubcode > 0 
      BEGIN
			SELECT @v_bisacsubheading = bisacdatacode
			  FROM subgentables
			 WHERE tableid = 339 and datacode = @v_bisaccategorycode and datasubcode = @v_bisaccategorysubcode
		END
      ELSE
      BEGIN
     		SELECT @v_bisacsubheading = ''
      END
      
		IF @v_bisacsubheading <> ''
      BEGIN
      	SELECT @v_desc = @v_bisacheading + '|' + @v_bisacsubheading
      END
      ELSE
      BEGIN
   		SELECT @v_desc = @v_bisacheading
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
Grant execute on dbo.[get_bisaccategory_bisacdatacode] to Public
GO
--********************************************************************************





--**********************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_bookcategory_all_category_externalcodes]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_bookcategory_all_category_externalcodes]
GO
CREATE FUNCTION [dbo].[get_bookcategory_all_category_externalcodes] 
			(@i_bookkey	INT,
			@i_numberofcategories	INT,
			@v_separator varchar (1))

RETURNS	VARCHAR(120)

/*  The purpose of the get_bookcategory_all_category_externalcodes function is to return 
the externalcode from gentables for each book category 
each of the first n categories based upon the bookkey passed and number requested. 
The names wil be separated as a list with the separator specified
This functions uses the bookcategory table.

	PARAMETER OPTIONS

		@i_numberofcategories - number from 1-50 - the number of categories desired in the list. This will allow the user
to limit the number of categories - i.e. they may only want the first 4 categories in the returned string to 
limit the size.
		
		@v_separator = a single character to be added between multiple names i.e. ';' or ','.
		A single space will be added after the separator in the final result
		

RETURN = varchar (8000)

EXAMPLE:
select dbo.get_bookcategory_all_categories (b.bookkey, 5, ';') as allcategories

REVISIONS:
11/14/2009 written by Tolga Tuncer
			
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(8000)
	DECLARE @v_desc			VARCHAR(8000)
	DECLARE @v_namedesc		VARCHAR(8000)
	DECLARE @v_heading		VARCHAR(120)
	DECLARE @v_subheading	VARCHAR(120)
	DECLARE @i_order		int

/* parameter validations */
if @i_numberofcategories is null or @i_numberofcategories =0 or @i_numberofcategories > 50
	begin
	select @RETURN = 'invalid parameter number of categories: valid = 1-50'
	end


/** exit with error message if parameters not accepted **/
if len (@return) > 0
	begin
	return @return
	end

if @v_separator is null
	begin
	select @v_separator = ''
	end


	select @i_order =1
	while @i_order <= @i_numberofcategories
	begin

		select @v_namedesc = dbo.get_bookcategory_externalcode (@i_bookkey,@i_order)
		
		if len (@v_namedesc) > 0
			begin
				IF LEN(@v_desc) > 0
					BEGIN
						SELECT @v_desc = @v_desc + @v_separator + ' ' + @v_namedesc
					END
				ELSE
					BEGIN
						SELECT @v_desc =  @v_namedesc
					END
		END
		
		select @i_order = @i_order + 1

end /*end while */

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
Grant execute on dbo.get_bookcategory_all_category_externalcodes to Public
GO
--********************************************************************************




--**********************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_bookcategory_externalcode]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_bookcategory_externalcode]
GO
CREATE FUNCTION [dbo].[get_bookcategory_externalcode] 
			(@i_bookkey	INT,
			@i_order	INT)

RETURNS	VARCHAR(120)

/*  The purpose of the get_bookcategory_extcode function is to return external code of a category based upon the bookkey.

	PARAMETER OPTIONS

		@i_Order
			1 = Returns first Category
			2 = Returns second Category
			3 = Returns third Category
		   .
			.
			.
			n
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(240)
	DECLARE @v_category		VARCHAR(120)
	DECLARE @v_desc			VARCHAR(240)
	DECLARE @v_count			INT
   DECLARE @v_categorycode INT
 
/*  GET categorycode from bookcategory 	*/
	SELECT @v_count = count(*)
     FROM bookcategory
    WHERE bookkey = @i_bookkey
      AND sortorder = @i_order

	IF @v_count > 0 
   BEGIN
		SELECT @v_categorycode = categorycode
		  FROM bookcategory
		 WHERE bookkey = @i_bookkey
			AND sortorder = @i_order
		
		SELECT @v_category = externalcode
        FROM gentables
       WHERE tableid = 317 and datacode = @v_categorycode

    
      
		IF @v_category <> ''
      BEGIN
      	SELECT @v_desc = @v_category 
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
Grant execute on dbo.get_bookcategory_externalcode to Public
GO
--********************************************************************************




--**********************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_BookMiscDesc]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_BookMiscDesc]
GO
CREATE FUNCTION [dbo].[get_BookMiscDesc]
		(@i_bookkey	INT,
		@tableid	int,
		@datacode int,
		@misckey int)

RETURNS VARCHAR(255)


AS

BEGIN

		DECLARE @RETURN				VARCHAR(255)
		DECLARE @v_desc				VARCHAR(255)

		Select @v_desc = datadesc FROM bookmisc bm 
		JOIN subgentables sg on bm.longvalue = sg.datasubcode 
		WHERE sg.tableid = @tableid and sg.datacode = @datacode and bm.bookkey = @i_bookkey
		and bm.misckey = @misckey

				
		IF datalength(@v_desc) > 0
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
Grant execute on dbo.get_BookMiscDesc to Public
GO
--********************************************************************************



--**********************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_pricetype_final_effdate]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_pricetype_final_effdate]
GO
CREATE FUNCTION dbo.get_pricetype_final_effdate 
			(@i_bookkey	INT,
			@i_order	INT)

RETURNS	VARCHAR(240)


AS

BEGIN

	DECLARE @RETURN			VARCHAR(240)
	DECLARE @v_return	VARCHAR(240)
	DECLARE @v_desc			VARCHAR(240)
	DECLARE @v_count			INT
    DECLARE @v_price varchar(30)
    DECLARE @v_effdate varchar(10)
 

	SELECT @v_count = count(*)
     FROM bookprice
    WHERE bookkey = @i_bookkey
      AND sortorder = @i_order

	IF @v_count > 0 
    BEGIN


		Select @v_desc = g.datadescshort, @v_price = bp.finalprice, 
		@v_effdate = Convert(varchar(10), effectivedate, 101)  
		FROM bookprice bp
		JOIN gentables g
		ON bp.pricetypecode = g.datacode 
		WHERE g.tableid= 306 and bp.bookkey = @i_bookkey
		AND bp.sortorder = @i_order

		If LEN(@v_desc) > 0 
			Select @v_return = LTRIM(RTRIM(@v_desc)) + '|'
		ELSE
			Select @v_return = '|'
		
		IF LEN(@v_price) > 0 
			Select @v_return = @v_return + LTRIM(RTRIM(@v_price)) + '|'
		ELSE
			Select @v_return = @v_return + '|'
		
		IF LEN(@v_effdate) > 0 
			Select @v_return = @v_return + LTRIM(RTRIM(@v_effdate)) 
--		ELSE
--			Select @v_return = @v_return + ','
      
   END


	IF LEN(@v_return) > 0
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_return))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END
RETURN @RETURN
END


GO
Grant execute on dbo.get_pricetype_final_effdate to Public
GO
--********************************************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_author]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_author]
GO

CREATE FUNCTION [dbo].[get_author] 
			(@i_bookkey	INT,
			@i_order	INT,
			@i_type		INT,
			@v_name		VARCHAR(1))

RETURNS	VARCHAR(120)

/*  The purpose of the get_author functions is to return a specific author name from the author table based upon the bookkey.

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
			C = Complete Name (Authorkey1, Authortype1, Author First Name 1, Author Last Name 1)
			
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
	DECLARE @i_individualind	INT
   DECLARE @i_authortype 		INT
   DECLARE @v_authortypedesc 	VARCHAR (80) 


/*  GET AUTHOR KEY FOR AUTHOR TYPE and ORDER 	*/
	IF @i_type = 0
		BEGIN

			SELECT 	@i_authorkey = authorkey, @i_authortype = authortypecode
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
					AND sortorder = @i_order

		END

	IF @i_type > 0 
		BEGIN
			SELECT 	@i_authorkey = authorkey, @i_authortype = authortypecode				
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
					AND sortorder = @i_order
					AND authortypecode = @i_type
		END

/* GET AUTHOR NAME		*/

	SELECT @i_individualind = individualind
	FROM globalcontact
	WHERE globalcontactkey = @i_authorkey


	IF @i_individualind = 0	
		BEGIN
			SELECT @v_desc = lastname
			FROM	globalcontact
			WHERE globalcontactkey = @i_authorkey
		END

	ELSE
		BEGIN
			IF @v_name = 'C' 
				BEGIN
					SELECT @v_authortypedesc = g.datadesc
					FROM	gentables g
					WHERE	g.tableid = 134
						AND datacode = @i_authortype
						
	
					SELECT @v_firstname = firstname,
						@v_middlename = middlename,
						@v_lastname = lastname,
						@v_suffix = suffix
					FROM globalcontact
					WHERE globalcontactkey = @i_authorkey
		 
					SELECT @v_desc =  
						convert(varchar(12),@i_authorkey)  + ', '
                        				
						+CASE 
							WHEN @v_authortypedesc IS NULL THEN  ''
							WHEN @v_authortypedesc IS NOT NULL THEN @v_authortypedesc + ', '
            						ELSE ''
          					END
						

						+CASE 
							WHEN @v_firstname IS  NULL THEN ''
	            					ELSE @v_firstname + ', '
	          				END

	          				

	          			+ @v_lastname
			
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
Grant execute on dbo.get_author to Public
GO

--****************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_bisaccategory2]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_bisaccategory2]
GO

CREATE FUNCTION [dbo].[get_bisaccategory2] 
			(@i_bookkey	INT,
			@i_order	INT)

RETURNS	VARCHAR(120)

/*  The purpose of the get_bisaccategory functions is to return a specific category heading /subheading from  the bookbisaccategory table based upon the bookkey.

	PARAMETER OPTIONS

		@i_Order
			1 = Returns first Category
			2 = Returns second Category
			3 = Returns third Category
		   .
			.
			.
			n
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(240)
	DECLARE @v_bisacheading	VARCHAR(120)
	DECLARE @v_bisacsubheading VARCHAR(120)
   DECLARE @v_desc			VARCHAR(240)
	DECLARE @v_count		INT
   DECLARE @v_bisaccategorycode INT
   DECLARE @v_bisaccategorysubcode INT		
	


/*  GET bisaccategorycode and bisaccategorysubcode from bookbisaccategory 	*/
	SELECT @v_count = count(*)
     FROM bookbisaccategory
    WHERE bookkey = @i_bookkey
      AND sortorder = @i_order

	IF @v_count > 0 
   BEGIN
		SELECT @v_bisaccategorycode = bisaccategorycode, @v_bisaccategorysubcode = bisaccategorysubcode
		  FROM bookbisaccategory
		 WHERE bookkey = @i_bookkey
			AND sortorder = @i_order
		
		SELECT @v_bisacheading = datadesc
        FROM gentables
       WHERE tableid = 339 and datacode = @v_bisaccategorycode

      IF @v_bisaccategorysubcode > 0 
      BEGIN
			SELECT @v_bisacsubheading = datadesc
			  FROM subgentables
			 WHERE tableid = 339 and datacode = @v_bisaccategorycode and datasubcode = @v_bisaccategorysubcode
		END
      ELSE
      BEGIN
     		SELECT @v_bisacsubheading = ''
      END
      
		IF @v_bisacsubheading <> ''
      BEGIN
      	SELECT @v_desc = @v_bisacheading + '|' + @v_bisacsubheading
      END
      ELSE
      BEGIN
   		SELECT @v_desc = @v_bisacheading
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
Grant execute on dbo.get_bisaccategory2 to Public
GO



--**********************************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_bisac_heading_sub_heading]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_bisac_heading_sub_heading]
GO

CREATE FUNCTION [dbo].[get_bisac_heading_sub_heading] 
			(@i_bookkey	INT,
			@i_numberofcategories	INT,
			@v_separator varchar (1))

RETURNS	VARCHAR(120)

/*  The purpose of the get_bisac_heading_sub_heading function is to return bisac heading/subheading for 
each of the first n categories based upon the bookkey passed and number requested. 
The names wil be separated as a list with the separator specified
This functions uses the bookbisaccategory table.

	PARAMETER OPTIONS

		@i_numberofcategories - number from 1-50 - the number of categories desired in the list. This will allow the user
to limit the number of categories - i.e. they may only want the first 4 categories in the returned string to 
limit the size.
		
		@v_separator = a single character to be added between multiple names i.e. ';' or ','.
		A single space will be added after the separator in the final result
		i.e. 'LastName1; LastName2; LastName3'

RETURN = varchar (8000)

EXAMPLE:
select dbo.get_bisac_heading_sub_heading (b.bookkey, 5, ';') as allbisacinfo

REVISIONS:
6/5/2009 written by Kusum Basra
			
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(8000)
	DECLARE @v_desc			VARCHAR(8000)
	DECLARE @v_namedesc		VARCHAR(8000)
	DECLARE @v_heading		VARCHAR(120)
	DECLARE @v_subheading	VARCHAR(120)
	DECLARE @i_order		int

/* parameter validations */
if @i_numberofcategories is null or @i_numberofcategories =0 or @i_numberofcategories > 50
	begin
	select @RETURN = 'invalid parameter number of categories: valid = 1-50'
	end


/** exit with error message if parameters not accepted **/
if len (@return) > 0
	begin
	return @return
	end

if @v_separator is null
	begin
	select @v_separator = ''
	end


	select @i_order =1
	while @i_order <= @i_numberofcategories
	begin

		select @v_namedesc = dbo.get_bisaccategory2 (@i_bookkey,@i_order)
		
		if len (@v_namedesc) > 0
			begin
				IF LEN(@v_desc) > 0
					BEGIN
						SELECT @v_desc = @v_desc + @v_separator + ' ' + @v_namedesc
					END
				ELSE
					BEGIN
						SELECT @v_desc =  @v_namedesc
					END
		END
		
		select @i_order = @i_order + 1

end /*end while */

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
Grant execute on dbo.[get_bisac_heading_sub_heading] to Public
GO

--****************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_allpricetype_externalcode]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_allpricetype_externalcode]
GO
CREATE FUNCTION [dbo].[get_allpricetype_externalcode] 
			(@i_bookkey	INT,
			@i_numberofpricetypes	INT,
			@v_separator varchar (1))

RETURNS	VARCHAR(120)

AS

BEGIN

	DECLARE @RETURN			VARCHAR(8000)
	DECLARE @v_desc			VARCHAR(8000)
	DECLARE @v_namedesc		VARCHAR(8000)
	DECLARE @v_heading		VARCHAR(120)
	DECLARE @v_subheading	VARCHAR(120)
	DECLARE @i_order		int

/* parameter validations */
if @i_numberofpricetypes is null or @i_numberofpricetypes =0 or @i_numberofpricetypes > 50
	begin
	select @RETURN = 'invalid parameter number of categories: valid = 1-50'
	end


/** exit with error message if parameters not accepted **/
if len (@return) > 0
	begin
	return @return
	end

if @v_separator is null
	begin
	select @v_separator = ''
	end


	select @i_order =1
	while @i_order <= @i_numberofpricetypes
	begin

		select @v_namedesc = dbo.get_pricetype_externalcode(@i_bookkey,@i_order)
		
		if len (@v_namedesc) > 0
			begin
				IF LEN(@v_desc) > 0
					BEGIN
						SELECT @v_desc = @v_desc + @v_separator + ' ' + @v_namedesc
					END
				ELSE
					BEGIN
						SELECT @v_desc =  @v_namedesc
					END
		END
		
		select @i_order = @i_order + 1

end /*end while */

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
Grant execute on dbo.get_allpricetype_externalcode to Public
GO


--*****************************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_pricetype_externalcode]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[get_pricetype_externalcode]
GO

CREATE FUNCTION [dbo].[get_pricetype_externalcode] 
			(@i_bookkey	INT,
			@i_order	INT)

RETURNS	VARCHAR(240)


AS

BEGIN

	DECLARE @RETURN			VARCHAR(240)
	DECLARE @v_return	VARCHAR(240)
	DECLARE @v_desc			VARCHAR(240)
	DECLARE @v_count			INT
     

	SELECT @v_count = count(*)
     FROM bookprice
    WHERE bookkey = @i_bookkey
      AND sortorder = @i_order

	IF @v_count > 0 
    BEGIN


		Select @v_desc = g.externalcode  
		FROM bookprice bp
		JOIN gentables g
		ON bp.pricetypecode = g.datacode 
		WHERE g.tableid= 306 and bp.bookkey = @i_bookkey
		AND bp.sortorder = @i_order

		If LEN(@v_desc) > 0 
			Select @v_return = LTRIM(RTRIM(@v_desc)) 
		ELSE
			Select @v_return = '|'
      
   END


	IF LEN(@v_return) > 0
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_return))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END
RETURN @RETURN
END
GO
Grant execute on dbo.get_pricetype_externalcode to Public
GO


--**************************************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IPUB_title_info_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[IPUB_title_info_view]
GO
CREATE VIEW [dbo].[IPUB_title_info_view] as
SELECT
b.bookkey,
p.printingkey,
i.ean13 as isbn13,
titleprefixandtitle = 
	CASE 
		WHEN (bd.titleprefix IS NOT NULL AND  bd.titleprefix <> '')
			 THEN bd.titleprefix + ' ' + b.title
		WHEN (bd.titleprefix IS NULL OR bd.titleprefix = ' ') 
			 THEN b.title
	 END,
b.shorttitle as shorttitle,
itemnumber =
  CASE
   WHEN (i.isbn is null)
     THEN i.itemnumber
   END,
i.isbn10 as isbn10,
bd.copyrightyear as copyrightyear,
pubdate = COALESCE(pubdate_view.activedate,pubdate_view.bestdate),
warehousedate = COALESCE(whdate_view.activedate,whdate_view.bestdate),
(select datadesc from gentables where tableid = 132 and datacode = b.titletypecode) as typedesc,
(select externalcode from gentables where tableid = 132 and datacode = b.titletypecode) as typecode,

--officialoutofprintdate = COALESCE(officialoutofprintdate_view.activedate,officialoutofprintdate_view.bestdate),
--titlehistorytitle_created_view.minlastmaintdate as title,
--distrbuted =
--	CASE
--		WHEN bookdivision_view.orgentrydesc = 'Discovery House Publishers'
--			THEN 'Distributed'
--	END,
outofprint =
	CASE
		WHEN bd.bisacstatuscode = 2 OR b.titletypecode = 30
			THEN 'Out of Print'
		END,
outofprintcode =
	CASE
		WHEN bd.bisacstatuscode = 2 OR b.titletypecode = 30
			THEN 'P'
		END,
(dbo.get_author_all_name (b.bookkey, 10,0,'C', ';')) as authors,
--(select datadesc from gentables where tableid = 459 and datacode = bd.discountcode) as discount,
bd.publishtowebind as publishtoweb,
--Is this a set? media = prepack yes, otherwise no
IsSet = Case when bd.mediatypecode = 13 THEN 'Yes' ELSE 'No' End,
PrepackCode = Case when bd.mediatypecode = 13 THEN 
(Select externalcode from subgentables where tableid=312 and datacode=13 and datasubcode = bd.mediatypesubcode)
End,

(dbo.get_bookcategory_all_categories (b.bookkey, 1, ';')) as categories,
(dbo.get_bookcategory_all_category_externalcodes (b.bookkey, 1,';')) as category_codes,
--returncode = 
--	CASE 
--     WHEN (bd.returncode = 2)
--      THEN 'Y'
--   END,
--rtnrestriction =
--	CASE
--		WHEN (bd.restrictioncode = 1)
-- 			THEN 'N'
--   END,
(select datadesc from gentables where tableid = 131 and datacode = b.territoriescode) as territories,
(select datadesc from gentables where tableid = 428 and datacode = bd.canadianrestrictioncode) as salesrestrictions,
(select datadesc from subgentables where tableid = 312 and datacode = bd.mediatypecode and datasubcode = bd.mediatypesubcode) as titleformat,
(select externalcode from subgentables where tableid = 312 and datacode = bd.mediatypecode and datasubcode = bd.mediatypesubcode) as titleformatcode,
(select datadesc from gentables where tableid = 312 and datacode = bd.mediatypecode) as media,
(select externalcode from gentables where tableid = 312 and datacode = bd.mediatypecode) as mediacode,
cartonqty = bindingspecs.cartonqty1,
pagecount = COALESCE(p.pagecount,p.tmmpagecount,p.tentativepagecount),
trimwidth = COALESCE(p.trimsizewidth,p.tmmactualtrimwidth,p.esttrimsizewidth),
trimlength = COALESCE(p.trimsizelength,p.tmmactualtrimlength,p.esttrimsizelength),
bookpublisher_view.orgentrydesc as publisher,
bookdivision_view.orgentrydesc as division,
bookimprint_view.orgentrydesc as imprint,
[dbo].[get_orgentry_alt2](b.bookkey, 1) as publisher_code,
[dbo].[get_orgentry_alt2](b.bookkey, 2) as division_code,
[dbo].[get_orgentry_alt2](b.bookkey, 3) as imprint_code,
dbo.qweb_get_Series(b.bookkey, 'D') as Series,
dbo.qweb_get_Series(b.bookkey, 'E') as SeriesCode,
dbo.get_Edition(b.bookkey, 'D') as Edition,
bd.gradelow as gradelevellow,
bd.gradehigh as gradelevelhigh,
bd.agelow as agelevellow,
bd.agehigh as agelevelhigh,
bd.volumenumber as volume,
(dbo.get_BookMiscDesc(b.bookkey, 525,4, 9)) as CountryOfOrigin,
(dbo.get_bisac_heading_sub_heading (b.bookkey, 5, ';')) as bisacheadingsubheading,
(dbo.get_bisac_heading_sub_heading_bisacdatacode (b.bookkey, 5, ';')) as bisacheadingsubheading_code,
([dbo].[get_allpricetype_final_effdate] (b.bookkey,5,';')) as pricetype_final_effdate,
(dbo.get_allpricetype_externalcode(b.bookkey, 5,';')) as pricetype_code,
--dbo.get_Comment_HTMLLITE(b.bookkey, 3,8) as [100WordFrontListCopy]
[dbo].[rpt_get_book_comment] (b.bookkey, 3, 8, 1) as [100WordFrontListCopy]
From book b 
 FULL OUTER JOIN printing AS p ON (b.bookkey = p.bookkey) 
 FULL OUTER JOIN isbn AS i ON (b.bookkey = i.bookkey) 
 FULL OUTER JOIN bookdetail AS bd  ON (b.bookkey = bd.bookkey) 
LEFT OUTER JOIN pubdate_view ON p.bookkey = pubdate_view.bookkey AND p.printingkey = pubdate_view.printingkey 
LEFT OUTER JOIN whdate_view ON p.bookkey = whdate_view.bookkey AND p.printingkey = whdate_view.printingkey 
--LEFT OUTER JOIN officialoutofprintdate_view ON p.bookkey = officialoutofprintdate_view.bookkey AND p.printingkey = officialoutofprintdate_view.printingkey
--FULL OUTER JOIN titlehistorytitle_created_view ON p.bookkey = titlehistorytitle_created_view.bookkey AND p.printingkey = titlehistorytitle_created_view.printingkey 
FULL OUTER JOIN bindingspecs ON p.bookkey = bindingspecs.bookkey AND p.printingkey = bindingspecs.printingkey 
LEFT OUTER JOIN bookdivision_view ON p.bookkey = bookdivision_view.bookkey 
LEFT OUTER JOIN bookimprint_view ON p.bookkey = bookimprint_view.bookkey
LEFT OUTER JOIN bookpublisher_view ON p.bookkey = bookpublisher_view.bookkey
--LEFT OUTER JOIN datehistory dh on p.bookkey = dh.bookkey 
WHERE p.printingkey=1
AND b.standardind <> 'Y'
GO
--Grant execute on dbo.title_info_view_IPUB to Public
--GO



-- ************* INBOUND FEED ******************************************

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IPUB_TMM_Inbound]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.IPUB_TMM_Inbound
GO

CREATE PROCEDURE dbo.IPUB_TMM_Inbound
@bookkey int,
@FrontBackListFlag char(1),
@BookWeight float 
AS
BEGIN

--If Not Exists (Select * FROM book where bookkey = @bookkey)

If @FrontBackListFlag = 'F'
	BEGIN
		DECLARE @i_titletypecode int,
		@bisacstatuscode smallint,
		@productavailability int	

		Select @i_titletypecode = b.titletypecode, @bisacstatuscode = bd.bisacstatuscode,
		@productavailability = bd.prodavailability
		FROM book b
		join bookdetail bd
		on b.bookkey = bd.bookkey
		where b.bookkey = @bookkey
--		b.titletypecode <> 27  
--		or bd.bisacstatuscode <> 1
--		or bd.productavailability <> 2
	
		Declare @stringvalue_type varchar(255)
		Declare @stringvalue_bisacstatus varchar(255)
		Declare @stringvalue_prodavailability varchar(255)
		SET @stringvalue_type = null
		SET @stringvalue_bisacstatus = null
		SET @stringvalue_prodavailability = null
		DECLARE @feedin_count2 int
		DECLARE @feedin_count3 int
				
			


		If @i_titletypecode is null
			BEGIN
				SET @stringvalue_type = '(Not Present)'
			END
			
		else
			BEGIN
				Select @stringvalue_type = datadesc from gentables where tableid = 132 and datacode = @i_titletypecode
			END

		IF @stringvalue_type is not null and (@i_titletypecode is null OR @i_titletypecode <> 27)
			BEGIN
				DECLARE @lastmaintdate datetime
				SET @lastmaintdate = getdate()

				insert into titlehistory (bookkey,printingkey,columnkey,lastmaintdate,stringvalue,lastuserid,
					currentstringvalue,fielddesc) 
				values (@bookkey,1,54,@lastmaintdate,@stringvalue_type,'IPUBFEED',
					'Frontlist','Type')

				Update book
				SET titletypecode = 27
				FROM book b
				WHERE b.bookkey = @bookkey 
--				and b.titletypecode <> 27

				
			END
			


			If @bisacstatuscode is null
				BEGIN
					SET @stringvalue_bisacstatus = '(Not Present)'
				END
			ELSE
				BEGIN
					Select @stringvalue_bisacstatus = datadesc from gentables where tableid = 314 and datacode = @bisacstatuscode
				END

			IF @stringvalue_bisacstatus is not null and (@bisacstatuscode is null or @bisacstatuscode <> 1) -- update only if it is not already set to Available- In Stock 
				BEGIN

					insert into titlehistory (bookkey,printingkey,columnkey,lastmaintdate,stringvalue,lastuserid,
						currentstringvalue,fielddesc)
					values (@bookkey,1,4,getdate(),@stringvalue_bisacstatus,'IPUBFEED',
						'Available- In Stock','BISAC Status')

					Update bookdetail
					SET bisacstatuscode = 1
					FROM bookdetail bd
					WHERE bd.bookkey = @bookkey
--					and bd.bisacstatuscode <> 1
					/** Resend title to Eloquence-set bookedistatus.edistatuscode to Resend (3)
					Only resend if the title has been sent to elo before (previousedistatuscode=4)
					and edistatuscode = 4 
					edistatuscode 1 and 2, title is already in outbox. same with 3
					don't update if marked error (5), delete(6) or never send - do not send (8 & 7)
					
					**/
					
					select @feedin_count2 = 0
					select @feedin_count2 = count(*) from bookedistatus
					where printingkey = 1 and bookkey = @bookkey 
					and previousedistatuscode = 4
					and edistatuscode = 4

					if @feedin_count2 > 0 
					begin
						update bookedipartner set sendtoeloquenceind = 1
						where printingkey =1 and bookkey = @bookkey

						update bookedistatus set edistatuscode=3
						where bookkey=@bookkey
						and printingkey=1

					end

				END
		

				If @productavailability is null
					BEGIN
						SET @stringvalue_prodavailability = '(Not Present)'
					END
				ELSE
					BEGIN
						Select @stringvalue_prodavailability = datadesc FROM subgentables where tableid = 314 and datacode = 1 and datasubcode = @productavailability
					END

				IF @stringvalue_prodavailability is not null and ( @productavailability is null or @productavailability <> 2)
					BEGIN

						insert into titlehistory (bookkey,printingkey,columnkey,lastmaintdate,stringvalue,lastuserid,
							currentstringvalue,fielddesc)
						values (@bookkey,1,245,getdate(),@stringvalue_prodavailability,'IPUBFEED',
							'Available','Product Availability')

						Update bookdetail
						SET prodavailability = 2
						FROM bookdetail bd
						WHERE bd.bookkey = @bookkey
						
						select @feedin_count2 = 0
						select @feedin_count2 = count(*) from bookedistatus
						where printingkey = 1 and bookkey = @bookkey 
						and previousedistatuscode = 4
						and edistatuscode = 4

						if @feedin_count2 > 0 
						begin
							update bookedipartner set sendtoeloquenceind = 1
							where printingkey =1 and bookkey = @bookkey

							update bookedistatus set edistatuscode=3
							where bookkey=@bookkey
							and printingkey=1

						end

						
					END
	END


--Now do the backlist
If @FrontBackListFlag = 'B'
	BEGIN
		DECLARE @titletypecode int
		Declare @stringvalue varchar(255)
		SET @stringvalue = null
		SET @titletypecode = NULL

		Select @titletypecode = b.titletypecode from book b
		where b.bookkey = @bookkey
--		b.titletypecode <> 17 

				If @titletypecode is null
					BEGIN
						SET @stringvalue = '(Not Present)'
					END
				ELSE
					BEGIN
						Select @stringvalue = datadesc from gentables where tableid = 132 and datacode = @titletypecode
					END

				IF @stringvalue is not null and (@titletypecode is null or @titletypecode <> 17)
					BEGIN


						insert into titlehistory (bookkey,printingkey,columnkey,lastmaintdate,stringvalue,lastuserid,
							currentstringvalue,fielddesc)
						values (@bookkey,1,54,getdate(),@stringvalue,'IPUBFEED',
							'Backlist','Type')
						
						Update book
						SET titletypecode = 17
						FROM book b
						WHERE b.bookkey = @bookkey and 
						b.titletypecode <> 17

					END

	END

--Now BookWeight, if bookweight is null or '' ignore

IF @BookWeight > 0
  BEGIN
			DECLARE @book_weight float
			DECLARE @s_bw_value varchar(255)
			DECLARE @bookweightunitofmeasure int
			DECLARE @s_uom int
			DECLARE @s_uom_value varchar(255)

			SET @s_bw_value = null
			SET @s_uom = null
			SET @s_uom_value = null
			SET @book_weight = null
			SET @bookweightunitofmeasure = null
			SELECT @book_weight = bookweight, @s_uom = bookweightunitofmeasure from printing where bookkey = @bookkey


			If @book_weight is null
				BEGIN
					SET @s_bw_value = '(Not Present)'
				END
			ELSE
				BEGIN
					Select @s_bw_value = Cast(@book_weight as varchar(10))
				END

			If @s_bw_value is not null and (@book_weight is null OR @BookWeight <> @book_weight)
				BEGIN
					insert into titlehistory (bookkey,printingkey,columnkey,lastmaintdate,stringvalue,lastuserid,
						currentstringvalue,fielddesc)
					values (@bookkey,1,96,getdate(),@s_bw_value,'IPUBFEED',
						Cast(@BookWeight as varchar(10)),'Book Weight')

					Update printing
					SET bookweight = @BookWeight
					FROM printing p
					WHERE p.bookkey = @bookkey 
				END
			

			If @s_uom is null
				BEGIN
					SET @s_uom_value = '(Not Present)'
				END
			ELSE
				BEGIN
					Select @s_uom_value = datadesc from gentables where tableid=613 and datacode = @s_uom
				END

			If @s_uom_value is not null and (@s_uom is null or @s_uom <> 5)
				BEGIN
					insert into titlehistory (bookkey,printingkey,columnkey,lastmaintdate,stringvalue,lastuserid,
						currentstringvalue,fielddesc)
					values (@bookkey,1,96,getdate(),@s_uom_value,'IPUBFEED',
						'Ounces','Book Weight Unit of Measure')
					
					Update printing
					SET bookweightunitofmeasure = 5
					FROM printing p
					WHERE p.bookkey = @bookkey


				END

	END

END





GO
Grant execute on dbo.IPUB_TMM_Inbound to Public
GO

--CREATE THE TRIGGER

--if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertInto_Ipub_title_updated]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
--drop trigger dbo.[InsertInto_Ipub_title_updated]
--GO
--CREATE trigger [dbo].[InsertInto_Ipub_title_updated]
--ON [dbo].[titlechangedinfo]
--FOR INSERT, UPDATE
--AS
--/*Need to check if this bookkey already exists in IPUB_Title_Updated table
--If not, it gets added 5 times. Triggers on other tables must be updating this table
--
--*/
--If not exists (Select * FROM dbo.IPUB_Title_Updated where bookkey = (select bookkey from [inserted]))
--	BEGIN
--			Insert into dbo.IPUB_title_updated
--			SELECT Distinct
--			b.bookkey
--			From book b 
--			FULL OUTER JOIN printing AS p ON (b.bookkey = p.bookkey)
--			JOIN [inserted] i 
--			ON b.bookkey = i.bookkey 
--			WHERE p.printingkey=1
--			AND b.standardind <> 'Y'
--			and
--			(
--			(
--			b.bookkey in (Select dh.bookkey from datehistory dh where dh.datetypecode in (8,47) -- 8 pubdate, 47 warehouse date
--			and dh.lastmaintdate > i.lastchangedate - (((5.0/60.0)/60.0)/24.0 )) -- check last 5 seconds, there might be multiple updates to the title therefore multiple rows in titlehistory or datehistory tables
--			)
--			OR
--			(b.bookkey in (Select th.bookkey from titlehistory th join titlechangedinfo tci on th.bookkey = tci.bookkey
--			where th.lastmaintdate > i.lastchangedate - (((5.0/60.0)/60.0)/24.0 ) 
--			and
--			( 
--			(
--			th.columnkey in
--			( 45, --ISBN-13
--			  42, -- Prefix
--			   1, --Title
--			  41, --Short Title
--			  43, --ISBN 10
--			 235, --CopyRight Year
--			  54, --Type
--			   4, --Bisac Status
--			 245, -- Product Availability
--			   6, --Author
--			  40, --Author Type
--			  84, --Publish To Web
--			  10, --Media
--			  55, --Territory
--			 210, --Sales restrictions
--			  11, --Format
--			  89, --Carton Qty
--			  15, --Actual page Count
--			  16, --Estimated Page Count
--			  19, 20, 21, 22, --(Est vs Actual Trim Width and Length)
--			  23, --Publisher, Imprint, Division
--			 103, --Book Categories
--			  50, --Series 
--			  47, --Edition
--			  29, 30, --Grade Levels
--			  32, 33, --Age Levels
--			  52, --Volume
--			  38,39, --Bisac Heading Subheading
--			  7, 9, 100 --Price Type = 7, Actual Price: 9, Price Eff Date: 100
--			))
--			OR
--			(th.columnkey = 248 AND th.fielddesc = 'Country Of Origin')
--			OR 
--			(th.columnkey = 70 AND th.fielddesc like '%100-word front list catalog copy%')
--			)
--			)))	
--	END

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertBookkeyTo_IPUB_Title_Updated]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger dbo.[InsertBookkeyTo_IPUB_Title_Updated]
GO
CREATE trigger [dbo].[InsertBookkeyTo_IPUB_Title_Updated]
ON [dbo].[titlehistory]
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @bookkey int
	DECLARE @lastuserid varchar(100)
	DECLARE @itemnumber varchar(20)
	DECLARE @ean13 varchar(13)
	--DECLARE @lastmaintdate datetime

	Select @bookkey = bookkey,
	@lastuserid = lastuserid,
	@ean13 = dbo.get_isbn(bookkey, 17)
	--, @lastmaintdate = lastmaintdate 
	from inserted
	
	Select @itemnumber = itemnumber from isbn where bookkey = @bookkey

	If NOT (@ean13 = '' AND @itemnumber is NULL)
	BEGIN
		IF NOT EXISTS(Select * FROM IPUB_Title_Updated where bookkey = @bookkey)
			BEGIN
				If Exists (Select * FROM inserted where columnkey in 
					( 45, --ISBN-13
					  42, -- Prefix
					   1, --Title
					  41, --Short Title
					  43, --ISBN 10
					 235, --CopyRight Year
					  54, --Type
					   4, --Bisac Status
					 245, -- Product Availability
					   6, --Author
					  40, --Author Type
					  84, --Publish To Web
					  10, --Media
					  55, --Territory
					 210, --Sales restrictions
					  11, --Format
					  89, --Carton Qty
					  15, --Actual page Count
					  16, --Estimated Page Count
					  19, 20, 21, 22, --(Est vs Actual Trim Width and Length)
					  23, --Publisher, Imprint, Division
					 103, --Book Categories
					  50, --Series 
					  47, --Edition
					  29, 30, --Grade Levels
					  32, 33, --Age Levels
					  52, --Volume
					  38,39, --Bisac Heading Subheading
					  7, 9, 100 --Price Type = 7, Actual Price: 9, Price Eff Date: 100
					)
					OR
					(columnkey = 248 AND fielddesc = 'Country Of Origin')
					OR 
					(columnkey = 70 AND fielddesc like '%100-word front list catalog copy%')
					) AND @lastuserid <> 'IPUBFEED'
					BEGIN
						Insert dbo.IPUB_Title_Updated (bookkey) VALUES (@bookkey)
					END
			END
			ELSE
				BEGIN
					Update dbo.IPUB_Title_Updated
					SET UPDATED = 0
					WHERE bookkey = @bookkey
				END
	END

END

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertInto_IPUB_Title_Updated]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger dbo.[InsertInto_IPUB_Title_Updated]
GO
CREATE trigger [dbo].[InsertInto_IPUB_Title_Updated]
ON [dbo].[datehistory]
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @bookkey int
	DECLARE @itemnumber varchar(20)
	DECLARE @ean13 varchar(13)

	Select @bookkey = bookkey,
	@ean13 = dbo.get_isbn(bookkey, 17) 
	from inserted

	Select @itemnumber = itemnumber from isbn where bookkey = @bookkey

	If NOT (@ean13 = '' AND @itemnumber is NULL)
	BEGIN
		IF NOT EXISTS(Select * FROM IPUB_Title_Updated where bookkey = @bookkey)
			BEGIN
				If Exists (Select * FROM inserted where datetypecode in (8,47)) -- 8 pubdate, 47 warehouse date 
					BEGIN
						Insert dbo.IPUB_Title_Updated (bookkey) VALUES (@bookkey)
					END
			END
		  ELSE
				BEGIN
					Update dbo.IPUB_Title_Updated
					SET UPDATED = 0
					WHERE bookkey = @bookkey
				END
	END
END






