SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.feed_out_web_toc') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.feed_out_web_toc
end

GO

create proc dbo.feed_out_web_toc 
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

DECLARE @err_msg varchar (100)

DECLARE @feed_system_date datetime
DECLARE @feedout_isbn varchar(10) 
DECLARE @feedout_toc varchar(4000)
DECLARE @i_bookkey int
DECLARE @i_isbn int
DECLARE @feedout_count int

BEGIN tran
 
SELECT @feed_system_date = getdate()

 
 /* delete old records */ 
 delete from  feedout_web_toc 
 
DECLARE feed_toc INSENSITIVE CURSOR
  FOR
 select distinct b.bookkey
 	from bookdetail b, website w, catalog c, catalogsection cs, bookcatalog bc
 		 where c.catalogkey= w.websitecatalogkey
			and c.catalogkey= cs.catalogkey
			and cs.sectionkey=bc.sectionkey
			and bc.bookkey=b.bookkey 
			and bisacstatuscode <> 6 
			
 FOR READ ONLY

OPEN feed_toc
FETCH NEXT FROM feed_toc 
INTO  
	@i_bookkey

select @i_isbn  = @@FETCH_STATUS

if @i_isbn <> 0 /*no isbn*/
begin	
	insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@feedout_isbn,'3',@feed_system_date,'NO ROWS to PROCESS')
end

while (@i_isbn<>-1 )  /* sttus 1*/
begin
	IF (@i_isbn<>-2) /* status 2*/
	begin

		 if @i_bookkey > 0 
		   begin
/* clear fields for next record*/ 
  			select @feedout_count = 0
			select @feedout_toc = ''

/*cat in bookdetail.titleprefix */
   			select @feedout_count = count(*) 
			     from isbn
			 where bookkey=@i_bookkey  
  			if @feedout_count > 0 
			  begin
   				select @feedout_isbn=isbn10
				    from isbn
     					where bookkey=@i_bookkey 
 			   end
			if datalength(@feedout_isbn) = 0
			  begin
				 insert into feedhistory (numisbnsucceeded, 
     					numisbnfailed,batchnumber,processdate,messagetext) 
  				 values (0, @i_bookkey,1,@feed_system_date,'NO ROW ISBN row not outputted- TOC EXPORT')
			  end
			else
			  begin
/* comment table of content datacode 3 and subcode 51*/
				select @feedout_count = 0
				select @feedout_count = count(*) 
				     from bookcommenthtml 
  					   where bookkey=@i_bookkey  
						and printingkey=1
						and commenttypecode=3 and commenttypesubcode=51
	  			if @feedout_count > 0 
				  begin
    					 select @feedout_toc = commenttext 
						from bookcommenthtml
  					 	  where bookkey=@i_bookkey 
							and printingkey=1 
							and commenttypecode=3 and commenttypesubcode=51
					end
				  else
				    begin	
						select @feedout_count = count(*) 
						     from bookcomments 
		  					   where bookkey=@i_bookkey  
								and printingkey=1
								and commenttypecode=3 and commenttypesubcode=51
			  			if @feedout_count > 0 
						  begin
    							 select @feedout_toc = commenttext 
								from bookcomments 
  								   where bookkey=@i_bookkey 
									and printingkey=1 
									and commenttypecode=3 and commenttypesubcode=51
						end
			  	  end
		INSERT INTO feedout_web_toc
			(isbn ,toc)
		VALUES (@feedout_isbn  ,@feedout_toc)
	  end
	end
		FETCH NEXT FROM feed_toc
		  INTO 	
			@i_bookkey

			select @i_isbn = @@FETCH_STATUS
end

END

close feed_toc
deallocate feed_toc

commit tran

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

