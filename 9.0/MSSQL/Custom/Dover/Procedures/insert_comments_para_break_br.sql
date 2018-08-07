SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.insert_comments_para_break_br') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.insert_comments_para_break_br
end

GO
create proc dbo.insert_comments_para_break_br
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

DECLARE @online_commenttext varchar (8000) 
DECLARE @charfind  int
DECLARE @charfind2  int
DECLARE @searchtest1  int
DECLARE @searchtest2  int
DECLARE @searchtest3  int
DECLARE @searchtest4  int
DECLARE @i_status int
DECLARE @i_bookkey  int
DECLARE @i_printingkey  int
DECLARE @i_commenttypecode  int
DECLARE @i_commenttypesubcode  int
DECLARE @c_commentstring  varchar (2000)
DECLARE @c_commenttext varchar (8000)
DECLARE @c_lastuserid varchar (30)
DECLARE @d_lastmaintdate datetime
DECLARE @i_releasetoeloquenceind  int

BEGIN tran
 
DECLARE insertcomments_br INSENSITIVE CURSOR
  FOR

	select bc.BOOKKEY,bc.PRINTINGKEY, bc.COMMENTTYPECODE,bc.COMMENTTYPESUBCODE,
    		bc.COMMENTSTRING, bc.COMMENTTEXT,bc.LASTUSERID,bc.LASTMAINTDATE,
		bc.RELEASETOELOQUENCEIND
			from bookcomments bc   
 FOR READ ONLY


OPEN insertcomments_br 
FETCH NEXT FROM insertcomments_br
INTO  
	@i_bookkey  ,
	@i_printingkey  ,
 	@i_commenttypecode,
	@i_commenttypesubcode,
 	@c_commentstring,
	@c_commenttext ,
	@c_lastuserid ,
	@d_lastmaintdate ,
	@i_releasetoeloquenceind  

select @i_status  = @@FETCH_STATUS

while (@i_status<>-1 )  /* sttus 1*/
  begin
	IF (@i_status<>-2) /* status 2*/
	  begin

	select @online_commenttext = @c_commenttext
	
	select @searchtest1 = charindex('<br>',@online_commenttext)

  	if @searchtest1 > 0  
	  begin
	
	  while @searchtest1 > 0 
	    begin
		select @online_commenttext = STUFF(@online_commenttext,@searchtest1,4,char(13))
	
		select @searchtest1 = 0
	
		select @searchtest1 = charindex('<br>',@online_commenttext)
	    end

		delete from bookcomments
			where bookkey = @i_bookkey
				and printingkey = @i_printingkey
				and commenttypecode = @i_commenttypecode
				and commenttypesubcode = @i_commenttypesubcode

		insert into bookcomments
		 values ( @i_bookkey,@i_printingkey,@i_commenttypecode,
			@i_commenttypesubcode,@c_commentstring,@online_commenttext,
			'TAGFIX', getdate(),@i_releasetoeloquenceind)

		select @online_commenttext = ''
		select @charfind2 = 0 
		select @searchtest1 = 0

		select @charfind2 = count(*) 
			from bookcommentrtf
				where bookkey = @i_bookkey
				and printingkey = @i_printingkey
				and commenttypecode = @i_commenttypecode
				and commenttypesubcode = @i_commenttypesubcode
		if @charfind2 > 0 
		  begin
			select @online_commenttext = COMMENTTEXT 
				from bookcommentrtf
					where bookkey = @i_bookkey
				and printingkey = @i_printingkey
				and commenttypecode = @i_commenttypecode
				and commenttypesubcode = @i_commenttypesubcode
				
				select @searchtest1 = charindex('<br>',@online_commenttext)

			  while @searchtest1 > 0 
	 	 	    begin
	
			/* insert the paragraph by itself do not circle the entire paragraph*/
				select @online_commenttext = STUFF(@online_commenttext,@searchtest1,4,'{\par}\pard\ql{\f0\fs20\cf0\up0\dn0 }')
		
				select @searchtest1 = 0
	
				select @searchtest1 = charindex('<br>',@online_commenttext)
		 	 end
				
			delete from bookcommentrtf
				where bookkey = @i_bookkey
				and printingkey = @i_printingkey
				and commenttypecode = @i_commenttypecode
				and commenttypesubcode = @i_commenttypesubcode 

			insert into bookcommentrtf
			 values ( @i_bookkey,@i_printingkey,@i_commenttypecode,
				@i_commenttypesubcode,@c_commentstring,@online_commenttext,
				'TAGFIX', getdate(),@i_releasetoeloquenceind)	

	   	end 
	  end /** End of Search Test */

	select @searchtest1 = 0	
	select @online_commenttext = ''

    end
		FETCH NEXT FROM insertcomments_br
		INTO  
			@i_bookkey  ,
			@i_printingkey  ,
 			@i_commenttypecode,
			@i_commenttypesubcode,
 			@c_commentstring,
			@c_commenttext ,
			@c_lastuserid ,
			@d_lastmaintdate ,
			@i_releasetoeloquenceind  

	select @i_status  = @@FETCH_STATUS

end

close insertcomments_br 
deallocate insertcomments_br

commit tran

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
