/****** Object:  StoredProcedure [dbo].[UCAL_Elo_verify_ONIX]    Script Date: 08/06/2014 15:40:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[UCAL_Elo_verify_ONIX]
		     @i_bookkey int,
		     @i_printingkey int,
		     @i_verificationtypecode int,
		     @i_username varchar(80)

AS

--Select * from gentables where tableid=556
/* 
5/31/11 - Created for PGI to verify existence of fields to be used in interface from TM to SAP Material Master

*/




	
BEGIN 
--DECLARE @newtitle_creationdate datetime
--SET @newtitle_creationdate = '07-26-2011'


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
Declare @v_count int


--DECLARE @msg varchar(255)
--SET @msg = ''

SET @v_count = 0


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

/*
Select * FROM bookverificationcolumns




if not exists (Select 1 from bookverificationcolumns where columnname like 'UCAL_elo%')
begin
Insert into bookverificationcolumns Select 'UCAL_Elo_BNumber',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_BisacStatus',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_AvailabilityCode',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_BisacSubject',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_ISBN',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_Title',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_Publisher',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_Imprint',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_CopyrightYear',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_USPrice',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_DiscountCode',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_PubDate',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_ShipDate',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_ContributorLastName',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_ContributorRole',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_SalesRights',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_ReturnsCode',1,'qsidba',GETDATE()
Insert into bookverificationcolumns Select 'UCAL_Elo_BarCode',1,'qsidba',GETDATE()



end

*/

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
@v_bisacstatuscode smallint,
@v_workkey int,
@isbn10 varchar(10),
@ean varchar(50),
@copyrightyear smallint,
@prodavailability int,
@returncode int,
@barcodeid1 int,
@discountcode int

select @v_title = b.title, @v_mediatypecode = mediatypecode, @v_mediatypesubcode = mediatypesubcode,
@v_bisacstatuscode = bd.bisacstatuscode,
@v_standardind = b.standardind,
@v_workkey = b.workkey,
@isbn10 = dbo.rpt_get_isbn(b.bookkey, 10), 
@ean = dbo.rpt_get_isbn(b.bookkey, 17),
@copyrightyear = bd.copyrightyear,
@prodavailability = bd.prodavailability,
@discountcode = bd.discountcode,
@returncode = bd.returncode,
--@barcodeid1 = p.barcodeid1 
@barcodeid1 = (Select barcodeid1 from printing where bookkey = b.bookkey and printingkey = @i_printingkey)
from bookdetail bd
JOIN book b
on bd.bookkey = b.bookkey
--JOIN isbn i  -- no records in isbn table for POMS templates
--on b.bookkey = i.bookkey 
--join printing p 
--on b.bookkey = p.bookkey 
where b.bookkey = @i_bookkey --and p.printingkey in (1,0) -- 0 for POMS templates





/*
THIS SECTION IS ADDED TO SET THE STATUS TO "READY FOR VERIFICATION" FOR NEW TITLES
Creationdate is sometimes not recorded correctly. If you add a title in the afternoon, the app records the time component in a.m 
RULE: IF CreationDate is TODAY and if there is not titlehistory record for this bookkey prior to 3 minutes ago, assume this is a brand new title 

*/

--IF ((Select Convert(varchar(10), creationdate, 101) from book where bookkey = @i_bookkey and standardind = 'N') = Convert(varchar(10), getdate(), 101))
--and NOT EXISTS (Select * FROM titlehistory where bookkey = @i_bookkey and lastmaintdate < DateAdd(minute, -3, getdate()))
--	if @i_verificationtypecode = 6 
--		begin
--			IF NOT EXISTS (Select * FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
--					BEGIN
--						INSERT INTO bookverification 
--						Select @i_bookkey, 6, 5, @i_username, getdate() --5 is ready for verification
--					END
--			ELSE
--					BEGIN
--						update bookverification
--						set titleverifystatuscode = 5,
--						   lastmaintdate = getdate(),
--						   lastuserid = @i_username
--						where bookkey = @i_bookkey
--						and verificationtypecode = @i_verificationtypecode
--					END

--			RETURN
--		end



--IF TEMPLATE,  EXCLUDE FROM ONIX
--IF  EXISTS (Select * FROM book WHERE bookkey = @i_bookkey and standardind = 'Y')
-- looks like POMS templates have no isbn record. And printingkey = 0 in printing table. exclude them from ONIX. 
IF  (@v_standardind = 'Y') OR Exists (Select 1 from printing where bookkey = @i_bookkey and printingkey = 0)

	begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Templates are excluded from ONIX.',@i_username, getdate() )

		IF NOT EXISTS (Select 1 FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
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



--A
--FIRST CHECK ON EXCLUDED FROM ONIX FIELDS
-- EBOOKS ARE EXCLUDED FROM ONIX

IF  (@v_mediatypecode = 14)
	begin
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage
		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'eBooks are excluded from ONIX',@i_username, getdate() )

		IF NOT EXISTS (Select 1 FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
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


exec bookverification_check 'UCAL_Elo_BNumber', @i_write_msg output  
  if @i_write_msg = 1   
  begin  
   if @i_verificationtypecode = 6   
    begin  
     if ISNULL(dbo.UCAL_Get_BNumber_from_bookkey(@v_workkey),'') = ''
     begin  
      exec get_next_key @i_username, @v_nextkey out  
      insert into bookverificationmessage  
      values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'BNumber is Missing at the Project Level.',@i_username, getdate() )  
      set @v_failed = 1  
     end   
    end  
  end 
  
  

-- Bisac Status   


exec bookverification_check 'UCAL_Elo_BisacStatus', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if ISNULL(@v_bisacstatuscode,'') = '' 
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Bisac Title Status is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 
  

exec bookverification_check 'UCAL_Elo_AvailabilityCode', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if ISNULL(@prodavailability,'') = '' 
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Product Availability Code is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 
  



-- there has to be at least one subject category
exec bookverification_check 'UCAL_Elo_BisacSubject', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if not exists (Select 1 from bookbisaccategory where bookkey =  @i_bookkey and bisaccategorycode is not null and bisaccategorysubcode is not null) 
					and (ISNULL(@v_bisacstatuscode, '') = '' OR  @v_bisacstatuscode <> 6)
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'BISAC Subject Code is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 



exec bookverification_check 'UCAL_Elo_ISBN', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if ISNULL(@isbn10, '') = '' OR ISNULL(@ean, '') = ''
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'ISBN10 or EAN is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 




exec bookverification_check 'UCAL_Elo_Title', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if ISNULL(@v_title, '') = ''
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Title is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 



exec bookverification_check 'UCAL_Elo_Publisher', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if ISNULL(dbo.rpt_get_group_level_2(@i_bookkey,'1'),'') = ''
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Publisher is missing. Populate alternatedesc1 field of the publisher on Group Entry window.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 


exec bookverification_check 'UCAL_Elo_Imprint', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if ISNULL(dbo.rpt_get_group_level_3(@i_bookkey,'1'),'') = ''
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Imprint is missing. Populate alternatedesc1 field of the imprint on Group Entry window.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 





exec bookverification_check 'UCAL_Elo_CopyrightYear', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if ISNULL(@copyrightyear,'') = ''
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Copyright Year is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 




exec bookverification_check 'UCAL_Elo_USPrice', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if ISNULL(dbo.rpt_get_best_us_price(@i_bookkey,8),'') = ''
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'US Price is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 


exec bookverification_check 'UCAL_Elo_DiscountCode', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if ISNULL(dbo.UCAL_rpt_get_discount(@i_bookkey, 'T'), '') = '' OR ISNULL(@discountcode, '') = ''  --ISNULL(dbo.UCal_Get_Discount(@i_bookkey),'') = '' 
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Discount code or eloquence field tag for discount code is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 




exec bookverification_check 'UCAL_Elo_PubDate', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if ISNULL(dbo.rpt_get_best_pub_date(@i_bookkey,1),'') = '' 
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Pub Date is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 
		
		
/*
SHIP DATE
Required only if BISAC status is { OS, NYP, NYAPOD or ACT with a pub date greater than the current date)
OS = 7
NYP = 4
NYAPOD = ?
ACT: 1

OS, IS, PP
@v_bisacstatuscode
@prodavailability 

Select * FROM gentables where tableid = 314 and deletestatus = 'N'

not empty if BISAC status is {ACT, NYP, NYAPOD, ONDEMAND}

Select * FROM subgentables where tableid = 314 and deletestatus = 'N'
Select * FROM book

Select * from bookdetail bd where exists 
(Select 1 from gentables g join subgentables sg on g.tableid = sg.tableid
and g.datacode = sg.datacode where g.tableid = 314 and g.datacode = bd.bisacstatuscode and sg.datasubcode = bd.prodavailability
and (g.deletestatus = 'Y' OR sg.deletestatus = 'Y'))

*/



exec bookverification_check 'UCAL_Elo_ShipDate', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if ((@v_bisacstatuscode = 1 and @prodavailability  = 2) OR 
					(@v_bisacstatuscode = 4 and @prodavailability  = 1) OR 
					(@v_bisacstatuscode = 8 and @prodavailability  = 1)) 
					AND ISNULL(dbo.qtitle_get_last_taskdate(@i_bookkey, 1, 8), '01/01/1900') > GETDATE()
					AND ISNULL(dbo.rpt_get_best_release_date(@i_bookkey,1),'') = ''
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Release Date is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 

exec bookverification_check 'UCAL_Elo_ContributorLastName', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if not exists (Select 1 from bookauthor ba where bookkey = @i_bookkey) OR
					exists (Select 1 from bookauthor ba join globalcontact gc on ba.authorkey = gc.globalcontactkey where bookkey = @i_bookkey and ISNULL(gc.lastname, '') = '')
					  
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Contributor or last name is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 


exec bookverification_check 'UCAL_Elo_ContributorRole', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					Select @v_count = count(*)  
					  from bookauthor ba
					  where bookkey = @i_bookkey  
					  and  exists (select 1 from gentables where tableid = 134 and datacode = ba.authortypecode and (ISNULL(eloquencefieldtag, '') <> '' and ISNULL(exporteloquenceind, '') <> '')) 
				
					  If @v_count = 0 
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Contributor or Eloquence setup for role type is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 		
		
--Select COUNT(*) FROM bookcomments where commenttypecode = 3 and commenttypesubcode = 103 and LEN(CAST(commenthtmllite as varchar(max)))> 0

exec bookverification_check 'UCAL_Elo_SalesRights', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if not exists (Select 1 FROM bookcomments where bookkey = @i_bookkey and printingkey = 1 and commenttypecode = 3 and commenttypesubcode = 103 and LEN(CAST(commenthtmllite as varchar(max)))> 0)
					and (ISNULL(@v_bisacstatuscode, '') = '' OR  @v_bisacstatuscode <> 6)
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Sales Rights/Territory is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 
		
		
exec bookverification_check 'UCAL_Elo_ReturnsCode', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if ISNULL(@returncode,'') = '' 
						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Return Code is missing',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 

-- not empty if BISAC status is {ACT, NYP, NYAPOD, ONDEMAND}

-- @barcodeid1
/** 
**
** barcode check commented out per Help Ticket #19181 -- DR 11/07/2013
**
exec bookverification_check 'UCAL_Elo_BarCode', @i_write_msg output  
	if @i_write_msg = 1   
		begin  
			if @i_verificationtypecode = 6   
				begin  
					if ((@v_bisacstatuscode = 1 and @prodavailability  = 2) OR 
					(@v_bisacstatuscode = 4 and @prodavailability  = 1) OR 
					(@v_bisacstatuscode = 8 and @prodavailability  = 1)) AND exists (Select 1 FROM printing where bookkey = @i_bookkey and printingkey = 1 and ISNULL(barcodeid1, 0) = 0)

						begin  
							exec get_next_key @i_username, @v_nextkey out  
							insert into bookverificationmessage  
							values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Barcode 1 is missing.',@i_username, getdate() )  
							set @v_failed = 1  
						end   
				end			 
		end 
**/







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
	IF NOT EXISTS (Select 1 FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
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

if @v_failed = 0 --and @v_varnings = 0 
begin

	IF NOT EXISTS (Select 1 FROM bookverification WHERE bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode)
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

end 

end


