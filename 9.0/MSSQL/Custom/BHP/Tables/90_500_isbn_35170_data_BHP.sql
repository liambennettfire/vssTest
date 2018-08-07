DECLARE
	@v_bookkey INT,
	@v_isbnkey INT
	
DECLARE cur CURSOR FOR
	SELECT DISTINCT b.bookkey from book b INNER JOIN printing p ON b.bookkey = p.bookkey AND p.printingkey = 1
	INNER JOIN bookdetail bd ON b.bookkey = bd.bookkey
		WHERE b.bookkey NOT IN (SELECT distinct bookkey FROM isbn)
		
OPEN cur
	
FETCH NEXT FROM cur INTO @v_bookkey
	
WHILE @@FETCH_STATUS = 0 BEGIN
  execute get_next_key 'QSIDBA',@v_isbnkey OUTPUT
  INSERT INTO isbn
	(bookkey,isbnkey,lastuserid,lastmaintdate)
  VALUES
	(@v_bookkey,@v_isbnkey,'QSIDBA',getdate())
		
  FETCH NEXT FROM cur INTO @v_bookkey
END
	
CLOSE cur
DEALLOCATE cur

GO