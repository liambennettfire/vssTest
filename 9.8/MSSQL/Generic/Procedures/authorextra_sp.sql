SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[authorextra_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[authorextra_sp]
GO


create proc dbo.authorextra_sp
@ware_authorkey  int, @ware_whichvalue int, @ware_authorstring  varchar(2000) OUTPUT
AS

DECLARE @ware_author varchar(100) 
DECLARE @i_authorstatus2 int 
DECLARE @ware_firstname varchar(75) 
DECLARE @ware_lastname varchar(75) 
DECLARE @ware_middlename varchar(75) 
DECLARE @ware_authorsuffix varchar(75) 
DECLARE @ware_title varchar(75) 
DECLARE @ware_authordegree varchar(75) 
DECLARE @ware_corporatecontributorind tinyint 
DECLARE @i_length int

DECLARE whauthorextra INSENSITIVE CURSOR
   FOR
	SELECT firstname,lastname, middlename,authorsuffix,title,corporatecontributorind,
		  authordegree
		    FROM  author 
		   	WHERE  authorkey=@ware_authorkey
	FOR READ ONLY

  if @ware_whichvalue= 1   /*accredation*/
    begin
	   OPEN  whauthorextra 
		FETCH NEXT FROM whauthorextra
		INTO @ware_firstname,@ware_lastname,@ware_middlename,@ware_authorsuffix,
			@ware_title,@ware_corporatecontributorind,@ware_authordegree 
		
	select @i_authorstatus2 = @@FETCH_STATUS

	if @i_authorstatus2 != 0 /** NOne **/
	  begin
		close whauthorextra
		deallocate whauthorextra
		RETURN
   	  end
	while (@i_authorstatus2<>-1 )
	   begin

		IF (@i_authorstatus2 <>-2)
		  begin
			if  @ware_title is null 
			  begin
				 select @ware_title = ''
			  end
			
			if datalength(rtrim(@ware_title)) > 0 
			  begin
				select @ware_authorstring = rtrim(@ware_title)
				close whauthorextra
				deallocate whauthorextra
				RETURN
			  end
			else
			  begin
				select @ware_authorstring = null
				close whauthorextra
				deallocate whauthorextra
				RETURN
			end 
		
		end

		FETCH NEXT FROM whauthorextra
			INTO @ware_firstname,@ware_lastname,@ware_middlename,@ware_authorsuffix,
				@ware_title,@ware_corporatecontributorind,@ware_authordegree 

		select @i_authorstatus2 = @@FETCH_STATUS
	end
   end

  if @ware_whichvalue= 2    /*suffix*/
	 begin
	   OPEN  whauthorextra 
		FETCH NEXT FROM whauthorextra
		INTO @ware_firstname,@ware_lastname,@ware_middlename,@ware_authorsuffix,
			@ware_title,@ware_corporatecontributorind,@ware_authordegree 

	select @i_authorstatus2 = @@FETCH_STATUS

	if @i_authorstatus2 != 0 /** NOne **/
	  begin
		close whauthorextra
		deallocate whauthorextra
		RETURN
   	  end
	while (@i_authorstatus2<>-1 )
	   begin
		IF (@i_authorstatus2 <>-2)
		  begin
			if  @ware_authorsuffix is null 
			  begin
				 select @ware_authorsuffix = ''
			  end
			
			if datalength(rtrim(@ware_authorsuffix)) > 0 
			  begin
				select @ware_authorstring = rtrim(@ware_authorsuffix) 
				close whauthorextra
				deallocate whauthorextra
				RETURN
			  end
			else
			  begin
				select @ware_authorstring = null
				close whauthorextra
				deallocate whauthorextra
				RETURN
			  end
		 end

	
		FETCH NEXT FROM whauthorextra
			INTO @ware_firstname,@ware_lastname,@ware_middlename,@ware_authorsuffix,
				@ware_title,@ware_corporatecontributorind,@ware_authordegree 
	select @i_authorstatus2 = @@FETCH_STATUS
	   end
   end

 if @ware_whichvalue= 3    /*degree*/
   begin
	   OPEN  whauthorextra 
	
		FETCH NEXT FROM whauthorextra
			INTO @ware_firstname,@ware_lastname,@ware_middlename,@ware_authorsuffix,
				@ware_title,@ware_corporatecontributorind,@ware_authordegree 

	select @i_authorstatus2 = @@FETCH_STATUS

	if @i_authorstatus2 != 0 /** NOne **/
	  begin
		close whauthorextra
		deallocate whauthorextra
		RETURN
   	  end
	while (@i_authorstatus2<>-1 )
	   begin

		IF (@i_authorstatus2 <>-2)
		  begin
			if  @ware_authordegree is null 
			  begin
				 select @ware_authordegree = ''
			  end
	
			if datalength(rtrim(@ware_authordegree)) > 0 
			  begin
				select @ware_authorstring = rtrim(@ware_authordegree)
				close whauthorextra
				deallocate whauthorextra
				RETURN
			  end
			else
			  begin
				select @ware_authorstring = null
				close whauthorextra
				deallocate whauthorextra

				RETURN
			  end
		  end

	
		FETCH NEXT FROM whauthorextra
			INTO @ware_firstname,@ware_lastname,@ware_middlename,@ware_authorsuffix,
				@ware_title,@ware_corporatecontributorind,@ware_authordegree 
		select @i_authorstatus2 = @@FETCH_STATUS
	   end
   end

 if @ware_whichvalue= 4    /*complete name*/
    begin
	   OPEN  whauthorextra 
	
		FETCH NEXT FROM whauthorextra
			INTO @ware_firstname,@ware_lastname,@ware_middlename,@ware_authorsuffix,
				@ware_title,@ware_corporatecontributorind,@ware_authordegree 

	select @i_authorstatus2 = @@FETCH_STATUS

	if @i_authorstatus2 != 0 /** NOne **/
	  begin
		close whauthorextra
		deallocate whauthorextra
		RETURN
   	  end
	while (@i_authorstatus2<>-1 )
	   begin

		IF (@i_authorstatus2 <>-2)
		  begin
			if @ware_firstname is null 
			  begin
				 select @ware_firstname = ''
			  end
			if  @ware_lastname is null 
			  begin
				 select @ware_lastname = ''
			  end
			if  @ware_middlename is null 
			  begin
				 select @ware_middlename = ''
			  end
			if  @ware_authorsuffix is null 
			  begin
				 select @ware_authorsuffix = ''
			  end
			if  @ware_title is null 
			  begin
				 select @ware_title = ''
			  end
			if  @ware_authordegree is null 
			  begin
				 select @ware_authordegree = ''
			  end
			if  @ware_corporatecontributorind is null 
			  begin
				 select @ware_corporatecontributorind = 0
			  end

		 	if @ware_corporatecontributorind  is null 
			  begin
				select @ware_corporatecontributorind = 0
			  end
		  	if @ware_corporatecontributorind = 1 
			  begin
				if datalength(rtrim(@ware_lastname)) > 0 
				  begin
					select @ware_authorstring = @ware_lastname	
				   end
	 		  end
			else
			  begin
				if datalength(rtrim(@ware_title)) > 0 
				  begin
					select @ware_author = rtrim(@ware_title)	
				  end
				 else
				  begin
					select @ware_author = ''
				  end
		
				if datalength(@ware_author) > 0 
				  begin
					select @ware_authorstring = @ware_author + ' '
				  end
				else
				  begin
					select @ware_authorstring = ''
			 	  end
				if datalength(rtrim(@ware_firstname)) > 0 
				  begin
					if datalength(@ware_authorstring) > 0 
					  begin
						select @ware_authorstring = @ware_authorstring + rtrim(@ware_firstname) + ' '
					  end
					else
					  begin
						select @ware_authorstring = rtrim(@ware_firstname) + ' '	
					  end
				  end
				if datalength(rtrim(@ware_middlename)) > 0 
				  begin
					if datalength(@ware_authorstring) > 0 
					  begin
						select @ware_authorstring = @ware_authorstring + rtrim(@ware_middlename) + ' '
					  end
					else
					  begin
						select @ware_authorstring = rtrim(@ware_middlename) + ' '
					  end
				  end
				if datalength(rtrim(@ware_lastname)) > 0 
				  begin
					if datalength(@ware_authorstring) > 0 
					  begin
						select @ware_authorstring = @ware_authorstring + rtrim(@ware_lastname) + ', '
					  end
				else
				  begin
					select @ware_authorstring = rtrim(@ware_lastname) +  ', '	
				  end
			  end
			if datalength(rtrim(@ware_authorsuffix)) > 0 
			  begin
				if datalength(@ware_authorstring) > 0 
				  begin
					select @ware_authorstring = @ware_authorstring + rtrim(@ware_authorsuffix) + ', '
				  end
			else
			  begin
				select @ware_authorstring = rtrim(@ware_authorsuffix)  + ', '
			   end
		   end 
		if datalength(rtrim(@ware_authordegree)) > 0 
		  begin
			if datalength(@ware_authorstring) > 0 
			  begin
				select @ware_authorstring = @ware_authorstring +  rtrim(@ware_authordegree)
			  end
			else
			  begin
				select @ware_authorstring = rtrim(@ware_authordegree)
			  end
		  end
	end
   end

	
		FETCH NEXT FROM whauthorextra
			INTO @ware_firstname,@ware_lastname,@ware_middlename,@ware_authorsuffix,
				@ware_title,@ware_corporatecontributorind,@ware_authordegree 

	
		select @i_authorstatus2 = @@FETCH_STATUS
	   end

	select @ware_authorstring = rtrim(@ware_authorstring)
	select @i_length = datalength(@ware_authorstring)
	if substring(@ware_authorstring,@i_length,1) = ',' 
	 begin
		select @i_length = @i_length-1
		select @ware_authorstring = substring(@ware_authorstring,1,@i_length)
	  end
   end

close whauthorextra
deallocate whauthorextra

RETURN

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

