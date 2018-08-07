if exists (select * from dbo.sysobjects where id = object_id(N'dbo.PGI_verify_tm_to_sap_material_master') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.PGI_verify_tm_to_sap_material_master
GO

/******************************************************************************
**  Name: PGI_verify_tm_to_sap_material_master
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

/****** Object:  StoredProcedure [dbo].[PGI_verify_tm_to_sap_material_master]    Script Date: 02/11/2016 14:30:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PGI_verify_tm_to_sap_material_master]
		     @i_bookkey int,
		     @i_printingkey int,
		     @i_verificationtypecode int,
		     @i_username varchar(15)

AS

/* 
5/31/11 - Created for PGI to verify existence of fields to be used in interface from TM to SAP Material Master

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
Declare @v_Datacode varchar(255)


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



	--DECLARE @Return varchar (20)
	
	Declare @mediatypecode varchar(50)
	Declare @mediatypesubcode varchar(50)
	Declare @Customint01 as int
	Declare @materialDescription varchar(255)
	Declare @bisacstatuscode varchar(50)
	Declare @Xplant varchar(255)
	Declare @busPartner int
	Declare @Role int
	Declare @Sequence int
	Declare @authortypecode int
	Declare @CreationDate datetime
	Declare @materialtype varchar(255)
	
	--Update this flag 

	--Set Variables
	--set @Return = 'Y'
	
	
	Select @mediatypecode = dbo.rpt_get_gentables_field(312, bd.mediatypecode, 'E'), 
	@mediatypesubcode = dbo.rpt_get_subgentables_field(312, bd.mediatypecode, bd.mediatypesubcode, 'E'), 
	@CreationDate = b.creationdate, 
	@materialDescription = b.shorttitle, 
	@bisacstatuscode = dbo.rpt_get_gentables_field(314, bd.bisacstatuscode, 'E'), --bd.bisacstatuscode, 
	@Customint01 = dbo.get_CustomInt01(b.bookkey),
	@Xplant = (case when LEN(dbo.rpt_get_gentables_field(314, bd.bisacstatuscode, 'E')) = 4 THEN SUBSTRING(dbo.rpt_get_gentables_field(314, bd.bisacstatuscode, 'E'), 1, 2)
	ELSE dbo.rpt_get_gentables_field(314, bd.bisacstatuscode, 'E') END),
	@materialtype = dbo.rpt_get_misc_value(b.bookkey, 121, 'external')
	from book b
	join bookdetail bd
	on b.bookkey = bd.bookkey 
	where b.bookkey = @i_bookkey
	
	--commented out by Tolga on 12/07/2011
	--set @mediatypecode = (Select mediatypecode from bookdetail where bookkey=@i_bookkey)
	--set @mediatypesubcode = (Select mediatypesubcode from bookdetail where bookkey=@i_bookkey)
	--set @CreationDate =(Select CreationDate from book where bookkey=@i_bookkey)
	--set @Customint01 = (Select dbo.get_CustomInt01(@i_bookkey))
	--set @materialDescription = (Select shorttitle from book where bookkey=@i_bookkey)
	--set @bisacstatuscode = (Select bisacstatuscode from bookdetail where bookkey=@i_bookkey)
	--set @Xplant = (Select CASE WHEN dbo.rpt_get_gentables_field(314, @bisacstatuscode, 'E') = 'NPOP' THEN 'NP'
	--	  ELSE dbo.rpt_get_gentables_field(314, @bisacstatuscode, 'E') END)
	
	set @authortypecode =  (Select top 1 authortypecode from bookauthor where bookkey=@i_bookkey)


	IF EXISTS(Select * from bookauthor ba JOIN globalcontact gc ON ba.authorkey = gc.globalcontactkey WHERE ba.bookkey = @i_bookkey)
		SET @busPartner = 1
	ELSE
		SET @busPartner = 0

--	(Select count(1) from globalcontact gc,bookauthor ba 
--		where ba.authorkey = gc.globalcontactkey and
--		ba.bookkey =@i_bookkey and (externalcode1 is null or externalcode1 =''))

--	set @Sequence =(Select count(1) from bookauthor where bookkey =@i_bookkey and (sortorder is null or sortorder =''))
--	Set @Role = (Select count(1) from (Select dbo.rpt_get_gentables_field(134, 12, 'E') as A) as B where A is null or A ='')

	IF NOT EXISTS (Select * FROM bookauthor where bookkey =@i_bookkey and (sortorder is null or sortorder =''))
		SET @Sequence = 1
	ELSE
		SET @Sequence = 0


	IF NOT EXISTS (Select * FROM bookauthor where bookkey =@i_bookkey and (authortypecode is null or authortypecode = '' or authortypecode = 0))
		SET @Role = 1
	ELSE
		SET @Role = 0


--clean bookverificationmessager for passed bookkey
delete bookverificationmessage
where bookkey = @i_bookkey
and verificationtypecode = @i_verificationtypecode


exec bookverification_check 'PGI_TMM_to_SAP_ISBN Number', @i_write_msg output
if @i_write_msg = 1 
	begin
		if @i_verificationtypecode = 5 
			begin
				if dbo.PGI_get_itemnumber(@i_bookkey)= ''  
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing ISBN or itemnumber',@i_username, getdate() )
					set @v_failed = 1
				end 
			end
	end

exec bookverification_check 'PGI_TMM_to_SAP_Material type', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
		begin
			if @materialtype is null or @materialtype = ''
			/*dbo.rpt_get_gentables_field(312, @mediatypecode,'1') removed as Per Tolga "Verification Stored Procedure E-mail
				dbo.rpt_get_misc_value(@i_bookkey, 121, 'external') is null or dbo.rpt_get_misc_value(@i_bookkey, 121, 'external') ='' */
			 begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
        (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Material Type is Missing.',@i_username, getdate() )
				set @v_failed = 1
			end 
	end
end
exec bookverification_check 'PGI_TMM_to_SAP_Template material', @i_write_msg output

if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		if (@Customint01 = '' OR @Customint01 IS NULL) and (@CreationDate IS NULL OR @Creationdate >=  @newtitle_creationdate) --Cast('7/11/2011' as datetime)  
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'SAP Template ID is Missing. Please go to the Title Summary Page, and at the bottom of the page you will find the SAP Template field under Custom Fields. Edit, and Insert a SAP Template ID',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end

exec bookverification_check 'PGI_TMM_to_SAP_Material Description', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		if @materialDescription = '' or @materialDescription is null  
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Short Title (Material Description is Missing). Please go to the Title Summary Page, Click Edit under Title Information and add a Short Title.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end

exec bookverification_check 'PGI_TMM_to_SAP_Author/Artist', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
--		if dbo.rpt_get_author_first_primary(@i_bookkey, 12, 'D')='' or dbo.rpt_get_author_first_primary(@i_bookkey, 12, 'D') is null 
		IF (dbo.rpt_get_author_first_primary(@i_bookkey, 0, 'D') = '' OR dbo.rpt_get_author_first_primary(@i_bookkey, 0, 'D') IS NULL) AND @materialtype <> 'ZPRO' --dbo.rpt_get_misc_value(@i_bookkey,121,'external') <> 'ZPRO'
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Author with a Primary Key Indicator is Missing. Please go to the Title Summary Page, edit the Authors Section, and check the checkbox for which the author type is Primary.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end


exec bookverification_check 'PGI_TMM_to_SAP_Basic Data Text', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		if dbo.rpt_get_title(@i_bookkey, 'F')='' or dbo.rpt_get_title(@i_bookkey, 'F') is null 
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Title is missing from item. Please go to Title Summary Page. Edit the Title Information section, and add a Title for this item.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end

exec bookverification_check 'PGI_TMM_to_SAP_Current On Sale Date', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		if dbo.rpt_get_date(@i_bookkey, 1, 20003, 'B') = '' or dbo.rpt_get_date(@i_bookkey, 1, 20003, 'B') is null 
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Current On Sale Date is Missing.Please go to Title Summary Page. Click "TASK" on the Task Section. Click on "Edit" on the Task List Section which is on the Task Tracking Page. Click on "Add", and choose "OnSale Date" for the Task Drop Down and Add a date in the field below. Click on "Key Date", then submit.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end


/* Removed as per Tolga "Verification Stored Procedure E-Mail"

--SET TO INACTIVE
Select *  from bookverificationcolumns
WHERE columnname = 'PGI_TMM_to_SAP_X-plant Status'

Update bookverificationcolumns
SET activeind = 0
WHERE columnname = 'PGI_TMM_to_SAP_X-plant Status'

exec bookverification_check 'PGI_TMM_to_SAP_X-plant Status', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		if @Xplant ='' or @Xplant is null 
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Bisac Title Status is Missing. Please go to Title Summary page. Click Edit, and add a Bisac Status to the title.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end

*/

exec bookverification_check 'PGI_TMM_to_SAP_Prod.presentat', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		-- removed by Tolga, 12/07
		/*if dbo.rpt_get_subgentables_field(312, @mediatypecode, @mediatypesubcode, 'E') is null or dbo.rpt_get_subgentables_field(312, @mediatypecode, @mediatypesubcode, 'E')='' */
		if @mediatypesubcode is null or @mediatypesubcode = ''
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Format is missing. Please go to Title Summary page. Under Spec Details, click "Edit", then click on Format. Choose appropriate Format.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end

exec bookverification_check 'PGI_TMM_to_SAP_Imprint', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		if dbo.rpt_get_misc_value(@i_bookkey, 96, 'external') is null or dbo.rpt_get_misc_value(@i_bookkey, 96, 'external') = '' 
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Imprint is missing. Please go to Title Summary page. Under Product Section, click "Edit", then select an Imprint from the drop down list.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end

exec bookverification_check 'PGI_TMM_to_SAP_Material group', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		--Removed by Tolga, 12/07/11
		--if dbo.rpt_get_gentables_field(312, @mediatypecode,  'E') is null or dbo.rpt_get_gentables_field(312, @mediatypecode,  'E') ='' 
		if @mediatypecode IS NULL OR @mediatypecode = '' 
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Media Type (Material Group) is Missing.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end


exec bookverification_check 'PGI_TMM_to_SAP_Product Hierarchy', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		if dbo.rpt_get_group_level_6(@i_bookkey, '1') is null or dbo.rpt_get_group_level_6(@i_bookkey, '1') = '' 
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Org Levels (Product Hierarchy) are Missing.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end


--PGI_TMM_to_SAP_Valid from (X-plant)
/*
--SET TO INACTIVE
Select *  from bookverificationcolumns
WHERE columnname = 'PGI_TMM_to_SAP_Valid from (X-plant)'

Update bookverificationcolumns
SET activeind = 0
WHERE columnname = 'PGI_TMM_to_SAP_Valid from (X-plant)'



exec bookverification_check 'PGI_TMM_to_SAP_Valid from (X-plant)', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		if dbo.PGI_get_validfromdate(@i_bookkey) is null or dbo.PGI_get_validfromdate(@i_bookkey) ='' 
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Valid from (X-plant) Date is Missing. Please go to Title Summary Page. Click on "Tasks" on Task Section. Go To Task List, and Click Edit. Select Valid From for Task, and a Date in the field below. Click Submit.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end

*/

exec bookverification_check 'PGI_TMM_to_SAP_Publication Date', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		if [dbo].[rpt_get_date](@i_bookkey, 1,8, 'B') is null or [dbo].[rpt_get_date](@i_bookkey, 1,8, 'B')='' 
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Publication Date is Missing. Please go to Title Summary Page. Click on "Tasks" on Task Section. Go To Task List, and Click Edit. Select Pub Date for Task, and a Pub Date in the field below. Click Submit.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end



exec bookverification_check 'PGI_TMM_to_SAP_Dchain-spec. status', @i_write_msg output
if @i_write_msg = 1 begin
	if @i_verificationtypecode =5 begin
		--if dbo.rpt_get_gentables_field(314, @bisacstatuscode, 'E') ='' or dbo.rpt_get_gentables_field(314, @bisacstatuscode, 'E') is null begin
		if @bisacstatuscode is null or @bisacstatuscode = '' begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Bisac Title Status is missing.Please go to Inventory Section and click on "Edit". Please add a bisac status.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end



exec bookverification_check 'PGI_TMM_to_SAP_Valid from (Dchain)', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		if dbo.PGI_get_validfromdate(@i_bookkey) is null or  dbo.PGI_get_validfromdate(@i_bookkey) = ''
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Valid From Date is Missing. Please go to Title Summary Page. Click "TASK" on the Task Section. Click on "Edit" on the Task List Section which is on the Task Tracking Page. Click on "Add", and choose "Valid From Date" for the Task Drop Down and Add a date in the field below then submit.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end



exec bookverification_check 'PGI_TMM_to_SAP_Delivering Plant', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		if dbo.rpt_get_misc_value(@i_bookkey, 114, 'external') is null or dbo.rpt_get_misc_value(@i_bookkey, 114, 'external')=''  
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Delivering Plant is Missing. Please go to Title Summary Page. Click "Edit" under the Supply Chain Section. Add a Delivering Plant.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end

exec bookverification_check 'PGI_TMM_to_SAP_Profit Center', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		if dbo.rpt_get_misc_value(@i_bookkey, 107, 'external') is null or dbo.rpt_get_misc_value(@i_bookkey, 107, 'external') =''  
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Profit Center is Missing. Please go to Title Summary Page. Click "Edit" under the Supply Chain Section. Add a Profit Center.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end

--COMMENTED OUT ON 1/3/2012 per James Rowan's request
--Do not require prices for ZPROS and EBOOKS
-- Do not require for Canadian Editions (proprietary = Canada or Canada Only
-- Do not require prices for ZNVL where media is Jacket
/*
exec bookverification_check 'PGI_TMM_to_SAP_PPI_US_PRICE', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		--Removed by TT on 12/07
		--if (dbo.rpt_get_price(@i_bookkey, 8, 6, 'B') is null  or cast(dbo.rpt_get_price(@i_bookkey, 8, 6, 'B') as float)=0 or dbo.rpt_get_price(@i_bookkey, 8, 6, 'B')='') AND dbo.rpt_get_misc_value(@i_bookkey,121,'external') <> 'ZPRO' AND NOT EXISTS (Select * FROM bookdetail bd JOIN gentables g ON bd.mediatypecode = g.datacode WHERE bd.bookkey = @i_bookkey and g.tableid = 312 and g.externalcode = '02') AND (dbo.rpt_get_misc_value(@i_bookkey, 105, 'long') IS NULL OR dbo.rpt_get_misc_value(@i_bookkey, 105, 'long') NOT IN ('Canada', 'Canada Only'))
		if (dbo.rpt_get_price(@i_bookkey, 8, 6, 'B') is null  or cast(dbo.rpt_get_price(@i_bookkey, 8, 6, 'B') as float)=0 or dbo.rpt_get_price(@i_bookkey, 8, 6, 'B')='') 
		AND (@materialtype is NULL or @materialtype <> 'ZPRO') 
		AND NOT (@mediatypecode = '02') 
		AND (dbo.rpt_get_misc_value(@i_bookkey, 105, 'long') IS NULL OR dbo.rpt_get_misc_value(@i_bookkey, 105, 'long') NOT IN ('Canada', 'Canada Only'))
		AND NOT (@materialtype = 'ZNVL' AND @mediatypecode = '10')
		
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'A MSRP US Price is missing. Please go to Title Summary Page. Go to Prices Section and click on "Edit". Add a Manufacturer Suggested Retail Price, US, and a Dollar Amount.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end
*/



exec bookverification_check 'PGI_TMM_to_SAP_Standard_Project_Definition', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
	begin
		if  (dbo.rpt_get_misc_value(@i_bookkey,162,'long') is null OR dbo.rpt_get_misc_value(@i_bookkey,162,'long') = '') and (@CreationDate IS NULL OR @Creationdate>= @newtitle_creationdate) and EXISTS (Select * FROM taqproject tp join book b on tp.workkey = b.workkey where b.bookkey = @i_bookkey) and dbo.rpt_get_group_level_4(@i_bookkey, '1') <> 'PPITHPTHPGB'  --cast('7/11/2011' as datetime)
		begin
			exec get_next_key @i_username, @v_nextkey out
			insert into bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Standard Project Definition is missing. Please go to Title Summary Page. Go to the Product Section and click on "Edit". Add a Standard Project Definition.',@i_username, getdate() )
			set @v_failed = 1
		end 
	end
end



exec bookverification_check 'PGI_TMM_to_SAP_BusPartner', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
		begin
			-- dbo.rpt_get_misc_value(@i_bookkey,121,'external') <> 'ZPRO'
			if  (@busPartner = 0 AND (@materialtype IS NULL OR @materialtype <> 'ZPRO') )
			begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
        (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Author Type is missing. At least one author type should be entered from Author Window.',@i_username, getdate() )
				set @v_failed = 1
			end 
		end
end


exec bookverification_check 'PGI_TMM_to_SAP_Role', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
		begin
			if ((@busPartner > 0 and @Role = 0) OR (@busPartner = 0)) AND (@materialtype IS NULL OR @materialtype <> 'ZPRO') --dbo.rpt_get_misc_value(@i_bookkey,121,'external') <> 'ZPRO'
			begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
        (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'ROLE for at least one of the Author Types is MISSING.',@i_username, getdate() )
				set @v_failed = 1
			end 
		end
end

exec bookverification_check 'PGI_TMM_to_SAP_Sequence', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
		begin
			if  ((@busPartner > 0 and @Sequence = 0) OR (@busPartner = 0)) AND (@materialtype IS NULL OR @materialtype <> 'ZPRO') --dbo.rpt_get_misc_value(@i_bookkey,121,'external') <> 'ZPRO'
			begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
        (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'SORT ORDER for at least one of the Author Types is MISSING.',@i_username, getdate() )
				set @v_failed = 1
			end 
		end
end


exec bookverification_check 'PGI_TMM_to_SAP_Discount_Unit', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
		begin
			IF EXISTS (select * FROM associatedtitles where bookkey = @i_bookkey and associationtypecode = 7) and (dbo.rpt_get_misc_value(@i_bookkey,125, 'long') IS NULL OR dbo.rpt_get_misc_value(@i_bookkey,125, 'long') = 0) AND (@materialtype IS NULL OR @materialtype <> 'ZPRO')
			begin
				exec get_next_key @i_username, @v_nextkey out
				insert into bookverificationmessage
        (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'DISCOUNT UNIT IS REQUIRED FOR SETS (except ZPROs)!',@i_username, getdate() )
				set @v_failed = 1
			end 
		end
end


--PGI -- 01/14/2013
declare @count int
declare @usage int
exec bookverification_check 'PGI Set Components', @i_write_msg output
if @i_write_msg = 1 
begin
	if @i_verificationtypecode =5
		begin
			select @usage = usageclasscode from dbo.book  where book.bookkey = @i_bookkey
			if @usage = 2
			begin
				select @count = count(*) from dbo.book,associatedtitles where book.bookkey = @i_bookkey and usageclasscode = 2 and associatedtitles.bookkey = book.bookkey and associationtypecode = 7
				if @count = 0
				begin
					exec get_next_key @i_username, @v_nextkey out
					insert into bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Please add component titles to the Set.',@i_username, getdate() )
					set @v_failed = 1
				end
			end  
		end
end


/*

exec bookverification_check 'PGI_TMM_to_SAP_BusPartner', @i_write_msg output
if @i_write_msg = 1 
begin
	exec bookverification_check 'PGI_TMM_to_SAP_Role', @i_write_msg output
		if @i_write_msg = 1 
		begin
			exec bookverification_check 'PGI_TMM_to_SAP_Sequence', @i_write_msg output
				if @i_write_msg = 1 
				begin
					if @i_verificationtypecode =5
					begin
						if @busPartner >0  or @Sequence >0 or @Role >0  
						begin
							exec get_next_key @i_username, @v_nextkey out
							insert into bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							values(@v_nextkey,@i_bookkey , @i_verificationtypecode, @v_Error, dbo.PGI_BusinessPartner_Error(@i_bookkey),@i_username, getdate() )
							set @v_failed = 1
						end 
					end
				end
		end
end

*/

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

GRANT EXECUTE ON dbo.PGI_verify_tm_to_sap_material_master TO PUBLIC