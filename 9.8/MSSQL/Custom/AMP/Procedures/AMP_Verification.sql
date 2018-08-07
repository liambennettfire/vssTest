if exists (select * from dbo.sysobjects where id = object_id(N'dbo.AMP_Verification') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.AMP_Verification
GO

/******************************************************************************
**  Name: AMP_Verification
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  04/26/2016   Uday        Case 37721
*******************************************************************************/

/****** Object:  StoredProcedure [dbo].[AMP_Verification]    Script Date: 04/26/2016 09:57:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--drop procedure [dbo].[AMP_Verify] 

CREATE PROCEDURE [dbo].[AMP_Verification]
		     @i_bookkey int,
		     @i_printingkey int,
		     @i_verificationtypecode int,
		     @i_username varchar(15)
AS

BEGIN 
	--grant execute on dbo.WK_Verify_Tm_to_SLX to public

	Declare @creationdate datetime
		set @CreationDate =(Select CreationDate from book where bookkey=@i_bookkey)

	Declare @BisacDataCode int
		Set @bisacDatacode = (Select Bisacstatuscode from bookdetail where bookkey = @i_bookkey)

	DECLARE 
	@v_active_date datetime,
	@v_audience_code int,
	@v_effective_date datetime,
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
	@v_shorttitle varchar(50),
	@v_cnt int,
	@v_territoriescode	int,
	@v_isbn varchar(13),
	@v_isbn10 varchar(10),
	@v_ean13 varchar(13),
	@v_ean  varchar(50),
	@v_upc  varchar(50),
	@v_mediatypecode int,
	@v_mediatypesubcode int,
	@v_bestdate datetime,
	@v_bestdate_weekday int,
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
	@v_packqty int,
	@v_editiontypeid int,
	@v_tmmpagecount int,
	@v_totalruntime  varchar(10),
	@v_eloquencefieldtag varchar(25),
	@v_season int,
	@v_copyrightyear smallint,
	@v_nextkey int,
	@v_varnings int,
	@v_failed int,
	@v_isbn13 varchar(13),
	@v_discountcode int,
	@v_barcodeid1 numeric(18,0),
	@v_barcodeposition1 numeric(18,0),
	@v_barcodeid2 numeric(18,0),
	@v_barcodeposition2  numeric(18,0),
	@v_bsg_msg varchar(100),
	@v_g_msg varchar(100),
	@v_bisac_status_code int,
	@v_internal_status_code int,
	@v_publishing_category_code int,
	@v_prodavailability int,
	@v_allagesind int,
	@v_agelowupind int,
	@v_agehighupind int,
	@v_gradelowupind int,
	@v_gradehighupind int,
	@v_elocustomerkey int,
	@v_usageclasscode int,
	@i_write_msg int,
	@v_commenttypecode int,
	@v_commenttypesubcode int,
	@v_commenthtml varchar(MAX),
	@v_count int,
	@v_count2 int

	set @v_Error = 2
	set @v_Warning = 3
	set @v_Information = 4
	set @v_Aborted = 5
	set @v_Completed = 6
	set @v_failed = 0 
	set @v_varnings = 0
	set @v_bsg_msg = ''
	set @v_g_msg = ''

	--make sure AMP custom checks are in table
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP UPC')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP UPC',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Book Short Title')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Book Short Title',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Internal Status')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Internal Status',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP_Territory')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP_Territory',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Season')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Season',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Copyright Year')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Copyright Year',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Book Comments')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Book Comments',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Pack Qty')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Pack Qty',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Edition Type')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Edition Type',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Publishing Category')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Publishing Category',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Product Line')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Product Line',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Book Comment ONIX')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Book Comment ONIX',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Book Comment Key Selling Points')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Book Comment Key Selling Points',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Book Comment Sales Handle')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Book Comment Sales Handle',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP USD Price')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP USD Price',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Cover Image')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Cover Image',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP POD Price')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP POD Price',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Price Value')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Price Value',1,'amp',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='AMP Juvenile - No Audience Code')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'AMP Juvenile - No Audience Code',1,'amp',GETDATE()
		end
	--end 

	--clean bookverificationmessager for passed bookkey
	delete bookverificationmessage
	where bookkey = @i_bookkey
	and verificationtypecode = @i_verificationtypecode

	--check for titlefrefix, mediatypecode, mediatypesubcode, agelow, agehigh, gradelow, gradehigh
	select @v_titleprefix = ltrim(rtrim(titleprefix)), @v_mediatypecode = mediatypecode, @v_mediatypesubcode = mediatypesubcode,
	@v_agelow = agelow,@v_agehigh = agehigh, @v_gradelow = gradelow, @v_gradehigh = gradehigh, @v_seriescode = seriescode,
	@v_volumenumber = volumenumber, @v_editioncode = editioncode, @v_editionnumber = editionnumber, @v_editiondescription = editiondescription,
	@v_returncode = returncode, @v_languagecode = languagecode, @v_languagecode2 = languagecode2, @v_discountcode = discountcode,
	@v_bisac_status_code = bisacstatuscode, @v_prodavailability = prodavailability, @v_allagesind = allagesind, @v_agelowupind = agelowupind,
	@v_agehighupind = agehighupind, @v_gradelowupind = gradelowupind, @v_gradehighupind = gradehighupind, @v_copyrightyear = copyrightyear
	from bookdetail
	where bookkey = @i_bookkey

	exec bookverification_check 'BISAC Status Code', @i_write_msg output
	if @i_write_msg = 1 begin
		if @i_verificationtypecode in(5) begin
			if @v_bisac_status_code is null  begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
				      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing BISAC Status Code',@i_username, getdate() )
				set @v_failed = 1
			end 
		end
	end
	exec bookverification_check 'Book Media', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_mediatypecode is null begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
				  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)			
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Media'+ @v_bsg_msg,@i_username, getdate() )
			set @v_failed = 1
		end 
	end
	exec bookverification_check 'Book Format', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_mediatypesubcode is null begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
				  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)			
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Format'+ @v_bsg_msg,@i_username, getdate() )
			set @v_failed = 1
		end 
	end
	if @v_allagesind is null or @v_allagesind = 0 begin
		if @v_agelowupind is null or @v_agelowupind = 0 begin
			exec bookverification_check 'Age Range - Age Low', @i_write_msg output
			if @i_write_msg = 1 begin
				if @v_mediatypecode not in (23,47,48,57) begin
					if @v_agelow is null begin
						select @v_cnt = count(bookkey)
						from booksubjectcategory
						where bookkey = @i_bookkey and booksubjectcategory.categorytableid = 435 and booksubjectcategory.categorycode in (2,25) and booksubjectcategory.sortorder = 1
						if @v_cnt <> 0 begin
							exec get_next_key @i_username, @v_nextkey out
							insert into bookverificationmessage
								  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)							
							values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Age Range - Age Low',@i_username, getdate() )
							set @v_failed = 1
						end
					end 
				end
			end
			if @v_agehighupind is null or @v_agehighupind = 0 begin
				exec bookverification_check 'Age Range - Age High', @i_write_msg output
				if @i_write_msg = 1 begin
					if @v_mediatypecode not in (23,47,48,57) begin
						if @v_agehigh is null begin
							select @v_cnt = count(bookkey)
							from booksubjectcategory
							where bookkey = @i_bookkey and booksubjectcategory.categorytableid = 435 and booksubjectcategory.categorycode in (2,25) and booksubjectcategory.sortorder = 1
							if @v_cnt <> 0 begin
								exec get_next_key @i_username, @v_nextkey out
								insert into bookverificationmessage
									  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)								
								values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Age Range - Age High',@i_username, getdate() )
								set @v_failed = 1
							end
						end
					end
				end
			end 
		end
	end
	-- @v_count > 0 indicates book subject is Juvenile (Childrens's)
	select @v_count = 0
	exec bookverification_bisacsubjects_check @i_bookkey,1, @v_count out
	
	-- only output error message for Grade Level if title has rows for BISAC Subjects of Juvenile Fiction or Juvenile Non-Fiction
	exec bookverification_check 'Grade Level - Grade Low', @i_write_msg output
	if @i_write_msg = 1 begin
		-- Moved execution of SP bookverification_bisacsubjects_check above the if since @v_count is used for detecting several error conditions.
		--select @v_count = 0
		--exec bookverification_bisacsubjects_check @i_bookkey,1, @v_count out
		if @v_count > 0 BEGIN
			if @v_mediatypecode not in (23,47,48,57) begin
				-- mediaTypeCode =	23	Display Units
				--					47	Assembled/Kit/Set
				--					48	Unassembled/Kit/Set
				--					57	Non-Merch
				if @v_gradelowupind is null or @v_gradelowupind = 0 begin
					if @v_gradelow is null begin
						select @v_cnt = count(bookkey)
						from booksubjectcategory
						where bookkey = @i_bookkey and booksubjectcategory.categorytableid = 435 
							and booksubjectcategory.categorycode = 25 
							and booksubjectcategory.sortorder = 1
						if @v_cnt = 0 begin
							exec get_next_key @i_username, @v_nextkey out
							insert into bookverificationmessage
							      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Grade Level - Grade Low',@i_username, getdate() )
							set @v_failed = 1
						end
					end
				end 
			end
		end
	end
	exec bookverification_check 'Grade Level - Grade High', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_count > 0 begin
			if @v_mediatypecode not in (23,47,48,57) begin
				if @v_gradehighupind is null or @v_gradehighupind = 0  begin
					if @v_gradehigh is null begin
						select @v_cnt = count(bookkey)
						from booksubjectcategory
						where bookkey = @i_bookkey and booksubjectcategory.categorytableid = 435 
							and booksubjectcategory.categorycode = 25 
							and booksubjectcategory.sortorder = 1
						if @v_cnt = 0 begin
							exec get_next_key @i_username, @v_nextkey out
							insert into bookverificationmessage
							      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Grade Level - Grade High',@i_username, getdate() )
							set @v_failed = 1
						end
					end
				end 
			end
		end
	end
	-- Output error message (v_failed = 1) if title is Children's (Juvenile Fiction or Juvenile Non-Fiction & there is no audience code
	exec bookverification_check 'AMP Juvenile - No Audience Code', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_count > 0 begin
			-- Media Type is not Display Unit, Kit or Non-Merch
			if @v_mediatypecode not in (23,47,48,57) begin
				select @v_cnt = count(bookkey)
					from booksubjectcategory
					where bookkey = @i_bookkey and booksubjectcategory.categorytableid = 435 
						and booksubjectcategory.categorycode = 25 
						and booksubjectcategory.sortorder = 1
				if @v_cnt > 0 begin
					select @v_audience_code = 0
					select @v_audience_code = audienceCode
						from bookAudience
						where bookKey = @i_bookkey
						and sortOrder = 1
					if @v_audience_code is null or @v_audience_code = 0 begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'AMP Juvenile - No Audience Code',@i_username, getdate() )
						set @v_failed = 1
					end
				end 
			end
		end
	end
	if @v_count > 0 BEGIN -- Rows exist for JUV/NON JUV on bookbisaccategory
		exec bookverification_bisacsubjects_check @i_bookkey,0, @v_count2 out
		if @v_count2 > 0 BEGIN -- Rows also exist on bookbisaccategory for other than JUV/NON JUV
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
			      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'It is not valid to use JUV and Non JUV BISAC Subjects on a single title',@i_username, getdate() )
			set @v_varnings = 1
		end
	end
	--check for title, subtitle, shorttitle
	select @v_title = ltrim(rtrim(title)), @v_subtitle = ltrim(rtrim(subtitle)), @v_shorttitle = ltrim(rtrim(shorttitle)), 
	@v_internal_status_code = titlestatuscode, @v_usageclasscode = usageclasscode
	from book
	where bookkey = @i_bookkey

	exec bookverification_check 'Book Title', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_title is null or  @v_title = '' begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
			      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Title' + @v_bsg_msg,@i_username, getdate() )
			set @v_failed = 1
		end 
	end
	exec bookverification_check 'Book Title Subtitle', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_subtitle is null or @v_subtitle = '' begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
			      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Information, 'Missing Book Sub-title'+ @v_bsg_msg,@i_username, getdate() )
		end 
	end
	exec bookverification_check 'AMP Book Short Title', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_shorttitle is null or @v_shorttitle = '' begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
			      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Short Title'+ @v_bsg_msg,@i_username, getdate() )
			set @v_failed = 1
		end 
	end
	
	--select @v_usageclasscode = usageclasscode
	--from book
	--where bookkey = @i_bookkey
	if @v_usageclasscode = 1 begin
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
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Primary Author'+ @v_bsg_msg,@i_username, getdate() )
				set @v_failed = 1
			end 
		end
	end
	exec bookverification_check 'AMP Internal Status', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_internal_status_code is null or  @v_internal_status_code = '' begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
				  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)			
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Internal Status Code' + @v_bsg_msg,@i_username, getdate() )
			set @v_failed = 1
		end 
	end
	exec bookverification_check 'AMP Copyright Year', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_copyrightyear is null or @v_copyrightyear = '' begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
				  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)			
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Copyright Year' + @v_bsg_msg,@i_username, getdate() )
			set @v_failed = 1
		end 
	end
	--check for isbn, isbn10, ean13, upc
	select @v_isbn = ltrim(rtrim(isbn)), @v_isbn10 = ltrim(rtrim(isbn10)), @v_ean13 = ltrim(rtrim(ean13)), @v_ean = ltrim(rtrim(ean)),
		@v_isbn13 =  ltrim(rtrim(isbn)),@v_upc =  ltrim(rtrim(upc))
	from isbn 
	where bookkey = @i_bookkey

	exec bookverification_check 'ISBN', @i_write_msg output
	if @i_write_msg = 1 begin
		if @i_verificationtypecode = 5 begin
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
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing ISBN10'+ @v_bsg_msg,@i_username, getdate() )
			set @v_failed = 1
		end 
	end
	if @i_verificationtypecode in(5) begin
		exec bookverification_check 'EAN13', @i_write_msg output
		if @i_write_msg = 1 begin
			if @v_ean13 is null or @v_ean13 = '' begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
				      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing EAN13'+ @v_bsg_msg,@i_username, getdate() )
				set @v_failed = 1
			end 
		end
	end
	if @i_verificationtypecode in(5) begin
		exec bookverification_check 'EAN13', @i_write_msg output
		if @i_write_msg = 1 begin
			if @v_ean is null or @v_ean = '' begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
				      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing EAN'+ @v_bsg_msg,@i_username, getdate() )
				set @v_failed = 1
			end 
		end
	end
	if @i_verificationtypecode in(5) begin
		exec bookverification_check 'AMP UPC', @i_write_msg output
		if @i_write_msg = 1 begin
			if @v_upc is null or @v_upc = '' begin
				if @v_ean13 not like '97807671%' and @v_ean13 not like '93416920%' and @v_ean13 not like '97809800131%' and @v_ean13 not like '97809854662%' and @v_ean13 not like '97809889492%' and @v_ean13 not like '9781941252%' begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing UPC'+ @v_bsg_msg,@i_username, getdate() )
					set @v_failed = 1
				end
			end 
		end
	end

	--check for pub date 
	select @v_bestdate = bestdate, @v_bestdate_weekday = DATEPART(weekday,bestdate)
	from bookdates
	where bookkey = @i_bookkey
	and datetypecode = 8
	and printingkey = @i_printingkey

	exec bookverification_check 'PUB Date', @i_write_msg output
	if @i_write_msg = 1 begin
		if @i_verificationtypecode in(5) begin
			if @v_bestdate is null begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
				      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Publication Date'+ @v_bsg_msg,@i_username, getdate() )
				set @v_failed = 1
			end else
				begin 
					if @v_bestdate_weekday != 3 begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Publication Date is not a Tuesday'+ @v_bsg_msg,@i_username, getdate() )
						set @v_varnings = 1
					end
				end
		end
	end

	--check for on sale date
	select @v_cnt = count(bookkey)
	from bookDates
	where bookKey = @i_bookkey
	and datetypecode = 20003
	and printingkey = @i_printingkey
	 
	select @v_bestdate = bestdate, @v_bestdate_weekday = DATEPART(weekday,bestdate)
	from bookdates
	where bookkey = @i_bookkey
	and datetypecode = 20003
	and printingkey = @i_printingkey

	exec bookverification_check 'On Sale Date', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_bestdate is null or @v_cnt = 0 begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
			      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing On Sale Date'+ @v_bsg_msg,@i_username, getdate() )
			set @v_failed = 1
		end else
			begin 
				if @v_bestdate_weekday != 3 begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'On Sale Date is not a Tuesday'+ @v_bsg_msg,@i_username, getdate() )
					set @v_varnings = 1
				end
			end
	end

	--check for tentativepagecount , pagecount, tmmpagecount 
	--select @v_usageclasscode = usageclasscode
	--from book
	--where bookkey = @i_bookkey
	if @v_usageclasscode = 1 begin
		--select @v_mediatypecode = mediatypecode
		--from bookdetail
		--where bookkey = @i_bookkey
		if @v_mediatypecode not in (23,47,48) begin
			select @v_tentativepagecount = tentativepagecount , @v_pagecount = pagecount, @v_tmmpagecount = tmmpagecount , @v_season = seasonkey
			from printing 
			where bookkey = @i_bookkey and printingkey = @i_printingkey
			exec bookverification_check 'Page Cnt', @i_write_msg output
			if @i_write_msg = 1 begin
				if @v_tentativepagecount is null and  @v_pagecount is null and @v_tmmpagecount is null begin
					--select @v_ean13 = ltrim(rtrim(ean13))
					--from isbn 
					--where bookkey = @i_bookkey
					if @v_ean13 not like '97807671%' and @v_ean13 not like '93416920%' begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Page Cnt'+ @v_g_msg,@i_username, getdate() )
						set @v_failed = 1
					end	else
						begin
							exec get_next_key @i_username, @v_nextkey out
							insert into bookverificationmessage
							      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Page Cnt'+ @v_g_msg,@i_username, getdate() )
							set @v_varnings = 1
						end
				end 
			end
		end
	end
	
	--check for Season code
	--select @v_season = seasonkey
	--from printing 
	--where bookkey = @i_bookkey and printingkey = @i_printingkey
	
	exec bookverification_check 'AMP Season', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_season is null and  @v_season = '' begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
			      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Season Code'+ @v_g_msg,@i_username, getdate() )
			set @v_varnings = 1
		end 
	end
	
	--check for Bisac Subject 1, Bisac Subject 2
	select @v_cnt = count(bookkey)
	from bookbisaccategory
	where bookkey = @i_bookkey
	and printingkey = @i_printingkey

	exec bookverification_check 'BISAC Subject 1', @i_write_msg output
	if @i_write_msg = 1 begin
		if @i_verificationtypecode in (5) begin
			if @v_cnt = 0 begin
				select @v_ean13 = ltrim(rtrim(ean13))
				from isbn 
				where bookkey = @i_bookkey
				if @v_ean13 not like '97807671%' and @v_ean13 not like '93416920%' begin
					select @v_mediatypecode = mediatypecode
					from bookdetail
					where bookkey = @i_bookkey
					if @v_mediatypecode not in (15) begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing BISAC Subject 1'+ @v_bsg_msg,@i_username, getdate() )
						set @v_failed = 1
					end else
						begin
							exec get_next_key @i_username, @v_nextkey out
							insert into bookverificationmessage
							      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing BISAC Subject 1'+ @v_bsg_msg,@i_username, getdate() )
							set @v_varnings = 1
						end
				end else
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing BISAC Subject 1'+ @v_bsg_msg,@i_username, getdate() )
						set @v_varnings = 1
					end
			end 
		end
	end
	if @i_write_msg = 1 begin
		if @i_verificationtypecode in (5) begin
			if @v_cnt = 1 begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
				      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing BISAC Subject 2'+ @v_bsg_msg,@i_username, getdate() )
				set @v_varnings = 1
			end 
		end
	end

	--price
	select @v_cnt = count(*)
	from bookprice 
	where bookkey = @i_bookkey
	and (finalprice is not null or finalprice <> '')
	and activeind = 1

	exec bookverification_check 'Price', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_cnt = 0  begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
			      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Price'+ @v_bsg_msg,@i_username, getdate() )
			set @v_failed = 1
		end else
			begin
				if (@v_mediatypecode in (45)) and (@v_mediatypesubcode in (1)) begin
					--currency USD Library
					select @v_cnt = count(currencytypecode)
					from bookprice 
					where bookkey = @i_bookkey
					and pricetypecode = 30 
					and currencytypecode = 6 
					and (finalprice is not null)
					and activeind = 1

					exec bookverification_check 'AMP USD Price', @i_write_msg output
					if @i_write_msg = 1 begin
						if @i_verificationtypecode in(5) begin
							if @v_cnt = 0 begin
								exec get_next_key @i_username, @v_nextkey out
								insert into bookverificationmessage
								      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing USD Library Price'+ @v_bsg_msg,@i_username, getdate() )
								set @v_failed = 1
							end else
								begin
									select @v_effective_date = effectivedate
									from bookprice 
									where bookkey = @i_bookkey
									and pricetypecode = 30
									and currencytypecode = 6 
									and activeind = 1
									if @v_effective_date is null begin
										exec get_next_key @i_username, @v_nextkey out
										insert into bookverificationmessage
										      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
										values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing USD Library Price Effective Date'+ @v_bsg_msg,@i_username, getdate() )
										set @v_failed = 1
									end else
										begin 
											if @v_effective_date > GETDATE() begin
												exec get_next_key @i_username, @v_nextkey out
												insert into bookverificationmessage
												      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
												values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'USD Library Price Effective Date in future'+ @v_bsg_msg,@i_username, getdate() )
												set @v_failed = 1
											end
										end
								end
						end
					end

					--POD Price Type
					select @v_cnt = count(currencytypecode)
					from bookprice 
					where bookkey = @i_bookkey
					and pricetypecode = 31 
					and activeind = 1

					exec bookverification_check 'AMP POD Price', @i_write_msg output
					if @i_write_msg = 1 begin
						if @i_verificationtypecode in(5) begin
							if @v_cnt > 0 begin
								exec get_next_key @i_username, @v_nextkey out
								insert into bookverificationmessage
								      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'AMP POD Price Type Used'+ @v_bsg_msg,@i_username, getdate() )
								set @v_failed = 1
							end
						end
					end
					
					--currency Canadian
					select @v_cnt = count(currencytypecode)
					from bookprice 
					where bookkey = @i_bookkey
					and pricetypecode = 30
					and currencytypecode = 11
					and (finalprice is not null)
					and activeind = 1
					
					exec bookverification_check 'Canadian Price', @i_write_msg output
					if @i_write_msg = 1 begin
						if @i_verificationtypecode in(5) begin
							if @v_cnt = 0 begin
								exec get_next_key @i_username, @v_nextkey out
								insert into bookverificationmessage
								      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Canadian Library Price'+ @v_bsg_msg,@i_username, getdate() )
								set @v_varnings = 1
							end else
								begin
									select @v_effective_date = effectivedate
									from bookprice 
									where bookkey = @i_bookkey
									and pricetypecode = 30
									and currencytypecode = 11
									and activeind = 1
									if @v_effective_date is null begin
										exec get_next_key @i_username, @v_nextkey out
										insert into bookverificationmessage
										      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
										values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Canadian Library Price Effective Date'+ @v_bsg_msg,@i_username, getdate() )
										set @v_failed = 1
									end else
										begin 
											if @v_effective_date > GETDATE() begin
												exec get_next_key @i_username, @v_nextkey out
												insert into bookverificationmessage
												      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
												values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Canadian Library Price Effective Date in future'+ @v_bsg_msg,@i_username, getdate() )
												set @v_failed = 1
											end
										end
								end
						end
					end
				end else
					begin
						--currency USD MSRP
						select @v_cnt = count(currencytypecode)
						from bookprice 
						where bookkey = @i_bookkey
						and currencytypecode = 6 
						and (finalprice is not null)
						and activeind = 1

						exec bookverification_check 'AMP USD Price', @i_write_msg output
						if @i_write_msg = 1 begin
							if @i_verificationtypecode in(5) begin
								if @v_cnt = 0 begin
									exec get_next_key @i_username, @v_nextkey out
									insert into bookverificationmessage
									      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing USD Price'+ @v_bsg_msg,@i_username, getdate() )
									set @v_failed = 1
								end else
									begin
										select @v_effective_date = effectivedate
										from bookprice 
										where bookkey = @i_bookkey
										and currencytypecode = 6 
										and activeind = 1
										if @v_effective_date is null begin
											exec get_next_key @i_username, @v_nextkey out
											insert into bookverificationmessage
											      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
											values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing USD Price Effective Date'+ @v_bsg_msg,@i_username, getdate() )
											set @v_failed = 1
										end else
											begin 
												if @v_effective_date > GETDATE() begin
													exec get_next_key @i_username, @v_nextkey out
													insert into bookverificationmessage
													      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
													values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'USD Price Effective Date in future'+ @v_bsg_msg,@i_username, getdate() )
													set @v_failed = 1
												end
											end
									end
							end
						end
						
					
						--currency Canadian
						select @v_cnt = count(currencytypecode)
						from bookprice 
						where bookkey = @i_bookkey
						and currencytypecode = 11
						and (finalprice is not null)
						and activeind = 1

						exec bookverification_check 'Canadian Price', @i_write_msg output
						if @i_write_msg = 1 begin
							if @i_verificationtypecode in(5) begin
								if @v_cnt = 0 begin
									exec get_next_key @i_username, @v_nextkey out
									insert into bookverificationmessage
									      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Canadian Price'+ @v_bsg_msg,@i_username, getdate() )
									set @v_varnings = 1
								end else
									begin
										select @v_effective_date = effectivedate
										from bookprice 
										where bookkey = @i_bookkey
										and currencytypecode = 11
										and activeind = 1
										if @v_effective_date is null begin
											exec get_next_key @i_username, @v_nextkey out
											insert into bookverificationmessage
											      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
											values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Canadian Price Effective Date'+ @v_bsg_msg,@i_username, getdate() )
											set @v_failed = 1
										end else
											begin 
												if @v_effective_date > GETDATE() begin
													exec get_next_key @i_username, @v_nextkey out
													insert into bookverificationmessage
													      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
													values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Canadian Price Effective Date in future'+ @v_bsg_msg,@i_username, getdate() )
													set @v_failed = 1
												end
											end
									end
							end
						end
				end
				--currency
				select @v_cnt = count(currencytypecode)
				from bookprice 
				where bookkey = @i_bookkey
				and currencytypecode is not null
				and activeind = 1

				exec bookverification_check 'Price Type', @i_write_msg output
				if @i_write_msg = 1 begin
					if @i_verificationtypecode in(5) begin
						if @v_cnt = 0 begin
							exec get_next_key @i_username, @v_nextkey out
							insert into bookverificationmessage
							      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Price Type missing'+ @v_bsg_msg,@i_username, getdate() )
							set @v_failed = 1
						end
					end
				end
			end
	end
	----currency precision
	--select @v_cnt = count(currencytypecode)
	--from bookprice 
	--where bookkey = @i_bookkey
	--	and ((round(finalprice,2) <> finalprice) and (finalprice <> 0))
	--	and activeind = 1
	--exec bookverification_check 'AMP Price Value', @i_write_msg output
	--if @i_write_msg = 1 begin
	--	if @i_verificationtypecode in(5) begin
	--		if @v_cnt = 0 begin
	--			exec get_next_key @i_username, @v_nextkey out
	--			insert into bookverificationmessage
	--			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'AMP Price Value'+ @v_bsg_msg,@i_username, getdate() )
	--			set @v_failed = 1
	--		end
	--	end
	--end
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
			      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
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
			      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Imprint' + @v_bsg_msg,@i_username, getdate() )
			set @v_failed = 1
		end
	end
	--Publishing Category 
	select @v_cnt = count(bookkey)
	from booksubjectcategory
	where bookkey = @i_bookkey
	and booksubjectcategory.categorytableid = 435

	exec bookverification_check 'AMP Publishing Category', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_cnt = 0 begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
			      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Publishing Category' + @v_bsg_msg,@i_username, getdate() )
			set @v_failed = 1
		end
	end
	--Product Line 
	select @v_cnt = count(bookkey)
	from booksubjectcategory
	where bookkey = @i_bookkey
	and booksubjectcategory.categorytableid = 437

	exec bookverification_check 'AMP Product Line', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_cnt = 0 begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
			      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Product Line' + @v_bsg_msg,@i_username, getdate() )
			set @v_failed = 1
		end
	end
	--Book ONIX Description
	select @v_cnt = count(*)
	from bookcomments
	where bookkey = @i_bookkey and commenttypecode = 3 and commenttypesubcode = 8

	exec bookverification_check 'AMP Book Comment ONIX', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_cnt = 0 begin
			select @v_ean13 = ltrim(rtrim(ean13))
			from isbn 
			where bookkey = @i_bookkey
			if @v_ean13 not like '97807671%' and @v_ean13 not like '93416920%' begin
				select @v_mediatypecode = mediatypecode
				from bookdetail
				where bookkey = @i_bookkey
				if @v_mediatypecode not in (15) begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing ONIX Description'+ @v_g_msg,@i_username, getdate() )
					set @v_failed = 1
				end else
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing ONIX Description'+ @v_g_msg,@i_username, getdate() )
						set @v_varnings = 1
					end
			end else
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing ONIX Description'+ @v_g_msg,@i_username, getdate() )
					set @v_varnings = 1
				end
		end 
	end
	--Book Key Selling Points Description
	select @v_cnt = count(*)
	from bookcomments
	where bookkey = @i_bookkey and commenttypecode = 3 and commenttypesubcode = 59

	exec bookverification_check 'AMP Book Comment Key Selling Points', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_cnt = 0 begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
			      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Key Selling Points Description'+ @v_g_msg,@i_username, getdate() )
			set @v_varnings = 1
		end 
	end
	----Book Key Selling Points Description
	--select @v_commenthtml = commenthtml
	--from bookcomments
	--where bookkey = @i_bookkey and commenttypecode = 3 and commenttypesubcode = 59

	--exec bookverification_check 'AMP Book Comment Key Selling Points', @i_write_msg output
	--if @i_write_msg = 1 begin
	--	if @v_commenthtml is Null or @v_commenthtml = '' begin
	--		exec get_next_key @i_username, @v_nextkey out
	--		insert into bookverificationmessage
	--		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Key Selling Points Description'+ @v_g_msg,@i_username, getdate() )
	--		set @v_failed = 1
	--	end 
	--end
	--Book Sales Handle Description
	select @v_cnt = count(*)
	from bookcomments
	where bookkey = @i_bookkey and commenttypecode = 3 and commenttypesubcode = 61

	exec bookverification_check 'AMP Book Comment Sales Handle', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_cnt = 0 begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
			      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Sales Handle Description'+ @v_g_msg,@i_username, getdate() )
			set @v_varnings = 1
		end 
	end
	--Book Key Cover Image
	select @v_mediatypecode = bd.mediatypecode, @v_internal_status_code = book.titlestatuscode
	from bookdetail as bd left outer join
		book on book.bookkey = bd.bookkey
	where bd.bookkey = @i_bookkey 

	exec bookverification_check 'AMP Cover Image', @i_write_msg output
	if @i_write_msg = 1 begin	
		if @v_mediatypecode not in (15,22,23,57,55,56,48) begin
			if @v_internal_status_code = 30 begin
				select @v_cnt = count(*)
				from filelocation 
				where filelocation.bookkey = @i_bookkey and filelocation.filetypecode = 2 and filelocation.filestatuscode = 1 and filelocation.[pathname] is not null
				if @v_cnt = 0 begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Cover Image or not marked as Final Status'+ @v_g_msg,@i_username, getdate() )
					set @v_varnings = 1
				end
			end else begin
				select @v_cnt = count(*)
				from filelocation 
				where filelocation.bookkey = @i_bookkey and filelocation.filetypecode = 2 and filelocation.filestatuscode = 1 and filelocation.[pathname] is not null
				if @v_cnt = 0 begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Cover Image or not marked as Final Status'+ @v_g_msg,@i_username, getdate() )
					set @v_failed = 1
				end
			end
		end 
	end
	--non ebook/ecalendar checks
	select @v_mediatypecode = mediatypecode
	from bookdetail
	where bookkey = @i_bookkey

	exec bookverification_check 'Book Media', @i_write_msg output
	if @i_write_msg = 1 begin
		if @v_mediatypecode not in (45,46) begin
			--start check for Carton Qty/Case Pack
			select @v_cartonqty1 = cartonqty1
			from bindingspecs
			where bookkey = @i_bookkey
			and printingkey = @i_printingkey
			exec bookverification_check 'Carton Qty/Case Pack', @i_write_msg output
			if @i_write_msg = 1 begin
				if @i_verificationtypecode in(5) begin
					if @v_cartonqty1 is Null begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Carton Qty/Case Pack'+ @v_bsg_msg,@i_username, getdate() )
						set @v_varnings = 1
					end
				end 
			end
			--start check for trimsizelength, esttrimsizelength, trimsizewidth, esttrimsizewidth, barcode indicators
			select @v_tmmactualtrimsizelength = ltrim(rtrim(tmmactualtrimlength)), @v_tmmactualtrimsizewidth = ltrim(rtrim(tmmactualtrimwidth)),
				   @v_esttrimsizelength = ltrim(rtrim(esttrimsizelength)), @v_esttrimsizewidth = ltrim(rtrim(esttrimsizewidth)),
				   @v_trimsizelength = ltrim(rtrim(trimsizelength)), @v_trimsizewidth = ltrim(rtrim(trimsizewidth)),
				   @v_spinesize = ltrim(rtrim(spinesize)), @v_barcodeid1 = barcodeid1, @v_barcodeposition1 = barcodeposition1, 
				   @v_barcodeid2 = barcodeid2, @v_barcodeposition2 = barcodeposition2
			from printing
			where bookkey = @i_bookkey
			and printingkey = @i_printingkey
			if @i_verificationtypecode in(5) begin
				exec bookverification_check 'Height', @i_write_msg output
				if @i_write_msg = 1 begin
					if @v_trimsizelength is null or @v_trimsizelength = '' begin
						if  @v_esttrimsizelength is null or @v_esttrimsizelength = '' begin 
							if @v_tmmactualtrimsizelength is null or @v_tmmactualtrimsizelength = '' begin
								exec get_next_key @i_username, @v_nextkey out
								insert into bookverificationmessage
								      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Height'+ @v_bsg_msg,@i_username, getdate() )
								set @v_varnings = 1
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
								      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Width'+ @v_bsg_msg,@i_username, getdate() )
								set @v_varnings = 1
							end
						end
					end 
				end
				exec bookverification_check 'Depth (spine size)', @i_write_msg output
				if @i_write_msg = 1 begin
					if @i_verificationtypecode in(5) begin
						if @v_spinesize is null or @v_spinesize = '' begin
							exec get_next_key @i_username, @v_nextkey out
							insert into bookverificationmessage
							      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Depth (spine size)'+ @v_g_msg,@i_username, getdate() )
							set @v_varnings = 1
						end 
					end
				end
				if @v_mediatypecode in (50,18,53,21,28) begin
					exec bookverification_check 'Bar Code Indicator', @i_write_msg output
					if @i_write_msg = 1 begin
						if @i_verificationtypecode in(5) begin
							if @v_barcodeid1 is null and @v_barcodeposition1 is null and @v_barcodeid2 is null and @v_barcodeposition2 is null begin
								select @v_ean13 = ltrim(rtrim(ean13))
								from isbn 
								where bookkey = @i_bookkey
								if @v_ean13 not like '97807671%' and @v_ean13 not like '93416920%' begin
									select @v_mediatypecode = mediatypecode
									from bookdetail
									where bookkey = @i_bookkey
									if @v_mediatypecode not in (15) begin
										exec get_next_key @i_username, @v_nextkey out
										insert into bookverificationmessage
										      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
										values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Bar Code Indicator',@i_username, getdate() )
										set @v_failed = 1
									end else
										begin
											exec get_next_key @i_username, @v_nextkey out
											insert into bookverificationmessage
											      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
											values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Bar Code Indicator',@i_username, getdate() )
											set @v_varnings = 1
										end
								end else
									begin
										exec get_next_key @i_username, @v_nextkey out
										insert into bookverificationmessage
										      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
										values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Bar Code Indicator',@i_username, getdate() )
										set @v_varnings = 1
									end
							end
						end
					end
				end
			end
			--start check for bookweight
			select @v_bookweight = bookweight 
			from printing
			where bookkey = @i_bookkey

			exec bookverification_check 'Weight', @i_write_msg output
			if @i_write_msg = 1 begin
				if @i_verificationtypecode in(5) begin
					if @v_bookweight is null  begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Weight'+ @v_g_msg,@i_username, getdate() )
						set @v_varnings = 1
					end 
				end
			end
			--Pack Qty 
			select @v_packqty = floatvalue
			from bookmisc
			where bookkey = @i_bookkey
				and misckey = 103
			
			exec bookverification_check 'AMP Pack Qty', @i_write_msg output
			if @i_write_msg = 1 begin
				if @v_packqty is null or  @v_packqty = '' begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Pack Qty' + @v_bsg_msg,@i_username, getdate() )
					set @v_failed = 1
				end 
			end
			--S&S Edition Type Id
			SELECT @v_editiontypeid = bookmisc.longvalue
			FROM bookmisc INNER JOIN
				   bookmiscitems ON bookmisc.misckey = bookmiscitems.misckey INNER JOIN
				   subgentables ON bookmiscitems.datacode = subgentables.datacode AND bookmisc.longvalue = subgentables.datasubcode
			WHERE (bookmiscitems.miscname = 'Edition Type') AND (bookmisc.misckey = 127) AND (bookmiscitems.misckey = 127) AND (subgentables.tableid = 525)
				and bookmisc.bookkey = @i_bookkey
				
			exec bookverification_check 'AMP Edition Type', @i_write_msg output
			if @i_write_msg = 1 begin
				if @v_editiontypeid is null or  @v_editiontypeid = '' begin
					select @v_ean13 = ltrim(rtrim(ean13))
					from isbn 
					where bookkey = @i_bookkey
					if @v_ean13 not like '97807671%' and @v_ean13 not like '93416920%' begin
						select @v_mediatypecode = mediatypecode
						from bookdetail
						where bookkey = @i_bookkey
						if @v_mediatypecode not in (15) begin
							exec get_next_key @i_username, @v_nextkey out
							insert into bookverificationmessage
							      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Edition Type' + @v_bsg_msg,@i_username, getdate() )
							set @v_failed = 1
						end else
							begin
								exec get_next_key @i_username, @v_nextkey out
								insert into bookverificationmessage
								      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Edition Type' + @v_bsg_msg,@i_username, getdate() )
								set @v_varnings = 1
							end
					end else
						begin
							exec get_next_key @i_username, @v_nextkey out
							insert into bookverificationmessage
							      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Missing Edition Type' + @v_bsg_msg,@i_username, getdate() )
							set @v_varnings = 1
						end
				end 
			end	
		end 
	end


	--error - territories
--check first for the new territory structure
-- Based on client option 114 
DECLARE @territoryctrybytable TABLE (
  territoryrightskey INT,
  rightskey INT NULL,  
  contractkey INT NULL,
  bookkey INT NULL,
  countrycode INT NULL,
  forsaleind TINYINT NULL DEFAULT 0,
  contractexclusiveind TINYINT NULL DEFAULT 0,
  nonexclusivesubrightsoldind TINYINT NULL DEFAULT 0,
  currentexclusiveind TINYINT NULL DEFAULT 0,
  exclusivesubrightsoldind TINYINT NULL DEFAULT 0,
  lastuserid VARCHAR(30) NULL,
  lastmaintdate DATETIME NULL)
 
INSERT INTO @territoryctrybytable 
SELECT territoryrightskey, rightskey, contractkey, bookkey, countrycode, forsaleind, contractexclusiveind, 
        nonexclusivesubrightsoldind, currentexclusiveind, exclusivesubrightsoldind, lastuserid, lastmaintdate
FROM qtitle_get_territorycountry_by_title(@i_bookkey)        
exec bookverification_check 'AMP_Territory', @i_write_msg output
	if @i_write_msg = 1 begin
		 SELECT @v_count2 = 0

		  select @v_territoriescode = territoriescode, @v_internal_status_code = titlestatuscode, @v_mediatypecode = bookdetail.mediatypecode
			  from book b
				left outer join bookdetail on bookdetail.bookkey = b.bookkey
			  join gentables g
				  on b.territoriescode = g.datacode
			   and g.tableid = 131
				 and g.deletestatus = 'N'
				where b.bookkey = @i_bookkey 

		  --print titles now need to fail on missing territory also
			if (@v_territoriescode is null or  @v_territoriescode = 0) and @v_mediatypecode not in (56)  begin
			   SET @v_bsg_msg = 'Missing or Inactive Sales Territory information'
			   if @v_internal_status_code in (31,32,33) begin
					set @v_failed = 1				
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'AMP Territory - ' + @v_bsg_msg,@i_username, getdate() )
				end else begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'AMP Territory - ' + @v_bsg_msg,@i_username, getdate() )
				end	   
			 end 

			-- if @v_territoriescode > 0  begin
			--  set @v_cnt = 0

			--	select @v_cnt = count(*)
			--	  from book b
			--	  join gentables g
			--		  on b.territoriescode = g.datacode
			--	   and g.tableid = 131
			--		 and g.deletestatus = 'N'
			--		 and eloquencefieldtag is not null 
			--		 and exporteloquenceind=1 
			--	 where bookkey = @i_bookkey

			--	 if @v_cnt is null or @v_cnt = 0  begin
			--		SET @v_bsg_msg = 'Selected Territory value is missing Eloquence fieldtag or is inactive or hasn''t been marked to export to eloquence'
			--		set @v_failed = 1
			--		  exec get_next_key @i_username, @v_nextkey out
			--				insert into bookverificationmessage
			--				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'AMP Territory - ' + @v_bsg_msg,@i_username, getdate() )
			--				set @v_failed = 1
			--	  end 
			--end
	end


	--failed
	if @v_failed = 1 begin
		select @v_datacode = datacode
		from gentables 
		where tableid = 513
		and qsicode = 2
		
		--TOLGA: NOT SURE WHEN THE BOOKVERIFICATION RECORD IS CREATED THE FIRST TIME. WILL CHECK AND INSERT ONE IF IT DOESN'T ALREADY EXIST
		IF NOT EXISTS (Select * FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
			BEGIN
				INSERT INTO bookverification
				Select @i_bookkey, 5, @v_datacode, @i_username, getdate()
			END
		ELSE
			BEGIN
				update bookverification
				set titleverifystatuscode = @v_datacode,
					   lastmaintdate = getdate(),
					   lastuserid = @i_username
				where bookkey = @i_bookkey	
				and verificationtypecode = @i_verificationtypecode
			END
	end 

	--passed with warnings
	select @v_datacode = datacode
	from gentables 
	where tableid = 513
	and qsicode = 4

	if @v_failed = 0 and @v_varnings = 1 begin
		IF NOT EXISTS (Select * FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
			BEGIN
				INSERT INTO bookverification
				Select @i_bookkey, 5, @v_datacode, @i_username, getdate()
			END
		ELSE
			BEGIN
				update bookverification
				set titleverifystatuscode = @v_datacode,
				   lastmaintdate = getdate(),
				   lastuserid = @i_username
				where bookkey = @i_bookkey
				and verificationtypecode = @i_verificationtypecode
			end
	end 

	--passed
	select @v_datacode = datacode
	from gentables 
	where tableid = 513
	and qsicode = 3

	if @v_failed = 0 and @v_varnings = 0 begin
		IF NOT EXISTS (Select * FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
			BEGIN
				INSERT INTO bookverification
				Select @i_bookkey, 5, @v_datacode, @i_username, getdate()
			END
		ELSE
			BEGIN
				update bookverification
				set titleverifystatuscode = @v_datacode,
				   lastmaintdate = getdate(),
				   lastuserid = @i_username
				where bookkey = @i_bookkey
				and verificationtypecode = @i_verificationtypecode
			END
	end 
end


GO

GRANT EXECUTE ON dbo.AMP_Verification TO PUBLIC
GO
