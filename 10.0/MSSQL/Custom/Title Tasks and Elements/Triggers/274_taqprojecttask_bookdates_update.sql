IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'taqprojecttask_bookdates_update')
BEGIN
  DROP  Trigger taqprojecttask_bookdates_update
END
GO

CREATE TRIGGER taqprojecttask_bookdates_update
ON bookdates FOR INSERT, UPDATE 
AS
IF UPDATE (estdate) or UPDATE (activedate)
BEGIN

--this will prevent taqprojecttask trigger to fire back
CREATE TABLE #dont_fire_bookdates ( DummyCol int )

--check if updates are not comming from bookdates taqprojecttask
if object_id( 'tempdb..#dont_fire_taqprojecttask' ) is not null begin
  return
end

declare
  @v_bookkey int,
  @v_printingkey int,
  @v_datetypecode int,
  @v_activedate datetime,
  @v_actualind int,
  @v_lastuserid varchar(50),
  @v_lastmaintdate datetime,
  @v_estdate datetime,
  @v_sortorder int,
  @v_bestdate datetime,
  @v_originaldate datetime,
  @v_scmatkey int,
  @v_cnt int,
  @v_new_taqtaskkey int,
  @v_date datetime
  
select @v_bookkey = i.bookkey,
  @v_printingkey = i.printingkey,
  @v_datetypecode = i.datetypecode,
  @v_activedate = i.activedate ,
  @v_lastuserid = i.lastuserid,
  @v_lastmaintdate = i.lastmaintdate,
  @v_estdate = i.estdate,
  @v_sortorder = i.sortorder,
  @v_bestdate = i.bestdate,
  @v_scmatkey = i.scmatkey
from inserted i

if (@v_bookkey is null OR @v_printingkey is null OR @v_datetypecode is null) begin
  return
end

select @v_cnt = count(*)
from taqprojecttask
where bookkey = @v_bookkey 
and printingkey = @v_printingkey
and datetypecode = @v_datetypecode

if @v_cnt = 0 begin
  -- If bookdates.estdate is updated and there is no bookdates.activedate, 
  -- update taqprojecttask.activedate with the estdate and set taqprojecttask.actualind to 0.
  -- if taqprojecttask original date is null, update taqprojecttask.activedate with the estdate. 
  
  -- If bookdates.activedate is updated, update taqprojecttask.activedate with bookdates.activedate 
  -- and set taqprojecttask.actualind to 1. And if original date is null, update this as well.

  if @v_activedate is not null
    begin
      set @v_date = @v_activedate
      set @v_actualind = 1
    end
  else
    begin
      set @v_date = @v_estdate
      set @v_actualind = 0
    end
    
  if @v_estdate is not null
    set @v_originaldate = @v_estdate
  else
    set @v_originaldate = @v_activedate
    
  execute dbo.get_next_key 'taqprojecttask', @v_new_taqtaskkey OUT
  
  insert into taqprojecttask
    (taqtaskkey, bookkey, printingkey, datetypecode, activedate, actualind, 
    keyind, scheduleind, originaldate, lastuserid, lastmaintdate, sortorder)
  values
    (@v_new_taqtaskkey, @v_bookkey, @v_printingkey, @v_datetypecode, @v_date, @v_actualind, 
    1, 0, @v_originaldate, @v_lastuserid, @v_lastmaintdate, @v_sortorder)
end

else begin

  set @v_date = @v_estdate
  if @v_activedate is not null begin
    set @v_date = @v_activedate
    set @v_actualind = 1
  end

  update taqprojecttask
  set bookkey = @v_bookkey, printingkey = @v_printingkey, datetypecode = @v_datetypecode, 
    activedate = @v_date, actualind = @v_actualind, keyind = 1,
    lastuserid = @v_lastuserid, lastmaintdate = @v_lastmaintdate, sortorder = @v_sortorder
  where bookkey = @v_bookkey 
  and printingkey = @v_printingkey
  and datetypecode = @v_datetypecode 
end

END
go





