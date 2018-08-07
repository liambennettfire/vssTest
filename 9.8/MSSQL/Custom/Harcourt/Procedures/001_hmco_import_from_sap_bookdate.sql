/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_bookdate]    Script Date: 02/25/2009 14:08:04 ******/

--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_bookdate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_bookdate]SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create PROCEDURE [dbo].[hmco_import_from_SAP_bookdate] 
	@i_bookkey int, 
	@i_printingkey int,
	@i_update_mode	char(1),
	@i_userid   varchar(30),
	@i_datetypecode	int,
	@i_newvalue	datetime,
	@i_fielddesc	varchar(30),
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare @update int,
@v_rowcount	int,
@existing	datetime,
@v_error	varchar(2000)

set @update = 1

select @existing = activedate
from bookdates
where datetypecode = @i_datetypecode
and bookkey = @i_bookkey
and printingkey = @i_printingkey

SELECT @v_rowcount = @@ROWCOUNT

if @i_update_mode = 'B' and @existing is not null
	select @update = 0

if @update = 1 
begin

	if @i_newvalue = @existing
	begin
		set @o_error_code = 0
		return
	end

	if @v_rowcount = 1
	begin
		update bookdates
		set activedate = @i_newvalue,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey
		and datetypecode = @i_datetypecode
		and printingkey = @i_printingkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update '+@i_fielddesc+' on bookdates table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'bookdates', 'activedate' , @i_bookkey, 1, 0, @i_newvalue, 'Update', @i_userid, 
			null, @i_fielddesc, @o_error_code output, @o_error_desc output
	end
	else
	begin
		insert into bookdates
		(bookkey, printingkey, datetypecode, activedate, lastuserid, lastmaintdate)
		values (@i_bookkey, @i_printingkey, @i_datetypecode, @i_newvalue, @i_userid, getdate())

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to insert '+@i_fielddesc+' into bookdates table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'bookdates', 'activedate' , @i_bookkey, 1, 0, @i_newvalue, 'Insert', @i_userid, 
			null, @i_fielddesc, @o_error_code output, @o_error_desc output
	end
end

end