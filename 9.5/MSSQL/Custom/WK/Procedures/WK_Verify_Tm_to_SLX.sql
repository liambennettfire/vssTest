/****** Object:  StoredProcedure [dbo].[WK_Verify_Tm_to_SLX]    Script Date: 2/16/2016 3:23:05 PM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.UCAL_Verify_Tm_to_CISPUB') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_Verify_Tm_to_SLX
GO

/******************************************************************************
**  Name: WK_Verify_Tm_to_SLX
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

CREATE PROCEDURE [dbo].[WK_Verify_Tm_to_SLX]
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
set @v_istitle =0



--clean bookverificationmessager for passed bookkey
delete bookverificationmessage
where bookkey = @i_bookkey
and verificationtypecode = @i_verificationtypecode

if exists(Select 1 from book where bookkey=@i_bookkey and usageclasscode=1)
begin

					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Verification is for Set Level only.',@i_username, getdate() )
					set @v_isTitle = 1
end
else begin
	
exec bookverification_check 'IsCompletedSet', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if [dbo].[rpt_get_misc_value](@i_bookkey, 51, 'long') <> 'Yes'  
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Set Is not marked as completed.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
	end

exec bookverification_check 'EAN13', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif(dbo.WK_get_itemnumber(@i_bookkey),'') is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'EAN or Item Number does not exist. Please create an Item Number/ISBN',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
	end

exec bookverification_check 'Territory', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif(dbo.rpt_get_territory(@i_bookkey,'D'),'') is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Territory field is incomplete. Please select a territory',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

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
				if nullif(dbo.WK_get_title(@i_bookkey),'') is null 
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Title fields are incomplete. Please enter title fields',@i_username, getdate() )
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
			end
end
--Select [dbo].[WK_INVPAK_get_PackagePrice](1843834)

exec bookverification_check 'Price', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
			--Select [dbo].[WK_INVPAK_get_PackagePrice](@i_bookkey)
				if [dbo].[WK_INVPAK_get_PackagePrice](@i_bookkey) is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Calculated price is invalid. Please check component prices.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end


exec bookverification_check 'Sac Code', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				--Select dbo.[qweb_get_BookSubjects](1843834,1,0,'D',3)
				if nullif(dbo.[qweb_get_BookSubjects](@i_bookkey,1,0,'D',3),'') is null 
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'SAC does not exist. Please select a SAC ',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'Sac Sum Code', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
					--select [dbo].[qweb_get_BookSubjects](1843834,1,0,'D',2)
					
				if nullif([dbo].[qweb_get_BookSubjects](@i_bookkey,1,0,'D',2),'') is null 
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'SAC Sum does not exist. Please select a SAC SUM ',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'Sub Type', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif(dbo.qweb_get_BookSubjects(@i_bookkey, 5,0,'E',2),'') is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Product Sub Type does not exist. Please select a sub type. ',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end


exec bookverification_check 'Search Type', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif(dbo.qweb_get_BookSubjects(@i_bookkey, 5,0,'E',1),'') is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Product Search Type does not exist. Please select a Search type. ',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'Copy Right', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif([dbo].[rpt_get_misc_value](@i_bookkey, 44, 'long'),'') is null 
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Copy Right Year does not exist. Please select a Copy Right Year. ',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'Pub Date', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif([dbo].[rpt_get_best_pub_date](@i_bookkey, 1),'') is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Pub Date does not exist. Please select a Pub Date. ',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'BISAC Status Code', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if @bisacDatacode is null or nullif([dbo].[rpt_get_gentables_field](314,@bisacDatacode , 'E'),'') is null
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
				if nullif([dbo].[rpt_get_group_level_4](@i_bookkey, 'F'),'') is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Imprint does not exist. Please Select an Imprint',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

/* --removing the 0% discount check b/c it is no longer needed by the business
exec bookverification_check 'Discount Percent', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if dbo.WK_get_setType(@i_bookkey)in ('Adhoc','Custom')begin
					if nullif(dbo.WK_get_Discount_Percent(@i_bookkey),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Discount Percent does not exist, please enter a discount percent',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
			end
	
end
*/

exec bookverification_check 'DiscountCode', @i_write_msg output
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


exec bookverification_check 'Set Type', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif(dbo.WK_get_setType(@i_bookkey),'') is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Set type does not exist. Please Select a set type',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'Order Number', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if dbo.WK_get_setType(@i_bookkey) in ('AdHoc','Custom') and nullif([dbo].[rpt_get_misc_value](@i_bookkey, 54, 'long'),'')  is null and (@CreationDate is null or @CreationDate>=@newtitle_creationdate)
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Order Number does not exist. Please enter an Order Number.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'Market', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif([dbo].[qweb_get_BookSubjects](@i_bookkey,1,0,'D',2),'') is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Market does not exist. Please enter a Market.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'Book Media', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if nullif(dbo.rpt_get_media(@i_bookkey,'D'),'') is null
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Media does not exist. Please enter a Media.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'Primary Author', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if dbo.WK_has_PrimaryAuthor(@i_bookkey)='n'
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
				if dbo.WK_get_PrimaryAuthor(@i_bookkey) ='n'
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'A Primary Author does not exist. Please select or create a primary author.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'Unique Set Bookkey', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if exists(Select associatetitlebookkey,Count(*) from associatedtitles where associationtypecode in (9,11)and associationtypesubcode =1 and bookkey=@i_bookkey group by associatetitlebookkey having count(*)>1)
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'This set has more than 1 isbn. ',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end


exec bookverification_check 'Unique Set Bookkey', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if NOT EXISTS(Select * FROM associatedtitles where bookkey = @i_bookkey and associationtypecode in (9,11) and associationtypesubcode = 1)
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'This set has more than 1 isbn. ',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'SET Contain Components', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if NOT EXISTS(Select * FROM associatedtitles where bookkey = @i_bookkey and associationtypecode in (9,11) and associationtypesubcode = 1)
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'This set does not have components ',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end

exec bookverification_check 'TM Contain Components', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				IF  EXISTS (Select * FROM associatedtitles where bookkey = @i_bookkey and associationtypecode in (9,11) and associationtypesubcode = 1 and associatetitlebookkey = 0)
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'This set does not have components in Title Management.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end
exec bookverification_check 'Primary Author', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if dbo.WK_Is_Authors_Valid(@i_bookkey) ='N'
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Author First Name missing or Group Author missing name.',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
end


			DECLARE @i_bookkey_component int
				DECLARE @i_titlefetchstatus int


					DECLARE c_components  CURSOR LOCAL
							FOR
							
							Select associatetitlebookkey FROM associatedtitles
							WHERE bookkey = @i_bookkey and associationtypecode in (9,11) and associationtypesubcode = 1

							FOR READ ONLY
									
							OPEN c_components 

							FETCH NEXT FROM c_components 
								INTO @i_bookkey_component
								select  @i_titlefetchstatus  = @@FETCH_STATUS

										 while (@i_titlefetchstatus >-1 )
											begin
												IF (@i_titlefetchstatus <>-2) 
												begin
														--FIRST CHECK ON ITEM NUMBER
													exec bookverification_check 'Comp_ISBN', @i_write_msg output
													if @i_write_msg = 1 
														begin
															if @i_verificationtypecode = 5 
																begin
																	IF  dbo.WK_get_itemnumber(@i_bookkey_component) = ''
																	begin
																		exec get_next_key @i_username, @v_nextkey out
																		insert into bookverificationmessage
                                    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
																		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Component '+dbo.rpt_get_isbn(@i_bookkey_component,17)+' does not have an ISBN. Please assign an ISBN.',@i_username, getdate() )
																		set @v_failed = 1
																	end 
																end
													end
														--ALL COMPONENTS MUST ALREADY BE PUBLISHED TO ADVANTAGE/CSI
														
														exec bookverification_check 'Comp_Bisac', @i_write_msg output
														if @i_write_msg = 1 
															begin
																if @i_verificationtypecode = 5 
																	begin
																		If NOT EXISTS (Select * FROM bookmisc where bookkey = @i_bookkey_component and misckey = 29 and textvalue is NOT NULL and textvalue <> '')
																		begin
																			exec get_next_key @i_username, @v_nextkey out
																			insert into bookverificationmessage
                                      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
																			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Component '+dbo.rpt_get_isbn(@i_bookkey_component,17)+' has not been published to SLX/ADV yet.',@i_username, getdate() )
																			set @v_failed = 1
																		end 
																	end
														end		

														-- ALL COMPONENTS MUST HAVE BISAC TITLE STATUS
														--PACKAGE STATUS WILL BE DERIVED FROM COMPONENT STATUS CODES
														--IF ALREADY PUBLISHED TO ADV, THE TITLE SHOULD HAVE A STATUS CODE
													exec bookverification_check 'Comp_Bisac', @i_write_msg output
													if @i_write_msg = 1 
														begin
															if @i_verificationtypecode = 5 
																begin
																	IF [dbo].[rpt_get_bisac_status](@i_bookkey_component, 'E') IS NULL OR [dbo].[rpt_get_bisac_status](@i_bookkey_component, 'E') = ''
																	begin
																		exec get_next_key @i_username, @v_nextkey out
																		insert into bookverificationmessage
                                    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
																		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Component '+dbo.rpt_get_isbn(@i_bookkey_component,17)+' does not have an Bisac Status. Please assign a Bisac Status to the componenet.',@i_username, getdate() )
																		set @v_failed = 1
																	end 
																end
													end
													exec bookverification_check 'Comp_Price', @i_write_msg output
													if @i_write_msg = 1 
														begin
															if @i_verificationtypecode = 5 
																begin
																	IF dbo.WK_INPAK_getComponentPrice(@i_bookkey_component) IS NULL 
																	begin
																		exec get_next_key @i_username, @v_nextkey out
																		insert into bookverificationmessage
                                    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
																		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Component '+dbo.rpt_get_isbn(@i_bookkey_component,17)+' does not have a price. Please assign a price to the componenet.',@i_username, getdate() )
																		set @v_failed = 1
																	end 
																end
													end
														--All components have to have a pub date
													exec bookverification_check 'Comp_PubDate', @i_write_msg output
													if @i_write_msg = 1 
														begin
															if @i_verificationtypecode = 5 
																begin
																	IF dbo.rpt_get_date(@i_bookkey_component, 1, 8, 'B') IS NULL
																	begin
																		exec get_next_key @i_username, @v_nextkey out
																		insert into bookverificationmessage
                                    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
																		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Component '+dbo.rpt_get_isbn(@i_bookkey_component,17)+' does not have a pub date. Please assign a pub date to the componenet.',@i_username, getdate() )
																		set @v_failed = 1
																	end 
																end
													end

												end
												FETCH NEXT FROM c_components
													INTO @i_bookkey_component
														select  @i_titlefetchstatus  = @@FETCH_STATUS
											end
									

						close c_components
						deallocate c_components
end			

if @v_isTitle = 1
begin
IF NOT EXISTS (Select * FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
		BEGIN
			INSERT INTO bookverification
			Select @i_bookkey, 5, 9, @i_username, getdate()

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

if @v_failed = 0 and @v_varnings = 0  and @v_isTitle=0
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

grant execute on WK_Verify_Tm_to_SLX to public
