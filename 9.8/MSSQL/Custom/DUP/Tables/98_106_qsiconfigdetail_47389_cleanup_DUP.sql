DECLARE @v_count INT, @v_configobjectkey INT, @v_configdetailkey INT

SET @v_configobjectkey = 0

SELECT @v_configobjectkey = configobjectkey FROM qsiconfigobjects WHERE configobjectid = 'ProjectReaderInfo'
SELECT @v_count = COUNT(*) FROM qsiconfigdetail WHERE configobjectkey = @v_configobjectkey AND usageclasscode = 1

-- If there are duplicate rows FOR 'ProjectReaderInfo'
IF @v_count > 1
BEGIN
  SET @v_configdetailkey = 0

  SELECT top 1 @v_configdetailkey = configdetailkey 
  FROM qsiconfigdetail 
  WHERE configobjectkey = @v_configobjectkey
     AND usageclasscode = 1 AND visibleind = 1

   -- If one of them is visible, delete the others
  IF @v_configdetailkey > 0
    DELETE FROM qsiconfigdetail WHERE configobjectkey = @v_configobjectkey AND usageclasscode = 1 AND configdetailkey <> @v_configdetailkey
END
  