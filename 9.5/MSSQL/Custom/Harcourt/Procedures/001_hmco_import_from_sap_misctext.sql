/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_misctext]    Script Date: 02/25/2009 14:08:04 ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_misctext]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_misctext]SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create PROCEDURE [dbo].[hmco_import_from_SAP_misctext] 
	@i_bookkey int, 
	@i_update_mode	char(1),
	@i_userid   varchar(30),
	@i_misckey	int,
	@i_newvalue	varchar(255),
	@i_miscname	varchar(50),
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare @update int,
@v_rowcount	int,
@existing	varchar(255),
@v_error	varchar(2000)

select @update = 1

select @existing = isnull(textvalue,'')
from bookmisc
where misckey = @i_misckey
and bookkey = @i_bookkey

SELECT @v_rowcount = @@ROWCOUNT

if @v_rowcount = 0
	set @existing = ''

if @i_update_mode = 'B' and @existing <> ''
	select @update = 0

if @update = 1 and @i_newvalue <> @existing
begin
	if @i_newvalue = '&&&'	
		select @i_newvalue = null

	if @v_rowcount = 1
	begin
		update bookmisc
		set textvalue = @i_newvalue,
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

		exec qtitle_update_titlehistory 'bookmisc', 'textvalue' , @i_bookkey, 1, 0, @i_newvalue, 'Update', @i_userid, 
			null, @i_miscname, @o_error_code output, @o_error_desc output
	end
	else
	begin
		insert into bookmisc
		(bookkey, misckey, textvalue, lastuserid, lastmaintdate, sendtoeloquenceind)
		values (@i_bookkey, @i_misckey, @i_newvalue, @i_userid, getdate(),0)

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to insert ' + @i_miscname + ' into bookmisc table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'bookmisc', 'textvalue' , @i_bookkey, 1, 0, @i_newvalue, 'Insert', @i_userid, 
			null, @i_miscname, @o_error_code output, @o_error_desc output
	end
end

end