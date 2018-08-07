SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[elocustomoutbook_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[elocustomoutbook_sp]
GO




CREATE proc dbo.elocustomoutbook_sp @i_bookkey int
as

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back

i_onixlevel can equal 1 for generic onix (Level 1), 2 for Onix Level 2, 3 for QSI WEB Site Onix 
**/

DECLARE @c_isbn13 varchar (13)
DECLARE @c_isbn10 varchar (10)
DECLARE @c_ean varchar (50)



	

DECLARE @d_usretailprice decimal (10,2)
DECLARE @d_canadaretailprice decimal (10,2)	
DECLARE @d_estusretailprice decimal (10,2)
DECLARE @d_estcanadaretailprice decimal (10,2)	
DECLARE @d_pubdate datetime
DECLARE @c_pubdateYYYYMMDD varchar(8)
DECLARE @c_bisacstatuscode varchar (25)
DECLARE @i_rownumber int

DECLARE @i_error int
DECLARE @i_warning int
DECLARE @i_validationerrorind int
DECLARE @i_activetitle int
DECLARE @c_tempmessage varchar (255)


/** Constants for Validation Errors **/
select @i_error = 1
select @i_warning = 2

begin tran

/** Initialize the Validation Error to zero (False) **/
/** This will be set to '1' if any validation fails, and the transaction will be rolled back **/
/** for this bookkey.  Processing will continue to the next bookkey **/

select @i_validationerrorind = 0
select @i_activetitle = 0

/******************************************************************/
/** Output  Bookkey,ISBN10,EAN,PubDate,& Retail Price     **/
/*****************************************************************/
select @d_pubdate=NULL

select @c_bisacstatuscode=g.bisacdatacode
from bookdetail bd,gentables g
where bd.bookkey= @i_bookkey and g.tableid=314 
and g.datacode=bd.bisacstatuscode

/* don't include  OS, OSI titles */
/* CT - 4/22/03 - Modified per Rahul's request to incldue ONLY Active titles */

if @c_bisacstatuscode <> ('ACT')
Begin
	set @i_activetitle = 1
end
else 
Begin /* main Loop */

/* select ISBN13, ISBN10, EAN */


	select  @c_isbn10=isbn10, @c_ean=ean
		from isbn where bookkey= @i_bookkey and isbn10 is not null
		if @@rowcount<=0
		begin
			select @i_validationerrorind = 1
			exec eloonixvalidation_sp @i_error, @i_bookkey, 'ISBN missing'
			print 'blank ISBN' 
			return 1
		end
		if @@error <>0
		begin
			rollback tran
			/*exec eloprocesserror_sp @i_bookkey,@@error,'SQL Error'*/
			return -1  /** Fatal SQL Error **/
		end
/* select pubdate */

	select @d_pubdate = activedate from bookdates 
		where bookkey=@i_bookkey  and printingkey=1 and datetypecode=8

		if @d_pubdate is NOT NULL
		begin
			/* Call the Date conversion function, 
			then retrieve the resuling date from eloconverteddate */
			exec eloformatdateYYYYMMDD_sp @d_pubdate
			select @c_pubdateYYYYMMDD=converteddate from eloconverteddate
		end
		else /*** Check for Estimated Pub Date ***/
		begin
			select @d_pubdate = estdate from bookdates 
			where bookkey=@i_bookkey and printingkey=1 and datetypecode=8
			if @d_pubdate is NOT NULL
			begin
				/* Call the Date conversion function, 
				then retrieve the resuling date from eloconverteddate */
				exec eloformatdateYYYYMMDD_sp @d_pubdate
				select @c_pubdateYYYYMMDD=converteddate from eloconverteddate
			end
			else 
		/*** Actual or Estimated Pub Date does not exist, Try Pub Year from Printing. Pub Year is set in Java Import
	   	 to Pub Month + Pub Year, with day set to '01'. i.e. 03/01/2001 ***/
			begin
				select @d_pubdate=pubmonth from printing
      			where bookkey=@i_bookkey and printingkey=1 
				if @d_pubdate is NOT NULL
				begin
					/* Call the Date conversion function, 
					then retrieve the resuling date from eloconverteddate */
					exec eloformatdateYYYYMMDD_sp @d_pubdate
					select @c_pubdateYYYYMMDD=converteddate from eloconverteddate
				end
			end
		end /** End Else Check Est Pub DatePub Year **/
	

	/******************************************/
	/** Output US Retail and Canadian Retail***/
	/******************************************/


	/** output Estimate price if Final not available **/

	select @d_usretailprice=0
	select @d_estusretailprice=0

		select 
	@d_usretailprice=convert (decimal (10,2),finalprice),
	@d_estusretailprice=convert (decimal (10,2),budgetprice)  
	from bookprice
	where bookkey=@i_bookkey and pricetypecode=8
	and currencytypecode=6

	if @d_usretailprice=0 or @d_usretailprice is null  /* Final price not found, use budget */
	begin
		if @d_estusretailprice > 0 and @d_estusretailprice is not null
		begin
			select @d_usretailprice=@d_estusretailprice
		end
	end

	if @d_usretailprice=0 or @d_usretailprice is null /* Retail Price Not Found - Try for Suggested List Price */
	begin
		select @d_usretailprice=convert (decimal (10,2),finalprice),
		@d_estusretailprice=convert (decimal (10,2),budgetprice)  
		from bookprice
		where bookkey=@i_bookkey and pricetypecode=11
		and currencytypecode=6

		if @d_usretailprice=0 or @d_usretailprice is null  /* Final price not found, use budget */
		begin
			if @d_estusretailprice > 0 and @d_estusretailprice is not null
			begin
				select @d_usretailprice=@d_estusretailprice
			end
		end
	end


	select @d_canadaretailprice=0
	select @d_estcanadaretailprice=0

	select 
	@d_canadaretailprice=convert (decimal (10,2),finalprice),
	@d_estcanadaretailprice=convert (decimal (10,2),budgetprice)  
	from bookprice
	where bookkey=@i_bookkey and pricetypecode=8
	and currencytypecode=11

	if @d_canadaretailprice=0 or @d_canadaretailprice is null  /* Final price not found, use budget */
	begin
		if @d_estcanadaretailprice > 0 and @d_estcanadaretailprice is not null
		begin
			select @d_canadaretailprice=@d_estcanadaretailprice
		end
	end

	if @d_canadaretailprice=0 or @d_canadaretailprice is null /* Retail Price Not Found - Try for Suggested List Price */
	begin
		select @d_canadaretailprice=convert (decimal (10,2),finalprice),
		@d_estcanadaretailprice=convert (decimal (10,2),budgetprice)  
		from bookprice
		where bookkey=@i_bookkey and pricetypecode=11
		and currencytypecode=11

		if @d_canadaretailprice=0 or @d_canadaretailprice is null  /* Final price not found, use budget */
		begin
			if @d_estcanadaretailprice > 0 and @d_estcanadaretailprice is not null
			begin
				select @d_canadaretailprice=@d_estcanadaretailprice
			end
		end
	end





/**********************************************************/
/**                                                      **/
/** Insert the row into the elocustomfeed table          **/
/**                                                      **/  
/**********************************************************/
if @i_validationerrorind = 1
begin
	rollback tran
	return 0
end

insert into elocustomfeed
(
	bookkey ,
	status,
	isbn10 ,	
	ean ,
	pubdateYYYYMMDD ,
	uslistprice ,
	canadalistprice 
)
values
(
	@i_bookkey,
	@c_bisacstatuscode,
	@c_isbn10,
	@c_ean,
	@c_pubdateYYYYMMDD  ,
	@d_usretailprice ,
	@d_canadaretailprice 
	
)


end  /*end of main loop */

if @i_validationerrorind = 1
begin
	rollback tran
end
else
begin
	commit tran
end

return 0



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

