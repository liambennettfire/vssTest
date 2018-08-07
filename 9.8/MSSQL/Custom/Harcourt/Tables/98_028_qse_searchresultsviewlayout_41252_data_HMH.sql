DECLARE @v_viewkey INT, @v_name_columnorder INT, @v_keyrelationship_columnorder INT, @v_mktg_project_code INT

SELECT @v_mktg_project_code = datasubcode FROM subgentables WHERE tableid=550 AND qsicode=3

-- loop through Project search views defined FOR marketing projects specifically or all project usage classes
DECLARE resultsview_cur CURSOR FOR
SELECT resultsviewkey FROM qse_searchresultsview WHERE searchtypecode=7 AND itemtypecode = 3 AND usageclasscode IN (0, @v_mktg_project_code)

OPEN resultsview_cur
FETCH resultsview_cur INTO @v_viewkey
WHILE (@@FETCH_STATUS = 0)
BEGIN
  IF NOT EXISTS (SELECT * FROM qse_searchresultsviewlayout WHERE resultsviewkey = @v_viewkey AND columnnumber = 13)
  BEGIN
    INSERT INTO qse_searchresultsviewlayout (resultsviewkey, columnnumber, columnorder, columnwidth, lastuserid, lastmaintdate)
    VALUES (@v_viewkey, 13, 0, NULL, 'qsidba', getdate())
  END
  
  IF NOT EXISTS (SELECT * FROM qse_searchresultsviewlayout WHERE resultsviewkey = @v_viewkey AND columnnumber = 14)
  BEGIN
    -- INSERT column after project name column
    SELECT @v_name_columnorder = columnorder FROM qse_searchresultsviewlayout WHERE resultsviewkey = @v_viewkey AND columnnumber=3

    -- move following columns over one place IF necessary
    IF EXISTS (SELECT * FROM qse_searchresultsviewlayout WHERE resultsviewkey = @v_viewkey AND columnorder = @v_name_columnorder + 1)
      UPDATE qse_searchresultsviewlayout SET columnorder = columnorder + 1 WHERE resultsviewkey = @v_viewkey AND columnorder > @v_name_columnorder
    
    SET @v_keyrelationship_columnorder = @v_name_columnorder + 1

    INSERT INTO qse_searchresultsviewlayout (resultsviewkey, columnnumber, columnorder, columnwidth, lastuserid, lastmaintdate)
    VALUES (@v_viewkey, 14, @v_keyrelationship_columnorder, NULL, 'qsidba', getdate())
  END
  FETCH resultsview_cur INTO @v_viewkey
END
CLOSE resultsview_cur
DEALLOCATE resultsview_cur