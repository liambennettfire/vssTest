if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[webcatalogout_sp_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[webcatalogout_sp_v2]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE proc dbo.webcatalogout_sp_v2 @i_websitekey int, @i_exportsubjectind int as

/** Send websitekey and exportsubjectind as parameters **/
/** exportsubjectind = 1 for exporting Bisac Subjects as additional sections **/
/** zero = Do not Export the Bisac Subjects **/
DECLARE @i_websitecatalogkey int
DECLARE @i_websitecatalogkey2 int
DECLARE @i_websitecatalogkey3 int
DECLARE @i_websitecatalogkey4 int
DECLARE @i_websitecatalogkey5 int
DECLARE @i_websitecatalogkey6 int
DECLARE @i_websitecatalogkey7 int
DECLARE @i_websitecatalogkey8 int
DECLARE @i_websitecatalogkey9 int
DECLARE @i_websitecatalogkey10 int
DECLARE @c_websitecatalogdescription varchar (100)
DECLARE @i_sectionkey int
DECLARE @c_sectiondescription varchar (100)
DECLARE @i_bookkey int
DECLARE @c_title varchar(80)
DECLARE @c_titleprefix varchar (80)
DECLARE @i_catalogweightcode int
DECLARE @c_catalogweighttag varchar(25)
DECLARE @i_firstsection  int
DECLARE @i_count int
DECLARE @c_outputstring varchar (255)
DECLARE @i_section_cursor_status int
DECLARE @i_book_cursor_status int
DECLARE @i_calcsectionkey int

select @i_firstsection = 1
select @i_count = 0


delete from webcatalogfeed



/** Output Header Info **/


select @c_outputstring = ('<?xml version="1.0" encoding="Windows-1250"?>')
 
insert into webcatalogfeed (feedtext) values (@c_outputstring)

select @c_outputstring =('<!DOCTYPE Catalog SYSTEM "Catalog.dtd">')
 
insert into webcatalogfeed (feedtext) values (@c_outputstring) 

select @c_outputstring = ('<Catalog>')
 
insert into webcatalogfeed (feedtext) values (@c_outputstring) 

select @i_websitecatalogkey = websitecatalogkey
from website 
where websitekey=@i_websitekey

select @c_websitecatalogdescription=description
from catalog
where catalogkey=@i_websitecatalogkey

select @c_outputstring = ('<Description>' + @c_websitecatalogdescription + '</Description>')
 
insert into webcatalogfeed (feedtext) values (@c_outputstring) 

/** PM 5/31/06 CRM 3951 Sterling Web Catalog Enhancements 
    (Remove the 'Featured Titles' section of Catalog.xml)**/

/** Output all Sections in the Main Catalog Section **/
--     exec webcatalogoutdetail_sp @i_websitecatalogkey

/** Call the SP to export the Bisac Subject Categories**/
if @i_exportsubjectind =  1 
begin
	exec webcatalogoutsubject_sp_v2
end


/** Output all Sections in the Secondary Catalog **/
/*
select @i_websitecatalogkey2=NULL

select @i_websitecatalogkey2 = websitecatalogkey2
from website 
where websitekey=@i_websitekey


if @i_websitecatalogkey2 is not null and  @i_websitecatalogkey2 > 0
begin
	exec webcatalogoutdetail_sp @i_websitecatalogkey2
end
*/

/*
select @i_websitecatalogkey3=NULL

select @i_websitecatalogkey3 = websitecatalogkey3
from website 
where websitekey=@i_websitekey

if @i_websitecatalogkey3 is not null and  @i_websitecatalogkey3 > 0
begin
	exec webcatalogoutdetail_sp @i_websitecatalogkey3
end
*/

/** Output all Sections in the Fourth Catalog **/
/*
select @i_websitecatalogkey4=NULL

select @i_websitecatalogkey4 = websitecatalogkey4
from website 
where websitekey=@i_websitekey

if @i_websitecatalogkey4 is not null and  @i_websitecatalogkey4 > 0
begin
	exec webcatalogoutdetail_sp @i_websitecatalogkey4
end
*/
/** Output all Sections in the Fifth Catalog **/
/*
select @i_websitecatalogkey5=NULL

select @i_websitecatalogkey5 = websitecatalogkey5
from website 
where websitekey=@i_websitekey

if @i_websitecatalogkey5 is not null and  @i_websitecatalogkey5 > 0
begin
	exec webcatalogoutdetail_sp @i_websitecatalogkey5
end
*/
/** Output all Sections in the Sixth Catalog **/
/*
select @i_websitecatalogkey6=NULL

select @i_websitecatalogkey6 = websitecatalogkey6
from website 
where websitekey=@i_websitekey

if @i_websitecatalogkey6 is not null and  @i_websitecatalogkey6 > 0
begin
	exec webcatalogoutdetail_sp @i_websitecatalogkey6
end*/
/** Output all Sections in the Seventh Catalog **/
/*
select @i_websitecatalogkey7=NULL

select @i_websitecatalogkey7 = websitecatalogkey7
from website 
where websitekey=@i_websitekey

if @i_websitecatalogkey7 is not null and  @i_websitecatalogkey7 > 0
begin
	exec webcatalogoutdetail_sp @i_websitecatalogkey7
end
*/
/** Output all Sections in the Eigth Catalog **/
/*
select @i_websitecatalogkey8=NULL

select @i_websitecatalogkey8 = websitecatalogkey8
from website 
where websitekey=@i_websitekey

if @i_websitecatalogkey8 is not null and  @i_websitecatalogkey8 > 0
begin
	exec webcatalogoutdetail_sp @i_websitecatalogkey8
end
*/
/** Output all Sections in the Ninth Catalog **/
/*
select @i_websitecatalogkey9=NULL

select @i_websitecatalogkey9 = websitecatalogkey9
from website 
where websitekey=@i_websitekey

if @i_websitecatalogkey9 is not null and  @i_websitecatalogkey9 > 0
begin
	exec webcatalogoutdetail_sp @i_websitecatalogkey9
end
*/
/** Output all Sections in the Tenth Catalog **/
/*
select @i_websitecatalogkey10=NULL

select @i_websitecatalogkey10 = websitecatalogkey10
from website 
where websitekey=@i_websitekey

if @i_websitecatalogkey10 is not null and  @i_websitecatalogkey10 > 0
begin
	exec webcatalogoutdetail_sp @i_websitecatalogkey10
end
*/


select @c_outputstring = ('</Catalog>')
insert into webcatalogfeed (feedtext) values (@c_outputstring) 







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

