
/****** Object:  StoredProcedure [dbo].[dup_calc_signatures_sp]    Script Date: 10/09/2008 12:51:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dup_calc_signatures_sp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dup_calc_signatures_sp]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE procedure [dbo].[dup_calc_signatures_sp] 
(
@projectkey int,	--used to get total page count
@signature	int,	--signature size calculating for - pass 0 to return total signature pagecount
@mode		int,	
@result int OUTPUT	--variable the value is being returned in
)
as

--10/5/08	Jennifer Hurd
--@mode values
--1	calculate individual signature counts based on typeset pagecount
--2	calculate total page count for signatures based on typeset pagecount
--3	calculate natural blank pages based on typeset pagecount
--4	calculate individual signature counts based on typeset plus ad pagecount
--5	calculate total page count for signatures based on typeset plus ad pagecount
--6	calculate blank pages based on typeset plus ad pagecount
--7	calculate total page count for signatures based on revised
--8	calculate blank pages based on revised
--9	calculate best page count for printer - if print element is digital, don't calculate signatures, use typeset pages + ads
--											if not digital, use same as mode 5

Begin

declare @pagecount int,
	@counter	int,
	@count		int,
	@howmany	int,
	@remainder	int,
	@sigsize	int,
	@lastsigsize	int,
	@final			int,
	@nextsig		int,
	@origpagecount	int,
	@digitalcount	int


select @result=0

select @digitalcount = isnull(count(*),0)
from taqprojectelement te
join taqelementmisc tm
on te.taqelementkey = tm.taqelementkey
where taqelementtypecode = 20101
and taqprojectkey = @projectkey
and misckey = 295
and longvalue = 2

--if @digitalcount > 0 and @mode <> 9 begin -- Commented out due to Case 27956 
--	return
--end
--if @digitalcount = 0 and @mode = 9 begin -- Commented out due to Case 27956 
--	set @mode = 5
--end

if @mode = 9 begin   -- Case 27956
	set @mode = 5
end

if @mode = 1 or @mode = 2 or @mode = 3 begin		--just include typeset pages
	exec dup_calc_actual_total_pages_sp @projectkey,1,@result output
	select @pagecount = @result
end
else if @mode = 4 or @mode = 5 or @mode = 6 or @mode = 8 or @mode = 9 begin	--include typeset and ad pages
	exec dup_calc_actual_total_pages_sp @projectkey,2,@result output
	select @pagecount = @result
end

if @mode = 9 begin
	set @result = @pagecount
	return
end

if @mode = 1 or @mode = 2 or @mode = 3 or @mode = 4 or @mode = 5 or @mode = 6 or @mode = 9 begin
	set @origpagecount = @pagecount

	create table #tmp_signatures
	(sortorder	int	identity(1,1),
	misckey	int	not null,
	sigsize		int	null,
	numsigs		int null)

	-- 3/10/11 - KW - Removed misckey 473 (Reprint Platform - externalid=12) from the where clause (see Case 14593)
        -- 6/21/11 - KW - Removed misckey 471 (Reprint Decision) - see case 15475
	insert into #tmp_signatures
	select misckey, externalid, 0
	from bookmiscitems
	where misckey in (467, 469, 470, 472, 474, 475, 476)
	and activeind = 1
	order by cast(externalid as int) desc

	set @counter = 1

	select @sigsize = max(sigsize), @count = count(*)
	from #tmp_signatures

	while @counter <= @count 
	begin
		set @howmany = @pagecount / @sigsize
		set @remainder = @pagecount % @sigsize

		if @sigsize - @remainder = 1 begin
			set @howmany = @howmany + 1
			set @remainder = 0
			set @counter = @count
		end
		else begin
			set @counter = @counter + 1
		end

		if @howmany = 0 begin
			select @sigsize = max(sigsize)
			from #tmp_signatures
			where sigsize < @sigsize

			set @counter = @counter + 1
			
			continue
		end

		update #tmp_signatures
		set numsigs = @howmany
		where sigsize = @sigsize

		set @lastsigsize = @sigsize
		set @pagecount = @remainder

		select @sigsize = max(sigsize)
		from #tmp_signatures
		where sigsize < @sigsize

	end

	if @remainder > 0 begin
		select @final = min(sigsize)
		from #tmp_signatures
		where sigsize >= @remainder

		select @nextsig = a.sigsize
		from #tmp_signatures a
		join #tmp_signatures b
		on a.sortorder = b.sortorder - 1
		where b.sigsize = @lastsigsize

		if (@lastsigsize + @final ) >= @nextsig begin
			update #tmp_signatures
			set numsigs = numsigs - 1
			where sigsize = @lastsigsize

			update #tmp_signatures
			set numsigs = numsigs + 1
			where sigsize = @nextsig
		end
		else begin
			update #tmp_signatures
			set numsigs = numsigs + 1
			where sigsize = @final
		end
	end
end

if @mode = 7 or @mode = 8 or @mode = 9 begin
	select @result = sum(case when misckey = 152 then isnull(longvalue * 12,0) 
			when misckey = 159 then isnull(longvalue * 32 ,0)
			when misckey = 228 then isnull(longvalue * 8 ,0)
			when misckey = 254 then isnull(longvalue * 6 ,0)
			when misckey = 271 then isnull(longvalue * 40 ,0)
			when misckey = 297 then isnull(longvalue * 24 ,0)
			when misckey = 298 then isnull(longvalue * 16 ,0)
			when misckey = 436 then isnull(longvalue * 4 ,0)
			when misckey = 446 then isnull(longvalue * 20 ,0) end)
	from taqprojectmisc 
	where misckey in (159,152,298,446,297,436,271,254,228)
	and taqprojectkey = @projectkey
end

if @mode = 1 or @mode = 4 begin
	select @result= numsigs
	from #tmp_signatures
	where sigsize = @signature
end
else if @mode = 2 or @mode = 5 begin
	select @result = sum(sigsize * numsigs)
	from #tmp_signatures
end
else if @mode = 3 or @mode = 6 begin
	select @result = sum(sigsize * numsigs)
	from #tmp_signatures

	select @result = @result - @origpagecount
end
else if @mode = 8 begin
	select @result = @result - @pagecount
end
else if @mode = 9 begin
	if @result = 0 or @result is null begin
		select @result = sum(sigsize * numsigs)
		from #tmp_signatures
	end
end

end



