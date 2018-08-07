IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_author_formatted') )
DROP FUNCTION dbo.rpt_get_author_formatted
GO

/****** Object:  StoredProcedure [dbo].[rpt_get_author_formatted]    Script Date: 05/12/2009 18:53:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[rpt_get_author_formatted] 
(@v_bookkey int)
returns varchar (8000)
as
/** Revision History  **/
/** Created by DSL 6/10/2008  ***/

/** This procedure will return a  formatted author string including the Author Type (altdesc2 as first priority) */
/** example:

by Fran Toolan, Ben Todd
Illustrated by Susan Burke, Brock Lyman

Written and modified 5/11/2009 by DSL  */
begin

DECLARE @c_output varchar (8000) 
DECLARE @c_currentauthorheader varchar (255) 
DECLARE @c_authorheader varchar (255) 
DECLARE @c_authorname varchar (255) 
DECLARE @c_datadesc varchar (255)
DECLARE @c_alternatedesc varchar (255)
DECLARE @i_bookauthor_cursor_status int
DECLARE @i_count int
DECLARE @i_typecount int
DECLARE @i_typetotalcount int
DECLARE @i_authortypecode int
DECLARE @i_authorkey int

/** Initialize the comment strings **/
select @c_output = ''
select @c_currentauthorheader = ''
select @c_authorheader = ''
select @i_count = 0

DECLARE cursor_bookauthor CURSOR
FOR

select ba.authorkey, g.datadesc,g.alternatedesc1, ba.authortypecode
from bookauthor ba, gentables g
where ba.bookkey = @v_bookkey
and ba.authortypecode = g.datacode
and g.tableid=134
order by isnull(g.sortorder,100), ba.sortorder

FOR READ ONLY


	
OPEN cursor_bookauthor

FETCH NEXT FROM cursor_bookauthor
INTO @i_authorkey, @c_datadesc, @c_alternatedesc, @i_authortypecode
	
select @i_bookauthor_cursor_status = @@FETCH_STATUS

while (@i_bookauthor_cursor_status<>-1 )
begin
	IF (@i_bookauthor_cursor_status<>-2)
	begin
		select @i_count = @i_count + 1
		/*First choice is to use Alternate Desc, otherwise use datadesc*/
		if @c_alternatedesc is not null
		begin
			select @c_authorheader = @c_alternatedesc
		end
		else
		begin
			select @c_authorheader = @c_datadesc
			
		end

		if @c_authorheader is null
		begin 
			select @c_authorheader = ''
		end
		
		
		if @c_currentauthorheader <> @c_authorheader
		begin
			/* first time for this authortype, so output the header*/
			select @c_currentauthorheader = @c_authorheader
			select @i_typecount=1
			
			if @i_count > 1 /* Need a carriage return between authortypes, as long as this isn't the first one */
			begin
				select @c_output = @c_output + char(13)
			end
			select @c_output = @c_output + @c_currentauthorheader + ' ' + dbo.rpt_get_contact_name (@i_authorkey,'C')
		end
		else
	    begin
			/* another author exists for this authortype, so follow it with a comma, and or et al.*/
			select @i_typecount = @i_typecount + 1
			
			/*get the totalcount for this authortype */
			select @i_typetotalcount = count (*) 
			from bookauthor 
			where bookkey = @v_bookkey
			and authortypecode in
			(select datacode 
			 from gentables 
			 where tableid= 134
			 and alternatedesc1 = @c_currentauthorheader 
			 or datadesc = @c_currentauthorheader) /*check both altdesc1 and datadesc, because we will
			 default using datadesc as the heading if ther is no altdesc1*/
			 		
			
			if @i_typecount > 4 and @i_authortypecode = 12 /** 4 entries for Author, then et al **/
			begin 
				select @c_output = @c_output + ' et. al.'
			end
			else if @i_typecount > 3 and @i_authortypecode <> 12 /** 3 entries for all other types, then et al **/
			begin 
				select @c_output = @c_output + ' et. al.'
			end
			else /** Output the Author name - still room available **/
			begin 
				if @i_typecount = @i_typetotalcount /* Last one, use the word And */
				begin 
					select @c_output = @c_output + ' and '
				end	
				else /* not the last one, separate with a comma */
				begin
					select @c_output = @c_output + ', '
				end	
				/* now output the name */
				select @c_output = @c_output + dbo.rpt_get_contact_name (@i_authorkey,'C')
			end
		end
		

		
		/********* Test Output ********/
		/*print 'c_commenttext = ' + @c_commenttext
		select @c_output = 'Bookkey = ' + convert (varchar (25),@v_bookkey) + 
		'   Workkey = ' + convert (varchar (25),@i_workkey) + 
		'   Other Format Bookkey = ' + convert (varchar (25),@i_otherbookkey) + 
		'   ISBN = ' + @c_isbn +
		'   Format = ' + @c_format +
		'   Discount = ' + @c_discount + 
		'   US Price = ' + @c_usretail +
		'   UK Price = ' + @c_ukretail +
		'   Pub Year = ' + @c_pubyear
		print @c_output*/

		

	end /* End If status statement */

    FETCH NEXT FROM cursor_bookauthor
    INTO @i_authorkey, @c_datadesc, @c_alternatedesc, @i_authortypecode
        			
	select @i_bookauthor_cursor_status = @@FETCH_STATUS

end /** End Cursor bookformats While **/

close cursor_bookauthor
deallocate cursor_bookauthor


/*print 'End Comment:' + @c_output*/

return @c_output
end
GO

grant exec on rpt_get_author_formatted to public
go
