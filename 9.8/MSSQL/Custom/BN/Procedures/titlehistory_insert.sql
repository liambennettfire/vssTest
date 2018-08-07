PRINT 'STORED PROCEDURE : dbo.titlehistory_insert'
GO


if exists (select * from dbo.sysobjects where id = Object_id('dbo.feed_in_title_info') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.titlehistory_insert
end

GO

CREATE proc dbo.titlehistory_insert
@columnkey  int,
@bookkey int,
@printingkey int,
@otherinfo varchar(20),
@newvalue varchar(100)

AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

/*2-19-04 change parameter from columnname,tablename to columnkey*/
/* 10-18-04 CRM 01754  add datehistory for vista xjrpop.prn file confirmed warehouse date update*/
/*1-11-05 CRM 2289  test edistatuscode before changing to send*/

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
DECLARE @stringvalue	varchar(100)
DECLARE @lv_edipartnerkey int
DECLARE @i_count int
DECLARE @lv_datetypecode int
DECLARE @lv_table_to_upd varchar(5)
DECLARE @nextkey int
DECLARE @stagecount int
DECLARE @i_gen1ind int
DECLARE @edistatuscode int


BEGIN tran 

	SELECT @feed_system_date = getdate()

	select @feedin_count = 0	
 
	select @feedin_count =count(*)  
		from titlehistorycolumns 
			where  columnkey = @columnkey

	if  @feedin_count > 0 
	begin
		select @feedin_datatype = datatype, 
			@feedin_fielddesc =columndescription,@c_tablename = tablename,@c_columnname=columnname  
			from titlehistorycolumns 
				where  columnkey = @columnkey 

		if @c_tablename ='BOOKDATES'  
		begin
			select @feedin_fielddesc = description from datetype where datetypecode = convert(int,@otherinfo)
		end
	end
	else
	begin
		insert into feederror 							
			(isbn,batchnumber,processdate,errordesc)
		values (convert(char,10,@bookkey),'3',@feed_system_date,('There is no titlehistory column for this value ' + @c_tablename +' '+@c_columnname))
		RETURN 0
	end

	if  @feedin_count > 0 
	begin
 		/*possible values pubmonth taken care off with pub date */
		if @feedin_datatype = 'i'
		begin
		  if upper(rtrim(@c_tablename)) ='PRINTING' and upper(rtrim(@c_columnname)) = 'PUBMONTHCODE'
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
		  if upper(rtrim(@c_tablename)) ='BINDINGSPECS' and upper(rtrim(@c_columnname)) = 'CARTONQTY1'
		  begin
			
			select @feedin_count2 = 0

			select @feedin_count2 = count(*) 
				from bindingspecs
				  where bookkey = @bookkey
					and printingkey = @printingkey
			if @feedin_count2 > 0 
			begin
				select @currentvalue_int = cartonqty1
				from bindingspecs
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
		end  /* int data*/
  
		if @feedin_datatype = 'a' OR @feedin_datatype = 'd' /*possible values retailprice,pubdate,reldate,canadianprice */
		begin

	 	   if upper(rtrim(@c_tablename)) ='BOOKDETAIL' and upper(rtrim(@c_columnname)) = 'BISACSTATUSCODE' /*BISAC*/
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
					select @stringvalue = convert(char,@currentvalue_int)
				end
			end

		   if @c_tablename ='BOOKDATES' 
		   begin
				select @lv_datetypecode = convert (int,@otherinfo)
				select @feedin_count2 = 0
					
				select @lv_table_to_upd = 'D'

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
     		end  /* tablename = "BOOKDATES: */

 			if upper(rtrim(@c_tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='6' /*list/retail price*/
			begin
  				select @feedin_count2 = 0

				 select @feedin_count2 = count(*) 
				   from BOOKPRICE
				  	where pricetypecode=11 and currencytypecode=6
						and bookkey = @bookkey
				if @feedin_count2 > 0 
				begin
				      select @currentvalue_numeric = finalprice
					   from BOOKPRICE
					  	where pricetypecode=11 and currencytypecode=6
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
					select @stringvalue = convert(char,@currentvalue_numeric)
			    end 
     		 end 

			 if upper(rtrim(@c_tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='11' /*list price*/
			 begin
				select @feedin_count2 = 0

				 select @feedin_count2 = count(*) 
					from BOOKPRICE
				  		where pricetypecode=11 and currencytypecode=11
							and bookkey = @bookkey
				if @feedin_count2 > 0 
				begin
 					select @currentvalue_numeric = finalprice
					   from BOOKPRICE
					  	where pricetypecode=11 and currencytypecode=11
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
					select @stringvalue = convert(char,@currentvalue_numeric)
			    end 
           end 	  
	 	end  /*	end alpha description*/
	

		if rtrim(@stringvalue) <> rtrim(@newvalue)  /* compare old and new values */
		begin
	 	   if upper(rtrim(@c_tablename)) ='BOOKDETAIL' and upper(rtrim(@c_columnname)) = 'BISACSTATUSCODE' /* only gentable row that needs converting currently*/
		   begin
			    if @stringvalue <> '(Not Present)' 
			    begin
			       select @stringvalue = datadesc from gentables where tableid=314 and 
					    datacode = convert(int,rtrim(@stringvalue))
				 end
				 select @newvalue = datadesc from gentables where tableid=314 and 
				    datacode = convert(int,rtrim(@newvalue))
			end

		   if @c_tablename ='BOOKPRICE' and  convert(int,@otherinfo) = 6 /*us price*/
			begin
				select @newvalue = @newvalue + ' USDL'
				select  @feedin_fielddesc = 'Price 1 - List'
			end

			if @c_tablename ='BOOKPRICE' and  convert(int,@otherinfo) = 11 /*canada price*/
			begin
				select @newvalue = @newvalue + ' CNDL'
				select  @feedin_fielddesc = 'Price 2 - List'
			end

			if  @lv_table_to_upd  = 'D' 
			begin/*update datehistory dateprior will be entered in trigger*/

				UPDATE keys SET generickey = generickey+1, 
					 lastuserid = 'QSIADMIN', 
					lastmaintdate = getdate()

				select @nextkey = generickey from Keys

				/*36 is actual date ,37 estimated*/
				if @columnkey = 36 
				begin
					select @stagecount = 1
				end
				else
				begin	
					select @stagecount = 2
				end

				insert into datehistory (bookkey,datetypecode,datekey,
					printingkey,datechanged,datestagecode,dateprior,lastuserid,lastmaintdate)
				values (@bookkey,@lv_datetypecode,@nextkey,@printingkey,@newvalue,
					@stagecount,@currentvalue_date,'feedin',@feed_system_date)
			end
			else
			begin

				insert into titlehistory (bookkey,printingkey,columnkey,lastmaintdate,stringvalue,lastuserid,
				currentstringvalue,fielddesc)
				values (@bookkey,1,@columnkey,@feed_system_date,@stringvalue,'VISTAFEED',
				@newvalue,@feedin_fielddesc)
				
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

			if @feedin_count3 > 0  /*rows present on bookedistatus*/
			begin 
				
            select @edistatuscode = 0
				
            /*check edistatuscode first*/
            select @edistatuscode = edistatuscode
					from bookedistatus b
				  where printingkey = 1 and bookkey = @bookkey

				if @edistatuscode is null 
				begin
				  	select @edistatuscode = 0
				end

				if @feedin_count2 > 0   /* rows on bookedipartner  */
				begin
              /* Do not send to eloquence if edistatuscode = 7 (Do not send) or 8 (Never send)  or 1 (Not Sent) or 6 (Delete)*/
				  IF (@edistatuscode not in (0,1,6,7,8))
              begin
				 		update bookedipartner
							set sendtoeloquenceind = 1,
								 lastuserid='VISTAFEED',
							    lastmaintdate = @feed_system_date
						 where printingkey =1 and bookkey = @bookkey
	
						update bookedistatus
							set edistatuscode = 3,
							 	 lastuserid='VISTAFEED',
							    lastmaintdate = @feed_system_date
						 where printingkey =1 and bookkey = @bookkey
               end
				 end
			end  /* rows present on bookedistatus */
			/*else/* no rows on bookedistatus present insert values */
			begin
				/*if @feedin_count2 > 0 and @i_gen1ind <> 1 */
            if @feedin_count2 > 0  /* rows on bookedipartner */
				begin
					/* This makes no sense so I am commenting it out KB 11/13/07 */
					/*update bookedistatus
					     set edistatuscode = 3,
							   lastuserid='VISTAFEED',
							   lastmaintdate = @feed_system_date
					 	where printingkey =1 and bookkey = @bookkey */

					update bookedipartner
						set sendtoeloquenceind = 1,
							 lastuserid='VISTAFEED',
							 lastmaintdate = @feed_system_date
					 where printingkey =1 and bookkey = @bookkey
	
					insert into bookedistatus (EDIPARTNERKEY,BOOKKEY,PRINTINGKEY,EDISTATUSCODE,
							LASTUSERID,LASTMAINTDATE)
					select edipartnerkey,bookkey,1,1,'VISTAFEED',@feed_system_date
							from bookedipartner where printingkey =1 and bookkey = @bookkey
				 end
			end */
	
			/*  add bookwhupdate */
			select @feedin_count2 = 0
			 select @feedin_count2 = count(*) from bookwhupdate
			 	where bookkey = @bookkey
			if @feedin_count2 = 0 
			  begin /*insert */
				insert into bookwhupdate
					(bookkey,lastmaintdate,lastuserid)
				values  (@bookkey,getdate(),'VISTAFEED')
			  end

		 end /* compare old and new */
end /*count > 0*/
commit tran
return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO