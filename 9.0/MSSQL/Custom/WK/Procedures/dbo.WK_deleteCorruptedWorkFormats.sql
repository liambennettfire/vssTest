-- Case 37562

DECLARE @v_taqprojectkey int, @v_count int, @error_code int, @error_desc varchar(2000)

DECLARE tpt_cur CURSOR FOR 
SELECT DISTINCT taqprojectkey FROM taqprojecttitle
WHERE taqprojectkey in (SELECT taqprojectkey FROM taqproject WHERE searchitemcode = 9)
and projectrolecode = 4 --work
and titlerolecode = 1 -- title
and bookkey is null

OPEN tpt_cur

FETCH tpt_cur INTO @v_taqprojectkey
WHILE (@@FETCH_STATUS=0)
BEGIN
  DELETE FROM taqprojecttitle 
  WHERE taqprojectkey=@v_taqprojectkey
  and projectrolecode = 4 --work
  and titlerolecode = 1 -- title
  and bookkey is null

  SELECT @v_count=COUNT(*) FROM taqprojecttitle
  WHERE taqprojectkey = @v_taqprojectkey
  and projectrolecode = 4 --work

  IF @v_count = 0
    EXEC qproject_delete_project @v_taqprojectkey, 0, @error_code output, @error_desc output

  FETCH tpt_cur INTO @v_taqprojectkey
END

CLOSE tpt_cur
DEALLOCATE tpt_cur

