SET QUOTED_IDENTIFIER ON ਍ഀ
GO਍ഀ
SET ANSI_NULLS ON ਍ഀ
GO਍ഀ
਍ഀ
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[webcatalogoutsubject_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)਍ഀ
drop procedure [dbo].[webcatalogoutsubject_sp]਍ഀ
GO਍ഀ
਍ഀ
create proc dbo.webcatalogoutsubject_sp as਍ഀ
਍ഀ
/** This Function will Exports All titles according to Bisac Subject Category**/਍ഀ
਍ഀ
DECLARE @i_sectionkey int਍ഀ
DECLARE @c_sectiondescription varchar (100)਍ഀ
DECLARE @i_bookkey int਍ഀ
DECLARE @c_title varchar(80)਍ഀ
DECLARE @c_titleprefix varchar (80)਍ഀ
DECLARE @i_catalogweightcode int਍ഀ
DECLARE @c_catalogweighttag varchar(25)਍ഀ
DECLARE @i_firstsection  int਍ഀ
DECLARE @i_count int਍ഀ
DECLARE @i_bookcount int਍ഀ
DECLARE @c_outputstring varchar (255)਍ഀ
DECLARE @i_section_cursor_status int਍ഀ
DECLARE @i_book_cursor_status int਍ഀ
DECLARE @i_calcsectionkey int਍ഀ
DECLARE @i_bisacmajorcode int਍ഀ
DECLARE @i_bisacminorcode int਍ഀ
DECLARE @c_bisacmajordesc varchar(80)਍ഀ
DECLARE @c_bisacminordesc varchar(80)਍ഀ
DECLARE @i_bisacmajor_cursor_status int਍ഀ
DECLARE @i_bisacminor_cursor_status int਍ഀ
਍ഀ
select @i_firstsection = 1਍ഀ
select @i_count = 0਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
/*** After building sections from the Web Catalog, Add all of the Bisac Subject Categories which contain active books **/਍ഀ
਍ഀ
/** Create an Arbitrary Section Key for use in the Bisac Subject Category Sections਍ഀ
    by selecting the max sectionkey from bookcatalog **/਍ഀ
਍ഀ
select @i_calcsectionkey = max (sectionkey) + 1਍ഀ
from bookcatalog਍ഀ
਍ഀ
declare bisacmajor_cursor INSENSITIVE CURSOR਍ഀ
FOR਍ഀ
select g.datacode,g.datadesc਍ഀ
from gentables g਍ഀ
where g.tableid=339 ਍ഀ
and g.datacode in਍ഀ
(select distinct (bisaccategorycode) from bookbisaccategory where bookkey in਍ഀ
(select bookkey from bookdetail where publishtowebind=1))਍ഀ
order by g.datadesc਍ഀ
FOR READ ONLY਍ഀ
਍ഀ
open bisacmajor_cursor਍ഀ
fetch next from bisacmajor_cursor ਍ഀ
into @i_bisacmajorcode, @c_bisacmajordesc਍ഀ
਍ഀ
select @i_bisacmajor_cursor_status = @@FETCH_STATUS਍ഀ
/* print 'Section cursor status ' + convert (varchar (15),@i_section_cursor_status) */਍ഀ
while (@i_bisacmajor_cursor_status <> -1)਍ഀ
begin਍ഀ
	਍ഀ
	/** First check to see if this major category has any Active Books assigned to it, ਍ഀ
	This will check to see if Publish To Web Flag is True **/਍ഀ
	select @i_count = count(*)਍ഀ
	from bookbisaccategory bc, bookdetail bd਍ഀ
	where bc.bisaccategorycode=@i_bisacmajorcode਍ഀ
	and bc.bookkey=bd.bookkey਍ഀ
	and bd.publishtowebind=1਍ഀ
਍ഀ
	if @i_count > 0  /** Output the Major Section Info, then output the Minor sections via cursor*/਍ഀ
	begin਍ഀ
		select @c_bisacmajordesc = replace (@c_bisacmajordesc, '<','&lt;')਍ഀ
		select @c_bisacmajordesc = replace (@c_bisacmajordesc, '&','&amp;')਍ഀ
਍ഀ
		਍ഀ
		select @c_outputstring = ('<Section Selected="No" Display="Yes" FeaturedSection="No">')਍ഀ
		insert into webcatalogfeed (feedtext) values (@c_outputstring) ਍ഀ
਍ഀ
		select @i_calcsectionkey=@i_calcsectionkey+1਍ഀ
		select @c_outputstring = '<SectionKey>' + convert (varchar (15),@i_calcsectionkey) + '</SectionKey>'਍ഀ
		insert into webcatalogfeed (feedtext) values (@c_outputstring) ਍ഀ
	਍ഀ
		select @c_outputstring = '<Name><![CDATA[' + @c_bisacmajordesc + ']]></Name>'਍ഀ
		insert into webcatalogfeed (feedtext) values (@c_outputstring) ਍ഀ
਍ഀ
਍ഀ
		declare bisacminor_cursor INSENSITIVE CURSOR਍ഀ
		FOR਍ഀ
		select sg.datasubcode, sg.datadesc਍ഀ
		from subgentables sg਍ഀ
		where sg.tableid=339਍ഀ
		and sg.datacode=@i_bisacmajorcode਍ഀ
		and sg.datasubcode in ਍ഀ
		(select distinct (bisaccategorysubcode) ਍ഀ
		from bookbisaccategory ਍ഀ
		where bisaccategorycode = @i_bisacmajorcode and ਍ഀ
		bookkey in਍ഀ
		(select bookkey from bookdetail where publishtowebind=1))਍ഀ
		order by sg.datadesc਍ഀ
਍ഀ
		FOR READ ONLY਍ഀ
਍ഀ
		open bisacminor_cursor਍ഀ
		fetch next from bisacminor_cursor ਍ഀ
		into @i_bisacminorcode, @c_bisacminordesc਍ഀ
਍ഀ
		select @i_bisacminor_cursor_status = @@FETCH_STATUS਍ഀ
		/* print 'Section cursor status ' + convert (varchar (15),@i_section_cursor_status) */਍ഀ
		while (@i_bisacminor_cursor_status <> -1)਍ഀ
		begin	਍ഀ
	਍ഀ
਍ഀ
			/** First check to see if this minor category has any Active Books assigned to it, ਍ഀ
			This will check to see if Publish To Web Flag is True **/਍ഀ
			select @i_count = count(*)਍ഀ
			from bookbisaccategory bc, bookdetail bd਍ഀ
			where bc.bisaccategorycode=@i_bisacmajorcode਍ഀ
			and bc.bisaccategorysubcode=@i_bisacminorcode਍ഀ
			and bc.bookkey=bd.bookkey਍ഀ
			and bd.publishtowebind=1਍ഀ
਍ഀ
			if @i_count > 0  /** Output the Minor Section Info, then output the Minor sections via cursor*/਍ഀ
			begin਍ഀ
				select @c_bisacminordesc = replace (@c_bisacminordesc, '<','&lt;')਍ഀ
				select @c_bisacminordesc = replace (@c_bisacminordesc, '&','&amp;')		਍ഀ
				select @c_outputstring = ('<Section Selected="No" Display="Yes" FeaturedSection="No">')਍ഀ
				insert into webcatalogfeed (feedtext) values (@c_outputstring) ਍ഀ
਍ഀ
				select @i_calcsectionkey=@i_calcsectionkey+1਍ഀ
				select @c_outputstring = '<SectionKey>' + convert (varchar (15),@i_calcsectionkey) + '</SectionKey>'਍ഀ
				insert into webcatalogfeed (feedtext) values (@c_outputstring) ਍ഀ
	਍ഀ
				select @c_outputstring = '<Name><![CDATA[' + @c_bisacminordesc + ']]></Name>'਍ഀ
				insert into webcatalogfeed (feedtext) values (@c_outputstring) ਍ഀ
਍ഀ
਍ഀ
਍ഀ
			declare book_cursor insensitive cursor਍ഀ
			FOR਍ഀ
				select b.bookkey, b.title਍ഀ
				from bookbisaccategory bc, book b, bookdetail bd਍ഀ
				where bc.bisaccategorycode=@i_bisacmajorcode਍ഀ
				and bc.bisaccategorysubcode=@i_bisacminorcode਍ഀ
				and b.bookkey=bc.bookkey਍ഀ
				and bd.bookkey=bc.bookkey਍ഀ
				and bd.publishtowebind=1਍ഀ
				order by b.title਍ഀ
			FOR READ ONLY਍ഀ
਍ഀ
			open book_cursor਍ഀ
			fetch next from book_cursor ਍ഀ
			into @i_bookkey,  @c_title਍ഀ
			਍ഀ
			select @i_bookcount=0਍ഀ
਍ഀ
			select @i_book_cursor_status = @@FETCH_STATUS਍ഀ
			while (@i_book_cursor_status <> -1)਍ഀ
			begin਍ഀ
				select @i_bookcount=@i_bookcount + 1਍ഀ
				select @c_title = replace (@c_title, '<','&lt;')਍ഀ
				select @c_title = replace (@c_title, '&','&amp;')਍ഀ
਍ഀ
				/*** Select the eloquencefieldtag which will match the weight tag **/਍ഀ
				/** in the style sheet allowing flexibility of the display of titles **/਍ഀ
਍ഀ
				select @i_catalogweightcode = NULL਍ഀ
਍ഀ
				select @i_catalogweightcode = customcode03 ਍ഀ
				from bookcustom਍ഀ
				where bookkey=@i_bookkey਍ഀ
				਍ഀ
				select @c_catalogweighttag = NULL਍ഀ
				਍ഀ
				if @i_catalogweightcode is not null਍ഀ
				begin਍ഀ
					select @c_catalogweighttag= eloquencefieldtag਍ഀ
					from gentables਍ഀ
					where tableid=419਍ഀ
					and datacode = @i_catalogweightcode਍ഀ
				end਍ഀ
			਍ഀ
				/* If the catalog web weight tag on the first title਍ഀ
                                   is blank, default to Web Featured (3) */਍ഀ
				if @c_catalogweighttag is NULL and @i_bookcount=1਍ഀ
				begin ਍ഀ
					select @c_catalogweighttag = 'WEBWEIGHT3'਍ഀ
				end				਍ഀ
				else if @c_catalogweighttag = NULL ਍ഀ
				begin ਍ഀ
					select @c_catalogweighttag = ''਍ഀ
				end਍ഀ
				਍ഀ
਍ഀ
				if @c_catalogweighttag = '' ਍ഀ
				begin਍ഀ
					select @c_catalogweighttag = '10'਍ഀ
				end਍ഀ
਍ഀ
				if @c_catalogweighttag = 'WEBWEIGHT1' ਍ഀ
					select @c_catalogweighttag = '1'਍ഀ
				else if @c_catalogweighttag = 'WEBWEIGHT2' ਍ഀ
					select @c_catalogweighttag = '2'਍ഀ
				else if @c_catalogweighttag = 'WEBWEIGHT3' ਍ഀ
					select @c_catalogweighttag = '3'਍ഀ
				else if @c_catalogweighttag = 'WEBWEIGHT4' ਍ഀ
					select @c_catalogweighttag = '4'਍ഀ
				else if @c_catalogweighttag = 'WEBWEIGHT5' ਍ഀ
					select @c_catalogweighttag = '5'਍ഀ
				else if @c_catalogweighttag = 'WEBWEIGHT6' ਍ഀ
					select @c_catalogweighttag = '6'਍ഀ
				else if @c_catalogweighttag = 'WEBWEIGHT7' ਍ഀ
					select @c_catalogweighttag = '7'਍ഀ
				else if @c_catalogweighttag = 'WEBWEIGHT8' ਍ഀ
					select @c_catalogweighttag = '8'਍ഀ
				else if @c_catalogweighttag = 'WEBWEIGHT9' ਍ഀ
					select @c_catalogweighttag = '9'਍ഀ
				else if @c_catalogweighttag = 'WEBWEIGHT10' ਍ഀ
					select @c_catalogweighttag = '10'਍ഀ
				else਍ഀ
					select @c_catalogweighttag = '10'਍ഀ
਍ഀ
਍ഀ
				select @c_outputstring = ('<Book Weight="' + @c_catalogweighttag +'">')਍ഀ
			 ਍ഀ
				insert into webcatalogfeed (feedtext) values (@c_outputstring) ਍ഀ
਍ഀ
				select @c_outputstring = ('<BookKey>' + convert (varchar (15),@i_bookkey) ਍ഀ
						+ '</BookKey>')਍ഀ
				insert into webcatalogfeed (feedtext) values (@c_outputstring) ਍ഀ
		਍ഀ
				select @c_outputstring = ('<Title><![CDATA[' + @c_title + ']]></Title>')਍ഀ
				insert into webcatalogfeed (feedtext) values (@c_outputstring) ਍ഀ
			਍ഀ
				select @c_outputstring = ('</Book>')਍ഀ
				insert into webcatalogfeed (feedtext) values (@c_outputstring) ਍ഀ
਍ഀ
				fetch next from book_cursor ਍ഀ
				into @i_bookkey, @c_title਍ഀ
਍ഀ
				select @i_book_cursor_status = @@FETCH_STATUS਍ഀ
਍ഀ
			end /** While Book Cursor **/਍ഀ
		਍ഀ
			close book_cursor਍ഀ
			deallocate book_cursor਍ഀ
਍ഀ
			/* Close the Section for the current Bisac Minor Section **/਍ഀ
			select @c_outputstring = ('</Section>')਍ഀ
			insert into webcatalogfeed (feedtext) values (@c_outputstring) ਍ഀ
਍ഀ
		end /** if Count > 0 For Bisac Minor Section**/਍ഀ
਍ഀ
		fetch next from bisacminor_cursor ਍ഀ
		into @i_bisacminorcode, @c_bisacminordesc਍ഀ
਍ഀ
		select @i_bisacminor_cursor_status = @@FETCH_STATUS਍ഀ
਍ഀ
		end /* while bisacminor_cursor */਍ഀ
਍ഀ
		close bisacminor_cursor਍ഀ
		deallocate bisacminor_cursor਍ഀ
	਍ഀ
		/* Close the Section for the current Bisac Major Section **/਍ഀ
		select @c_outputstring = ('</Section>')਍ഀ
		insert into webcatalogfeed (feedtext) values (@c_outputstring) ਍ഀ
਍ഀ
	end /** if Count > 0 for Bisac Major Section**/਍ഀ
਍ഀ
਍ഀ
਍ഀ
	fetch next from bisacmajor_cursor ਍ഀ
	into @i_bisacmajorcode, @c_bisacmajordesc਍ഀ
਍ഀ
	select @i_bisacmajor_cursor_status = @@FETCH_STATUS਍ഀ
਍ഀ
end /* while bisacmajor_cursor */਍ഀ
਍ഀ
close bisacmajor_cursor਍ഀ
deallocate bisacmajor_cursor਍ഀ
਍ഀ
਍ഀ
GO਍ഀ
SET QUOTED_IDENTIFIER OFF ਍ഀ
GO਍ഀ
SET ANSI_NULLS ON ਍ഀ
GO਍ഀ
਍ഀ
