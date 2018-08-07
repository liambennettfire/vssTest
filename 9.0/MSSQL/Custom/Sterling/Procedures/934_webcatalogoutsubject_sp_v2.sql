if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[webcatalogoutsubject_sp_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[webcatalogoutsubject_sp_v2]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE proc dbo.webcatalogoutsubject_sp_v2 as

/** This Function will Exports All titles according to Subject Category**/
/** Modified 01/23/03 to change from Bisac category to Sterling Category **/
/** Modified 02/05/03 to select External Code for Web weight instead of Eloquence Field Tag **/
/** Modified 01/28/04 to remove Not Cataloged  titles from the web site**/
/** Modified 05/31/06 CRM 3951 Only output ACTIVE subjects in WebSubjectOut based on the gentable/subgentable entries**/

DECLARE @i_sectionkey int
DECLARE @c_sectiondescription varchar (100)
DECLARE @i_bookkey int
DECLARE @c_title varchar(80)
DECLARE @c_titleprefix varchar (80)
DECLARE @i_catalogweightcode int
DECLARE @c_catalogweighttag varchar(25)
DECLARE @i_firstsection  int
DECLARE @i_count int
DECLARE @i_bookcount int
DECLARE @c_outputstring varchar (255)
DECLARE @i_section_cursor_status int
DECLARE @i_book_cursor_status int
DECLARE @i_calcsectionkey int
DECLARE @i_majorcode int
DECLARE @i_minorcode int
DECLARE @c_majordesc varchar(80)
DECLARE @c_minordesc varchar(80)
DECLARE @i_major_cursor_status int
DECLARE @i_minor_cursor_status int

select @i_firstsection = 1
select @i_count = 0


/** Columns
categorytableid                                                                                                                  int                                                                                                                              no                                  4           10    0     no                                  (n/a)                               (n/a)                               NULL
categorycode                                                                                                                     int                                                                                                                              no                                  4           10    0     no                                  (n/a)                               (n/a)                               NULL
categorysubcode    
**/


/** Create an Arbitrary Section Key for use in the Subject Category Sections
    by selecting the max sectionkey from bookcatalog **/

select @i_calcsectionkey = max (sectionkey) + 1
from catalogsection

declare major_cursor INSENSITIVE CURSOR
FOR
select g.datacode,g.datadesc
from gentables g
where g.tableid=412 
and (g.gen1ind is null or g.gen1ind = 0)  /*remove rows not wanted*/
and g.datacode in
(select distinct (categorycode) from booksubjectcategory 
where categorytableid=412 
and bookkey in (select bookkey from bookdetail where publishtowebind=1))
and g.deletestatus = 'N' -- PM 5/31/06 CRM 3951	
order by g.datadesc
FOR READ ONLY

open major_cursor
fetch next from major_cursor 
into @i_majorcode, @c_majordesc

select @i_major_cursor_status = @@FETCH_STATUS
/* print 'Section cursor status ' + convert (varchar (15),@i_section_cursor_status) */
while (@i_major_cursor_status <> -1)
begin
	
	/** First check to see if this major category has any Active Books assigned to it, 
	This will check to see if Publish To Web Flag is True **/
	select @i_count = count(*)
	from booksubjectcategory bc, bookdetail bd
	where categorytableid=412 
	and bc.categorycode=@i_majorcode
	and bc.bookkey=bd.bookkey
	and bd.publishtowebind=1

	if @i_count > 0  /** Output the Major Section Info, then output the Minor sections via cursor*/
	begin
		select @c_majordesc = replace (@c_majordesc, '<','&lt;')
		select @c_majordesc = replace (@c_majordesc, '&','&amp;')

		
		select @c_outputstring = ('<Section Selected="No" Display="Yes" FeaturedSection="No">')
		insert into webcatalogfeed (feedtext) values (@c_outputstring) 

		select @i_calcsectionkey=@i_calcsectionkey+1
		select @c_outputstring = '<SectionKey>' + convert (varchar (15),@i_calcsectionkey) + '</SectionKey>'
		insert into webcatalogfeed (feedtext) values (@c_outputstring) 
	
		select @c_outputstring = '<Name><![CDATA[' + @c_majordesc + ']]></Name>'
		insert into webcatalogfeed (feedtext) values (@c_outputstring) 


		declare minor_cursor INSENSITIVE CURSOR
		FOR
		select sg.datasubcode, sg.datadesc
		from subgentables sg
		where sg.tableid=412
		and sg.datacode=@i_majorcode
		and sg.datasubcode in 
		(select distinct (categorysubcode) 
		from booksubjectcategory 
		where categorytableid=412 and categorycode = @i_majorcode and 
		bookkey in
		(select bookkey from bookdetail where publishtowebind=1))
 		and sg.deletestatus = 'N' -- PM 5/31/06 CRM 3951	
		order by sg.datadesc

		FOR READ ONLY

		open minor_cursor
		fetch next from minor_cursor 
		into @i_minorcode, @c_minordesc

		select @i_minor_cursor_status = @@FETCH_STATUS
		/* print 'Section cursor status ' + convert (varchar (15),@i_section_cursor_status) */
		while (@i_minor_cursor_status <> -1)
		begin	
	

			/** First check to see if this minor category has any Active Books assigned to it, 
			This will check to see if Publish To Web Flag is True **/
			select @i_count = count(*)
			from booksubjectcategory bc, bookdetail bd
			where categorytableid=412 and bc.categorycode=@i_majorcode
			and bc.categorysubcode=@i_minorcode
			and bc.bookkey=bd.bookkey
			and bd.publishtowebind=1

			if @i_count > 0  /** Output the Minor Section Info, then output the Minor sections via cursor*/
			begin
				select @c_minordesc = replace (@c_minordesc, '<','&lt;')
				select @c_minordesc = replace (@c_minordesc, '&','&amp;')		
				select @c_outputstring = ('<Section Selected="No" Display="Yes" FeaturedSection="No">')
				insert into webcatalogfeed (feedtext) values (@c_outputstring) 

				select @i_calcsectionkey=@i_calcsectionkey+1
				select @c_outputstring = '<SectionKey>' + convert (varchar (15),@i_calcsectionkey) + '</SectionKey>'
				insert into webcatalogfeed (feedtext) values (@c_outputstring) 
	
				select @c_outputstring = '<Name><![CDATA[' + @c_minordesc + ']]></Name>'
				insert into webcatalogfeed (feedtext) values (@c_outputstring) 



			declare book_cursor insensitive cursor
			FOR
				select b.bookkey, b.title
				from booksubjectcategory bc, book b, bookdetail bd
				where categorytableid=412 and bc.categorycode=@i_majorcode
				and bc.categorysubcode=@i_minorcode
				and b.bookkey=bc.bookkey
				and bd.bookkey=bc.bookkey
				and bd.publishtowebind=1
				order by b.title
			FOR READ ONLY

			open book_cursor
			fetch next from book_cursor 
			into @i_bookkey,  @c_title
			exec convert_char_to_unicode_column @c_title output
			select @i_bookcount=0

			select @i_book_cursor_status = @@FETCH_STATUS
			while (@i_book_cursor_status <> -1)
			begin
				select @i_bookcount=@i_bookcount + 1
				select @c_title = replace (@c_title, '<','&lt;')
				select @c_title = replace (@c_title, '&','&amp;')

				/*** Select the externalcode which will match the weight tag **/
				/** in the style sheet allowing flexibility of the display of titles **/

				select @i_catalogweightcode = NULL

				select @i_catalogweightcode = customcode03 
				from bookcustom
				where bookkey=@i_bookkey
				
				select @c_catalogweighttag = NULL
				
				if @i_catalogweightcode is not null
				begin
					select @c_catalogweighttag= externalcode
					from gentables
					where tableid=419
					and datacode = @i_catalogweightcode
				end
			
				/* If the catalog web weight tag on the first title
                                   is blank, default to Web Featured (3) */
				if @c_catalogweighttag is NULL and @i_bookcount=1
				begin 
					select @c_catalogweighttag = 'WEBWEIGHT3'
				end				
				else if @c_catalogweighttag = NULL 
				begin 
					select @c_catalogweighttag = ''
				end
				

				if @c_catalogweighttag = '' 
				begin
					select @c_catalogweighttag = '10'
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
				into @i_bookkey, @c_title
				exec convert_char_to_unicode_column @c_title output

				select @i_book_cursor_status = @@FETCH_STATUS

			end /** While Book Cursor **/
		
			close book_cursor
			deallocate book_cursor

			/* Close the Section for the current Subject Minor Section **/
			select @c_outputstring = ('</Section>')
			insert into webcatalogfeed (feedtext) values (@c_outputstring) 

		end /** if Count > 0 For Subject Minor Section**/

		fetch next from minor_cursor 
		into @i_minorcode, @c_minordesc

		select @i_minor_cursor_status = @@FETCH_STATUS

		end /* while minor_cursor */

		close minor_cursor
		deallocate minor_cursor
	
		/* Close the Section for the current Subject Major Section **/
		select @c_outputstring = ('</Section>')
		insert into webcatalogfeed (feedtext) values (@c_outputstring) 

	end /** if Count > 0 for Subject Major Section**/



	fetch next from major_cursor 
	into @i_majorcode, @c_majordesc

	select @i_major_cursor_status = @@FETCH_STATUS

end /* while major_cursor */

close major_cursor
deallocate major_cursor




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


