SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[webbuildcatalog_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[webbuildcatalog_sp]
GO

create proc dbo.webbuildcatalog_sp @i_websitekey int as

DECLARE @i_websitecatalogkey int
DECLARE @c_websitecatalogdescription varchar (100)
DECLARE @i_sectionkey int
DECLARE @c_sectiondescription varchar (100)
DECLARE @i_bookkey int
DECLARE @c_title varchar(80)
DECLARE @c_titleprefix varchar (80)
DECLARE @i_catalogweightcode int
DECLARE @i_defaultcatalogweightcode int
DECLARE @i_categorycode int
DECLARE @c_catalogweighttag varchar(25)
DECLARE @i_firstsection  int
DECLARE @i_count int
DECLARE @i_section_cursor_status int
DECLARE @i_book_cursor_status int
DECLARE @i_booksortorder int

DECLARE @i_categorytableid int
select @i_firstsection = 1
select @i_count = 0

/** Set the Tableid to the desired bookcategory Tableid **/
select @i_categorytableid = 317



/*****************************************************/
/** Get the default web weight code to be used for  **/
/** books being added to the catalog                **/

select @i_defaultcatalogweightcode = NULL

select @i_defaultcatalogweightcode= datacode
from gentables
where tableid=290
and eloquencefieldtag = 'WEBWEIGHT10'
			
if @i_defaultcatalogweightcode = NULL /** If code is not found, exit program **/
begin 
	print 'ERROR: Unable to obtain the default webweightcode for tableid=290,eloquencefieldtag=WEBWEIGHT10'
	return
end


select @i_websitecatalogkey = websitecatalogkey
from website 
where websitekey=@i_websitekey

declare section_cursor INSENSITIVE CURSOR
FOR
	select sectionkey,description from catalogsection 
	where catalogkey=@i_websitecatalogkey
	order by startingpagenumber
FOR READ ONLY

open section_cursor
fetch next from section_cursor 
into @i_sectionkey, @c_sectiondescription

select @i_section_cursor_status = @@FETCH_STATUS
/* print 'Section cursor status ' + convert (varchar (15),@i_section_cursor_status) */
while (@i_section_cursor_status <> -1)
begin
	/* print 'In Section Loop ' + convert (varchar (15),@i_sectionkey) */
	
	select @i_booksortorder=1000
	select @i_categorycode=0

	select @i_categorycode=datacode from gentables where tableid=@i_categorytableid
	and lower (datadesc) = lower (@c_sectiondescription)
	
	if @i_categorycode > 0 /*** This Section is based on a Book Category ***/
	begin
		/** First, remove all books from the Section which no longer have this Book 
		category assigned to it **/

		delete from bookcatalog where sectionkey=@i_sectionkey and 
		bookkey not in (select bookkey from bookcategory where categorycode=
		@i_categorycode)

		/** Next, Insert all Books into this section which have the corresponding Category Code
		on Book Category and which have not previously been added to this section **/

		insert into bookcatalog (bookkey,printingkey,sectionkey, catalogweightcode,
		lastuserid, lastmaintdate) 
		select bookkey, 1, @i_sectionkey,@i_defaultcatalogweightcode, 'WEBCATSP',getdate() 
		from bookcategory 
		where bookkey not in (select bookkey from bookcatalog where sectionkey=@i_sectionkey)
		and categorycode=@i_categorycode
		

	end /* If i_categorycount > 0 */	

	/* Set the Sort Order for all titles in the section based on WebWeight first, then
	Alphabetical by Title. If the Web Weight is not the default, do NOT set the sort order
	assuming that the Web user administrator has manually set the Weight and the sort order */

	declare book_cursor insensitive cursor
	FOR
		select b.bookkey, b.title,bc.catalogweightcode
		from bookcatalog bc, book b, gentables g
		where bc.sectionkey=@i_sectionkey
		and b.bookkey=bc.bookkey
		and g.tableid=290 and g.datacode=bc.catalogweightcode
		order by g.sortorder, b.title
	FOR READ ONLY

	open book_cursor
	fetch next from book_cursor 
	into @i_bookkey, @c_title, @i_catalogweightcode

	select @i_book_cursor_status = @@FETCH_STATUS
	while (@i_book_cursor_status <> -1)
	begin
		/** Check to see if this is the default WeightCode. If so, set the Sortorder **/
		/** starting at 1000. It is assumed that if the Weight is not the default that **/
		/** user has manually set the weight and sortorder, therefore we will not override **/
		/** it here. **/

		if @i_catalogweightcode = @i_defaultcatalogweightcode 
		begin
			update bookcatalog set sortorder = @i_booksortorder
			where bookkey=@i_bookkey and printingkey=1 
			and sectionkey=@i_sectionkey

			select @i_booksortorder = @i_booksortorder + 1
		end

		fetch next from book_cursor 
		into @i_bookkey, @c_title, @i_catalogweightcode

		select @i_book_cursor_status = @@FETCH_STATUS

	end /** While Book Cursor **/
		
	close book_cursor
	deallocate book_cursor

fetch next from section_cursor 
into @i_sectionkey, @c_sectiondescription

select @i_section_cursor_status = @@FETCH_STATUS

end /* while section_cursor */

close section_cursor
deallocate section_cursor



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

