if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isbn_13]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isbn_13]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE  proc dbo.isbn_13
@feedin_isbn varchar(10), @feed_isbn varchar(13) OUTPUT 
AS 
 
DECLARE @isbn_count int
DECLARE @isbn_temp1  varchar(9)
DECLARE @isbn_increment  int
DECLARE @isbn_prefix  varchar(9)
DECLARE @isbn_short  varchar(8) 
DECLARE @isbn_ckdg  char(1)
DECLARE @isbn_body  varchar(8)
DECLARE @feed_system_date datetime 
 
SELECT @feed_system_date= getdate()
 
 if datalength(@feedin_isbn ) < 10 
   begin
	insert into feederror 
	(isbn,batchnumber,processdate,errordesc) 
	 values (@feedin_isbn ,'3',@feed_system_date,('ISBN CONTAINS less than 10 CHARACTERS' + ' ' + @feedin_isbn))
	select @feed_isbn = 'NO ISBN'
   end
 else
  begin
 
 	select @isbn_temp1 = convert(char,substring(@feedin_isbn ,1,9))
 	select @isbn_increment = 1
 
 	WHILE @isbn_increment < 10
  	begin
 		select @isbn_count = ASCII(substring(@isbn_temp1,@isbn_increment,1))
 
 		if @isbn_count < 48 or @isbn_count > 57 
		begin  
	 		insert into feederror 
			(isbn,batchnumber,processdate,errordesc) 
			 values (@feedin_isbn ,'3',@feed_system_date,('ISBN CONTAINS LETTER IN POSITION  OTHER THAN CHECK DIGIT' + ' ' + @feed_isbn))
 
  			select @feed_isbn = 'NO ISBN'
			select @isbn_increment = 11
		 end 
 		select @isbn_increment = @isbn_increment + 1
  	END
 	if @feed_isbn <> 'NO ISBN' or @feed_isbn is null
 	  begin
 		select @isbn_count = 0
 
 		select @isbn_count = ASCII(substring(@feedin_isbn ,10,1))
 
 		select @isbn_ckdg = convert(char,substring(@feedin_isbn ,10,1))
 
		 if @isbn_count < 48 or @isbn_count > 57 
  		   begin  /* not a number*/ 
  		 	if @isbn_count <> 88 
    		  	 begin 
  				insert into feederror 
				(isbn,batchnumber,processdate,errordesc) 
				  values (@feedin_isbn ,'3',@feed_system_date,('INVALID LAST DIGIT IN ISBN' + ' ' + @feed_isbn))
   
  				select @feed_isbn = 'NO ISBN'
		        end
		 end
	end
	if @feed_isbn <> 'NO ISBN' or @feed_isbn is null
 	  begin
 		select @isbn_count = 0
		 select @isbn_increment = 1
 
 		WHILE @isbn_increment < 11
 		 begin
 			select @isbn_count = 0
			 select @isbn_count = count (*)  
  			 from gentables 
   				 where tableid = 138 
    					 and replace(datadesc,'-','')  = (substring(@feedin_isbn ,1,@isbn_increment)) 

  			if @isbn_increment > 10 
  			 begin
  	 			select @feed_isbn = 'NO ISBN' 
				  insert into feederror 
					(isbn,batchnumber,processdate,errordesc) 
	  			values (@feedin_isbn ,'3',@feed_system_date,('UNABLE TO FIND A MATCHING PREFIX FOR THIS ISBN' + ' ' + @feed_isbn))
   			end  
  			if   @isbn_count = 1  
  			 begin 
				if @isbn_increment = 1 
	 			  begin
    					 select @isbn_prefix = datadesc, @isbn_increment = len(replace(datadesc,'-',''))   
		    			    from gentables 
			        		where tableid =138 
			          		   and replace(datadesc,'-','') like (substring(@feedin_isbn,1,@isbn_increment))
 	  			end 
	 		      else
	  		 	 begin
 					select @isbn_prefix = datadesc   
			       		   from gentables 
				       		 where tableid =138 
			          		  and replace(datadesc,'-','') = (substring(@feedin_isbn,1,@isbn_increment))
			 	end
 
      				select @isbn_body =  convert(varchar, substring(@feedin_isbn ,(@isbn_increment + 1),(9 - @isbn_increment))) 
      				select @feed_isbn =  rtrim(@isbn_prefix) +  '-' +  rtrim(convert(varchar (10),@isbn_body))  + '-' +   convert(varchar(10),@isbn_ckdg)
  			end 
  			select @isbn_increment = @isbn_increment + 1 
 		END
	end
  	IF datalength(@FEED_ISBN) = 0 
  	  begin
   		select @feed_isbn = 'NO ISBN'
 	END
  end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO