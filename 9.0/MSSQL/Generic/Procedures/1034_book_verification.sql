SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.verify_eloquence') and (type = 'P' or type = 'RF'))
begin
 drop proc verify_eloquence 
end
go

create       PROCEDURE dbo.verify_eloquence
		     @i_bookkey int,
		     @i_printingkey int,
		     @i_verificationtypecode int,
		     @i_username varchar(15)

AS

/* 
Best Practice - Verify existance of eloquence fields
AH -  2/6/07
*/

DECLARE 
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
@v_cnt2 int,
@v_cnt3	int,
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
@v_tmmactualtrimsizelength varchar(10),
@v_tmmactualtrimsizewidth varchar(10),
@v_spinesize varchar(15),
@v_bookweight float,
@v_tentativepagecount int, 
@v_pagecount int, 
@v_tmmpagecount int,
@v_totalruntime  varchar(10),
@v_eloquencefieldtag varchar(25),
@v_nextkey int,
@v_varnings int,
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
@i_write_msg int,
@v_count int,
@v_count2 int,
@v_pricevalidation_group int,
@v_error_code	int,
@v_err_desc	varchar(2000)


BEGIN 
-- init variables
set @v_Error = 2
set @v_Warning = 3
set @v_Information = 4
set @v_Aborted = 5
set @v_Completed = 6
set @v_failed = 0 
set @v_varnings = 0 
set @v_err_desc = ''


if @i_verificationtypecode in(4) begin
	set @v_bsg_msg = ' (Required for Bronze, Silver or Gold)'
	set @v_g_msg = ' (Required for Gold)'
end else begin
	set @v_bsg_msg = ' '
	set @v_g_msg = ' '
end

--clean bookverificationmessager for passed bookkey
delete bookverificationmessage
where bookkey = @i_bookkey
and verificationtypecode = @i_verificationtypecode



--check for titlefrefix, mediatypecode, mediatypesubcode, agelow, agehigh, gradelow, gradehigh,
--seriescode
select @v_titleprefix = ltrim(rtrim(titleprefix)), @v_mediatypecode = mediatypecode, @v_mediatypesubcode = mediatypesubcode,
@v_agelow = agelow,@v_agehigh = agehigh, @v_gradelow = gradelow, @v_gradehigh = gradehigh, @v_seriescode = seriescode,
@v_volumenumber = volumenumber, @v_editioncode = editioncode, @v_editionnumber = editionnumber, @v_editiondescription = editiondescription,
@v_returncode = returncode, @v_languagecode = languagecode, @v_languagecode2 = languagecode2, @v_discountcode = discountcode,
@v_bisac_status_code = bisacstatuscode, @v_prodavailability = prodavailability, @v_allagesind = allagesind, @v_agelowupind = agelowupind,
@v_agehighupind = agehighupind, @v_gradelowupind = gradelowupind, @v_gradehighupind = gradehighupind
from bookdetail
where bookkey = @i_bookkey

exec bookverification_check 'Book Title Prefix', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(2,3) begin
	if @v_titleprefix is null or  @v_titleprefix = '' begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Information, 'Missing Book Title Prefix',@i_username, getdate() )
	end 
end
end

exec bookverification_check 'BISAC Status Code', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(2) begin
	if @v_bisac_status_code is null  begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing BISAC Status Code',@i_username, getdate() )
		set @v_varnings = 1
	end 
end
if @i_verificationtypecode in(3) begin
	if @v_bisac_status_code is null  begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing BISAC Status Code',@i_username, getdate() )
		set @v_failed = 1
	end 
end
end
exec bookverification_check 'Product Availability Code', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(3) begin
	if @v_bisac_status_code = 1  begin
	if @v_prodavailability is null or  @v_prodavailability = 0 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Product Availability Code',@i_username, getdate() )
		set @v_failed = 1
	end 
    end
end
end
exec bookverification_check 'Discount Code', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(2) begin
	if @v_discountcode is null begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Discount Code',@i_username, getdate() )
		set @v_varnings = 1
	end 
end
end
exec bookverification_check 'Discount Code', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(3) begin
	if @v_discountcode is null begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Discount Code',@i_username, getdate() )
		set @v_failed = 1
	end 
end
end
exec bookverification_check 'Book Media', @i_write_msg output
if @i_write_msg = 1 begin
if @v_mediatypecode is null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Media'+ @v_bsg_msg,@i_username, getdate() )
	set @v_failed = 1
end 
end
exec bookverification_check 'Eloquence Field tag for Media', @i_write_msg output
if @i_write_msg = 1 begin
if @v_mediatypecode is not null begin
	select @v_cnt = count(*)
	from bookdetail
	where bookkey = @i_bookkey
	and mediatypecode in (select datacode from gentables where tableid = 312 and (eloquencefieldtag is not null and eloquencefieldtag  <> ' '))

	if @v_cnt = 0 begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Eloquence Field tag for Media'+ @v_bsg_msg,@i_username, getdate() )
	set @v_failed = 1
	end 
end
end

exec bookverification_check 'Book Format', @i_write_msg output
if @i_write_msg = 1 begin
if @v_mediatypesubcode is null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Format'+ @v_bsg_msg,@i_username, getdate() )
	set @v_failed = 1
end 
end

exec bookverification_check 'Eloquence Field tag for Format', @i_write_msg output
if @i_write_msg = 1 begin
if @v_mediatypesubcode is not null and @v_mediatypecode is not null begin
	select @v_cnt = count(*)
	from subgentables
	where datacode = @v_mediatypecode
	and datasubcode = @v_mediatypesubcode
	and tableid = 312
	and eloquencefieldtag is not null
    and eloquencefieldtag <> ' '

	if @v_cnt = 0 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Eloquence Field tag for Format'+ @v_bsg_msg,@i_username, getdate() )
		set @v_failed = 1
	end 
end
end

if @i_verificationtypecode in(2,3) begin
	if @v_allagesind is null or @v_allagesind = 0 begin
		if @v_agelowupind is null or @v_agelowupind = 0 begin
			exec bookverification_check 'Age Range - Age Low', @i_write_msg output
			if @i_write_msg = 1 begin
				if @v_agelow is null begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Age Range - Age Low',@i_username, getdate() )
					set @v_varnings = 1
				end 
			end
			if @v_agehighupind is null or @v_agehighupind = 0 begin
				exec bookverification_check 'Age Range - Age High', @i_write_msg output
				if @i_write_msg = 1 begin
					if @v_agehigh is null begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Age Range - Age High',@i_username, getdate() )
						set @v_varnings = 1
					end
				end
			end 
		end
	end
end

if @i_verificationtypecode = 2 begin --elo only
   -- only output error message for Grade Level if title has rows for BISAC Subjects of Juvenile Fiction or Juvenile Non-Fiction
	exec bookverification_check 'Grade Level - Grade Low', @i_write_msg output
	if @i_write_msg = 1 begin
   select @v_count = 0
   exec bookverification_bisacsubjects_check @i_bookkey,1, @v_count out
   if @v_count > 0 
   BEGIN
		if @v_gradelowupind is null or @v_gradelowupind = 0 begin
			if @v_gradelow is null begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Grade Level - Grade Low',@i_username, getdate() )
				set @v_varnings = 1
			end 
		end
		end
   END
	exec bookverification_check 'Grade Level - Grade High', @i_write_msg output
	if @i_write_msg = 1 begin
   if @v_count > 0
   BEGIN
		if @v_gradehighupind is null or @v_gradehighupind = 0  begin
			if @v_gradehigh is null begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Grade Level - Grade High',@i_username, getdate() )
				set @v_varnings = 1
			end 
		end
		end
    END
   if @v_count > 0  -- Rows exist for JUV/NON JUV on bookbisaccategory
   BEGIN
		exec bookverification_bisacsubjects_check @i_bookkey,0, @v_count2 out
      if @v_count2 > 0  -- Rows also exist on bookbisaccategory for other than JUV/NON JUV
      BEGIN
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'It is not valid to use JUV and Non JUV BISAC Subjects on a single title',@i_username, getdate() )
			set @v_varnings = 1
		END
	END
end

exec bookverification_check 'Series', @i_write_msg output
if @i_write_msg = 1 begin
if @v_seriescode is null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Series'+ @v_g_msg,@i_username, getdate() )
	set @v_varnings = 1
end 
end
/*
if @v_volumenumber is null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Volume Number'+ @v_g_msg,@i_username, getdate() )
	set @v_varnings = 1
end 

if @i_verificationtypecode in(3,4) begin
	if @v_editioncode is null begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Edition Type'+ @v_g_msg,@i_username, getdate() )
		set @v_varnings = 1
	end 
end
if @i_verificationtypecode in(3,4) begin
	if @v_editionnumber is null begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Edition #'+ @v_g_msg,@i_username, getdate() )
		set @v_varnings = 1
	end 
end
*/
exec bookverification_check 'Edition Description', @i_write_msg output
if @i_write_msg = 1 begin
if @v_editiondescription is null  or  @v_editiondescription = '' begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Edition Description'+ @v_g_msg,@i_username, getdate() )
	set @v_varnings = 1
end 
end
exec bookverification_check 'Return Code', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(3,4) begin
	if @v_returncode is null begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Return Code'+ @v_bsg_msg,@i_username, getdate() )
		set @v_failed = 1
	end 
end
end
exec bookverification_check 'Language', @i_write_msg output
if @i_write_msg = 1 begin
if @v_languagecode is null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Language'+ @v_bsg_msg,@i_username, getdate() )
	set @v_varnings = 1
end
end
/* 
if @v_languagecode2 is null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Second Language'+ @v_bsg_msg,@i_username, getdate() )
	set @v_varnings = 1
end 
*/

--check for title and subtitle
select @v_title = ltrim(rtrim(title)), @v_subtitle = ltrim(rtrim(subtitle))
from book
where bookkey = @i_bookkey
exec bookverification_check 'Book Title', @i_write_msg output
if @i_write_msg = 1 begin
if @v_title is null or  @v_title = '' begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Title' + @v_bsg_msg,@i_username, getdate() )
	set @v_failed = 1
end 
end
exec bookverification_check 'Book Title Subtitle', @i_write_msg output
if @i_write_msg = 1 begin
if @v_subtitle is null or  @v_subtitle = '' begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Information, 'Missing Book Title Subtitle'+ @v_bsg_msg,@i_username, getdate() )
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
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Primary Author'+ @v_bsg_msg,@i_username, getdate() )
	set @v_failed = 1
	end 
end

--check for eloquencefieldtag for that author type
exec bookverification_check 'Eloquence Field tag for Author', @i_write_msg output
if @i_write_msg = 1 begin
	if @v_cnt > 0 begin
		select @v_cnt = count(*)
		from bookauthor
		where bookkey = @i_bookkey
		and authortypecode in (select datacode from gentables where tableid = 134 and (eloquencefieldtag is not null and eloquencefieldtag <> ' '))
		
		if @v_cnt = 0 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Eloquence Field tag for Author'+ @v_bsg_msg,@i_username, getdate() )
		set @v_failed = 1
		end 
	end
end	



--check for isbn, isbn10, ean13
-- For elo basic 5 check EAN instead of EAN13
--select @v_isbn = ltrim(rtrim(isbn)), @v_isbn10 = ltrim(rtrim(isbn10)), @v_ean13 = ltrim(rtrim(ean13)),@v_ean = ltrim(rtrim(ean)),
--	@v_isbn13 =  ltrim(rtrim(isbn))
--from isbn 
--where bookkey = @i_bookkey
--
--exec bookverification_check 'ISBN', @i_write_msg output
--if @i_write_msg = 1 begin
--if @i_verificationtypecode = 3 begin
--   if @v_isbn13 is null or @v_isbn13 = '' begin
--      exec get_next_key @i_username, @v_nextkey out
--      insert into bookverificationmessage
--      values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing ISBN',@i_username, getdate() )
--      set @v_failed = 1
--   end 
--end
--end
--
--exec bookverification_check 'ISBN10', @i_write_msg output
--if @i_write_msg = 1 begin
--if @v_isbn10 is null or @v_isbn10 = '' begin
--	exec get_next_key @i_username, @v_nextkey out
--	insert into bookverificationmessage
--	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Information, 'Missing ISBN10'+ @v_bsg_msg,@i_username, getdate() )
--	set @v_failed = 1
--end 
--end
--if @i_verificationtypecode in(1,3,4) begin
--	exec bookverification_check 'EAN13', @i_write_msg output
--	if @i_write_msg = 1 begin
--	if @v_ean13 is null or @v_ean13 = '' begin
--		exec get_next_key @i_username, @v_nextkey out
--		insert into bookverificationmessage
--		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing EAN13'+ @v_bsg_msg,@i_username, getdate() )
--		set @v_failed = 1
--	end 
--	end
--end
--
--if @i_verificationtypecode = 2 begin
--	exec bookverification_check 'EAN13', @i_write_msg output
--	if @i_write_msg = 1 begin
--	if @v_ean is null or @v_ean = '' begin
--		exec get_next_key @i_username, @v_nextkey out
--		insert into bookverificationmessage
--		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing EAN'+ @v_bsg_msg,@i_username, getdate() )
--		set @v_failed = 1
--	end 
--	end
--end

exec qean_verify_productnumber_by_customer @i_bookkey, @v_error_code output, @v_err_desc output
IF @v_err_desc <> '' BEGIN
  SET @v_failed = 1
  exec get_next_key @i_username, @v_nextkey out
  insert into bookverificationmessage
  values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error,  @v_err_desc , @i_username, getdate() )
END


--check for pub date 
select @v_bestdate = bestdate
from bookdates
where bookkey = @i_bookkey
and datetypecode = 8
and printingkey = @i_printingkey

exec bookverification_check 'PUB Date', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(3) begin
if @v_bestdate is null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing PUB Date'+ @v_bsg_msg,@i_username, getdate() )
	set @v_failed = 1
end 
end
if @i_verificationtypecode in(2,4) begin
if @v_bestdate is null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing PUB Date'+ @v_bsg_msg,@i_username, getdate() )
	set @v_varnings = 1
end 
end
end

--check for on sale date 
select @v_datatypecode = datetypecode
from datetype 
where qsicode = 2;

select @v_bestdate = bestdate
from bookdates
where bookkey = @i_bookkey
and datetypecode = @v_datatypecode
and printingkey = @i_printingkey
exec bookverification_check 'On Sale Date', @i_write_msg output
if @i_write_msg = 1 begin
if @v_bestdate is null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Information, 'Missing On Sale Date'+ @v_bsg_msg,@i_username, getdate() )
end 
end

--check Total vol in Series
select @v_numericdesc1 = numericdesc1  
from gentables where tableid = 327 
and datacode in( select seriescode
from bookdetail
where bookkey = @i_bookkey)

exec bookverification_check 'Total vol in Series', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(4) begin
	if @v_numericdesc1 is null  begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Total vol in Series'+ @v_g_msg,@i_username, getdate() )
		set @v_varnings = 1
	end 
end
end

--check for Carton Qty/Case Pack
select @v_cartonqty1 = cartonqty1
from bindingspecs
where bookkey = @i_bookkey
and printingkey = @i_printingkey

exec bookverification_check 'Carton Qty/Case Pack', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(3) begin
if @v_cartonqty1 is Null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Carton Qty/Case Pack'+ @v_bsg_msg,@i_username, getdate() )
	set @v_failed = 1
end
end 
if @i_verificationtypecode in(2,4) begin
if @v_cartonqty1 is Null begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Carton Qty/Case Pack'+ @v_bsg_msg,@i_username, getdate() )
	set @v_varnings = 1
end
end 
end

--check for trimsizelength, esttrimsizelength, trimsizewidth, esttrimsizewidth
select @v_tmmactualtrimsizelength = ltrim(rtrim(tmmactualtrimlength)), @v_tmmactualtrimsizewidth = ltrim(rtrim(tmmactualtrimwidth)),
       @v_esttrimsizelength = ltrim(rtrim(esttrimsizelength)), @v_esttrimsizewidth = ltrim(rtrim(esttrimsizewidth)),
       @v_trimsizelength = ltrim(rtrim(trimsizelength)), @v_trimsizewidth = ltrim(rtrim(trimsizewidth)),
       @v_spinesize = ltrim(rtrim(spinesize)), @v_barcodeid1 = barcodeid1, @v_barcodeposition1 = barcodeposition1, 
       @v_barcodeid2 = barcodeid2, @v_barcodeposition2 = barcodeposition2
from printing
where bookkey = @i_bookkey
and printingkey = @i_printingkey
if @i_verificationtypecode in(3) begin
	exec bookverification_check 'Height', @i_write_msg output
	if @i_write_msg = 1 begin
	if @v_trimsizelength is null or @v_trimsizelength = '' begin
		if  @v_esttrimsizelength is null or @v_esttrimsizelength = '' begin 
			if @v_tmmactualtrimsizelength is null or @v_tmmactualtrimsizelength = '' begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Height'+ @v_bsg_msg,@i_username, getdate() )
				set @v_failed = 1
			end
		end
	end
	end
	exec bookverification_check 'Width', @i_write_msg output
	if @i_write_msg = 1 begin
	if @v_trimsizewidth is null or @v_trimsizewidth = '' begin
		if  @v_esttrimsizewidth is null or @v_esttrimsizewidth = '' begin 
			if @v_tmmactualtrimsizewidth is null or @v_tmmactualtrimsizewidth = '' begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Width'+ @v_bsg_msg,@i_username, getdate() )
				set @v_failed = 1
			end
		end
	end 
	end
end
exec bookverification_check 'Depth (spine size)', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(4) begin
	if @v_spinesize is null or @v_spinesize = '' begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Depth (spine size)'+ @v_g_msg,@i_username, getdate() )
		set @v_failed = 1
	end 
end
end

exec bookverification_check 'Bar Code Indicator', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(3) begin
	if @v_barcodeid1 is null and @v_barcodeposition1 is null and @v_barcodeid2 is null and @v_barcodeposition2 is null begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Bar Code Indicator',@i_username, getdate() )
		set @v_failed = 1
	end
end
end

--check for bookweight
--select @v_bookweight = bookweight 
---from booksimon
--where bookkey = @i_bookkey
select @v_bookweight = bookweight 
from printing
where bookkey = @i_bookkey

exec bookverification_check 'Weight', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(4) begin
	if @v_bookweight is null  begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Weight'+ @v_g_msg,@i_username, getdate() )
		set @v_failed = 1
	end 
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
if @v_eloquencefieldtag in('B') begin
	if @v_tentativepagecount is null and  @v_pagecount is null and @v_tmmpagecount is null begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Page Cnt'+ @v_g_msg,@i_username, getdate() )
		set @v_varnings = 1
	end 
end
end

--check fo Totalruntime
select @v_totalruntime = ltrim(rtrim(totalruntime))
from audiocassettespecs
where bookkey = @i_bookkey
and printingkey = @i_printingkey

--error if audio or visual
exec bookverification_check 'Running Time', @i_write_msg output
if @i_write_msg = 1 begin
if @v_eloquencefieldtag in('A', 'D', 'F', 'V') begin
	if @v_totalruntime is null begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Running Time',@i_username, getdate() )
		set @v_failed = 1
	end 
end
end
--check for Bisac Subject 1
select @v_cnt = count(bookkey)
from bookbisaccategory
where bookkey = @i_bookkey
and printingkey = @i_printingkey

exec bookverification_check 'BISAC Subject 1', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(3) begin
if @v_cnt = 0 begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing BISAC Subject 1'+ @v_bsg_msg,@i_username, getdate() )
	set @v_failed = 1
end 
end
if @i_verificationtypecode in(2,4) begin
if @v_cnt = 0 begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing BISAC Subject 1'+ @v_bsg_msg,@i_username, getdate() )
	set @v_varnings = 1
end 
end
end

--price
select @v_pricevalidation_group = pricevalidationgroupcode
  from bookdetail
 where bookkey = @i_bookkey

IF @v_pricevalidation_group IS NULL OR ltrim(rtrim(@v_pricevalidation_group)) = ' ' BEGIN
	exec qtitle_set_price_validation_group @i_bookkey,@v_error_code output, @v_err_desc output
	select @v_pricevalidation_group = pricevalidationgroupcode
	 from bookdetail
	where bookkey = @i_bookkey
END

set @v_cnt = 0
    
select @v_cnt = count(*)
 from bookprice 
 where bookkey = @i_bookkey	
   and activeind = 1
 
exec bookverification_check 'Price', @i_write_msg output
if @i_write_msg = 1 begin
	if @v_cnt = 0  begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Active Price'+ @v_bsg_msg,@i_username, getdate() )
		set @v_failed = 1
	end
end

-- Allow any price to be zero
if @v_cnt > 0 begin
  if @v_pricevalidation_group = 1 begin
	  set @v_cnt3 = 0
    set @v_cnt2 = 0

	  select @v_cnt3 = count(*)
		  from bookprice 
		  where bookkey = @i_bookkey	
            and (finalprice = 0 OR budgetprice = 0 OR finalprice IS NULL OR budgetprice IS NULL)
            and activeind = 1

	  IF @v_cnt3 = 0 
      BEGIN
		  select @v_cnt2 = count(*)
		  from bookprice 
		  where bookkey = @i_bookkey	
            and (finalprice > 0 OR budgetprice > 0)
            and activeind = 1
      END
      
     IF @v_cnt2 = 0 BEGIN
		  exec bookverification_check 'Price', @i_write_msg output
		  if @i_write_msg = 1 begin
			  if @v_cnt = 0  begin
				  exec get_next_key @i_username, @v_nextkey out
				  insert into bookverificationmessage
				  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Acive Price'+ @v_bsg_msg,@i_username, getdate() )
				  set @v_failed = 1
			  end
		  end
	  END
  end

  -- 2 Do not allow zero prices
  IF @v_pricevalidation_group = 2 begin
	  set @v_cnt = 0
  	
	  select @v_cnt = count(*)
	  from bookprice 
	  where bookkey = @i_bookkey
	  and (finalprice > 0 or budgetprice > 0)
    and activeind = 1
      
	  exec bookverification_check 'Price', @i_write_msg output
	  if @i_write_msg = 1 begin
	  if @v_cnt = 0  begin
		  exec get_next_key @i_username, @v_nextkey out
		  insert into bookverificationmessage
		  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Active Price'+ @v_bsg_msg,@i_username, getdate() )
		  set @v_failed = 1
	  end
	  end
  END

  -- 3  - Only allow Price Types with * to be zero
  IF @v_pricevalidation_group = 3
  BEGIN
	  set @v_cnt = 0
    set @v_cnt2 = 0
	  set @v_cnt3 = 0

	  select @v_cnt3 = count(*)
		  from bookprice 
	   where bookkey = @i_bookkey
	     and (finalprice > 0 or budgetprice > 0)
       and activeind = 1

	  IF @v_cnt3 = 0 begin
		  -- check if pricetypes that cannot be zero exist for bookkey with zero or null prices
		  SELECT @v_cnt = count(*)
		    FROM bookprice  p
		     LEFT OUTER JOIN gentables g1 ON p.pricetypecode = g1.datacode AND g1.tableid = 306
		    WHERE bookkey = @i_bookkey
			  AND ((finalprice = 0 or finalprice is null)  AND (budgetprice =  0 or budgetprice is null))
			  AND gen2ind = 0
        and p.activeind = 1

		  IF @v_cnt > 0 begin
			  SELECT @v_cnt2 = 0
			  -- row with pricetype that allow prices to be zeros should exist with a zero price for budget or final price
			  SELECT @v_cnt2 = count(*)
			    FROM bookprice  p
			     LEFT OUTER JOIN gentables g1 ON p.pricetypecode = g1.datacode AND g1.tableid = 306
			    WHERE bookkey = @i_bookkey
				   AND ((finalprice is not null)  OR (budgetprice is not null))
			 	   AND gen2ind = 1
           and p.activeind = 1

			  IF @v_cnt2 = 0 BEGIN
				  exec bookverification_check 'Price', @i_write_msg output
				  if @i_write_msg = 1 begin
					  exec get_next_key @i_username, @v_nextkey out
					  insert into bookverificationmessage
					  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Active Price' + @v_bsg_msg,@i_username, getdate() )
					  set @v_failed = 1
				  end
			  END
		  END
      ELSE BEGIN
        SELECT @v_cnt2 = 0
			  -- row with pricetype that allow prices to be zeros should exist with a zero price for budget or final price
			  SELECT @v_cnt2 = count(*)
			    FROM bookprice  p
			     LEFT OUTER JOIN gentables g1 ON p.pricetypecode = g1.datacode AND g1.tableid = 306
			    WHERE bookkey = @i_bookkey
				   AND ((finalprice is not null)  OR (budgetprice is not null))
			 	   AND gen2ind = 1
           and p.activeind = 1

			  IF @v_cnt2 = 0 BEGIN
				  exec bookverification_check 'Price', @i_write_msg output
				  if @i_write_msg = 1 begin
					  exec get_next_key @i_username, @v_nextkey out
					  insert into bookverificationmessage
					  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Active Price' + @v_bsg_msg,@i_username, getdate() )
					  set @v_failed = 1
				  end
			  END
      END
	  END
  END 

end



--currency
select @v_cnt = count(currencytypecode)
from bookprice 
where bookkey = @i_bookkey
and currencytypecode is not null

exec bookverification_check 'Price Type', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(1) begin
	if @v_cnt = 0 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Price Type'+ @v_bsg_msg,@i_username, getdate() )
		set @v_failed = 1
	end
end
end

--currency Canadian
select @v_cnt = count(currencytypecode)
from bookprice 
where bookkey = @i_bookkey
and currencytypecode = 11

exec bookverification_check 'Canadian Price', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(4) begin
	if @v_cnt = 0 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Canadian Price'+ @v_bsg_msg,@i_username, getdate() )
		set @v_failed = 1
	end
end
end

--Territorial Rights, ELO customer
select @v_territoriescode = territoriescode, @v_elocustomerkey = elocustomerkey  
from book
where bookkey = @i_bookkey

exec bookverification_check 'Territorial Rights', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(3) begin
	if @v_territoriescode is null begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Information, 'Missing Territorial Rights',@i_username, getdate() )
	end 
end
end

exec bookverification_check 'ELO Customer', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode = 2 begin
	if @v_elocustomerkey is null begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Eloquence Customer',@i_username, getdate() )
		set @v_failed = 1
	end 
end
end

--bookaudience
select @v_cnt = count(bookkey)
from bookaudience
where bookkey = @i_bookkey

exec bookverification_check 'Audience', @i_write_msg output
if @i_write_msg = 1 begin
if @i_verificationtypecode in(3) begin
	if @v_cnt = 0 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Audience'+ @v_bsg_msg,@i_username, getdate() )
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
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Publisher'+ @v_bsg_msg,@i_username, getdate() )
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
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Imprint' + @v_bsg_msg,@i_username, getdate() )
	set @v_varnings = 1
end
end

-- Replaces/Replaced By
select @v_editionnumber = editionnumber 
from bookdetail
where bookkey = @i_bookkey

exec bookverification_check 'Replaces/Replaced By, edition # is 2 or higher', @i_write_msg output
if @i_write_msg = 1 begin
if @v_editionnumber > 1 begin
if @i_verificationtypecode in(3) begin
	select @v_cnt = count(bookkey)
	from associatedtitles
	where bookkey = @i_bookkey
	and 
	((associationtypecode = 4 and associationtypesubcode = 3)
	or
	(associationtypecode = 4 and associationtypesubcode = 4))
  	if @v_cnt = 0 begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Replaces/Replaced By, edition # is 2 or higher' ,@i_username, getdate() )
		set @v_failed = 1

       end 
end
end
end

--expected ship date
select @v_subgen1ind = subgen1ind
from subgentables
where datacode in (select bisacstatuscode
		   from bookdetail
	           where bookkey = @i_bookkey)
and datasubcode in (select prodavailability
		    from bookdetail
		    where bookkey = @i_bookkey)
and tableid = 314



exec bookverification_check 'Expected Ship Date', @i_write_msg output
if @i_write_msg = 1 begin
if @v_subgen1ind = 1 begin
	SELECT @v_active_date = bookdates.activedate
	FROM bookdates  
	WHERE  bookdates.bookkey = @i_bookkey  AND  
	       bookdates.printingkey = @i_printingkey  AND  
	       datetypecode in( select datetypecode 
				from datetype  
				where qsicode = 9 )
	if @v_active_date is null begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Expected Ship Date ',@i_username, getdate() )
		set @v_varnings = 1
	end
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


--passed with warnings

select @v_datacode = datacode
from gentables 
where tableid = 513
and qsicode = 4

if @v_failed = 0 and @v_varnings = 1 begin
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

if @v_failed = 0 and @v_varnings = 0 begin
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

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



GRANT EXEC ON dbo.verify_eloquence TO PUBLIC
GO