/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_update_task]    Script Date: 02/25/2009 14:08:04 ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_update_task]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_update_task]SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




create PROCEDURE [dbo].[hmco_import_from_SAP_update_task] 
	@i_bookkey int, 
	@i_userid   varchar(30),
	@datetypecode	int,
	@datevalue	datetime,
	@actualind	int,
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare @count	int,
@datedesc	varchar(50),
@sortorder	int,
@v_error	varchar(2000),
@v_rowcount	int

if isnull(@datetypecode,0) = 0
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update task dates.  You must populate the datetypecode.'
	RETURN
end

if @actualind is null
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update task dates.  You must populate the actualind.'
	RETURN
end

if @datevalue is null
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update task dates.  You must populate the task date.'
	RETURN
end

select @datedesc = description
from datetype
where datetypecode = @datetypecode

SELECT @v_rowcount = @@ROWCOUNT
if @v_rowcount = 0
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update task dates.  Datetypecode is invalid.'
	RETURN
end

if @actualind not in (1, 0)
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update task dates.  Actualind must be 1 for actual or 0 for estimated.'
	RETURN
end

select @count = count(*)
from bookdates
where bookkey = @i_bookkey
and datetypecode = @datetypecode

if isnull(@count,0) = 0
begin
	select @sortorder = max(isnull(sortorder,0))
	from bookdates
	where bookkey = @i_bookkey

	select @sortorder = isnull(@sortorder,0) + 1

	if @actualind = 1
	begin
		insert into bookdates
		(bookkey,printingkey,datetypecode,activedate,actualind,lastuserid,lastmaintdate,estdate,sortorder,bestdate)
		values (@i_bookkey,1,@datetypecode,@datevalue,@actualind,@i_userid,getdate(),null,@sortorder,@datevalue)

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update bookdates table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'bookdates', 'activedate' , @i_bookkey, 1, @datetypecode, @datevalue, 'Insert', @i_userid, 
				null, null, @o_error_code output, @o_error_desc output

--this is a just in case update - there shouldn't be a task for this type if the type doesn't exist on bookdates
--but if the task happens by chance, it needs to match the date on bookdates
		update task
		set actualdate = @datevalue
		from task t
		join element e
		on t.elementkey = e.elementkey
		join bookelement be
		on be.elementkey = e.elementkey
		where bookkey = @i_bookkey 
		and datetypecode = @datetypecode
		and keydateind = 1

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update task table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		if @v_rowcount > 0
			exec qtitle_update_titlehistory 'task', 'actualdate' , @i_bookkey, 1, 0, @datevalue, 'Update', @i_userid, 
					null, @datedesc, @o_error_code output, @o_error_desc output
	end
	else
	begin
		insert into bookdates
		(bookkey,printingkey,datetypecode,activedate,actualind,lastuserid,lastmaintdate,estdate,sortorder,bestdate)
		values (@i_bookkey,1,@datetypecode,null,@actualind,@i_userid,getdate(),@datevalue,@sortorder,@datevalue)

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update bookdates table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'bookdates', 'estdate' , @i_bookkey, 1, @datetypecode, @datevalue, 'Insert', @i_userid, 
				null, null, @o_error_code output, @o_error_desc output

--this is a just in case update - there shouldn't be a task for this type if the type doesn't exist on bookdates
--but if the task happens by chance, it needs to match the date on bookdates
		update task
		set estimateddate = @datevalue
		from task t
		join element e
		on t.elementkey = e.elementkey
		join bookelement be
		on be.elementkey = e.elementkey
		where bookkey = @i_bookkey 
		and datetypecode = @datetypecode
		and keydateind = 1

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update task table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		if @v_rowcount > 0
			exec qtitle_update_titlehistory 'task', 'estimateddate' , @i_bookkey, 1, 0, @datevalue, 'Update', @i_userid, 
				null, @datedesc, @o_error_code output, @o_error_desc output
	end
end
else
begin
	if @actualind = 1
	begin
		update bookdates
		set activedate = @datevalue,
		actualind = 1,
		bestdate = @datevalue
		where bookkey = @i_bookkey 
		and datetypecode = @datetypecode

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update bookdates table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'bookdates', 'activedate' , @i_bookkey, 1, @datetypecode, @datevalue, 'Update', @i_userid, 
				null, null, @o_error_code output, @o_error_desc output

		update task
		set actualdate = @datevalue
		from task t
		join element e
		on t.elementkey = e.elementkey
		join bookelement be
		on be.elementkey = e.elementkey
		where bookkey = @i_bookkey 
		and datetypecode = @datetypecode
		and keydateind = 1

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update task table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		if @v_rowcount > 0
			exec qtitle_update_titlehistory 'task', 'actualdate' , @i_bookkey, 1, 0, @datevalue, 'Update', @i_userid, 
					null, @datedesc, @o_error_code output, @o_error_desc output

	end
	else
	begin
	--first update updates estdate and bestdate with estdate value sent if existing date is not already actual
		update bookdates
		set estdate = @datevalue,
		bestdate = @datevalue
		where bookkey = @i_bookkey 
		and datetypecode = @datetypecode
		and actualind = 0

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update bookdates table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		if @v_rowcount > 0
		begin
			exec qtitle_update_titlehistory 'bookdates', 'estdate' , @i_bookkey, 1, @datetypecode, @datevalue, 'Update', @i_userid, 
				null, null, @o_error_code output, @o_error_desc output
		end
		else
		begin
	--if existing date is actual, only populate the estdate with date sent & leave bestdate alone
			update bookdates
			set estdate = @datevalue
			where bookkey = @i_bookkey 
			and datetypecode = @datetypecode

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Unable to update bookdates table.   Error #' + cast(@v_error as varchar(20))
				RETURN
			END 

			exec qtitle_update_titlehistory 'bookdates', 'estdate' , @i_bookkey, 1, @datetypecode, @datevalue, 'Update', @i_userid, 
					null, null, @o_error_code output, @o_error_desc output
		end

		update task
		set estimateddate = @datevalue
		from task t
		join element e
		on t.elementkey = e.elementkey
		join bookelement be
		on be.elementkey = e.elementkey
		where bookkey = @i_bookkey 
		and datetypecode = @datetypecode
		and keydateind = 1

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update task table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		if @v_rowcount > 0
			exec qtitle_update_titlehistory 'task', 'estimateddate' , @i_bookkey, 1, 0, @datevalue, 'Update', @i_userid, 
				null, @datedesc, @o_error_code output, @o_error_desc output

	end
end

end
