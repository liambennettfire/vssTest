/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_miscgent]    Script Date: 02/25/2009 14:08:04 ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_miscgent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_miscgent]SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create PROCEDURE [dbo].[hmco_import_from_SAP_miscgent] 
	@i_bookkey int, 
	@i_update_mode	char(1),
	@i_userid   varchar(30),
	@i_misckey	int,
	@i_newvalue	varchar(50),
	@i_fielddesc	varchar(50),
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare @update int,
@v_rowcount	int,
@new_code		int,
@existing	int,
@v_error	varchar(2000),
@new_value	varchar(100)

select @update = 1

select @existing = longvalue
from bookmisc
where misckey = @i_misckey
and bookkey = @i_bookkey

SELECT @v_rowcount = @@ROWCOUNT

if @i_update_mode = 'B' and @existing <> ''
	select @update = 0

if @update = 1 
begin
	if @i_newvalue = '&&&'	
	begin
		select @new_code = null
	end
	else
	begin
		select top 1 @new_code = datasubcode
		from subgentables s
		join bookmiscitems m
		on s.datacode = m.datacode
		where tableid = 525
		and misckey = @i_misckey
		and datadescshort = @i_newvalue

		if @new_code is null
		begin
			SET @o_error_code = -2
			SET @o_error_desc = 'Unable to update bookmisc table.  '+@i_fielddesc + ' value of '+@i_newvalue+' not found.'
			RETURN
		end
	end

	if @new_code = @existing
	begin
		set @o_error_code = 0
		return
	end

	if @v_rowcount = 1
	begin
		update bookmisc
		set longvalue = @new_code,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey
		and misckey = @i_misckey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update '+@i_fielddesc+' on bookmisc table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		select @new_value = dbo.get_bookmisc_gent (@i_bookkey, @i_misckey, 'D')

		exec qtitle_update_titlehistory 'bookmisc', 'longvalue' , @i_bookkey, 1, 0, @new_value, 'Update', @i_userid, 
			null, @i_fielddesc, @o_error_code output, @o_error_desc output

	end
	else
	begin
		insert into bookmisc
		(bookkey, misckey, longvalue, lastuserid, lastmaintdate, sendtoeloquenceind)
		values (@i_bookkey, @i_misckey, @new_code, @i_userid, getdate(),0)

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to insert '+@i_fielddesc+' into bookmisc table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		select @new_value = dbo.get_bookmisc_gent (@i_bookkey, @i_misckey, 'D')

		exec qtitle_update_titlehistory 'bookmisc', 'longvalue' , @i_bookkey, 1, 0, @new_value, 'Insert', @i_userid, 
			null, @i_fielddesc, @o_error_code output, @o_error_desc output

	end
end
--history

end