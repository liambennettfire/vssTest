GO

/****** Object:  StoredProcedure [dbo].[HMH_Verify_OnixPreverification]    Script Date: 05/22/2014 13:56:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HMH_Verify_OnixPreverification]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[HMH_Verify_OnixPreverification]
GO


GO

/****** Object:  StoredProcedure [dbo].[HMH_Verify_OnixPreverification]    Script Date: 05/22/2014 13:56:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[HMH_Verify_OnixPreverification]
		     @i_bookkey int,
		     @i_printingkey int,
		     @i_verificationtypecode int,
		     @i_username varchar(15)

AS

/* 
Last update on 4/16/2014. Added OP.
*/

	
BEGIN 
--grant execute on [dbo].[HMH_Verify_OnixPreverification] to public
/*

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

Declare @i_IsWarnings int
Declare @i_write_msg int
Declare @v_nextkey int
Declare @v_Datacode varchar(255)

--gentables 539
set @v_Error = 2
set @v_Warning = 3
set @v_Information = 4
set @v_Aborted = 5
set @v_Completed = 6

set @v_failed = 0 
set @i_IsWarnings = 0



--clean bookverificationmessager for passed bookkey
delete bookverificationmessage
where bookkey = @i_bookkey
and verificationtypecode = @i_verificationtypecode



	select @v_datacode = datacode
	from gentables 
	where tableid = 513
	and qsicode = 2
	
	
	if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HMH_ISBN13')
	begin
		insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		Select 'HMH_ISBN13',1,'qsidba',GETDATE()

		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HMH_BisacStatus')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'HMH_BisacStatus',1,'qsidba',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HMH_MaterialType')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'HMH_MaterialType',1,'qsidba',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HMH_MaterialGroup')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'HMH_MaterialGroup',1,'qsidba',GETDATE()
		end
		if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HMH_Imprint')
		begin
			insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
			Select 'HMH_Imprint',1,'qsidba',GETDATE()
		end
		--if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HMH_Reprint')
		--begin
		--	insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
		--	Select 'HMH_Reprint',1,'qsidba',GETDATE()--Slot field
		--end
	
	end	
	
	exec bookverification_check 'HMH_ISBN13', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if len(dbo.rpt_get_isbn(@i_bookkey,17))<>13
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Invalid ISBN',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end





exec bookverification_check 'HMH_BisacStatus', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.rpt_get_bisac_status(@i_bookkey,'D'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'BISAC Status Missing. Please a BISAC Status',@i_username, getdate() )
						set @v_failed = 1
					end 
					else if dbo.HMH_Skip_BISAC_Verification(@i_bookkey) = 'false' 
					begin
						 if (dbo.rpt_get_bisac_status(@i_bookkey,'D') not in ('Active','PP - PrePrint','Special Status','Not Yet Published','Temporarily out of Stock','Out of Stock Indefinitely','On Demand','Out of Print','Withdrawn from Sale','Publication Cancelled'))
						begin
						
							exec get_next_key @i_username, @v_nextkey out
							insert into bookverificationmessage
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_warning, 'BISAC Status not valid for outbox.',@i_username, getdate() )
							Set @i_IsWarnings=1
						end
						-- 6/04/2014 - change- if BISAC Status = Preprint and misc item 131 not in (PPIO or IO) then remove from outbox
						if (dbo.rpt_get_bisac_status(@i_bookkey,'D'))  = 'PP - PrePrint' and @i_bookkey not in (select bookkey from bookmisc where misckey=132 and longvalue in (1,2))
     						begin 
     								exec get_next_key @i_username, @v_nextkey out
     							insert into bookverificationmessage
     							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_warning, 'PrePrint title that is not PPIO or IO not valid for outbox.',@i_username, getdate() )
     							Set @i_IsWarnings=1
     						end
							
					end
					
				end
		end
		
		exec bookverification_check 'HMH_MaterialType', @i_write_msg output
		if @i_write_msg = 1 
			begin
				if @i_verificationtypecode = 5 
					begin
						if nullif(dbo.rpt_get_misc_Value(@i_bookkey,22,'long'),'') is null
						begin
							exec get_next_key @i_username, @v_nextkey out
							insert into bookverificationmessage
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Material Type is Missing. Please select a Material Type',@i_username, getdate() )
							set @v_failed = 1
						end 
						if dbo.rpt_get_media(@i_bookkey,'D')='Ebook Format' begin
							 if (dbo.rpt_get_misc_Value(@i_bookkey,22,'long') not in ('DIEN - Services'))
							begin
							
								exec get_next_key @i_username, @v_nextkey out
								insert into bookverificationmessage
								values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_warning, 'Material Type not valid for outbox.',@i_username, getdate() )
								Set @i_IsWarnings=1
							end
						end
						else if (dbo.rpt_get_misc_Value(@i_bookkey,22,'long') not in ('FERT - Finished Goods','ZNBW - Distribution Client'))
						begin
						
							exec get_next_key @i_username, @v_nextkey out
							insert into bookverificationmessage
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_warning, 'Material Type not valid for outbox.',@i_username, getdate() )
							Set @i_IsWarnings=1
						end
					end
			end
		
		
	exec bookverification_check 'HMH_MaterialGroup', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.rpt_get_misc_Value(@i_bookkey,15,'long'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Material Group is Missing. Please select a Material Type',@i_username, getdate() )
						set @v_failed = 1
					end 
						if dbo.rpt_get_media(@i_bookkey,'D')='Ebook Format' begin
							if (dbo.rpt_get_misc_Value(@i_bookkey,15,'long') not in ('H00-003 Online','H00-072 Digital Download','H00-080 Software Download','H00-081 Mobile Apps'))
							begin
							
								exec get_next_key @i_username, @v_nextkey out
								insert into bookverificationmessage
								values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_warning, 'Material Type not valid for outbox.',@i_username, getdate() )
								Set @i_IsWarnings=1
							end
					end
					else if ltrim(rtrim(dbo.rpt_get_misc_Value(@i_bookkey,15,'long'))) not in ('H00-024 Binder','H00-001 Book','H00-015 Box(Kit)','H00-004 CD','H00-065 Display','H00-002 Kit','H00-060 Map','H00-009 Calender')
					begin
					
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_warning, 'Material group not valid for outbox.',@i_username, getdate() )
						Set @i_IsWarnings=1
					end
				end
		end
		
			exec bookverification_check 'HMH_Imprint', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 5 
				begin
					if nullif(dbo.rpt_get_group_level_4(@i_bookkey,'F'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Imprint Type is Missing. Please select an Imprint',@i_username, getdate() )
						set @v_failed = 1
					end 
					
				end
		end
	--exec bookverification_check 'HMH_reprint', @i_write_msg output
	--if @i_write_msg = 1 
	--	begin
	--		if @i_verificationtypecode = 5 
	--			begin
	--				if nullif(dbo.rpt_get_misc_value(@i_bookkey,136,'long'),'') is null
	--				begin
	--					exec get_next_key @i_username, @v_nextkey out
	--					insert into bookverificationmessage
	--					values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Reprint\Slot is Missing. Please select a Reprint\Slot',@i_username, getdate() )
	--					set @v_failed = 1
	--				end 
	--				else if ltrim(rtrim(dbo.rpt_get_misc_Value(@i_bookkey,136,'long'))) <> '0005-Out of Print'
	--				begin
					
	--					exec get_next_key @i_username, @v_nextkey out
	--					insert into bookverificationmessage
	--					values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_warning, 'Reprint\Slot not valid for outbox.',@i_username, getdate() )
	--					Set @i_IsWarnings=1
	--				end
	--			end
	--	end



	--TOLGA: NOT SURE WHEN THE BOOKVERIFICATION RECORD IS CREAtED THE FIRST TIME. WILL CHECK AND INSERT ONE IF IT DOESN'T ALREADY EXIST
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





--passed with warnings
--UPDATE gentables
--SET qsicode=5
--WHERE tableid=513 AND datacode=9


--EXCLUDED FROM ONIX

if @v_failed = 0 and @i_IsWarnings = 1 
begin

select @v_datacode = datacode
from gentables 
where tableid = 513
and qsicode = 5

	update bookverification
	set titleverifystatuscode = @v_datacode,
       lastmaintdate = getdate(),
       lastuserid = @i_username
 	where bookkey = @i_bookkey
	and verificationtypecode = @i_verificationtypecode

end 

--passed
select @v_datacode = datacode
from gentables 
where tableid = 513
and qsicode = 3

if @v_failed = 0 and @i_IsWarnings = 0
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

end




GO


grant all on [dbo].[HMH_Verify_OnixPreverification] to public