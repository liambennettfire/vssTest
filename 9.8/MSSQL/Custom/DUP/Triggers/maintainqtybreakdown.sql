SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jennifer Hurd
-- Create date: 3/17/09
-- Description:	update print qty breakdown for 'Author Comp Copies'
--	to sum of all participant's rate where rate = Comp Copies if participant's role changes
-- =============================================

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.maintainqtybreakdown') AND type = 'TR')
	DROP TRIGGER dbo.maintainqtybreakdown
GO


CREATE TRIGGER [dbo].[maintainqtybreakdown] 
   ON  [dbo].[taqprojectcontactrole]
   FOR INSERT,DELETE,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

declare @newsum	int,
@oldsum			int,
@taqprojectkey	int,
@search			int,
@usage			int,
@count			int,
@newtaqprojectkey	int,
@newsub1sum		int,
@newsub2sum		int,
@sumexistsind	tinyint

select @taqprojectkey = taqprojectkey
from inserted

if @taqprojectkey is null
begin
	select @taqprojectkey = taqprojectkey
	from deleted
end

if @taqprojectkey is null
	return

select @search = searchitemcode, @usage = usageclasscode
from taqproject
where taqprojectkey = @taqprojectkey

if isnull(@search,0) <> 6 or (isnull(@usage,0) <> 3 and isnull(@usage,0) <> 4)
	return

if @usage = 4		--change was made on the content unit, force update of issue's qty
begin
	select @newtaqprojectkey = tpi.taqprojectkey
	from taqprojectrelationship tr
	join taqproject tpcu
	on tr.taqprojectkey2 = tpcu.taqprojectkey
	and tpcu.searchitemcode = 6
	and tpcu.usageclasscode = 4
	join taqproject tpi
	on tr.taqprojectkey1 = tpi.taqprojectkey
	and tpi.searchitemcode = 6
	and tpi.usageclasscode = 3
	where tpcu.taqprojectkey = @taqprojectkey

	if @newtaqprojectkey is null
	begin
		select @newtaqprojectkey = tpi.taqprojectkey
		from taqprojectrelationship tr
		join taqproject tpcu
		on tr.taqprojectkey1 = tpcu.taqprojectkey
		and tpcu.searchitemcode = 6
		and tpcu.usageclasscode = 4
		join taqproject tpi
		on tr.taqprojectkey2 = tpi.taqprojectkey
		and tpi.searchitemcode = 6
		and tpi.usageclasscode = 3
		where tpcu.taqprojectkey = @taqprojectkey
	end

	set @taqprojectkey = @newtaqprojectkey

  if @taqprojectkey is null
	  return
end

select @newsum = sum(isnull(workrate,0))
from taqprojectcontactrole
where taqprojectkey = @taqprojectkey
and ratetypecode = 3

--IF @newsum is null return

--gather comp copies from content units beneath this issue
select @newsub1sum = sum(isnull(workrate,0))
from taqprojectrelationship tr
join taqproject tpcu		--join to the content unit on key2
on tr.taqprojectkey2 = tpcu.taqprojectkey
and tpcu.searchitemcode = 6
and tpcu.usageclasscode = 4
join taqproject tpi			--join to the issue on key1
on tr.taqprojectkey1 = tpi.taqprojectkey
and tpi.searchitemcode = 6
and tpi.usageclasscode = 3
join taqprojectcontactrole tcr
on tcr.taqprojectkey = tpcu.taqprojectkey
and tcr.ratetypecode = 3
where tpi.taqprojectkey = @taqprojectkey	--where key1 is the issue in question

select @newsub2sum = sum(isnull(workrate,0))
from taqprojectrelationship tr
join taqproject tpcu		--join to the content unit on key1, to be safe
on tr.taqprojectkey1 = tpcu.taqprojectkey
and tpcu.searchitemcode = 6
and tpcu.usageclasscode = 4
join taqproject tpi			--join to the issue on key2, to be safe
on tr.taqprojectkey2 = tpi.taqprojectkey
and tpi.searchitemcode = 6
and tpi.usageclasscode = 3
join taqprojectcontactrole tcr
on tcr.taqprojectkey = tpcu.taqprojectkey
and tcr.ratetypecode = 3
where tpi.taqprojectkey = @taqprojectkey	--where key2 is the issue in question

if @newsum is null and @newsub1sum is null and @newsub2sum is null
begin
	set @sumexistsind = 0
end
else begin
	set @sumexistsind = 1
end

select @newsum = isnull(@newsum, 0) + isnull(@newsub1sum, 0) + isnull(@newsub2sum, 0)

IF @newsum is null return

select @count = count(*)
from taqprojectqtybreakdown
where taqprojectkey = @taqprojectkey
and qtyoutletcode = 5
and qtyoutletsubcode = 1

if @count > 0
begin
	if @sumexistsind <> 0
	begin
		select @oldsum = coalesce(estqty,null)
		from taqprojectqtybreakdown
		where taqprojectkey = @taqprojectkey
		and qtyoutletcode = 5
		and qtyoutletsubcode = 1

		if @oldsum is null or @oldsum <> @newsum
		begin
			update taqprojectqtybreakdown
			set estqty = @newsum,
			lastuserid = 'contactroletrigger',
			lastmaintdate = getdate()
			where taqprojectkey = @taqprojectkey
			and qtyoutletcode = 5
			and qtyoutletsubcode = 1
		end
	end
end
else
begin
	
	insert into taqprojectqtybreakdown
	(taqprojectkey, qtyoutletcode, qtyoutletsubcode, qty, lastuserid, lastmaintdate, estqty, qtynote)
	values (@taqprojectkey, 5,1,null, 'contactroletrigger',getdate(),@newsum,null)

end

END

