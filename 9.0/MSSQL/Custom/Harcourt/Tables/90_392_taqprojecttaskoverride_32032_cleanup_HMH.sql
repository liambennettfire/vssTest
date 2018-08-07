select * into taqprojecttaskoverride_cleanup_042215
from taqprojecttaskoverride
go

BEGIN
  DECLARE @v_gpokey INT,
	  @v_datetypecode	INT,
	  @v_taqtaskkey	INT,
	  @v_taqelementkey INT,
	  @v_scheduleind INT,
	  @v_lag INT,
	  @v_sortorder INT,
	  @NumberRecords INT,
	  @RowCount INT,
	  @v_count int

  CREATE TABLE #taskfix (
	RowID int IDENTITY (1,1),
	taqprojecttask_bookkey	INT,
	taqprojecttask_book_title varchar(2000),
	taqprojectelement_bookkey INT,
	taqprojectelement_book_title varchar(2000),
	taqprojecttask_datetype INT,
	taqprojecttask_date varchar(100),
	taqtaskkey	INT,
	taqelementkey INT)
		
  insert into #taskfix
  select tpt.bookkey,(select title from book where book.bookkey = tpt.bookkey),
         tpe.bookkey,(select title from book where book.bookkey = tpe.bookkey),
         tpt.datetypecode,(select datelabel from datetype where datetype.datetypecode = tpt.datetypecode),
         tpo.taqtaskkey,tpo.taqelementkey
   from taqprojecttaskoverride tpo,taqprojecttask tpt, taqprojectelement tpe
  where tpo.taqtaskkey = tpt.taqtaskkey
    and tpo.taqelementkey = tpe.taqelementkey
    and tpt.bookkey <> tpe.bookkey
  
  --SELECT * from #taskfix

  SET @NumberRecords	= @@ROWCOUNT
  SET @RowCount = 1
  SET @v_taqtaskkey = 0
  
  print '@NumberRecords'
  print @NumberRecords

  WHILE @RowCount <= @NumberRecords BEGIN
    SELECT @v_taqtaskkey = taqtaskkey, @v_taqelementkey = taqelementkey
      FROM #taskfix
     WHERE ROWID = @RowCount

    IF @v_taqtaskkey > 0 and @v_taqelementkey > 0 BEGIN               
      -- remove from taqprojecttaskoverride
      DELETE FROM taqprojecttaskoverride
       WHERE taqtaskkey = @v_taqtaskkey
         and taqelementkey = @v_taqelementkey
    END

  	SET @RowCount = @RowCount + 1
  END
 
  DROP TABLE #taskfix
END
go