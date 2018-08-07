if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[webcatalogoutdetail_sp_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[webcatalogoutdetail_sp_v2]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE proc dbo.webcatalogoutdetail_sp_v2 @i_websitecatalogkey int as

/** Send websitecatalogkey as parameters **/
/** This Procedure will output all Sections for the specified CatalogKey**/

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





declare section_cursor INSENSITIVE CURSOR
FOR
	select sectionkey,description from catalogsection 
	where catalogkey=@i_websitecatalogkey
	order by sortorder
FOR READ ONLY

open section_cursor
fetch next from section_cursor 
into @i_sectionkey, @c_sectiondescription

select @i_section_cursor_status = @@FETCH_STATUS
/* print 'Section cursor status ' + convert (varchar (15),@i_section_cursor_status) */
while (@i_section_cursor_status <> -1)
begin
	/* print 'In Section Loop ' + convert (varchar (15),@i_sectionkey) */
	select @c_sectiondescription = replace (@c_sectiondescription, '<','&lt;')
	select @c_sectiondescription = replace (@c_sectiondescription, '&','&amp;')
		
	select @i_count = 0

	select @i_count = count(*)
		from bookcatalog bc, book b, bookdetail bd
			where sectionkey=@i_sectionkey
				and b.bookkey=bc.bookkey
				and bd.bookkey=b.bookkey
                                                     and bd.publishtowebind  = 1

	if @i_count > 0 
	begin
		/* print 'in count > 0' */
	
		if @i_firstsection  = 1 
		begin
			select @c_outputstring = ('<Section Selected="No" Display="Yes" FeaturedSection="Yes">')
			 
			insert into webcatalogfeed (feedtext) values (@c_outputstring) 

			select @i_firstsection  = 0
                end
		else
		begin   /** Modified 9/25/02 to set all sections as FeaturedSection=Yes to allow for automatic Catalog Image Linking **/
			select @c_outputstring = ('<Section Selected="No" Display="Yes" FeaturedSection="Yes">')
			 
			insert into webcatalogfeed (feedtext) values (@c_outputstring) 
	
		end

		select @c_outputstring = '<SectionKey>' + convert (varchar (15),@i_sectionkey) + '</SectionKey>'
		 
		insert into webcatalogfeed (feedtext) values (@c_outputstring) 
	
		select @c_outputstring = '<Name><![CDATA[' + @c_sectiondescription + ']]></Name>'
		 
		insert into webcatalogfeed (feedtext) values (@c_outputstring) 

		declare book_cursor insensitive cursor
		FOR
			select b.bookkey, bd.titleprefix,b.title,bc.catalogweightcode
			from bookcatalog bc, book b, bookdetail bd
			where sectionkey=@i_sectionkey
			and b.bookkey=bc.bookkey
			and bd.bookkey=b.bookkey
                                        and bd.publishtowebind  = 1	
		order by sortorder
		FOR READ ONLY

		open book_cursor
		fetch next from book_cursor 
		into @i_bookkey, @c_titleprefix, @c_title, @i_catalogweightcode

	        exec convert_char_to_unicode_column @c_title output		
		
		select @i_book_cursor_status = @@FETCH_STATUS
		while (@i_book_cursor_status <> -1)
		begin
			select @c_title = replace (@c_title, '<','&lt;')
			select @c_title = replace (@c_title, '&','&amp;')


	
			/*** Select the eloquencefieldtag which will match the weight tag **/
			/** in the style sheet allowing flexibility of the display of titles **/

			select @c_catalogweighttag = NULL
	
			select @c_catalogweighttag= externalcode
			from gentables
			where tableid=290
			and datacode = @i_catalogweightcode
			
			if @c_catalogweighttag = NULL 
			begin 
				select @c_catalogweighttag = ''
			end

			if @c_catalogweighttag = '' 
			begin
				select @c_catalogweighttag = '10'
/*				select @c_catalogweighttag = 'WEBWEIGHTDEFAULT'  
				AA - change 4-26-01 from words to number 1-10	*/
			end

			if @c_catalogweighttag = 'WEBWEIGHT1' 
				select @c_catalogweighttag = '1'
			else if @c_catalogweighttag = 'WEBWEIGHT2' 
				select @c_catalogweighttag = '2'
			else if @c_catalogweighttag = 'WEBWEIGHT3' 
				select @c_catalogweighttag = '3'
			else if @c_catalogweighttag = 'WEBWEIGHT4' 
				select @c_catalogweighttag = '4'
			else if @c_catalogweighttag = 'WEBWEIGHT5' 
				select @c_catalogweighttag = '5'
			else if @c_catalogweighttag = 'WEBWEIGHT6' 
				select @c_catalogweighttag = '6'
			else if @c_catalogweighttag = 'WEBWEIGHT7' 
				select @c_catalogweighttag = '7'
			else if @c_catalogweighttag = 'WEBWEIGHT8' 
				select @c_catalogweighttag = '8'
			else if @c_catalogweighttag = 'WEBWEIGHT9' 
				select @c_catalogweighttag = '9'
			else if @c_catalogweighttag = 'WEBWEIGHT10' 
				select @c_catalogweighttag = '10'
			else
				select @c_catalogweighttag = '10'
			

			select @c_outputstring = ('<Book Weight="' + @c_catalogweighttag +'">')
			 
			insert into webcatalogfeed (feedtext) values (@c_outputstring) 
		
			select @c_outputstring = ('<BookKey>' + convert (varchar (15),@i_bookkey) 
						+ '</BookKey>')
			 
			insert into webcatalogfeed (feedtext) values (@c_outputstring) 
		
			select @c_outputstring = ('<Title><![CDATA[' + @c_title + ']]></Title>')
			 
			insert into webcatalogfeed (feedtext) values (@c_outputstring) 
			
			select @c_outputstring = ('</Book>')
			 
			insert into webcatalogfeed (feedtext) values (@c_outputstring) 

			fetch next from book_cursor 
			into @i_bookkey, @c_titleprefix, @c_title, @i_catalogweightcode
			
			exec convert_char_to_unicode_column @c_title output			

			select @i_book_cursor_status = @@FETCH_STATUS

		end /** While Book Cursor **/
		
		close book_cursor
		deallocate book_cursor

		select @c_outputstring = ('</Section>')
		 
		insert into webcatalogfeed (feedtext) values (@c_outputstring) 

	end /** if Count > 0 **/

fetch next from section_cursor 
into @i_sectionkey, @c_sectiondescription

select @i_section_cursor_status = @@FETCH_STATUS

end /* while section_cursor */

close section_cursor
deallocate section_cursor

return

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


