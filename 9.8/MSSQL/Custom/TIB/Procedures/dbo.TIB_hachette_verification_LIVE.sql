if exists (select * from dbo.sysobjects where id = object_id(N'dbo.TIB_hachette_verification') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.TIB_hachette_verification
GO

CREATE proc dbo.TIB_hachette_verification(
		     @i_bookkey int,
  @i_printingkey int,
  @i_verificationtypecode int,
  @i_username varchar(15),
  @o_error_code INT OUT,
  @o_error_desc VARCHAR(2000) OUT)

AS
 
BEGIN
SET NOCOUNT ON; 


/*
6/21/17 == TT: Added language code requirement
07/21/2017 == TT: Pub Date Changes  
Pub Date: Check from bookdates not taqprojecttask. If not marked as key in taqprojecttask, the trigger is not going to insert it into bookdates
elo verification checks in bookdates, get product sends only from Bookdates as well. 
08/25/2017 == TT: Associated format logic: For Sets, associated format is required which is the format of the primary component of the set. 
08/30/2018 == TT: Set type will map to BOM Type. Require it for SETS. 
08/30/2018 == TT: If Internal Only flag is checked, we will fail HBG verification.  
*/

/*
Run the following to insert "Ready for Verification" Rows

DECLARE @statuscode int 
DECLARE @verificationtypecode int 

Select @statuscode = datacode from gentables where tableid=513 and qsicode = 1
SET @verificationtypecode = 7 


Insert into bookverification(bookkey, verificationtypecode, titleverifystatuscode, lastuserid, lastmaintdate)
Select b.bookkey , @verificationtypecode, @statuscode, 'VerificationImport', GETDATE()
FROM book b
where standardind = 'N' -- no templates
and usageclasscode = 1 -- Titles
and not exists (Select 1 from bookverification where bookkey = b.bookkey and verificationtypecode = @verificationtypecode)


*/


/*

-- Use following script to insert new message types 

Delete from gentables_ext where datacode > 35 and tableid = 675 

Delete from gentables where datacode > 35 and tableid = 675 

Select * FROM gentables where tableid = 675 

declare @datacode int
select @datacode=max(datacode) +1 from gentables where tableid=675
  
INSERT INTO gentables
(tableid,datacode, datadesc,deletestatus,tablemnemonic, lastuserid,lastmaintdate, lockbyqsiind, lockbyeloquenceind )
VALUES (675, @datacode,'Missing Audience','N', 'VERMSGTP','FBTDBA',getdate(),1,0)


declare @datacode int
select @datacode=max(datacode) +1 from gentables where tableid=675
  
INSERT INTO gentables
(tableid,datacode, datadesc,deletestatus,tablemnemonic, lastuserid,lastmaintdate, lockbyqsiind, lockbyeloquenceind )
VALUES (675, @datacode,'Missing Family Code','N', 'VERMSGTP','FBTDBA',getdate(),1,0 )

declare @datacode int
select @datacode=max(datacode) +1 from gentables where tableid=675

INSERT INTO gentables
(tableid,datacode, datadesc,deletestatus,tablemnemonic, lastuserid,lastmaintdate, lockbyqsiind, lockbyeloquenceind )
VALUES (675, @datacode,'Missing Hachette Format Code','N', 'VERMSGTP','FBTDBA',getdate(),1,0 )




declare @datacode int
select @datacode=max(datacode) +1 from gentables where tableid=675

INSERT INTO gentables
(tableid,datacode, datadesc,deletestatus,tablemnemonic, lastuserid,lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode)
VALUES (675, @datacode,'Missing Age Low','N', 'VERMSGTP','FBTDBA',getdate(),1,0, 34)


declare @datacode int
select @datacode=max(datacode) +1 from gentables where tableid=675

INSERT INTO gentables
(tableid,datacode, datadesc,deletestatus,tablemnemonic, lastuserid,lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode )
VALUES (675, @datacode,'Missing Age High','N', 'VERMSGTP','FBTDBA',getdate(),1,0, 35)

Update gentablesdesc 
SET refreshcacheind = 1
WHERE tableid = 675


*/


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
DECLARE @msg varchar(150)
DECLARE @v_messagecategoryqsicode int
DECLARE @v_msg VARCHAR(255) 
DECLARE @v_rowcount INT 

DECLARE @v_Author varchar(120)
Declare @v_BISACSubject varchar(100)
Declare @v_Audience varchar(100)
DECLARE @v_familycode varchar(100)
Declare @v_BISACStatus_origpub varchar(10)
DECLARE @v_bisacstatus_US varchar(40)
Declare @v_UsageClass varchar(10)
Declare @v_Pubdate_origpub datetime
DECLARE @v_Pubdate_US varchar(10)
DECLARE @v_ISBN13 varchar(13)
DECLARE @v_Title varchar(80)
DECLARE @internalOnly char(1) 

DECLARE @coo as varchar(20)
DECLARE @pubdate_datetypecode_us int
DECLARE @hachette_format_code varchar(30)
DECLARE @hbg_family_cnt int 
DECLARE @hbg_format_cnt int 
DECLARE @languagecode1 int
DECLARE @languagecode2 int 
DECLARE @isSet tinyint 
DECLARE @associatedformatcode varchar(30)
DECLARE @associatedsubformatcode varchar(30)
DECLARE @setType varchar(1)

SET @internalOnly = 'N'
SET @isSet = 0 


DECLARE @v_agelowupind int,
@v_agehighupind int,
@v_agelow float, 
@v_agehigh float,
@v_allagesind tinyint




set @v_Error = 2

set @v_Warning = 3
set @v_Information = 4
set @v_Aborted = 5
set @v_Completed = 6
set @v_failed = 0 
set @v_varnings = 0



IF NOT EXISTS (SELECT 1 FROM bookverification where bookkey= @i_bookkey and verificationtypecode = @i_verificationtypecode)
begin 
  insert into bookverification select @i_bookkey, @i_verificationtypecode,1,'fbt-initial',getdate()
	
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error inserting into bookverification table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) +
      + ', verificationtypecode=' + CONVERT(VARCHAR, @i_verificationtypecode) + ').'
    RETURN
  END	
end


--clean bookverificationmessage for passed bookkey
delete bookverificationmessage
where bookkey = @i_bookkey
and verificationtypecode = @i_verificationtypecode

SELECT @v_error = @@ERROR
IF @v_error <> 0
BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error deleting rows from bookverificationmessage table (verificationtypecode=' + CONVERT(VARCHAR, @i_verificationtypecode) + ').'
  RETURN
END	


--if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_ISBN13')
--begin
--  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
--  Select 'HACHETTE_ISBN13',1,'qsidba',GETDATE()
-- end
--if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_Title')
--begin
--  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
--  Select 'HACHETTE_Title',1,'qsidba',GETDATE()
-- end
--if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_Pubdate')
--begin
--  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
--  Select 'HACHETTE_Pubdate',1,'qsidba',GETDATE()
-- end
--if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_BISACStatus')
--begin
--  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
--  Select 'HACHETTE_BISACStatus',1,'qsidba',GETDATE()
-- end
--if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_UsageClass')
--begin
--  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
--  Select 'HACHETTE_UsageClass',1,'qsidba',GETDATE()
-- end
--if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_BISACSubject')
--begin
--  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
--  Select 'HACHETTE_BISACSubject',1,'qsidba',GETDATE()
-- end
--if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_Audience')
--begin
--  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
--  Select 'HACHETTE_Audience',1,'qsidba',GETDATE()
-- end
--if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_Author')
--begin
--  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
--  Select 'HACHETTE_Author',1,'qsidba',GETDATE()
-- end
--if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_familycode')
--begin
--  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
--  Select 'HACHETTE_familycode',1,'qsidba',GETDATE()
-- end
 


--Select @coo = dbo.rpt_get_country_of_origin(@i_bookkey, 5)

--Select @pubdate_datetypecode_us = datetypecode from datetype where eloquencefieldtag = '1US'

--Select @v_bisacstatus_US = sg.datadesc from bookproductdetail bpd
--JOIN subgentables sg 
--on bpd.tableid = sg.tableid and bpd.datacode = sg.datacode and bpd.datasubcode = sg.datasubcode 
--join gentables g 
--on sg.tableid = g.tableid and g.datacode = sg.datacode 
--where g.tableid = 659 and g.eloquencefieldtag = 'US' 
--and g.deletestatus = 'N' and sg.deletestatus = 'N'
--and ISNULL(sg.eloquencefieldtag, '') <> ''


--Select @v_familycode = oe.customid1 from bookorgentry boe 
--join orgentry oe 
--on boe.orgentrykey = oe.orgentrykey
--where bookkey = @i_bookkey and boe.orglevelkey = 5 


SET @hbg_family_cnt = 0 

SElect @hbg_family_cnt = COUNT(*) FROm booksubjectcategory bcs
JOIN sub2gentables s2
on bcs.categorycode = s2.datacode and bcs.categorysubcode = s2.datasubcode and bcs.categorysub2code = s2.datasub2code and bcs.categorytableid = s2.tableid
JOIN subgentables s
on s2.datasubcode = s.datasubcode and s2.datacode = s.datacode and s2.tableid = s.tableid 
JOIN gentables g
on s.datacode = g.datacode and s.tableid = g.tableid 
where bcs.categorytableid = 412 and bcs.bookkey = @i_bookkey 
and s2.deletestatus = 'N' and s.deletestatus = 'N' and g.deletestatus = 'N'
and ISNULL(s2.alternatedesc1, '') <> '' and LEN(s2.alternatedesc1) = 8  


SET @hbg_format_cnt = 0 
Select @hbg_format_cnt = Count(*) from booksubjectcategory bsc join gentables g on bsc.categorytableid = g.tableid and bsc.categorycode = g.datacode 
where bookkey = @i_bookkey and g.tableid = 414 and g.deletestatus = 'N' and ISNULL(externalcode, '') <> ''




Select 
@v_ISBN13 = ISNULL(i.ean13, ''),
@v_Title = b.title,
--@v_Pubdate_origpub = nullif(Convert(varchar(10),dbo.[rpt_get_title_task_Printingkey_Specific](@i_bookkey,8,1,'B'),101),''),

--@v_Pubdate_origpub = dbo.rpt_get_title_task_Printingkey_Specific(@i_bookkey,8,1,'B'),
@v_Pubdate_origpub = dbo.rpt_get_date(@i_bookkey,1,8,'B'),
--@v_Pubdate_US = dbo.rpt_get_title_task_Printingkey_Specific(@i_bookkey,@pubdate_datetypecode_us,1,'B'),
@v_BISACStatus_origpub = dbo.rpt_get_bisac_status(b.bookkey, 'D'),
@v_Audience = dbo.rpt_get_audience(b.bookkey, 'D', 1),
@v_BISACSubject = dbo.rpt_get_bisac_subject(@i_bookkey,1,'d'),
@v_Author = Case when exists (Select 1 from bookauthor where bookkey = @i_Bookkey and exists (select 1  from gentables where tableid=134 and datacode = bookauthor.authortypecode and deletestatus = 'N')) Then 'Y'
		   else '' end,
--@hachette_format_code = dbo.rpt_get_format(b.bookkey, 'E'),
--@hachette_format_code = (Select TOP 1 g.externalcode from booksubjectcategory bsc join gentables g on bsc.categorytableid = g.tableid and bsc.categorycode = g.datacode 
--where bookkey = b.bookkey and g.tableid = 414 and g.deletestatus = 'N' ORDER BY bsc.lastmaintdate DESC),
@v_agelowupind = bd.agelowupind,
@v_agehighupind = bd.agehighupind, 
@v_agelow = bd.agelow, 
@v_agehigh = bd.agehigh,
@v_allagesind = bd.allagesind,
@languagecode1 = languagecode, 
@languagecode2 = @languagecode2
FROM book b 
JOIN isbn i 
on b.bookkey = i.bookkey 
JOIN bookdetail bd 
ON b.bookkey = bd.bookkey 
where b.bookkey = @i_bookkey

if exists (Select 1 from book where bookkey = @i_bookkey and usageclasscode = 2)
	BEGIN
		SET @isSet = 1

		
			Select  --TOP 1
			@associatedformatcode = g.externalcode, 
			@associatedsubformatcode = (Select externalcode from subgentables s where tableid = 414 and s.deletestatus = 'N' and 
												datacode = bsc.categorycode and datasubcode = bsc.categorysubcode)
			FROM associatedtitles a 
			JOIN booksubjectcategory bsc 
			ON a.associatetitlebookkey = bsc.bookkey
			JOIN gentables g 
			On bsc.categorytableid = g.tableid and bsc.categorycode = g.datacode
			--LEFT OUTER JOIN subgentables s 
			--ON bsc.categorytableid = s.tableid and bsc.categorycode = s.datacode and bsc.categorysubcode = s.datasubcode 
			--join gentables g 
			--on s.tableid = g.tableid and s.datacode = g.datacode 
			where a.bookkey = @i_bookkey 
			and a.associationtypecode = 6 -- titles in sets
			and a.associationtypesubcode = 1 -- set component
			--and s.tableid = 414 
			and g.tableid = 414
			and g.deletestatus = 'N' 
			and a.sortorder = 1
			--and s.deletestatus = 'N'
			--and ISNULL(s.externalcode, '') <> ''
			--ORDER BY a.sortorder

			Select @setType = g.eloquencefieldtag
			FROM booksets bs
			JOIN gentables g 
			ON bs.settypecode = g.datacode 
			where bookkey = @i_bookkey
			and printingkey = 1 
			and g.tableid = 481




	END

-- Internal Only Flag 
IF exists (Select 1 from bookmisc where bookkey = @i_bookkey and misckey = 313 and longvalue = 1)
	BEGIN
		SET @internalOnly = 'Y'
	END

-- if COO is UK, check to see whether you have US status or Orig Pub
-- If COO is US, check to see you have Orig Pub




--Select @v_ISBN13 = nullif(ean13,'') from isbn where bookkey = @i_bookkey
--Select @v_Title = nullif(substring(title,1,80),'') from book where bookkey = @i_bookkey
--Select @v_Pubdate = nullif(Convert(varchar(10),dbo.[rpt_get_title_task_Printingkey_Specific](@i_bookkey,8,1,'B'),101),'')

--Select @v_UsageClass = nullif(Cast(usageclasscode as varchar(1)),'') from book where bookkey =@i_bookkey
--Select @v_BISACSubject = nullif(dbo.rpt_get_bisac_subject(@i_bookkey,1,'d'),'')
--Select @v_Audience = coalesce(dbo.rpt_hbg_get_assoc_title_audience (@i_bookkey,1,8),dbo.rpt_get_bisac_subject(@i_bookkey,1,'B'))
--select @v_audience = nullif(@v_Audience,'') 
--Select @v_Author =  (select count(*) from bookauthor where bookkey = @i_Bookkey and authortypecode in (select datacode from gentables where tableid=134))	 --nullif(dbo.rpt_get_author (@i_bookkey,1,12,'D'),'')
--Select @v_Author = nullif(@v_Author,'')
--Select @v_familycode =  nullif(  (Select top 1 dbo.rpt_get_gentables_field(412,CategoryCode,'E') from booksubjectcategory b 
--	   where b.bookkey=@i_bookkey and categorytableid=412 and sortorder=(select min(sortorder) from booksubjectcategory where bookkey=@i_bookkey and categorytableid=412))
--	,'')


--print @v_ISBN13 
--print @v_Title 
--print @v_Pubdate 
--print @v_BISACStatus 
--print @v_UsageClass 
--print @v_BISACSubject 
--print @v_Audience 
--print @v_Author 
--print @v_familycode 


if ISNULL(@v_ISBN13, '') = '' 
begin
	SET @v_failed = 1
	SET @v_msg = 'Missing EAN (Product Number)' 
	SET @v_messagecategoryqsicode = 19
	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, 2, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
	  RETURN
end 


if ISNULL(@v_Title, '') = '' 
begin
	SET @v_failed = 1
	SET @v_msg = 'Missing Book Title' 
	SET @v_messagecategoryqsicode = 23
	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, 2, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
	  RETURN
end 


-- if COO is UK (not US), check to see whether you have market specific US status or Orig Pub
-- If COO is US, check to see you have Orig Pub

--if (ISNULL(@coo, '') <> 'US' and ISNULL(@v_Pubdate_US, '') = '' AND  ISNULL(@v_Pubdate_origpub, '') = '')
--OR (ISNULL(@coo, '') = 'US' and ISNULL(@v_Pubdate_origpub, '') = '')

if ISNULL(@v_Pubdate_origpub, '') = ''
begin
	SET @v_failed = 1
	SET @v_msg = 'Missing or no Key Pub Date' 
	SET @v_messagecategoryqsicode = 20
	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, 2, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
	  RETURN
end 



--if (ISNULL(@coo, '') <> 'US' and ISNULL(@v_bisacstatus_US, '') = '' AND  ISNULL(@v_BISACStatus_origpub, '') = '')
--OR (ISNULL(@coo, '') = 'US' and ISNULL(@v_BISACStatus_origpub, '') = '')

If ISNULL(@v_BISACStatus_origpub, '') = ''
begin
	SET @v_failed = 1
	SET @v_msg = 'Missing BISAC status code' 
	SET @v_messagecategoryqsicode = 9
	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, 2, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
	  RETURN
end 

if ISNULL(@v_BISACSubject, '') = '' 
begin
	SET @v_failed = 1
	SET @v_msg = 'Missing Bisac Subject Category' 
	SET @v_messagecategoryqsicode = 10
	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, 2, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
	  RETURN
end 

if ISNULL(@v_Audience, '') = '' 
begin
	SET @v_failed = 1
	SET @v_msg = 'Missing Audience' 
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate, messagecategorycode)
	SELECT @v_nextkey, @i_bookkey, @i_verificationtypecode, 2, @v_msg ,@i_username, getdate(), NULL
end 


if ISNULL(@v_Author, '') = '' 
begin
	SET @v_failed = 1
	SET @v_msg = 'Missing Author' 
	SET @v_messagecategoryqsicode = 8
	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, 2, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
	  RETURN
end 

--if ISNULL(@v_familycode, '') = '' 
if ISNULL(@hbg_family_cnt, 0) <>  1 
begin
	SET @v_failed = 1
	SET @v_msg = 'Hachette Family Code is either missing (HBG Reporting Group/Publisher/Imprint category),  not configured properly or multiple entries exist' 
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate, messagecategorycode)
	SELECT @v_nextkey, @i_bookkey, @i_verificationtypecode, 2, @v_msg ,@i_username, getdate(), NULL
end 

--if ISNULL(@hachette_format_code, '') = '' 
if ISNULL(@hbg_format_cnt, 0) <>  1 
begin
	SET @v_failed = 1
	SET @v_msg = 'Hachette Format Code is either missing (HBG Format/Sub-Format category), not configured properly or multiple entries exist' 
	exec get_next_key @i_username, @v_nextkey out
	insert into bookverificationmessage (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate, messagecategorycode)
	SELECT @v_nextkey, @i_bookkey, @i_verificationtypecode, 2, @v_msg ,@i_username, getdate(), NULL
end 

--Check the first level of Bisac Subject and if it is "JUVENILE NONFICTION"   or  "JUVENILE FICTION"  require age ranges.
IF EXISTS (Select 1 FROM bookbisaccategory bbc where bookkey = @i_bookkey and printingkey = 1 and 
exists (Select 1 from gentables where tableid = 339 and datacode = bbc.bisaccategorycode and eloquencefieldtag in ('JNF', 'JUV')))

BEGIN
	IF ISNULL(@v_allagesind, 0) = 0
		BEGIN
			IF isnull(@v_agelowupind,0) = 0 
				BEGIN
					--IF isnull(@v_agelow,0) = 0 
					IF isnull(@v_agelow,-1) = -1 -- 0 is a valid entry for agelow when agehigh is > 0. e.g. ages 0 to 3 
						BEGIN
							SET @v_failed = 1
							SET @v_msg = 'Missing Grade Level - Age Low. Required for titles with a JUVENILE Bisac Subject Category.' 
							SET @v_messagecategoryqsicode = 34
							EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, 2, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
							IF @o_error_code = -1
							  RETURN
						END  
				END 



			IF ISNULL(@v_agehighupind,0) = 0 
				BEGIN
					IF ISNULL(@v_agehigh,0) = 0 
					BEGIN
						SET @v_failed = 1
						SET @v_msg = 'Missing Grade Level - Age High. Required for titles with a JUVENILE Bisac Subject Category.'
						SET @v_messagecategoryqsicode = 35
						EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, 2, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
						IF @o_error_code = -1 
							RETURN
					END  
				END  
		END
END


--language
if isnull(@languagecode1,0) = 0 and isnull(@languagecode2,0) = 0 begin
  SET @v_failed = 1
	SET @v_msg = 'Missing Language' 
	SET @v_messagecategoryqsicode = 13
	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, 2, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
	  RETURN
end 

If @isSet = 1 and  ISNULL(@associatedformatcode, '') = ''
	BEGIN

		SET @v_failed = 1
		SET @v_msg = 'Missing HBG Format on Primary (First) Component. HBG Format/Sub-Format category is required on the first component of the set' 
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate, messagecategorycode)
		SELECT @v_nextkey, @i_bookkey, @i_verificationtypecode, 2, @v_msg ,@i_username, getdate(), NULL
		IF @o_error_code = -1
			RETURN

	END

If @isSet = 1 and  ISNULL(@setType, '') = ''
	BEGIN

		SET @v_failed = 1
		SET @v_msg = 'Missing Set Type. Set Type is mapped to BOM Type and Hachette requires this field for sets' 
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate, messagecategorycode)
		SELECT @v_nextkey, @i_bookkey, @i_verificationtypecode, 2, @v_msg ,@i_username, getdate(), NULL
		IF @o_error_code = -1
			RETURN

	END

If @internalOnly = 'Y'
	BEGIN

		SET @v_failed = 1
		SET @v_msg = 'Internal Only flag is checked. This title is not eligible to go to Hachette.' 
		exec get_next_key @i_username, @v_nextkey out
		insert into bookverificationmessage (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate, messagecategorycode)
		SELECT @v_nextkey, @i_bookkey, @i_verificationtypecode, 2, @v_msg ,@i_username, getdate(), NULL
		IF @o_error_code = -1
			RETURN

	END

 --exec bookverification_check 'HACHETTE_ISBN13', @i_write_msg output
 --if @i_write_msg = 1 
	--	begin
	--		if @i_verificationtypecode = 6 
	--			begin
	--			IF coalesce(@v_ISBN13,'')=''
	--				BEGIN
	--					set @msg= 'ISBN13 is missing.'
	--					exec get_next_key @i_username, @v_nextkey out
	--					insert into bookverificationmessage
	--					values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
	--					set @v_failed = 1
	--				END
	--			END
	--	end

 --exec bookverification_check 'HACHETTE_Title', @i_write_msg output
 --if @i_write_msg = 1 
	--	begin
	--		if @i_verificationtypecode = 6 
	--			begin
	--			IF coalesce(@v_Title,'')=''
	--				BEGIN
	--					set @msg= 'Title is missing.'
	--					exec get_next_key @i_username, @v_nextkey out
	--					insert into bookverificationmessage
	--					values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
	--					set @v_failed = 1
	--				END
	--			END
	--	end


 --exec bookverification_check 'HACHETTE_Pubdate', @i_write_msg output
 --if @i_write_msg = 1 
	--	begin
	--		if @i_verificationtypecode = 6 
	--			begin
	--			IF coalesce(@v_Pubdate,'')=''
	--				BEGIN
	--					set @msg= 'Pubdate is missing.'
	--					exec get_next_key @i_username, @v_nextkey out
	--					insert into bookverificationmessage
	--					values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
	--					set @v_failed = 1
	--				END
	--			END
	--	end
 --exec bookverification_check 'HACHETTE_BISACStatus', @i_write_msg output
 --if @i_write_msg = 1 
	--	begin
	--		if @i_verificationtypecode = 6 
	--			begin
	--			IF coalesce(@v_BISACStatus,'')=''
	--				BEGIN
	--					set @msg= 'BISAC Status is missing.'
	--					exec get_next_key @i_username, @v_nextkey out
	--					insert into bookverificationmessage
	--					values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
	--					set @v_failed = 1
	--				END
	--			END
	--	end
 --exec bookverification_check 'HACHETTE_UsageClass', @i_write_msg output
 --if @i_write_msg = 1 
	--	begin
	--		if @i_verificationtypecode = 6 
	--			begin
	--			IF coalesce(@v_UsageClass,'')=''
	--				BEGIN
	--					set @msg= 'Usage Class is missing.'
	--					exec get_next_key @i_username, @v_nextkey out
	--					insert into bookverificationmessage
	--					values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
	--					set @v_failed = 1
	--				END
	--			END
	--	end
 --exec bookverification_check 'HACHETTE_BISACSubject', @i_write_msg output
 --if @i_write_msg = 1 
	--	begin
	--		if @i_verificationtypecode = 6 
	--			begin
	--			IF coalesce(@v_BISACSubject,'')=''
	--				BEGIN
	--					set @msg= 'BISAC Subject is missing.'
	--					exec get_next_key @i_username, @v_nextkey out
	--					insert into bookverificationmessage
	--					values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
	--					set @v_failed = 1
	--				END
	--			END
	--	end
 --exec bookverification_check 'HACHETTE_Audience', @i_write_msg output
 --if @i_write_msg = 1 
	--	begin
	--		if @i_verificationtypecode = 6 
	--			begin
	--			IF coalesce(@v_Audience,'')=''
	--				BEGIN
	--					set @msg= 'Audience is missing.'
	--					exec get_next_key @i_username, @v_nextkey out
	--					insert into bookverificationmessage
	--					values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
	--					set @v_failed = 1
	--				END
	--			END
	--	end
 --exec bookverification_check 'HACHETTE_Author', @i_write_msg output
 --if @i_write_msg = 1 
	--	begin
	--		if @i_verificationtypecode = 6 
	--			begin
	--			IF coalesce(@v_Author,'')=''
	--				BEGIN
	--					set @msg= 'Author is missing.'
	--					exec get_next_key @i_username, @v_nextkey out
	--					insert into bookverificationmessage
	--					values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
	--					set @v_failed = 1
	--				END
	--			END
	--	end
 --exec bookverification_check 'HACHETTE_familycode', @i_write_msg output
 --if @i_write_msg = 1 
	--	begin
	--		if @i_verificationtypecode = 6 
	--			begin
	--			IF coalesce(@v_familycode,'')=''
	--				BEGIN
	--					set @msg= 'familycode is missing.'
	--					exec get_next_key @i_username, @v_nextkey out
	--					insert into bookverificationmessage
	--					values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
	--					set @v_failed = 1
	--				END
	--			END
	--	end



--Select TOP 10 * from bookverification 


-- FAILED


		IF @v_failed = 1

		BEGIN
			--FAILED
			SELECT @v_datacode = datacode FROM gentables WHERE tableid = 513 AND qsicode = 2

			-- We will never send failed code to the eloquence verification
			-- Will send passed with warnings code with failed description
			-- This way, if a title doesn't go to Hachette and fails HBG verification for some reason, we will not block it from going to other partners
			-- table valued function will send hachette verification status to the cloud
			-- we will have a condition on the cloud (for partner Hachette)
			-- we will only include titles in the Hachette feed where this flag / verification status is true/not failed. 


			SET @o_error_code = 2
			SET @o_error_desc = 'Title Failed Hachette Verification'


			IF NOT EXISTS (SELECT 1 FROM bookverification WHERE bookkey = @i_bookkey AND verificationtypecode = @i_verificationtypecode)
				BEGIN
					INSERT INTO bookverification (bookkey, verificationtypecode, titleverifystatuscode, lastuserid, lastmaintdate)
					SELECT @i_bookkey,
					@i_verificationtypecode,
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

			RETURN 
		END

		
		

-- PASSED WITH WARNING

		IF @v_failed = 0 AND @v_varnings = 1
		BEGIN
			--passed with warnings
			SELECT @v_datacode = datacode FROM gentables WHERE tableid = 513 AND qsicode = 4
			SET @o_error_code = 2
			SET @o_error_desc = 'Title Passed Hachette Verification with warning(s)'

			IF NOT EXISTS (SELECT 1 FROM bookverification WHERE bookkey = @i_bookkey AND verificationtypecode = @i_verificationtypecode)
				BEGIN
					INSERT INTO bookverification (bookkey, verificationtypecode, titleverifystatuscode, lastuserid, lastmaintdate)
					SELECT @i_bookkey,
					@i_verificationtypecode,
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
			RETURN 
		END



		




-- PASSED 

		

		IF @v_failed = 0 AND @v_varnings = 0
		BEGIN
			--passed 
			SELECT @v_datacode = datacode FROM gentables WHERE tableid = 513 AND qsicode = 3
			SET @o_error_code = 1
			SET @o_error_desc = 'Title Passed Hachette Verification'

			IF NOT EXISTS (SELECT 1 FROM bookverification WHERE bookkey = @i_bookkey AND verificationtypecode = @i_verificationtypecode)
				BEGIN
					INSERT INTO bookverification (bookkey, verificationtypecode, titleverifystatuscode, lastuserid, lastmaintdate)
					SELECT @i_bookkey,
					@i_verificationtypecode,
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
			RETURN 
		END

	--END
	--ELSE
	--	--Set verification status for non-B&H products to Not Applicable
	--BEGIN
	--	DELETE bookverificationmessage
	--	WHERE bookkey = @i_bookkey
	--		AND verificationtypecode = @i_verificationtypecode

	--	IF NOT EXISTS (
	--			SELECT *
	--			FROM bookverification
	--			WHERE bookkey = @i_bookkey
	--				AND verificationtypecode = @i_verificationtypecode
	--			)
	--	BEGIN
	--		INSERT INTO bookverification
	--		SELECT @i_bookkey,
	--			5,
	--			8,
	--			@i_username,
	--			getdate()
	--	END
	--	ELSE
	--	BEGIN
	--		UPDATE bookverification
	--		SET titleverifystatuscode = 8,
	--			lastmaintdate = getdate(),
	--			lastuserid = @i_username
	--		WHERE bookkey = @i_bookkey
	--			AND verificationtypecode = @i_verificationtypecode
	--	END
	--END
END






GO


GRANT EXEC ON dbo.TIB_hachette_verification TO PUBLIC 
