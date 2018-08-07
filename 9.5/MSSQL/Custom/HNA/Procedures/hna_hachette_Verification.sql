/****** Object:  StoredProcedure [dbo].[hna_hachette_Verification]    Script Date: 7/28/2016 1:50:28 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hna_hachette_Verification]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hna_hachette_Verification]
GO

/****** Object:  StoredProcedure [dbo].[hna_hachette_Verification]    Script Date: 7/28/2016 1:50:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hna_hachette_Verification]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[hna_hachette_Verification] AS' 
END
GO






ALTER proc [dbo].[hna_hachette_Verification](
		     @i_bookkey int,
		     @i_printingkey int,
		     @i_verificationtypecode int,
		     @i_username varchar(15))

AS
 
BEGIN
		    SET NOCOUNT ON; 



------DECLARE @i_orgentrykey int

------SELECT @i_orgentrykey = orgentrykey
------from bookorgentry where bookkey = @i_bookkey and orglevelkey = 2
--------select * from orgentry where orgentrykey in ( 4028289,4028339,4028341)
------IF @i_orgentrykey in ( 4028289,4028339,4028341) and @b_unit<>1
------BEGIN



--declare @i_bookkey int,
--		     @i_printingkey int,
--		     @i_verificationtypecode int,
--		     @i_username varchar(15)
--set @i_bookkey=15817344
--set @i_printingkey=1
--set @i_verificationtypecode=6
--set @i_username='ba_test'






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

if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_ISBN13')
begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'HACHETTE_ISBN13',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_Title')
begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'HACHETTE_Title',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_Pubdate')
begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'HACHETTE_Pubdate',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_BISACStatus')
begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'HACHETTE_BISACStatus',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_UsageClass')
begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'HACHETTE_UsageClass',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_BISACSubject')
begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'HACHETTE_BISACSubject',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_Audience')
begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'HACHETTE_Audience',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_Author')
begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'HACHETTE_Author',1,'qsidba',GETDATE()
 end
if not exists(Select 1 from dbo.bookverificationcolumns where columnname='HACHETTE_familycode')
begin
  insert into dbo.bookverificationcolumns(columnname,activeind,lastmaintuserid,lastmaintdate)
  Select 'HACHETTE_familycode',1,'qsidba',GETDATE()
 end
 

 DECLARE @v_Author varchar(120)
Declare @v_BISACSubject varchar(100)
Declare @v_Audience varchar(100)
DECLARE @v_familycode varchar(100)
Declare @v_BISACStatus varchar(10)
Declare @v_UsageClass varchar(10)
Declare @v_Pubdate varchar(10)
DECLARE @v_ISBN13 varchar(13)
DECLARE @v_Title varchar(80)



Select @v_ISBN13 = nullif(ean13,'') from isbn where bookkey = @i_bookkey
Select @v_Title = nullif(substring(title,1,80),'') from book where bookkey = @i_bookkey
Select @v_Pubdate = nullif(Convert(varchar(10),dbo.[rpt_get_title_task_Printingkey_Specific](@i_bookkey,8,1,'B'),101),'')
select @v_BISACStatus = case when dbo.rpt_hbg_get_assoc_title_status (@i_bookkey,1,8)<>'' then dbo.rpt_hbg_get_assoc_title_status (@i_bookkey,1,8) else dbo.rpt_get_bisac_status(@i_bookkey,'d') end
Select @v_BISACStatus = nullif(@v_BISACStatus,'')
Select @v_UsageClass = nullif(Cast(usageclasscode as varchar(1)),'') from book where bookkey =@i_bookkey
Select @v_BISACSubject = nullif(dbo.rpt_get_bisac_subject(@i_bookkey,1,'d'),'')
Select @v_Audience = case when dbo.rpt_hbg_get_assoc_title_audience (@i_bookkey,1,8)<>'' then dbo.rpt_hbg_get_assoc_title_audience (@i_bookkey,1,8) else  dbo.rpt_get_bisac_subject(@i_bookkey,1,'B') end
select @v_audience = nullif(@v_Audience,'') 
Select @v_Author =  (select count(*) from bookauthor where bookkey = @i_Bookkey and authortypecode in (select datacode from gentables where tableid=134))	 --nullif(dbo.rpt_get_author (@i_bookkey,1,12,'D'),'')
Select @v_Author = nullif(@v_Author,'')
Select @v_familycode =  nullif(  (Select top 1 dbo.rpt_get_gentables_field(412,CategoryCode,'E') from booksubjectcategory b 
	   where b.bookkey=@i_bookkey and categorytableid=412 and sortorder=(select min(sortorder) from booksubjectcategory where bookkey=@i_bookkey and categorytableid=412))
	,'')


--print @v_ISBN13 
--print @v_Title 
--print @v_Pubdate 
--print @v_BISACStatus 
--print @v_UsageClass 
--print @v_BISACSubject 
--print @v_Audience 
--print @v_Author 
--print @v_familycode 



 exec bookverification_check 'HACHETTE_ISBN13', @i_write_msg output
 if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
				IF coalesce(@v_ISBN13,'')=''
					BEGIN
						set @msg= 'ISBN13 is missing.'
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
						set @v_failed = 1
					END
				END
		end
 exec bookverification_check 'HACHETTE_Title', @i_write_msg output
 if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
				IF coalesce(@v_Title,'')=''
					BEGIN
						set @msg= 'Title is missing.'
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
						set @v_failed = 1
					END
				END
		end
 exec bookverification_check 'HACHETTE_Pubdate', @i_write_msg output
 if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
				IF coalesce(@v_Pubdate,'')=''
					BEGIN
						set @msg= 'Pubdate is missing.'
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
						set @v_failed = 1
					END
				END
		end
 exec bookverification_check 'HACHETTE_BISACStatus', @i_write_msg output
 if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
				IF coalesce(@v_BISACStatus,'')=''
					BEGIN
						set @msg= 'BISAC Status is missing.'
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
						set @v_failed = 1
					END
				END
		end
 exec bookverification_check 'HACHETTE_UsageClass', @i_write_msg output
 if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
				IF coalesce(@v_UsageClass,'')=''
					BEGIN
						set @msg= 'Usage Class is missing.'
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
						set @v_failed = 1
					END
				END
		end
 exec bookverification_check 'HACHETTE_BISACSubject', @i_write_msg output
 if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
				IF coalesce(@v_BISACSubject,'')=''
					BEGIN
						set @msg= 'BISAC Subject is missing.'
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
						set @v_failed = 1
					END
				END
		end
 exec bookverification_check 'HACHETTE_Audience', @i_write_msg output
 if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
				IF coalesce(@v_Audience,'')=''
					BEGIN
						set @msg= 'Audience is missing.'
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
						set @v_failed = 1
					END
				END
		end
 exec bookverification_check 'HACHETTE_Author', @i_write_msg output
 if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
				IF coalesce(@v_Author,'')=''
					BEGIN
						set @msg= 'Author is missing.'
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
						set @v_failed = 1
					END
				END
		end
 exec bookverification_check 'HACHETTE_familycode', @i_write_msg output
 if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 6 
				begin
				IF coalesce(@v_familycode,'')=''
					BEGIN
						set @msg= 'familycode is missing.'
						exec get_next_key @i_username, @v_nextkey out
						insert into bookverificationmessage
						values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, @msg,@i_username, getdate() )
						set @v_failed = 1
					END
				END
		end







-- FAILED

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
		END
		


		--select * from gentables where datadesc like '%fail%'
		--select * from gentables where tableid=513


-- PASSED WITH WARNING

		--passed with warnings
		SELECT @v_datacode = datacode
		FROM gentables
		WHERE tableid = 513
			AND qsicode = 4

		IF @v_failed = 0
			AND @v_varnings = 1
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
		END




-- PASSED 

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

GRANT EXECUTE ON [dbo].[hna_hachette_Verification] TO [public] AS [dbo]
GO


