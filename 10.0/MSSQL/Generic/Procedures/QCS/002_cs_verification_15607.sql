/****** Object:  StoredProcedure [dbo].[cs_verification]    Script Date: 05/17/2011 15:28:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cs_verification]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[cs_verification]

/****** Object:  StoredProcedure [dbo].[cs_verification]    Script Date: 05/17/2011 15:27:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[cs_verification]
  @i_bookkey int,
  @i_printingkey int,
  @i_verificationtypecode int,
  @i_username varchar(15),
  @o_error_code INT OUT,
  @o_error_desc VARCHAR(2000) OUT
 
AS 

--changes made by Jen 10/17/11 for case 17089
--4/23/14 Jen case 27820
--12/12/14 Kusum case 30814
--02/08/16 Colman case 34577
--02/09/16 Uday case 36231
--02/11/16 Kusum Case 36144
--02/12/16 Colman case 35900
--02/09/16 Uday case 36231 - Task 002
--02/16/16 Kusum Case 36144 - Task 002
--02/17/16 Kusum Case 36144 - Task 003
--03/02/16 Kusum Case 36806
--03/04/16 Alan Case 36852
--03/09/16 Kusum Case 36904
--04/11/16 Kusum Case 37519
--02/10/17 Uday Case 37519 - Task 001
--05/24/17 Tolga - fix custom verification error
--09/26/17 Colman case 47349


DECLARE 
@v_datacode int,
@v_messagecategoryqsicode int,
@v_verificationsubtypecode int,
@v_msgtype_error int,
@v_msgtype_info  int,
@v_msgtype int,
@v_elo2ind int,
@v_title varchar(255),
@v_cnt int,
@v_isbn varchar(13),
@v_isbn10 varchar(10),
@v_ean13 varchar(13),
@v_ean  varchar(50),
@v_mediatypecode int,
@v_mediatypesubcode int,
@v_bestdate datetime,
@v_languagecode int,
@v_languagecode2 int,
@v_tentativepagecount int, 
@v_pagecount int, 
@v_tmmpagecount int,
@v_eloquencefieldtag varchar(25),
@v_warnings int,
@v_failed int,
@v_isbn13 varchar(13),
@v_bsg_msg varchar(100),
@v_g_msg varchar(100),
@v_bisac_status_code int,
@minpricetype int,
@counter int,
@printisbnrequired int,
@digitalonly	int,
@i_numcount int,
@i_rowcount int,
@c_pricedesc nvarchar(120),
@csapproval	int,
@csapproved int,
@v_error  int,
@v_rowcount int,
@v_msg	VARCHAR(2000),
@mediaelotag	varchar(50),
@formatelotag	varchar(50),
@v_prodavailability	int,
@v_nextkey	int,
@v_territoriescode	int,
@minpricetag	varchar(50),
@mediaonly	int,
@eloqcustomerid	varchar(20),
@commentDdesc	varchar(255),
@commentBDdesc	varchar(255),
@pddesc		varchar(255),
@osddesc		varchar(255),
@statelo	varchar(20),
@count		int,
@v_printpricecnt	int,
@i_pricevalidationgroup	int,
@counter2	int,
@rowcount2	int,
@minpricekey	int,
@currencytag	varchar(50),
@budgetprice	float,
@finalprice		float,
@printbudgetprice	float,
@printfinalprice	float,
@printbudgetprice2	float,
@printfinalprice2	float,
@currencytypecode	int,
@pricetypecode		int,
@v_msgtype_warning	int,
@assocbookkey	int,
@osdate			datetime,
@v_eod_monthswarning	int,
@monthstopub	int,
@eodlevel		int,
@trimsizewidth	varchar(20),
@trimsizelength	varchar(20),
@spinesize		varchar(20),
@esttrimsizewidth varchar(20),
@esttrimsizelength varchar(20), 
@tmmactualtrimwidth varchar(20),
@tmmactualtrimlength varchar(20),
@trimsizeunitofmeasure int,
@spinesizeunitofmeasure int,
@bookweight float,
@bookweightunitofmeasure	int,
@label	varchar(100),
@csformat int,
@v_error_code INT,
@v_error_msg  VARCHAR(2000),
@AOPconflictsource	varchar(50),
@amazonbrandcodeind	int,
@amazonbrandcode	varchar(50),
@mincountrycode INT,
@countrytag VARCHAR(25),
@v_count INT,
@v_count2 INT,
@v_count3 INT,
@v_count4 INT,
@v_count5 INT,
@v_count6 INT,
@SendRightsToCloud  INT,
@countrycode INT,
@countrydesc VARCHAR(255),
@exporteloquenceind INT,
@v_salesrights_commenttext VARCHAR(MAX),
@v_string VARCHAR(MAX),
@v_start INT,
@v_end INT,
@v_counter2 INT,
@v_rowcount2 INT,
@v_eloquencefieldtag_ctry CHAR(2),
@v_len INT,
@v_totalruntime VARCHAR(10),
@deletestatus varchar(25),
@v_numcassettes INT,
@v_params VARCHAR(255),
@TrimActualTrimSize INT,
@v_bicverification INT,
@v_messageEloOrCS varchar(100),
@v_gradelowupind int,
@v_gradehighupind int,
@v_gradelow varchar(4), 
@v_gradehigh varchar(4),
@v_customerprocedurename varchar(255),
@v_verificationtypecode INT,
@v_customproc_messagetypecode INT 


BEGIN 

-- init variables
set @v_msgtype_error = 2
set @v_msgtype_warning = 3
set @v_msgtype_info = 4
set @v_failed = 0 
set @v_warnings = 0 
set @v_eod_monthswarning = 10

set @v_bsg_msg = ''
set @v_g_msg = ''

SET @v_verificationsubtypecode = 2 -- Original Cloud verify behavior by default
SET @v_bicverification = 0 -- Never Verify BIC by default
SELECT @v_elo2ind = COALESCE(optionvalue,0) FROM clientoptions WHERE optionid=111

SELECT @v_params = gentext1
FROM gentables_ext
WHERE tableid = 556 AND datacode=@i_verificationtypecode

IF @v_params IS NOT NULL BEGIN
  -- Parameters are stored as a '|' delimited string. 
  -- 1. verificationsubtypecode
  -- 2. bicverification
  DECLARE @v_id TINYINT,
          @v_param NVARCHAR(128)
          
  CREATE TABLE #param_table 
  ( 
      id TINYINT IDENTITY(1,1),
      arg NVARCHAR(128)
  );
  DECLARE @XML xml = N'<r><![CDATA[' + REPLACE(@v_params, '|', ']]></r><r><![CDATA[') + ']]></r>'
  INSERT INTO #param_table ([arg])
  SELECT RTRIM(LTRIM(T.c.value('.', 'NVARCHAR(128)')))
  FROM @xml.nodes('//r') T(c)

  DECLARE param_cursor CURSOR FOR SELECT id, arg FROM #param_table
  OPEN param_cursor

  FETCH NEXT FROM param_cursor 
  INTO @v_id, @v_param
  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF @v_id = 1
      SET @v_verificationsubtypecode = CONVERT(INT, @v_param)
    ELSE IF @v_id = 2
      SET @v_bicverification = CONVERT(INT, @v_param)
      
    FETCH NEXT FROM param_cursor 
    INTO @v_id, @v_param
  END
  CLOSE param_cursor
  DEALLOCATE param_cursor
  DROP TABLE #param_table
END

-- Is bicverification enabled per customer?
IF @v_bicverification = 2 BEGIN
  SELECT @v_bicverification = COALESCE(bicverificationind,0) 
  FROM customer c
  JOIN book b ON c.customerkey = b.elocustomerkey
  WHERE b.bookkey = @i_bookkey
END

-- Send Rights to Cloud client option  114
  -- 1 - (default) use standard prioritization for rights 
  -- 2 - use new territories with countries
  -- 3 - use Rights Comments
  -- 5 - use legacy territory

SELECT @SendRightsToCloud = optionvalue
  FROM clientoptions
 WHERE optionid = 114

IF @SendRightsToCloud IS NULL
   SET @SendRightsToCloud = 1
   
SELECT @TrimActualTrimSize = optionvalue
  FROM clientoptions
 WHERE optionid = 7
 
IF @TrimActualTrimSize IS NULL
	SET @TrimActualTrimSize = 0 ---default value

select @eloqcustomerid = eloqcustomerid
from customer c
join book b
on c.customerkey = b.elocustomerkey
where b.bookkey = @i_bookkey

IF @v_bicverification = 2 BEGIN
select @eloqcustomerid = eloqcustomerid
from customer c
join book b
on c.customerkey = b.elocustomerkey
where b.bookkey = @i_bookkey
END
--*****RETURN successfully until I finish coding
--return 

--insert into bookverification table if not already there - status=ready for verification
select @i_numcount=count(*) from bookverification where bookkey= @i_bookkey and verificationtypecode = @i_verificationtypecode
if @i_numcount = 0 OR @i_numcount is NULL
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

-- Case 37519 Call "Additional Cloud Verification" from eloquence verification
SELECT @v_count = COUNT(*)
  FROM gentables 
 WHERE tableid = 556 AND qsicode = 5 
   AND (deletestatus = 'N' OR deletestatus = 'n') --Additional Cloud Verification
 
IF @v_count = 1 BEGIN
	SELECT @v_customerprocedurename = COALESCE(alternatedesc1,''), @v_verificationtypecode = COALESCE(datacode,0) 
	  FROM gentables 
	 WHERE tableid = 556 AND qsicode = 5 
	   AND (deletestatus = 'N' OR deletestatus = 'n') --Additional Cloud Verification

	select @i_numcount=count(*) from bookverification where bookkey= @i_bookkey and verificationtypecode = @v_verificationtypecode
	if @i_numcount = 0 OR @i_numcount is NULL
	begin 
	  insert into bookverification select @i_bookkey, @v_verificationtypecode,1,'fbt-initial',getdate()
	
	  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	  IF @v_error <> 0 OR @v_rowcount = 0
	  BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Error inserting into bookverification table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) +
		  + ', verificationtypecode=' + CONVERT(VARCHAR, @v_verificationtypecode) + ').'
		RETURN
	  END	
	end

	delete bookverificationmessage
	where bookkey = @i_bookkey
	and verificationtypecode = @v_verificationtypecode

	SELECT @v_error = @@ERROR
	IF @v_error <> 0
	BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error deleting rows from bookverificationmessage table (verificationtypecode=' + CONVERT(VARCHAR, @v_verificationtypecode) + ').'
	  RETURN
	END
END
ELSE
	SET @v_customerprocedurename = ''
       

IF @v_customerprocedurename <> '' BEGIN
	EXEC @v_customerprocedurename @i_bookkey, @i_printingkey, @v_verificationtypecode, @i_username, @o_error_code output, @o_error_desc output
	IF @o_error_code = -1 BEGIN
		SET @v_failed = 1
	    SET @v_msg = 'Error in Additional Cloud Verification procedure: ' + @v_customerprocedurename + ' - Please contact your Firebrand Representative for assistance.'
	    SELECT @v_customproc_messagetypecode = datacode FROM gentables WHERE tableid = 539 AND qsicode = 2 --Error
	    SELECT @v_messagecategoryqsicode = 32
		SET @o_error_code = 0
		EXEC bookverificationmessage_insert @i_bookkey, @v_verificationtypecode, @v_customproc_messagetypecode, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		IF @o_error_code = -1
			RETURN

	    select @v_datacode = datacode
	    from gentables 
	    where tableid = 513
	    and qsicode = 2
	
	    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	    IF @v_error <> 0 OR @v_rowcount = 0
	    BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Error accessing gentables 513 (qsicode=2).'
		  RETURN
	    END

		update bookverification
		set titleverifystatuscode = @v_datacode, lastmaintdate = getdate(), lastuserid = @i_username
		where bookkey = @i_bookkey	
		and verificationtypecode = @v_verificationtypecode

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0
		BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Error updating bookverification table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ', verificationtypecode=' + CONVERT(VARCHAR, @v_verificationtypecode) + ').'
			RETURN
		END

		EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		IF @o_error_code = -1
			RETURN
	END
	ELSE IF @o_error_code > 0 BEGIN
		SELECT @v_msg = datadesc FROM gentables WHERE tableid = 675 AND qsicode = 32  
		SELECT @v_msg = @v_msg + '. ' + @o_error_desc + ' returned from: ' + @v_customerprocedurename + '.' -- Custom  verification results
		SELECT @v_messagecategoryqsicode = 32
		IF @o_error_code = 1 BEGIN-- Passed
			SELECT @v_customproc_messagetypecode = datacode FROM gentables WHERE tableid = 539 AND qsicode = 4 --Information
		END
		ELSE IF @o_error_code = 2 BEGIN-- Warning
			SELECT @v_customproc_messagetypecode = datacode FROM gentables WHERE tableid = 539 AND qsicode = 3 --Warning
			SET @v_warnings = 1
		END
		ELSE IF @o_error_code = 3 BEGIN-- Error
			SELECT @v_customproc_messagetypecode = datacode FROM gentables WHERE tableid = 539 AND qsicode = 2 --Error
			SET @v_failed = 1
		END

		SET @o_error_code = 0
		EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_customproc_messagetypecode, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		IF @o_error_code = -1
			RETURN
	END
	
	SET @o_error_code = 0
	SET @o_error_desc = ''
	SET @v_msg = ''
	SET @v_count = 0
END  --IF @v_customerprocedurename <> ''

--confirm title will potentially be sent to content services/EOD before running this routine (compare media/format against cspartnerformat)
--load data from bookdetail table
select @v_mediatypecode = mediatypecode, @v_mediatypesubcode = mediatypesubcode,
  @v_languagecode = languagecode, @v_languagecode2 = languagecode2, 
  @v_bisac_status_code = bisacstatuscode, @v_prodavailability = prodavailability, @csapproval = isnull(csapprovalcode,0), @i_pricevalidationgroup = pricevalidationgroupcode,
  @v_gradelowupind = gradelowupind, @v_gradehighupind = gradehighupind, @v_gradelow = gradelow, @v_gradehigh = gradehigh
from bookdetail
where bookkey = @i_bookkey

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 OR @v_rowcount = 0
BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error accessing bookdetail table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ').'
  RETURN
END
  
select @mediaelotag = eloquencefieldtag
from gentables
where tableid = 312
and datacode = @v_mediatypecode

select @formatelotag = eloquencefieldtag
from subgentables
where tableid = 312
and datacode = @v_mediatypecode
and datasubcode = @v_mediatypesubcode

--jen 7/31/12 remove the limitation of only running this against titles that will go to CS, let them run it against any title since it is so thorough
--11/11/12 however, if it is a format to be sent to CS, check that title is approved for content services
--otherwise, let a title pass CS/EOD verification without being approved
select @i_numcount = count(*)
from cspartnerformat
where mediacode = @v_mediatypecode

if isnull(@i_numcount,0) > 0
	set @CSformat = 1
--
--SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
--IF @v_error <> 0 OR @v_rowcount = 0
--BEGIN
--  SET @o_error_code = -1
--  SET @o_error_desc = 'Error accessing cspartnerformat table (mediacode=' + CONVERT(VARCHAR, @v_mediatypecode) + ').'
--  RETURN
--END
--
--if isnull(@i_numcount,0) = 0		--this title is not of a media type being sent to content services, so don't write this verification row
--BEGIN
--  SET @o_error_code = -2  --DistributionAdapter will keep track of these titles
--  RETURN
--END

--Fail titles that have the Target account misc field populated and released to eloquence
select @i_numcount = count(*)
from bookmisc bm
join bookmiscitems bmi
on bm.misckey = bmi.misckey
join gentables g1 --find eloquence field identifier - 
on bmi.eloquencefieldidcode = g1.datacode 
and g1.eloquencefieldtag = 'DPIDXBIZTARGETACC' 
and g1.tableid = 560
AND g1.deletestatus='N'
join gentables g2 --find misc item gentables entry
on bmi.datacode = g2.datacode 
and g2.tableid = 525 
join subgentables sg1 
on bm.longvalue = sg1.datasubcode 
and sg1.tableid = 525 
and sg1.datacode = g2.datacode
and sg1.deletestatus='N'
where bm.sendtoeloquenceind = 1
and bookkey = @i_bookkey

if @i_numcount > 0 begin
	set @v_failed = 1
	SET @v_msg = 'Target Accounts are not allowed through EOD/CS for now' + @v_bsg_msg
  SET @v_messagecategoryqsicode = 7
	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
		RETURN
end 

-- 05/12/15 - KB - Case 32775 Remove PPT check to allow mixed VAT products
--Fail titles that have the PPT (percent of product that is taxable) <> 0, 1, or 100 and released to eloquence
--select @i_numcount = count(*), @label = max(bmi.miscname)
--from bookmisc bm
--join bookmiscitems bmi
--on bm.misckey = bmi.misckey
--join gentables g1 --find eloquence field identifier - 
--on bmi.eloquencefieldidcode = g1.datacode 
--and g1.eloquencefieldtag = 'DPIDXBIZPPT' 
--and g1.tableid = 560
--AND g1.deletestatus='N'
--where bm.sendtoeloquenceind = 1
--and bm.longvalue not in (0, 1, 100)
--and bookkey = @i_bookkey

--if @i_numcount > 0 begin
--	set @v_failed = 1
--	SET @v_msg = @label + ' must be all or nothing (0% or 100%) for now' + @v_bsg_msg
--  SET @v_messagecategoryqsicode = 0
--	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
--	IF @o_error_code = -1
--		RETURN
--end 

--get pub date now, check that it is populated later
select @v_bestdate = bestdate, @pddesc = dt.description
from bookdates bd
right outer join datetype dt
on bd.datetypecode = dt.datetypecode
and printingkey = @i_printingkey
and bookkey = @i_bookkey
and dt.activeind = 1
where eloquencefieldtag = 'PD'

SELECT @v_error = @@ERROR
IF @v_error <> 0
BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error accessing bookdates table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ', printingkey=' + CONVERT(VARCHAR, @i_printingkey) + ').'
  RETURN
END

select @osdate = bestdate, @osddesc = dt.description
from bookdates bd
right outer join datetype dt
on bd.datetypecode = dt.datetypecode
and bookkey = @i_bookkey
and printingkey = @i_printingkey
and dt.activeind = 1
where eloquencefieldtag = 'OSD'

SELECT @v_error = @@ERROR
IF @v_error <> 0
BEGIN
SET @o_error_code = -1
SET @o_error_desc = 'Error accessing bookdates table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ', printingkey=' + CONVERT(VARCHAR, @i_printingkey) + ').'
RETURN
END	

if @v_bestdate is null
	set @v_bestdate = @osdate

if @i_verificationtypecode <> 0 begin
if @v_bestdate is null begin
  set @v_failed = 1
  SET @v_msg = 'Missing or no Key '+ COALESCE(@pddesc, 'NULL') + ' and/or '+ COALESCE(@osddesc, 'NULL') + '. At least one must be populated.'+ @v_bsg_msg
  SET @v_messagecategoryqsicode = 20
  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  IF @o_error_code = -1
    RETURN			
end 
end

if @osdate < @v_bestdate and @osdate is not null
	set @v_bestdate = @osdate

select @monthstopub = datediff(month, getdate(),@v_bestdate)

if @monthstopub < @v_eod_monthswarning and @mediaelotag <> 'EP'
	set @eodlevel = 3	--warning
else if @mediaelotag <> 'EP'
	--set @eodlevel = 2	--info  --03/09/2016 change informational messge to warning 
	set @eodlevel = 3	--warning
else if @mediaelotag = 'EP'
	set @eodlevel = 4	--error

--check for title 
select @v_title = ltrim(rtrim(title))
from book
where bookkey = @i_bookkey

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 OR @v_rowcount = 0
BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error accessing book table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ').'
  RETURN
END

if @v_title is null or  @v_title = '' begin
	set @v_failed = 1
	SET @v_msg = 'Missing Book Title' + @v_bsg_msg
  SET @v_messagecategoryqsicode = 23
	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
	  RETURN
end 

exec qean_verify_productnumber_by_customer @i_bookkey, @v_error_code output, @v_error_msg output
IF @v_error_msg <> '' BEGIN
  SET @v_failed = 1
  SET @v_msg = 'Missing Product Number - ' + @v_error_msg + @v_bsg_msg
  SET @v_messagecategoryqsicode = 19
  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  IF @o_error_code = -1
    RETURN	
END

--check for primary author
select @v_cnt = count(bookkey)
from  bookauthor
where primaryind = 1
and bookkey = @i_bookkey

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 OR @v_rowcount = 0
BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'Error accessing bookauthor table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ').'
RETURN
END

if @v_cnt = 0 begin
	set @v_failed = 1
	SET @v_msg = 'Missing Primary Author'+ @v_bsg_msg
  SET @v_messagecategoryqsicode = 8
	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
	  RETURN		
end 

--check for eloquencefieldtag for that author type
if @v_cnt > 0 begin
	select @v_cnt = count(*)
	from bookauthor
	where bookkey = @i_bookkey
	and primaryind = 1
	and authortypecode in (select datacode from gentables where tableid = 134 and eloquencefieldtag is not null and deletestatus = 'N')

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0
	BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error accessing bookauthor table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ').'
	  RETURN
	END

	if @v_cnt = 0 begin
	  set @v_failed = 1
	  SET @v_msg = 'Missing Eloquence Field tag or export to eloquence indicator for Author or active Author Type '+ @v_bsg_msg
    SET @v_messagecategoryqsicode = 1
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	  IF @o_error_code = -1
		RETURN			
	end 
end

-- check for format of totalruntime value on audiocassettespecs
SELECT @i_numcount = count(*) from audiocassettespecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
IF @i_numcount > 0 BEGIN
  SELECT @v_totalruntime = totalruntime, @v_numcassettes = numcassettes
    FROM audiocassettespecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
  IF ((@v_totalruntime IS NOT NULL AND @v_totalruntime <> '') OR (@v_numcassettes > 0)) BEGIN
    IF @v_totalruntime IS NULL OR @v_totalruntime = '' BEGIN
      set @v_failed = 1
      SET @v_msg = 'Missing total run time for Audio title' + @v_bsg_msg
      SET @v_messagecategoryqsicode = 5
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  IF @o_error_code = -1
		   RETURN
    END
    ELSE BEGIN
      IF patindex('[0-9][0-9][0-9]:[0-9][0-9]:[0-9][0-9]', @v_totalruntime) = 0 BEGIN
        set @v_failed = 1
        SET @v_msg = 'Required format for total run time for Audio titles - hhh:mm:ss' + @v_bsg_msg
        SET @v_messagecategoryqsicode = 5
		    EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		    IF @o_error_code = -1
			    RETURN 
      END
    END
  END
END


--price
set @i_rowcount =0
set @mediaonly = 0

--if pricevalidationgroup not defined on title, pull default from clientdefaults
if isnull(@i_pricevalidationgroup,0) = 0
begin
    EXEC qtitle_set_price_validation_group @i_bookkey,@o_error_code OUTPUT,@o_error_desc OUTPUT

	select @i_pricevalidationgroup = pricevalidationgroupcode
	from bookdetail
	where bookkey = @i_bookkey
end

select @i_rowcount = count(*) , @minpricetag = min(priceelotag)
from CS_formatverification cs  
where cs.mediaelotag =  @mediaelotag
and cs.formatelotag = @formatelotag
and eloqcustomerid = @eloqcustomerid

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 
BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error accessing CS_formatverification table (mediaelotag' + @mediaelotag + ', formatelotag=' + @formatelotag + ').'
  RETURN
END

if @i_rowcount = 0	--if cs_formatverification isn't defined for full media & format, check for just media
begin
	select @i_rowcount = count(*) , @minpricetag = min(priceelotag)
	from CS_formatverification cs  
	where cs.mediaelotag =  @mediaelotag
	and cs.formatelotag is null
	and eloqcustomerid = @eloqcustomerid

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 
	BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error accessing CS_formatverification table (mediaelotag' + @mediaelotag + ', formatelotag=' + @formatelotag + ').'
	  RETURN
	END

	set @mediaonly = 1

	if @i_rowcount = 0
	begin
		set @v_failed = 1
		SET @v_msg = 'Incomplete cs_formatverification Setup - email ContentServicesGroup@FirebrandTech.com to have this populated for media '+ COALESCE(@mediaelotag, 'NULL') + @v_bsg_msg
    SET @v_messagecategoryqsicode = 28
		EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		IF @o_error_code = -1
			RETURN  
	end
end

if @mediaonly = 1
begin
	select @printisbnrequired = max(printisbnrequiredind)
	from CS_formatverification cs  
	where cs.mediaelotag =  @mediaelotag
	and cs.formatelotag is null
	and eloqcustomerid = @eloqcustomerid

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
end
else
begin
	select @printisbnrequired = max(printisbnrequiredind)
	from CS_formatverification cs  
	where cs.mediaelotag =  @mediaelotag
	and cs.formatelotag = @formatelotag
	and eloqcustomerid = @eloqcustomerid

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
end

--this client option controls whether we should pull any print prices from the print isbn for ebooks (1/'print') or pull them only from the AOP price type on the ebook (2/'ebook')
select @AOPconflictsource = case when optionvalue = 2 then 'ebook' else 'print' end
from clientoptions
where optionid = 113

if @AOPconflictsource is null
	set @AOPconflictsource = 'print'

select @digitalonly = count(*)
from bookmisc bm
join bookmiscitems bmi
on bm.misckey = bmi.misckey
join gentables g
on bmi.eloquencefieldidcode = g.datacode
and g.tableid = 560
and g.eloquencefieldtag = 'DPIDXBIZRLSTYPE'
and g.deletestatus = 'N'
join subgentables sg
on sg.tableid = 525
and bmi.datacode = sg.datacode
and bm.longvalue = sg.datasubcode
and sg.datadesc = 'digital-only'
and sg.deletestatus = 'N'
where bm.bookkey = @i_bookkey

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 
BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error accessing bookmisc table (bookkey' + CONVERT(VARCHAR, @i_bookkey) + ').'
  RETURN
END

set @digitalonly = isnull(@digitalonly,0)

IF @v_error <> 0 OR @v_rowcount = 0
BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error accessing CS_formatverification table (mediatypecode' + @mediaelotag + ', mediatypesubcode=' + @formatelotag + ').'
  RETURN
END

set @counter = 1
while @counter <= @i_rowcount
BEGIN -- 1
  set @v_cnt = 0

  select @v_cnt = count(*)
  from bookprice bp
  join gentables g
  on bp.pricetypecode = g.datacode
  and g.tableid = 306
  and eloquencefieldtag is not null and eloquencefieldtag <> '' 
  and eloquencefieldtag not in ('NA','N/A')  
  and exporteloquenceind=1  
  and deletestatus='n'
  where bookkey = @i_bookkey 
  and g.eloquencefieldtag = @minpricetag 
  and bp.activeind = 1
  and isnull(bp.finalprice, bp.budgetprice) is not null 

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 
  BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'Error accessing bookprice table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ').'
	RETURN
  END

--if we need an AOP and it isn't entered on the ebook and title is NOT digital only, then look at the print title for the MSR
  if @minpricetag = 'AOP' and isnull(@v_cnt,0) = 0 and @digitalonly = 0 and @AOPconflictsource = 'print'
  begin
	SELECT  @v_printpricecnt = count(*)
	FROM associatedtitles a
		join subgentables s
		on a.associationtypecode = s.datacode
		and a.associationtypesubcode = s.datasubcode
		and s.tableid = 440
		and s.eloquencefieldtag = 13
    and s.deletestatus = 'N'
		join bookprice bp
		on a.associatetitlebookkey = bp.bookkey
		and bp.activeind = 1
		and a.releasetoeloquenceind = 1
		join gentables bpp
		on bp.pricetypecode = bpp.datacode
		and bpp.tableid = 306
		and bpp.eloquencefieldtag = 'MSR'
    and bpp.deletestatus = 'N'
		join gentables bpc
		on bp.currencytypecode = bpc.datacode
		and bpc.tableid = 122
    and bpc.deletestatus = 'N'
	WHERE a.bookkey=@i_bookkey
		and isnull(bp.finalprice, bp.budgetprice) is not null

	if @v_printpricecnt > 0
		set @v_cnt = @v_printpricecnt
  end

  if @minpricetag = 'AOP' and @digitalonly > 0	--if we need an AOP, but title is digital only, we don't actually need AOP so satisfy check
	set @v_cnt = 1

--if no price found for this type, go into this if statement to write the error message
  if isnull(@v_cnt,0) = 0  
  begin

	  select @count = count(*)
	  from gentables
	  where tableid = 306
	  and eloquencefieldtag = @minpricetag

	  SELECT @v_error = @@ERROR
	  IF @v_error <> 0
	  BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Error accessing gentables 306 (price tag =' + @minpricetag + ').'
		RETURN
	  END

	  if @count = 1
	  begin
		  select @c_pricedesc = datadesc
		  from gentables
		  where tableid = 306
		  and eloquencefieldtag = @minpricetag
	  end
	  else 
	  begin
		select @c_pricedesc = case when @minpricetag = 'msr' then 'Retail price (tag = msr)'
									when @minpricetag = 'agy' then 'Agency price (tag = agy)'
									when @minpricetag = 'lib' then 'Library price (tag = lib)'
									else 'Price with eloquencefieldtag = ' + @minpricetag end
	  end

	if isnull(@v_cnt,0) = 0  
	BEGIN
	  set @v_failed = 1
	  SET @v_msg = 'Missing Price or Inactive Price Type or Currency Type: '+ isnull(@c_pricedesc,'') + @v_bsg_msg
    SET @v_messagecategoryqsicode = 17
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	  IF @o_error_code = -1
		RETURN			
	END
  end	--end error if no price entered for required price type
  
  if @v_cnt > 0
  begin	--price exists, confirm values are valid
	  set @counter2 = 1
	  set @rowcount2 = 0
	  set @minpricekey = 0

	  select @rowcount2 = count(*), @minpricekey = min(pricekey)
	  from bookprice bp
	  join gentables g
	  on bp.pricetypecode = g.datacode
	  and g.tableid = 306
	  and exporteloquenceind=1  
	  and deletestatus='n'
	  where bookkey = @i_bookkey 
	  and g.eloquencefieldtag = @minpricetag 
	  and bp.activeind = 1
	  and isnull(bp.finalprice, bp.budgetprice) is not null

	  while @counter2 <= @rowcount2
	  begin
		  select @currencytag = gc.eloquencefieldtag, @currencytypecode = currencytypecode, @pricetypecode = pricetypecode, @budgetprice = budgetprice, @finalprice = finalprice
		  from bookprice bp
		  join gentables gc
		  on bp.currencytypecode = gc.datacode
		  and gc.tableid = 122
		  and gc.exporteloquenceind = 1
      and gc.deletestatus = 'N'
		  and isnull(gc.eloquencefieldtag,'') not in ('NA','N/A','')
		  where bookkey = @i_bookkey 
		  and bp.pricekey = @minpricekey
		  and bp.activeind = 1
		  and isnull(bp.finalprice, bp.budgetprice) is not null

		  --basically checks for Apple
		  if (@minpricetag = 'AGY' or @minpricetag = 'AGI') and @digitalonly = 0 and @printisbnrequired = 1    --@minpricetag = 'AOP' or 
		  begin
			  set @printbudgetprice = 0
			  set @printfinalprice = 0

			  if @AOPconflictsource = 'print'
			  begin
				  select @printbudgetprice = budgetprice, @printfinalprice = finalprice
				  FROM associatedtitles a
				  join subgentables s
				  on a.associationtypecode = s.datacode
				  and a.associationtypesubcode = s.datasubcode
				  and s.tableid = 440
				  and s.eloquencefieldtag = 13
          and s.deletestatus = 'N'
				  join bookprice bp
				  on a.associatetitlebookkey = bp.bookkey
				  and bp.activeind = 1
				  join gentables bpp
				  on bp.pricetypecode = bpp.datacode
				  and bpp.tableid = 306
				  and bpp.eloquencefieldtag = 'MSR'
          and bpp.deletestatus = 'N'
				  join gentables bpc
				  on bp.currencytypecode = bpc.datacode
				  and bpc.tableid = 122
          and bpc.deletestatus = 'N'
				  WHERE a.bookkey=@i_bookkey
				  and bp.currencytypecode = @currencytypecode
				  and isnull(bp.finalprice, bp.budgetprice) is not null

				  SELECT @v_rowcount = @@ROWCOUNT
			  end
			  else
			  begin
				  set @v_rowcount = 0
			  end

			  if (@v_rowcount = 0 or @v_rowcount is null) and (@minpricetag = 'AGY' or @minpricetag = 'AGI')		--if AGY/AGI and no msr on related print title, look for AOP on ebook for that currency
			  begin
				  set @printbudgetprice2 = 0
				  set @printfinalprice2 = 0

				  select @printbudgetprice2 = budgetprice, @printfinalprice2 = finalprice
				  from bookprice bp
				  join gentables gp
				  on bp.pricetypecode = gp.datacode
				  and gp.tableid = 306
				  and gp.eloquencefieldtag = 'AOP'
          and gp.deletestatus = 'N'
				  where bp.bookkey = @i_bookkey
				  and bp.currencytypecode = @currencytypecode
				  and bp.activeind = 1
				  and isnull(bp.finalprice, bp.budgetprice) is not null

				  SELECT @v_rowcount = @@ROWCOUNT

				  if isnull(@v_rowcount,0) = 0
				  begin
					  set @v_warnings = 1
					  SET @v_msg = 'Apple Failure: Missing corresponding Print retail price or Inactive Currency Type for currency ' + COALESCE(@currencytag, 'NULL') + @v_bsg_msg
            SET @v_messagecategoryqsicode = 11
					  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
					  IF @o_error_code = -1
						  RETURN			
				  end
			  end

			  if @AOPconflictsource = 'print'
			  begin
				  if isnull(@printfinalprice,isnull(@printbudgetprice,0)) <> 0 and isnull(@printfinalprice2,isnull(@printbudgetprice2,0)) <> 0 
						  and isnull(@printfinalprice,isnull(@printbudgetprice,0)) <> isnull(@printfinalprice2,isnull(@printbudgetprice2,0))
				  begin
				    set @v_warnings = 1
				    SET @v_msg = 'Print price and ebook''s AOP price are different for currency '+ COALESCE(@currencytag, 'NULL') +'. Print price will be used.' + @v_bsg_msg
            SET @v_messagecategoryqsicode = 17
				    EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
				    IF @o_error_code = -1
					  RETURN			
				  end
			  end
		  end

		  select @minpricekey = min(pricekey)
		  from bookprice bp
		  join gentables g
		  on bp.pricetypecode = g.datacode
		  and g.tableid = 306
		  and exporteloquenceind=1  
		  and deletestatus='n'
		  where bookkey = @i_bookkey 
		  and g.eloquencefieldtag = @minpricetag 
		  and bp.activeind = 1
		  and isnull(bp.finalprice, bp.budgetprice) is not null
		  and pricekey > @minpricekey
	
		  select @counter2 = @counter2 + 1
	  end

    IF @v_cnt > 1
    BEGIN
      -- Check for duplicate pricetype/currencytype
      IF EXISTS (
        SELECT bookkey, pricetypecode, currencytypecode
        FROM bookprice
        WHERE bookkey = @i_bookkey AND activeind = 1
        GROUP BY bookkey, pricetypecode, currencytypecode 
        HAVING (COUNT(*) > 1)
      )
      BEGIN
		    SET @v_failed = 1
		    SET @v_msg = 'Multiple active prices with the same Price Type and Currency Type.'
        SET @v_messagecategoryqsicode = 17
		    EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
      	IF @o_error_code = -1
		      RETURN		
      END
    END
  end	--end price exists, confirm values are valid

  if @mediaonly = 1
  begin
	  select @minpricetag = min(priceelotag)
	  from CS_formatverification cs  
	  where cs.mediaelotag =  @mediaelotag
	  and cs.formatelotag is null
	  and cs.priceelotag > @minpricetag
	  and eloqcustomerid = @eloqcustomerid
  end
  else
  begin
	  select @minpricetag = min(priceelotag)
	  from CS_formatverification cs  
	  where cs.mediaelotag =  @mediaelotag
	  and cs.formatelotag = @formatelotag
	  and cs.priceelotag > @minpricetag
	  and eloqcustomerid = @eloqcustomerid
  end	

  set @counter = @counter + 1
END 

set @counter2 = 1
set @rowcount2 = 0
set @minpricekey = 0

select @rowcount2 = count(*), @minpricekey = min(pricekey)
from bookprice bp
join gentables g
on bp.pricetypecode = g.datacode
and g.tableid = 306
and exporteloquenceind=1 
and deletestatus='n'
join gentables gc
on bp.currencytypecode = gc.datacode
and gc.tableid = 122
and gc.exporteloquenceind = 1
and isnull(gc.eloquencefieldtag,'') not in ('NA','N/A','')
and gc.deletestatus = 'N'
where bookkey = @i_bookkey 
and bp.activeind = 1
and (isnull(bp.finalprice, 0) = 0 and isnull(bp.budgetprice, 0) = 0)

while @counter2 <= @rowcount2
begin
	select @currencytypecode = currencytypecode, @pricetypecode = pricetypecode
	from bookprice bp
	where bookkey = @i_bookkey 
	and bp.pricekey = @minpricekey
	and bp.activeind = 1

	exec qtitle_price_validation 0, 0, @i_pricevalidationgroup, @pricetypecode, @currencytypecode, @o_error_code output, @o_error_desc output

	if @o_error_code < 0
	begin
		set @o_error_code = 0
		set @v_failed = 1
		SET @v_msg = @o_error_desc + @v_bsg_msg
    SET @v_messagecategoryqsicode = 17
			EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		IF @o_error_code = -1
		RETURN 
	end

	select @minpricekey = min(pricekey)
	from bookprice bp
	join gentables g
	on bp.pricetypecode = g.datacode
	and g.tableid = 306
	and exporteloquenceind=1 
	and deletestatus='n'
	join gentables gc
	on bp.currencytypecode = gc.datacode
	and gc.tableid = 122
	and gc.exporteloquenceind = 1
  and gc.deletestatus = 'N'
	and isnull(gc.eloquencefieldtag,'') not in ('NA','N/A','')
	where bookkey = @i_bookkey 
	and bp.activeind = 1
	and (isnull(bp.finalprice, 0) = 0 and isnull(bp.budgetprice, 0) = 0)
	and pricekey > @minpricekey

	select @counter2 = @counter2 + 1
end
	
--error - check for pub date 

select @statelo = eloquencefieldtag
from gentables
where tableid = 314
and datacode = @v_bisac_status_code
and eloquencefieldtag is not null
and exporteloquenceind = 1
and deletestatus = 'N'

--status
if @v_bisac_status_code is null or @statelo is null begin
	SET @v_msg = 'Missing BISAC Status Code or Inactive BISAC Status Code'+ @v_bsg_msg
	set @v_failed = 1
  SET @v_messagecategoryqsicode = 9
	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
		RETURN		
end 

--product availability
if @v_prodavailability is null  begin
  SET @v_msg = 'Missing Product Availability code or Inactive Product Availability code'+ @v_bsg_msg
  SET @v_messagecategoryqsicode = 18
  if @eodlevel = 3
  begin	
	  set @v_warnings = 1
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  end
  else if @eodlevel = 4
  begin	
	  set @v_failed = 1
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  end
  else if @eodlevel = 2
  begin	
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_info, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  end
	IF @o_error_code = -1
	  RETURN		
end 

if @v_bestdate <getdate() and @statelo = 'NYP' begin
  SET @v_msg = 'PUB/On Sale Date passed, status still Forthcoming (NYP)'+ @v_bsg_msg
  SET @v_messagecategoryqsicode = 27
  if @eodlevel = 3
  begin	
	  set @v_warnings = 1
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  end
  else if @eodlevel = 4
  begin	
	  set @v_failed = 1
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  end
  else if @eodlevel = 2
  begin	
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_info, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  end
  IF @o_error_code = -1
    RETURN	
end 

--4/23/14 Jen
if @v_bestdate >getdate()+10 and @statelo = 'ACT' begin
  SET @v_msg = 'PUB/On Sale Date in future, status is Active'+ @v_bsg_msg
  SET @v_messagecategoryqsicode = 27
  if @eodlevel = 3 or @eodlevel = 4
  begin	
	  set @v_warnings = 1
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  end
--  else if @eodlevel = 4
--  begin	
--	  set @v_failed = 1
--    SET @v_messagecategoryqsicode = 0
--	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
--  end
  else if @eodlevel = 2
  begin	
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_info, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  end
  IF @o_error_code = -1
    RETURN	
end 

--amazon brand code	option values 0 - don't use, 1 - use & require for print & ebook, 2 - use & require for non-ebook only
select @amazonbrandcodeind = optionvalue
from clientoptions
where optionid = 112

if isnull(@amazonbrandcodeind,0) = 1
begin
    select 
        @amazonbrandcode = o.amazonbrandcode
    from 
        filterorglevel fl join 
        orgentry o	on fl.filterorglevelkey = o.orglevelkey	join 
        bookorgentry bo	on o.orgentrykey = bo.orgentrykey
    where 
        bo.bookkey = @i_bookkey	and 
        fl.filterkey = 35	and 
        amazonbrandcode is not null and amazonbrandcode <> ''

	if isnull(@amazonbrandcode,'') = ''
	begin
		SET @v_msg = 'Missing Amazon Brand Code'+ @v_bsg_msg
		set @v_failed = 1
    SET @v_messagecategoryqsicode = 7
		EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		IF @o_error_code = -1
			RETURN	
	end	
end
else if isnull(@amazonbrandcodeind,0) = 2 and @mediaelotag <> 'EP'
begin
    select 
        @amazonbrandcode = o.amazonbrandcode
    from 
        filterorglevel fl join 
        orgentry o	on fl.filterorglevelkey = o.orglevelkey	join 
        bookorgentry bo	on o.orgentrykey = bo.orgentrykey
    where 
        bo.bookkey = @i_bookkey	and 
        fl.filterkey = 35	and 
        amazonbrandcode is not null and amazonbrandcode <> ''

	if isnull(@amazonbrandcode,'') = ''
	begin
		SET @v_msg = 'Missing Amazon Brand Code'+ @v_bsg_msg
		set @v_failed = 1
    SET @v_messagecategoryqsicode = 7
		EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		IF @o_error_code = -1
			RETURN	
	end	
end

--related product
if isnull(@printisbnrequired,0) = 1
begin
    if isnull(@digitalonly,0) = 0
	begin

--do you even have supply chain row?
      select @v_cnt = count(bookkey), @assocbookkey = min(associatetitlebookkey)
      from associatedtitles at
      join subgentables sg
      on sg.tableid = 440
      and at.associationtypecode = sg.datacode
      and at.associationtypesubcode = sg.datasubcode
      and sg.eloquencefieldtag in (13, 15)
      and sg.deletestatus = 'N'
      where bookkey = @i_bookkey 

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 OR @v_rowcount = 0
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Error accessing associatedtitles table (bookkey' + CONVERT(VARCHAR, @i_bookkey) + ').'
        RETURN
      END
    
      if @i_verificationtypecode <>0  
	  begin
        if isnull(@v_cnt,0) = 0 
		begin
      SET @v_msg = 'Missing or Inactive Supply Chain data for Print ISBN (Epublication based on (print product))'+ @v_bsg_msg
      SET @v_messagecategoryqsicode = 21
		  if @eodlevel = 3
		  begin	
			  set @v_warnings = 1
			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end
		  else if @eodlevel = 4
		  begin	
			  set @v_failed = 1
			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end
		  else if @eodlevel = 2
		  begin	
			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_info, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end
          IF @o_error_code = -1
            RETURN					
        end
        if isnull(@v_cnt,0) > 1 
		begin
      SET @v_msg = 'Incorrect Supply Chain data for Print ISBN - Only one print title allowed'+ @v_bsg_msg
      SET @v_messagecategoryqsicode = 6
		  if @eodlevel = 3
		  begin	
			  set @v_warnings = 1
			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end
		  else if @eodlevel = 4
		  begin	
			  set @v_failed = 1
			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end
		  else if @eodlevel = 2
		  begin	
			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_info, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end
          IF @o_error_code = -1
            RETURN					
        end
     end

--Is the supply chain row marked as export to eloquence?
      select @v_cnt = count(bookkey), @assocbookkey = min(associatetitlebookkey)
      from associatedtitles at
      join subgentables sg
      on sg.tableid = 440
      and at.associationtypecode = sg.datacode
      and at.associationtypesubcode = sg.datasubcode
      and sg.eloquencefieldtag in (13, 15)
      and sg.deletestatus = 'N'
      where bookkey = @i_bookkey 
	  and releasetoeloquenceind = 1

      if @i_verificationtypecode <>0  
	  begin
        if isnull(@v_cnt,0) = 0 
		begin
      SET @v_msg = 'Incorrect or Inactive Supply Chain data for Print ISBN - not Released to eloquence'+ @v_bsg_msg
      SET @v_messagecategoryqsicode = 6
		  if @eodlevel = 3
		  begin	
			  set @v_warnings = 1
			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end
		  else if @eodlevel = 4
		  begin	
			  set @v_failed = 1
			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end
		  else if @eodlevel = 2
		  begin	
			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_info, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end
          IF @o_error_code = -1
            RETURN					
        end
	  end

--is your title pointing to itself?
      select @v_cnt = count(bookkey)
      from associatedtitles at
      join subgentables sg
      on sg.tableid = 440
      and at.associationtypecode = sg.datacode
      and at.associationtypesubcode = sg.datasubcode
      and sg.eloquencefieldtag in (13, 15)
      and sg.deletestatus = 'N'
      where bookkey = @i_bookkey 
	  and isnull(at.associatetitlebookkey,0) = at.bookkey

      if @i_verificationtypecode <>0  and isnull(@v_cnt,0) > 0
	  begin
      SET @v_msg = 'Incorrect Supply Chain data for Print ISBN - ebook pointing to itself'+ @v_bsg_msg
      SET @v_messagecategoryqsicode = 6
		  if @eodlevel = 3
		  begin	
			  set @v_warnings = 1
			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end
		  else if @eodlevel = 4
		  begin	
			  set @v_failed = 1
			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end
		  else if @eodlevel = 2
		  begin	
			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_info, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end
          IF @o_error_code = -1
            RETURN					
      end

	  if isnull(@assocbookkey,0) > 0
	  begin
	--does your linked title have an ean?
		  select @v_cnt = count(at.bookkey)
		  from associatedtitles at
		  join subgentables sg
		  on sg.tableid = 440
		  and at.associationtypecode = sg.datacode
		  and at.associationtypesubcode = sg.datasubcode
		  and sg.eloquencefieldtag in (13, 15)
      and sg.deletestatus = 'N'
		  join isbn i
		  on at.associatetitlebookkey = i.bookkey
		  where at.bookkey = @i_bookkey 
		  and isnull(i.ean13,'') <> ''

		  if @i_verificationtypecode <>0  and isnull(@v_cnt,0) = 0
		  begin
			  SET @v_msg = 'Incorrect Supply Chain data - Assoc Print Title missing EAN13'+ @v_bsg_msg
        SET @v_messagecategoryqsicode = 6
			  if @eodlevel = 3
			  begin	
				  set @v_warnings = 1
  			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
			  end
			  else if @eodlevel = 4
			  begin	
				  set @v_failed = 1
  			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
			  end
			  else if @eodlevel = 2
			  begin	
  			  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_info, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
			  end
			  IF @o_error_code = -1
				RETURN					
		  end
		end
		else
		begin
	--related item doesn't have a valid 97x ean
		  select @v_cnt = count(bookkey)
		  from associatedtitles at
		  join subgentables sg
		  on sg.tableid = 440
		  and at.associationtypecode = sg.datacode
		  and at.associationtypesubcode = sg.datasubcode
		  and sg.eloquencefieldtag in (13, 15)
      and sg.deletestatus = 'N'
		  where bookkey = @i_bookkey 
		  and associatetitlebookkey = 0
		  and len(at.isbn) in (13,17)
		  and at.isbn is not null

		  if @i_verificationtypecode <>0  and isnull(@v_cnt,0) = 0
		  begin
			  SET @v_msg = 'Incorrect Supply Chain data - Print EAN13 missing or invalid'+ @v_bsg_msg
	      SET @v_messagecategoryqsicode = 6
		  if @eodlevel = 3
			  begin	
				  set @v_warnings = 1
				  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
			  end
			  else if @eodlevel = 4
			  begin	
				  set @v_failed = 1
				  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
			  end
			  else if @eodlevel = 2
			  begin	
				  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_info, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
			  end
			  IF @o_error_code = -1
				RETURN					
		  end
		end
	end    
end

--Long or Brief Description
select @v_cnt = count(bookkey)
from bookcomments bc
join subgentables sg
on bc.commenttypecode = sg.datacode
and bc.commenttypesubcode = sg.datasubcode
and sg.tableid = 284
and eloquencefieldtag in ('D' ,'BD')
and deletestatus='N' 
and exporteloquenceind=1
where bookkey = @i_bookkey 
and commenthtml is not null
and releasetoeloquenceind=1 

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 OR @v_rowcount = 0
BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error accessing bookcomments table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ').'
  RETURN
END

select @commentDdesc = min(isnull(datadesc,'Description'))
from subgentables
where tableid = 284
and eloquencefieldtag = 'D'

select @commentBDdesc = min(isnull(datadesc,'Brief Description'))
from subgentables
where tableid = 284
and eloquencefieldtag = 'BD'

if @i_verificationtypecode <>0 begin
	if isnull(@v_cnt,0) = 0 begin
	  SET @v_msg = COALESCE(@commentDdesc, 'NULL') + ' and/or ' + COALESCE(@commentBDdesc, 'NULL') + ' is missing or Release to Eloquence not checked'+ @v_bsg_msg
    SET @v_messagecategoryqsicode = 15
	  if @eodlevel = 3
	  begin	
		  set @v_warnings = 1
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	  end
	  else if @eodlevel = 4
	  begin	
		  set @v_failed = 1
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	  end
	  else if @eodlevel = 2
	  begin	
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_info, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	  end
	  IF @o_error_code = -1
		RETURN			
	end
end

IF @v_bicverification = 1 BEGIN
  DECLARE @v_deletestatusind INT
  DECLARE @v_eloquencefieldtagind INT
  DECLARE @v_completeind INT
  
  SELECT
  @v_deletestatusind =
  CASE WHEN g.datacode IS NOT NULL AND LOWER(COALESCE(g.deletestatus,'')) <> 'n' THEN 0
  WHEN s.datasubcode IS NOT NULL AND LOWER(COALESCE(s.deletestatus,'')) <> 'n' THEN 0 
  WHEN t.datasub2code IS NOT NULL AND LOWER(COALESCE(t.deletestatus,'')) <> 'n' THEN 0 
  ELSE 1 END,
  @v_eloquencefieldtagind =
  CASE WHEN g.datacode IS NOT NULL AND g.eloquencefieldtag IS NULL THEN 0
  WHEN s.datasubcode IS NOT NULL AND s.eloquencefieldtag IS NULL THEN 0 
  WHEN t.datasub2code IS NOT NULL AND t.eloquencefieldtag IS NULL THEN 0 
  ELSE 1 END,
  @v_completeind =
  CASE WHEN g.datacode IS NULL THEN 0 
  WHEN s.datasubcode IS NULL AND EXISTS (SELECT * FROM subgentables WHERE tableid=668 AND datacode=g.datacode) THEN 0 
  WHEN t.datasub2code IS NULL AND EXISTS (SELECT * FROM sub2gentables WHERE tableid=668 AND datacode=g.datacode AND datasubcode=s.datasubcode) THEN 0 
  ELSE 1 END
  FROM booksubjectcategory b 
  LEFT OUTER JOIN gentables g on g.tableid = b.categorytableid AND g.datacode=b.categorycode
  LEFT OUTER JOIN subgentables s on s.tableid=b.categorytableid AND s.datacode=b.categorycode AND s.datasubcode=b.categorysubcode
  LEFT OUTER JOIN sub2gentables t on b.categorytableid=t.tableid AND t.datacode=b.categorycode AND t.datasubcode=b.categorysubcode AND t.datasub2code=b.categorysub2code
  WHERE bookkey=@i_bookkey AND b.categorytableid=668
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0
  BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error accessing booksubjectcategory table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ').'
      RETURN
  END
  SET @v_messagecategoryqsicode = 10
  IF @v_rowcount = 0 BEGIN
	  set @v_failed = 1  
      SET @v_msg = 'There must be at least one BIC Subject category.'+ @v_bsg_msg
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  END ELSE BEGIN
      IF @v_completeind = 0
        SET @v_msg = 'The BIC Subject is incomplete. All available levels must be specified.' + @v_bsg_msg
      ELSE IF @v_deletestatusind = 0
        SET @v_msg = 'The BIC Subject contains one or more levels marked as inactive.' + @v_bsg_msg
      ELSE IF @v_eloquencefieldtagind = 0
        SET @v_msg = 'The BIC Subject contains one or more levels missing an Eloquence field tag.' + @v_bsg_msg
     
      IF @v_msg IS NOT NULL AND @v_msg <> '' BEGIN 
		  set @v_failed = 1  
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  IF @o_error_code = -1
			RETURN			
	  END  
  END
END

--check for Bisac Subject 1
select @v_cnt = count(bookkey)
from bookbisaccategory bc, subgentables s
where bc.bookkey = @i_bookkey
and bc.printingkey = @i_printingkey
and bc.printingkey=1
and s.tableid=339 
and s.deletestatus='N'
and bc.bisaccategorycode=s.datacode 
and bc.bisaccategorysubcode=s.datasubcode
and s.exporteloquenceind = 1

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 OR @v_rowcount = 0
BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error accessing bookbisaccategory table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ', printingkey=' + CONVERT(VARCHAR, @i_printingkey) + ').'
  RETURN
END

if @i_verificationtypecode <>0 begin
	if @v_cnt = 0 begin
	  SET @v_msg = 'Missing BISAC Subject 1'+ @v_bsg_msg
    SET @v_messagecategoryqsicode = 10
	  if @eodlevel = 3
	  begin	
		  set @v_warnings = 1
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	  end
	  else if @eodlevel = 4
	  begin	
		  set @v_failed = 1
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	  end
	  else if @eodlevel = 2
	  begin	
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_info, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	  end
	  IF @o_error_code = -1
		RETURN			
	end 
end

--check for tentativepagecount , pagecount, tmmpagecount 
select @v_tentativepagecount = tentativepagecount, @v_pagecount = pagecount, @v_tmmpagecount = tmmpagecount, @trimsizewidth = trimsizewidth, @trimsizelength = trimsizelength,
@esttrimsizewidth = esttrimsizewidth, @esttrimsizelength = esttrimsizelength, @tmmactualtrimwidth = tmmactualtrimwidth, @tmmactualtrimlength = tmmactualtrimlength, @trimsizeunitofmeasure = trimsizeunitofmeasure,
@spinesize = spinesize, @spinesizeunitofmeasure = spinesizeunitofmeasure, @bookweight = bookweight, @bookweightunitofmeasure = bookweightunitofmeasure 
from printing
where bookkey = @i_bookkey
and printingkey = @i_printingkey

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 OR @v_rowcount = 0
BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error accessing printing table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ', printingkey=' + CONVERT(VARCHAR, @i_printingkey) + ').'
  RETURN
END

--error if is book/ebook
if @mediaelotag in ('B', 'EP') begin
	if @v_tentativepagecount is null and  @v_pagecount is null and @v_tmmpagecount is null begin
	  SET @v_msg = 'Missing Page Count'+ @v_g_msg
    SET @v_messagecategoryqsicode = 16
	  if @eodlevel = 3
	  begin	
		  set @v_warnings = 1
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	  end
	  else if @eodlevel = 4
	  begin	
		  set @v_failed = 1
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	  end
	  else if @eodlevel = 2
	  begin	
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_info, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	  end
	  IF @o_error_code = -1
		RETURN			
	end 
end

--error if trim fields sent, but no unit of measure
--if  (isnull(@trimsizewidth,'') <> '' or isnull(@trimsizelength,'') <> '' or isnull(@esttrimsizewidth,'') <> '' or isnull(@esttrimsizelength,'') <> '' or isnull(@tmmactualtrimwidth,'') <> '' 
--	or isnull(@tmmactualtrimlength,'') <> '') and isnull(@trimsizeunitofmeasure,0) = 0
--begin
--	SET @v_msg = 'Trim Size Unit of Measure is blank'+ @v_g_msg
--	  set @v_failed = 1
--    SET @v_messagecategoryqsicode = 0
--	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
--	IF @o_error_code = -1
--	RETURN			
--end 
--error if trim fields sent, but no unit of measure
if @TrimActualTrimSize = 1 begin  --use actual trim size values in validation
	if (isnull(@esttrimsizewidth,'') <> '' or 
	    isnull(@esttrimsizelength,'') <> '' or 
	    isnull(@tmmactualtrimwidth,'') <> '' or 
	    isnull(@tmmactualtrimlength,'') <> '') and 
	    isnull(@trimsizeunitofmeasure,0) = 0
	begin
		SET @v_msg = 'Trim Size Unit of Measure is blank'+ @v_g_msg
		  set @v_failed = 1
      SET @v_messagecategoryqsicode = 24
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		IF @o_error_code = -1
		RETURN			
	end 
end
if @TrimActualTrimSize = 0 begin  --use trim size values in validation
	if (isnull(@esttrimsizewidth,'') <> '' or 
	    isnull(@esttrimsizelength,'') <> '' or 
	    isnull(@trimsizewidth,'') <> '' or 
	    isnull(@trimsizelength,'') <> '') and 
	    isnull(@trimsizeunitofmeasure,0) = 0 
	 begin
		SET @v_msg = 'Trim Size Unit of Measure is blank'+ @v_g_msg
		  set @v_failed = 1
      SET @v_messagecategoryqsicode = 24
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		IF @o_error_code = -1
		RETURN			
	end 
end


--error if spine size sent, but no unit of measure
if isnull(@spinesize,'') <> '' and isnull(@spinesizeunitofmeasure,0) = 0
begin
	SET @v_msg = 'Spine Size Unit of Measure is blank'+ @v_g_msg
	  set @v_failed = 1
    SET @v_messagecategoryqsicode = 24
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
	RETURN			
end 

--error if bookweight sent, but no unit of measure
if isnull(@bookweight,'') <> '' and isnull(@bookweightunitofmeasure,0) = 0
begin
	SET @v_msg = 'Book Weight Unit of Measure is blank'+ @v_g_msg
	  set @v_failed = 1
    SET @v_messagecategoryqsicode = 24
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
	RETURN			
end 

-- error - elo 5 error - missing media
if @v_mediatypecode is null begin
	set @v_failed = 1
	SET @v_msg = 'Missing Book Media'+ @v_bsg_msg
  SET @v_messagecategoryqsicode = 14
	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
	  RETURN		
end 

if @v_mediatypecode is not null begin
	select @v_cnt = count(*)
	from bookdetail
	where bookkey = @i_bookkey
	and mediatypecode in (select datacode from gentables where tableid = 312 and 
          eloquencefieldtag is not null and exporteloquenceind=1 and deletestatus = 'N')

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0
	BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error accessing bookdetail table (bookkey' + CONVERT(VARCHAR, @i_bookkey) + ').'
	  RETURN
	END

	if @v_cnt = 0 begin
	  set @v_failed = 1
	  SET @v_msg = 'Missing Eloquence Field tag or export to eloquence indicator for Media or Inactive Media'+ @v_bsg_msg
    SET @v_messagecategoryqsicode = 3
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	  IF @o_error_code = -1
		RETURN		
	end 
end

--error - elo 5 error - missing format
if @v_mediatypesubcode is null begin
	set @v_failed = 1
	SET @v_msg = 'Missing Book Format'+ @v_bsg_msg
  SET @v_messagecategoryqsicode = 12
	EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	IF @o_error_code = -1
	  RETURN		
end 

if @v_mediatypesubcode is not null and @v_mediatypecode is not null begin
	select @v_cnt = count(*)
	from subgentables
	where datacode = @v_mediatypecode
	and datasubcode = @v_mediatypesubcode
	and tableid = 312
	and eloquencefieldtag is not null and exporteloquenceind=1
  and deletestatus = 'N'

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0
	BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error accessing subgentables 312 (datacode' + CONVERT(VARCHAR, @v_mediatypecode) + ', datasubcode=' + CONVERT(VARCHAR, @v_mediatypesubcode) + ').'
	  RETURN
	END

	if @v_cnt = 0 begin
	  set @v_failed = 1
	  SET @v_msg = 'Missing Eloquence Field tag or export to eloquence indicator or inactive Format for Format'+ @v_bsg_msg
    SET @v_messagecategoryqsicode = 2
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	  IF @o_error_code = -1
		RETURN			
	end 
end

IF @csapproval = 1 OR (@v_elo2ind = 2 AND @csapproval = 4)
 set @csapproved = 1
ELSE
 set @csapproved = 0
 
 SET @v_messageEloOrCS = 'Content Services'
 IF @v_elo2ind > 0 BEGIN
	SET @v_messageEloOrCS = 'Eloquence'
 END
  
--Eloquence approval - only check if the format is one set up with CS partners
if @csapproved <> 1 and @csformat = 1
begin
  SET @v_messagecategoryqsicode = 25
  IF @v_verificationsubtypecode = 2 BEGIN
     SET @v_failed = 1
    SET @v_msgtype = @v_msgtype_error
  END
  
  IF @v_verificationsubtypecode = 2 BEGIN -- First Pass Verification should not check for eloquence approval
  	  SET @v_msg = 'Title not approved for Distribution through ' + @v_messageEloOrCS
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		IF @o_error_code = -1
		  RETURN
  END
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
 
IF @SendRightsToCloud = 1 BEGIN
  SELECT @v_count2 = count(*)
  FROM @territoryctrybytable t, gentables g
  WHERE t.countrycode = g.datacode 
  AND g.tableid=114 
  AND g.deletestatus='N' 
  AND g.eloquencefieldtag IS NOT NULL 
  AND g.exporteloquenceind = 1
  and forsaleind <> 99

  if @v_count2 is null or @v_count2 = 0
  begin
	  --check second for the SALES comment, if that doesn't exist, look for the territory field
	  select @count = count(*)
	  from bookcomments bc
	  join subgentables sg
	  on bc.commenttypecode = sg.datacode
	  and bc.commenttypesubcode = sg.datasubcode
	  and sg.tableid = 284
	  where bookkey = @i_bookkey
	  and sg.eloquencefieldtag in ('SALES', '4SALE','N4SALE')
	  and bc.commenttext is not null and ltrim(convert(varchar(max),bc.commenttext)) <> ''
	  and bc.releasetoeloquenceind = 1
    and sg.deletestatus = 'N'

	  if @count is null or @count = 0
	  begin
		  select @v_territoriescode = territoriescode
		  from book b
		  join gentables g
		  on b.territoriescode = g.datacode
		  and g.tableid = 131
		  and g.deletestatus = 'N'
		  where bookkey = @i_bookkey

  --print titles now need to fail on missing territory also
		  if @v_territoriescode is null or  @v_territoriescode = 0  begin
		    SET @v_msg = 'Missing or Inactive Sales Territory information'+ @v_bsg_msg
		    set @v_failed = 1
        SET @v_messagecategoryqsicode = 22
		    EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end 

		  if @v_territoriescode > 0  begin
			  set @count = 0

			  select @count = count(*)
			  from book b
			  join gentables g
			  on b.territoriescode = g.datacode
			  and g.tableid = 131
			  and g.deletestatus = 'N'
			  and eloquencefieldtag is not null 
			  and exporteloquenceind=1 
			  where bookkey = @i_bookkey

			  if @count is null or @count = 0  begin
			    SET @v_msg = 'Selected Territory value is missing Eloquence fieldtag or is inactive or hasn''t been marked to export to eloquence'+ @v_bsg_msg
			    set @v_failed = 1
          SET @v_messagecategoryqsicode = 4
			    EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
			  end 
		  end
	  end
  end
END --@SendRightsToCloud = 1

IF @SendRightsToCloud = 2 BEGIN
  SELECT @v_count = 0

  SELECT @v_count2 = count(*)
  FROM @territoryctrybytable t, gentables g
  WHERE t.countrycode = g.datacode 
  AND g.tableid=114 
  AND g.deletestatus='N' 
  AND g.eloquencefieldtag IS NOT NULL 
  AND g.exporteloquenceind = 1
  and forsaleind in (0,1)

  IF @v_count2 = 0 OR @v_count2 IS NULL BEGIN
    SET @v_msg = 'Missing or Inactive Sales Territory information'+ @v_bsg_msg
		set @v_failed = 1
    SET @v_messagecategoryqsicode = 22
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	END
END

IF @SendRightsToCloud = 3 BEGIN
  SELECT @v_count2 = 0

  select @v_count2 = count(*)
	  from bookcomments bc
	  join subgentables sg
	  on bc.commenttypecode = sg.datacode
	  and bc.commenttypesubcode = sg.datasubcode
	  and sg.tableid = 284
	  where bookkey = @i_bookkey
	  and sg.eloquencefieldtag in ('SALES', '4SALE','N4SALE')
	  and bc.commenttext is not null and ltrim(convert(varchar(max),bc.commenttext)) <> ''
	  and bc.releasetoeloquenceind = 1
    and sg.deletestatus = 'N'

  IF @v_count2 = 0 OR @v_count2 IS NULL BEGIN
    SET @v_msg = 'Missing or Inactive Rights Comments information'+ @v_bsg_msg
		set @v_failed = 1
    SET @v_messagecategoryqsicode = 22
		EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  END
END

IF @SendRightsToCloud = 5 BEGIN
  SELECT @v_count2 = 0

  select @v_territoriescode = territoriescode
	  from book b
	  join gentables g
		  on b.territoriescode = g.datacode
	   and g.tableid = 131
		 and g.deletestatus = 'N'
		where bookkey = @i_bookkey

  --print titles now need to fail on missing territory also
	if @v_territoriescode is null or  @v_territoriescode = 0  begin
	   SET @v_msg = 'Missing or Inactive Sales Territory information'+ @v_bsg_msg
	   set @v_failed = 1
     SET @v_messagecategoryqsicode = 22
	   EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
	 end 

	 if @v_territoriescode > 0  begin
	  set @count = 0

		select @count = count(*)
		  from book b
		  join gentables g
			  on b.territoriescode = g.datacode
		   and g.tableid = 131
			 and g.deletestatus = 'N'
			 and eloquencefieldtag is not null 
			 and exporteloquenceind=1 
		 where bookkey = @i_bookkey

		 if @count is null or @count = 0  begin
		    SET @v_msg = 'Selected Territory value is missing Eloquence fieldtag or is inactive or hasn''t been marked to export to eloquence'+ @v_bsg_msg
		    set @v_failed = 1
        SET @v_messagecategoryqsicode = 4
			   EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  end 
	end
END

IF @SendRightsToCloud = 1 OR @SendRightsToCloud = 2 BEGIN
  -- Verify that all countries (both for sale and not for sale ) are present in the Clound region table
  SELECT @v_count2 = 0

  DECLARE @invalidcountrycodesfortitle TABLE (
    bookkey INT NOT NULL,
    countrycode INT NULL,
    countrydesc VARCHAR(255) NULL,
    elofieldtag VARCHAR(25) NULL,
		deletestatus VARCHAR(25) NULL,
    exporteloquenceind INT NULL)

-- fail verification if (country is inactive) OR (if exporteloquenceind=1 AND eloquencefieldtag is invalid). 
-- Note that it is OK to have Active Country with invalid eloquencefieldtag if exporteloquenceind=0

  INSERT INTO @invalidcountrycodesfortitle
  SELECT bookkey,countrycode,datadesc,eloquencefieldtag,g.deletestatus,exporteloquenceind
  FROM @territoryctrybytable t 
      join gentables g
      on t.countrycode = g.datacode 
      AND g.tableid=114 
--      AND g.eloquencefieldtag IS NOT NULL 
--      AND g.exporteloquenceind = 1
      left outer join cloudregion cr
      on lower(ltrim(rtrim(tag))) = lower(ltrim(rtrim(g.eloquencefieldtag)))
  WHERE t.forsaleind in (0,1)
    and (cr.id is null or upper(g.deletestatus)='Y') 
            
  set @counter2 = 1
  set @rowcount2 = 0
  set @mincountrycode = 0

  select @rowcount2 = count(*), @mincountrycode = min(countrycode)
  from @invalidcountrycodesfortitle

  while @counter2 <= @rowcount2
  begin
    select @countrytag = ltrim(rtrim(elofieldtag)), @countrydesc = countrydesc, @exporteloquenceind = exporteloquenceind,@deletestatus=deletestatus
    from @invalidcountrycodesfortitle
    where countrycode = @mincountrycode

    IF 	UPPER(@deletestatus)='N' and @exporteloquenceind=1 BEGIN -- country is active and exportable, but eloquencefieldtag is invalid data
      SET @v_msg = 'Selected Country is missing a valid eloquencefieldtag: ' + COALESCE(@countrydesc, 'NULL') + @v_bsg_msg
      set @v_failed = 1
      SET @v_messagecategoryqsicode = 31
      EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
      IF @o_error_code = -1 BEGIN
	      RETURN
	    END  
    END

    IF @deletestatus='Y' BEGIN --country is inactive. get_product will not get inactive countries
      SET @v_msg = 'Selected Country is inactive: ' + COALESCE(@countrydesc, 'NULL') + @v_bsg_msg
      set @v_failed = 1
      SET @v_messagecategoryqsicode = 31
      EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
      IF @o_error_code = -1 BEGIN
	      RETURN
	    END  
    END

    select @mincountrycode = min(countrycode)
    from @invalidcountrycodesfortitle
    where countrycode > @mincountrycode
	
	  select @counter2 = @counter2 + 1
  end
END

IF @SendRightsToCloud = 3 BEGIN
  -- Verify that all countries (from the commentstring) are present in the Cloud region table
  SELECT @v_count2 = 0

  select @v_count2 = count(*)
	  from bookcomments bc
	  join subgentables sg
	  on bc.commenttypecode = sg.datacode
	  and bc.commenttypesubcode = sg.datasubcode
	  and sg.tableid = 284
	  where bookkey = @i_bookkey
	  and sg.eloquencefieldtag in ('SALES', '4SALE','N4SALE')
	  and bc.commenttext is not null
	  and bc.releasetoeloquenceind = 1  
    and sg.deletestatus = 'N'
            
  set @counter2 = 1
  set @rowcount2 = 0
  set @mincountrycode = 0

  IF @v_count2 = 1 BEGIN

    SELECT @v_salesrights_commenttext = commenttext
      FROM bookcomments bc
      JOIN subgentables sg
        ON bc.commenttypecode = sg.datacode
	     AND bc.commenttypesubcode = sg.datasubcode
	     AND sg.tableid = 284
	   WHERE bookkey = @i_bookkey
	     AND sg.eloquencefieldtag in ('SALES', '4SALE','N4SALE')
	     AND bc.commenttext is not null
	     AND bc.releasetoeloquenceind = 1
       AND sg.deletestatus = 'N'

    SET @v_start = 0
    SET @v_end = 0
    SET @v_count3 = 0
    SET @v_string = ''

    DECLARE @tmpcountries TABLE (
     id		INT IDENTITY(1,1),
     eloquencefieldtag	CHAR(20) null)
    

    IF @v_salesrights_commenttext IS NOT NULL AND LTRIM(@v_salesrights_commenttext) <> '' BEGIN
      SET @v_start = CHARINDEX('<b090>',@v_salesrights_commenttext)
      IF @v_start > 0 BEGIN
         SET @v_start = @v_start + 6
         SET @v_end = CHARINDEX('</b090>',@v_salesrights_commenttext)
         SET @v_string = substring(@v_salesrights_commenttext,@v_start,@v_end-(@v_start))
      END
      ELSE BEGIN
         SET @v_end = DataLength(@v_salesrights_commenttext)
         SET @v_string = substring(@v_salesrights_commenttext,1,@v_end)
      END
    END

    IF @v_string <> '' AND @v_string IS NOT NULL BEGIN
      SELECT @v_start = 1
      SELECT @v_len = DataLength(@v_salesrights_commenttext)
		  while @v_start <= @v_len
		  begin
			  select @v_eloquencefieldtag_ctry = substring(@v_salesrights_commenttext, @v_start, 2)
			  insert into @tmpcountries values (@v_eloquencefieldtag_ctry)
			  select @v_start = @v_start + 3
		  end

      SELECT @v_count3 = count(*)
        FROM @tmpcountries

      IF @v_count3 > 0 BEGIN  --  country rows
         SET @v_counter2 = 1
	       SET @v_rowcount2 = 0
	       SET @v_eloquencefieldtag_ctry = ' '

         SELECT @v_rowcount2 = count(*), @v_eloquencefieldtag_ctry = min(eloquencefieldtag)
	         FROM @tmpcountries

         WHILE @v_counter2 <= @v_rowcount2 BEGIN
          SELECT @v_count4 = 0

          SELECT @v_count4 = count(*)
            FROM gentables
           WHERE tableid = 114
             AND eloquencefieldtag = @v_eloquencefieldtag_ctry
             AND deletestatus = 'N'

          IF @v_count4 = 1 BEGIN
            SELECT @countrycode = datacode, @countrydesc = datadesc, @exporteloquenceind = exporteloquenceind
              FROM gentables
             WHERE tableid = 114
               AND eloquencefieldtag = @v_eloquencefieldtag_ctry
               AND deletestatus = 'N'

             IF COALESCE(@exporteloquenceind,0) = 0 BEGIN
                SET @v_msg = 'Export to Eloquence is not checked for Selected Country: ' + COALESCE(@countrydesc, 'NULL') + @v_bsg_msg
                set @v_failed = 1
                SET @v_messagecategoryqsicode = 31
                EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
                IF @o_error_code = -1 BEGIN
	                RETURN
	              END 
             END

             SELECT @v_count = 0

             SELECT @v_count = count(*)
               FROM cloudregion
              WHERE ltrim(rtrim(tag)) = @v_eloquencefieldtag_ctry


             IF @v_count IS NULL OR @v_count = 0  BEGIN
		            SET @v_msg = 'Selected Country value is missing on ISO CloudRegion table for:' + COALESCE(@countrytag, 'NULL') + @v_bsg_msg
		            SET @v_failed = 1
                SET @v_messagecategoryqsicode = 31
		            EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
                IF @o_error_code = -1 BEGIN
					        RETURN
	              END 
             END    
           
            END  --@v_count4 = 1

                                            
            SELECT @v_eloquencefieldtag_ctry = min(eloquencefieldtag)
		          FROM @tmpcountries
             WHERE eloquencefieldtag > @v_eloquencefieldtag_ctry
    	  	
		        SELECT @v_counter2 = @v_counter2 + 1
        END  --@v_counter2 <= @v_rowcount2 loop
      END -- @v_count3 > 0 (countries exist in sales rights comment)
    END  -- @v_string <> ''
  END  --@v_count2 = 1(sales rights comments exist for bookkey)
END   --@SendRightsToCloud = 3



--language
if isnull(@v_languagecode,0) = 0 and isnull(@v_languagecode2,0) = 0 begin
  SET @v_msg = 'Missing Language'+ @v_bsg_msg
  SET @v_messagecategoryqsicode = 13
  if @eodlevel = 3
  begin	
	  set @v_warnings = 1
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  end
  else if @eodlevel = 4
  begin	
	  set @v_failed = 1
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_error, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  end
  else if @eodlevel = 2
  begin	
	  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_info, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
  end
  IF @o_error_code = -1
    RETURN  
end 

-- Check to see if both JUV and Non JUV Bisac Subjects on same title 2/11/16 KB
SELECT @v_count5 = 0
EXEC bookverification_bisacsubjects_juv_jnf_check @i_bookkey,1, @v_count5 out  -- Check for JUV rows on bookbisaccategory
IF @v_count5 > 0 BEGIN
	IF isnull(@v_gradelowupind,0) = 0 BEGIN
		IF isnull(@v_gradelow,'0') = '0' BEGIN
		  SET @v_msg = 'Missing Grade Level - Grade Low'+ @v_bsg_msg 
		  SET @v_warnings = 1
		  SET @v_messagecategoryqsicode = 29
		  EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		  IF @o_error_code = -1 BEGIN
			  RETURN
		  END  
		END 
	END
END
IF @v_count5 > 0 BEGIN
	IF ISNULL(@v_gradehighupind,0) = 0 BEGIN
		IF ISNULL(@v_gradehigh,'0') = '0' BEGIN
			SET @v_msg = 'Missing Grade Level - Grade High'+ @v_bsg_msg 
			SET @v_warnings = 1
			SET @v_messagecategoryqsicode = 30
			EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
			IF @o_error_code = -1 BEGIN
			  RETURN
			END  
		END  
	END
END
SELECT @v_count6 = 0
IF @v_count5 > 0  BEGIN -- Rows exist for JUV on bookbisaccategory
   EXEC bookverification_bisacsubjects_juv_jnf_check @i_bookkey,0, @v_count6 out -- Check for JNF rows on bookbisaccategory
   IF @v_count6 > 0  BEGIN-- Rows also exist on bookbisaccategory for JNF
		SET @v_msg = ' It is not valid to use JUV and Non JUV BISAC Subjects on a single title'+ @v_bsg_msg 
		SET @v_warnings = 1
		SET @v_messagecategoryqsicode = 31
		EXEC bookverificationmessage_insert @i_bookkey, @i_verificationtypecode, @v_msgtype_warning, @v_msg, @i_username, @o_error_code output, @o_error_desc output, @v_messagecategoryqsicode
		IF @o_error_code = -1 BEGIN
		  RETURN
		END         
   END
END
--error - missing discount code
--
--	if @v_discountcode is null and @v_mediatypecode=2 begin
--		exec get_next_key @i_username, @v_nextkey out
--		insert into bookverificationmessage
--		values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_msgtype_error, 'Missing Discount Code',@i_username, getdate() )
--		set @v_failed = 1
--	end 

----Publisher 
--select @v_cnt = count(bookkey)
--from bookorgentry
--where bookkey = @i_bookkey
--and orglevelkey in(select filterorglevelkey
--		from filterorglevel
--		where filterkey = 18)
--
--if @v_cnt = 0 begin
--	exec get_next_key @i_username, @v_nextkey out
--	insert into bookverificationmessage
--	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_msgtype_error, 'Missing Publisher'+ @v_bsg_msg,@i_username, getdate() )
--	set @v_failed = 1
--end
--
----Imprint 
--select @v_cnt = count(bookkey)
--from bookorgentry
--where bookkey = @i_bookkey
--and orglevelkey in(select filterorglevelkey
--		from filterorglevel
--		where filterkey = 15)
--
--if @v_cnt = 0 begin
--	exec get_next_key @i_username, @v_nextkey out
--	insert into bookverificationmessage
--	values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_msgtype_error, 'Missing Imprint' + @v_bsg_msg,@i_username, getdate() )
--	set @v_failed = 1
--end

--failed
if @v_failed = 1 begin

  select @v_datacode = datacode
  from gentables 
  where tableid = 513
  and qsicode = 2
	
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing gentables 513 (qsicode=2).'
    RETURN
  END	
	
  update bookverification
  set titleverifystatuscode = @v_datacode, lastmaintdate = getdate(), lastuserid = @i_username
  where bookkey = @i_bookkey	
  and verificationtypecode = @i_verificationtypecode

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error updating bookverification table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ', verificationtypecode=' + CONVERT(VARCHAR, @i_verificationtypecode) + ').'
    RETURN
  END
  
	/*	if @i_verificationtypecode = 1 begin
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
	end */

end 


--passed with warnings
if @v_failed = 0 and @v_warnings = 1 begin
  select @v_datacode = datacode
  from gentables 
  where tableid = 513
  and qsicode = 4

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing gentables 513 (qsicode=4).'
    RETURN
  END
  
  update bookverification
  set titleverifystatuscode = @v_datacode, lastmaintdate = getdate(), lastuserid = @i_username
  where bookkey = @i_bookkey
  and verificationtypecode = @i_verificationtypecode

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error updating bookverification table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ', verificationtypecode=' + CONVERT(VARCHAR, @i_verificationtypecode) + ').'
    RETURN
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
if @v_failed = 0 and @v_warnings = 0 begin
  select @v_datacode = datacode
  from gentables 
  where tableid = 513
  and qsicode = 3
	
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing gentables 513 (qsicode=3).'
    RETURN
  END	

  update bookverification
  set titleverifystatuscode = @v_datacode, lastmaintdate = getdate(), lastuserid = @i_username
  where bookkey = @i_bookkey
  and verificationtypecode = @i_verificationtypecode
	
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error updating bookverification table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ', verificationtypecode=' + CONVERT(VARCHAR, @i_verificationtypecode) + ').'
    RETURN
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
END
END
go

grant execute on cs_verification to public
go