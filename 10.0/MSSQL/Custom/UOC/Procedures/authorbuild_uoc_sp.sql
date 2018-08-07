PRINT 'STORED PROCEDURE : dbo.authorbuild_uoc_sp'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.authorbuild_uoc_sp') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.authorbuild_uoc_sp
end

GO

create proc dbo.authorbuild_uoc_sp
@i_authbookkey  int, @whichvalue int, @c_authorstring  varchar(1000) OUTPUT
AS

DECLARE @i_count int
DECLARE @c_author varchar(200) 

DECLARE @c_author_type varchar(1000) 

DECLARE @c_authordesc varchar(300) 
DECLARE @i_authorstatus2 int 
DECLARE @c_firstname varchar(75) 
DECLARE @c_lastname varchar(75) 
DECLARE @c_middlename varchar(75) 
DECLARE @i_authortypecode int 

DECLARE @i_count_authors int 
DECLARE @i_authors_incr int 
DECLARE @i_length int 
DECLARE @i_sortorder int 
DECLARE @c_last_type  varchar (1000)
DECLARE @i_ck_for_by_count int
DECLARE @i_authoredit_ck int

/* 1 = author only; 2 = editor only ;  3= author and other contributor; 4 = primary 5= primary with authordesc */
/* CRM 01936: 9-30-04 expand authortype variable so no truncating and add syntax 4 and 5, check if 'by' already part of description*/
/*CRM 2232:  12-15-04 change middlename firstname to firstname middlename  originally middlename not filled in*/

if @whichvalue = 1
  begin
	DECLARE c_authorbuild INSENSITIVE CURSOR
	   FOR
		SELECT firstname,lastname, middlename,authortypecode, sortorder
		    FROM  bookauthor b, author a
		   	WHERE  b.authorkey = a.authorkey
				and b.bookkey = @i_authbookkey  and authortypecode =12
					order by  sortorder,authortypecode		
	   FOR READ ONLY

  
	   OPEN  c_authorbuild 
		FETCH NEXT FROM c_authorbuild
		INTO @c_firstname,@c_lastname,@c_middlename,@i_authortypecode,
			@i_sortorder

		select @i_authorstatus2 = @@FETCH_STATUS

		if @i_authorstatus2 != 0 /** NOne **/
		  begin

			select @c_authorstring = ''
			close c_authorbuild
			deallocate c_authorbuild
			RETURN
   	 	 end
	
		select @i_authors_incr = 1
		select @i_count_authors = 0

		while (@i_authorstatus2<>-1 )
	 	  begin

			IF (@i_authorstatus2 <>-2)
			  begin

				select @i_count_authors = count(*) 
					FROM  bookauthor b, author a
		   				WHERE  b.authorkey = a.authorkey and b.bookkey = @i_authbookkey
							and b.authortypecode = @i_authortypecode

				if  @i_authors_incr = 0
				  begin
					select @i_authors_incr = 1
			  	  end

				select @c_authordesc = datadesc from gentables where tableid= 134
					and datacode = @i_authortypecode
	
				if @c_middlename is null 
  				 begin
					select @c_middlename = ''
  			 	 end
		
				if @c_firstname is null 
  			 	 begin
					select @c_firstname = ''
  			 	 end
			
				if @i_authors_incr = 1 
			  	  begin

					if datalength(@c_firstname) > 0 and datalength(@c_middlename) > 0
  			 	 	 begin
				  		select @c_author = @c_lastname + ', ' + @c_firstname + ' ' + @c_middlename

  			  	 	 end
					else if datalength(@c_firstname) > 0 
  			 		  begin
					 	 select @c_author = @c_lastname + ', ' + @c_firstname
  					  end	
					else 
  			 		  begin
					 	 select @c_author = @c_lastname 
  					  end	
			 	  end
				else
			  	  begin
					if datalength(@c_firstname) > 0 and datalength(@c_middlename) > 0
  			 	 	   begin
				 	 	select @c_author = @c_firstname + ' ' + @c_middlename + ' ' + @c_lastname
  			  	 	 end
					else if datalength(@c_firstname) > 0 
  			 	 	 begin
						select @c_author = @c_firstname + ' ' + @c_lastname
  					  end
					else 
  			 		  begin
					 	 select @c_author = @c_lastname 
  					  end	
			  	 end

				if datalength(@c_author) > 0 
		 	 	 begin
					 if  @i_authors_incr = 1
					   begin  	
						select @c_authorstring  = @c_author
				
					   end

					if  @i_authors_incr > 1 and (@i_authors_incr = @i_count_authors)
					  begin
						if @i_authors_incr = 2 
						  begin
							select @c_authorstring  = @c_authorstring   + ' and ' + @c_author
						  end
						else
						  begin
							select @c_authorstring  = @c_authorstring   + ', and ' + @c_author
						  end	
						select @i_authors_incr = 0					
				  	 end
					else if @i_authors_incr > 1 and (@i_count_authors<> @i_authors_incr)
					  begin
				  	 	select @c_authorstring  = @c_authorstring + ', ' + @c_author
					  end
				 end


				select @i_authors_incr =  @i_authors_incr +  1

			end

			FETCH NEXT FROM c_authorbuild
				INTO @c_firstname,@c_lastname,@c_middlename,@i_authortypecode,
				@i_sortorder

			select @i_authorstatus2 = @@FETCH_STATUS
		end

	if @c_authorstring is null 
 	 begin
		select @c_authorstring = ''
  	end

	close c_authorbuild
	deallocate c_authorbuild

	RETURN
 end

/*editors*/

if @whichvalue = 2
  begin
	DECLARE c_authorbuild INSENSITIVE CURSOR
	   FOR
		SELECT firstname,lastname, middlename,authortypecode, sortorder
		    FROM  bookauthor b, author a
		   	WHERE  b.authorkey = a.authorkey
				and b.bookkey = @i_authbookkey  and authortypecode =16
					order by  sortorder,authortypecode		
	   FOR READ ONLY

  
	   OPEN  c_authorbuild 
		FETCH NEXT FROM c_authorbuild
		INTO @c_firstname,@c_lastname,@c_middlename,@i_authortypecode,
			@i_sortorder

		select @i_authorstatus2 = @@FETCH_STATUS

		if @i_authorstatus2 != 0 /** NOne **/
		  begin

			select @c_authorstring = ''
			close c_authorbuild
			deallocate c_authorbuild
			RETURN
   	 	 end

		select @i_authors_incr = 1

		select @i_count_authors = 0

		select @i_count_authors = count(*) 
			 FROM  bookauthor b, author a
		   		WHERE  b.authorkey = a.authorkey and b.bookkey = @i_authbookkey
					and b.authortypecode = @i_authortypecode

		while (@i_authorstatus2<>-1 )
	 	  begin

			IF (@i_authorstatus2 <>-2)
			  begin

				if  @i_authors_incr = 0
				  begin
					select @i_authors_incr = 1
			  	  end

				select @c_authordesc = datadesc from gentables where tableid= 134
					and datacode = @i_authortypecode
	
				if @c_middlename is null 
  				 begin
					select @c_middlename = ''
  			 	 end
		
				if @c_firstname is null 
  			 	 begin
					select @c_firstname = ''
  			 	 end
			
				if @i_authors_incr = 1 
			  	  begin

					if datalength(@c_firstname) > 0 and datalength(@c_middlename) > 0
  			 	 	 begin
				  		select @c_author =  @c_lastname + ', ' + @c_firstname + ' ' + @c_middlename

  			  	 	 end
					else if datalength(@c_firstname) > 0 
  			 		  begin
					 	 select @c_author = @c_lastname + ', ' + @c_firstname
  					  end	
					else 
  			 		  begin
					 	 select @c_author = @c_lastname 
  					  end	
			 	  end
				else
			  	  begin
					if datalength(@c_firstname) > 0 and datalength(@c_middlename) > 0
  			 	 	   begin
				 	 	select @c_author = @c_firstname + ' ' + @c_middlename + ' ' + @c_lastname
  			  	 	   end
					else if datalength(@c_firstname) > 0 
  			 	 	 begin
						select @c_author = @c_firstname + ' ' + @c_lastname
  					  end
					else 
  			 		  begin
					 	 select @c_author = @c_lastname 
  					  end	
			  	 end

				if datalength(@c_author) > 0 and datalength(@c_authordesc) >0 
				 begin
					if @i_authors_incr> 1 and @i_authors_incr = @i_count_authors
					   begin
						select  @c_author_type =  @c_author +', ' + lower(@c_authordesc) + 's'
				  	   end
					else if @i_count_authors = 1
				 	  begin
						select  @c_author_type =  @c_author +', ' + lower(@c_authordesc) 
				  	  end
					else if (@i_authors_incr> 1 and @i_authors_incr <> @i_count_authors) or (@i_authors_incr = 1 and @i_count_authors > 1)
					  begin
						select  @c_author_type =  @c_author
				  	   end
			 	 end

				if datalength(@c_author) > 0 
		 	 	 begin
					 if  @i_authors_incr = 1
					   begin  	
						select @c_authorstring  = @c_author_type
				
					   end

					else if  @i_authors_incr> 1 and (@i_authors_incr = @i_count_authors)
					  begin
						if @i_authors_incr = 2 
					  	  begin
							select @c_authorstring  = @c_authorstring   + ' and ' + @c_author_type
						  end
						else
						  begin
							select @c_authorstring  = @c_authorstring   + ', and ' + @c_author_type
						  end			
						select @i_authors_incr = 0
				  	 end
					else if @i_authors_incr > 1 and (@i_authors_incr <> @i_count_authors)
					  begin
				  	 	select @c_authorstring  = @c_authorstring + ', ' + @c_author_type
					  end
				 end

				select @i_authors_incr =  @i_authors_incr +  1

			end


			FETCH NEXT FROM c_authorbuild
				INTO @c_firstname,@c_lastname,@c_middlename,@i_authortypecode,
				@i_sortorder

			select @i_authorstatus2 = @@FETCH_STATUS
		end

		if @c_authorstring is null 
 		 begin
			select @c_authorstring = ''
  		end

	close c_authorbuild
	deallocate c_authorbuild

	RETURN
 end

/*author and contributors*/
if @whichvalue = 3
  begin
	DECLARE c_authorbuild INSENSITIVE CURSOR
	   FOR
		SELECT firstname,lastname, middlename,authortypecode, sortorder
		    FROM  bookauthor b, author a
		   	WHERE  b.authorkey = a.authorkey
				and b.bookkey = @i_authbookkey and authortypecode <> 12
					order by authortypecode,sortorder		
	   FOR READ ONLY

  
	   OPEN  c_authorbuild 
		FETCH NEXT FROM c_authorbuild
		INTO @c_firstname,@c_lastname,@c_middlename,@i_authortypecode,
			@i_sortorder

		select @i_authorstatus2 = @@FETCH_STATUS

		if @i_authorstatus2 != 0 /** NOne **/
		  begin

			select @c_authorstring = ''
			close c_authorbuild
			deallocate c_authorbuild
			RETURN
   	 	 end

		select @i_authors_incr = 1

		select @i_count_authors = 0

		select @c_authorstring =''
		select @i_count = 0

		select @i_count = count(*) 
			 FROM  bookauthor b, author a
				WHERE  b.authorkey = a.authorkey and b.bookkey = @i_authbookkey
					and b.authortypecode = 12 /*check if no authors*/


		while (@i_authorstatus2<>-1 )
	 	  begin

			IF (@i_authorstatus2 <>-2)
			  begin
				select @i_count_authors = count(*) 
				 FROM  bookauthor b, author a
					WHERE  b.authorkey = a.authorkey and b.bookkey = @i_authbookkey
						and b.authortypecode = @i_authortypecode

				if  @i_authors_incr = 0
				  begin
					select @i_authors_incr = 1
			  	  end

				select @c_authordesc = datadesc from gentables where tableid= 134
					and datacode = @i_authortypecode
	
				if @c_middlename is null 
  				 begin
					select @c_middlename = ''
  			 	 end
		
				if @c_firstname is null 
  			 	 begin
					select @c_firstname = ''
  			 	 end

				/*if no author then use first contrib as author; and do not put any editor in list*/

				
				if @i_count = 0  
				  begin  /* push back increment because not using this name*/
					select @i_authors_incr =  @i_authors_incr -  1
					select @i_authoredit_ck = @i_count
					select @i_count  = 1  /*next time around will not go in here*/
				  end
				else
				  begin
					if datalength(@c_firstname) > 0 and datalength(@c_middlename) > 0
  				 	  begin
					  	select @c_author =  @c_firstname + ' ' + @c_middlename + ' ' + @c_lastname

	  			  	 end
					else if datalength(@c_firstname) > 0 
  			 		 begin
						  select @c_author = @c_firstname + ' '  + @c_lastname
  				 	end
					else 
  			 		  begin
					 	 select @c_author = @c_lastname 
  					  end		
				  end
				
				if @i_authortypecode = 16  and @i_authoredit_ck = 0  /*no author rows  so do not put any editor in contributor list*/
				  begin
					select @c_author = ''
					select @i_authors_incr =  @i_authors_incr -  1
				  end


				if datalength(@c_author) > 0 and datalength(@c_authordesc) >0 
				 begin
					select @i_length = 0
					select @i_length = datalength(@c_authordesc)

					if upper(substring(@c_authordesc, (@i_length-1),2)) =  'OR'
					  begin
						select @c_authordesc = substring(@c_authordesc, 1, (datalength(@c_authordesc)-2)) + 'ed by '
					   end
					else
					  begin
						select @i_ck_for_by_count = 0
						select @i_ck_for_by_count = charindex(' by',@c_authordesc)
						if @i_ck_for_by_count = 0 
						  begin
							select @c_authordesc = @c_authordesc + ' by '
						  end
						else
						  begin
							select @c_authordesc = @c_authordesc + ' '
						  end
					  end
					
					if @i_authors_incr = 1  
				 	  begin
						select  @c_author_type =  @c_authordesc + @c_author
				  	  end
					else if @c_last_type <> @c_authordesc
					  begin
						select  @c_author_type =  @c_authordesc + @c_author
				  	  end
					else 
					  begin
						select @c_author_type = @c_author
					  end
			 	 end


				if datalength(@c_author) > 0 
		 	 	 begin
					 if  @i_authors_incr = 1 and datalength(@c_authorstring)= 0
					   begin  	
						select @c_authorstring  = @c_author_type
				
					   end
					else if  @c_last_type <> @c_authordesc and datalength(@c_authorstring) > 0
					  begin
						select @c_authorstring  = @c_authorstring + '. ' + @c_author_type
						select @i_authors_incr = 0
					  end

					else if  @i_authors_incr> 1 and (@i_count_authors = @i_authors_incr)
					  begin
						select @c_authorstring  = @c_authorstring   + ' and ' + @c_author_type
						select @i_authors_incr = 0
				  	 end
					else if @i_authors_incr > 1 and (@i_authors_incr <> @i_count_authors) 
					  begin
				  	 	select @c_authorstring  = @c_authorstring + ', ' + @c_author_type
					  end
				 end



				select @c_last_type = @c_authordesc
				select @i_authors_incr =  @i_authors_incr +  1


			end

			FETCH NEXT FROM c_authorbuild
				INTO @c_firstname,@c_lastname,@c_middlename,@i_authortypecode,
				@i_sortorder

			select @i_authorstatus2 = @@FETCH_STATUS
		end

		if @c_authorstring is null 
 		 begin
			select @c_authorstring = ''
  		end
		
	close c_authorbuild
	deallocate c_authorbuild

	RETURN
 end

if @whichvalue = 4 /*web title use lowest sortorder which should be primary name only*/
  begin
	
	select @i_sortorder = min(sortorder) from bookauthor b, author a
		   	WHERE  b.authorkey = a.authorkey
				and b.bookkey = @i_authbookkey  

	if @i_sortorder > 0 
	  begin
		SELECT @c_firstname = firstname,@c_lastname = lastname, @c_middlename = middlename
		    FROM  bookauthor b, author a
		   	WHERE  b.authorkey = a.authorkey
				and b.bookkey = @i_authbookkey  and sortorder =@i_sortorder
			

		if datalength(@c_firstname) > 0 and datalength(@c_middlename) > 0
  		 begin
			select @c_authorstring =  @c_lastname + ', ' + @c_firstname + ' ' + @c_middlename

  		 end
		else if datalength(@c_firstname) > 0 
  		 begin
			 select @c_authorstring = @c_lastname + ', ' + @c_firstname
  		 end	
		else 
  		  begin
			 select @c_authorstring = @c_lastname 
  		  end	


		if @c_authorstring is null 
 	 	  begin
		 	select  @c_authorstring = ''
  		end
	end
end
if @whichvalue = 5 /*web title use lowest sortorder which should be primary name and description IF NOT AUTHOR*/
  begin
	
	select @i_sortorder = min(sortorder) from bookauthor b, author a
		   	WHERE  b.authorkey = a.authorkey
				and b.bookkey = @i_authbookkey  

	if @i_sortorder > 0 
	  begin
		SELECT @c_firstname = firstname,@c_lastname = lastname, @c_middlename = middlename, 
			 @i_authortypecode = authortypecode
		    FROM  bookauthor b, author a
		   	WHERE  b.authorkey = a.authorkey
				and b.bookkey = @i_authbookkey  and sortorder =@i_sortorder
			

		select @c_authordesc = datadesc from gentables where tableid= 134
					and datacode = @i_authortypecode 

		if datalength(@c_firstname) > 0 and datalength(@c_middlename) > 0
  		 begin
			select @c_authorstring =  @c_lastname + ', ' + @c_firstname + ' ' + @c_middlename

  		 end
		else if datalength(@c_firstname) > 0 
  		 begin
			 select @c_authorstring = @c_lastname + ', ' + @c_firstname
  		 end	
		else 
  		  begin
			 select @c_authorstring = @c_lastname 
  		  end	

		if @i_authortypecode =12 
		  begin
			select @c_authordesc = ''
		  end

		if @c_authorstring is null 
 	 	  begin
		 	select  @c_authorstring = ''
  		 end
		else
		  begin
			if len(@c_authordesc)>0
			  begin
				select @c_authorstring = @c_authorstring + ', ' + @c_authordesc 
			  end
		  end
	end
end
RETURN

GO