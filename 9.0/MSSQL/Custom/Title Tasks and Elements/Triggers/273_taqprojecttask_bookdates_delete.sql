IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'taqprojecttask_bookdates_delete')
BEGIN
  DROP  Trigger taqprojecttask_bookdates_delete
END
GO

create trigger taqprojecttask_bookdates_delete
on bookdates
for delete
as

--check if updates are not comming from bookdates trigger
if object_id( 'tempdb..#dont_fire_bookdates_delete'  ) is not null begin
	return
end

CREATE TABLE #dont_fire_taqprojecttask_delete ( DummyCol int )

declare 
  @v_bookkey int,
  @v_printingkey int,
  @v_datetypecode int

select @v_bookkey = d.bookkey,
  @v_printingkey = d.printingkey,
  @v_datetypecode = d.datetypecode
from deleted d

IF @v_bookkey is null
   RETURN

delete from taqprojecttask
where bookkey = @v_bookkey
and printingkey = @v_printingkey
and datetypecode = @v_datetypecode

go

