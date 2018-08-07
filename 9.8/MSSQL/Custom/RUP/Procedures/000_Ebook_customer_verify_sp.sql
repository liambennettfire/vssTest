if exists (select * from dbo.sysobjects where id = object_id(N'dbo.Ebook_customer_verify_sp') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.Ebook_customer_verify_sp
GO

/******************************************************************************
**  Name: Ebook_customer_verify_sp
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  02/11/2016   UK		     Case 36337
*******************************************************************************/

/****** Object:  StoredProcedure [dbo].[Ebook_customer_verify_sp]    Script Date: 02/11/2016 14:30:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE       PROCEDURE [dbo].[Ebook_customer_verify_sp]
		     @i_bookkey int,
		     @i_printingkey int,
		     @i_verificationtypecode int,
		     @i_username varchar(15)

AS
BEGIN
/* 


*/

DECLARE 
@v_optionvalue int,
@v_active_date datetime,
@v_subgen1ind int,
@v_price float,
@v_final_price float,
@v_datatypecode int,
@v_datacode int,
@v_titleprefix varchar(15),
@v_Error int,
@v_Warning int,
@v_Information int,
@v_Aborted int,
@v_Completed int,
@v_title varchar(255),
@v_subtitle varchar(255),
@v_cnt int,
@v_isbn varchar(13),
@v_isbn10 varchar(10),
@v_ean13 varchar(13),
@v_ean  varchar(50),
@v_mediatypecode int,
@v_mediatypesubcode int,
@v_bestdate datetime,
@v_agelow int,
@v_agehigh int, 
@v_gradelow varchar(4), 
@v_gradehigh varchar(4), 
@v_seriescode int,
@v_volumenumber int,
@v_editioncode int,
@v_editionnumber int,
@v_editiondescription varchar(50),
@v_returncode int,
@v_languagecode int,
@v_languagecode2 int,
@v_numericdesc1 float,
@v_cartonqty1 int,
@v_trimsizelength varchar(10),
@v_esttrimsizelength varchar(10),
@v_trimsizewidth varchar(10), 
@v_esttrimsizewidth varchar(10),
@v_spinesize varchar(15),
@v_bookweight float,
@v_tentativepagecount int, 
@v_pagecount int, 
@v_tmmpagecount int,
@v_totalruntime  varchar(10),
@v_eloquencefieldtag varchar(25),
@v_nextkey int,
@v_warnings int,
@v_failed int,
@v_isbn13 varchar(13),
@v_discountcode int,
@v_territoriescode int,
@v_barcodeid1 numeric(18,0),
@v_barcodeposition1 numeric(18,0),
@v_barcodeid2 numeric(18,0),
@v_barcodeposition2  numeric(18,0),
@v_bsg_msg varchar(100),
@v_g_msg varchar(100),
@v_bisac_status_code int,
@v_prodavailability int,
@v_allagesind int,
@v_agelowupind int,
@v_agehighupind int,
@v_gradelowupind int,
@v_gradehighupind int,
@v_elocustomerkey int,
@v_restriction_code int,
@i_write_msg int,

@i_cursor_pricetypes_status int,
@v_pricetypecode int,
@v_currencytypecode int,

@i_numcount int,
@i_rowcount int,
 @c_pricedesc nvarchar(120)

BEGIN 
-- init variables
set @v_Error = 2
set @v_Warning = 3
set @v_Information = 4
set @v_Aborted = 5
set @v_Completed = 6
set @v_failed = 0 
set @v_warnings = 0 

set @v_bsg_msg = ''
set @v_g_msg = ''

--insert into bookverification table if not already there - status=ready for verification

select @i_numcount=0
select @i_numcount=count(*) from bookverification where bookkey= @i_bookkey and verificationtypecode = @i_verificationtypecode
if @i_numcount = 0 OR @i_numcount is NULL
begin 
		insert into bookverification select @i_bookkey, @i_verificationtypecode,1,'fbt-initial',getdate()
end

--clean bookverificationmessager for passed bookkey
--if @i_username <> 'qsidba_load' begin
	delete bookverificationmessage
	where bookkey = @i_bookkey
	and verificationtypecode = @i_verificationtypecode
--end



--load data from bookdetail table

select @v_titleprefix = ltrim(rtrim(titleprefix)), @v_mediatypecode = mediatypecode, @v_mediatypesubcode = mediatypesubcode,
@v_agelow = agelow,@v_agehigh = agehigh, @v_gradelow = gradelow, @v_gradehigh = gradehigh, @v_seriescode = seriescode,
@v_volumenumber = volumenumber, @v_editioncode = editioncode, @v_editionnumber = editionnumber, @v_editiondescription = editiondescription,
@v_returncode = returncode,@v_restriction_code=restrictioncode, @v_languagecode = languagecode, @v_languagecode2 = languagecode2, @v_discountcode = discountcode,
@v_bisac_status_code = bisacstatuscode, @v_prodavailability = prodavailability, @v_allagesind = allagesind, @v_agelowupind = agelowupind,
@v_agehighupind = agehighupind, @v_gradelowupind = gradelowupind, @v_gradehighupind = gradehighupind
from bookdetail
where bookkey = @i_bookkey


--status
exec bookverification_check 'BISAC Status Code', @i_write_msg output
if @i_write_msg = 1 begin
	if @v_bisac_status_code is null  begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing BISAC Status Code',@i_username, getdate(), NULL)
		set @v_failed = 1
	end 
end

--product availability
exec bookverification_check 'Product Availability code', @i_write_msg output
if @i_write_msg = 1 begin
	if @v_prodavailability is null  begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Product Availability code',@i_username, getdate(), NULL)
		set @v_failed = 1
	end 
end

--error - elo 5 error - missing language

--exec bookverification_check 'Book Format', @i_write_msg output
if @i_write_msg = 1 begin
if @v_languagecode is null  begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Primary Language'+ @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
end 
end

select @i_write_msg = 1
if @i_write_msg = 1 begin
if @v_languagecode is NOT null and @v_languagecode2 is NOT  null begin 

	select @v_cnt = count(*)
	from gentables
	where datacode  in (@v_languagecode)
	
	and tableid = 318
	and eloquencefieldtag is not null and exporteloquenceind=1

	if @v_cnt = 0 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Eloquence Field tag or export to eloquence indicator for Primary Langauge'+ @v_bsg_msg,@i_username, getdate(), NULL)
		set @v_failed = 1
	end 
end
end





--error - territories

select @v_territoriescode = territoriescode
from book
where bookkey = @i_bookkey and territoriescode in (select datacode from gentables where tableid = 131 and deletestatus ='N')
select @i_write_msg = 1
if @i_write_msg = 1 begin
if @v_territoriescode is null or  @v_territoriescode = 0  begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing or Inactive Sales Territories information' + @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
end 
end

select @v_territoriescode = territoriescode
from book
where bookkey = @i_bookkey and territoriescode in (select datacode from gentables where tableid = 131 
	and eloquencefieldtag is not null and exporteloquenceind=1 and deletestatus ='N')

if @i_write_msg = 1 begin
if @v_territoriescode is null or  @v_territoriescode = 0  begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Eloquence Field tag or export to eloquence indicator for Sales Territories' + @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
end 
end

--check for tentativepagecount , pagecount, tmmpagecount 
select @v_tentativepagecount = tentativepagecount , @v_pagecount = pagecount, @v_tmmpagecount = tmmpagecount 
from printing
where bookkey = @i_bookkey
and printingkey = @i_printingkey

select @v_eloquencefieldtag = eloquencefieldtag
from gentables 
where tableid = 312
and datacode = @v_mediatypecode

--error if is book
exec bookverification_check 'Page Cnt', @i_write_msg output
if @i_write_msg = 1 begin
if @v_eloquencefieldtag in('EP') begin
	if @v_tentativepagecount is null and  @v_pagecount is null and @v_tmmpagecount is null begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Page Cnt'+ @v_g_msg,@i_username, getdate(), NULL)
		set @v_failed = 1
	end 
end
end


--error - missing discount code

exec bookverification_check 'Discount Code', @i_write_msg output
if @i_write_msg = 1 begin

	if @v_discountcode is null and @v_mediatypecode=2 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Discount Code',@i_username, getdate(), NULL)
		set @v_failed = 1
	end 
end

-- error - elo 5 error - missing media

exec bookverification_check 'Book Media', @i_write_msg output
if @i_write_msg = 1 begin
if @v_mediatypecode is null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Media'+ @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
end 
end
select @i_write_msg=1
if @i_write_msg = 1 begin
if @v_mediatypecode is not null begin
	select @v_cnt = count(*)
	from bookdetail
	where bookkey = @i_bookkey
	and mediatypecode in (select datacode from gentables where tableid = 312 and eloquencefieldtag is not null and exporteloquenceind=1)

	if @v_cnt = 0 begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Eloquence Field tag or export to eloquence indicator for Media'+ @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
	end 
end
end

--error - elo 5 error - missing format

exec bookverification_check 'Book Format', @i_write_msg output
if @i_write_msg = 1 begin
if @v_mediatypesubcode is null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Format'+ @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
end 
end

select @i_write_msg = 1
if @i_write_msg = 1 begin
if @v_mediatypesubcode is not null and @v_mediatypecode is not null begin
	select @v_cnt = count(*)
	from subgentables
	where datacode = @v_mediatypecode
	and datasubcode = @v_mediatypesubcode
	and tableid = 312
	and eloquencefieldtag is not null and exporteloquenceind=1

	if @v_cnt = 0 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Eloquence Field tag or export to eloquence indicator for Format'+ @v_bsg_msg,@i_username, getdate(), NULL)
		set @v_failed = 1
	end 
end
end





--check for title 

select @v_title = ltrim(rtrim(title)), @v_subtitle = ltrim(rtrim(subtitle))
from book
where bookkey = @i_bookkey
exec bookverification_check 'Book Title', @i_write_msg output
if @i_write_msg = 1 begin
if @v_title is null or  @v_title = '' begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Title' + @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
end 
end




--check for primary author
exec bookverification_check 'Primary Author', @i_write_msg output
if @i_write_msg = 1 begin
	select @v_cnt = count(bookkey)
	from  bookauthor
	where primaryind = 1
	and bookkey = @i_bookkey

	if @v_cnt = 0 begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Primary Author'+ @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
	end 
end

--check for eloquencefieldtag for that author type
select @i_write_msg = 1
if @i_write_msg = 1 begin
	if @v_cnt > 0 begin
		select @v_cnt = count(*)
		from bookauthor
		where bookkey = @i_bookkey
		and authortypecode in (select datacode from gentables where tableid = 134 and eloquencefieldtag is not null)
		
		if @v_cnt = 0 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Eloquence Field tag or export to eloquence indicator for Author'+ @v_bsg_msg,@i_username, getdate(), NULL)
		set @v_failed = 1
		end 
	end
end	



--check for isbn, isbn10, ean13
-- For elo basic 5 check EAN instead of EAN13
select @v_isbn = ltrim(rtrim(isbn)), @v_isbn10 = ltrim(rtrim(isbn10)), @v_ean13 = ltrim(rtrim(ean13)),@v_ean = ltrim(rtrim(ean)),
	@v_isbn13 =  ltrim(rtrim(isbn))
from isbn 
where bookkey = @i_bookkey

exec bookverification_check 'ISBN', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode <>0 begin
   if @v_isbn13 is null or @v_isbn13 = '' begin
      exec get_next_key @i_username, @v_nextkey out
      insert into bookverificationmessage
      values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing ISBN',@i_username, getdate(), NULL)
      set @v_failed = 1
   end 
end
end

exec bookverification_check 'ISBN10', @i_write_msg output
if @i_write_msg = 1 begin
if @v_isbn10 is null or @v_isbn10 = '' begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Information, 'Missing ISBN10'+ @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
end 
end

if @i_verificationtypecode <>0 begin
	exec bookverification_check 'EAN13', @i_write_msg output
	if @i_write_msg = 1 begin
	if @v_ean13 is null or @v_ean13 = '' begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing EAN13'+ @v_bsg_msg,@i_username, getdate(), NULL)
		set @v_failed = 1
	end 
	end
end

if @i_verificationtypecode <>0 begin
	exec bookverification_check 'EAN', @i_write_msg output
	if @i_write_msg = 1 begin
	if @v_ean is null or @v_ean = '' begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing EAN'+ @v_bsg_msg,@i_username, getdate(), NULL)
		set @v_failed = 1
	end 
	end
end

--error - check for pub date 
select @v_bestdate = bestdate
from bookdates
where bookkey = @i_bookkey
and datetypecode = 8
and printingkey = @i_printingkey


exec bookverification_check 'PUB Date', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode <> 0 begin
if @v_bestdate is null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing PUB Date'+ @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
end 
end
end


select @v_bestdate=NULL


--modify to add check for past due pubdate or too far forward pubdate
--add pubdate/status checks

select @v_bestdate = bestdate
from bookdates
where bookkey = @i_bookkey
and datetypecode = 8
and printingkey = @i_printingkey


if @v_bestdate <getdate()and @v_bisac_status_code = 4 begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_error, 'PUB Date passed, status still Forthcoming (NYP)'+ @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
end 

select @v_bestdate=NULL

select @v_bestdate = bestdate
from bookdates
where bookkey = @i_bookkey
and datetypecode = 8
and printingkey = @i_printingkey

if @v_bestdate >getdate()+21 and @v_bisac_status_code = 1 begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_error, 'PUB Date in future, status is Active'+ @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
end 




--check for Bisac Subject 1
select @v_cnt = count(bookkey)
from bookbisaccategory
where bookkey = @i_bookkey
and printingkey = @i_printingkey

exec bookverification_check 'BISAC Subject 1', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode <>0 begin
if @v_cnt = 0 begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing BISAC Subject 1'+ @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
end 
end
end
set @i_rowcount =0

select @i_rowcount= count(*) from CS_verification_control cs  where cs.mediatypecode =  @v_mediatypecode
and cs.mediatypesubcode=@v_mediatypesubcode



if @i_rowcount is not null and @i_rowcount >0 

BEGIN -- 1
	
	
	DECLARE cursor_pricetypes  CURSOR FAST_FORWARD
	for
	select cs.pricetypecode,cs.currencytypecode ,g.datadesc from CS_verification_control cs ,gentables g where cs.mediatypecode= @v_mediatypecode
	and cs.mediatypesubcode=@v_mediatypesubcode and cs.pricetypecode=g.datacode and g.tableid=306

	FOR READ ONLY

	OPEN cursor_pricetypes


	FETCH NEXT FROM cursor_pricetypes
	INTO @v_pricetypecode,@v_currencytypecode, @c_pricedesc

	select @i_cursor_pricetypes_status = @@FETCH_STATUS
	select @i_numcount = 0

	while (@i_cursor_pricetypes_status<>-1 )
	BEGIN --2
	
	IF (@i_cursor_pricetypes_status<>-2)
	BEGIN  --3
 	
 	
--price 
	
	

				select @v_cnt = count(*)
				from bookprice 
				where bookkey = @i_bookkey and currencytypecode=@v_currencytypecode and pricetypecode=@v_pricetypecode and activeind=1
				and (finalprice > 0 or budgetprice > 0) and pricetypecode in (select datacode from gentables where tableid = 306 
				and eloquencefieldtag is not null and eloquencefieldtag <> '' 
				and eloquencefieldtag not in ('NA','N/A') and 
				exporteloquenceind=1 and 
				deletestatus='n') 


	exec bookverification_check 'Price', @i_write_msg output
	if @i_write_msg = 1  
	BEGIN  --4

		if @v_cnt = 0  
		BEGIN  --5
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing '+ @c_pricedesc + @v_bsg_msg,@i_username, getdate(), NULL)
		set @v_failed = 1
	 END --5
	END --4


	
	FETCH NEXT FROM cursor_pricetypes
	INTO @v_pricetypecode,@v_currencytypecode,  @c_pricedesc
	select @i_cursor_pricetypes_status = @@FETCH_STATUS



 
 	END  -- 3 IF <> -2
END --2--While <> -1


	close cursor_pricetypes
	deallocate cursor_pricetypes


END --1  end price type IF
--Long Description
select  @i_write_msg = 1
select @v_cnt = count(bookkey)
from bookcomments
where bookkey = @i_bookkey and commenthtml is not null
and commenttypecode in (1,3) and commenttypesubcode in 
(select datasubcode from subgentables where tableid = 284 and eloquencefieldtag='D' and deletestatus='N' and exporteloquenceind=1)
and releasetoeloquenceind=1 


if @i_write_msg = 1 begin
if @i_verificationtypecode <>0 begin
	if @v_cnt = 0 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Long Description is missing or Release to Eloquence not checked'+ @v_bsg_msg,@i_username, getdate(), NULL)
		set @v_failed = 1
	end
end
end

--Short Description
select  @i_write_msg = 1
select @v_cnt = count(bookkey)
from bookcomments
where bookkey = @i_bookkey and commenthtml is not null
and commenttypecode in (1,3) and commenttypesubcode in 
(select datasubcode from subgentables where tableid = 284 and eloquencefieldtag='BD' and deletestatus='N' and exporteloquenceind=1)
and releasetoeloquenceind=1 

select @i_write_msg = 1
if @i_write_msg = 1 begin
if @i_verificationtypecode <> 0  begin
	if @v_cnt = 0 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Short Description is missing or Release to Eloquence not checked'+ @v_bsg_msg,@i_username, getdate(), NULL)
		set @v_failed = 1
	end
end
end


--related product
exec bookverification_check 'Supply Chain - Print ISBN', @i_write_msg output
select @v_cnt = count(bookkey)
from associatedtitles
where bookkey = @i_bookkey and associationtypecode=4 and associationtypesubcode=11 and len(isbn) in (13,17)


 if @i_write_msg = 1 begin
if @i_verificationtypecode <>0  begin
	if @v_cnt = 0 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Supply Chain data for Print ISBN'+ @v_bsg_msg,@i_username, getdate(), NULL)
		set @v_failed = 1
	end
end
end

--Publisher 
select @v_cnt = count(bookkey)
from bookorgentry
where bookkey = @i_bookkey
and orglevelkey in(select filterorglevelkey
		from filterorglevel
		where filterkey = 18)

exec bookverification_check 'Publisher', @i_write_msg output
if @i_write_msg = 1 begin
if @v_cnt = 0 begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Publisher'+ @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
end
end

--Imprint 
select @v_cnt = count(bookkey)
from bookorgentry
where bookkey = @i_bookkey
and orglevelkey in(select filterorglevelkey
		from filterorglevel
		where filterkey = 15)

exec bookverification_check 'Imprint', @i_write_msg output
if @i_write_msg = 1 begin
if @v_cnt = 0 begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Imprint' + @v_bsg_msg,@i_username, getdate(), NULL)
	set @v_failed = 1
end
end



--failed
if @v_failed = 1 begin

	select @v_datacode = datacode
	from gentables 
	where tableid = 513
	and qsicode = 2
	
	update bookverification
	set titleverifystatuscode = @v_datacode,
	       lastmaintdate = getdate(),
	       lastuserid = @i_username
	where bookkey = @i_bookkey	
	and verificationtypecode = @i_verificationtypecode

	/*	if @i_verificationtypecode = 1 begin
	 update coretitleinfo set verifcustomer = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
	end
	if @i_verificationtypecode = 2 begin
	 update coretitleinfo set verifelobasic = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
	end
	if @i_verificationtypecode = 3 begin
	 update coretitleinfo set verifbna = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
	end
	if @i_verificationtypecode = 4 begin
	 update coretitleinfo set verifbooknet = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
	end */

end 


--passed with warnings

select @v_datacode = datacode
from gentables 
where tableid = 513
and qsicode = 4

if @v_failed = 0 and @v_warnings = 1 begin
	update bookverification
	set titleverifystatuscode = @v_datacode,
       lastmaintdate = getdate(),
       lastuserid = @i_username
 	where bookkey = @i_bookkey
	and verificationtypecode = @i_verificationtypecode

/*
	if @i_verificationtypecode = 1 begin
	 update coretitleinfo set verifcustomer = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
	end
	if @i_verificationtypecode = 2 begin
	 update coretitleinfo set verifelobasic = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
	end
	if @i_verificationtypecode = 3 begin
	 update coretitleinfo set verifbna = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
	end
	if @i_verificationtypecode = 4 begin
	 update coretitleinfo set verifbooknet = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
	end
*/
end 

--passed
select @v_datacode = datacode
from gentables 
where tableid = 513
and qsicode = 3

if @v_failed = 0 and @v_warnings = 0 begin
	update bookverification
	set titleverifystatuscode = @v_datacode,
       lastmaintdate = getdate(),
       lastuserid = @i_username
	where bookkey = @i_bookkey
	and verificationtypecode = @i_verificationtypecode
/*	
	if @i_verificationtypecode = 1 begin
	 update coretitleinfo set verifcustomer = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
	end
	if @i_verificationtypecode = 2 begin
	 update coretitleinfo set verifelobasic = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
	end
	if @i_verificationtypecode = 3 begin
	 update coretitleinfo set verifbna = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
	end
	if @i_verificationtypecode = 4 begin
	 update coretitleinfo set verifbooknet = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
	end
*/

end 
END
END
GO
GRANT EXEC ON Ebook_customer_verify_sp TO PUBLIC
GO




