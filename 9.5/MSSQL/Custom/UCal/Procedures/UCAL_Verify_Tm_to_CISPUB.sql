if exists (select * from dbo.sysobjects where id = object_id(N'dbo.UCAL_Verify_Tm_to_CISPUB') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.UCAL_Verify_Tm_to_CISPUB
GO

/******************************************************************************
**  Name: UCAL_Verify_Tm_to_CISPUB
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  02/16/2016   Colman      Case 36337
*******************************************************************************/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UCAL_Verify_Tm_to_CISPUB]
		     @i_bookkey int,
		     @i_printingkey int,
		     @i_verificationtypecode int,
		     @i_username varchar(15)

AS

/* 
7/25/11 - Created for WK - TM to SLX Verification
*/

	
BEGIN 
--grant execute on dbo.WK_Verify_Tm_to_SLX to public
/*

Update this field before go-live
if book.creationdate > @createiondate it means it is a brand new title
Some of the fields will only be required for new titles, 
it is okay to have blank values in those fields for converted titles

Select top 100 * FROM bookverificationmessage

Select TOP 100 * FROM bookverification
WHERE verificationtypecode = 1

*/

DECLARE @newtitle_creationdate datetime
SET @newtitle_creationdate = '09-06-2011'


Declare @creationdate datetime
set @CreationDate =(Select CreationDate from book where bookkey=@i_bookkey)

	declare @BisacDataCode int
	Set @bisacDatacode = (Select Bisacstatuscode from bookdetail where bookkey = @i_bookkey)
	
	declare @workkey as int
	set @workkey = (Select workkey from book where bookkey=@i_bookkey)

Declare @v_Error int
Declare @v_Warning int
Declare @v_Information int
Declare @v_Aborted int
Declare @v_Completed int
Declare @v_failed int
Declare @v_varnings int
Declare @i_write_msg int
Declare @v_nextkey int
Declare @v_Datacode varchar(255)


set @v_Error = 2
set @v_Warning = 3
set @v_Information = 4
set @v_Aborted = 5
set @v_Completed = 6
set @v_failed = 0 
set @v_varnings = 0



--clean bookverificationmessager for passed bookkey
delete bookverificationmessage
where bookkey = @i_bookkey
and verificationtypecode = @i_verificationtypecode



	select @v_datacode = datacode
	from gentables 
	where tableid = 513
	and qsicode = 2
	
	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_ISBN13')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_ISBN13',1,'qsidba',GETDATE()
	end
	--if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_Title')
	--begin
	--	insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
	--	Select 'UCAL_Title',1,'qsidba',GETDATE()
	--end
	--if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_ShortTitle')
	--begin
	--	insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
	--	Select 'UCAL_ShortTitle',1,'qsidba',GETDATE()
	--end
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_Binding')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_Binding',1,'qsidba',GETDATE()
	end
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_ProductLine')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_ProductLine',1,'qsidba',GETDATE()
	end
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_Edition')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_Edition',1,'qsidba',GETDATE()
	end
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_ISBN10')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_ISBN10',1,'qsidba',GETDATE()
	end
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_DiscountCode')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_DiscountCode',1,'qsidba',GETDATE()
	end
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_CopyRightYear')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_CopyRightYear',1,'qsidba',GETDATE()
	end
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_PubDate')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_PubDate',1,'qsidba',GETDATE()
	end
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_BNumber')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_BNumber',1,'qsidba',GETDATE()
	end
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_Publisher')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_Publisher',1,'qsidba',GETDATE()
	end
	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_MajorSubject')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_MajorSubject',1,'qsidba',GETDATE()
	end
	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_USPrice')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_USPrice',1,'qsidba',GETDATE()
	end
	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_AuthorName')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_AuthorName',1,'qsidba',GETDATE()
	end
	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_MinorSubject')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_MinorSubject',1,'qsidba',GETDATE()
	end
	
	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_Pages')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_Pages',1,'qsidba',GETDATE()
	end	
	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_AcqEditor')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_AcqEditor',1,'qsidba',GETDATE()
	end	
	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_PC')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_PC',1,'qsidba',GETDATE()
	end	
	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_Season')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_Season',1,'qsidba',GETDATE()
	end	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_Length')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_Length',1,'qsidba',GETDATE()
	end	
	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_Width')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_Width',1,'qsidba',GETDATE()
	end	
	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_TitleStatus')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_TitleStatus',1,'qsidba',GETDATE()
	end
	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_Activate')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_Activate',1,'qsidba',GETDATE()
	end
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_Territory')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_Territory',1,'qsidba',GETDATE()
	end
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='UCAL_ProductTypeMisc')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'UCAL_ProductTypeMisc',1,'qsidba',GETDATE()
	end

	--exec bookverification_check 'UCAL_TitleStatus', @i_write_msg output
	--if @i_write_msg = 1 
	--	begin
	--		if @i_verificationtypecode = 5 
	--			begin
	--				if not exists(Select 1 from book where bookkey =@i_bookkey and titlestatuscode = 6)
	--				begin
	--					exec get_next_key @i_username, @v_nextkey out
	--					insert into bookverificationmessage
	--					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Internal Title Status is not "Published".',@i_username, getdate() )
	--					set @v_failed = 1
	--				end 
	--			end
	--	end
	
	
	exec bookverification_check 'UCAL_ISBN13', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if len(dbo.rpt_get_isbn(@i_bookkey,17))<>13
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Invalid ISBN',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
		
	exec bookverification_check 'UCAL_Territory', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.rpt_get_territory(@i_bookkey,'d') ,'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Territory',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end


--exec bookverification_check 'UCAL_Title', @i_write_msg output
--	if @i_write_msg = 1 
--		begin
--			if @i_verificationtypecode = 5 
--				begin --will have to change function for truncation/substitution
--					if nullif(dbo.rpt_get_misc_value(@i_bookkey,227,'D'),'') is null or LEN(dbo.rpt_get_misc_value(@i_bookkey,227,'D'))>60
--					begin
--						exec get_next_key @i_username, @v_nextkey out
--						insert into bookverificationmessage
--						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'CISPUB Long Title is Missing or greater than 60 characters.',@i_username, getdate() )
--						set @v_failed = 1
--					end 
--				end
--		end
		
--exec bookverification_check 'UCAL_ShortTitle', @i_write_msg output
--	if @i_write_msg = 1 
--		begin
--			if @i_verificationtypecode = 5 
--				begin
--					if nullif(dbo.rpt_get_misc_value(@i_bookkey,227,'D'),'') is null or LEN(dbo.rpt_get_misc_value(@i_bookkey,227,'D'))>60
--					begin
--						exec get_next_key @i_username, @v_nextkey out
--						insert into bookverificationmessage
--						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'CISPUB Short Title is Missing or greater than 20 characters.',@i_username, getdate() )
--						set @v_failed = 1
--					end 
--				end
--		end

exec bookverification_check 'UCAL_Binding', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.UCal_Get_ProductType(@i_bookkey),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values	 (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Binding Missing. Please select Media/Format',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
	exec bookverification_check 'UCAL_ProductLine', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.rpt_get_group_level_3(@i_bookkey,'2'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Product Line is missing for this org entry. (Level 3 - Alt Desc 2)',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		exec bookverification_check 'UCAL_Edition', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.rpt_get_edition_number(@i_bookkey,'D'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Edition # missing. Please enter an Edition #.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		exec bookverification_check 'UCAL_ISBN10', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif([dbo].[rpt_get_isbn](@i_bookkey,10),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'ISBN is missing.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end		
		
		
		
				
		exec bookverification_check 'UCAL_CopyRightYear', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.UCAL_Get_CopyRightYear(@i_bookkey),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Copyright Year Missing.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		exec bookverification_check 'UCAL_PubDate', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(isnull(dbo.Ucal_fixDate(isnull(dbo.rpt_get_best_pub_date(@i_bookkey,1),'01-01-1900')),''),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Pub Date Missing. Please enter a Pub Date.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		exec bookverification_check 'UCAL_BNumber', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.UCAL_Get_BNumber(@workkey),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'BNumber is Missing at the Project Level.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
--Ben Todd added activate indicator check to verification - 2013-01-23
		exec bookverification_check 'UCAL_Activate', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if dbo.rpt_ucal_get_tm2cispub_activate (@i_bookkey,1) = 0
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Activate indicator is not set.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end		
		--		select dbo.rpt_ucal_get_tm2cispub_activate (5285660,1)
--End Updates by Ben Todd for activate indicator		
		exec bookverification_check 'UCAL_Publisher', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.rpt_get_group_level_2(@i_bookkey,'2'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Publisher is missing, Please choose a publisher.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
	exec bookverification_check 'UCAL_MajorSubject', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					/*if coalesce(nullif([dbo].[qweb_get_BookSubjects](@i_bookkey,1,1,'E',1),''),
								nullif([dbo].[qweb_get_BookSubjects](@i_bookkey,1,1,'E',2),''),
								nullif([dbo].[qweb_get_BookSubjects](@i_bookkey,1,1,'E',3),'')
								)
								 is null*/
								 
					if dbo.UCAL_Verify_Subjects(@i_bookkey,412,'E')='Failed'

					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Subject(s) is/are missing or invalid.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
		exec bookverification_check 'UCAL_USPrice', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.rpt_get_best_us_price(@i_bookkey,8),'') is null or not exists(Select 1 from bookprice where bookkey = @i_bookkey and pricetypecode = 8)
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'US Price Missing',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		exec bookverification_check 'UCAL_AuthorName', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif([dbo].[UCAL_get_author_all_name](@i_bookkey,50,12,'F',char(9)) ,'') is null and nullif([dbo].[UCAL_get_author_all_name](@i_bookkey,50,12,'L',char(9)),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Primary Author/Editor, Please Enter an Author.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
	----exec bookverification_check 'UCAL_MinorSubject', @i_write_msg output
	----if @i_write_msg = 1 
	----	begin
	----		if @i_verificationtypecode = 5 
	----			begin
	----				if coalesce(nullif([dbo].[qweb_get_BookSubjects](@i_bookkey,1,2,'E',1),''),
	----							nullif([dbo].[qweb_get_BookSubjects](@i_bookkey,1,2,'E',2),''),
	----							nullif([dbo].[qweb_get_BookSubjects](@i_bookkey,1,2,'E',3),'')) is null

	----				begin
	----					exec get_next_key @i_username, @v_nextkey out
	----					insert into bookverificationmessage
	----					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Minor Subject is missing or invalid.',@i_username, getdate() )
	----					set @v_failed = 1
	----				end 
	----			end
	----	end
		
		
		
		exec bookverification_check 'UCAL_ACQEditor', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.UCAL_Get_Sponsors(@I_bookkey,154),'') is null and nullif(dbo.UCAL_Get_Sponsors(@workkey,154),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Acquisition Editor is missing.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end

		exec bookverification_check 'UCAL_PC', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if (nullif(dbo.UCAL_Get_Sponsors(@I_bookkey,155),'') is null and nullif(dbo.UCAL_Get_Sponsors(@workkey,155),'') is null) and dbo.rpt_get_group_level_3(@i_bookkey,'F') = 'University of California Press'
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'PC is missing.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end


		exec bookverification_check 'UCAL_Season', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.Ucal_Get_Season(@i_bookkey),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Season is missing.',@i_username, getdate() )
						set @v_failed = 1
					end 
					if right(nullif(dbo.rpt_get_Season(@i_bookkey,'B'),''),4)> YEAR(getdate())+1
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Season is more than one year out.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
		if dbo.rpt_get_media(@i_bookkey,'D') <>'Ebook Format' begin
		exec bookverification_check 'UCAL_DiscountCode', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.UCal_Get_Discount(@i_bookkey),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Discount Missing. Please enter a Discount.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		exec bookverification_check 'UCAL_ProductTypeMisc', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.rpt_get_misc_value(@i_bookkey,253,'long'),'') is null 
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Product Type Misc Field Missing. Please enter a Product Type.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
		
		
		exec bookverification_check 'UCAL_Length', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.UCAL_get_Trim(@i_bookkey,1),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Length of book is missing.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
		exec bookverification_check 'UCAL_Width', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.UCAL_get_Trim(@i_bookkey,2),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Width of book is missing.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		exec bookverification_check 'UCAL_Pages', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.rpt_get_page_count(@i_bookkey,1,'B'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Number of Pages are missing.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
		end
	--TOLGA: NOT SURE WHEN THE BOOKVERIFICATION RECORD IS CREAtED THE FIRST TIME. WILL CHECK AND INSERT ONE IF IT DOESN'T ALREADY EXIST
	IF NOT EXISTS (Select top 1 1 FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
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


/*
--passed with warnings

select @v_datacode = datacode
from gentables 
where tableid = 513
and qsicode = 4

if @v_failed = 0 and @v_varnings = 1 
begin
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

*/


--passed
select @v_datacode = datacode
from gentables 
where tableid = 513
and qsicode = 3

if @v_failed = 0 and @v_varnings = 0 
begin

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

grant execute on UCAL_Verify_Tm_to_CISPUB to public
