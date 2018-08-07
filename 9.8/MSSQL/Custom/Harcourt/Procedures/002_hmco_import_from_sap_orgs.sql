/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_orgs]    Script Date: 02/25/2009 14:08:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





alter PROCEDURE [dbo].[hmco_import_from_SAP_orgs] 
	@i_bookkey int, 
	@i_userid   varchar(30),
	@i_orglevelkey	int,
	@i_newvalue	varchar(50),
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare @update int,
@v_rowcount	int,
@new_code		int,
@v_error	varchar(2000),
@orglevel	varchar(50),
@orgentry	varchar(50)

select @update = 1

if @update = 1
begin
	select @new_code = orgentrykey
	from orgentry 
	where orglevelkey = @i_orglevelkey
	and altdesc1 = @i_newvalue

	if @new_code is null
	begin
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update bookorgentry table.  Level '+convert(char(2),@i_orglevelkey) + ' value of '+@i_newvalue+' not found.'
		RETURN
	end

	update bookorgentry
	set orgentrykey = @new_code,
	lastuserid = @i_userid,
	lastmaintdate = getdate()
	where bookkey = @i_bookkey
	and orglevelkey = @i_orglevelkey
	and orgentrykey <> @new_code

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to update Level '+convert(char(2),@i_orglevelkey) + ' on bookorgentry table.   Error #' + cast(@v_error as varchar(20))
		RETURN
	END 

	IF @v_rowcount = 0 BEGIN
		SET @o_error_code = 0
		RETURN
	END 

	select @orglevel = orgleveldesc
	from orglevel
	where orglevelkey = @i_orglevelkey

	select @orgentry = o.orgentrydesc
	from bookorgentry b
	join orgentry o
	on b.orgentrykey = o.orgentrykey
	where bookkey = @i_bookkey
	and b.orglevelkey = @i_orglevelkey

	exec qtitle_update_titlehistory 'bookorgentry', 'orgentrykey' , @i_bookkey, 1, 0, @orgentry, 'Update', @i_userid, 
		null, @orglevel, @o_error_code output, @o_error_desc output

end

end