/****** Object:  StoredProcedure [dbo].[pers_verification_ebook]    Script Date: 05/17/2011 15:28:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pers_verification_ebook]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pers_verification_ebook]

/******************************************************************************
**  Name: pers_verification_ebook
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  02/11/2016   Colman	     Case 36337
*******************************************************************************/

/****** Object:  StoredProcedure [dbo].[pers_verification_ebook]    Script Date: 05/17/2011 15:27:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create       PROCEDURE [dbo].[pers_verification_ebook]
		     @i_bookkey int,
		     @i_printingkey int,
		     @i_verificationtypecode int,
		     @i_username varchar(15)

AS
BEGIN
/* 


*/

DECLARE 
@v_datacode int,
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
@eb_pubdate datetime,
@v_languagecode int,
@v_languagecode2 int,
@v_tentativepagecount int, 
@v_pagecount int, 
@v_tmmpagecount int,
@v_eloquencefieldtag varchar(25),
@v_nextkey int,
@v_warnings int,
@v_failed int,
@v_isbn13 varchar(13),
@v_bisac_status_code int,
@i_write_msg int,
@minpricetype int,
@counter int,
@digitalonly	int,
@i_numcount int,
@i_rowcount int,
@c_pricedesc nvarchar(120),
@csapproval	int,
@releasetype	varchar(255),
@assocbookkey	int,
@assocelo		int,
@numrows		int,
@count		int,
@currency	varchar(255),
@mincurr	int,
@hardcover	int,
@print_pubdate	datetime,
@partnerdates	int,
--@kobo	int,
--@nonkobo	int,
@apple	int,
@mediaelotag	varchar(20),
@formatelotag	varchar(20),
@minpricetag	varchar(20),
@elocustomer	varchar(10)

-- init variables
set @v_Error = 2
set @v_Warning = 3
set @v_Information = 4
set @v_Aborted = 5
set @v_Completed = 6
set @v_failed = 0 
set @v_warnings = 0 

--confirm title will potentially be sent to content services before running this routine
--load data from bookdetail table
select @v_mediatypecode = mediatypecode, @v_mediatypesubcode = mediatypesubcode,
@v_languagecode = languagecode, @v_languagecode2 = languagecode2, 
@v_bisac_status_code = bisacstatuscode
from bookdetail
where bookkey = @i_bookkey

select @elocustomer = eloqcustomerid
from book b
join customer c
on b.elocustomerkey = c.customerkey

select @mediaelotag = eloquencefieldtag
from gentables
where tableid = 312
and datacode = @v_mediatypecode

select @formatelotag = eloquencefieldtag
from subgentables
where tableid = 312
and datacode = @v_mediatypecode
and datasubcode = @v_mediatypesubcode

select @i_numcount = count(*)
from cs_formatverification
where mediaelotag = @mediaelotag
and eloqcustomerid = @elocustomer

if @mediaelotag <> 'EP'
	set @i_numcount = 0

if isnull(@i_numcount,0) = 0		--this title is not of a media type being sent to content services, so don't write this verification row
begin
	update bookverification
	set titleverifystatuscode = 14,		--not applicable
       lastmaintdate = getdate(),
       lastuserid = @i_username
	where bookkey = @i_bookkey
	and verificationtypecode = @i_verificationtypecode

	return
end

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

----content services approval
--select @csapproval = isnull(csapprovalcode,0)
--from bookdetail bd
--where bookkey = @i_bookkey
--
--if @csapproval <> 1
--begin
--	exec get_next_key @i_username, @v_nextkey out
--	insert into bookverificationmessage
--	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Title not approved for Content Services',@i_username, getdate() )
--	set @v_failed = 1
--end

--status
exec bookverification_check 'BISAC Status Code', @i_write_msg output
if @i_write_msg = 1 begin
	if @v_bisac_status_code is null  begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing BISAC Status Code',@i_username, getdate() )
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

--error if is book/ebook
exec bookverification_check 'Page Cnt', @i_write_msg output
if @i_write_msg = 1 begin
	if @v_eloquencefieldtag in('EP') begin
		if @v_tentativepagecount is null and  @v_pagecount is null and @v_tmmpagecount is null begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Page Cnt',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end

-- error - elo 5 error - missing media
exec bookverification_check 'Book Media', @i_write_msg output
if @i_write_msg = 1 begin
	if @v_mediatypecode is null begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Media',@i_username, getdate() )
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
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Eloquence Field tag or export to eloquence indicator for Media',@i_username, getdate() )
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
    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Format',@i_username, getdate() )
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
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Eloquence Field tag or export to eloquence indicator for Format',@i_username, getdate() )
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
    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Title' ,@i_username, getdate() )
		set @v_failed = 1
	end 
end

if @v_title like '%</%'
begin 
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Title has invalid html coding (<></> not valid)' ,@i_username, getdate() )
	set @v_failed = 1
end

if @v_subtitle like '%</%'
begin 
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Subtitle has invalid html coding (<></> not valid)' ,@i_username, getdate() )
	set @v_failed = 1
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
    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Primary Author',@i_username, getdate() )
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
		and primaryind = 1
		and authortypecode in (select datacode from gentables where tableid = 134 and eloquencefieldtag is not null)
		
		if @v_cnt = 0 begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Eloquence Field tag or export to eloquence indicator for Author',@i_username, getdate() )
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
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
		  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing ISBN',@i_username, getdate() )
		  set @v_failed = 1
	   end 
	end
end

exec bookverification_check 'ISBN10', @i_write_msg output
if @i_write_msg = 1 begin
	if @v_isbn10 is null or @v_isbn10 = '' begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Information, 'Missing ISBN10',@i_username, getdate() )
		set @v_failed = 1
	end 
end

if @i_verificationtypecode <>0 begin
	exec bookverification_check 'EAN13', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_ean13 is null or @v_ean13 = '' begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing EAN13',@i_username, getdate() )
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
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing EAN',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end

--error - check for pub date 
select @eb_pubdate = bestdate
from bookdates
where bookkey = @i_bookkey
and datetypecode = 8
and printingkey = @i_printingkey

if @eb_pubdate is null
begin
	select @eb_pubdate = bestdate
	from bookdates
	where bookkey = @i_bookkey
	and datetypecode = 20003
	and printingkey = @i_printingkey
end

exec bookverification_check 'PUB Date', @i_write_msg output
if @i_write_msg = 1 begin
	if @i_verificationtypecode <> 0 begin
		if @eb_pubdate is null begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing PUB Date and/or On Sale Date',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end

if @eb_pubdate <getdate() and @v_bisac_status_code = 4 begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_error, 'PUB/On Sale Date passed, status still Forthcoming (NYP)',@i_username, getdate() )
	set @v_failed = 1
end 

if @eb_pubdate >getdate()+10 and @v_bisac_status_code = 1 begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_error, 'PUB/On Sale Date in future, status is Active',@i_username, getdate() )
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
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing BISAC Subject 1',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end

--Long or Brief Description
select  @i_write_msg = 1
select @v_cnt = count(bookkey)
from bookcomments bc
join subgentables sg
on bc.commenttypecode = sg.datacode
and bc.commenttypesubcode = sg.datasubcode
and sg.tableid = 284
and eloquencefieldtag in ('D' ,'BD')
and deletestatus='N' 
and exporteloquenceind=1
where bookkey = @i_bookkey 
and commenthtml is not null
and releasetoeloquenceind=1 

if @i_write_msg = 1 begin
	if @i_verificationtypecode <>0 begin
		if @v_cnt = 0 begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Long and/or Brief Description is missing or Release to Eloquence not checked',@i_username, getdate() )
			set @v_failed = 1
		end
	end
end

--language
if isnull(@v_languagecode,0) = 0 and isnull(@v_languagecode2,0) = 0 begin
  exec get_next_key @i_username, @v_nextkey out
  insert into bookverificationmessage
  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Language',@i_username, getdate() )
  set @v_failed = 1
end 

select @Apple = sum(case when dt.eloquencefieldtag = 'ONIX-AP' then 1 else 0 end), @partnerdates = count(*)
--,@Kobo = sum(case when dt.eloquencefieldtag = 'ONIX-KO' then 1 else 0 end), @nonKobo = sum(case when dt.eloquencefieldtag <> 'ONIX-KO' then 1 else 0 end)
from bookdates bd
join datetype dt
on bd.datetypecode = dt.datetypecode
where bd.bookkey = @i_bookkey
and dt.eloquencefieldtag like 'ONIX%'
and dt.exporteloquenceind = 1

--price
set @i_rowcount =0

select @i_rowcount = count(*) , @minpricetag = min(priceelotag)
from CS_formatverification cs  
where cs.mediaelotag = @mediaelotag
and cs.formatelotag = @formatelotag
and eloqcustomerid = @elocustomer

set @counter = 1
exec bookverification_check 'Price', @i_write_msg output

while @counter <= @i_rowcount
BEGIN -- 1
	if @minpricetag <> 'AGY' or isnull(@apple,0) > 0	
	begin
		--if agency price and title not being sent to apple, not an error, so don't bother checking
		select @v_cnt = count(*)
		from bookprice bp
		join gentables g
		on bp.pricetypecode = g.datacode
		and g.tableid = 306
		and eloquencefieldtag is not null and eloquencefieldtag <> '' 
		and eloquencefieldtag not in ('NA','N/A')  
		and exporteloquenceind=1  
		and deletestatus='n'
		where bookkey = @i_bookkey 
		and g.eloquencefieldtag = @minpricetag 
		and bp.activeind = 1
		and (finalprice > 0 or budgetprice > 0) 

		select @c_pricedesc = datadesc
		from gentables
		where tableid = 306
		and eloquencefieldtag = @minpricetag

		if @i_write_msg = 1  
		BEGIN  --4
			if isnull(@v_cnt,0) = 0  
			BEGIN  --5
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
        (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing '+ isnull(@c_pricedesc,''),@i_username, getdate() )
				set @v_failed = 1
			END --5
		END --4
	end

	select @minpricetag = min(priceelotag)
	from CS_formatverification cs  
	where cs.mediaelotag = @mediaelotag
	and cs.formatelotag = @formatelotag
	and eloqcustomerid = @elocustomer
	and cs.priceelotag > @minpricetag

	set @counter = @counter + 1
END 

--related product
--select @printisbnrequired = max(printisbnrequiredind)
--from CS_formatverification cs  
--where cs.mediaelotag = @mediaelotag
--and cs.formatelotag = @formatelotag
--and eloqcustomerid = @elocustomer

select @releasetype = isnull(sg.datadesc,'')
from bookmisc bm
join bookmiscitems bmi
on bm.misckey = bmi.misckey
join gentables g
on bmi.eloquencefieldidcode = g.datacode
and g.tableid = 560
and g.eloquencefieldtag = 'DPIDXBIZRLSTYPE'
join subgentables sg
on sg.tableid = 525
and bmi.datacode = sg.datacode
and bm.longvalue = sg.datasubcode
where bm.bookkey = @i_bookkey

if (isnull(@releasetype,'') <> 'digital-only') and (isnull(@apple,0) > 0)
begin	--apple and not digital only
	select @assocbookkey = at.associatetitlebookkey
	from associatedtitles at
	join subgentables sg
	on sg.tableid = 440
	and at.associationtypecode = sg.datacode
	and at.associationtypesubcode = sg.datasubcode
	and sg.eloquencefieldtag in (13, 15)
	where bookkey = @i_bookkey 
	and len(at.isbn) in (13,17)
	and at.isbn is not null
	and at.associatetitlebookkey <> 0

	if isnull(@assocbookkey,0) = 0 
	begin		--no assocbookkey
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Supply Chain data for Print ISBN',@i_username, getdate() )
		set @v_failed = 1
	end
	else
	begin		--valid assocbookkey
		--is print title being sent/been sent to eloquence?
		select @assocelo = count(*)
		from bookedistatus be
		join gentables g
		on be.edistatuscode = g.datacode
		and g.tableid = 325
		join book b
		on be.bookkey = b.bookkey
		where edistatuscode in (1,2,3,4)
		and sendtoeloind = 1
		and be.bookkey = @assocbookkey

		if isnull(@assocelo,0) = 0 begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Print ISBN is not in outbox and has not been sent to eloquence',@i_username, getdate() )
			set @v_failed = 1
		end

		--does print title have all valid prices and currencies?
		select @numrows = count(*)
		from bookprice bpe
		left outer join bookprice bpp
		on bpe.currencytypecode = bpp.currencytypecode
		and bpp.bookkey = @assocbookkey					--print
		and bpp.pricetypecode = 11						--print has list price
		and bpp.activeind = 1
		where bpe.bookkey = @i_bookkey						--ebook
		and bpe.pricetypecode = 9						--ebook has agency price
		and bpp.bookkey is null
		and bpe.activeind = 1

		--if no rows, success - print title has all of the same currencies that the ebook has
		if isnull(@numrows,0) > 0
		begin
			--if rows are missing, have to loop through to find missings on ebook as apple print price.  If not on either, write out message for currency
			set @numrows = 0
			set @mincurr = 0

			select @numrows = count(*), @mincurr = min(bpe.currencytypecode)
			from bookprice bpe
			left outer join bookprice bpp
			on bpe.currencytypecode = bpp.currencytypecode
			and bpp.bookkey = @assocbookkey					--print
			and bpp.pricetypecode = 11						--print has list price
			and bpp.activeind = 1
			where bpe.bookkey = @i_bookkey						--ebook
			and bpe.pricetypecode = 9						--ebook has agency price
			and bpp.bookkey is null
			and bpe.activeind = 1

			set @counter = 1

			while @counter <= @numrows
			begin
				--see if ebook has that currency for Apple Print Price
				select @count = count(*)
				from bookprice
				where bookkey = @i_bookkey
				and pricetypecode = 14
				and activeind = 1
				and currencytypecode = @mincurr

				if isnull(@count,0) = 0
				begin
					select @currency = datadesc
					from gentables
					where tableid = 122
					and datacode = @mincurr
					
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'No print price for '+@currency+ ' on related Print title or Apple Print Price on ebook',@i_username, getdate() )
					set @v_failed = 1
				end

				select @mincurr = min(bpe.currencytypecode)
				from bookprice bpe
				left outer join bookprice bpp
				on bpe.currencytypecode = bpp.currencytypecode
				and bpe.bookkey = @i_bookkey						--ebook
				and bpp.bookkey = @assocbookkey					--print
				and bpe.pricetypecode = 9						--ebook has agency price
				and bpp.pricetypecode = 11						--print has list price
				and bpp.activeind = 1
				where bpp.bookkey is null
				and bpe.currencytypecode > @mincurr

				set @counter = @counter + 1
			end
		end

		--is release type correct based on print title format & pubdate?
		select @hardcover = count(*)
		from bookdetail bd
		join subgentables sg
		on bd.mediatypecode = sg.datacode
		and bd.mediatypesubcode = sg.datasubcode
		and tableid = 312
		where bd.bookkey = @assocbookkey
		and eloquencefieldtag = 'TC'
		
		select @print_pubdate = bestdate
		from bookdates
		where datetypecode = 8
		and bookkey = @assocbookkey

		if (@hardcover = 1 and (datediff(day, @print_pubdate, getdate()) < 214)) or (@hardcover = 0 and (datediff(day, @print_pubdate, getdate()) < 365))
		begin
			if @releasetype = 'other'
			begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
        (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Release type should be new-release',@i_username, getdate() )
				set @v_failed = 1
			end
		end
		else if @releasetype = 'new-release'
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Release type should be other',@i_username, getdate() )
			set @v_failed = 1
		end
	end		--valid assocbookkey
end		--apple and not digital only

--if isnull(@kobo,0) > 0
--begin
--	set @count = 0
--
--	select @count = count(*)
--	from bookdetail
--	where bookkey = @i_bookkey	
--	and canadianrestrictioncode is not null
--
--	if isnull(@count,0) = 0
--	begin
--		exec get_next_key @i_username, @v_nextkey out
--		insert into bookverificationmessage
--		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Titles going to Kobo require Sales Restriction',@i_username, getdate() )
--		set @v_failed = 1
--	end
--end

set @count = 0
--if isnull(@nonKobo,0) > 0
begin
	select @count = count(*)
	from bookcomments bc
	join subgentables sg
	on sg.datacode = bc.commenttypecode
	and sg.datasubcode = bc.commenttypesubcode
	and tableid = 284
	and eloquencefieldtag = 'sales'
	where bc.bookkey = @i_bookkey 
	and commenttext is not null
	and releasetoeloquenceind = 1

	if isnull(@count,0) = 0
	begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Sales Rights comment',@i_username, getdate() )
		set @v_failed = 1
	end
end

if isnull(@partnerdates,0) = 0
begin
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage
	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'No Partner specific dates have been added to this title or are marked to be released to eloquence',@i_username, getdate() )
	set @v_failed = 1
end

----product availability
--exec bookverification_check 'Product Availability code', @i_write_msg output
--if @i_write_msg = 1 begin
--	if @v_prodavailability is null  begin
--		exec get_next_key @i_username, @v_nextkey out
--		insert into bookverificationmessage
--		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Product Availability code',@i_username, getdate() )
--		set @v_failed = 1
--	end 
--end


--error - territories

--select @v_territoriescode = territoriescode
--from book
--where bookkey = @i_bookkey and territoriescode in (select datacode from gentables where tableid = 131 and deletestatus ='N')
--select @i_write_msg = 1
--if @i_write_msg = 1 begin
--if @v_territoriescode is null or  @v_territoriescode = 0  begin
--	exec get_next_key @i_username, @v_nextkey out
--	insert into bookverificationmessage
--	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing or Inactive Sales Territories information' ,@i_username, getdate() )
--	set @v_failed = 1
--end 
--end
--
--select @v_territoriescode = territoriescode
--from book
--where bookkey = @i_bookkey and territoriescode in (select datacode from gentables where tableid = 131 
--	and eloquencefieldtag is not null and exporteloquenceind=1 and deletestatus ='N')
--
--if @i_write_msg = 1 begin
--if @v_territoriescode is null or  @v_territoriescode = 0  begin
--	exec get_next_key @i_username, @v_nextkey out
--	insert into bookverificationmessage
--	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Eloquence Field tag or export to eloquence indicator for Sales Territories' ,@i_username, getdate() )
--	set @v_failed = 1
--end 
--end
--error - missing discount code
--exec bookverification_check 'Discount Code', @i_write_msg output
--if @i_write_msg = 1 begin
--
--	if @v_discountcode is null and @v_mediatypecode=2 begin
--		exec get_next_key @i_username, @v_nextkey out
--		insert into bookverificationmessage
--		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Discount Code',@i_username, getdate() )
--		set @v_failed = 1
--	end 
--end

----Publisher 
--select @v_cnt = count(bookkey)
--from bookorgentry
--where bookkey = @i_bookkey
--and orglevelkey in(select filterorglevelkey
--		from filterorglevel
--		where filterkey = 18)
--
--exec bookverification_check 'Publisher', @i_write_msg output
--if @i_write_msg = 1 begin
--if @v_cnt = 0 begin
--	exec get_next_key @i_username, @v_nextkey out
--	insert into bookverificationmessage
--	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Publisher',@i_username, getdate() )
--	set @v_failed = 1
--end
--end
--
----Imprint 
--select @v_cnt = count(bookkey)
--from bookorgentry
--where bookkey = @i_bookkey
--and orglevelkey in(select filterorglevelkey
--		from filterorglevel
--		where filterkey = 15)
--
--exec bookverification_check 'Imprint', @i_write_msg output
--if @i_write_msg = 1 begin
--if @v_cnt = 0 begin
--	exec get_next_key @i_username, @v_nextkey out
--	insert into bookverificationmessage
--	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Imprint' ,@i_username, getdate() )
--	set @v_failed = 1
--end
--end

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

end 


--passed with warnings
if @v_failed = 0 and @v_warnings = 1 begin
	select @v_datacode = datacode
	from gentables 
	where tableid = 513
	and qsicode = 4

	update bookverification
	set titleverifystatuscode = @v_datacode,
       lastmaintdate = getdate(),
       lastuserid = @i_username
 	where bookkey = @i_bookkey
	and verificationtypecode = @i_verificationtypecode

end 

--passed
if @v_failed = 0 and @v_warnings = 0 begin
	select @v_datacode = datacode
	from gentables 
	where tableid = 513
	and qsicode = 3

	update bookverification
	set titleverifystatuscode = @v_datacode,
       lastmaintdate = getdate(),
       lastuserid = @i_username
	where bookkey = @i_bookkey
	and verificationtypecode = @i_verificationtypecode

END

END
GO

grant EXEC on pers_verification_ebook to public
go