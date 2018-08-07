PRINT 'STORED procedure: dbo.titlehistory_insert'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.titlehistory_insert') and (type = 'P' or type = 'RF'))
 drop proc dbo.titlehistory_insert
GO

CREATE proc dbo.titlehistory_insert
  @columnkey  int,
  @bookkey int,
  @printingkey int,
  @otherinfo varchar(20),
  @newvalue varchar(255),
  @newvalueisready tinyint
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

/* 1-5-07 - KW - Fixes for case 4479 */
/* 1-11-05 CRM 2289  test edistatuscode before changing to send */
/* 2-19-04 change parameter from columnname,tablename to columnkey */

DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime
DECLARE @c_tablename varchar(100)
DECLARE @c_columnname varchar(100)
DECLARE @currentvalue varchar(100)
DECLARE @currentvalue_int  int
DECLARE @currentvalue_date  datetime
DECLARE @currentvalue_numeric numeric
DECLARE @feedin_datatype varchar(1)
DECLARE @feedin_fielddesc varchar(40)
DECLARE @feedin_count int
DECLARE @feedin_count2 int
DECLARE @feedin_count3 int
DECLARE @stringvalue	varchar(255)
DECLARE @lv_edipartnerkey int
DECLARE @i_pricecode2 int
DECLARE @i_currencycode2 int
DECLARE @i_count int
DECLARE @lv_datetypecode int
DECLARE @lv_table_to_upd varchar(5)
DECLARE @nextkey int
DECLARE @i_gen1ind int


SET @feed_system_date = getdate()

select @feedin_count = count(*)  
from titlehistorycolumns 
where  columnkey = @columnkey

if @feedin_count > 0 
  begin
    select @feedin_datatype = datatype, 
      @feedin_fielddesc = columndescription,
      @c_tablename = upper(tablename),
      @c_columnname = upper(columnname)  
    from titlehistorycolumns 
    where  columnkey = @columnkey 

    if @c_tablename ='BOOKDATES'  
      begin
        SET @lv_table_to_upd = 'D'
        select @feedin_fielddesc = description from datetype where datetypecode = convert(int,@otherinfo)
      end      
    else if @c_tablename ='BOOKORGENTRY'
      select @feedin_fielddesc = @feedin_fielddesc + @otherinfo
    
  end
else
  begin
    insert into feederror
      (isbn,batchnumber,processdate,errordesc)
    values 
      (convert(char,10,@bookkey),'3',@feed_system_date,('There is no titlehistory column for this value ' + @c_tablename +' '+@c_columnname))
      
    RETURN 0
  end


IF @feedin_count > 0
BEGIN

  -- 1/5/07 - KW - This titlehistory_insert stored procedure is called from feed_in_title_info - a feed which 
  -- starts out with descriptions, and figures out corresponding datacodes needed for table inserts/updates.
  -- There was no reason to pass datacodes into this procedure (@otherinfo and @newvalue) to come up 
  -- with the SAME descriptions that we started with anyway.
  -- Added @newvalueisready parameter - when 1 is passed, this indicates that @newvalue is the actual 
  -- descriptive string ready for titlehistory insert.
  IF @newvalueisready = 1 --passed @newvalue is titlehistory-ready
   BEGIN
      -- Get old value from titlehistory for comparison
      IF @printingkey = 0
        SET @printingkey = 1
        
      DECLARE cur_oldtitlehistory CURSOR FOR
        SELECT currentstringvalue
        FROM titlehistory
        WHERE bookkey = @bookkey AND
          printingkey =  @printingkey AND
          columnkey = @columnkey AND
          fielddesc = @feedin_fielddesc
        ORDER BY bookkey, printingkey, columnkey, lastmaintdate DESC
      FOR READ ONLY

      OPEN cur_oldtitlehistory

      FETCH NEXT FROM cur_oldtitlehistory INTO @stringvalue

      IF (@@FETCH_STATUS <> 0)
        SET @stringvalue = '(Not Present)'
  
      CLOSE cur_oldtitlehistory
      DEALLOCATE cur_oldtitlehistory
   
   END
  ELSE  --@newvalueisready = 0 (OLD code - datacodes are passed, so must come up with descriptions)
   BEGIN
    
		if @feedin_datatype = 'i'
		  begin
 			if @c_tablename ='BOOK' and @c_columnname = 'TITLETYPECODE' 
		          begin
				select @currentvalue_int = titletypecode
				from BOOK
				  where bookkey = @bookkey

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = convert(varchar,@currentvalue_int)
			  end
		 	 end
			if @c_tablename ='BOOK' and @c_columnname = 'TERRITORIESCODE' 
		          begin
				select @currentvalue_int = territoriescode
				from BOOK
				  where bookkey = @bookkey

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = convert(varchar,@currentvalue_int)
			  end
		 	 end
			if @c_tablename ='BOOKDETAIL' and @c_columnname = 'EDITIONCODE' 
		   	  begin
				select @currentvalue_int = editioncode
				from BOOKDETAIL
				  where bookkey = @bookkey

				if @currentvalue_int is null
				  begin
						select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
				  end
				else
			 	 begin
					select @stringvalue = convert(varchar,@currentvalue_int)
			 	 end
		   	end
			if @c_tablename ='BOOKDETAIL' and @c_columnname = 'VOLUMENUMBER' 
		   	  begin
				select @currentvalue_int = volumenumber
				from BOOKDETAIL
				  where bookkey = @bookkey

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = convert(varchar,@currentvalue_int)
			  end
		        end
 		 	 if @c_tablename ='BOOKDETAIL' and @c_columnname = 'SERIESCODE' 
		   	   begin
				select @currentvalue_int = seriescode
				from BOOKDETAIL
				  where bookkey = @bookkey

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = convert(varchar,@currentvalue_int)
			  end
		       end
		      if @c_tablename ='PRINTING' and @c_columnname = 'PUBMONTHCODE'
		       begin
			
			select @feedin_count2 = 0

			select @feedin_count2 = count(*) 
				from PRINTING
				  where bookkey = @bookkey
					and printingkey = @printingkey
			if @feedin_count2 > 0 
			  begin
				select @currentvalue_int = pubmonthcode
				from PRINTING
				  where bookkey = @bookkey
					and printingkey = @printingkey
			  end
			  else
			  begin
			    select @currentvalue_int = null
			  end

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = convert(char,@currentvalue_int)
			  end
		       end
		     if @c_tablename ='PRINTING' and @c_columnname = 'TMMPAGECOUNT'  
		       begin
				select @currentvalue_int = tmmpagecount
				from PRINTING
				  where bookkey = @bookkey and printingkey = 1

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = @currentvalue_int
			  end
		     end

		end  /* int data*/
  
		if @feedin_datatype = 'a' OR @feedin_datatype = 'd'
		   begin

	 	   if @c_tablename ='BOOKDETAIL' and @c_columnname = 'BISACSTATUSCODE' /*BISAC*/
		     begin
				select @currentvalue_int = bisacstatuscode
				from BOOKDETAIL
				  where bookkey = @bookkey

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = convert(varchar,@currentvalue_int)
			  end
			end
		   if @c_tablename ='BOOKDETAIL' and @c_columnname = 'MEDIATYPESUBCODE' 
		     begin
				select @feedin_count = 0
				select @currentvalue_int = mediatypesubcode, @feedin_count = mediatypecode
				from BOOKDETAIL
				  where bookkey = @bookkey

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = convert(varchar,@currentvalue_int)
			  end
			end
 		   if @c_tablename ='ISBN' and @c_columnname = 'ISBN' 
		     begin
				select @currentvalue = isbn
				from ISBN
				  where bookkey = @bookkey

			if @currentvalue is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue = ''
			  end
			else
			  begin
				select @stringvalue = @currentvalue
			  end
			end

 		  if @c_tablename ='BOOKORGENTRY' and @c_columnname = 'ORGENTRYKEY'
		     begin
				select @currentvalue_int = orgentrykey
				from BOOKORGENTRY
				  where bookkey = @bookkey and orglevelkey = convert(int,@otherinfo)

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = convert(varchar,@currentvalue_int)
			  end
		end
 		if @c_tablename ='BOOKDATES' 
			  begin
				select @lv_datetypecode = convert (int,@otherinfo)
 				select @feedin_count2 = 0				 

				select @feedin_count2 = count(*)
				   from BOOKDATES
				  	where datetypecode = @lv_datetypecode
						and printingkey= @printingkey
						and bookkey = @bookkey
			   	if @feedin_count2 > 0 
				  begin

				 	 select @currentvalue_date = activedate 
				  	 from BOOKDATES
				  		where datetypecode= @lv_datetypecode
							and printingkey= @printingkey
							and bookkey = @bookkey
				  end
			  	else
				  begin
					select @currentvalue_date = null
			 	 end

			    	 if @currentvalue_date is null 
				   begin
				 	select  @stringvalue = '(Not Present)'
					select  @currentvalue_date = ''
				  end
			        else
				  begin
					select @stringvalue = convert(varchar,@currentvalue_date)
			          end
     		end
		if @c_tablename ='BOOK' and @c_columnname = 'TITLE' 
		     begin
				select @currentvalue = title
				from BOOK
				  where bookkey = @bookkey

			if @currentvalue is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue = ''
			  end
			else
			  begin
				select @stringvalue = @currentvalue
			  end
		 end
		if @c_tablename ='BOOK' and @c_columnname = 'SUBTITLE' 
		     begin
				select @currentvalue = subtitle
				from BOOK
				  where bookkey = @bookkey

			if @currentvalue is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue = ''
			  end
			else
			  begin
				select @stringvalue = @currentvalue
			  end
		 end
		if @c_tablename ='BOOK' and @c_columnname = 'SHORTTITLE' 
		     begin
				select @currentvalue = shorttitle
				from BOOK
				  where bookkey = @bookkey

			if @currentvalue is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue = ''
			  end
			else
			  begin
				select @stringvalue = @currentvalue
			  end
		 end
		if @c_tablename ='BOOKDETAIL' and @c_columnname = 'TITLEPREFIX' 
		     begin
				select @currentvalue = titleprefix
				from BOOKDETAIL
				  where bookkey = @bookkey

			if @currentvalue is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue = ''
			  end
			else
			  begin
				select @stringvalue = @currentvalue
			  end
		 end
		if @c_tablename ='BOOKPRICE' 
			   begin
			/*get default currency and pricetypecode*/
				select @i_count = 0
				select @i_count = count(*) from filterpricetype
					where filterkey = 5 /*currency and price types*/

				if @i_count > 0 
	 			  begin
					select @i_pricecode2= pricetypecode, @i_currencycode2 = currencytypecode
						 from filterpricetype
						where filterkey = 5 /*currency and price types*/
	 			end
				
				select @feedin_count2 = 0
 
				select @feedin_count2 = count(*) 
					from BOOKPRICE
				  		where pricetypecode= @i_pricecode2 and currencytypecode = convert(int, @otherinfo)
							and bookkey = @bookkey
					if @feedin_count2 > 0 
				 	 begin
 						select @currentvalue_numeric = rtrim(finalprice)
						   from BOOKPRICE
					 	 	where pricetypecode= @i_pricecode2 and  currencytypecode =convert(int, @otherinfo)
							and bookkey = @bookkey
				 	 end 	
				  	else
				  	begin
						select @currentvalue_numeric = null
			  		  end
					if @currentvalue_numeric is null
			       		  begin
				  		select @stringvalue = '(Not Present)'
				 		 select @currentvalue_numeric = 0
			     		 end
			  		  else
			    	 	 begin
						select @stringvalue = convert(varchar,@currentvalue_numeric)
			     		 end  
			end
			if @c_tablename ='PRINTING' and @c_columnname = 'SEASONKEY'  
		     	  begin
				select @currentvalue_int = seasonkey
				from PRINTING
				  where bookkey = @bookkey and printingkey = 1

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = @currentvalue_int
			  end
		   end
		if @c_tablename ='PRINTING' and @c_columnname = 'PAGECOUNT'  
		     begin
				select @currentvalue_int = pagecount
				from PRINTING
				  where bookkey = @bookkey and printingkey = 1

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = @currentvalue_int
			  end
		   end
		if @c_tablename ='PRINTING' and @c_columnname = 'TMMACTUALTRIMWIDTH'  
		     begin
				select @currentvalue =  tmmactualtrimwidth
				from PRINTING
				  where bookkey = @bookkey and printingkey = 1

			if @currentvalue is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue = ''
			  end
			else
			  begin
				select @stringvalue = @currentvalue
			  end
		   end
		if @c_tablename ='PRINTING' and @c_columnname = 'TMMACTUALTRIMLENGTH'  
		     begin
				select @currentvalue =  tmmactualtrimlength
				from PRINTING
				  where bookkey = @bookkey and printingkey = 1

			if @currentvalue is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue = ''
			  end
			else
			  begin
				select @stringvalue = @currentvalue
			  end
		   end
		if @c_tablename ='PRINTING' and @c_columnname = 'TRIMSIZEWIDTH'  
		     begin
				select @currentvalue =  trimsizewidth
				from PRINTING
				  where bookkey = @bookkey and printingkey = 1

			if @currentvalue is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue = ''
			  end
			else
			  begin
				select @stringvalue = @currentvalue
			  end
		   end
		if @c_tablename ='PRINTING' and @c_columnname = 'TRIMSIZELENGTH'  
		     begin
				select @currentvalue =  trimsizelength
				from PRINTING
				  where bookkey = @bookkey and printingkey = 1

			if @currentvalue is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue = ''
			  end
			else
			  begin
				select @stringvalue = @currentvalue
			  end
		   end
		if @c_tablename ='PRINTING' and @c_columnname = 'ACTUALINSERTILLUS'  
		     begin
				select @currentvalue =  actualinsertillus
				from PRINTING
				  where bookkey = @bookkey and printingkey = 1

			if @currentvalue is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue = ''
			  end
			else
			  begin
				select @stringvalue = @currentvalue
			  end
		   end
	 	end  /*	end alpha description*/
	

    IF RTRIM(@stringvalue) <> RTRIM(@newvalue)  /* compare old and new */
    BEGIN
    
	 	   if @c_tablename ='BOOKDETAIL' and @c_columnname = 'BISACSTATUSCODE' /* only gentable row that needs converting currently*/
			   begin
			      if @stringvalue <> '(Not Present)' 
				  begin
			    		   select @stringvalue = datadesc from gentables where tableid=314 and 
						    datacode = convert(int,rtrim(@stringvalue))
				  end
				select @newvalue = datadesc from gentables where tableid=314 and 
				    datacode = convert(int,rtrim(@newvalue))
			   end

			if @c_tablename ='BOOK' and @c_columnname = 'TITLETYPECODE' 
		         begin
				 if @stringvalue <> '(Not Present)' 
				  begin
			    		   select @stringvalue = datadesc from gentables where tableid=132 and 
						    datacode = convert(int,rtrim(@stringvalue))
				  end
					select @newvalue = datadesc from gentables where tableid=132 and 
				 	   datacode = convert(int,rtrim(@newvalue))
			   end
			if @c_tablename ='BOOK' and @c_columnname = 'TERRITORIESCODE' 
		         begin
				 if @stringvalue <> '(Not Present)' 
				  begin
			    		   select @stringvalue = datadesc from gentables where tableid=131 and 
						    datacode = convert(int,rtrim(@stringvalue))
				  end
					select @newvalue = datadesc from gentables where tableid=131 and 
				 	   datacode = convert(int,rtrim(@newvalue))
			   end
			if @c_tablename ='BOOKDETAIL' and @c_columnname = 'EDITIONCODE' 
		         begin
				 if @stringvalue <> '(Not Present)' 
				  begin
			    		   select @stringvalue = datadesc from gentables where tableid=200 and 
						    datacode = convert(int,rtrim(@stringvalue))
				  end
					select @newvalue = datadesc from gentables where tableid=200 and 
				 	   datacode = convert(int,rtrim(@newvalue))
			   end
			if @c_tablename ='BOOKDETAIL' and @c_columnname = 'SERIESCODE' 
		   	 begin
				if @stringvalue <> '(Not Present)' 
				  begin
			    		   select @stringvalue = datadesc from gentables where tableid=327 and 
						    datacode = convert(int,rtrim(@stringvalue))
				  end
					select @newvalue = datadesc from gentables where tableid=327 and 
				 	   datacode = convert(int,rtrim(@newvalue))
			   end

	 	         if @c_tablename ='BOOKDETAIL' and @c_columnname = 'MEDIATYPESUBCODE'
		           begin
				if @stringvalue <> '(Not Present)' 
				  begin
			    		   select @stringvalue = datadesc from subgentables where tableid=312 and 
						    datacode =  @feedin_count
							and datasubcode = convert(int,rtrim(@stringvalue))
				  end
					select @newvalue = datadesc from subgentables where tableid=312 and 
				 	   datacode = convert (varchar (100),@otherinfo)
							and datasubcode = convert(int,rtrim(@newvalue))
			   end
		  	   if @c_tablename ='BOOKPRICE' and  convert(int,@otherinfo) = @i_currencycode2 /*us price*/
			     begin
				select @newvalue = @newvalue + ' USDL'
				select  @feedin_fielddesc = 'Price 1 - List'
			     end

			    if @c_tablename ='BOOKPRICE' and  convert(int,@otherinfo) = 11 /*canada price*/
			     begin
				select @newvalue = @newvalue + ' CNDL'
				select  @feedin_fielddesc = 'Price 2 - List'
			     end
						  
    END /* compare old and new */
    
  END --@newvalueisready = 0
			  
	
	IF RTRIM(@stringvalue) <> RTRIM(@newvalue)  /* compare old and new */
	BEGIN

    if  @lv_table_to_upd  = 'D' --DATEHISTORY
    begin /*update datehistory dateprior will be entered in trigger*/

      UPDATE keys 
      SET generickey = generickey+1, lastuserid = 'feedin', lastmaintdate = getdate()

      select @nextkey = generickey from Keys

      /*@printingkey , pass stagecode here*/

      insert into datehistory 
        (bookkey, datetypecode, datekey, printingkey,
        datechanged, datestagecode, dateprior, lastuserid, lastmaintdate)
      values 
        (@bookkey, @lv_datetypecode, @nextkey, 1,
        @newvalue, @printingkey, @currentvalue_date, 'feedin', @feed_system_date)      
    end
     
    else  --TITLEHISTORY
    begin    
      -- 1/5/07 - KW - Note: stringvalue is updated by AFTER_HISTORY_CHANGEDFROM trigger on titlehistory.
      insert into titlehistory 
        (bookkey, printingkey, columnkey, fielddesc,
        currentstringvalue, stringvalue, lastuserid, lastmaintdate)
      values 
        (@bookkey, 1, @columnkey, @feedin_fielddesc,
        @newvalue, @stringvalue, 'feedin', @feed_system_date)
    end
			  
/** Resend title to Eloquence-set bookedistatus.edistatuscode to Resend (3)**/
/*1-11-05 edistatuscode update
		check status before update gentables.gen1ind=1 then do not update to resend */
			
			    select @i_gen1ind = 0
			    select @feedin_count2 = 0
			    select @feedin_count2 = count(*) from bookedipartner
			 		where printingkey = 1 and bookkey = @bookkey
		 			

			    select @feedin_count3 = 0
			    select @feedin_count3 = count(*)  from bookedistatus
			 		where printingkey = 1 and bookkey = @bookkey

			    if @feedin_count3 > 0
			     begin /*rows present on bookedistatus*/
				/*check edistatuscode first*/
				select @i_gen1ind = gen1ind
					from bookedistatus b, gentables g
				  where b.edistatuscode = datacode and tableid=325
					and printingkey = 1 and bookkey = @bookkey

				if @i_gen1ind is null 
				  begin
				   	select @i_gen1ind = 0
				   end

				 if @i_gen1ind <> 1 
				  begin

					if @feedin_count2 > 0
					  begin

						update bookedipartner
						set sendtoeloquenceind = 1,
					  	lastuserid='feedin',
					 	 lastmaintdate = @feed_system_date
						   	 where printingkey =1 and bookkey = @bookkey

						update bookedistatus
						set edistatuscode = 3,
						   lastuserid='feedin',
						  lastmaintdate = @feed_system_date
						    	where printingkey =1 and bookkey = @bookkey
					  end
				  end
			  end
			  
			else/* no rows present insert values */
	 	 	  begin
				if @feedin_count2 > 0 and @i_gen1ind <> 1 
				  begin
					insert into bookedistatus (EDIPARTNERKEY,BOOKKEY,PRINTINGKEY,EDISTATUSCODE,
						LASTUSERID,LASTMAINTDATE)
					select edipartnerkey,bookkey,1,3,'feedin',@feed_system_date
						from bookedipartner where printingkey =1 and bookkey = @bookkey
				    end
			  end	
/*  add bookwhupdate */
			select @feedin_count2 = 0
			 select @feedin_count2 = count(*) from bookwhupdate
			 	where bookkey = @bookkey
			if @feedin_count2 = 0 
			  begin /*insert */
				insert into bookwhupdate
					(bookkey,lastmaintdate,lastuserid)
				values  (@bookkey,getdate(),'feedin')
			  end
		 
  END /* compare old and new */
  
END /*count > 0*/

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO