IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'bookdate_taqprojecttask_delete')
BEGIN
  DROP  Trigger bookdate_taqprojecttask_delete
END
GO

CREATE TRIGGER bookdate_taqprojecttask_delete
ON taqprojecttask FOR DELETE
AS

--check if updates are not comming from bookdates trigger
if object_id( 'tempdb..#dont_fire_taqprojecttask_delete'  ) is not null begin
	return
end

CREATE TABLE #dont_fire_bookdates_delete ( DummyCol int )

declare 
  @v_bookkey int,
  @v_printingkey int,
  @v_datetypecode int,
  @v_cnt int,
  @v_count  int,
  @v_errcode int,
  @v_errdesc varchar(2000),
  @v_activedate datetime,
  @v_estdate datetime,
  @v_keyind int,
  @v_lastuserid  VARCHAR(30),
  @v_taqtaskkey int

  select @v_bookkey = d.bookkey,
    @v_printingkey = COALESCE(d.printingkey,0),
    @v_datetypecode = d.datetypecode,
    @v_keyind = d.keyind,
    @v_taqtaskkey = d.taqtaskkey
  from deleted d

  if @v_printingkey <= 0 begin
    SET @v_printingkey = 1
  end

	select @v_cnt = count(*)
	from bookdates
	where bookkey = @v_bookkey 
	and printingkey = @v_printingkey
	and datetypecode = @v_datetypecode
	
  IF OBJECT_ID('tempdb..#deletetaqprojecttask') IS NOT NULL  BEGIN
    SELECT @v_lastuserid = lastuserid FROM #deletetaqprojecttask WHERE taqtaskkey = @v_taqtaskkey
  END
	
  IF @v_lastuserid IS NULL OR ltrim(rtrim(@v_lastuserid)) = '' BEGIN
	SET @v_lastuserid = 'TASKDELETETRIGGER'
  END

  -- if we are deleting the key task, delete teh bookdates row
  if @v_cnt > 0 and @v_keyind = 1 begin
    SELECT @v_count = 0

    SELECT @v_count = count(*)
      FROM gentablesitemtype
     WHERE tableid = 323
       AND datacode = @v_datetypecode
       AND itemtypecode = 1   --Title
       AND relateddatacode = 2   --Only 1 Task Allowed

    IF @v_count = 1 BEGIN

      select @v_estdate = estdate, @v_activedate = activedate
	    from bookdates
	    where bookkey = @v_bookkey 
	    and printingkey = @v_printingkey
	    and datetypecode = @v_datetypecode
  	   
      delete from bookdates
      where bookkey = @v_bookkey
      and printingkey = @v_printingkey
      and datetypecode = @v_datetypecode

      if @v_estdate is not null begin
        EXEC qtitle_update_titlehistory 'bookdates', 'estdate', @v_bookkey, 
          @v_printingkey, @v_datetypecode, '', 'delete', @v_lastuserid, 
          0, '', @v_errcode OUTPUT, @v_errdesc OUTPUT	
      end
      if @v_activedate is not null begin
        EXEC qtitle_update_titlehistory 'bookdates', 'activedate', @v_bookkey, 
          @v_printingkey, @v_datetypecode, '', 'delete', @v_lastuserid, 
          0, '', @v_errcode OUTPUT, @v_errdesc OUTPUT	
      end
    END
  end

go

