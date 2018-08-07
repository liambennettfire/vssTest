BEGIN
  DECLARE @v_gpokey INT,
	  @v_datetypecode	INT,
	  @v_taqtaskkey	INT,
	  @v_taqelementkey INT,
	  @v_scheduleind INT,
	  @v_lag INT,
	  @v_sortorder INT,
	  @v_next_taqtaskkey INT,
	  @NumberRecords INT,
	  @RowCount INT,
	  @v_count int

  CREATE TABLE #taskfix (
	RowID int IDENTITY (1,1),
	datetypecode	INT,
	taqtaskkey	INT,
	taqelementkey INT,
	scheduleind INT,
	lag INT,
	sortorder INT)
	
  insert into #taskfix
  select (select datetypecode from taqprojecttask where taqprojecttask.taqtaskkey = taqprojecttaskoverride.taqtaskkey) datetypecode, 
  taqtaskkey,taqelementkey,scheduleind,lag,sortorder
  from taqprojecttaskoverride
  where taqtaskkey in (select taqtaskkey FROM taqprojecttask
                        WHERE taqelementkey IS NULL)
    and taqelementkey > 0
  order by taqtaskkey, sortorder
  
  --SELECT * from #taskfix

  SET @NumberRecords	= @@ROWCOUNT
  SET @RowCount = 1
  SET @v_taqtaskkey = 0
  
  --print '@NumberRecords'
  --print @NumberRecords

  WHILE @RowCount <= @NumberRecords BEGIN
    SELECT @v_next_taqtaskkey = taqtaskkey, @v_taqelementkey = taqelementkey, @v_scheduleind = scheduleind, 
           @v_lag = lag, @v_sortorder = sortorder
      FROM #taskfix
     WHERE ROWID = @RowCount

    IF @v_next_taqtaskkey > 0 and @v_next_taqtaskkey <> @v_taqtaskkey BEGIN
      SET @v_taqtaskkey = @v_next_taqtaskkey
      
      SELECT @v_count = count(*)
        FROM taqprojecttask
       WHERE taqtaskkey = @v_taqtaskkey
         AND coalesce(taqelementkey,0) > 0
         
      IF @v_count > 0 BEGIN
        print 'Elementkey already populated on taqprojecttask - @v_taqtaskkey: '
        print @v_taqtaskkey
      END
      ELSE BEGIN
        -- update taqprojecttask with first element info
        UPDATE taqprojecttask
           SET taqelementkey = @v_taqelementkey,
               scheduleind = @v_scheduleind,
               lag = @v_lag,
               sortorder = @v_sortorder
         WHERE taqtaskkey = @v_taqtaskkey
         
        -- remove from taqprojecttaskoverride
        DELETE FROM taqprojecttaskoverride
        WHERE taqtaskkey = @v_taqtaskkey
          and taqelementkey = @v_taqelementkey
      END      
    END

  	SET @RowCount = @RowCount + 1
  END
 
  DROP TABLE #taskfix
END
go