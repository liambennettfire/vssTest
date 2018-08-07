
/****** Object:  StoredProcedure [dbo].[hmco_import_from_xart2_detail]    Script Date: 01/11/2010 15:22:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_xart2_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_xart2_detail]
/****** Object:  StoredProcedure [dbo].[hmco_import_from_xart2_detail]    Script Date: 05/22/2009 10:47:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jennifer Hurd
-- Create date: 2/24/09
-- Description:	imports data from SAP
-- you can run this by calling hmco_import_from_sap_driver to let it determine bookkeys to run
-- or run it for individual bookkeys, just sending in the arguments setting the prevstartdatetime to the starting
-- period for the data and startdatetime as the end of the run period.  this startdatetime will be written as 
-- the extract date on the file.
-- =============================================
CREATE PROCEDURE [dbo].[hmco_import_from_xart2_detail] 
	@i_bookkey int = 0, 
	@i_rowid	int,
	@i_update_mode	char(1),
	@i_userid   varchar(30),
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare     @v_error  INT,
@v_rowcount INT,
@count	int,
@update		int,
@insert		int,
@material	varchar(20),
@materialold	varchar(20),
@upc		varchar(50),
@upcold		varchar(50),
@ean13		varchar(20),	--no hyphens
@ean13old	varchar(20),
@ean		varchar(20),	--hyphens
@eanold		varchar(20),
@isbn		varchar(20),	--hyphens
@isbnold	varchar(20),
@isbn10		varchar(20),	--no hyphens
@isbn10old	varchar(20),
@gtin		varchar(20),	--hyphens
@gtin14		varchar(20)		--no hyphens

declare @hyphen	int,
@v_eanprefix	varchar(10),
@v_isbnprefix	varchar(20),
@v_isbnpostfix	varchar(20),
@v_isbnprefix_gt	varchar(20),
@v_eanprefix_code	int,
@v_isbnprefix_code		int


SET @o_error_code = 0
SET @o_error_desc = ''  

select @material = isnull(material,''),
@ean13 = isnull(isbn13,''),
@isbn10 = isnull(isbn10,''),
@upc = isnull(upccode,'')
from hmco_export_to_sap
where bookkey = @i_bookkey
and row_id = @i_rowid
and sap_request_type = 'Request'
and sap_status = 'Accepted'


if @material = ''
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Error with Material Number: Title not updated because material number was blank.'  
	return
end

--isbn precheck - confirm isbn will pass all validation before running any updates.  Since validation involves all of the
--variables needed for the update, keep all variable population together with error checking, just move update after.
if @ean13 <> ''	--not all products will have an ean/ISBN
begin
	select @ean13old = isnull(dbo.get_isbn_item (@i_bookkey, 17),'')

	if @i_update_mode = 'B' and @ean13old <> ''
		set @update = 0
	else 
		set @update = 1

	if @ean13 <> @ean13old and @update = 1	--no need to check anything if isbn already updated
	begin
		EXECUTE qean_validate_product @ean13,1,0,null,@ean output,@o_error_code output, @o_error_desc output
		IF @o_error_code <> 0
		BEGIN
			SET @o_error_desc = 'Error with ISBN13: Invalid ISBN - ' + @o_error_desc
			SET @o_error_code = -2
			return
		END

		-- qean_validate_product does not check for prefix on gentables so do it here
		set @hyphen=charindex('-',@ean)
		set @v_eanprefix = substring(@ean,1,@hyphen-1)
		set @hyphen=charindex('-',@ean,@hyphen+1)
		set @hyphen=charindex('-',@ean,@hyphen+1)
		set @v_isbnprefix=substring(@ean,1,@hyphen-1)
		set @v_isbnpostfix=substring(@ean,@hyphen+1,20)

		set @v_isbnprefix_gt=substring(@v_isbnprefix,5,15)

		SELECT @v_eanprefix_code = isnull(datacode,0)
		FROM gentables
		WHERE tableid = 138 
		AND datadesc = LTRIM(RTRIM(@v_eanprefix))
		and deletestatus <> 'Y'

		if @v_eanprefix_code is null or @v_eanprefix_code = 0
		begin
			SET @o_error_desc = 'Error with ISBN13: Unsupported EAN prefix'
			SET @o_error_code = -2
			return
		end
			
		SELECT @v_isbnprefix_code = isnull(datasubcode,0)
		FROM subgentables
		WHERE tableid = 138 
		AND datacode = @v_eanprefix_code
		AND datadesc = LTRIM(RTRIM(@v_isbnprefix_gt))
		and deletestatus <> 'Y'

		if @v_isbnprefix_code is null or @v_isbnprefix_code = 0
		begin
			SET @o_error_desc = 'Error with ISBN13: Unsupported ISBN prefix'
			SET @o_error_code = -2
			return
		end

		exec qean_ISBN_from_EAN	@ean, @isbn output, @o_error_code output, @o_error_desc output
		if @o_error_code <> 0 begin
			set @o_error_desc = 'Error with ISBN13: Problem generating ISBN10.  ' + isnull(@o_error_desc,'')
			set @o_error_code = -2
			return
		end

		set @isbn10 = replace(@isbn,'-','')

		set @gtin = '0-' + substring(@ean,1,16)
		set @gtin = @gtin + dbo.qean_checkdigit (@gtin, 2)
		set @gtin14 = replace(@gtin,'-','')
	end
end

select @Materialold = isnull(dbo.get_isbn_item (@i_bookkey, 15),'')

if @i_update_mode = 'B' and @materialold <> ''
	set @update = 0
else 
	set @update = 1

if @material <> @materialold and @update = 1
begin
	update isbn
	set itemnumber = @material,
	lastuserid = @i_userid,
	lastmaintdate = getdate()
	where bookkey = @i_bookkey

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'System Error: Unable to update material on isbn table.   Error #' + cast(@v_error as varchar(20))
		RETURN
	END 

	exec qtitle_update_titlehistory 'isbn', 'itemnumber' , @i_bookkey, 1, 0, @material, 'Update', @i_userid, 
			null, 'Material Number', @o_error_code output, @o_error_desc output
end

if @upc <> ''	--not all products will have a UPC
begin
	select @upcold = isnull(dbo.get_isbn_item (@i_bookkey, 21),'')

	if @i_update_mode = 'B' and @upcold <> ''
		set @update = 0
	else 
		set @update = 1

	if @upc <> @upcold and @update = 1
	begin
		update isbn
		set upc = @upc,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'System Error: Unable to update upc on isbn table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'isbn', 'upc' , @i_bookkey, 1, 0, @upc, 'Update', @i_userid, 
				null, 'UPC Number', @o_error_code output, @o_error_desc output
	end
end

if @ean13 <> ''	--not all products will have an ean/ISBN
begin
	select @ean13old = isnull(dbo.get_isbn_item (@i_bookkey, 17),'')

	if @i_update_mode = 'B' and @ean13old <> ''
		set @update = 0
	else 
		set @update = 1

	if @ean13 <> @ean13old and @update = 1	--no need to check anything if isbn already updated
	begin
		update isbn
		set isbn = @isbn,
		isbn10 = @isbn10,
		ean = @ean,
		ean13 = @ean13,
		eanprefixcode = @v_eanprefix_code,
		isbnprefixcode = @v_isbnprefix_code,
		gtin = @gtin,
		gtin14 = @gtin14,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'System Error:  Unable to update ISBN/EAN fields on isbn table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'isbn', 'isbn' , @i_bookkey, 1, 0, @isbn, 'Update', @i_userid, 
				null, 'ISBN', @o_error_code output, @o_error_desc output

		exec qtitle_update_titlehistory 'isbn', 'ean' , @i_bookkey, 1, 0, @ean, 'Update', @i_userid, 
				null, 'EAN', @o_error_code output, @o_error_desc output

		exec qtitle_update_titlehistory 'isbn', 'gtin' , @i_bookkey, 1, 0, @gtin, 'Update', @i_userid, 
				null, 'GTIN', @o_error_code output, @o_error_desc output
	end
END

update hmco_export_to_sap
set sap_status = 'Autostamp Success',
xart2dateprocessed = getdate(),
xart2comment = null
where bookkey = @i_bookkey
and row_id = @i_rowid

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 or @v_rowcount = 0 BEGIN 
	SET @o_error_code = -1
	SET @o_error_desc = 'System Error: Unable to update the sap_status for this bookkey.   Error #' + cast(@v_error as varchar(20))
	RETURN
END 

END

