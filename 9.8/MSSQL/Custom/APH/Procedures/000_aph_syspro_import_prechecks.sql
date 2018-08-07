IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_syspro_import_prechecks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[aph_syspro_import_prechecks]
/****** Object:  StoredProcedure [dbo].[aph_syspro_import_prechecks]    Script Date: 08/25/2008 16:44:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[aph_syspro_import_prechecks] AS

declare		@error_var		int,
			@rowcount_var	int,
			@minitem		varchar(30),
			@counter		int,
			@numitems		int,
			@minid			int,
			@error_code		int,
			@title			varchar(500),
			@error_desc		varchar(255),
			@qsibatchkey	int,
			@qsijobkey		int


BEGIN 

set @qsibatchkey = null
set @qsijobkey = null

exec write_qsijobmessage @qsibatchkey output, @qsijobkey output, 3,2,null,null,'QSIADMIN',0,0,0,1,'job started','started',@error_code output, @error_desc output

select @minid = min(id_num), @numitems = count(*)
from aph_syspro_import
where stockcode = ''
or stockcode is null

set @counter = 1

while @counter <= @numitems
begin
	select @title = isnull(description,'*Blank Title*')
	from aph_syspro_import
	where id_num = @minid

	SET @error_code = 1
	SET @error_desc = 'Blank stockcode sent from Syspro for title '+ @title + '.  No updates or inserts done for this title.'
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,2,null,null,'QSIADMIN',0,0,0,2,@error_desc,null,@error_code output, @error_desc output

	delete from aph_syspro_import
	where id_num = @minid

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @error_code = -1
		SET @error_desc = 'Unable to delete from aph_syspro_import table.  Title: '+ @title + '.  Error #' + cast(@error_var as varchar(20))
		exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,2,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
		RETURN
	END 

	set @counter = @counter + 1

	select @minid = min(id_num)
	from aph_syspro_import
	where stockcode = ''
	or stockcode is null
	and id_num > @minid

end

set @numitems = 0

select @minitem = min(stockcode), @numitems = count(distinct stockcode)
from aph_syspro_import
where stockcode in (select stockcode
					from aph_syspro_import
					group by stockcode
					having count(*) > 1)

set @counter = 1

while @counter <= @numitems
begin

	SET @error_code = 1
	SET @error_desc = 'Duplicate records sent from Syspro for stockcode '+ @minitem + '.  No updates or inserts done for this stockcode.'
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,2,null,null,'QSIADMIN',0,0,0,2,@error_desc,null,@error_code output, @error_desc output

	delete from aph_syspro_import
	where stockcode = @minitem

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @error_code = -1
		SET @error_desc = 'Unable to delete from aph_syspro_import table.  Stockcode ' + @minitem + '.  Error #' + cast(@error_var as varchar(20))
		exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,2,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
		RETURN
	END 

	set @counter = @counter + 1

	select @minitem = min(stockcode)
	from aph_syspro_import
	where stockcode in (select stockcode
						from aph_syspro_import
						group by stockcode
						having count(*) > 1)
	and stockcode > @minitem

end

exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,2,null,null,'QSIADMIN',0,0,0,6,'job completed','completed',@error_code output, @error_desc output

end

