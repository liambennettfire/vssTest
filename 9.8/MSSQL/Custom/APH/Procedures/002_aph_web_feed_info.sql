/****** Object:  StoredProcedure [dbo].[aph_web_feed_info]    Script Date: 12/09/2008 15:10:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_info]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[aph_web_feed_info]

/****** Object:  StoredProcedure [dbo].[aph_web_feed_info]    Script Date: 12/09/2008 15:09:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









--11/17/08 JLH - After running this new version of code once to write out bookdates records,
--go down to line 523 to correpsonding comment says to Uncomment the code that deletes from
--feedout_titles table.  Run sql to insert datetype.  Stored in u:\jhurd\aph\ecommerce_datetype_insert.sql.

--5/21/08 JLH
--Results from user testing found we need to add an extra " in front of any " in the data values.
--We also need to put "'s around data values if there is a comma in the data value.
--In order to not duplicate the "'s that we add due to the commas, the double " from the first step
--should be done prior to adding the " around the values with commas.

CREATE proc [dbo].[aph_web_feed_info]
AS

BEGIN
declare @numrows	int,
@minsort			int,
@rownum				int,
@numcols			int,
@qsibatchkey		int,
@qsijobkey			int,
@error_code			int,
@error_desc			varchar(300),
@error_var			int,
@rowcount_var		int,
@bookkey			int, 
@count				int, 
@maxlength			int,
@counter			int, 
@messagelongdesc	varchar(200),
@lastrundate		datetime,
@thisrundate		datetime

set @maxlength = 4000
set @qsibatchkey = null
set @qsijobkey = null

--using bookdates to track last date sent, using this to send markfordelete flag
select @lastrundate = max(startdatetime)-7
from qsijob
where jobtypecode = 2
and statuscode = 3

exec write_qsijobmessage @qsibatchkey output, @qsijobkey output, 2,1,null,null,'QSIADMIN',0,0,0,1,'job started','started',@error_code output, @error_desc output

select @thisrundate = startdatetime
from qsijob
where qsibatchkey = @qsibatchkey
and qsijobkey = @qsijobkey
and jobtypecode = 2
and jobtypesubcode = 1

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_category_name]') AND type in (N'U'))
drop table aph_web_feed_category_name

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to drop aph_web_feed_category table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

/*11/12/08 JLH per email from John Gebhardt on 10/22, categorydescription no longer being sent
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_categorydescription]') AND type in (N'U'))
drop table aph_web_feed_categorydescription	

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to drop aph_web_feed_categorydescription table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_categoryrelation]') AND type in (N'U'))
drop table aph_web_feed_categoryRelation

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to drop aph_web_feed_categoryrelation table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[feedout_titles]') AND type in (N'U'))
drop table feedout_titles

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to drop feedout_titles table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_product]') AND type in (N'U'))
drop table aph_web_feed_product

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to drop aph_web_feed_product table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_productdesc]') AND type in (N'U'))
drop table aph_web_feed_productdesc

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to drop aph_web_feed_productdesc table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_price]') AND type in (N'U'))
drop table aph_web_feed_price

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to drop aph_web_feed_price table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_category]') AND type in (N'U'))
drop table aph_web_feed_category

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to drop aph_web_feed_category table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_attributevalues]') AND type in (N'U'))
drop table aph_web_feed_attributevalues

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to drop aph_web_feed_attributevalues table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_attributes]') AND type in (N'U'))
drop table aph_web_feed_attributes

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to drop aph_web_feed_attributes table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_associations]') AND type in (N'U'))
drop table aph_web_feed_associations

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to drop aph_web_feed_associations table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_optional_related]') AND type in (N'U'))
drop table aph_web_feed_optional_related

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to drop aph_web_feed_optional_related table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 


-- aph_web_feed_category

CREATE TABLE dbo.aph_web_feed_category_name(
	recordtype		varchar(20) not null,
	categoryname	varchar(60) not null,
	markfordelete	varchar(10)	null,
	field1          varchar(40) null,
	field2          varchar(40) null,
	tableid			int			null,
	datacode		int			null,
	datasubcode		int			null,
	datasub2code	int			null) 

insert into aph_web_feed_category_name
Select 'category', cast (tableid as varchar(10))+'A', 0, Null, Null, tableid, null, null, null
from gentablesdesc 
where tableid = 413
and tabledesclong is not null
UNION
Select 'category', cast (tableid as varchar(10))+'A' + cast (datacode as varchar(10))+'B', 0, Null, Null, tableid, datacode, null, null
from gentables 
where tableid = 413
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'category', cast (tableid as varchar(10))+'A' + cast (datacode as varchar(10))+'B' + cast (datasubcode as varchar(10))+'C', 0, Null, Null, tableid, datacode, datasubcode, null
from subgentables 
where tableid = 413
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'category', cast (tableid as varchar(10)) +'A' + cast (datacode as varchar(10))+'B' + cast (datasubcode as varchar(10))+'C' + cast (datasub2code as varchar(10))+'D', 0, Null, Null, tableid, datacode, datasubcode, datasub2code
from sub2gentables 
where tableid = 413
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'category', cast (tableid as varchar(10)) +'A', 0, Null,Null, tableid, null, null, null
from gentablesdesc 
where tableid = 412
and tabledesclong is not null
UNION
Select 'category', cast (tableid as varchar(10)) +'A' + cast (datacode as varchar(10))+'B', 0, Null, Null, tableid, datacode, null, null
from gentables 
where tableid = 412
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'category', cast (tableid as varchar(10)) +'A' + cast (datacode as varchar(10))+'B' + cast (datasubcode as varchar(10))+'C', 0, Null, Null, tableid, datacode, datasubcode, null
from subgentables 
where tableid = 412
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'category', cast (tableid as varchar(10)) +'A' + cast (datacode as varchar(10))+'B' + cast (datasubcode as varchar(10))+'C' + cast (datasub2code as varchar(10))+'D', 0, Null, Null, tableid, datacode, datasubcode, datasub2code
from sub2gentables 
where tableid = 412
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'category', cast (tableid as varchar(10)) +'A', 0, Null, Null, tableid, null, null, null
from gentablesdesc 
where tableid = 558
and tabledesclong is not null
UNION
Select 'category', cast (tableid as varchar(10)) +'A' + cast (datacode as varchar(10))+'B', 0, Null, Null, tableid, datacode, null, null
from gentables 
where tableid = 558
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'category', cast (tableid as varchar(10)) +'A' + cast (datacode as varchar(10))+'B' + cast (datasubcode as varchar(10))+'C', 0, Null, Null, tableid, datacode, datasubcode, null
from subgentables 
where tableid = 558
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'category', cast (tableid as varchar(10)) +'A' + cast (datacode as varchar(10))+'B' + cast (datasubcode as varchar(10))+'C' + cast (datasub2code as varchar(10))+'D' , 0, Null, Null, tableid, datacode, datasubcode, datasub2code
from sub2gentables 
where tableid = 558
and deletestatus = 'N'
and datadesc is not null
/*shipping added 12-2-08*/
UNION
Select 'category', cast (tableid as varchar(10)) +'A', 0, Null, Null, tableid, null, null, null
from gentablesdesc 
where tableid = 434
and tabledesclong is not null
UNION
Select 'category', cast (tableid as varchar(10)) +'A' + cast (datacode as varchar(10))+'B', 0, Null, Null, tableid, datacode, null, null
from gentables 
where tableid = 434
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'category', cast (tableid as varchar(10)) +'A' + cast (datacode as varchar(10))+'B' + cast (datasubcode as varchar(10))+'C', 0, Null, Null, tableid, datacode, datasubcode, null
from subgentables 
where tableid = 434
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'category', cast (tableid as varchar(10)) +'A' + cast (datacode as varchar(10))+'B' + cast (datasubcode as varchar(10))+'C' + cast (datasub2code as varchar(10))+'D' , 0, Null, Null, tableid, datacode, datasubcode, datasub2code
from sub2gentables 
where tableid = 434
and deletestatus = 'N'
and datadesc is not null

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_category_name table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

/*
-- aph_web_feed_categorydescription

CREATE TABLE dbo.aph_web_feed_categorydescription(
recordtype		varchar(20) not null,	
categoryName	varchar(60) not null,
languageid		varchar(10)		null,
displayName	    varchar(60) not null,
shortDescription	varchar(20) null,
longDescription		varchar(2000) null,
published			varchar(10) null,
thumbnail			varchar(255) null,
fullImage			varchar(255) null)



insert into aph_web_feed_categorydescription
Select 'categoryDescription', c.categoryname, '-1', RTRIM(LTRIM(tabledesclong)), Null, RTRIM(LTRIM(gentablesdesclong)), 1, Null, Null
from gentablesdesc g
join aph_web_feed_category_name c
on g.tableid = c.tableid
and c.datacode is null
and c.datasubcode is null
and c.datasub2code is null
where g.tableid = 412
and tabledesclong is not null
UNION
Select 'categoryDescription', c.categoryname, '-1', RTRIM(LTRIM(datadesc)), RTRIM(LTRIM(datadescshort)), RTRIM(LTRIM(alternatedesc1)), 1, Null, Null
from gentables g
join aph_web_feed_category_name c
on g.tableid = c.tableid
and c.datacode = g.datacode
and c.datasubcode is null
and c.datasub2code is null
where g.tableid = 412
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'categoryDescription', c.categoryname, '-1', RTRIM(LTRIM(datadesc)), RTRIM(LTRIM(datadescshort)), RTRIM(LTRIM(alternatedesc1)), 1, Null, Null
from subgentables g
join aph_web_feed_category_name c
on g.tableid = c.tableid
and c.datacode = g.datacode
and c.datasubcode = g.datasubcode
and c.datasub2code is null
where g.tableid = 412
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'categoryDescription', c.categoryname, '-1', RTRIM(LTRIM(datadesc)), RTRIM(LTRIM(datadescshort)), RTRIM(LTRIM(alternatedesc1)), 1, Null, Null
from sub2gentables g
join aph_web_feed_category_name c
on g.tableid = c.tableid
and c.datacode = g.datacode
and c.datasubcode = g.datasubcode
and c.datasub2code = g.datasub2code
where g.tableid = 412
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'categoryDescription', c.categoryname, '-1', RTRIM(LTRIM(tabledesclong)), Null, RTRIM(LTRIM(gentablesdesclong)), 1, Null, Null
from gentablesdesc g
join aph_web_feed_category_name c
on g.tableid = c.tableid
and c.datacode is null
and c.datasubcode is null
and c.datasub2code is null
where g.tableid = 413
and tabledesclong is not null
UNION
Select 'categoryDescription', c.categoryname, '-1', RTRIM(LTRIM(datadesc)), RTRIM(LTRIM(datadescshort)), RTRIM(LTRIM(alternatedesc1)), 1, Null, Null
from gentables g
join aph_web_feed_category_name c
on g.tableid = c.tableid
and c.datacode = g.datacode
and c.datasubcode is null
and c.datasub2code is null
where g.tableid = 413
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'categoryDescription', c.categoryname, '-1', RTRIM(LTRIM(datadesc)), RTRIM(LTRIM(datadescshort)), RTRIM(LTRIM(alternatedesc1)), 1, Null, Null
from subgentables g
join aph_web_feed_category_name c
on g.tableid = c.tableid
and c.datacode = g.datacode
and c.datasubcode = g.datasubcode
and c.datasub2code is null
where g.tableid = 413
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'categoryDescription', c.categoryname, '-1', RTRIM(LTRIM(datadesc)), RTRIM(LTRIM(datadescshort)), RTRIM(LTRIM(alternatedesc1)), 1, Null, Null
from sub2gentables g
join aph_web_feed_category_name c
on g.tableid = c.tableid
and c.datacode = g.datacode
and c.datasubcode = g.datasubcode
and c.datasub2code = g.datasub2code
where g.tableid = 413
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'categoryDescription', c.categoryname, '-1', RTRIM(LTRIM(tabledesclong)), Null, RTRIM(LTRIM(gentablesdesclong)), 1, Null, Null
from gentablesdesc g
join aph_web_feed_category_name c
on g.tableid = c.tableid
and c.datacode is null
and c.datasubcode is null
and c.datasub2code is null
where g.tableid = 558
and tabledesclong is not null
UNION
Select 'categoryDescription', c.categoryname, '-1', RTRIM(LTRIM(datadesc)), RTRIM(LTRIM(datadescshort)), RTRIM(LTRIM(alternatedesc1)), 1, Null, Null
from gentables g
join aph_web_feed_category_name c
on g.tableid = c.tableid
and c.datacode = g.datacode
and c.datasubcode is null
and c.datasub2code is null
where g.tableid = 558
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'categoryDescription', c.categoryname, '-1', RTRIM(LTRIM(datadesc)), RTRIM(LTRIM(datadescshort)), RTRIM(LTRIM(alternatedesc1)), 1, Null, Null
from subgentables g
join aph_web_feed_category_name c
on g.tableid = c.tableid
and c.datacode = g.datacode
and c.datasubcode = g.datasubcode
and c.datasub2code is null
where g.tableid = 558
and deletestatus = 'N'
and datadesc is not null
UNION
Select 'categoryDescription', c.categoryname, '-1', RTRIM(LTRIM(datadesc)), RTRIM(LTRIM(datadescshort)), RTRIM(LTRIM(alternatedesc1)), 1, Null, Null
from sub2gentables g
join aph_web_feed_category_name c
on g.tableid = c.tableid
and c.datacode = g.datacode
and c.datasubcode = g.datasubcode
and c.datasub2code = g.datasub2code
where g.tableid = 558
and deletestatus = 'N'
and datadesc is not null

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_categorydescription table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 
*/

-- aph_web_feed_categoryRelation

Create table aph_web_feed_categoryRelation(
recordtype		varchar(20) not null,	
parent			varchar(60) null,
parentMemberId	varchar(10) null,
child			varchar(60) null,
sequence		varchar(10))


insert into aph_web_feed_categoryRelation
select 'categoryRelation', null,null, n1.categoryname, tableid
from aph_web_feed_category_name n1
where n1.datacode is null
union
select 'categoryRelation', n1.categoryname, null, n2.categoryname, n2.datacode  
from aph_web_feed_category_name n1
join aph_web_feed_Category_name n2
on n1.tableid = n2.tableid
and n1.datacode is null
and n2.datacode is not null
and n2.datasubcode is null
union
select 'categoryRelation', n1.categoryname, null, n2.categoryname, n2.datasubcode  
from aph_web_feed_category_name n1
join aph_web_feed_Category_name n2
on n1.tableid = n2.tableid
and n1.datacode = n2.datacode 
and n1.datasubcode is null
and n2.datasubcode is not null
and n2.datasub2code is null
union
select 'categoryRelation', n1.categoryname, null, n2.categoryname, n2.datasub2code  
from aph_web_feed_category_name n1
join aph_web_feed_Category_name n2
on n1.tableid = n2.tableid
and n1.datacode = n2.datacode 
and n1.datasubcode = n2.datasubcode 
and n1.datasub2code is null
and n2.datasub2code is not null

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_category_relation table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 


CREATE TABLE dbo.feedout_titles(
	bookkey			int			NOT NULL,
	itemnumber		varchar(30)	null,
	lastmaintdate	datetime	not null,
	productorsku	varchar(10)	null,
	parentbookkey	int			null,
	parentitemnumber	varchar(30)	null 
) 

insert into feedout_titles
select b.bookkey, i.itemnumber, getdate(), null, null, null 
from book b 
--join bookmisc bm		--send to e-commerce is true
--on b.bookkey = bm.bookkey
join isbn i
on b.bookkey = i.bookkey
where b.linklevelcode <> 30
--and bm.misckey=2
--and bm.longvalue=1
order by b.bookkey

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into feedout_titles table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

--11/17/08 JLH - Uncomment this after running proc once to write bookdates rows for all
--titles originally being sent
delete from feedout_titles
from feedout_titles ft
join book b 
on ft.bookkey = b.bookkey
left outer join bookmisc bm		--send to e-commerce is false or not there
on b.bookkey = bm.bookkey
and bm.misckey=2
join isbn i
on b.bookkey = i.bookkey
left outer join bookdates bd
on b.bookkey = bd.bookkey
and datetypecode = 483
where (bm.longvalue <> 1
or bm.longvalue is null)
and isnull(bd.activedate,'1/1/1900') < @lastrundate

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to delete from feedout_titles table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update feedout_titles
set productorsku = 'sku', parentbookkey = book.workkey, 
parentitemnumber = case when isbn.itemnumber is null then rtrim(convert(char(20),isbn.bookkey)) + 'P'
						when isbn.itemnumber = '' then rtrim(convert(char(20),isbn.bookkey)) + 'P'
						else rtrim(isbn.itemnumber)+'P'
					end
from book
join isbn
on book.workkey = isbn.bookkey
where feedout_titles.bookkey = book.bookkey
and linklevelcode = 20
and productorsku is null

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update feedout_titles table (1).  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

--update feedout_titles
--set productorsku = 'sku', parentbookkey = associatedtitles.bookkey, parentitemnumber = isbn.itemnumber
--from associatedtitles
--join isbn 
--on associatedtitles.bookkey = isbn.bookkey
--where feedout_titles.bookkey = associatedtitles.associatetitlebookkey
--and productorsku is null
--and associatedtitles.associationtypecode in (7)

--insert into feedout_titles
--select ft.bookkey, i.itemnumber, getdate(), 'sku', at.bookkey, ip.itemnumber
--from feedout_titles ft
--join associatedtitles at
--on ft.bookkey = at.associatetitlebookkey
--join bookmisc bm
--on ft.bookkey = bm.bookkey
--and bm.misckey=2
--and bm.longvalue=1
--join isbn i
--on ft.bookkey = i.bookkey
--join isbn ip
--on at.bookkey = ip.bookkey
--where at.associationtypecode in (7)
--and not exists (select 1 
--				from feedout_titles ftx
--				where ftx.bookkey = ft.bookkey
--				and ftx.parentbookkey = at.bookkey)
--order by ft.bookkey

update feedout_titles
set productorsku = 'product', parentbookkey = feedout_titles.bookkey, parentitemnumber = isbn.itemnumber
from isbn
where productorsku is null
and feedout_titles.bookkey = isbn.bookkey

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update feedout_titles table (2).  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

set @count = 0

select @bookkey = min(bookkey), @count = isnull(count(distinct bookkey),0)
from feedout_titles 
where exists (select *
		from bookcomments bl		
		where bl.bookkey = feedout_titles.bookkey
		and bl.printingkey = 1
		and bl.commenttypecode = 3
		and bl.commenttypesubcode = 8
		and datalength(commenthtmllite) > @maxlength)

set @counter = 1

while @counter <= @count
begin
	set @messagelongdesc = 'Did not send bookkey '+cast(@bookkey as varchar(20))+' because longdescription exceeds length of '+cast(@maxlength as varchar(10))

	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',@bookkey,0,0,2,@messagelongdesc,'longdescription too long',@error_code output, @error_desc output

	select @bookkey = min(bookkey)
	from feedout_titles 
	where bookkey > @bookkey
	and exists (select *
			from bookcomments bl		
			where bl.bookkey = feedout_titles.bookkey
			and bl.printingkey = 1
			and bl.commenttypecode = 3
			and bl.commenttypesubcode = 8
			and datalength(commenthtmllite) > @maxlength)

	set @counter = @counter + 1

end

set @count = 0

select @bookkey = min(bookkey), @count = isnull(count(distinct bookkey),0)
from feedout_titles 
where exists (select *
		from bookcomments bl		
		where bl.bookkey = feedout_titles.bookkey
		and bl.printingkey = 1
		and bl.commenttypecode = 3
		and bl.commenttypesubcode = 7
		and datalength(commenthtmllite) > @maxlength)

set @counter = 1

while @counter <= @count
begin
	set @messagelongdesc = 'Did not send bookkey '+cast(@bookkey as varchar(20))+' because auxdescription1 exceeds length of '+cast(@maxlength as varchar(10))

	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',@bookkey,0,0,2,@messagelongdesc,'auxdescription too long',@error_code output, @error_desc output

	select @bookkey = min(bookkey)
	from feedout_titles 
	where bookkey > @bookkey
	and exists (select *
			from bookcomments bl		
			where bl.bookkey = feedout_titles.bookkey
			and bl.printingkey = 1
			and bl.commenttypecode = 3
			and bl.commenttypesubcode = 7
			and datalength(commenthtmllite) > @maxlength)

	set @counter = @counter + 1

end

delete
from feedout_titles 
where exists (select *
		from bookcomments bl		
		where bl.bookkey = feedout_titles.bookkey
		and bl.printingkey = 1
		and bl.commenttypecode = 3
		and bl.commenttypesubcode = 8
		and datalength(commenthtmllite) > @maxlength)

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to delete from feedout_titles table. (1) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

delete
from feedout_titles 
where exists (select *
		from bookcomments bl		
		where bl.bookkey = feedout_titles.bookkey
		and bl.printingkey = 1
		and bl.commenttypecode = 3
		and bl.commenttypesubcode = 7
		and datalength(commenthtmllite) > @maxlength)

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to delete from feedout_titles table. (2) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

--6/14/08 JLH per Sujith, don't send skus whose parents are not set to ecommerce
--so I'm deleting any records whose parentbookkeys are not on feedout_titles
--and vice versa

select @bookkey = min(bookkey), @count = isnull(count(distinct bookkey),0)
from feedout_titles 
where productorsku = 'sku'
and not exists (select 1
				from feedout_titles fp
				where feedout_titles.parentbookkey = fp.bookkey)

set @counter = 1

while @counter <= @count
begin
	set @messagelongdesc = 'Did not send bookkey '+cast(@bookkey as varchar(20))+' because its parent product is not being sent to ECommerce.'

	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',@bookkey,0,0,2,@messagelongdesc,'orphan sku',@error_code output, @error_desc output

	select @bookkey = min(bookkey)
	from feedout_titles 
	where productorsku = 'sku'
	and bookkey > @bookkey
	and not exists (select 1
					from feedout_titles fp
					where feedout_titles.parentbookkey = fp.bookkey)

	set @counter = @counter + 1

end

delete
from feedout_titles 
where productorsku = 'sku'
and not exists (select 1
				from feedout_titles fp
				where feedout_titles.parentbookkey = fp.bookkey)

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to delete from feedout_titles table. (3) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

select @bookkey = min(bookkey), @count = isnull(count(distinct bookkey),0)
from feedout_titles 
where productorsku = 'product'
and (itemnumber is null
or itemnumber = '')
and not exists (select 1
				from feedout_titles fp
				where feedout_titles.bookkey = fp.parentbookkey
					and fp.bookkey <> fp.parentbookkey)

set @counter = 1

while @counter <= @count
begin
	set @messagelongdesc = 'Did not send bookkey '+cast(@bookkey as varchar(20))+' because it has no skus being sent to ECommerce.'

	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',@bookkey,0,0,2,@messagelongdesc,'orphan product',@error_code output, @error_desc output

	select @bookkey = min(bookkey)
	from feedout_titles 
	where productorsku = 'product'
	and bookkey > @bookkey
	and (itemnumber is null
	or itemnumber = '')
	and not exists (select 1
					from feedout_titles fp
					where feedout_titles.bookkey = fp.parentbookkey
						and fp.bookkey <> fp.parentbookkey)

	set @counter = @counter + 1

end

delete
from feedout_titles 
where productorsku = 'product'
and (itemnumber is null
or itemnumber = '')
and not exists (select 1
				from feedout_titles fp
				where feedout_titles.bookkey = fp.parentbookkey
					and fp.bookkey <> fp.parentbookkey)

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to delete from feedout_titles table. (4) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update feedout_titles
set itemnumber = bookkey
where productorsku = 'sku'
and (itemnumber is null
or itemnumber = '')

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update feedout_titles table. (3) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into feedout_titles	--add sku records for all products
select bookkey, itemnumber, getdate(), 'sku', parentbookkey, ltrim(rtrim(parentitemnumber)) + 'P'
from feedout_titles
where productorsku = 'product'
and itemnumber <> ''
and itemnumber is not null

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into feedout_titles table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update feedout_titles
set itemnumber = ltrim(rtrim(itemnumber)) + 'P'
where productorsku = 'product'
and itemnumber <> ''
and itemnumber is not null

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update feedout_titles table. (4) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update feedout_titles
set itemnumber = rtrim(convert(char(20),bookkey)) + 'P'
where productorsku = 'product'
and (itemnumber = ''
or itemnumber is null)

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update feedout_titles table. (5) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update feedout_titles
set parentitemnumber = rtrim(convert(char(20),parentbookkey)) + 'P'
where productorsku = 'sku'
and (parentitemnumber = ''
or parentitemnumber is null)

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update feedout_titles table. (6) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update feedout_titles
set parentitemnumber = ''
where productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update feedout_titles table. (7) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

--last catch - remove skus whose parentitemnumbers are not on the table.  different from checking bookkey
--bc bookkey would find its own record, but parentitemnumbers have P suffix that will not point back to itself
select @bookkey = min(bookkey), @count = isnull(count(distinct bookkey),0)
from feedout_titles 
where parentitemnumber <> ''
and parentitemnumber not in (select itemnumber 
							from feedout_titles) 

set @counter = 1

while @counter <= @count
begin
	set @messagelongdesc = 'Did not send bookkey '+cast(@bookkey as varchar(20))+' because its parent itemnumber is being sent to ECommerce.'

	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',@bookkey,0,0,2,@messagelongdesc,'orphan sku',@error_code output, @error_desc output

	select @bookkey = min(bookkey)
	from feedout_titles 
	where parentitemnumber <> ''
	and parentitemnumber not in (select itemnumber 
								from feedout_titles) 
	and bookkey > @bookkey

	set @counter = @counter + 1

end

delete
from feedout_titles 
where parentitemnumber <> ''
and parentitemnumber not in (select itemnumber 
							from feedout_titles) 

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to delete from feedout_titles table. (8) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 


create table aph_web_feed_optional_related
	(bookkey			int			NOT NULL,
	itemnumber		varchar(30)	null,
	lastmaintdate	datetime	not null,
	productorsku	varchar(10)	null,
	parentbookkey	int			null,
	parentitemnumber	varchar(30)	null) 

insert into aph_web_feed_optional_related
select at.associatetitlebookkey, i.itemnumber, getdate(), 'optrel', ft.bookkey, ft.itemnumber
from feedout_titles ft
join associatedtitles at
on ft.bookkey = at.bookkey
join isbn i
on at.associatetitlebookkey = i.bookkey
join bookmisc bm
on at.associatetitlebookkey = bm.bookkey
and bm.misckey=2
and bm.longvalue=1
where at.associationtypecode in (5,6,7)
and ft.productorsku = 'product'
and exists (select 1 
				from feedout_titles ftx
				where ftx.bookkey = at.associatetitlebookkey)
order by ft.bookkey

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_optional_related table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update aph_web_feed_optional_related
set itemnumber = feedout_titles.itemnumber
from feedout_titles
where aph_web_feed_optional_related.bookkey = feedout_titles.bookkey
and (aph_web_feed_optional_related.itemnumber is null
or aph_web_feed_optional_related.itemnumber = '')

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update aph_web_feed_optional_related table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

--Product table
create table aph_web_feed_product
(recordtype		varchar(20) null,
bookkey			int			null,
partnumber		varchar(20)	null,
parentpartnumber	varchar(20)	null,
parentbookkey	int			null,
type			varchar(20)	null,
currency		char(5)		null,
listprice		float		null,
inventory		int			null,
markfordelete	tinyint		null,
height			varchar(10)	null,
length			varchar(10)	null,
width			varchar(10)	null,
sizemeasure		varchar(10)	null,
weight			varchar(10)	null,
weightmeasure	varchar(10)	null,
field1			int			null,
field2			int			null,
field3			float	null,
field4			varchar(255)	null,
field5			varchar(10)	null)



insert into aph_web_feed_product
select 'recordtype' = 'product',
'bookkey' = b.bookkey,
'partnumber' = ft.itemnumber,
'parentpartnumber' = ft.parentitemnumber,
'parentbookkey' = case ft.productorsku 
			when 'sku' then ft.parentbookkey 
			else Null 
		end,
'type' = case ft.productorsku 
			when 'product' then 'ProductBean' 
			when 'sku' then 'ItemBean'
		end,
'currency' = 'USD',
'listprice' = case ft.productorsku 
			when 'product' then 0.00 
			when 'sku' then bpr.finalprice
		end,
'inventory' = '',
'markfordelete' = case ISNULL(bm.longvalue,0)
					when 1 then 0
					when 0 then 1
				end,
'height' = NULL,
'length' = case when ft.productorsku = 'sku' and p.trimsizelength <> ''
			then p.trimsizelength
		end,
'width' = case when ft.productorsku = 'sku' and p.trimsizewidth <> ''		
			then p.trimsizewidth
		end,
'sizemeasure' = case when ft.productorsku = 'sku' and (p.trimsizelength <> '' or p.trimsizewidth <> '')
			then 'INH'
		end, 
'weight' = case when ft.productorsku = 'sku' and bs.bookweight <> ''
			then bs.bookweight
		end,
'weightmeasure' = case when ft.productorsku = 'sku' and bs.bookweight <> ''
			then 'LBR'
		end,
'field1' = Null,
'field2' = Null,
'field3' = Null,
'field4' = b.shorttitle,
'field5' = Null
from feedout_titles ft
--(select bookkey, 'productorsku' = min(productorsku), 'parentbookkey' = min(parentbookkey)
--		from feedout_titles /*where productorsku ='product' or productorsku='sku'*/
--		group by bookkey) ft		--driver table of bookkeys to feed
join book b					--book for main feed title
on b.bookkey = ft.bookkey 
join book bp				--book for feed title's primary title
on ft.parentbookkey = bp.bookkey
join printing p				--printing of feed title
on b.bookkey = p.bookkey
left outer join bookmisc bm	--bookmisc of feed title
on b.bookkey = bm.bookkey
and bm.misckey = 2
and bm.longvalue=1
left join booksimon bs			--booksimon of feed title
on b.bookkey = bs.bookkey
left outer join bookprice bpr			--bookprice of feed title
on b.bookkey = bpr.bookkey
and pricetypecode = 8
and currencytypecode = 6
and activeind = 1
where p.printingkey = 1

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_product.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

--productdescription tab
create table aph_web_feed_productdesc
(recordtype				varchar(20)	null,
bookkey					int			null,
partnumber				varchar(20)	null,
languageid				varchar(10)	null,
displayname				varchar(255)	null,
shortdescription		text		null,
longdescription			text		null,
auxdescription1			text		null,
auxdescription2			text		null,
published				int			null,
thumbnail				varchar(255)	null,
fullimage				varchar(255)	null,
type					varchar(50)	null)
		
insert into aph_web_feed_productdesc
select distinct 'recordtype' = 'productDescription',
'bookkey' = b.bookkey,
'partnumber' = ft.itemnumber,
'languageid' = '-1',		--language of the website display, not the title
'displayname' = replace(substring(b.title + ' ' + coalesce (b.subtitle,''),1,128),'"','""'),
'shortdescription' = NULL,
'longdescription' = NULL,
'auxdescription1' = NULL,
'auxdescription2' = NULL,
'published' = case IsNUll(bd.bisacstatuscode,0)
				when 1	then 1
				else 0
			end ,
'thumbnail' = replace(substring(ftn.pathname,46,4000),'\','/'), --23
'fullimage' = NULL,
'type' = case ft.productorsku
			when 'product' then 'ProductBean' 
			when 'sku' then 'ItemBean'
		end
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
left outer join bookdetail bd				--bookmisc of feed title
on b.bookkey = bd.bookkey
left outer join filelocation ftn		--filelocation for the thumbnail image
on b.bookkey = ftn.bookkey
and ftn.filetypecode = 1

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_productdesc table. Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update aph_web_feed_productdesc
set shortdescription = replace(replace(replace (cast(commenttext as varchar(254)),char(13) + char(10),'') ,char(10),''),'"','""')
from bookcomments bs			--bookcomments for short desc
where aph_web_feed_productdesc.bookkey = bs.bookkey
and bs.printingkey = 1
and bs.commenttypecode = 3
and bs.commenttypesubcode = 48

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update aph_web_feed_productdesc table. (1) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update aph_web_feed_productdesc
set longdescription = substring(isnull(bl.commenthtmllite,''),1,@maxlength)
from bookcomments bl			--bookcomments for long desc
where aph_web_feed_productdesc.bookkey = bl.bookkey
and bl.printingkey = 1
and bl.commenttypecode = 3
and bl.commenttypesubcode = 8

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update aph_web_feed_productdesc table. (2) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update aph_web_feed_productdesc
set auxdescription1 = replace(substring(isnull(ba.commenthtmllite,''),1,@maxlength),'"','""')
from bookcomments ba			--bookcomments for aux desc1
where aph_web_feed_productdesc.bookkey = ba.bookkey
and ba.printingkey = 1
and ba.commenttypecode = 3
and ba.commenttypesubcode = 7

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update aph_web_feed_productdesc table. (3) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update aph_web_feed_productdesc
set auxdescription2 = replace(replace(replace (cast(commenttext as varchar(254)),char(13) + char(10),'') ,char(10),''),'"','""')
--replace new line characters with a space
-- PM 11/24/08 changed replace function to include character code for line feed
from bookcomments ba2			--bookcomments for aux desc2
where aph_web_feed_productdesc.bookkey = ba2.bookkey
and ba2.printingkey = 1
and ba2.commenttypecode = 3
and ba2.commenttypesubcode = 20

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update aph_web_feed_productdesc table. (4) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update aph_web_feed_productdesc
set fullimage = substring(isnull(ftn.notes,''),1,@maxlength)
from filelocation ftn			
where aph_web_feed_productdesc.bookkey = ftn.bookkey
and ftn.filetypecode = 1

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update aph_web_feed_productdesc table. (5) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

--price tab
create table aph_web_feed_price
(recordtype		varchar(20)		null,
bookkey			int				null,
partnumber		varchar(20)		null,
memberid		varchar(20)		null,
price			float			null,
currency		varchar(10)		null,
precedence		int				null,
startdate		datetime		null,
enddate			datetime		null,
field1			varchar(10)		null,
field2			varchar(10)		null)

insert into aph_web_feed_price
select distinct 'recordtype' = 'price',
'bookkey' = b.bookkey,
'partnumber' = ft.itemnumber,
'memberid' = Null,
'price' = ISNULL(bp.finalprice,0),
'currency' = gc.bisacdatacode,
'precedence' = ISNULL(bp.sortorder,0),		--?????
'startdate' = getdate(),
'enddate' = dateadd(year, 10, getdate()),
'field1' = Null,
'field2' = Null		
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookprice bp
on b.bookkey = bp.bookkey
and bp.pricetypecode = 8
and activeind = 1
join gentables gc
on bp.currencytypecode = gc.datacode
and tableid = 122
where ft.productorsku = 'sku'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_price table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

--categoryproductrelation tab
create table aph_web_feed_category
(recordtype			varchar(100)	null,
bookkey				int				null,
categoryname		varchar(255)	null,
categorymemberid	varchar(10)		null,
partnumber			varchar(20)		null,
sequence			int				null,
tableid				int				null,
datacode			int				null,
datasubcode			int				null,
datasub2code		int				null)

insert into aph_web_feed_category
select distinct 'recordtype' = 'categoryProductRelation',
'bookkey' = bs.bookkey,
c.categoryname,
'categorymemberid' = Null,
'partnumber' = ft.itemnumber,
'sequence' = (bs.categorytableid * 100) + bs.sortorder,
bs.categorytableid, bs.categorycode, bs.categorysubcode, bs.categorysub2code
from feedout_titles ft
join booksubjectcategory bs
on ft.bookkey = bs.bookkey 
and bs.categorytableid in (412,413,558,434)
left outer join aph_web_feed_category_name c
on bs.categorytableid = c.tableid
and isnull(bs.categorycode,0) = isnull(c.datacode,0)
and isnull(bs.categorysubcode,0) = isnull(c.datasubcode,0)
and isnull(bs.categorysub2code,0) = isnull(c.datasub2code,0)

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_category table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update aph_web_feed_category
set categoryname = cn.categoryname
from aph_web_feed_category_name cn
where aph_web_feed_category.tableid = cn.tableid
and aph_web_feed_category.datacode = cn.datacode
and aph_web_feed_category.datasubcode = cn.datasubcode
and cn.datasub2code is null
and aph_web_feed_category.categoryname is null

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update aph_web_feed_category table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update aph_web_feed_category
set categoryname = cn.categoryname
from aph_web_feed_category_name cn
where aph_web_feed_category.tableid = cn.tableid
and aph_web_feed_category.datacode = cn.datacode
and cn.datasubcode is null
and aph_web_feed_category.categoryname is null

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update aph_web_feed_category table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

update aph_web_feed_category
set categoryname = cn.categoryname
from aph_web_feed_category_name cn
where aph_web_feed_category.tableid = cn.tableid
and cn.datacode is null
and aph_web_feed_category.categoryname is null

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update aph_web_feed_category table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

--attributes & attributevalues tabs
create table aph_web_feed_attributevalues
(valuekey			int	identity (1,1) not null,
recordtype			varchar(20)		null,
bookkey				int				null,
itempartnumber		varchar(20)		null,
itemmemberid		int				null,
parentpartnumber	varchar(20)		null,
parentbookkey		int				null,
languageid			varchar(10)		null,
attributetype		varchar(20)		null,
attributename		varchar(100)	null,
attributevalue		varchar(255)	null,
sequence			int				null,
field1				int				null,
field2				varchar(255)	null,
field3				varchar(255)	null)

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = 0,	--b.bookkey,
'itempartnumber' = 0,--0 for orange, itemnumber for others
'itemmemberid' = '0',--0 for orange, blank for others
'parentpartnumber' = ft.parentitemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.parentbookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Catalog Number',
'attributevalue' = ft.itemnumber,
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
where ft.productorsku = 'sku'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (1) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

exec aph_web_feed_attr_vals_Sort 'catalog number'

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.parentitemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.parentbookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Catalog Number',
'attributevalue' = ft.itemnumber,
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
where ft.productorsku = 'sku'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (2) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = 0,	--b.bookkey,
'itempartnumber' = 0,--0 for orange, itemnumber for others
'itemmemberid' = '0',--0 for orange, blank for others
'parentpartnumber' = ft.parentitemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.parentbookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Print Type',
'attributevalue' = CASE WHEN dbo.get_format(b.bookkey, '2') <> '' THEN isnull(dbo.get_format(b.bookkey, '2'),'') END,
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
where ft.productorsku = 'sku'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (3) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

exec aph_web_feed_attr_vals_Sort 'print type'

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.parentitemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.parentbookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Print Type',
'attributevalue' = CASE WHEN dbo.get_format(b.bookkey, '2') <> '' THEN isnull(dbo.get_format(b.bookkey, '2'),'') END,
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
where ft.productorsku = 'sku'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (4) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = b.bookkey,
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Publish Date',
'attributevalue' = convert(varchar(10),bd.activedate,101),
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookdates bd
on b.bookkey = bd.bookkey
and bd.datetypecode = 8

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (5) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Year',
'attributevalue' = bd.copyrightyear,
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookdetail bd
on b.bookkey = bd.bookkey
and bd.copyrightyear <> Null
and bd.copyrightyear is not null
where productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (6) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = 0,	--b.bookkey,
'itempartnumber' = 0,--NULL for orange, itemnumber for others
'itemmemberid' = '0',--0 for orange, blank for others
'parentpartnumber' = ft.parentitemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.parentbookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Color',
'attributevalue' = sg.datadesc,
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookmisc bm
on b.bookkey = bm.bookkey
and bm.misckey = 5
join subgentables sg
on bm.longvalue = sg.datasubcode
and tableid = 525
and datacode = 1
where ft.productorsku = 'sku'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (7) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

exec aph_web_feed_attr_vals_Sort 'color'

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.parentitemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.parentbookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Color',
'attributevalue' = sg.datadesc,
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookmisc bm
on b.bookkey = bm.bookkey
and bm.misckey = 5
join subgentables sg
on bm.longvalue = sg.datasubcode
and tableid = 525
and datacode = 1
where ft.productorsku = 'sku'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (8) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = 0,	--b.bookkey,
'itempartnumber' = 0,--NULL for orange, itemnumber for others
'itemmemberid' = '0',--0 for orange, blank for others
'parentpartnumber' = ft.parentitemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.parentbookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Size',
'attributevalue' = sg.datadesc,
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookmisc bm
on b.bookkey = bm.bookkey
and bm.misckey = 6
join subgentables sg
on bm.longvalue = sg.datasubcode
and tableid = 525
and datacode = 2
where ft.productorsku = 'sku'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (9) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

exec aph_web_feed_attr_vals_Sort 'size'

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.parentitemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.parentbookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Size',
'attributevalue' = sg.datadesc,
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookmisc bm
on b.bookkey = bm.bookkey
and bm.misckey = 6
join subgentables sg
on bm.longvalue = sg.datasubcode
and tableid = 525
and datacode = 2
where ft.productorsku = 'sku'

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Pack Size',
'attributevalue' = bm.longvalue,
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookmisc bm
on b.bookkey = bm.bookkey
and bm.misckey = 7
where productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (10) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Series',
'attributevalue' = dbo.get_gentables_desc(327, bd.seriescode, 'long'),
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookdetail bd
on b.bookkey = bd.bookkey
and bd.seriescode is not null
and bd.seriescode <> 0
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (11) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Edition',
'attributevalue' = dbo.get_gentables_desc(200, editioncode, 'long'),
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookdetail bd
on b.bookkey = bd.bookkey
and bd.editioncode is not null
and bd.editioncode <> 0
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (12) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'INTEGER', --'STRING','INTEGER','FLOAT'
'attributename' = 'Volume',
'attributevalue' = bd.volumenumber, 
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookdetail bd
on b.bookkey = bd.bookkey
and bd.volumenumber is not null
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (13) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Author',
'attributevalue' = bd.fullauthordisplayname, 
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookdetail bd
on b.bookkey = bd.bookkey
and bd.fullauthordisplayname is not null
and bd.fullauthordisplayname <> ''
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (14) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Original Publisher',
'attributevalue' = dbo.get_gentables_desc(300, formatchildcode, 'long'),
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join booksimon bs
on b.bookkey = bs.bookkey
and bs.formatchildcode is not null
and bs.formatchildcode <> ''
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (15) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'INTEGER', --'STRING','INTEGER','FLOAT'
'attributename' = 'Page Count',
'attributevalue' = p.pagecount, 
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join printing p
on b.bookkey = p.bookkey
and p.printingkey = 1
and p.pagecount is not null
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (16) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'INTEGER', --'STRING','INTEGER','FLOAT'
'attributename' = 'Copyright Year',
'attributevalue' = bd.copyrightyear, 
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookdetail bd
on b.bookkey = bd.bookkey
and bd.copyrightyear is not null
and bd.copyrightyear <> ''
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (17) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Age Range',
'attributevalue' = convert(varchar(4),agelow) + ' to ' + convert(varchar(4),agehigh), 
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookdetail bd
on b.bookkey = bd.bookkey
and agelow is not null
and agehigh is not null
and agehigh <> 0
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (18) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Age Range',
'attributevalue' = isnull(convert(varchar(4),agelow), convert(varchar(4),agehigh)) + ' and up',
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookdetail bd
on b.bookkey = bd.bookkey
and (agelowupind = 1
or agehighupind = 1)
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (19) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Grade Level',
'attributevalue' = convert(varchar(4),gradelow) + ' to ' + convert(varchar(4),gradehigh),
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookdetail bd
on b.bookkey = bd.bookkey
and gradelow is not null
and gradelow <> ''
and gradehigh is not null
and gradehigh <> ''
and convert(varchar(4),gradehigh) <> '0'
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (20) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Grade Level',
'attributevalue' = isnull(convert(varchar(4),gradelow), convert(varchar(4),gradehigh)) + ' and up' , 
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookdetail bd
on b.bookkey = bd.bookkey
and (gradelowupind = 1
or gradehighupind = 1)
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (21) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'Sales Restriction',
'attributevalue' = isnull(dbo.get_gentables_desc(428, bd.canadianrestrictioncode, 'long'), ''),
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = case bd.canadianrestrictioncode
			when 4 then 0
			else 1
		end,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join bookdetail bd
on b.bookkey = bd.bookkey
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (22) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'ISBN10',
'attributevalue' = i.isbn, 
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join isbn i
on b.bookkey = i.bookkey
and i.isbn is not null
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (23) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into aph_web_feed_attributevalues
select distinct 'recordtype' = 'attributeValue',
'bookkey' = b.bookkey,
'itempartnumber' = ft.itemnumber,--0 for orange, itemnumber for others
'itemmemberid' = Null,--0 for orange, blank for others
'parentpartnumber' = ft.itemnumber,--sku's partnumber for yellow, parent partnumber for others
'parentbookkey' = ft.bookkey, 
'languageid' = '-1',
'attributetype' = 'STRING', --'STRING','INTEGER','FLOAT'
'attributename' = 'ISBN13',
'attributevalue' = i.ean, 
'sequence' = 1,--order them for orange within an itemnumber, 1 for all others
'field1' = Null,
'field2' = Null,
'field3' = Null
from feedout_titles ft
join book b
on ft.bookkey = b.bookkey
join isbn i
on b.bookkey = i.bookkey
and i.ean is not null
where ft.productorsku = 'product'

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributevalues table. (24) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

delete from aph_web_feed_attributevalues
where attributevalue is null
or attributevalue = Null
or (attributevalue = '' and field1 is null)	--for salesrestriction, attribute may be blank but field1 is populated

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to delete from aph_web_feed_attributevalues table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

--attributes tab
--should this be distinct on parent partnumber or original title's bookkey?  
--sample data has a difference of 4 rows between 2 options

create table aph_web_feed_attributes
(recordtype				varchar(20)	null,
bookkey					int			null,
parentpartnumber		varchar(20)	null,
parentbookkey			int			null,
languageid				varchar(10)	null,
attributetype			varchar(20)	null,
attributename			varchar(100)	null,
description				varchar(255)	null,
description2			varchar(255)	null,
sequence				int			null,
field1					varchar(255)	null,
usage					int			null)

insert into aph_web_feed_attributes
select DISTINCT 'recordtype' = 'attribute',
'bookkey' = 0,	--av.bookkey,  JLH commented out bookkey since this is at the parent level
'parentpartnumber' = case attributename 
						when 'Catalog Number' then av.parentpartnumber
						when 'Print Type' then av.parentpartnumber
						when 'Color' then av.parentpartnumber
						when 'Size' then av.parentpartnumber
						else isnull(av.itempartnumber, av.parentpartnumber)
					end,
'parentbookkey' = 0,	--av.parentbookkey,   JLH commented out parentbookkey b/c it messes up the distinct and is not used anywhere downstream
'languageid' = '-1',
'attributetype' = av.attributetype,
'attributename' = av.attributename,
'description' = case attributename
					when 'Catalog Number' then 'The catalog number for the sku.'
					when 'Print Type' then 'The type of print the book was published in.'
					when 'Publish Date' then 'The year the book was originally published.'
					when 'Revision Date' then 'The year the book was revised.'
					when 'Year' then 'The year the calendar is published for.'
					when 'Color' then 'The color of the shirt.'
					when 'Size' then 'The size of the shirt.'
					when 'Pack Size' then 'The number of cards/envelopes in a pack.'
					when 'Series' then 'The series of which this title is part.'
					when 'Edition' then 'The edition of this title.'
					when 'Volume' then 'The volume number of this title.'
					when 'Author' then 'The author of this title.'
					when 'Original Publisher' then 'The original publisher of this title.'
					when 'Page Count' then 'The page count of this book.'
					when 'Copyright Year' then 'The year this book was copyrighted.'
					when 'Age Range' then 'The appropriate age range for this title.'
					when 'Grade Level' then 'The appropriate grade level for this title.'
					when 'Sales Restriction' then 'Any sales restrictions for this title.'
					when 'ISBN10' then 'The 10 digit ISBN for this title.'
					when 'ISBN13' then 'The 13 digit ISBN for this title.'
				end,
'description2' = Null,
'sequence' = case attributename
					when 'Catalog Number' then 1
					when 'Print Type' then 2
					when 'Sales Restriction' then 3
					when 'Age Range' then 4
					when 'Author' then 5
					when 'Original Publisher' then 6
					when 'Series' then 7
					when 'Color' then 8
					when 'Size' then 9
					when 'Grade Level' then 10
					when 'Volume' then 11
					when 'Copyright Year' then 12
					when 'Pack Size' then 13
					when 'ISBN10' then 14
					when 'ISBN13' then 15
					when 'Publish Date' then 16
					when 'Revision Date' then 17
					when 'Year' then 18
					when 'Edition' then 19
					when 'Page Count' then 20
				end,
'field1' = Null,
'usage' = case attributename
					when 'Catalog Number' then 1
					when 'Print Type' then 1
					when 'Publish Date' then 2
					when 'Revision Date' then 2
					when 'Year' then 2
					when 'Color' then 1
					when 'Size' then 1
					when 'Pack Size' then 2
					else 2
				end
from aph_web_feed_attributevalues av
where av.parentpartnumber <> ''

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_attributes table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

--associations
create table aph_web_feed_associations
(recordtype			varchar(20)	null,
parentbookkey		int			null,
childbookkey		int			null,
parentpartnumber	varchar(20)	null,
childpartnumber		varchar(20)	null,
associationtype		varchar(20)	null,
condition			varchar(20)	null,
rank				int			null,
quantity			int			null)

--remove these from the associations b/c these relationships have already
--been defined and sent in the product table as parent/child
/*insert into aph_web_feed_associations
select distinct 'recordtype' = 'association', 
'parentbookkey' = ft.parentbookkey,
'childbookkey' = ft.bookkey,
'parentpartnumber' = case when ip.itemnumber= ''
					then convert(varchar,ip.bookkey)
					else isnull(ip.itemnumber,convert(varchar,ip.bookkey))
			end,
'childpartnumber' = case when i.itemnumber = ''
					then convert(varchar,ft.bookkey)
					else isnull(i.itemnumber,convert(varchar,ft.bookkey))
			end,
'associationtype' = case at.associationtypecode
						when 6 then 'ACCESSORY'
						when 7 then 'ACCESSORY'
						when 5 then 'UPSELL'
						else Null
					end,
'condition' = case at.associationtypecode
						when 6 then 'OPTIONAL'
						when 7 then 'REPLACEMENT'
						else 'NONE'
					end,
'rank' = at.sortorder,
'quantity' = at.salesunitgross
from feedout_titles ft
join isbn i
on ft.bookkey = i.bookkey
join isbn ip
on ft.parentbookkey = ip.bookkey
join associatedtitles at
on ft.bookkey = at.associatetitlebookkey
and ft.parentbookkey = at.bookkey
where ft.parentbookkey <> ft.bookkey
/*where ft.productorsku = 'sku'
and ip.itemnumber <> ''*/
order by ft.bookkey, ft.parentbookkey
*/

insert into aph_web_feed_associations
select distinct 'recordtype' = 'association', 
'parentbookkey' = aor.parentbookkey,
'childbookkey' = aor.bookkey,
'parentpartnumber' = aor.parentitemnumber,
'childpartnumber' = aor.itemnumber,
'associationtype' = case at.associationtypecode
						when 6 then 'ACCESSORY'
						when 7 then 'ACCESSORY'
						when 5 then 'UPSELL'
						else Null
					end,
'condition' = case at.associationtypecode
						when 6 then 'OPTIONAL'
						when 7 then 'COMES WITH'
						else 'NONE'
					end,
'rank' = at.sortorder,
'quantity' = at.salesunitgross
from aph_web_feed_optional_related aor
left outer join associatedtitles at
on aor.bookkey = at.associatetitlebookkey
and aor.parentbookkey = at.bookkey
order by aor.bookkey, aor.parentbookkey

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_associations table.  Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_master]') AND type in (N'U'))
drop table aph_web_feed_master

create table aph_web_feed_master(
sortorder	int	identity (1,1) not null,
output	text,
f1 varchar(8000),
f2 varchar(8000),
f3 varchar(8000),
f4 varchar(8000),
f5 varchar(8000),
f6 varchar(8000),
f7 varchar(8000),
f8 varchar(8000),
f9 varchar(8000),
f10 varchar(8000),
f11 varchar(8000),
f12 varchar(8000),
f13 varchar(8000),
f14 varchar(8000),
f15 varchar(8000),
f16 varchar(8000),
f17 varchar(8000),
f18 varchar(8000),
f19 varchar(8000))

/*category insert*/

Insert into aph_web_feed_master
Select '','category', 'categoryName','markForDelete','field1','field2',Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,''
Insert into aph_web_feed_master
Select '',recordtype, categoryName, markForDelete,field1,field2,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,''
	from aph_web_feed_category_name
	order by categoryname

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_master table. (1) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

/*
Insert into aph_web_feed_master
Select '','categoryDescription','categoryName','languageId','displayName','shortDescription','longDescription','published','thumbnail','fullImage',Null,Null,Null,Null,Null,Null,Null,Null,Null,''
Insert into aph_web_feed_master
Select '',recordtype,categoryName,languageId,displayName,shortDescription,longDescription,published,thumbnail,fullImage,Null,Null,Null,Null,Null,Null,Null,Null,Null,''
	from aph_web_feed_categorydescription	
	order by categoryname

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_master table. (2) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 
*/

Insert into aph_web_feed_master
Select '','categoryRelation','parent','parentMemberId','child','sequence',Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,''
Insert into aph_web_feed_master
Select '',recordtype,parent,parentMemberId,child,sequence,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,''
	from aph_web_feed_categoryRelation
	order by parent, child

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_master table. (3) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

Insert into aph_web_feed_master
Select '','product','partNumber','parentPartNumber','type','currency','listPrice','inventory','markForDelete','height','length','width','sizeMeasure','weight','weightMeasure','field1','field2','field3','field4','field5'
Insert into aph_web_feed_master
Select '',recordtype, partNumber,parentPartNumber,type,RTRIM(LTRIM(currency)),CAST(listPrice as varchar),
CAST(inventory as varchar),CAST(markForDelete as varchar),RTRIM(LTRIM(height)),RTRIM(LTRIM(length)),RTRIM(LTRIM(width)),sizeMeasure,weight,weightMeasure,CAST(field1 as varchar),CAST(field2 as varchar),CAST(field3 as varchar),field4,field5
	from  aph_web_feed_product
order by type desc, parentpartnumber, partnumber

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_master table. (4) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

Insert into aph_web_feed_master
Select '','productDescription','partNumber','languageId','displayName','shortDescription','longDescription','auxDescription1','auxDescription2','published','thumbnail','fullImage','type',Null,Null,Null,Null,Null,Null,''
Insert into aph_web_feed_master
Select '',recordtype,partNumber,languageId,displayName,shortDescription,longDescription,auxDescription1,auxDescription2,CAST(published as varchar),thumbnail,fullImage,type,Null,Null,Null,Null,Null,Null,''
	from aph_web_feed_productdesc
	order by partnumber

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_master table. (5) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

Insert into aph_web_feed_master
Select '','price','partNumber','memberId','price','currency','precedence','startDate','endDate','field1','field2',Null,Null,Null,Null,Null,Null,Null,Null,''
Insert into aph_web_feed_master
Select '',recordtype,partNumber,memberId,CAST(price as varchar),currency,CAST(precedence as varchar),CAST(startDate as varchar),CAST(endDate as varchar),field1,field2,Null,Null,Null,Null,Null,Null,Null,Null,''
	from aph_web_feed_price
	order by partnumber

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_master table. (6) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

Insert into aph_web_feed_master
Select '','categoryProductRelation','categoryName','categoryMemberId','partNumber','sequence',Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,''
Insert into aph_web_feed_master
Select '',recordtype,categoryName,categoryMemberId,partNumber,CAST(sequence as varchar),Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,''
	from  aph_web_feed_category
	order by partnumber, sequence

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_master table. (7) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

Insert into aph_web_feed_master
Select '','attribute','parentPartNumber','languageId','attributeType','attributeName','description','description2','sequence','field1','usage',Null,Null,Null,Null,Null,Null,Null,Null,''
Insert into aph_web_feed_master
Select '',recordtype, parentPartNumber, languageId, attributeType, attributeName, description, description2, CAST(sequence as varchar), field1, CAST(usage as varchar),Null,Null,Null,Null,Null,Null,Null,Null,''
	from  aph_web_feed_attributes
	order by parentpartnumber, sequence

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_master table. (8) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

Insert into aph_web_feed_master
Select '','attributeValue','itemPartNumber','itemMemberId','parentPartNumber','languageId','attributeType','attributeName','attributeValue','sequence','field1','field2','field3',Null,Null,Null,Null,Null,Null,''
Insert into aph_web_feed_master
Select '',recordtype,itemPartNumber,cast(itemMemberId as varchar),parentPartNumber,languageId,attributeType,attributeName,attributeValue,CAST(sequence as varchar),cast(field1 as varchar),field2,field3,Null,Null,Null,Null,Null,Null,''
	from  aph_web_feed_attributevalues
	where attributevalue is not null and attributevalue <> ''
	order by parentpartnumber, itempartnumber, attributename, sequence

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_master table. (9) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

Insert into aph_web_feed_master
Select '','association','parentPartNumber','childPartNumber','associationType','condition','rank','quantity',Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,''
Insert into aph_web_feed_master
Select '',recordtype,parentPartNumber,childPartNumber,associationType,condition,CAST(rank as varchar),CAST(quantity as varchar),Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,''
	from  aph_web_feed_associations
	order by parentpartnumber, childpartnumber

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert into aph_web_feed_master table. (10) Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

--must do this update for all fields then do update to add quotes around values with commas
update aph_web_feed_master
set f2 = replace(f2,'"','""')
where f2 like '%"%'

update aph_web_feed_master
set f3 = replace(f3,'"','""')
where f3 like '%"%'

update aph_web_feed_master
set f4 = replace(f4,'"','""')
where f4 like '%"%'

update aph_web_feed_master
set f5 = replace(f5,'"','""')
where f5 like '%"%'

update aph_web_feed_master
set f6 = replace(f6,'"','""')
where f6 like '%"%'

update aph_web_feed_master
set f7 = replace(f7,'"','""')
where f7 like '%"%'

update aph_web_feed_master
set f8 = replace(f8,'"','""')
where f8 like '%"%'

update aph_web_feed_master
set f9 = replace(f9,'"','""')
where f9 like '%"%'

update aph_web_feed_master
set f10 = replace(f10,'"','""')
where f10 like '%"%'

update aph_web_feed_master
set f11 = replace(f11,'"','""')
where f11 like '%"%'

update aph_web_feed_master
set f12 = replace(f12,'"','""')
where f12 like '%"%'

update aph_web_feed_master
set f13 = replace(f13,'"','""')
where f13 like '%"%'

update aph_web_feed_master
set f14 = replace(f14,'"','""')
where f14 like '%"%'

update aph_web_feed_master
set f15 = replace(f15,'"','""')
where f15 like '%"%'

update aph_web_feed_master
set f16 = replace(f16,'"','""')
where f16 like '%"%'

update aph_web_feed_master
set f17 = replace(f17,'"','""')
where f17 like '%"%'

update aph_web_feed_master
set f18 = replace(f18,'"','""')
where f18 like '%"%'

update aph_web_feed_master
set f19 = replace(f19,'"','""')
where f19 like '%"%'

--put double quotes around items with embedded commas
update aph_web_feed_master
set f2 = '"'+rtrim(f2)+'"'
--where isnumeric(f2) = 0

update aph_web_feed_master
set f3 = '"'+rtrim(f3)+'"'
--where isnumeric(f3) = 0

update aph_web_feed_master
set f4 = '"'+rtrim(f4)+'"'
where isnumeric(f4) = 0

update aph_web_feed_master
set f5 = '"'+rtrim(f5)+'"'
where isnumeric(f5) = 0

update aph_web_feed_master
set f6 = '"'+rtrim(f6)+'"'
where isnumeric(f6) = 0

update aph_web_feed_master
set f7 = '"'+rtrim(f7)+'"'
where isnumeric(f7) = 0

update aph_web_feed_master
set f8 = '"'+rtrim(f8)+'"'
where isnumeric(f8) = 0

update aph_web_feed_master
set f9 = '"'+rtrim(f9)+'"'
where isnumeric(f9) = 0

update aph_web_feed_master
set f10 = '"'+rtrim(f10)+'"'
where isnumeric(f10) = 0

update aph_web_feed_master
set f11 = '"'+rtrim(f11)+'"'
where isnumeric(f11) = 0

update aph_web_feed_master
set f12 = '"'+rtrim(f12)+'"'
where isnumeric(f12) = 0

update aph_web_feed_master
set f13 = '"'+rtrim(f13)+'"'
where isnumeric(f13) = 0

update aph_web_feed_master
set f14 = '"'+rtrim(f14)+'"'
where isnumeric(f14) = 0

update aph_web_feed_master
set f15 = '"'+rtrim(f15)+'"'
where isnumeric(f15) = 0

update aph_web_feed_master
set f16 = '"'+rtrim(f16)+'"'
where isnumeric(f16) = 0

update aph_web_feed_master
set f17 = '"'+rtrim(f17)+'"'
where isnumeric(f17) = 0

update aph_web_feed_master
set f18 = '"'+rtrim(f18)+'"'
where isnumeric(f18) = 0

update aph_web_feed_master
set f19 = '"'+rtrim(f19)+'"'
where isnumeric(f19) = 0

--concatenate the fields into the output field to send only the fields appropriate to each record type
update aph_web_feed_master 
set output =  isnull(f1,'')+','+isnull(f2,'')+','+isnull(f3,'')+','+isnull(f4,'')+','+isnull(f5,'')
where f1 in ('category', 'categoryRelation', 'categoryProductRelation')

update aph_web_feed_master 
set output =  isnull(f1,'')+','+isnull(f2,'')+','+isnull(f3,'')+','+isnull(f4,'')+','+isnull(f5,'')+','+isnull(f6,'')+','+isnull(f7,'')
where f1 in ('association')

/*
update aph_web_feed_master 
set output =  isnull(f1,'')+','+isnull(f2,'')+','+isnull(f3,'')+','+isnull(f4,'')+','+isnull(f5,'')+','+isnull(f6,'')+','+isnull(f7,'')+','+isnull(f8,'')+','+isnull(f9,'')
where f1 in ('categoryDescription')
*/

update aph_web_feed_master 
set output =  isnull(f1,'')+','+isnull(f2,'')+','+isnull(f3,'')+','+isnull(f4,'')+','+isnull(f5,'')+','+isnull(f6,'')+','+isnull(f7,'')+','+isnull(f8,'')+','+isnull(f9,'')+','+isnull(f10,'')
where f1 in ('price','attribute')

update aph_web_feed_master 
set output =  isnull(f1,'')+','+isnull(f2,'')+','+isnull(f3,'')+','+isnull(f4,'')+','+isnull(f5,'')+','+isnull(f6,'')+','+isnull(f7,'')+','+isnull(f8,'')+','+isnull(f9,'')+','+isnull(f10,'')+','+isnull(f11,'')+','+isnull(f12,'')
where f1 in ('productDescription','attributeValue')

update aph_web_feed_master 
set output =  isnull(f1,'')+','+isnull(f2,'')+','+isnull(f3,'')+','+isnull(f4,'')+','+isnull(f5,'')+','+isnull(f6,'')+','+isnull(f7,'')+','+isnull(f8,'')+','+isnull(f9,'')+','+isnull(f10,'')+','+isnull(f11,'')+','+isnull(f12,'')+','+isnull(f13,'')+','+isnull(f14,'')+','+isnull(f15,'')+','+isnull(f16,'')+','+isnull(f17,'')
where f1 in ('product')

update bookdates
set activedate = @thisrundate,
bestdate = @thisrundate,
lastmaintdate = getdate(),
lastuserid = 'QSIADMIN'
from bookdates bd
join feedout_titles ft
on bd.bookkey = ft.bookkey
and bd.datetypecode = 483
and bd.printingkey = 1
join bookmisc bm
on bd.bookkey = bm.bookkey
and bm.misckey=2
and bm.longvalue = 1

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to update Feed to eCommerce on bookdates. Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

insert into bookdates
(bookkey, printingkey, datetypecode, activedate, actualind, recentchangeind, lastuserid,
lastmaintdate, estdate, sortorder, bestdate, scmatkey)
select distinct ft.bookkey, 1, 483, @thisrundate, null, null, 'QSIADMIN',getdate(), null, 1, @thisrundate,null
from feedout_titles ft
join bookmisc bm
on ft.bookkey = bm.bookkey
and bm.misckey = 2
and bm.longvalue = 1
left outer join bookdates bd
on ft.bookkey = bd.bookkey
and bd.datetypecode = 483
where bd.bookkey is null

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @error_code = -1
	SET @error_desc = 'Unable to insert Feed to eCommerce on bookdates. Error #' + cast(@error_var as varchar(20))
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
	RETURN
END 

--exec master.dbo.xp_cmdshell 'bcp "SELECT output from PSS..aph_web_feed_master order by sortorder" queryout D:\firebrand_feeds\tmm2websphere\aph_web_feed_master.csv -c -t"," -T'
exec master.dbo.xp_cmdshell 'bcp "SELECT output from APH..aph_web_feed_master order by sortorder" queryout \\mohawk\users\PMilana\APH\tmm2websphere\aph_web_feed_master.csv -c -t"," -T'

exec write_qsijobmessage @qsibatchkey, @qsijobkey, 2,1,null,null,'QSIADMIN',0,0,0,6,'job completed','completed',@error_code output, @error_desc output

END

SET NOCOUNT OFF
















