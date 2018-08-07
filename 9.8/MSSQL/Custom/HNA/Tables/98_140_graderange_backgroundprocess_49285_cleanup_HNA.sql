SET NOCOUNT ON

declare 
  @v_newkey int, 
  @v_bookkey int,
  @o_error_code int, 
  @o_error_desc varchar(max)

UPDATE backgroundprocess_history
SET numofattempts = 1
WHERE failgetprodind = 1

DECLARE process_cur CURSOR FOR
  SELECT DISTINCT key1 FROM backgroundprocess_history
  WHERE failgetprodind=1

OPEN process_cur
FETCH process_cur INTO @v_bookkey

WHILE @@FETCH_STATUS = 0
BEGIN
  execute get_next_key 'qsiadmin', @v_newkey OUTPUT

  INSERT INTO backgroundprocess
    (backgroundprocesskey, jobtypecode, storedprocname, reqforgetprodind, processingind, numofattempts, key1, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 27, 'dbo.hna_gradeRangeUpdate', 1, 0, 1, @v_bookkey, 'qsiadmin', getdate())

  FETCH process_cur INTO @v_bookkey
END

CLOSE process_cur
DEALLOCATE process_cur

EXEC qutl_processbackgroundjobs NULL, 2147483647, NULL, @o_error_code out, @o_error_desc out

IF @o_error_code <> 0
  PRINT @o_error_desc
