/****** Object:  StoredProcedure [dbo].[UNP_export_to_LLS_detail]    Script Date: 03/08/2010 11:02:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UNP_export_to_LLS_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[UNP_export_to_LLS_detail]
GO

/****** Object:  StoredProcedure [dbo].[UNP_export_to_LLS_detail]    Script Date: 03/08/2010 11:02:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[UNP_export_to_LLS_detail] 
	@i_bookkey int = 0, 
	@i_userid   varchar(30),
	@i_prevstart_datetime	datetime,
	@i_start_datetime	datetime,
	@i_jobtypecode int,
	@i_jobtypesubcode int,
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare     @v_error  INT,
@v_rowcount INT,
@whichgenfield	char(1), 
@bookkey int,
@counter int,
@numrows int,

@BOOK_CODE varchar(255),
@ABC_CODE varchar(255),
@ALLOWABLE_WHSE varchar(255),
@AUTHOR_CODE varchar(255),
@CASE_QTY varchar(255),
@COMPANY_NUMBER varchar(255),
@COPYRIGHT_DATE varchar(255),
@DISCOUNT_CODE varchar(255),
@DIVISION varchar(255),
@EDITOR_CODE varchar(255),
@EXPANDED_DESC varchar(255),
@FINAL_DATE  varchar(255),
@FIRST_DUE_DATE varchar(255),
@HANDLING varchar(255),
@HOLD_CODE varchar(255),
@INTEREST_CODES varchar(255),
@ISBN varchar(255),
@LIST_PRICES varchar(255),
@MAJOR_DISCIPLINE varchar(255),
@MEMO_PAD_COMMENTS varchar(255),
@MINOR_DISCIPLINE varchar(255),
@OUT_OF_PRINT_ZERO_QTY varchar(255),
@PRICE_CLASSES varchar(255),
@PRODUCT_TYPE varchar(255),
@PUBLICATION_DATE varchar(255),
@PUBLICATION_STATUS varchar(255),
@PUBLISHER varchar(255),
@RELATED_PRODUCTS varchar(255),
@RETAIL_PRICE varchar(255),
@REORDER_POINT varchar(255),
@RIGHTS_CODE varchar(255),
@ROYALTIES varchar(255),
@SERIES_CODE varchar(255),
@STANDING_ORDER_CODES varchar(255),
@SUBSTITUTION_CODE varchar(255),
@SUBTITLE varchar(255),
@TAXABLE varchar(255),
@TITLE varchar(255),
@WEB_SALEABLE varchar(255),
@WEIGHT varchar(255),
@WHSE_ACTION_LEVEL  varchar(255),
--BL 11/18/09 @PRODUCTION_COST varchar(255),
@PRODUCTION_COST float,
@TAX_EXEMPTIONS varchar(255),
@COMMISSION varchar(255),
@ebook	int,
@mediatype	int,
@format	int,
@discount_code_p varchar(255),
@discount_code_e varchar(255)
	

set @ebook = 0	

Select @mediatype = mediatypecode, @format = mediatypesubcode 
from bookdetail 
where bookkey = @i_bookkey

if @mediatype = 14 
	set @ebook = 1

--Set Defaults
-- jobtype 2,1 = new title feed
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1
begin
	if @ebook = 1
	begin
		Select @ALLOWABLE_WHSE = ''
		Select @HANDLING = 'N'
		Select @HOLD_CODE = 'N'
	end
	else begin
		Select @ALLOWABLE_WHSE = '01'
		Select @HANDLING = 'Y'
		Select @HOLD_CODE = 'Y'
	end
	Select @ABC_CODE = 'A'
	Select @COMPANY_NUMBER = '06'
	Select @DIVISION = '1'
	Select @PRICE_CLASSES = '1'
	Select @TAXABLE = 'Y'
end
	
Select @BOOK_CODE = ''
Select @CASE_QTY = ''
Select @COPYRIGHT_DATE = ''
Select @FINAL_DATE  = ''
Select @MEMO_PAD_COMMENTS =''
Select @RELATED_PRODUCTS = ''
Select @REORDER_POINT = ''
Select @STANDING_ORDER_CODES =''
Select @SUBSTITUTION_CODE = ''
Select @WEIGHT = ''
Select @WHSE_ACTION_LEVEL  = ''
Select @TAX_EXEMPTIONS = ''


-- @AUTHOR_CODE


If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	Select top 1 @AUTHOR_CODE = ISNULL(lastname,'') + ', ' + ISNULL(firstname,'') + ' ' + ISNULL(middlename,'')
	from bookauthor ba, author a
	where a.authorkey = ba.authorkey
	  and ba.bookkey = @i_bookkey
	  and ba.primaryind = 1 
end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select top 1 @AUTHOR_CODE = ISNULL(lastname,'') + ', ' + ISNULL(firstname,'') + ' ' + ISNULL(middlename,'')
	from bookauthor ba, author a
	where a.authorkey = ba.authorkey
	  and ba.bookkey = @i_bookkey
	  and ba.primaryind = 1 
	  and exists (Select * from titlehistory where titlehistory.bookkey = ba.bookkey and columnkey in (6,60) and lastmaintdate >= @i_prevstart_datetime)
end

-- @DISCOUNT_CODE
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	Select @DISCOUNT_CODE_P = g.alternatedesc2, @DISCOUNT_CODE_E = g.alternatedesc1
	from gentables g, bookdetail bd
	where bd.bookkey = @i_bookkey
	and bd.discountcode = g.datacode
	and g.tableid = 459

	if @ebook = 1
		set @DISCOUNT_CODE = @DISCOUNT_CODE_E
	ELSE
		set @DISCOUNT_CODE = @DISCOUNT_CODE_p
end
else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @DISCOUNT_CODE_P = g.alternatedesc2, @DISCOUNT_CODE_E = g.alternatedesc1
	from gentables g, bookdetail bd
	where bd.bookkey = @i_bookkey
	and bd.discountcode = g.datacode
	and g.tableid = 459
	and exists (Select * from titlehistory where titlehistory.bookkey = bd.bookkey and columnkey = 90 and lastmaintdate >= @i_prevstart_datetime)

	if @ebook = 1
		set @DISCOUNT_CODE = @DISCOUNT_CODE_E
	ELSE
		set @DISCOUNT_CODE = @DISCOUNT_CODE_P
end


--@EDITOR_CODE
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	Select top 1 @EDITOR_CODE = p.shortname
	from bookcontributor bc, person p
	where bc.bookkey = @i_bookkey
	and bc.contributorkey = p.contributorkey
	and bc.roletypecode = 18
end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select top 1 @EDITOR_CODE = p.shortname
	from bookcontributor bc, person p
	where bc.bookkey = @i_bookkey
	and bc.contributorkey = p.contributorkey
	and bc.roletypecode = 18
	and exists (Select * from titlehistory where titlehistory.bookkey = bc.bookkey and columnkey = 66 and currentstringvalue like '%Acquisition Editor%' and lastmaintdate >= @i_prevstart_datetime)
end

--@EXPANDED_DESC 
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	Select @EXPANDED_DESC = commenttext
	from bookcomments bc
	where bookkey = @i_bookkey
	and commenttypecode = 3
	and commenttypesubcode = 7
end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @EXPANDED_DESC = commenttext
	from bookcomments bc
	where bookkey = @i_bookkey
	and commenttypecode = 3
	and commenttypesubcode = 7
	and exists (Select * from titlehistory where titlehistory.bookkey = bc.bookkey and columnkey = 70 and fielddesc = '(E) Brief Description' and lastmaintdate >= @i_prevstart_datetime)
end

--@FIRST_DUE_DATE
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	Select @FIRST_DUE_DATE = CAST(datepart(mm,estdate) as varchar) + '/' + CAST(datepart(dd,estdate) as varchar) + '/' + CAST(datepart(yyyy,bestdate) as varchar)
	from bookdates bd
	where datetypecode = 47
	and bookkey = @i_bookkey
end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2 
begin
	Select @FIRST_DUE_DATE = CAST(datepart(mm,estdate) as varchar) + '/' + CAST(datepart(dd,estdate) as varchar) + '/' + CAST(datepart(yyyy,bestdate) as varchar)
	from bookdates bd
	where datetypecode = 47
	and bookkey = @i_bookkey
	and exists (Select * from datehistory where datehistory.bookkey = bd.bookkey and datetypecode = 47 and lastmaintdate >= @i_prevstart_datetime and datestagecode=2)
end


--@INTEREST_CODES
Select @INTEREST_CODES = ''

If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	Select @numrows = count(*)
	from booksubjectcategory bs, gentables g
	where bs.bookkey = @i_bookkey
	and categorytableid = 413
	and bs.categorytableid = g.tableid 
	and bs.categorycode = g.datacode
	and bs.sortorder > 1
end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2 
begin
	Select @numrows = count(*)
	from booksubjectcategory bs, gentables g
	where bs.bookkey = @i_bookkey
	and categorytableid = 413
	and bs.categorytableid = g.tableid 
	and bs.categorycode = g.datacode
	and bs.sortorder > 1
--	and bs.bookkey in (Select bookkey from booksubjectcategory where categorytableid = 413 and sortorder > 1 and lastmaintdate >= @i_Prevstart_datetime) --grab all interest codes if one has changed
	and bs.bookkey in (Select distinct b.bookkey from booksubjectcategory b join titlehistory t on b.bookkey = t.bookkey  
						join gentables g on g.tableid = 413 and (t.currentstringvalue = g.datadesc )
						where t.columnkey in (220, 221) and categorytableid = 413 and t.lastmaintdate > @i_Prevstart_datetime and printingkey = 1)
--	and (bs.lastmaintdate >= @i_prevstart_datetime
--	 or g.lastmaintdate >= @i_prevstart_datetime)
	 
end
	
Create table #tempinterestcodes (seqnum int identity(1,1), interestdatadescshort varchar(20))

insert into #tempinterestcodes (interestdatadescshort)
Select g.datadescshort 
from booksubjectcategory bs, gentables g
where bs.bookkey = @i_bookkey
and categorytableid = 413
and bs.categorytableid = g.tableid 
and bs.categorycode = g.datacode
and bs.sortorder > 1
and g.datadescshort is not null
order by bs.sortorder

Select @counter = 1

while @counter <= @numrows
begin

	Select @INTEREST_CODES = @INTEREST_CODES  + interestdatadescshort + '|'
	from #tempinterestcodes
	where seqnum = @counter

	set @counter = @counter + 1
end

drop table #tempinterestcodes

If len(@INTEREST_CODES) > 1 begin
	Select @INTEREST_CODES = Substring(@INTEREST_CODES,1,len(@INTEREST_CODES)-1)
end

--@ISBN
Select @ISBN = ean13
from isbn 
where bookkey = @i_bookkey

--@LIST_PRICES
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	Select @LIST_PRICES = finalprice
	from bookprice bp
	where bookkey = @i_bookkey
	and pricetypecode = 8
	and currencytypecode = 6
end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @LIST_PRICES = finalprice
	from bookprice bp
	where bookkey = @i_bookkey
	and pricetypecode = 8
	and currencytypecode = 6
	and exists (Select bookkey 
					from titlehistory 
					where titlehistory.bookkey = bp.bookkey 
					and  columnkey = 9 
					and currentstringvalue like '%USDL%' 
					and fielddesc like '%Retail%' 
					and  lastmaintdate > @i_prevstart_datetime)
end

--@MAJOR_DISCIPLINE
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	SELECT @MAJOR_DISCIPLINE =  s.datadescshort
	FROM bookmisc b, gentables g, subgentables s, bookmiscitems i
	WHERE g.tableid = 525 and
	g.tableid = s.tableid and
	g.datacode = s.datacode and
	g.datacode = i.datacode and
	s.datasubcode = b.longvalue and
	i.misctype = 5 and
	b.misckey = 34 and	
	i.misckey = 34 and	
	b.bookkey =  @i_bookkey

end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	SELECT @MAJOR_DISCIPLINE =  s.datadescshort
	FROM bookmisc b, gentables g, subgentables s, bookmiscitems i
	WHERE g.tableid = 525 and
	g.tableid = s.tableid and
	g.datacode = s.datacode and
	g.datacode = i.datacode and
	s.datasubcode = b.longvalue and
	i.misctype = 5 and
	b.misckey = 34 and	
	i.misckey = 34 and	
	b.bookkey =  @i_bookkey and
	exists (Select * from titlehistory where titlehistory.bookkey = b.bookkey and columnkey = 248 and fielddesc = 'Major Discipline' and lastmaintdate >= @i_prevstart_datetime)
end


--@MINOR_DISCIPLINE 
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	Select @MINOR_DISCIPLINE  = g.alternatedesc2
	from booksubjectcategory bs, gentables g
	where bs.bookkey = @i_bookkey
	and categorytableid = 413
	and bs.categorytableid = g.tableid 
	and bs.categorycode = g.datacode
	and bs.sortorder = 1

 end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @MINOR_DISCIPLINE  = g.alternatedesc2
	from booksubjectcategory bs, gentables g
	where bs.bookkey = @i_bookkey
	and categorytableid = 413
	and bs.categorytableid = g.tableid 
	and bs.categorycode = g.datacode
	and bs.sortorder = 1
--	and exists (Select * from titlehistory where titlehistory.bookkey = bs.bookkey and columnkey in (220,221) and fielddesc like '%Subject 4%' and lastmaintdate >= @i_prevstart_datetime)
	and bs.bookkey in (Select distinct b.bookkey from booksubjectcategory b join titlehistory t on b.bookkey = t.bookkey  
						join gentables g on g.tableid = 413 and (t.currentstringvalue = g.datadesc)
						where t.columnkey in (220, 221) and categorytableid = 413 and t.fielddesc like '%1%' and t.lastmaintdate > @i_Prevstart_datetime and printingkey = 1)
 
end

-- @OUT_OF_PRINT_ZERO_QTY - misc field
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1
begin
	Select @OUT_OF_PRINT_ZERO_QTY = CASE longvalue WHEN 2 THEN 'N' WHEN 1 THEN 'Y' ELSE '' END
	from bookmisc bm
	where bookkey = @i_bookkey
	and misckey = 73
end	
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @OUT_OF_PRINT_ZERO_QTY = CASE longvalue WHEN 2 THEN 'N' WHEN 1 THEN 'Y' ELSE '' END
	from bookmisc bm
	where bookkey = @i_bookkey
	and misckey = 73
	and exists (Select * from titlehistory where titlehistory.bookkey = bm.bookkey and columnkey = 248 and fielddesc = 'OP at Zero' and lastmaintdate >= @i_prevstart_datetime)
end

-- @PRODUCT_TYPE 
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	Select @PRODUCT_TYPE = s.datadescshort
	from bookdetail bd, gentables g, subgentables s
	where bd.bookkey = @i_bookkey
	and bd.mediatypecode = s.datacode
	and bd.mediatypesubcode = s.datasubcode
	and s.tableid = 312
    
end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @PRODUCT_TYPE = s.datadescshort
	from bookdetail bd, gentables g, subgentables s
	where bd.bookkey = @i_bookkey
	and bd.mediatypecode = s.datacode
	and bd.mediatypesubcode = s.datasubcode
	and s.tableid = 312
	and exists (Select bookkey from titlehistory where titlehistory.bookkey = bd.bookkey and columnkey = 11 and lastmaintdate >= @i_prevstart_datetime)


end

-- @PUBLICATION_DATE 
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	Select @PUBLICATION_DATE = CAST(datepart(mm,bestdate) as varchar) + '/' + CAST(datepart(dd,bestdate) as varchar) + '/' + CAST(datepart(yyyy,bestdate) as varchar)
	from bookdates bd
	where bookkey = @i_bookkey
	and datetypecode = 8

end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @PUBLICATION_DATE = CAST(datepart(mm,bestdate) as varchar) + '/' + CAST(datepart(dd,bestdate) as varchar) + '/' + CAST(datepart(yyyy,bestdate) as varchar)
	from bookdates bd
	where bookkey = @i_bookkey
	and datetypecode = 8
    and exists (Select * from datehistory where datehistory.bookkey = bd.bookkey and datetypecode = 8 and lastmaintdate >= @i_prevstart_datetime)
end


-- @PUBLICATION_STATUS 
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	Select @PUBLICATION_STATUS = g.alternatedesc2
	from bookdetail bd, gentables g
	where tableid = 314
	and bd.bisacstatuscode = g.datacode
	and bd.bookkey = @i_bookkey

end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @PUBLICATION_STATUS = g.alternatedesc2
	from bookdetail bd, gentables g
	where tableid = 314
	and bd.bisacstatuscode = g.datacode
	and bd.bookkey = @i_bookkey
	and exists (Select * from titlehistory where titlehistory.bookkey = bd.bookkey and columnkey = 4 and lastmaintdate >= @i_prevstart_datetime)	
end


-- @PUBLISHER
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	Select @PUBLISHER = o.orgentryshortdesc
	from bookorgentry bo, orgentry o
	where bo.bookkey = @i_bookkey
	and bo.orglevelkey = 3
	and bo.orgentrykey = o.orgentrykey
end
If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @PUBLISHER = o.orgentryshortdesc
	from bookorgentry bo, orgentry o
	where bo.bookkey = @i_bookkey
	and bo.orglevelkey = 3
	and bo.orgentrykey = o.orgentrykey
	and exists (Select * from titlehistory where titlehistory.bookkey = bo.bookkey and columnkey = 23 and fielddesc = 'Imprint' and lastmaintdate >= @i_prevstart_datetime)	
end

-- @RETAIL_PRICE
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 
begin
	Select @RETAIL_PRICE = finalprice
	from bookprice bp
	where bookkey = @i_bookkey
	and pricetypecode = 8
	and currencytypecode = 6
end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @RETAIL_PRICE = finalprice
	from bookprice bp
	where bookkey = @i_bookkey
	and pricetypecode = 8
	and currencytypecode = 6
	and lastmaintdate >= @i_prevstart_datetime
end

-- @RIGHTS_CODE
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1
begin
	Select @RIGHTS_CODE = g.datadesc
	from book b, gentables g 
	where b.bookkey = @i_bookkey
	and b.territoriescode = g.datacode
	and g.tableid = 131
end	
else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @RIGHTS_CODE = g.datadesc
	from book b, gentables g 
	where b.bookkey = @i_bookkey
	and b.territoriescode = g.datacode
	and g.tableid = 131
	and exists (Select * from titlehistory where titlehistory.bookkey = b.bookkey and columnkey = 55 and lastmaintdate >= @i_prevstart_datetime)	
end

--@ROYALTIES
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1
begin
	Select @ROYALTIES = CASE WHEN o.orgentryparentkey = 5 THEN 'N' ELSE 'Y' END
	from bookorgentry bo, orgentry o
	where bookkey = @i_bookkey
	and bo.orglevelkey = 3
	and bo.orgentrykey = o.orgentrykey
end	
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @ROYALTIES = CASE WHEN o.orgentryparentkey = 5 THEN 'N' ELSE 'Y' END
	from bookorgentry bo, orgentry o
	where bookkey = @i_bookkey
	and bo.orglevelkey = 3
	and bo.orgentrykey = o.orgentrykey
	and exists (Select * from titlehistory where titlehistory.bookkey = bo.bookkey and columnkey = 23 and fielddesc = 'Division' and lastmaintdate >= @i_prevstart_datetime)	
end

-- @SERIES_CODE 
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1
begin
	Select @SERIES_CODE = g.externalcode
	from bookdetail bd, gentables g
	where bd.bookkey = @i_bookkey
	and g.tableid = 327
	and bd.seriescode = g.datacode

end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @SERIES_CODE = g.externalcode
	from bookdetail bd, gentables g
	where bd.bookkey = @i_bookkey
	and g.tableid = 327
	and bd.seriescode = g.datacode
	and exists (Select * from titlehistory where titlehistory.bookkey = bd.bookkey and columnkey = 50 and lastmaintdate >= @i_prevstart_datetime)	
end

--@SUBTITLE 
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1
begin
	Select @SUBTITLE = UPPER(Substring(subtitle,1,80))
	from book b
	where bookkey = @i_bookkey

end	
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @SUBTITLE = UPPER(Substring(subtitle,1,80))
	from book b
	where bookkey = @i_bookkey
	and exists (Select * from titlehistory where titlehistory.bookkey = b.bookkey and columnkey = 3 and lastmaintdate >= @i_prevstart_datetime)	
end

--@TITLE
Select @TITLE = UPPER(shorttitle)
from book
where bookkey = @i_bookkey

--@WEB_SALEABLE
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1
begin
	Select @WEB_SALEABLE = CASE publishtowebind WHEN 0 THEN 'N' WHEN 1 THEN 'Y' ELSE '' END
	from bookdetail bd
	where bookkey = @i_bookkey

end	
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @WEB_SALEABLE = CASE publishtowebind WHEN 0 THEN 'N' WHEN 1 THEN 'Y' ELSE '' END
	from bookdetail bd
	where bookkey = @i_bookkey
	and exists (Select * from titlehistory where titlehistory.bookkey = bd.bookkey and columnkey = 84 and lastmaintdate >= @i_prevstart_datetime)	
end

--@PRODUCTION_COST
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1-- jobtype 2,1 = new title feed
begin
	If exists (Select * from bookmisc where bookkey = @i_bookkey and misckey = 35 and floatvalue is not null)
	begin
		Select @PRODUCTION_COST = floatvalue FROM   bookmisc bm
		WHERE  bookkey = @i_bookkey 
		and misckey = 35
	end
end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	If exists (Select * from bookmisc where bookkey = @i_bookkey and  misckey = 36 and floatvalue is not null)
	begin
		Select @PRODUCTION_COST = floatvalue FROM   bookmisc bm
		WHERE  bookkey = @i_bookkey 
		and misckey = 36
		and exists (Select * from titlehistory where titlehistory.bookkey = bm.bookkey and columnkey = 226 and fielddesc = 'Current Reprint Unit Cost est.' and lastmaintdate >= @i_prevstart_datetime)
	end
	Else If exists (Select * from bookmisc where bookkey = @i_bookkey and misckey = 35 and floatvalue is not null)
	begin
		Select @PRODUCTION_COST = floatvalue FROM   bookmisc bm
		WHERE  bookkey = @i_bookkey 
		and misckey = 35
		and exists (Select * from titlehistory where titlehistory.bookkey = bm.bookkey and columnkey = 226 and fielddesc = 'Original Unit Cost est.' and lastmaintdate >= @i_prevstart_datetime)
	end
end	 

--end
--Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2-- jobtype 2,2 = change feed
--begin
--	--BL 11/18/09 Select @PRODUCTION_COST = longvalue FROM   bookmisc bm
--	Select @PRODUCTION_COST = floatvalue FROM   bookmisc bm
--	WHERE  bookkey = @i_bookkey and
--	 misckey = 36
--	and exists (Select * from titlehistory where titlehistory.bookkey = bm.bookkey and columnkey = 226 and fielddesc = 'Original Unit Cost est.' and lastmaintdate >= @i_prevstart_datetime)
--end

--@COMMISSION
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1
begin
	Select @COMMISSION = s.datadescshort
	FROM bookmisc b, gentables g, subgentables s, bookmiscitems i
	WHERE g.tableid = 525 and
	g.tableid = s.tableid and
	g.datacode = s.datacode and
	g.datacode = i.datacode and
	s.datasubcode = b.longvalue and
	i.misctype = 5 and
	b.misckey = 37 and	
	i.misckey = 37 and	
	b.bookkey =  @i_bookkey 

end
Else If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	Select @COMMISSION = s.datadescshort
	FROM bookmisc b, gentables g, subgentables s, bookmiscitems i
	WHERE g.tableid = 525 and
	g.tableid = s.tableid and
	g.datacode = s.datacode and
	g.datacode = i.datacode and
	s.datasubcode = b.longvalue and
	i.misctype = 5 and
	b.misckey = 37 and	
	i.misckey = 37 and	
	b.bookkey =  @i_bookkey 
	and exists (Select * from titlehistory where titlehistory.bookkey = b.bookkey and columnkey = 248 and fielddesc = 'Sales Commission' and lastmaintdate >= @i_prevstart_datetime)
end

-- jobtype 2,1 = new title feed

set @o_error_code = 0

If @i_jobtypecode = 2 and @i_jobtypesubcode = 1 -- new title feed
begin
	if isnull(@ABC_CODE,'') = ''       and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'ABC Code'       end else if isnull(@ABC_CODE,'') = ''       begin SET @o_error_code= 1 SET @o_error_desc ='ABC Code'       end
--	if isnull(@ALLOWABLE_WHSE,'') = '' and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'Allowable WHSE' end else if isnull(@ALLOWABLE_WHSE,'') = '' begin SET @o_error_code= 1 SET @o_error_desc ='Allowable WHSE' end
	if isnull(@AUTHOR_code,'') = ''		and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'Author'			end else if isnull(@author_code,'') = ''		begin SET @o_error_code= 1 SET @o_error_desc ='Author'      end
	if isnull(@COMPANY_NUMBER,'') = '' and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'Company #'      end else if isnull(@COMPANY_NUMBER,'') = '' begin SET @o_error_code= 1 SET @o_error_desc ='Company #'      end
	if isnull(@discount_code,'') = ''  and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'Discount code'       end else if isnull(@DIscount_code,'') = ''       begin SET @o_error_code= 1 SET @o_error_desc ='Discount code'       end
	if isnull(@DIVISION,'') = ''       and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'Division'       end else if isnull(@DIVISION,'') = ''       begin SET @o_error_code= 1 SET @o_error_desc ='Division'       end
	if isnull(@HANDLING,'') = ''       and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'Handling'       end else if isnull(@HANDLING,'') = ''       begin SET @o_error_code= 1 SET @o_error_desc ='Handling'       end
	if isnull(@HOLD_CODE,'') = ''      and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'Hold Code'      end else if isnull(@HOLD_CODE,'') = ''      begin SET @o_error_code= 1 SET @o_error_desc ='Hold Code'      end
	if isnull(@ISBN,'') = ''		   and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'ISBN'           end else if isnull(@ISBN,'') = ''           begin SET @o_error_code= 1 SET @o_error_desc ='ISBN'           end
	if isnull(@major_discipline,'') = ''      and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'Major Discipline'      end else if isnull(@major_discipline,'') = ''      begin SET @o_error_code= 1 SET @o_error_desc ='Major Discipline'      end
	if isnull(@publication_status,'') = ''      and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'Publication Status'      end else if isnull(@publication_status,'') = ''      begin SET @o_error_code= 1 SET @o_error_desc ='Publication Status'      end
	if isnull(@Retail_Price,'') = ''	and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'Retail Price'          end else if isnull(@Retail_Price,'') = ''          begin SET @o_error_code= 1 SET @o_error_desc ='Retail Price'          end
	if isnull(@TITLE,'') = ''		   and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'TITLE'          end else if isnull(@TITLE,'') = ''          begin SET @o_error_code= 1 SET @o_error_desc ='TITLE'          end
	if isnull(@PRICE_CLASSES,'') = ''  and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'Price Classes'  end else if isnull(@PRICE_CLASSES,'') = ''  begin SET @o_error_code= 1 SET @o_error_desc ='Price Classes'  end
end

-- jobtype 2,2 = change feed

If @i_jobtypecode = 2 and @i_jobtypesubcode = 2 -- change feed
begin
--if isnull(@COMPANY_NUMBER,'') = '' and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'Company #'    end else if isnull(@COMPANY_NUMBER,'') = '' begin SET @o_error_code= 1 SET @o_error_desc ='Company #'     end
	if isnull(@ISBN,'') = ''		   and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'ISBN'         end else if isnull(@ISBN,'') = ''           begin SET @o_error_code= 1 SET @o_error_desc ='ISBN'          end
	if isnull(@TITLE,'') = ''		   and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'TITLE'        end else if isnull(@TITLE,'') = ''          begin SET @o_error_code= 1 SET @o_error_desc ='TITLE'         end
--if isnull(@PRICE_CLASSES,'') = ''  and @o_error_code= 1 begin set @o_error_desc  = @o_error_desc + ', ' + 'Price Classes'end else if isnull(@PRICE_CLASSES,'') = ''  begin SET @o_error_code= 1 SET @o_error_desc ='Price Classes' end
end

if @o_error_code = 1
begin
	set @o_error_desc = 'Critical LLS values not populated completely – ' + @o_error_desc +'.  Row not written for this bookkey'
	RETURN
end

INSERT INTO [dbo].[unp_export_to_LLS](
[BOOKCODE],
[ABC CODE],
[ALLW WHS],
[AUTHOR],
[CASE QTY],
[CO #],
[COPYRIGHT],
[DISC CODE],
[DIVISION],
[EDITOR],
[EXPANDED],
[FINAL],
[FIRST DUE],
[HANDLING],
[HOLD],
[INTEREST],
[ISBN],
[LIST],
[MAJOR DISC],
[MEMO],
[MINOR DISC],
[OP AT ZERO],
[PRICE CLS],
[PROD TYPE],
[PUB DATE],
[PUB STATUS],
[PUBLISHER],
[RELATED],
[RETAIL],
[REORDER],
[RIGHTSCODE],
[ROYALTIES],
[SERIESCODE],
[STDG ORD],
[SUB CODE],
[SUBTITLE],
[TAXABLE],
[TITLE],
[WEBSALE],
[WEIGHT],
[WHST ACT],
[PROD COST],
[TAX],
[COMMISSION])
 VALUES
(@BOOK_CODE,
@ABC_CODE,
@ALLOWABLE_WHSE,
@AUTHOR_CODE,
@CASE_QTY,
@COMPANY_NUMBER,
@COPYRIGHT_DATE,
@DISCOUNT_CODE,
@DIVISION,
@EDITOR_CODE,
@EXPANDED_DESC,
@FINAL_DATE ,
@FIRST_DUE_DATE,
@HANDLING,
@HOLD_CODE,
@INTEREST_CODES,
@ISBN,
@LIST_PRICES,
@MAJOR_DISCIPLINE,
@MEMO_PAD_COMMENTS,
@MINOR_DISCIPLINE,
@OUT_OF_PRINT_ZERO_QTY,
@PRICE_CLASSES,
@PRODUCT_TYPE,
@PUBLICATION_DATE,
@PUBLICATION_STATUS,
@PUBLISHER,
@RELATED_PRODUCTS,
@RETAIL_PRICE,
@REORDER_POINT,
@RIGHTS_CODE,
@ROYALTIES,
@SERIES_CODE,
@STANDING_ORDER_CODES,
@SUBSTITUTION_CODE,
@SUBTITLE,
@TAXABLE,
@TITLE,
@WEB_SALEABLE,
@WEIGHT,
@WHSE_ACTION_LEVEL ,
@PRODUCTION_COST,
@TAX_EXEMPTIONS,
@COMMISSION
)

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'Unable to insert into the unp_export_to_LLS table.   Error #' + cast(@v_error as varchar(20))
	RETURN
END 

-- update unp sent date
--update bookdates
--set activedate = @i_start_datetime,
--bestdate = @i_start_datetime,
--lastuserid = 'qsidba_sap',
--lastmaintdate = getdate()
--where bookkey = @i_bookkey
--and datetypecode = 20004


END



GO

