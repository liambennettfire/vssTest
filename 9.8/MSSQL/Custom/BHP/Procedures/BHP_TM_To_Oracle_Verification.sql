if exists (select * from dbo.sysobjects where id = object_id(N'dbo.BHP_TM_To_Oracle_Verification') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.BHP_TM_To_Oracle_Verification
GO

/******************************************************************************
**  Name: BHP_TM_To_Oracle_Verification
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  02/16/2016   Colman      Case 36373
**  02/25/2016   UK          Case 36664
*******************************************************************************/

/****** Object:  StoredProcedure [dbo].[BHP_TM_To_Oracle_Verification]    Script Date: 02/11/2016 14:30:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BHP_TM_To_Oracle_Verification](
		     @i_bookkey int,
		     @i_printingkey int,
		     @i_verificationtypecode int,
		     @i_username varchar(15))

AS
 
BEGIN
		    SET NOCOUNT ON; 
DECLARE @newtitle_creationdate datetime
SET @newtitle_creationdate = '07-26-2000'

DECLARE  @b_unit int

select @b_unit= isnull(longvalue,0) from bookmisc where misckey=267 and bookkey=@i_bookkey


IF @b_unit IS NULL SET @b_unit=0

DECLARE @i_orgentrykey int

SELECT @i_orgentrykey = orgentrykey
from bookorgentry where bookkey = @i_bookkey and orglevelkey = 2
--select * from orgentry where orgentrykey in ( 4028289,4028339,4028341)
IF @i_orgentrykey in ( 4028289,4028339,4028341) and @b_unit<>1
BEGIN


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
Declare @d_creationdate datetime
Declare @d_sendtooraclestatusdate datetime
Declare @sostatus int, @setstatus int
DECLARE @PRICELIST INT
DECLARE	@CURRTYPE INT
DECLARE	@maxlastmaintdate DATETIME

--declare @i_bookkey int

--set @i_bookkey = 8040545

select @d_creationdate = creationdate from book where bookkey = @i_bookkey 
select @d_sendtooraclestatusdate = lastmaintdate from bookmisc where bookkey = @i_bookkey and misckey = 59

set @d_creationdate = DATEADD(minute,1,@d_creationdate)

--select @d_creationdate, @d_sendtooraclestatusdate

if @d_creationdate > @d_sendtooraclestatusdate
BEGIN
	update bookmisc set longvalue = null where bookkey = @i_bookkey and misckey = 59
END

--select * from bookmisc where misckey = 59 and bookkey = 8040545
--select * from book where bookkey = 8040545

set @v_Error = 2

set @v_Warning = 3
set @v_Information = 4
set @v_Aborted = 5
set @v_Completed = 6
set @v_failed = 0 
set @v_varnings = 0


--clean bookverificationmessage for passed bookkey
delete bookverificationmessage
where bookkey = @i_bookkey
and verificationtypecode = @i_verificationtypecode


if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Short_Title')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Short_Title',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Item_Template')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Item_Template',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Item_Type')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Item_Type',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_BISAC_Status')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_BISAC_Status',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Editorial_Component')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Editorial_Component',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Weight')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Weight',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_BC_Cross_Reference')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_BC_Cross_Reference',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Product_Line')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Product_Line',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_MSRP_USD')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_MSRP_USD',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Discount_Code')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Discount_Code',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Return_Status')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Return_Status',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Royalty')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Royalty',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Auto_Release')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Auto_Release',1,'qsidba',GETDATE()
 end
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Contract')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Contract',1,'qsidba',GETDATE()
 end
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Proforma')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Proforma',1,'qsidba',GETDATE()
 end
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Cross_Reference')
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Cross_Reference',1,'qsidba',GETDATE()
 end
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Trim_Size') 
 begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Trim_Size',1,'qsidba',GETDATE()
 end 
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Page_Count')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Page_Count',1,'qsidba',GETDATE()
 end 
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Pub_Date')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Pub_Date',1,'qsidba',GETDATE()
 end 
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Author')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Author',1,'qsidba',GETDATE()
 end 
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_First_Ship_Date')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_First_Ship_Date',1,'qsidba',GETDATE()
 end  
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Business_Leader')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Business_Leader',1,'qsidba',GETDATE()
 end  
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Harmonization_Code')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Harmonization_Code',1,'qsidba',GETDATE()
 end  
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_LWX_Tax_Override')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_LWX_Tax_Override',1,'qsidba',GETDATE()
 end  
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Country_Of_Origin')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Country_Of_Origin',1,'qsidba',GETDATE()
 end  
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Fully_Loaded_1')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Fully_Loaded_1',1,'qsidba',GETDATE()
 end 
  if not exists(Select 1 from dbo.bookverificationcolumns where columnname='Primary_Cross_Reference')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'Primary_Cross_Reference',1,'qsidba',GETDATE()
 end 
 if not exists(Select 1 from dbo.bookverificationcolumns where columnname='LW_Primary_Cross_Reference')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'LW_Primary_Cross_Reference',1,'qsidba',GETDATE()
 end 
  if not exists(Select 1 from dbo.bookverificationcolumns where columnname='Product_Group')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'Product_Group',1,'qsidba',GETDATE()
 end 
   if not exists(Select 1 from dbo.bookverificationcolumns where columnname='Responsiblity_Center')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'Responsiblity_Center',1,'qsidba',GETDATE()
 end 
  if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Item_Number')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Item_Number',1,'qsidba',GETDATE()
 end 
   if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Inventory_Organization_Code')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Inventory_Organization_Code',1,'qsidba',GETDATE()
 end 
    if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Price_exp')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Price_exp',1,'qsidba',GETDATE()
 end 
     if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_UOM_Freq')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_UOM_Freq',1,'qsidba',GETDATE()
 end 
      if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Price_Date_gap')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Price_Date_gap',1,'qsidba',GETDATE()
 end 
       if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Price_Date_backwards')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Price_Date_backwards',1,'qsidba',GETDATE()
 end 
  if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Price_exp_future')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Price_exp_future',1,'qsidba',GETDATE()
 end 
   if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Price_eff_future')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Price_eff_future',1,'qsidba',GETDATE()
 end 
    if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_PrimaryUOM_Itemtype_Submast')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_PrimaryUOM_Itemtype_Submast',1,'qsidba',GETDATE()
 end 
   if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Price_eff_mustexist')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Price_eff_mustexist',1,'qsidba',GETDATE()
 end 
    if not exists(Select 1 from dbo.bookverificationcolumns where columnname='BHP_Short_title')
 begin
 insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'BHP_Short_title',1,'qsidba',GETDATE()
 end 
 
 
 exec bookverification_check 'BHP_Short_title', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
 IF NULLIF((
							SELECT shorttitle
							FROM book
							WHERE bookkey = @i_bookkey
							), '') IS NULL
				begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
            values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'A short title is required. Please add a short title.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
 
  --When final price is not null, then effective date must exist
		exec bookverification_check 'BHP_Price_eff_mustexist', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
					IF	Exists (select 1 from bookprice where isnull(effectivedate,'')='' and isnull(cast(finalprice as varchar(250)),'')<>'' and bookkey=@i_bookkey)
									
				 
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'When a final price is declared, an effective date must also be defined. Please add an effective date.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
		
		
		
		
		
 --Itemtype, Freq, Primary Unit of Measure
		exec bookverification_check 'BHP_PrimaryUOM_Itemtype_Submast', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
					IF
					
				 dbo.rpt_get_misc_value (@i_bookkey,427,'external')<>'EA' -- Primary Unit of Measure
				 AND (
				 dbo.rpt_get_misc_value (@i_bookkey,407,'external')<>'Y'  -- Subscription Master Type
				OR
				 dbo.rpt_get_misc_value(@i_bookkey,56,'external') not in ('LWDATESUB','LWSUBMAST','LWCLUB')
				 )  --Item Type
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'When Item Type not in ( LW SUBSCRIPTION MASTER , LW DATED SUB or LW CLUB ) or Subscription Master is not ''Y'' , then Primary Unit of Measure must be equal to ''Each (EA)''',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
 
 
 
 --Find prices that have effective dates before there expiration dates
		exec bookverification_check 'BHP_Price_Date_backwards', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
					

							IF EXISTS (select 1 from bookprice where effectivedate>expirationdate and bookkey=@i_bookkey)
									
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Price Effective Date and Expiration Date Error. An effective date on a price occurs before the expiration date.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
 ----Detect gaps in price start and end dates
	--	exec bookverification_check 'BHP_Price_Date_gap', @i_write_msg output
	--	if @i_write_msg = 1 
	--	begin
	--		if @i_verificationtypecode = 6 
	--			begin
					

	--						IF EXISTS (
	--								SELECT  bookkey,
	--								pricetypecode,
	--								currencytypecode,
	--								expirationdate,
	--								NextDate,
	--								DATEDIFF("D", expirationdate, NextDate) as datedifference
							        
							        
	--						FROM    (   SELECT  bookkey, 
	--											pricetypecode,
	--											currencytypecode,
	--											expirationdate,
	--											(   SELECT  MIN(effectivedate) 
	--												FROM    bookprice T2
	--												WHERE   T2.bookkey=T1.bookkey 
	--												AND		T2.pricetypecode = T1.pricetypecode
	--												AND		T2.currencytypecode= T1.currencytypecode
	--												AND     T2.effectivedate > T1.expirationdate
	--												AND  T1.effectivedate<> T2.effectivedate
	--											) AS NextDate
	--									FROM    bookprice T1
	--								) AS T
	--								where NextDate is not null 
	--							  and t.bookkey=@i_bookkey  
	--								and DATEDIFF("D", expirationdate, NextDate) >1
	--								)
									
	--				begin
	--					exec get_next_key @i_username, @v_nextkey out
	--					insert into bookverificationmessage
  --         (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
	--					values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Price Date Gap Detected. There is more than 1 day in between a price''s expiration date and next effective date. Please update price effective and expiration dates so dates are within 1 day of each other.',@i_username, getdate() )
	--					set @v_failed = 1
	--				end 
	--			end
	--	end
  
 --Itemtype, Freq, Primary Unit of Measure
		exec bookverification_check 'BHP_Inventory_Organization_Code', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
					IF
				dbo.rpt_get_misc_value (@i_bookkey,427,'external')<>'EA'
				and dbo.rpt_get_misc_value(@i_bookkey,56,'external')='LWSUBMAST'
				and dbo.rpt_get_misc_value(@i_bookkey,399,'short')<> dbo.rpt_get_misc_value(@i_bookkey,427,'short')
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'When item type = LW SUBSCRIPTION MASTER and Primary Unit of Measure is not equal to Each (EA), then Primary Unit of Measure must equal Publication Frequency',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
 
 --BHP_Inventory_Organization_Code
		exec bookverification_check 'BHP_Inventory_Organization_Code', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,288,'long'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'BHP Inventory Organization Code Missing. Please enter a Inventory Organization Code',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end


--Item Number
		exec bookverification_check 'BHP_Item_Number', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
					IF NULLIF((
							SELECT itemnumber
							FROM isbn
							WHERE bookkey = @i_bookkey
							), '') IS NULL
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Item Number Missing.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end


--Short Title --Warning - Jorge
		exec bookverification_check 'BHP_Short_Title', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_short_title(@i_bookkey),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Short Title Missing. Please enter a Short Title.',@i_username, getdate() )
						set @v_varnings = 1
					end 
				end
		end
		
--Item Template --Warning - Jorge
		exec bookverification_check 'BHP_Item_Template', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,56,'long'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Item Template Missing. Please enter an Item Template.',@i_username, getdate() )
						set @v_varnings = 1
					end 
				end
		end

--Harmonization Code --Warning - Jorge
		exec bookverification_check 'BHP_Harmonization_Code', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,49,'long'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Harmonization Code Missing. Please enter an Harmonization Code.',@i_username, getdate() )
						set @v_varnings = 1
					end 
				end
		end

--Country of Origin --Warning - Jorge
		exec bookverification_check 'BHP_Country_Of_Origin', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,9,'long'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Country of Origin Missing. Please enter a Country of Origin.',@i_username, getdate() )
						set @v_varnings = 1
					end 
				end
		end
		
		--Product Group (BH)
		exec bookverification_check 'Product_Group', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,44,'long'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Product Group (BH) Missing. Please enter a Product Group (BH).',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
		--Editorial Component
		exec bookverification_check 'Responsiblity_Center', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,289,'long'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, 
						@i_bookkey, 
						@i_verificationtypecode, 
						@v_Error, 
						'Responsiblity_Center Missing. Please enter a Responsiblity_Center.',
						@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end

--LWX Tax Override --Warning - Jorge
		exec bookverification_check 'BHP_LWX_Tax_Override', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,47,'long'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'LWX Tax Override Missing. Please enter a LWX Tax Override.',@i_username, getdate() )
						set @v_varnings = 1
					end 
				end
		end
		
		
		
		EXEC bookverification_check 'LW_Primary_Cross_Reference'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 6
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 103, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Primary Cross Reference blank. Please enter Primary Cross Reference.',@i_username, getdate() )
									set @v_failed = 1
				
				END
			END
		END
		
--Primary Cross reference
		EXEC bookverification_check 'Primary_Cross_Reference'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 6
			BEGIN
			
			
				--1	ISBN (13) / EAN
				--2	UPC
				--3	LifeWay/Oracle #
				--4	ASIN
				--5	Apple ID
				--6	ISBN (10)
				--7	MFN
				--9	EPPS
				--10	Vendor Part #
				declare @longvalue int

				SELECT  @longvalue=longvalue from bookmisc where bookkey=@i_bookkey and misckey=103


				IF @longvalue =1
				BEGIN
					IF isnull((SELECT ean from isbn where bookkey=@i_bookkey),'')=''
					BEGIN
						EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Primary Cross Reference marked as ISBN (13) / EAN. ISBN (13) / EAN is missing.',@i_username, getdate() )
									set @v_failed = 1
					END
				END
				ELSE
				IF @longvalue =2
				BEGIN
					IF isnull((SELECT upc from isbn where bookkey=@i_bookkey),'')=''
					BEGIN
						EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Primary Cross Reference marked as UPC. UPC is missing.',@i_username, getdate() )
									set @v_failed = 1
					END
				END
				ELSE
				IF @longvalue =3
				BEGIN
					IF isnull((SELECT itemnumber from isbn where bookkey=@i_bookkey),'')=''
					BEGIN
						EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Primary Cross Reference marked as LifeWay/Oracle #. LifeWay/Oracle # is missing.',@i_username, getdate() )
									set @v_failed = 1
					END
				END
				ELSE
				IF @longvalue =4
				BEGIN
					IF NOT EXISTS(SELECT TEXTVALUE from bookmisc where bookkey=@i_bookkey and misckey=359) OR ISNULL((SELECT TEXTVALUE from bookmisc where bookkey=@i_bookkey and misckey=359),'')=''
						BEGIN
							EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Primary Cross Reference marked as ASIN. ASIN is missing.',@i_username, getdate() )
									set @v_failed = 1
						END
					
				END
				ELSE
				IF @longvalue =5
				BEGIN
					IF NOT EXISTS(SELECT TEXTVALUE from bookmisc where bookkey=@i_bookkey and misckey=360) OR ISNULL((SELECT TEXTVALUE from bookmisc where bookkey=@i_bookkey and misckey=360),'')=''
						BEGIN
							EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Primary Cross Reference marked as Apple ID. Apple ID is missing.',@i_username, getdate() )
									set @v_failed = 1
						END

				END
				ELSE
				IF @longvalue =6
				BEGIN
					IF isnull((SELECT isbn10 from isbn where bookkey=@i_bookkey),'')=''
					BEGIN
						EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Primary Cross Reference marked as isbn10. isbn10 is missing.',@i_username, getdate() )
									set @v_failed = 1
					END
				END
				ELSE
				IF @longvalue =7
				BEGIN
					IF NOT EXISTS(SELECT TEXTVALUE from bookmisc where bookkey=@i_bookkey and misckey=376) OR ISNULL((SELECT TEXTVALUE from bookmisc where bookkey=@i_bookkey and misckey=376),'')=''
						BEGIN
							EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Primary Cross Reference marked as MFN. MFN is missing.',@i_username, getdate() )
									set @v_failed = 1
						END
				END		
				ELSE IF @longvalue NOT IN (1,2,3,4,5,6,7)
				BEGIN
					EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Primary Cross Reference INVALID. Please select a different primary cross reference.',@i_username, getdate() )
									set @v_failed = 1
				END
			
			
			
			END
		END
				

--Item Type --Warning - Jorge
		exec bookverification_check 'BHP_Item_Type', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,56,'external'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Item Type Missing. Please enter an Item Type.',@i_username, getdate() )
						set @v_varnings = 1
					end 
				end
		end

--Item Status --Error
		exec bookverification_check 'BHP_BISAC_Status', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_bisac_status (@i_bookkey,'E'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'BISAC Status Missing. Please enter a BISAC Status.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
--Editorial Component
		--exec bookverification_check 'BHP_Editorial_Component', @i_write_msg output
		--if @i_write_msg = 1 
		--begin
		--	if @i_verificationtypecode = 6
		--		begin
		--			if nullif(dbo.rpt_get_misc_value (@i_bookkey,56,'external'),'') is null
		--			begin
		--				exec get_next_key @i_username, @v_nextkey out
		--				insert into bookverificationmessage
    --       (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
		--				values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Editorial Component Missing. Please enter an Editorial Component.',@i_username, getdate() )
		--				set @v_failed = 1
		--			end 
		--		end
		--end
		
--Weight --Jorge
		exec bookverification_check 'BHP_Weight', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_bookweight(@i_bookkey,1),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Weight Missing. Please enter a Weight.',@i_username, getdate() )
						set @v_varnings = 1
					end 
				end
		end


--Bar Code Cross Reference
--		exec bookverification_check 'BHP_BC_Cross_Reference', @i_write_msg output
--		if @i_write_msg = 1 
--		begin
--			if @i_verificationtypecode = 6
--				begin
--					if nullif(dbo.rpt_get_format(@i_bookkey,'E'),'') is null
--					begin
--						exec get_next_key @i_username, @v_nextkey out
--						insert into bookverificationmessage
--           (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
--						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Bar Code Cross Reference Missing. Please enter a Bar Code Cross Reference on Format User Tables.',@i_username, getdate() )
--						set @v_failed = 1
--					end 
--				end
--		end

--Product Line --Error
		exec bookverification_check 'BHP_Product_Line', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,276,'external'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Product Line Missing. Please enter a Product Line.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end

--MSRP USD --Error
	EXEC bookverification_check 'BHP_MSRP_USD',
							@i_write_msg OUTPUT

	IF @i_write_msg = 1
						
	BEGIN
			IF @i_verificationtypecode = 6
			BEGIN
								
							
							DECLARE @i_msrp_ct INT

							IF dbo.rpt_get_misc_value(@i_bookkey, 56, 'external') NOT IN (
									'LWDATESUB',
									'LWSUBMAST'
									)
							BEGIN
								SELECT @i_msrp_ct = count(pricekey)
								FROM bookprice
								WHERE bookkey = @i_bookkey
									AND pricetypecode = 8
									AND currencytypecode = 6
									AND (
										ISNULL(cast (budgetprice as varchar(max)), '') <> ''
										OR ISNULL(cast (finalprice  as varchar(max)), '') <> ''
										)

								IF @i_msrp_ct = 0
									--dbo.rpt_get_price (@i_bookkey,8,6,'B'),'') is null
								BEGIN
									EXEC get_next_key @i_username,
										@v_nextkey OUT

									INSERT INTO bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									VALUES (
										@v_nextkey,
										@i_bookkey,
										@i_verificationtypecode,
										@v_Error,
										'MSRP Price Missing. Please enter a Price.',
										@i_username,
										getdate()
										)

									SET @v_failed = 1
								END
							END
							ELSE IF dbo.rpt_get_misc_value(@i_bookkey, 56, 'external') IN (
									'LWDATESUB',
									'LWSUBMAST'
									)
							BEGIN
								SELECT @i_msrp_ct = count(pricekey)
								FROM bookprice
								WHERE bookkey = @i_bookkey
									AND pricetypecode = 8

								IF @i_msrp_ct > 0
								BEGIN
									EXEC get_next_key @i_username,
										@v_nextkey OUT

									INSERT INTO bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									VALUES (
										@v_nextkey,
										@i_bookkey,
										@i_verificationtypecode,
										@v_Error,
										'MSRP Found on product with item type in (LW SUBSCRIPTION MASTER , LW DATED SUB). MSRP Not allowed on these item types',
										@i_username,
										getdate()
										)

									SET @v_failed = 1
								END
							END
			END
	END
	
----expiration date must be today or in the future
--exec bookverification_check 'BHP_Price_exp_future', @i_write_msg output
--		if @i_write_msg = 1 
--		begin
--			if @i_verificationtypecode = 6
--				BEGIN
--				IF exists (select 1 from bookprice 
--				where expirationdate<DateAdd(Day, Datediff(Day, 0, lastmaintdate), 0) 
--				and bookkey=@i_bookkey 
--				AND lastuserid NOT LIKE '%Price_Import%' and lastmaintdate > DateAdd(Day, Datediff(Day, 0, GETDATE()), 0) - 1 --this will be the hard code for EDH golive date
--				)
--				BEGIN
--				exec get_next_key @i_username, @v_nextkey out
--											insert into bookverificationmessage
--                     (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
--											values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'An price expiration date needs to either be today or in the future.',@i_username, getdate() )
--											set @v_failed = 1
--				END

				
				
--				END
--		END

----effective date must be next day or future
--exec bookverification_check 'BHP_Price_eff_future', @i_write_msg output
--		if @i_write_msg = 1 
--		begin
--			if @i_verificationtypecode = 6
--				BEGIN
--				IF exists (select 1 from bookprice 
--				where effectivedate<DateAdd(Day, Datediff(Day, 0, lastmaintdate), 0) +1
--				and bookkey=@i_bookkey 
--				AND lastuserid NOT LIKE '%Price_Import%' and lastmaintdate > DateAdd(Day, Datediff(Day, 0, GETDATE()), 0) - 1 --this will be the hard code for EDH golive date
--				)
--				BEGIN
--				exec get_next_key @i_username, @v_nextkey out
--											insert into bookverificationmessage
--                     (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
--											values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'An price effective date needs to either be tomorrow or in the future.',@i_username, getdate() )
--											set @v_failed = 1
--				END

				
				
--				END
--		END


--PRICE EXP
/*
		exec bookverification_check 'BHP_Price_exp', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begiN
									
					IF NOT EXISTS (
							SELECT 1
							FROM bookmisc
							WHERE misckey = (
									SELECT misckey
									FROM bookmiscitems
									WHERE qsicode = 22
									)
								AND bookkey = @i_bookkey
								AND longvalue = 1
							)
					BEGIN
						IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
							DROP TABLE #TEMP

						SELECT pricetypecode,
							currencytypecode,
							count(1) AS counter
						INTO #TEMP
						FROM bookprice
						WHERE bookkey = @i_bookkey
							AND lastmaintdate > DateAdd(Day, Datediff(Day, 0, GETDATE()), 0) - 1 --this will be the hard code for EDH golive date
						GROUP BY pricetypecode,
							currencytypecode

						SELECT TOP 1 @PRICELIST = pricetypecode,
							@CURRTYPE = currencytypecode
						FROM #TEMP
						ORDER BY pricetypecode DESC

						WHILE EXISTS (
								SELECT 1
								FROM #TEMP
								)
						BEGIN
							IF (
									SELECT counter
									FROM #TEMP
									WHERE pricetypecode = @PRICELIST
										AND currencytypecode = @CURRTYPE
									) = 1
							BEGIN
								IF EXISTS (
										SELECT 1
										FROM bookprice
										WHERE bookkey = @i_bookkey
											AND pricetypecode = @PRICELIST
											AND currencytypecode = @CURRTYPE
											AND expirationdate IS NULL
											AND effectivedate < DateAdd(Day, Datediff(Day, 0, lastmaintdate), 0)
											AND lastuserid NOT LIKE '%Price_Import%'
										)
								BEGIN
										exec get_next_key @i_username, @v_nextkey out
											insert into bookverificationmessage
                      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
											values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'A price has an effective date, no expiration date, and a last maintenance date after the effective date. Please add an expiration date.',@i_username, getdate() )
											set @v_failed = 1


									GOTO DONE
								END
							END
							ELSE IF (
									SELECT counter
									FROM #TEMP
									WHERE pricetypecode = @PRICELIST
										AND currencytypecode = @CURRTYPE
									) > 1
							BEGIN
								SELECT @maxlastmaintdate = max(lastmaintdate)
								FROM bookprice
								WHERE bookkey = @i_bookkey
									AND pricetypecode = @PRICELIST
									AND currencytypecode = @CURRTYPE

								IF EXISTS (
										SELECT 1
										FROM bookprice
										WHERE bookkey = @i_bookkey
											AND pricetypecode = @PRICELIST
											AND currencytypecode = @CURRTYPE
											AND effectivedate < DateAdd(Day, Datediff(Day, 0, @maxlastmaintdate), 0)
											AND expirationdate IS NULL
											AND lastuserid NOT LIKE '%Price_Import%'
										)
								BEGIN
										exec get_next_key @i_username, @v_nextkey out
											insert into bookverificationmessage
                      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
											values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 
					'All prices in a list, that fall before the most recent maintenance date of that price type, must have a expiration date.',@i_username, getdate() )
											set @v_failed = 1

									GOTO DONE
								END
							END

							DELETE
							FROM #TEMP
							WHERE pricetypecode = @PRICELIST
								AND currencytypecode = @CURRTYPE

							SELECT TOP 1 @PRICELIST = pricetypecode,
								@CURRTYPE = currencytypecode
							FROM #TEMP
							ORDER BY pricetypecode DESC
						END

						DONE:
					END


				
				END
		END
*/		

--Discount Code --Jorge
		exec bookverification_check 'BHP_Discount_Code', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_discount (@i_bookkey,'D'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Discount Missing. Please enter a Discount.',@i_username, getdate() )
						set @v_varnings = 1
					end 
				end
		end

--Return Status --Error
		exec bookverification_check 'BHP_Return_Status', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,50,'external'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Return Status Missing. Please enter a Return Status.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end

--Royalty --Error
		exec bookverification_check 'BHP_Royalty', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,51,'external'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Royalty Missing. Please enter a Royalty.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
--Auto Release --Warning - Jorge
		exec bookverification_check 'BHP_Auto_Release', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,52,'short'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Warning, 'Auto Release Missing. Please enter an Auto Release.',@i_username, getdate() )
						set @v_varnings = 1
					end 
				end
		end
--Contract --Error
		exec bookverification_check 'BHP_Contract', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if not exists (
					select * from taqprojecttask where datetypecode = 395 and actualind = 1 and bookkey = @i_bookkey)
					and
					dbo.rpt_get_misc_value(@i_bookkey,99,'long') = 'No'
					
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Contract Signed Date or Send to Oracle Override Missing. Please enter a Signed Contract Date and Actual Indicator or Set the Send to Oracle Override Indicator.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end

--Proforma --Error - Copies of Proforma Available
		exec bookverification_check 'BHP_Proforma', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if not exists (
					select * from taqprojecttask where datetypecode = 395 and actualind = 1 and bookkey = @i_bookkey)
					and
					dbo.rpt_get_misc_value(@i_bookkey,76,'long') = 'No'
					
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Copies of Proforma Available Missing. Please enter a value in Copies of Proforma Available if true.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
--Cross Reference --Error
		exec bookverification_check 'BHP_Cross_Reference', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,103,'long'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Primary Cross Reference is Missing. Please enter Primary Cross Reference.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
		--select * from bookmiscitems where misckey = 103
		
--Page Count --Error
		exec bookverification_check 'BHP_Page_Count', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_page_count (@i_bookkey,1,'B'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Page Count Missing. Please enter a Page Count.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
--Author --Error
		exec bookverification_check 'BHP_Author', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_author (@i_bookkey,1,0,'D'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Author Missing. Please enter an Author.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
--Pub Date --Error
		exec bookverification_check 'BHP_Pub_Date', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_title_task (@i_bookkey,8,'B'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Pub Date Missing. Please enter a Pub Date.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
--First Ship Date --Error
		exec bookverification_check 'BHP_First_Ship_Date', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_title_task (@i_bookkey,309,'B'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Ship Date Missing. Please enter a Ship Date.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
--Business Leader --Error  
		exec bookverification_check 'BHP_Business_Leader', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_participant (@i_bookkey,10,'D'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Business Leader Missing. Please enter a Business Leader.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
--Fully Loaded 1 --Error
		exec bookverification_check 'BHP_Fully_Loaded_1', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					if nullif(dbo.rpt_get_misc_value (@i_bookkey,100,'long'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Fully Loaded 1 Missing. Please enter a value for Fully Loaded 1.',@i_username, getdate() )
						set @v_failed = 1
					end 
				end
		end
		
--Trim Size --Error  for all except eBook
		exec bookverification_check 'BHP_Trim_Size', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6
				begin
					
					declare @i_mediatypecode int
					--select * from gentables where tableid = 312 --14
					select @i_mediatypecode = mediatypecode from bookdetail where bookkey = @i_bookkey
					if @i_mediatypecode <> 14
					begin
					
					if nullif(dbo.rpt_get_trim_size (@i_bookkey,1,'B'),'') is null
					begin
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
            (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Trim Size Missing. Please enter a Trim Size.',@i_username, getdate() )
						set @v_failed = 1
					end 
					
					end
				end
		end		
--if @i_write_msg = 1 
--	begin
--		if @i_verificationtypecode = 6 
--			begin
--					If (14=14)
--					begin
--						exec get_next_key @i_username, @v_nextkey out
--						insert into bookverificationmessage
--           (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
--						values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Edit Error',@i_username, getdate() )
--						set @v_failed = 1
--						set @v_excluded_from_onix = 1
--					end
--			end
--		end




--IF Oracle status doesnt exists set it to 0 else set the variable to the status long value
		IF EXISTS (
				SELECT 1 longvalue
				FROM bookmisc
				WHERE misckey = 59 and longvalue is null
					AND bookkey = @i_bookkey
				)
				BEGIN
				UPDATE bookmisc set longvalue=3 where bookkey=@i_bookkey and misckey=59
				END
				
		IF EXISTS (
				SELECT 1 longvalue
				FROM bookmisc
				WHERE misckey = 59 and longvalue is not null
					AND bookkey = @i_bookkey
				)
		BEGIN
			SELECT @sostatus = longvalue
			FROM bookmisc
			WHERE misckey = 59
				AND bookkey = @i_bookkey
		END
		ELSE
		BEGIN
			SET @sostatus = 0
		END


--ORACLE FAILED

		SELECT @v_datacode = datacode
		FROM gentables
		WHERE tableid = 513
			AND qsicode = 2


		IF @v_failed = 1
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey
						AND verificationtypecode = @i_verificationtypecode
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey,
					6,
					@v_datacode,
					@i_username,
					getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode,
					lastmaintdate = getdate(),
					lastuserid = @i_username
				WHERE bookkey = @i_bookkey
					AND verificationtypecode = @i_verificationtypecode
			END

			--FAILED
			IF @sostatus IS NOT NULL
			BEGIN
				IF @sostatus = 0 -- NO PREVIOUS STATUS
				BEGIN
					SET @setstatus = 3 --3	Pending Oracle Review
				END
				ELSE IF @sostatus = 1 --1	Approved for Oracle Load
				BEGIN
					SET @setstatus = 2 --2	Review for Data Errors/Questions
				END
				ELSE IF @sostatus = 2 --2	Review for Data Errors/Questions
				BEGIN
					SET @setstatus = 2 --2	Review for Data Errors/Questions
				END
				ELSE IF @sostatus = 3 --3	Pending Oracle Review
				BEGIN
					SET @setstatus = 3 --3	Pending Oracle Review
				END
				ELSE IF @sostatus = 4 --4	Active
				BEGIN
					SET @setstatus = 2 --2	Review for Data Errors/Questions
				END
				ELSE IF @sostatus = 5 --5	Sync and Review
				BEGIN
					SET @setstatus = 5 --5	Sync and Review
				END

				IF NOT EXISTS (
						SELECT 1
						FROM bookmisc
						WHERE bookkey = @i_bookkey
							AND misckey = 59
						)
				BEGIN
					INSERT INTO bookmisc (
						bookkey,
						misckey,
						longvalue,
						lastuserid,
						lastmaintdate,
						sendtoeloquenceind
						)
					SELECT @i_bookkey,
						59,
						@setstatus,
						'fbt_oracle_verif',
						GETDATE(),
						0
				END
				ELSE
				BEGIN
					UPDATE bookmisc
					SET longvalue = @setstatus,
						lastuserid = 'fbt_oracle_verif',
						lastmaintdate = GETDATE()
					WHERE bookkey = @i_bookkey
						AND misckey = 59
				END
			END
		END





--ORACLE PASSED WITH WARNING

		--passed with warnings
		SELECT @v_datacode = datacode
		FROM gentables
		WHERE tableid = 513
			AND qsicode = 4

		IF @v_failed = 0
			AND @v_varnings = 1
		BEGIN
			UPDATE bookverification
			SET titleverifystatuscode = @v_datacode,
				lastmaintdate = getdate(),
				lastuserid = @i_username
			WHERE bookkey = @i_bookkey
				AND verificationtypecode = @i_verificationtypecode

			--PASSED
			IF @sostatus IS NOT NULL
			BEGIN
				IF @sostatus = 0 -- NO PREVIOUS STATUS
				BEGIN
					SET @setstatus = 3 --3	Pending Oracle Review
				END
				ELSE IF @sostatus = 1 --1	Approved for Oracle Load
				BEGIN
					SET @setstatus = 1 --1	Approved for Oracle Load
				END
				ELSE IF @sostatus = 2 --2	Review for Data Errors/Questions
				BEGIN
					SET @setstatus = 1 --1	Approved for Oracle Load
				END
				ELSE IF @sostatus = 3 --3	Pending Oracle Review
				BEGIN
					SET @setstatus = 1 --1	Approved for Oracle Load
				END
				ELSE IF @sostatus = 4 --4	Active
				BEGIN
					SET @setstatus = 4 --4	Active
				END
				ELSE IF @sostatus = 5 --5	Sync and Review
				BEGIN
					SET @setstatus = 5
				END

				IF NOT EXISTS (
						SELECT 1
						FROM bookmisc
						WHERE bookkey = @i_bookkey
							AND misckey = 59
						)
				BEGIN
					INSERT INTO bookmisc (
						bookkey,
						misckey,
						longvalue,
						lastuserid,
						lastmaintdate,
						sendtoeloquenceind
						)
					SELECT @i_bookkey,
						59,
						@setstatus,
						'fbt_oracle_verif',
						GETDATE(),
						0
				END
				ELSE
				BEGIN
					UPDATE bookmisc
					SET longvalue = @setstatus,
						lastuserid = 'fbt_oracle_verif',
						lastmaintdate = GETDATE()
					WHERE bookkey = @i_bookkey
						AND misckey = 59
				END
			END
					--if @i_verificationtypecode = 1 begin
					-- update coretitleinfo set verifcustomer = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
					--end
					--if @i_verificationtypecode = 2 begin
					-- update coretitleinfo set verifelobasic = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
					--end
					--if @i_verificationtypecode = 3 begin
					-- update coretitleinfo set verifbna = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
					--end
					--if @i_verificationtypecode = 4 begin
					-- update coretitleinfo set verifbooknet = @v_datacode where bookkey = @i_bookkey and printingkey = @i_printingkey
					--end
		END




--ORACLE PASSED 

		--passed
		SELECT @v_datacode = datacode
		FROM gentables
		WHERE tableid = 513
			AND qsicode = 3

		IF @v_failed = 0
			AND @v_varnings = 0
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey
						AND verificationtypecode = @i_verificationtypecode
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey,
					5,
					@v_datacode,
					@i_username,
					getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode,
					lastmaintdate = getdate(),
					lastuserid = @i_username
				WHERE bookkey = @i_bookkey
					AND verificationtypecode = @i_verificationtypecode
			END

			--PASSED
			IF @sostatus IS NOT NULL
			BEGIN
				IF @sostatus = 0 -- NO PREVIOUS STATUS
				BEGIN
					SET @setstatus = 3 --3	Pending Oracle Review
				END
				ELSE IF @sostatus = 1 --1	Approved for Oracle Load
				BEGIN
					SET @setstatus = 1 --1	Approved for Oracle Load
				END
				ELSE IF @sostatus = 2 --2	Review for Data Errors/Questions
				BEGIN
					SET @setstatus = 1 --1	Approved for Oracle Load
				END
				ELSE IF @sostatus = 3 --3	Pending Oracle Review
				BEGIN
					SET @setstatus = 1 --1	Approved for Oracle Load
				END
				ELSE IF @sostatus = 4 --4	Active
				BEGIN
					SET @setstatus = 4 --4	Active
				END
				ELSE IF @sostatus = 5 --5	Sync and Review
				BEGIN
					SET @setstatus = 5
				END

				IF NOT EXISTS (
						SELECT 1
						FROM bookmisc
						WHERE bookkey = @i_bookkey
							AND misckey = 59
						)
				BEGIN
					INSERT INTO bookmisc (
						bookkey,
						misckey,
						longvalue,
						lastuserid,
						lastmaintdate,
						sendtoeloquenceind
						)
					SELECT @i_bookkey,
						59,
						@setstatus,
						'fbt_oracle_verif',
						GETDATE(),
						0
				END
				ELSE
				BEGIN
					UPDATE bookmisc
					SET longvalue = @setstatus,
						lastuserid = 'fbt_oracle_verif',
						lastmaintdate = GETDATE()
					WHERE bookkey = @i_bookkey
						AND misckey = 59
				END
			END
		END
	END
	ELSE
		--Set verification status for non-B&H products to Not Applicable
	BEGIN
		DELETE bookverificationmessage
		WHERE bookkey = @i_bookkey
			AND verificationtypecode = @i_verificationtypecode

		IF NOT EXISTS (
				SELECT *
				FROM bookverification
				WHERE bookkey = @i_bookkey
					AND verificationtypecode = @i_verificationtypecode
				)
		BEGIN
			INSERT INTO bookverification
			SELECT @i_bookkey,
				5,
				8,
				@i_username,
				getdate()
		END
		ELSE
		BEGIN
			UPDATE bookverification
			SET titleverifystatuscode = 8,
				lastmaintdate = getdate(),
				lastuserid = @i_username
			WHERE bookkey = @i_bookkey
				AND verificationtypecode = @i_verificationtypecode
		END
	END
END
GO
GRANT EXEC on [dbo].[BHP_TM_To_Oracle_Verification] to public
go

