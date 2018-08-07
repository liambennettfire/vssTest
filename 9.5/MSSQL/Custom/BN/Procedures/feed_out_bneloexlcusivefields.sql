if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_out_bneloexlcusivefields]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_out_bneloexlcusivefields]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE proc dbo.feed_out_bneloexlcusivefields
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back

**/

DECLARE @titlestatusmessage varchar (255)
DECLARE @statusmessage varchar (255)
DECLARE @c_outputmessage varchar (255)
DECLARE @c_output varchar (255)
DECLARE @titlecount int
DECLARE @titlecountremainder int
DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime
DECLARE @i_isbn int
DECLARE @i_isbn2 int

DECLARE @feed_categorycode int
DECLARE @feed_categorysubcode int 
DECLARE @feed_sortorder int
DECLARE @feed_retailqty1 int
DECLARE @feed_retailqty2 int
DECLARE @feed_retailqty3 int
DECLARE @feed_retailqty4 int


DECLARE @feed_count int
DECLARE @feedout_bookkey  int
DECLARE @feedout_unitcost float
DECLARE @feedout_isbn char (13)
DECLARE @feedout_retailqty int
DECLARE @feedout_subject varchar (40)
DECLARE @feedout_subjectcategory  varchar (140) 
DECLARE @feedout_subjectcode varchar (100)
DECLARE @feedout_subjectsubcode  varchar (100) 
-- Added for CRM 3099 PM 8-24-05
DECLARE @feedout_boardtrimsize  varchar (40)   
DECLARE @feedout_pubclass  varchar (40)   
DECLARE @feedout_pubclassExtcode  varchar (30)   
DECLARE @feedout_businessgroup  varchar (40)   
-- Added for CRM 3456 PM 01-09-06
DECLARE @feed_bnclasscode int
DECLARE @feed_businessgroupcode int
DECLARE @feedout_bndcvendornumber varchar(10)
DECLARE @feedout_bnproprietarycode varchar(40)




DECLARE @c_message  varchar(255)

select @statusmessage = 'BEGIN BN ELOQ EXCLUSIVE FIELDS' + convert (char,getdate())
print @statusmessage


select @titlecount=0
select @titlecountremainder=0

SELECT @feed_system_date = getdate()

truncate table bnpubeloexclusivefields

DECLARE feedout_titles INSENSITIVE CURSOR
FOR
select distinct b.bookkey from book b, isbn i 
where b.bookkey = i.bookkey and
      i.isbn is not null and
      b.sendtoeloind = 1


	
FOR READ ONLY
	
	
OPEN feedout_titles 

FETCH NEXT FROM feedout_titles 
	INTO @feedout_bookkey
 
select @i_isbn  = @@FETCH_STATUS

if @i_isbn <> 0 /*no isbn*/
begin	
  begin tran
	insert into feederror 										
		(batchnumber,processdate,errordesc)
		values ('1',@feed_system_date,'NO ROWS to PROCESS - Titles')
  commit tran
end

while (@i_isbn<>-1 )  /* status 1*/
begin
	IF (@i_isbn<>-2) /* status 2*/
	begin

/*set defaults here*/	

	select @feed_count = 0
	select @feedout_isbn = ''
	select @feedout_unitcost = 0
	select @feedout_subjectcode = ''
	select @feedout_subjectsubcode = ''
	select @feedout_retailqty = 0
	select @feed_retailqty1 = 0
	select @feed_retailqty2 = 0
	select @feed_retailqty3 = 0
	select @feed_retailqty4 = 0
	select @feedout_boardtrimsize  = ''
	select @feedout_pubclass = ''   
	select @feedout_pubclassExtcode = ''  
	select @feedout_businessgroup  = ''   
	select @feedout_bndcvendornumber = ''
	select @feedout_bnproprietarycode = ''
	select @feed_bnclasscode = 0
	select @feed_businessgroupcode = 0

/*isbn */

	select @feedout_isbn = isbn
	from isbn
	where bookkey = @feedout_bookkey

/* unit cost */
	select @feedout_unitcost = floatvalue 
	from bookmisc 
	where misckey = 6
	  and bookkey = @feedout_bookkey

/* retail quantity */

	select  @feed_retailqty1 = qty  
		from bookqtybreakdown 
		where qtyoutletcode = 1 and qtyoutletsubcode = 1  /*Retail - B&N */
		  and printingkey = 1
		  and bookkey = @feedout_bookkey

	select @feed_retailqty2 = qty  
		from bookqtybreakdown 
		where qtyoutletcode = 1 and qtyoutletsubcode = 2  /*Retail - B.Dalton */
		  and printingkey = 1
		  and bookkey = @feedout_bookkey

	select @feed_retailqty3 = qty  
		from bookqtybreakdown 
		where qtyoutletcode = 2 and qtyoutletsubcode = 1  /*Internet -  BN.com */
		  and printingkey = 1
		  and bookkey = @feedout_bookkey

	select @feed_retailqty4 = qty  
		from bookqtybreakdown 
		where qtyoutletcode = 4 and qtyoutletsubcode = 1  /*College - B&N College */
		  and printingkey = 1
		  and bookkey = @feedout_bookkey
	
	select @feedout_retailqty = @feed_retailqty1 + @feed_retailqty2 + @feed_retailqty3 + @feed_retailqty4

	/* Board Trim Size */
	select @feedout_boardtrimsize = boardtrimsizewidth + ' x ' + boardtrimsizelength
	from printing

	where printingkey = 1
	      and bookkey = @feedout_bookkey
	      and boardtrimsizewidth is not null

	/* Pub Class Desc */
	
	select @feedout_pubclass  = s.datadesc 
		from subgentables s, bookmisc b
		where s.tableid = 525 and s.datacode = 3
		  and b.longvalue = s.datasubcode
		  and b.misckey = 3
		  and bookkey = @feedout_bookkey
	
	/* Pub Class External Code */
	
	select @feedout_pubclassExtcode = s.externalcode 
		from subgentables s, bookmisc b
		where s.tableid = 525 and s.datacode = 3
		  and b.misckey = 3 -- added 10-24-05 PM
		  and b.longvalue = s.datasubcode
		  and bookkey = @feedout_bookkey


	/* Business Group */

	select @feedout_businessgroup = s.datadesc
		from subgentables s, bookmisc b
		where s.tableid = 525 and s.datacode = 4
  		  and b.misckey = 4
		  and b.longvalue = s.datasubcode
		  and bookkey = @feedout_bookkey

	/* Proprietary Code */

	select @feedout_bnproprietarycode = s.datadesc
		from subgentables s, bookmisc b
		where s.tableid = 525 and s.datacode = 5
  		  and b.misckey = 9
		  and b.longvalue = s.datasubcode
		  and bookkey = @feedout_bookkey

	/* DC Vendor Number */
	
	-- for use in following case select
	select @feed_bnclasscode = b.longvalue
		from bookmisc b
		where b.misckey = 1
		  and b.bookkey = @feedout_bookkey
	-- for use in following case select
	select @feed_businessgroupcode = b.longvalue
		from bookmisc b
		where b.misckey = 4
		  and b.bookkey = @feedout_bookkey

	Select @feedout_bndcvendornumber = 
	CASE
	--All Class of Sterling Titles where Business Group = Trade get DC Vendor Number 66286
		WHEN @feed_bnclasscode = 8 and @feed_businessgroupcode = 2 
		THEN '66286'
	--All other B&N Titles where Business Group = Trade get DC Vendor Number 990000
		WHEN @feed_bnclasscode  IN (1,2,3,4,6,7,9,10,11) and @feed_businessgroupcode = 2 
		THEN '990000'
	--All Class of Sterling Titles where Business Group = Bargain get DC Vendor Number 66285
		WHEN @feed_bnclasscode = 8 and @feed_businessgroupcode = 1 
		THEN '66285'
	--All Class of M.J. Fine Titles where Business Group = Bargain get DC Vendor Number 00350
		WHEN @feed_bnclasscode = 5 and @feed_businessgroupcode = 1 
		THEN '003350'
	--All other B&N Titles where Business Group = Bargain get DC Vendor Number 999000
		WHEN @feed_bnclasscode  IN (1,2,3,4,6,7,9,10,11) and @feed_businessgroupcode = 1 
		THEN '990000'
	--All B&N Titles where Business Group = Gift or Calendar get DC Purchase Vendor Number 998000
		WHEN @feed_bnclasscode  IN (1,2,3,4,6,7,9,10,11) and @feed_businessgroupcode IN (3,4) 
		THEN '998000'
	--If bookkey doesn't meet any of this criteria set output to NULL
		ELSE NULL
	END

/*First subject - category */

	select @feed_count = 1
	DECLARE feed_subjects INSENSITIVE CURSOR
	FOR

	select distinct categorycode,categorysubcode,sortorder
		from booksubjectcategory
		where  categorytableid=437
			and bookkey = @feedout_bookkey order by sortorder
	
	FOR READ ONLY

	OPEN feed_subjects 

	FETCH NEXT FROM feed_subjects
		INTO @feed_categorycode,@feed_categorysubcode,@feed_sortorder

	select @i_isbn2  = @@FETCH_STATUS

	while (@i_isbn2<>-1 )  /* status 1*/
	  begin
		IF (@i_isbn2<>-2) /* status 2*/
		  begin
			
			if @feed_count = 1
			  begin
				select @feedout_subject = datadesc ,@feedout_subjectcode =externalcode
				from gentables where tableid=437 and datacode = @feed_categorycode 
			
				if @feed_categorysubcode is null
				  begin
					select @feed_categorysubcode = 0
				  end
			
				if @feed_categorysubcode > 0
				  begin
			
					select @feedout_subjectcategory = datadesc ,@feedout_subjectsubcode =externalcode
						from subgentables where tableid=437 and datacode = @feed_categorycode
						and datasubcode = @feed_categorysubcode
				  end
			    end
			   else
			    begin
				goto exitsubj
		           end
			select @feed_count = @feed_count + 1

		end /*isbn2 status 2*/

		FETCH NEXT FROM feed_subjects
		INTO @feed_categorycode,@feed_categorycode,@feed_sortorder

		select @i_isbn2  = @@FETCH_STATUS
	end /*isbn2 status 1*/

exitsubj:
	
close feed_subjects
deallocate feed_subjects


/*insert into temporary table*/
begin tran
	insert into bnpubeloexclusivefields (isbn, 
                                             unitcost,
					     retailqty,
                                             bnsubjectcode, 
                                             bnsubjectdesc,
                                             assortmentcode,
                                             corporateimprintcode,
					     boardtrimsize,
					     pubclass,
					     pubclassextcode,
					     businessgroup,
					     bndcvendornumber,
					     bnproprietarycode)
	     			     values (@feedout_isbn,
					     @feedout_unitcost,
					     @feedout_retailqty,
			                     @feedout_subjectcode, 
					     @feedout_subject + ' - ' + @feedout_subjectcategory,
					     NULL,
					     NULL,
					     @feedout_boardtrimsize,
					     @feedout_pubclass,
					     @feedout_pubclassExtcode,
					     @feedout_businessgroup,
					     @feedout_bndcvendornumber,
					     @feedout_bnproprietarycode)


commit tran

end /*isbn status 2*/

FETCH NEXT FROM feedout_titles 
	INTO @feedout_bookkey 

select @i_isbn  = @@FETCH_STATUS
end /*isbn status 1*/

close feedout_titles
deallocate feedout_titles

return 0

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

