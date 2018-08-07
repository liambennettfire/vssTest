if exists (select * from dbo.sysobjects where id = object_id(N'dbo.PGI_verify_eloquence_preverification') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.PGI_verify_eloquence_preverification
GO

/******************************************************************************
**  Name: PGI_verify_eloquence_preverification
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

/****** Object:  StoredProcedure [dbo].[PGI_verify_eloquence_preverification]    Script Date: 02/11/2016 14:30:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PGI_verify_eloquence_preverification]
		     @i_bookkey int,
		     @i_printingkey int,
		     @i_verificationtypecode int,
		     @i_username varchar(15)

AS

--Select * from gentables where tableid=556
/* 
5/31/11 - Created for PGI to verify existence of fields to be used in interface from TM to SAP Material Master

*/

BEGIN 

/*
DO NOTHING IF THIS IS A CANADIAN TITLE
*/

IF not exists (Select 1 from  bookorgentry bo   
					join orgentry oe  
					on bo.orgentrykey = oe.orgentrykey   
					where bo.bookkey = @i_bookkey and bo.orglevelkey = 1 and oe.orgentrykey = 1) --oe.orgentrydesc like 'Penguin US%') 
 BEGIN  
  RETURN   
 END




DECLARE @newtitle_creationdate datetime
SET @newtitle_creationdate = '07-26-2011'


Declare @v_Error int
Declare @v_Warning int
Declare @v_Information int
Declare @v_Aborted int
Declare @v_Completed int
Declare @v_failed int
Declare @v_varnings int
Declare @i_write_msg int
Declare @v_nextkey int
Declare @v_Datacode int
Declare @v_excluded_from_onix int

DECLARE @msg varchar(512)
SET @msg = ''


-- init variables
/************
@v_Error MAPS TO 

Select qsicode, * from gentables
where tableid = 513 and qsicode = 2

*/
set @v_Error = 2

set @v_Warning = 3
set @v_Information = 4
set @v_Aborted = 5
set @v_Completed = 6
set @v_failed = 0 
set @v_varnings = 0
set @v_excluded_from_onix = 0


--clean bookverificationmessager for passed bookkey
delete bookverificationmessage
where bookkey = @i_bookkey
and verificationtypecode = @i_verificationtypecode


if not exists (Select 1 from bookverificationcolumns where columnname like 'Pgi_elo%')
begin
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_Materialtype',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_DownloadableAudio',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_ActiveBatchPrice',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_StatusCode',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_Prefix',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_OrgXXXX',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_IsISBN13',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_Price',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_InventoryStatus',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_NonOnixTitle',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_NpFpTitleNoPubDate',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_MaterialGroups',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_ISBN300',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_hasMediaType',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'PGI_Elo_Preverification_NonOnixTitle',1,'qsidba',GETDATE()
end

/*
while adding a brand new title form TM WEb, the app runs book verification routines before populating the ISBN table
therefore, the initial status of this verification gets incorrectly set to "Excluded from ONIX"
The below section is added as a quick fix
Always assign "Ready for Verificaition, if lastmaintdate is within 2 mins 
and there is no ISBN record yet, assume the title record has just been added
and assign a status of "Ready For Verification"


IF NOT EXISTS (Select * FROM isbn i join book b on i.bookkey = b.bookkey where i.bookkey = @i_bookkey and b.standardind = 'N') AND (Select DATEDIFF(minute, lastmaintdate, getdate()) from book where bookkey = @i_bookkey and standardind = 'N') < 3
if @i_verificationtypecode = 6 
	begin
		IF NOT EXISTS (Select * FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
				BEGIN
					INSERT INTO bookverification 
					Select @i_bookkey, 6, 5, @i_username, getdate() --5 is ready for verification

				END
		ELSE
				BEGIN
					update bookverification
					set titleverifystatuscode = 5,
					   lastmaintdate = getdate(),
					   lastuserid = @i_username
					where bookkey = @i_bookkey
					and verificationtypecode = @i_verificationtypecode
				END

		RETURN
	end

--THIS ONE DID NOT WORK EITHER! 
--BETTER SOLUTION, ONLY INSERT READY FOR VERIFICATION IF IT IS A BRAND NEW TITLE 
IF NOT EXISTS (Select * FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
	BEGIN
		INSERT INTO bookverification 
		Select @i_bookkey, 6, 5, @i_username, getdate() --5 is ready for verification

		RETURN
	END

*/


DECLARE @v_title varchar(255),
@v_standardind char(1),
@v_mediatypecode smallint,
@v_mediatypesubcode smallint,
@v_bisacstatuscode smallint


select @v_title = b.title, @v_mediatypecode = mediatypecode, @v_mediatypesubcode = mediatypesubcode,
@v_bisacstatuscode = bd.bisacstatuscode,
@v_standardind = b.standardind
from bookdetail bd
JOIN book b
on bd.bookkey = b.bookkey
where b.bookkey = @i_bookkey





/*
THIS SECTION IS ADDED TO SET THE STATUS TO "READY FOR VERIFICATION" FOR NEW TITLES
Creationdate is sometimes not recorded correctly. If you add a title in the afternoon, the app records the time component in a.m 
RULE: IF CreationDate is TODAY and if there is not titlehistory record for this bookkey prior to 3 minutes ago, assume this is a brand new title 

*/

IF ((Select Convert(varchar(10), creationdate, 101) from book where bookkey = @i_bookkey and standardind = 'N') = Convert(varchar(10), getdate(), 101))
and NOT EXISTS (Select * FROM titlehistory where bookkey = @i_bookkey and lastmaintdate < DateAdd(minute, -3, getdate()))
	if @i_verificationtypecode = 6 
		begin
			IF NOT EXISTS (Select * FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
					BEGIN
						INSERT INTO bookverification 
						Select @i_bookkey, 6, 5, @i_username, getdate() --5 is ready for verification
					END
			ELSE
					BEGIN
						update bookverification
						set titleverifystatuscode = 5,
						   lastmaintdate = getdate(),
						   lastuserid = @i_username
						where bookkey = @i_bookkey
						and verificationtypecode = @i_verificationtypecode
					END

			RETURN
		end



--IF TEMPLATE,  EXCLUDE FROM ONIX
--IF  EXISTS (Select * FROM book WHERE bookkey = @i_bookkey and standardind = 'Y')
IF  (@v_standardind = 'Y')

	begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Templates are excluded from ONIX!',@i_username, getdate() )

		IF NOT EXISTS (Select * FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
				BEGIN
					INSERT INTO bookverification 
					Select @i_bookkey, 6, 9, @i_username, getdate() -- EXCLUDED FROM ONIX

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

		RETURN
	end


--EXCLUDE ALPHA TITLES - Added on 06/22/2012
IF EXISTS (Select 1 from bookorgentry bo where bo.bookkey = @i_bookkey and bo.orgentrykey = 2690 and bo.orglevelkey = 4)
	begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
    (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'ALPHA titles are excluded from ONIX!',@i_username, getdate() )
		set @v_failed = 1
		set @v_excluded_from_onix = 1

		IF @msg = '' 
			BEGIN
				SET @msg = 'Failed PGI filters: ' + 'Alpha Imprint'
			END
		ELSE
			BEGIN
				SET @msg = @msg + ', Alpha Imprint'
			END 
	end 


--A
--FIRST CHECK ON EXCLUDED FROM ONIX FIELDS


exec bookverification_check 'PGI_Elo_Preverification_Materialtype', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 6 
			begin
--				IF EXISTS (Select * FROM bookdetail where bookkey = @i_bookkey and mediatypecode = 16)
				IF dbo.rpt_get_misc_value(@i_bookkey, 121, 'external') =  'ZDIN' 
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'ZDIN (E-Books and Downloadable Audio) titles are excluded from ONIX!',@i_username, getdate() )
					set @v_failed = 1
					set @v_excluded_from_onix = 1

					IF @msg = '' 
						BEGIN
							SET @msg = 'Failed PGI filters: ' + 'E-book'
						END
					ELSE
						BEGIN
							SET @msg = @msg + ', E-book'
						END 

				end 
			end
	end

--B Commentted out on 11/21, we go by material type ZDIN
--exec bookverification_check 'PGI_Elo_Preverification_DownloadableAudio', @i_write_msg output
--if @i_write_msg = 1 
--	begin
--		if @i_verificationtypecode = 6 
--			begin
--				IF EXISTS (Select * FROM bookdetail bd join subgentables s on bd.mediatypecode = s.datacode and bd.mediatypesubcode = s.datasubcode where bookkey = @i_bookkey and s.tableid = 312 and  s.externalcode in ('0159', '0169',  '0184', '0185'))
--				begin
--					exec get_next_key @i_username, @v_nextkey out
--					insert into bookverificationmessage
--					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Downloadable Audio not valid for Eloquence.',@i_username, getdate() )
--					set @v_failed = 1
--					set @v_excluded_from_onix = 1
--
--					IF @msg = '' 
--						BEGIN
--							SET @msg = 'Failed PGI filters: ' + 'Downloadable Audio'
--						END
--					ELSE
--						BEGIN
--							SET @msg = @msg + ', Downloadable Audio'
--						END 
--				end 
--			end
--	end

--F
exec bookverification_check 'PGI_Elo_Preverification_OrgXXXX' , @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 6 
			begin
				IF [dbo].[rpt_get_group_level_2](@i_bookkey, '1') = 'XXXXX'
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Org Level not valid for Eloquence.',@i_username, getdate() )
					set @v_failed = 1
					set @v_excluded_from_onix = 1
					
					IF @msg = '' 
						BEGIN
							SET @msg = 'Failed PGI filters: ' + 'Org Level'
						END
					ELSE
						BEGIN
							SET @msg = @msg + ', Org Level'
						END 

				end 
			end
	end
	
--G
exec bookverification_check 'PGI_Elo_Preverification_IsISBN13' , @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 6 
			begin
				if LEN(dbo.rpt_get_isbn(@i_bookkey, 17)) <> 13 OR dbo.rpt_get_isbn(@i_bookkey, 17) NOT LIKE '978%'
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'ISBN is not valid for Eloquence.',@i_username, getdate() )
					set @v_failed = 1
					set @v_excluded_from_onix = 1

					IF @msg = '' 
						BEGIN
							SET @msg = 'Failed PGI filters: ' + 'ISBN'
						END
					ELSE
						BEGIN
							SET @msg = @msg + ', ISBN'
						END 

				end 
			end
	end


--M
exec bookverification_check 'PGI_Elo_Preverification_MaterialGroups' , @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 6 
			begin
--				IF EXISTS (Select * FROM bookdetail bd join gentables g on bd.mediatypecode = g.datacode where bookkey = @i_bookkey and g.tableid = 312 and g.externalcode in ('14', '25', '26'))
					If (@v_mediatypecode in (114, 116))
					begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Media type BL Subscription KITS and Online Proprietary are excluded from Eloquence.',@i_username, getdate() )
					set @v_failed = 1
					set @v_excluded_from_onix = 1

					IF @msg = '' 
						BEGIN
							SET @msg = 'Failed PGI filters: ' + 'Media Type'
						END
					ELSE
						BEGIN
							SET @msg = @msg + ', Media Type'
						END 

				end 
			end
	end	

--N
exec bookverification_check 'PGI_Elo_Preverification_ISBN300' , @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 6 
			begin
				IF EXISTS (Select * FROM isbn where bookkey = @i_bookkey and ean13 like '978300%')
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'ISBN 300 is not valid for Eloquence.',@i_username, getdate() )
					set @v_failed = 1
					set @v_excluded_from_onix = 1

					IF @msg = '' 
						BEGIN
							SET @msg = 'Failed PGI filters: ' + '300 ISBN'
						END
					ELSE
						BEGIN
							SET @msg = @msg + ', 300 ISBN'
						END 
				end 
			end
	end	

--E
exec bookverification_check 'PGI_Elo_Preverification_Prefix' , @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 6 
			begin
--				IF EXISTS (Select * FROM book where bookkey = @i_bookkey and (title like 'AMS %' OR title like 'CN %' OR title like 'CP %' OR title like 'SE %'))	
				IF (@v_title like 'AMS %' OR @v_title like 'CP %' OR @v_title like 'SE %')
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Title Prefix AMS, CN, CP and SE are excluded from Eloquence.',@i_username, getdate() )
					set @v_failed = 1
					set @v_excluded_from_onix = 1

					IF @msg = '' 
						BEGIN
							SET @msg = 'Failed PGI filters: ' + 'Title Prefix'
						END
					ELSE
						BEGIN
							SET @msg = @msg + ', Title Prefix'
						END 
				end 
			end
	end

--J
exec bookverification_check 'PGI_Elo_Preverification_NonOnixTitle' , @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 6 
			begin
--				IF dbo.rpt_get_misc_value(@i_bookkey, 105, 'altdesc2') = 'Exclude from Onix'
				If exists (select * FROM bookmisc where bookkey = @i_bookkey and misckey = 105 and longvalue is not null) and (dbo.rpt_get_misc_value(@i_bookkey, 105, 'altdesc2') IS NULL or dbo.rpt_get_misc_value(@i_bookkey, 105, 'altdesc2') = '') 
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Proprietary Title, excluded from Eloquence.',@i_username, getdate() )
					set @v_failed = 1
					set @v_excluded_from_onix = 1
					
					IF @msg = '' 
						BEGIN
							SET @msg = 'Failed PGI filters: ' + 'Proprietary Title'
						END
					ELSE
						BEGIN
							SET @msg = @msg + ', Proprietary Title'
						END 

				end 
			end
	end	


/*
Added on 11-01-2011 by TT. Per Oleg's email

Select * FROM bookverificationcolumns

Insert into bookverificationcolumns
SElect 'PGI_Elo_Preverification_PenguinGear', 1, 'qsidba', getdate()

*/

exec bookverification_check 'PGI_Elo_Preverification_PenguinGear' , @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 6 
			begin
--				If exists (Select * FROM bookdetail bd JOIN subgentables s ON bd.mediatypecode = s.datacode and bd.mediatypesubcode = s.datasubcode where bd.bookkey = @i_bookkey and s.tableid = 312 and s.externalcode = '0162') 
				If exists (Select * FROM subgentables s where s.tableid = 312 and datasubcode = @v_mediatypesubcode and s.externalcode = '0162') 

				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Penguin Gear titles are excluded from Eloquence.',@i_username, getdate() )
					set @v_failed = 1
					set @v_excluded_from_onix = 1
					
					IF @msg = '' 
						BEGIN
							SET @msg = 'Failed PGI filters: ' + 'Penguin Gear'
						END
					ELSE
						BEGIN
							SET @msg = @msg + ', Penguin Gear'
						END 

				end 
			end
	end	


--ADDED on 11/21, this is the last step for "excluded from ONIX" fields. If not already excluded, exclude it if media/format is not setup to be accepted by eloquence in User Tables. 
if @v_excluded_from_onix = 0
begin
	if @i_verificationtypecode = 6 
		begin
			IF (@v_mediatypecode IS NOT NULL AND @v_mediatypesubcode IS NOT NULL) AND 
			(
			EXISTS (Select * FROM gentables where tableid = 312 and datacode = @v_mediatypecode and deletestatus = 'N' and (ISNULL(exporteloquenceind, '') = '' OR  ISNULL(eloquencefieldtag, '') = ''))
			OR 
			EXISTS (Select * FROM subgentables where tableid = 312 and datacode = @v_mediatypecode and datasubcode = @v_mediatypesubcode and deletestatus = 'N' and (ISNULL(exporteloquenceind, '') = '' OR  ISNULL(eloquencefieldtag, '') = ''))
			)
			begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
        (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Media or Format not set up to be accepted by Eloquence',@i_username, getdate() )
				set @v_failed = 1
				set @v_excluded_from_onix = 1

				IF @msg = '' 
					BEGIN
						SET @msg = 'Failed PGI filters: ' + 'Media/Format not Accepted by Eloquence'
					END
				ELSE
					BEGIN
						SET @msg = @msg + ', Media/Format not Accepted by Eloquence'
					END 
			end 
		end
end




-- ********************************************************************************************************
-- NOW CHECK ON FIELDS THAT MIGHT BE MISSING DATA. WE WILL MARK THESE AS FAIL INSTEAD OF EXCLUDE FROM ONIX
-- "EXCLUDE FROM ONIX" TAKES PRECEDENCE OVER FAIL STATUS CODE
-- IF A TITLE  SHOULD BE EXCLUDED FROM ONIX (i.e. e-book), there is no need to check on conditions that would set the status to FAIL

if @v_excluded_from_onix = 0
begin
	exec bookverification_check 'PGI_Elo_Preverification_Materialtype', @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6  
				begin --If it is not ZDIN(e-book) then the only fail criteria is if material type is unassigned
					IF dbo.rpt_get_misc_value(@i_bookkey, 121, 'external') IS NULL OR dbo.rpt_get_misc_value(@i_bookkey, 121, 'external') = '' -- NOT IN ('FERT', 'ZPRO', 'ZNVL') 
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Invalid Material Type!',@i_username, getdate() )
						set @v_failed = 1

						IF @msg = '' 
							BEGIN
								SET @msg = 'Failed PGI filters: ' + 'Material Type'
							END
						ELSE
							BEGIN
								SET @msg = @msg + ', Material Type'
							END 
					end
				end
		end
end
	


--C
--if @v_excluded_from_onix = 0
--begin
--	exec bookverification_check 'PGI_Elo_Preverification_ActiveBatchPrice', @i_write_msg output
--	if @i_write_msg = 1 
--		begin
--			if @i_verificationtypecode = 6  
--				begin
--					IF dbo.rpt_get_misc_value(@i_bookkey, 277, 'long') = 'No'
--					begin
--						exec get_next_key @i_username, @v_nextkey out
--						insert into bookverificationmessage
--						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Active Batch Price has not been created in SAP.',@i_username, getdate() )
--						set @v_failed = 1

--						IF @msg = '' 
--							BEGIN
--								SET @msg = 'Failed PGI filters: ' + 'Active Batch Price'
--							END
--						ELSE
--							BEGIN
--								SET @msg = @msg + ', Active Batch Price'
--							END 
--					end 
--				end
--		end
--end

--D
if @v_excluded_from_onix = 0
begin
	exec bookverification_check 'PGI_Elo_Preverification_StatusCode' , @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
--					IF NOT EXISTS (Select * FROM bookdetail bd where bookkey = @i_bookkey and dbo.rpt_get_gentables_field(314, bd.bisacstatuscode, 'E') IN ('AB', 'IP', 'NP', 'OP', 'OI', 'TU', 'OPIP', 'OIIP', 'NPOP'))
					IF (dbo.rpt_get_gentables_field(314, @v_bisacstatuscode, 'E') NOT IN ('AB', 'IP', 'NP', 'OP', 'OI', 'TU', 'OPIP', 'OIIP', 'NPOP'))
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Bisac Status Code not valid for Eloquence.',@i_username, getdate() )
						set @v_failed = 1

						IF @msg = '' 
							BEGIN
								SET @msg = 'Failed PGI filters: ' + 'Bisac Status'
							END
						ELSE
							BEGIN
								SET @msg = @msg + ', Bisac Status'
							END 


					end 
				end
		end
end



	

--H
if @v_excluded_from_onix = 0
begin
	exec bookverification_check 'PGI_Elo_Preverification_Price' , @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
					IF (dbo.rpt_get_price(@i_bookkey, 8, 6, 'B') is null  or cast(dbo.rpt_get_price(@i_bookkey, 8, 6, 'B') as float)=0 or dbo.rpt_get_price(@i_bookkey, 8, 6, 'B')='')
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Price is not valid for Eloquence.',@i_username, getdate() )
						set @v_failed = 1

						IF @msg = '' 
							BEGIN
								SET @msg = 'Failed PGI filters: ' + 'US Price'
							END
						ELSE
							BEGIN
								SET @msg = @msg + ', US Price'
							END 

					end 
				end
		end
end
	
--I

if @v_excluded_from_onix = 0
begin
	exec bookverification_check 'PGI_Elo_Preverification_InventoryStatus' , @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
--					IF EXISTS (Select * from bookdetail where bookkey=@i_bookkey and (bisacstatuscode is null OR bisacstatuscode = ''))
					IF (@v_bisacstatuscode IS NULL OR @v_bisacstatuscode = '')
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Inventory Status not valid for Eloquence.',@i_username, getdate() )
						set @v_failed = 1
						
						IF @msg = '' 
							BEGIN
								SET @msg = 'Failed PGI filters: ' + 'Missing Status'
							END
						ELSE
							BEGIN
								SET @msg = @msg + ', Missing Status'
							END 

					end 
				end
		end	
end




--K, REPEATED, SAME AS J. REMOVED, TT 9/23
--exec bookverification_check 'PGI_Elo_Preverification_NonOnixTitle' , @i_write_msg output
--if @i_write_msg = 1 
--	begin
--		if @i_verificationtypecode = 6 
--			begin
--				IF dbo.rpt_get_misc_value(@i_bookkey, 105, 'altdesc2') = 'Exclude from Onix'
--				begin
--					exec get_next_key @i_username, @v_nextkey out
--					insert into bookverificationmessage
--					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Title is not valid for Eloquence.',@i_username, getdate() )
--					set @v_failed = 1
--				end 
--			end
--	end	

--L
if @v_excluded_from_onix = 0
begin
	exec bookverification_check 'PGI_Elo_Preverification_NpFpTitleNoPubDate' , @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
--					IF ([dbo].[rpt_get_date](@i_bookkey, 1,8, 'B') IS NULL OR [dbo].[rpt_get_date](@i_bookkey, 1,8, 'B') = '') AND EXISTS (Select * FROM bookdetail bd where bookkey = @i_bookkey and dbo.rpt_get_gentables_field(314, bd.bisacstatuscode, 'E') IN ('FT', 'NP'))
					IF ([dbo].[rpt_get_date](@i_bookkey, 1,8, 'B') IS NULL OR [dbo].[rpt_get_date](@i_bookkey, 1,8, 'B') = '') AND (dbo.rpt_get_gentables_field(314, @v_bisacstatuscode, 'E') IN ('FT', 'NP'))
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'NP FT Title without a pub date is not valid for Eloquence.',@i_username, getdate() )
						set @v_failed = 1

						IF @msg = '' 
							BEGIN
								SET @msg = 'Failed PGI filters: ' + 'Pub Date'
							END
						ELSE
							BEGIN
								SET @msg = @msg + ', Pub Date'
							END 
						

					end 
				end
		end	
end





--O
if @v_excluded_from_onix = 0
begin
	exec bookverification_check 'PGI_Elo_Preverification_hasMediaType' , @i_write_msg output
	if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
--					IF EXISTS (Select * FROM bookdetail  where bookkey = @i_bookkey and mediatypesubcode IS NULL)
					IF (@v_mediatypecode IS NULL or @v_mediatypecode = '' OR @v_mediatypesubcode IS NULL OR @v_mediatypesubcode = '')
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Non Existing Media or Format is not valid for Eloquence.',@i_username, getdate() )
						set @v_failed = 1

						IF @msg = '' 
							BEGIN
								SET @msg = 'Failed PGI filters: ' + 'Missing Media'
							END
						ELSE
							BEGIN
								SET @msg = @msg + ', Missing Media'
							END 
					end 
				end
		end	
end
	




--O, WE DON'T EXCLUDE NET PRICED ITEMS. COMMENTED OUT BY TOLGA 9/23
--exec bookverification_check 'PGI_Elo_Preverification_NetPriceItem' , @i_write_msg output
--if @i_write_msg = 1 
--	begin
--		if @i_verificationtypecode = 6 
--			begin
--				IF EXISTS (Select * FROM bookdetail bd JOIN gentables g ON bd.mediatypecode = g.datacode JOIN subgentables s ON g.datacode = s.datacode WHERE bd.bookkey = @i_bookkey and g.tableid = 312 and s.tableid = 312 and g.externalcode <> '27' and s.externalcode = '0192')
--				begin
--					exec get_next_key @i_username, @v_nextkey out
--					insert into bookverificationmessage
--					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Net Price Item is not valid for Eloquence.',@i_username, getdate() )
--					set @v_failed = 1
--				end 
--			end
--	end	


--failed
if @v_failed = 1 
begin

	--select /*@v_datacode = */datacode
	--from gentables 
	--where tableid = 513
	--and qsicode = 3
	
	if @v_excluded_from_onix = 0
		SET @v_Datacode = 8 --Failed
	else
		SET @v_Datacode = 9 --Excluded from ONIX


	--TOLGA: NOT SURE WHEN THE BOOKVERIFICATION RECORD IS CREATED THE FIRST TIME. WILL CHECK AND INSERT ONE IF IT DOESN'T ALREADY EXIST
	IF NOT EXISTS (Select * FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
		BEGIN
			INSERT INTO bookverification
			Select @i_bookkey, 6, @v_Datacode, @i_username, getdate()

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

			--Write the error message to the misc text field
			--PGI Onix Verification Messages, misckey = 278
			IF EXISTS (Select * FROM bookmisc where bookkey = @i_bookkey and misckey = 278)
				BEGIN
					Update bookmisc
					SET textvalue = SUBSTRING(@msg, 1, 255), lastuserid = 'pgi_onix_verify', lastmaintdate = getdate(), sendtoeloquenceind = 0
					WHERE bookkey = @i_bookkey and misckey = 278
				END
			ELSE
				BEGIN
					INSERT INTO BOOKMISC
					Select @i_bookkey, 278, NULL, NULL, SUBSTRING(@msg, 1, 255), 'pgi_onix_verify', getdate(), 0
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

if @v_failed = 0 and @v_varnings = 0 
begin

	IF NOT EXISTS (Select * FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
		BEGIN
			INSERT INTO bookverification
			Select @i_bookkey, 6, @v_datacode, @i_username, getdate()

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

		--Blank out the error message if it exists
		Update bookmisc
		SET textvalue = NULL, lastuserid = 'pgi_onix_verify', lastmaintdate = getdate(), sendtoeloquenceind = 0
		WHERE bookkey = @i_bookkey and misckey = 278
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

GRANT EXECUTE ON dbo.PGI_verify_eloquence_preverification TO PUBLIC