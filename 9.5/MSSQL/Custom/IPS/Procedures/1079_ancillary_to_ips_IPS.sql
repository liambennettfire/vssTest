--USE [IPS]
--GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.ancillary_to_ips') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.ancillary_to_ips 
end
go


CREATE PROCEDURE [dbo].[ancillary_to_ips] @v_incremental int AS
declare 
@v_cad_price varchar(10),
@v_product_rtn_disposition varchar(50),
@v_remainder_category varchar(50),
@v_taschen_series varchar(50),
@v_carton_rtn_disposition varchar(50),
@v_pub_discount_code varchar(50),
@v_tasche_mfg_cost varchar(50),
@v_budgetprice varchar(10), 
@v_finalprice varchar(10),
@v_pub_status varchar(50),
@v_price varchar(10),
@v_bisac_subject_code varchar(50),
@v_media  varchar(100),
@v_format varchar(100),
@v_media_format varchar(200),
@v_bookkey int,
@v_ean13 varchar(13),
@v_full_title varchar(1000),
@v_title varchar(500),
@v_subtitle varchar(500),
@v_imprint varchar(100),
@v_append_line varchar(8000),
@v_pub_date varchar(10),
@v_carton_qty varchar(10),
@v_header varchar(1000),
@command varchar(100),
@v_last_run datetime,
@v_expectedship_date varchar(10),
@v_ipsrelease_date varchar(10),
@v_ipsavailability_date varchar(10)


select @v_last_run = max(lastmaintdate) 
from titlehistory

create table #temp_export (bookkey int)

insert into #temp_export
select bookkey 
from titlehistory 
where columnkey in (248,89,39,9,10,11,3,1,23,4,90,248,43,45)
and lastmaintdate between cast(@v_last_run as varchar) and getdate()

insert into #temp_export
select bookkey 
from datehistory 
where datetypecode = 8
and lastmaintdate between cast(@v_last_run as varchar) and getdate()

if @v_incremental = 1 begin
	DECLARE cursor_isbn INSENSITIVE CURSOR
	FOR
	SELECT distinct bookkey 
	from #temp_export
	FOR READ ONLY
end else begin
	DECLARE cursor_isbn INSENSITIVE CURSOR
	FOR
	SELECT book.bookkey
	FROM book 
	FOR READ ONLY
end


--set @command='del C:\bbb\Ancillary_to_IPS.txt'
--EXEC MASTER..xp_cmdshell @command

set @v_header = 'EAN' + '|' + 'Title'  + '|' + 'Subtitle'  + '|' + 'Imprint'  + '|' + 'Media'  + '|' + 
						 'Binding'  + '|' + 'Pubdate'  + '|' + 'BISAC Subject'  + '|' + 'Ctn Qty' + '|' + 'List Price'  + '|' + 'CAD Price' + '|' + 
						 'Status' + '|' + 'IPS Disc Cat' + '|' + 'Carton Disposition' + '|' + 'Single Copy Disposition' + '|' + 'Return Category'  + '|' + 
						 'SKU' + '|' + 'Client Cost Price' + '|' + 'Expected Ship Date' + '|' + 'IPS Release Date' + '|' + 'IPS Availability Date'

--execute  sp_AppendToFile 'C:\bbb\Ancillary_to_IPS.txt', @v_header
execute  sp_AppendToFile 'd:\FirebrandShare\Ancillary_to_IPS.txt', @v_header


OPEN cursor_isbn
FETCH NEXT FROM cursor_isbn INTO @v_bookkey 
while (@@FETCH_STATUS<>-1 ) begin
	IF (@@FETCH_STATUS<>-2)
	begin
	set @v_ean13 = null
	select @v_ean13 = ean13
	from isbn 
	where bookkey = @v_bookkey

	set @v_title = null
	set @v_subtitle = null
	select @v_title = title, @v_subtitle = subtitle
	from book 
	where bookkey = @v_bookkey
  
	set @v_imprint = null
	select  @v_imprint = altdesc1
	from bookorgentry, orgentry
	where bookorgentry.orglevelkey = 4
	and bookorgentry.orgentrykey = orgentry.orgentrykey
	and bookkey = @v_bookkey

	set @v_media = null
	set  @v_format = null
	select @v_media = gentables.bisacdatacode, @v_format = subgentables.bisacdatacode
	from subgentables, bookdetail, gentables
	where bookdetail.mediatypecode = gentables.datacode
	and  bookdetail.mediatypesubcode = subgentables.datasubcode
	and bookdetail.mediatypecode = subgentables.datacode
	and bookdetail.bookkey = @v_bookkey
	and subgentables.tableid = 312
	and gentables.tableid = subgentables.tableid
	and gentables.tableid = 312

	
	set @v_pub_date = null
	SELECT @v_pub_date = CONVERT(VARCHAR(10), bookdates.bestdate, 101)
	from bookdates
	where bookkey = @v_bookkey
	and datetypecode = 8

	set @v_bisac_subject_code = null
	select @v_bisac_subject_code = subgentables.bisacdatacode
	from subgentables, bookbisaccategory, gentables
	where bookbisaccategory.bisaccategorycode = gentables.datacode
	and  bookbisaccategory.bisaccategorysubcode = subgentables.datasubcode
	and bookbisaccategory.bisaccategorycode = subgentables.datacode
	and bookbisaccategory.bookkey = @v_bookkey
	and subgentables.tableid = 339
	and gentables.tableid = subgentables.tableid
	and gentables.tableid = 339

	set @v_carton_qty = null
	select @v_carton_qty = cartonqty1
	from bindingspecs
	where bookkey = @v_bookkey

	
	set @v_budgetprice = null
	set @v_finalprice = null
	set @v_price = null
	select @v_budgetprice = budgetprice,  @v_finalprice = finalprice
	from bookprice, gentables
	where bookkey = @v_bookkey
	and bookprice.pricetypecode = 8
	and gentables.datacode = bookprice.pricetypecode
	and gentables.datacode = 8
	and gentables.tableid = 306
	and currencytypecode = 6
	
	if @v_finalprice is null begin
		set @v_price = @v_budgetprice
	end else begin
		set @v_price = @v_finalprice
	end

	set @v_budgetprice = null
	set @v_finalprice = null
	set @v_cad_price = null
	select @v_budgetprice = budgetprice,  @v_finalprice = finalprice
	from bookprice, gentables
	where bookkey = @v_bookkey
	and bookprice.pricetypecode = 8
	and gentables.datacode = bookprice.pricetypecode
	and gentables.datacode = 8
	and gentables.tableid = 306
	and currencytypecode = 11
	
	if @v_finalprice is null begin
		set @v_cad_price = @v_budgetprice
	end else begin
		set @v_cad_price = @v_finalprice
	end
	set @v_pub_status = null
	select @v_pub_status = gentables.externalcode
	from gentables, bookdetail
	where bookkey = @v_bookkey
	and bookdetail.bisacstatuscode = gentables.datacode
	and gentables.tableid = 314 

	set @v_pub_discount_code = null
	select @v_pub_discount_code = gentables.externalcode
	from gentables, bookdetail
	where bookkey = @v_bookkey
	and bookdetail.discountcode = gentables.datacode
	and gentables.tableid = 459

	set @v_budgetprice = null
	set @v_finalprice = null
	set @v_tasche_mfg_cost = null
	select @v_budgetprice = budgetprice,  @v_finalprice = finalprice
	from bookprice, gentables
	where bookkey = @v_bookkey
	and bookprice.pricetypecode = 21
	and gentables.datacode = bookprice.pricetypecode
	and gentables.datacode = 21
	and gentables.tableid = 306
	and currencytypecode = 6

	if @v_finalprice is null begin
		set @v_tasche_mfg_cost = @v_budgetprice
	end else begin
		set @v_tasche_mfg_cost = @v_finalprice
	end

	set @v_carton_rtn_disposition = null
	select @v_carton_rtn_disposition = externalcode
	from subgentables, bookmisc
	where misckey = 3
	and bookmisc.longvalue = subgentables.datasubcode
	and subgentables.datacode = 2
	and tableid = 525
	and bookkey = @v_bookkey

	set @v_product_rtn_disposition = null
	select @v_product_rtn_disposition = externalcode
	from subgentables, bookmisc
	where misckey = 5
	and bookmisc.longvalue = subgentables.datasubcode
	and subgentables.datacode = 2
	and tableid = 525
	and bookkey = @v_bookkey
	
	set @v_remainder_category = null
	select @v_remainder_category = externalcode
	from subgentables, bookmisc
	where misckey = 20
	and bookmisc.longvalue = subgentables.datasubcode
	and subgentables.datacode = 4
	and tableid = 525
	and bookkey = @v_bookkey
	
	set @v_taschen_series = null
	select @v_taschen_series = externalcode
	from subgentables, bookmisc
	where misckey = 2
	and bookmisc.longvalue = subgentables.datasubcode
	and subgentables.datacode = 1
	and tableid = 525
	and bookkey = @v_bookkey

	set @v_expectedship_date = null
	SELECT @v_expectedship_date = CONVERT(VARCHAR(10), bookdates.bestdate, 101)
	from bookdates
	where bookkey = @v_bookkey
	and datetypecode = 446

    set @v_ipsrelease_date = null
    select @v_ipsrelease_date = substring(dbo.rpt_get_misc_value (@v_bookkey, 34, ''),1,10)

    set @v_ipsavailability_date = null
    select @v_ipsavailability_date = substring(dbo.rpt_get_misc_value (@v_bookkey, 35, ''),1,10)
	
	set @v_append_line =    Isnull(@v_ean13, '') + '|' + 
							IsNull(@v_title, '') + '|' + 
							IsNull(@v_subtitle, '') + '|' + 
							IsNull(@v_imprint, '') + '|'  + 
							IsNull(@v_media, '') + '|'  + 
							IsNull(@v_format, '') + '|' + 
							IsNull(@v_pub_date, '') + '|' +
							IsNull(@v_bisac_subject_code, '') + '|'  + 
							IsNull(@v_carton_qty, '') + '|' +
							IsNull(@v_price, '') + '|'  + 
							IsNull(@v_cad_price, '') + '|'  + 
							IsNull(@v_pub_status, '')  + '|'  + 
							IsNull(@v_pub_discount_code, '') + '|'  + 
							IsNull(@v_carton_rtn_disposition, '') + '|'  + 
							IsNull(@v_product_rtn_disposition, '') + '|'  + 
							IsNull(@v_remainder_category, '')  + '|'  + 
							IsNull(@v_taschen_series, '') + '|'  + 
							IsNull(@v_tasche_mfg_cost, '')  + '|'  + 
                                IsNull(@v_expectedship_date, '') + '|' +
                                IsNull(@v_ipsrelease_date, '')  + '|'  + 
                                IsNull(@v_ipsavailability_date, '')


	--execute  sp_AppendToFile 'C:\bbb\Ancillary_to_IPS.txt', @v_append_line 
	execute  sp_AppendToFile 'D:\FirebrandShare\Ancillary_to_IPS.txt', @v_append_line 

	FETCH NEXT FROM cursor_isbn INTO @v_bookkey
	end
end


close cursor_isbn
deallocate cursor_isbn
drop table #temp_export