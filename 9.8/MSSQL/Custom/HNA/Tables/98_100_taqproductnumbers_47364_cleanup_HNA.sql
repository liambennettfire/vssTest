-- Delete duplicate taqproductnumbers rows. A project should only have one.
DECLARE @v_taqprojectkey INT,
        @v_prev_projectkey INT,
         @v_productnumberkey  INT,
         @v_productnumber VARCHAR(50)

IF EXISTS (
  SELECT taqprojectkey, productnumberkey, productnumber 
  FROM taqproductnumbers 
    WHERE taqprojectkey IN (
    SELECT taqprojectkey
    FROM taqproductnumbers 
    WHERE productidcode = 9
      AND lastuserid = 'work_import'
    GROUP BY taqprojectkey having COUNT(productnumber) > 1
  )
)
BEGIN
  CREATE TABLE #temp_table 
  (taqprojectkey    INT  NOT NULL,
   productnumberkey  INT   NULL,
   productnumber      VARCHAR(50)  NULL)

  INSERT INTO #temp_table
  SELECT taqprojectkey, productnumberkey, productnumber
  FROM taqproductnumbers 
    WHERE taqprojectkey IN (
    SELECT taqprojectkey
    FROM taqproductnumbers 
    WHERE productidcode = 9
      AND lastuserid = 'work_import'
    GROUP BY taqprojectkey having COUNT(productnumber) > 1
  )

  SET @v_prev_projectkey = 0

  DECLARE prodnum_cur CURSOR FOR
  SELECT taqprojectkey, productnumberkey, productnumber 
  FROM #temp_table
  ORDER BY taqprojectkey, productnumberkey DESC

  OPEN prodnum_cur

  FETCH prodnum_cur INTO @v_taqprojectkey, @v_productnumberkey, @v_productnumber

  WHILE @@FETCH_STATUS = 0
  BEGIN
    -- keep the one with the greatest productnumberkey (newest)
    IF @v_taqprojectkey = @v_prev_projectkey
      DELETE FROM taqproductnumbers WHERE productnumberkey = @v_productnumberkey
    ELSE
      SET @v_prev_projectkey = @v_taqprojectkey

    FETCH prodnum_cur INTO @v_taqprojectkey, @v_productnumberkey, @v_productnumber
  END
  
  CLOSE prodnum_cur
  DEALLOCATE prodnum_cur

  DROP TABLE #temp_table

END
