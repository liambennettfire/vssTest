/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_miscnum]    Script Date: 02/25/2009 14:08:04 ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_miscnum]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_miscnum]SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create PROCEDURE [dbo].[hmco_import_from_SAP_miscnum] 
	@i_bookkey int, 
	@i_update_mode	char(1),
	@i_userid   varchar(30),
	@i_misckey	int,
	@i_misctype	int,
	@i_newvalue	varchar(50),
	@i_miscname	varchar(50),
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare @update int,
@v_rowcount	int,
@newvalue	int,
@existing	int,
@v_error	varchar(2000)

select @update = 1

if isnumeric(@i_newvalue) = 0
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update ' + @i_miscname + ' on bookmisc table.  Value passed is not a valid number'
	RETURN
END 

set @newvalue = cast(@i_newvalue as int)

if @i_misctype = 4
begin
	if @newvalue <> 0 and @newvalue <> 1
	begin
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update ' + @i_miscname + ' on bookmisc table.  Value passed is not 0 or 1 for the checkbox'
		RETURN
	END 
end

select @existing = isnull(longvalue,0)
from bookmisc
where misckey = @i_misckey
and bookkey = @i_bookkey

SELECT @v_rowcount = @@ROWCOUNT

if @v_rowcount = 0
	set @existing = ''

if @i_update_mode = 'B' and @existing > 0
	select @update = 0

if @update = 1 and @newvalue <> @existing
begin
--		if @newvalue = '&&&'	
--			select @newvalue = null

	if @v_rowcount = 1
	begin
		update bookmisc
		set longvalue = @newvalue,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey
		and misckey = @i_misckey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update ' + @i_miscname + ' on bookmisc table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'bookmisc', 'longvalue' , @i_bookkey, 1, 0, @newvalue, 'Update', @i_userid, 
			null, @i_miscname, @o_error_code output, @o_error_desc output
	end
	else
	begin
		insert into bookmisc
		(bookkey, misckey, longvalue, lastuserid, lastmaintdate, sendtoeloquenceind)
		values (@i_bookkey, @i_misckey, @newvalue, @i_userid, getdate(),0)

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to insert ' + @i_miscname + ' into bookmisc table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'bookmisc', 'longvalue' , @i_bookkey, 1, 0, @newvalue, 'Insert', @i_userid, 
			null, @i_miscname, @o_error_code output, @o_error_desc output
	end
end
end