SET NOCOUNT ON

DECLARE
  @v_bookkey  INT,
  @v_printingkey  INT,
  @v_searchfield VARCHAR(2000)
  
BEGIN

	DECLARE cur_coretitle CURSOR FOR
	SELECT bookkey, printingkey
	FROM coretitleinfo 
	FOR READ ONLY
  
	OPEN cur_coretitle

	FETCH NEXT FROM cur_coretitle INTO @v_bookkey, @v_printingkey
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		/* Get searchfield data*/
		exec dbo.qtitle_get_coretitleinfo_searchfield @v_bookkey, @v_searchfield OUTPUT

		UPDATE coretitleinfo
		SET searchfield = @v_searchfield
		WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

		FETCH NEXT FROM cur_coretitle INTO @v_bookkey, @v_printingkey
	END

	CLOSE cur_coretitle 
	DEALLOCATE cur_coretitle

END
go