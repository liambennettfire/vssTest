if exists (select * from dbo.sysobjects where id = object_id(N'dbo.KPC_To_PGI_Verify_Export') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.KPC_To_PGI_Verify_Export
GO

/******************************************************************************
**  Name: KPC_To_PGI_Verify_Export
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  06/02/2016   Uday        Case 37721 - Task 002
*******************************************************************************/

/****** Object:  StoredProcedure [dbo].[KPC_To_PGI_Verify_Export]    Script Date: 06/02/2016 16:10:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[KPC_To_PGI_Verify_Export]
		     @i_bookkey int,
		     @i_printingkey int,
		     @i_verificationtypecode int,
		     @i_username varchar(15)

AS

/* 
7/25/11 - Created for WK - TM to SLX Verification
*/

	
BEGIN 
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
SET @newtitle_creationdate = '08-01-2012'


Declare @creationdate datetime
set @CreationDate =(Select CreationDate from book where bookkey=@i_bookkey)

	declare @BisacDataCode int
	Set @bisacDatacode = (Select Bisacstatuscode from bookdetail where bookkey = @i_bookkey)

Declare @v_Error int
Declare @v_Warning int
Declare @v_Information int
Declare @v_Aborted int
Declare @v_Completed int
Declare @v_failed int
Declare @v_varnings int
Declare @v_isTitle int
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
set @v_isTitle=0



--clean bookverificationmessager for passed bookkey
delete bookverificationmessage
where bookkey = @i_bookkey
and verificationtypecode = @i_verificationtypecode

--if exists(Select 1 from book where bookkey=@i_bookkey and usageclasscode=1)
--begin

--					exec get_next_key @i_username, @v_nextkey out
--					insert into bookverificationmessage
--					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
--					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Auto-Failed - Verification is for Set Level only.',@i_username, getdate() )
--					set @v_isTitle = 1
--end
--else 
begin
	







exec bookverification_check 'KPC_To_PGI_Release_To_Pgi', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if [dbo].[rpt_get_misc_value](@i_bookkey, 44, 'long') <> 'Yes'  
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Release to PGI checkbox is not checked.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
	end

exec bookverification_check 'EAN13', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif(dbo.rpt_get_isbn(@i_bookkey,17),'') is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'EAN does not exist. Please create an Item Number/ISBN',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
	end

--exec bookverification_check 'Territory', @i_write_msg output
--if @i_write_msg = 1 
--	begin
--		if @i_verificationtypecode = 5 
--			begin
--				if nullif(dbo.rpt_get_territory(@i_bookkey,'D'),'') is null
--				begin
--					exec get_next_key @i_username, @v_nextkey out
--					insert into bookverificationmessage
--					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
--					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Territory field is incomplete. Please select a territory',@i_username, getdate() )
--					set @v_failed = 1
--				end 
--			end
--end

exec bookverification_check 'Audience', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif(dbo.rpt_get_audience(@i_bookkey,'D',1),'') is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Audience field is incomplete. Please select an audience',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'Book Title', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif(dbo.rpt_get_title(@i_bookkey,'D'),'') is null 
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Title fields are incomplete. Please enter title fields',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end
 
exec bookverification_check 'KPC_To_PGI_isPOD', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if exists (Select 1 from booksimon where formatchildcode=74 and bookkey = @i_bookkey)
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Other Format - POD are not eligible.',@i_username, getdate() )
					set @v_failed = 1
				end 
		end
end


 



exec bookverification_check 'Book Format', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif(dbo.rpt_get_format(@i_bookkey,'D'),'') is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Book format has not been entered. Please enter a book format for this set.',@i_username, getdate() )
					set @v_failed = 1
				end 

				else if nullif(dbo.rpt_get_format(@i_bookkey,'D'),'') not in ('Trade Paper','HardCover','Mass Market')
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Book format should be "Trade Paper","HardCover","Mass Market"',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end
--Select [dbo].[WK_INVPAK_get_PackagePrice](1843834)

exec bookverification_check 'Price', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
			--Select [dbo].[WK_INVPAK_get_PackagePrice](@i_bookkey)
				if dbo.rpt_get_price(@i_bookkey,8,6,'B') =''
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'US price is invalid.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end


/*exec bookverification_check 'Pub Date', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif([dbo].[KPC_to_PGI_get_date](@i_bookkey, 8),'') is null or [dbo].[KPC_to_PGI_get_date](@i_bookkey, 8) ='01/01/2049'
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Pub Date does not exist. Please select a Pub Date. ',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end*/

exec bookverification_check 'BISAC Status Code', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif([dbo].[rpt_get_gentables_field](314,@bisacDatacode , 'E'),'') is null
				begin
					print 'x'
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Bisac Status does not exist. Please select a Bisac Status. ',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'Imprint', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif([dbo].[rpt_get_group_level_3](@i_bookkey, 'F'),'') is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Imprint does not exist. Please Select an Imprint',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end


exec bookverification_check 'Discount Code', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
			
					if nullif(dbo.rpt_get_discount(@i_bookkey,'D'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
					    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)						
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Discount Code does not exist, please enter a discount code.',@i_username, getdate() )
						set @v_failed = 1
					end 
				
			end
	
end


exec bookverification_check 'Book Media', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif(dbo.rpt_get_media(@i_bookkey,'D'),'') is null or nullif(dbo.rpt_get_media(@i_bookkey,'D'),'') <>'Book'
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Media does not exist. Please enter a Media.',@i_username, getdate() )
					set @v_failed = 1
				end 
				else if nullif(dbo.rpt_get_media(@i_bookkey,'D'),'') <>'Book'
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Media type can be a "Book" only.',@i_username, getdate() )
					set @v_failed = 1

				end
			end
end

exec bookverification_check 'Primary Author', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if dbo.KPC_has_PrimaryAuthor(@i_bookkey)='n'
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Primary Author does not exist. Please select a primary author.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'Primary Author', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if dbo.KPC_get_PrimaryAuthor(@i_bookkey) ='n'
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Primary Author does not exist. Please select or create a primary author.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end





/*exec bookverification_check 'Primary Author', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if dbo.KPC_Is_Authors_Valid(@i_bookkey) ='N'
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Author First Name missing or Group Author missing name.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end
*/

exec bookverification_check 'KPC_To_PGI_OnSaleDate', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin

			if dbo.[KPC_to_PGI_get_ReissueType](@i_bookkey)='' and (Select count(*) from taqprojecttask where bookkey=@i_bookkey and taqelementkey is null and datetypecode=20003)>1
				BEGIN
					
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'There are multiple OnSale Dates',@i_username, getdate() )
					set @v_failed = 1
				END
			else if dbo.[KPC_to_PGI_get_ReissueType](@i_bookkey)='' and dbo.[KPC_to_PGI_get_date](@i_bookkey,20003) is null
				begin
				
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'On Sale Date is missing on Title.',@i_username, getdate() )
					set @v_failed = 1


							
				end
				
			
				else if dbo.[KPC_to_PGI_get_ReissueType](@i_bookkey) like '%reissue%' and dbo.[KPC_to_PGI_get_date](@i_bookkey,20003) is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'On Sale Date is missing on Reissue.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'KPC_To_PGI_ShortTitle', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if dbo.rpt_get_short_title(@i_bookkey) =''
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Short Title is missing.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'KPC_To_PGI_BisacSubject', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if dbo.rpt_get_bisac_subject(@i_bookkey,1,'d') =''
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'BISAC Subject Category is missing.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end



exec bookverification_check 'KPC_To_PGI_Trim', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if (dbo.KPC_To_PGI_Get_MiscTrim(@i_bookkey) = 'Special' and dbo.KPC_To_PGI_Get_SpecialMiscTrim(@i_bookkey) is null) or dbo.KPC_To_PGI_Get_MiscTrim(@i_bookkey) is null or dbo.KPC_To_PGI_Get_SpecialMiscTrim(@i_bookkey) like '%-%'
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
					(messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)					
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Trim size needs to be updated. Any fractional trim size should not contain a dash "-" ex :6 1/2 x 11 3/4 ',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

end				

if @v_istitle = 1
begin

IF NOT EXISTS (Select 1 FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
		BEGIN
			INSERT INTO bookverification
			Select @i_bookkey, 5,9, @i_username, getdate()

		END
	ELSE
		BEGIN
			update bookverification
			set titleverifystatuscode = 9,
				   lastmaintdate = getdate(),
				   lastuserid = @i_username
			where bookkey = @i_bookkey	
			and verificationtypecode = @i_verificationtypecode

		END

end

		
						--failed
if @v_failed = 1 
begin

	select @v_datacode = datacode
	from gentables 
	where tableid = 513
	and qsicode = 2



	--TOLGA: NOT SURE WHEN THE BOOKVERIFICATION RECORD IS CREATED THE FIRST TIME. WILL CHECK AND INSERT ONE IF IT DOESN'T ALREADY EXIST
	IF NOT EXISTS (Select 1 FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
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


/*
--passed with warnings
-- NO WARNING FOR PGI, COMMENTING OUT. IT's EITHER FAIL OR PASS


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

if @v_failed = 0 and @v_varnings = 0 and @v_istitle=0
begin

	IF NOT EXISTS (Select 1 FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
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

	end

	
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'IsCompletedSet',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'KPC_To_PGI_Territory',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'KPC_To_PGI_Audience',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Sac Code',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Sac Sum Code',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Sub Type',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Search Type',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Copy Right',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Discount Percent',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Set Type',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Order Number',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Market',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Unique Set Bookkey',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'SET Contain Components',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'TM Contain Components',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Comp_CSI_ID',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Comp_ISBN',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Comp_Bisac',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Comp_Price',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'Comp_PubDate',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'KPC_To_PGI_DiscountCode',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'KPC_To_PGI_OnSaleDate',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'KPC_To_PGI_ShortTitle',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'KPC_To_PGI_Trim',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'KPC_To_PGI_BisacSubject',1,'qsidba',getdate()
--Insert into bookverificationcolumns (ColumnName,ActiveIND,LastMaintUserID,LastMaintDate) Select 'KPC_To_PGI_isPOD',1,'qsidba',getdate()

--Select * from bookverificationcolumns order by 1



GO

GRANT EXECUTE ON dbo.KPC_To_PGI_Verify_Export TO PUBLIC
GO

