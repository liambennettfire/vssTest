/****** Object:  StoredProcedure [dbo].[va_check_titles]    Script Date: 09/09/2010 10:05:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[va_check_titles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[va_check_titles]


/****** Object:  StoredProcedure [dbo].[va_check_titles]    Script Date: 09/09/2010 15:21:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[va_check_titles](
		@i_bookkey		INT,
		@i_row_passfail 	INT output,
		@v_title_message	VARCHAR(2000) output)
AS

/*	The purpose of the va_check_titles procedure is to verify a single title contains a set data for certain fields, and
	that some of those fields have an externalcode associated with their gentables entry.

	The procedure will also insert the error details into the feed_messages tables as well as the Title Error comments for 
	the title.

	Parameters
		@i_bookkey - Integer
			= bookkey

--this edit removed
--		@v_season -varchar = 'S 2008'
--		for PGW only:  acts as a check to ensure that no titles after a specific season are sent to cispub

	Output
		@i_row_passfail - Integer
			0 = Failed Verfication 
			1 = Passed Verification
						
		@v_error_msg - VARCHAR
			contains any error details
*/
DECLARE @v_toporg		varchar(20)
DECLARE @v_isbn			VARCHAR(20)
DECLARE @i_orgentrykey	int

DECLARE @d_lastmaintdate	DATETIME
DECLARE @v_lastuserid		VARCHAR(30)
DECLARE @i_feedkey		INT
DECLARE @v_newline		VARCHAR(10)
DECLARE @v_error_msg		VARCHAR(2000)
DECLARE @v_message		VARCHAR(2000)
declare @elosent		int
declare @errorcode		int
declare @errordesc		varchar(2000)

DECLARE @d_seasontoprange	DATETIME
declare @today	datetime

select @today = convert(varchar(8),getdate(),1)	--want to get the date with no time, so < comparison excludes any dates from today

SELECT @i_feedkey = MAX(feedkey) 
FROM cispub_feeds

SELECT @d_lastmaintdate = getdate()
SELECT @v_lastuserid = 'Verification Agent'
SELECT @v_newline = CHAR(13)+ CHAR(10)
SELECT @i_row_passfail = 1
SELECT @v_error_msg = ''

--SELECT @d_seasontoprange = enddate 
--from season 
--where seasonshortdesc = @v_season

/* Check for proper Organizations, based on top org */
select @v_toporg = dbo.get_grouplevel1(@i_bookkey,'S')
if @v_toporg = ''
begin
	SELECT @v_message = 'Company/PubCd not found in TMM OR has an invalid short description'
	EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
	SELECT @v_error_msg = @v_error_msg+@v_message+'\'
	SELECT @i_row_passfail = 0
end

--need to classify Avalon & Seal travel as PBG, even though they are in PGW's structure
select @i_orgentrykey = orgentrykey
from bookorgentry
where orglevelkey = 2
and bookkey = @i_bookkey

if @i_orgentrykey = 714 or @i_orgentrykey = 835
begin
	set @v_toporg = 'PBG'
end


--6/30/09 TEMPORARILY FAIL ALL PD TITLES UNTIL THEY ARE READY TO JOIN THE FEED
/*
if @v_toporg = 'PD'
begin
	SELECT @v_message = 'PD is not ready to feed to CISPUB from TMM'
	EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
	SELECT @v_error_msg = @v_error_msg+@v_message+'\'
	SELECT @i_row_passfail = 0
	RETURN
END
*/
--ONCE PD READY, JUST DELETE THIS BLOCK FROM THE 6/30/09 COMMENT TO THIS LINE


if @v_toporg = 'PBG'
begin
	/*Check for Company/PubCd	*/
	IF dbo.get_GroupLevel3(@i_bookkey,'S') = ''		-- 08/06/09 changed to group level 3 short description
	BEGIN
		SELECT @v_message = 'Company/PubCd not found in TMM OR has an invalid CIS.PUB Code'
		EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
		SELECT @v_error_msg = @v_error_msg+@v_message+'\'
		SELECT @i_row_passfail = 0
	END

	/*Check for Product Line - for Boulder Cispub for PBG	*/
	IF dbo.get_product_line(@i_bookkey,'E') = ''
	BEGIN
		SELECT @v_message = 'Product Line not found in TMM OR has an invalid CIS.PUB Code'
		EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
		SELECT @v_error_msg = @v_error_msg+@v_message+'\'
		SELECT @i_row_passfail = 0
	END
end
else if @v_toporg = 'PGW' or @v_toporg = 'CBSD'
begin
	/*Check for Division - "P-code" for PGW	*/
	IF dbo.get_GroupLevel3(@i_bookkey,'S') = ''
	BEGIN
		SELECT @v_message = 'Division not found in TMM OR has an invalid CIS.PUB Code'
		EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
		SELECT @v_error_msg = @v_error_msg+@v_message+'\'
		SELECT @i_row_passfail = 0
	END
end
else if @v_toporg = 'PD'
begin
	/*Check for "Pub-code" for PD	*/
	IF dbo.get_GroupLevel2(@i_bookkey,'S') = ''
	BEGIN
		SELECT @v_message = 'PD Pub Code not found in TMM OR has an invalid CIS.PUB Code'
		EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
		SELECT @v_error_msg = @v_error_msg+@v_message+'\'
		SELECT @i_row_passfail = 0
	END

	IF dbo.get_GroupLevel3(@i_bookkey,'S') = ''
	BEGIN
		SELECT @v_message = 'PD Imprint Code not found in TMM OR has an invalid CIS.PUB Code'
		EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
		SELECT @v_error_msg = @v_error_msg+@v_message+'\'
		SELECT @i_row_passfail = 0
	END

end
else
BEGIN
	SELECT @v_message = 'Company not defined for Cispub Feed'
	EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
	SELECT @v_error_msg = @v_error_msg+@v_message+'\'
	SELECT @i_row_passfail = 0
	RETURN
END



SELECT @v_isbn = dbo.get_ISBN(@i_bookkey,10)

/* Verify ISBN is present	*/
IF ltrim(rtrim(dbo.get_ISBN(@i_bookkey,10))) = ''
BEGIN
	SELECT @v_message = 'ISBN not found in TMM'
	EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
	SELECT @v_error_msg = @v_message+'\'
	SELECT @i_row_passfail = 0
END

/*  Check for Title	*/
IF ltrim(rtrim(dbo.get_Title(@i_bookkey,'F'))) = ''
BEGIN
	SELECT @v_message = 'Title not found in TMM'
	EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
	SELECT @v_error_msg = @v_error_msg+@v_message+'\'
	SELECT @i_row_passfail = 0
END

/*  Check for Short Title	*/
IF ltrim(rtrim(dbo.get_ShortTitle(@i_bookkey))) = ''
BEGIN
	SELECT @v_message = 'Short Title not found in TMM'
	EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
	SELECT @v_error_msg = @v_error_msg+@v_message+'\'
	SELECT @i_row_passfail = 0
END

/* Check for Format	*/
IF dbo.get_Format(@i_bookkey,'2') = ''
BEGIN
	SELECT @v_message = 'Format not found in TMM OR has an invalid CIS.PUB Code'
	EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
	SELECT @v_error_msg = @v_error_msg+@v_message+'\'
	SELECT @i_row_passfail = 0
END


/* Check BISAC Status		*/
if @v_toporg = 'PGW' or @v_toporg = 'CBSD'
begin
	IF dbo.get_BisacStatusCispub(@i_bookkey,'1') = ''
	BEGIN
		SELECT @v_message = 'Pub Status not found in TMM OR has an invalid CIS.PUB Code'
		EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message			
		SELECT @v_error_msg = @v_error_msg+@v_message+'\'
		SELECT @i_row_passfail = 0
	END
end
else if @v_toporg = 'PBG'
begin
	if dbo.get_BisacStatus(@i_bookkey,'S') = 'OP'
	begin
		if dbo.get_BestDate(@i_bookkey,1,399) <> '' and convert(datetime,dbo.get_BestDate(@i_bookkey,1,399)) < @today	--Last Return Date			
		BEGIN
			SELECT @v_message = 'BISAC status is OP and Last Return Date is earlier than today'
			EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message			
			SELECT @v_error_msg = @v_error_msg+@v_message+'\'
			SELECT @i_row_passfail = 0
		END
	end

	IF dbo.get_BisacStatusCispub(@i_bookkey,'2') = ''
	BEGIN
		SELECT @v_message = 'Pub Status not found in TMM OR has an invalid CIS.PUB Code'
		EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message			
		SELECT @v_error_msg = @v_error_msg+@v_message+'\'
		SELECT @i_row_passfail = 0
	END
end
else if @v_toporg = 'PD'
begin
	IF dbo.get_BisacStatusCispub(@i_bookkey,'1') = ''
	BEGIN
		SELECT @v_message = 'Pub Status not found in TMM OR has an invalid CIS.PUB Code'
		EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message			
		SELECT @v_error_msg = @v_error_msg+@v_message+'\'
		SELECT @i_row_passfail = 0
	END
end
		
/* Check for Discount	*/
IF dbo.get_Discount(@i_bookkey,'E') = ''
BEGIN
	SELECT @v_message = 'Discount not found in TMM OR has an invalid CIS.PUB Code'
	EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
	SELECT @v_error_msg = @v_error_msg+@v_message+'\'
	SELECT @i_row_passfail = 0
END

/* Check for price	*/
IF dbo.get_BestUSPrice(@i_bookkey,11) = ''
BEGIN
	SELECT @v_message = 'Price not found in TMM OR has an invalid CIS.PUB Code'
	EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
	SELECT @v_error_msg = @v_error_msg+@v_message+'\'
	SELECT @i_row_passfail = 0
END

--/* Check for season	*/
--if @v_toporg = 'PGW'		--PBG & PD wants to send titles as soon as they pass validation, not wait for seasons
--begin
--/* on 11/6/07 PGW decided that we should allow titles without seasons to be passed from TMM to Cispub, but if they do have a season it has to be before the cutoff date*/
--	IF dbo.get_bestseason_cispub(@i_bookkey,1,'E') >=  @d_seasontoprange 
--	BEGIN
--		SELECT @v_message = 'Season falls after cutoff date in TMM'
--		EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
--		SELECT @v_error_msg = @v_error_msg+@v_message+'\'
--		SELECT @i_row_passfail = 0
--	END
--end

--3/5/10 JL If PGW or CBSD title has been sent to eloquence and passes all previous edits 
--and is not already set to Always send or Never send or Sent to Cispub, mark it as Always send

if @v_toporg = 'PGW' or @v_toporg = 'CBSD' or @v_toporg = 'PD'
begin
	IF dbo.get_TitleVerifyStatus(@i_bookkey,'E') <> 'SEND' and dbo.get_TitleVerifyStatus(@i_bookkey,'E') <> 'NEVER' 
    begin
		select @elosent = isnull(count(*), 0)
		from bookedistatus
		where bookkey = @i_bookkey
		and edistatuscode in (3, 4)		--Resend or Send Complete

		if @elosent > 0 or dbo.get_TitleVerifyStatus(@i_bookkey,'D') = 'Sent to Cispub'  
		begin
			if @i_row_passfail = 1 
			begin
				UPDATE bookverification
				SET 	titleverifystatuscode = 9,	/* STATUS = 'always send to cispub' */
						lastmaintdate = getdate(),
						lastuserid = @v_lastuserid
				WHERE	bookkey = @i_bookkey
				and verificationtypecode=1

				EXEC qtitle_update_titlehistory 'bookverification','titleverifystatuscode',@i_bookkey,1,NULL,
					'Always Send to Cispub','UPDATE',@v_lastuserid,0,NULL,@errorcode output,@errordesc output		

			end
		end
		else
		begin
			SELECT @v_message = 'Title not sent to eloquence yet.'
			EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
			SELECT @v_error_msg = @v_error_msg+@v_message+'\'
			SELECT @i_row_passfail = 0
		end
	end
end

/* Check for override 1/23/08	*/
--3/5/10 JL - I was going to move this to the top since it overrides the status anyway,
--but decided to leave it here so all other errors would be collected for user to correct data for next time
--Title overrides with always send and never send
IF dbo.get_TitleVerifyStatus(@i_bookkey,'E') = 'NEVER'  
BEGIN
	SELECT @v_message = 'Verification Override - Never Send to Cispub'
	EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
	SELECT @v_error_msg = @v_error_msg+@v_message+'\'
	SELECT @i_row_passfail = 0
END

IF dbo.get_TitleVerifyStatus(@i_bookkey,'E') = 'SEND'     
BEGIN
	SELECT @v_message = 'Verification Override - Always Send to Cispub'
	EXECUTE cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,@v_message
	SELECT @v_error_msg = @v_error_msg+@v_message+'\'
	SELECT @i_row_passfail = 1
END	




IF @i_row_passfail = 0
BEGIN
	SELECT @v_title_message = REPLACE(@v_error_msg,'\',@v_newline)
END

RETURN



