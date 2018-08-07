SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.feed_out_web_cat') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.feed_out_web_cat
end

GO

create proc dbo.feed_out_web_cat 
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

DECLARE @err_msg varchar (100)

DECLARE @feed_system_date datetime
DECLARE @feedout_cat varchar(10) 
DECLARE @feedout_title_desc varchar(80)
DECLARE @feedout_webcopy varchar(4000)
DECLARE @feedout_relatedprod varchar(100)
DECLARE @feedout_featprod varchar(100)
DECLARE @i_bookkey int
DECLARE @i_isbn int
DECLARE @i_cat int
DECLARE @feedout_count int
DECLARE @feedout_relatedisbn varchar(10)

BEGIN tran
 
SELECT @feed_system_date = getdate()

 
 /* delete old records */ 
 delete from  feedout_web_cat 
 
DECLARE feed_category INSENSITIVE CURSOR
  FOR
 select distinct b.bookkey
 	from book b,bookdetail bd
 		 where b.bookkey=bd.bookkey 
			and bisacstatuscode <> 6 
  			and titletypecode=31 /*category*/
 FOR READ ONLY

OPEN feed_category
FETCH NEXT FROM feed_category 
INTO  
	@i_bookkey

select @i_isbn  = @@FETCH_STATUS

if @i_isbn <> 0 /*no isbn*/
begin	
	insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@feedout_cat,'3',@feed_system_date,'NO ROWS to PROCESS')
end

while (@i_isbn<>-1 )  /* sttus 1*/
begin
	IF (@i_isbn<>-2) /* status 2*/
	begin

		 if @i_bookkey > 0 
		   begin
/* clear fields for next record*/ 
  			select @feedout_count = 0
			select @feedout_cat = ''
			select @feedout_title_desc = ''
			select @feedout_webcopy = ''
			select @feedout_relatedprod = ''
			select @feedout_featprod = ''

/*cat in bookdetail.titleprefix */
   			select @feedout_count = count(*) 
			     from bookdetail
  				   where bookkey=@i_bookkey  
  			if @feedout_count > 0 
			  begin
   				select @feedout_cat=titleprefix
				    from bookdetail
     					where bookkey=@i_bookkey 
 			   end
			if datalength(@feedout_cat) = 0
			  begin
				 insert into feedhistory (numisbnsucceeded, 
     					numisbnfailed,batchnumber,processdate,messagetext) 
  				 values (0, @i_bookkey,1,@feed_system_date,'NO ROW titleprefix present on bookdetail TABLE- CAT EXPORT')
			  end

   				select @feedout_count = 0 
				 select @feedout_count = count(*) 
			     from book
  				   where bookkey=@i_bookkey  
  			if @feedout_count > 0 
			  begin
   				select @feedout_title_desc=title
				    from book
     					where bookkey=@i_bookkey 
 			   end

/* comment description datacode 3 and subcode 8*/
			select @feedout_count = 0
			select @feedout_count = count(*) 
			     from bookcommenthtml 
  				   where bookkey=@i_bookkey  
					and printingkey=1
					and commenttypecode=3 and commenttypesubcode=8
  			if @feedout_count > 0 
			  begin
    				 select @feedout_webcopy = commenttext 
					from bookcommenthtml
  				 	  where bookkey=@i_bookkey 
						and printingkey=1 
						and commenttypecode=3 and commenttypesubcode=8
				end
			  else
			    begin	
					select @feedout_count = count(*) 
					     from bookcomments 
		  				   where bookkey=@i_bookkey  
							and printingkey=1
							and commenttypecode=3 and commenttypesubcode=8
		  			if @feedout_count > 0 
					  begin
    						 select @feedout_webcopy = commenttext 
							from bookcomments 
  							   where bookkey=@i_bookkey 
								and printingkey=1 
								and commenttypecode=3 and commenttypesubcode=8
					end
			  end
/* associated titles */
			select @feedout_count = 0
			select @feedout_relatedisbn = ''

			select @feedout_count = count(*) 
			    from associatedtitles a, isbn i
  				where a.associatetitlebookkey =i.bookkey
					and associationtypecode=4
					and a.bookkey = @i_bookkey
			if @feedout_count > 0 
			  begin
  				DECLARE feed_associated INSENSITIVE CURSOR
 				 FOR
 					select isbn10
 						from associatedtitles a, isbn i
  							where a.associatetitlebookkey =i.bookkey
							      and associationtypecode=4
								and a.bookkey = @i_bookkey
 				FOR READ ONLY
		
				OPEN feed_associated
				FETCH NEXT FROM feed_associated
				    INTO  
					@feedout_relatedisbn

				select @i_cat  = @@FETCH_STATUS

				while (@i_cat<>-1 )  /* sttus 1*/
				  begin
					IF (@i_cat<>-2) /* status 2*/
					  begin
						if datalength(@feedout_relatedprod ) > 0
						  begin
							select @feedout_relatedprod = @feedout_relatedprod + ' ' + @feedout_relatedisbn
						   end
						else
						  begin
							select @feedout_relatedprod  =  @feedout_relatedisbn
						  end
					  end

					FETCH NEXT FROM feed_associated
					  INTO 
					     @feedout_relatedisbn

				 	select @i_cat= @@FETCH_STATUS
				end

		close feed_associated
		deallocate feed_associated
	end /*bookkey > 0*/

/* featured product*/

	INSERT INTO feedout_web_cat
		(category , description,webcopy,relatedprod,featureprod)
	VALUES (@feedout_cat  ,@feedout_title_desc ,@feedout_webcopy,
		@feedout_relatedprod ,@feedout_featprod)

	end
		FETCH NEXT FROM feed_category
		  INTO 	
			@i_bookkey

			select @i_isbn = @@FETCH_STATUS
end

END

close feed_category
deallocate feed_category

commit tran

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

