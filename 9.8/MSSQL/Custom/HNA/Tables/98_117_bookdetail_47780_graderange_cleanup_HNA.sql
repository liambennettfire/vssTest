DECLARE 
  @v_bookkey INT,
  @v_newvalueHigh VARCHAR(100),
  @v_newvalueLow VARCHAR(100),
  @v_oldvalueHigh VARCHAR(100),
  @v_oldvalueLow VARCHAR(100),
  @v_agelowupind INT,
  @v_agehighupind INT

SET NOCOUNT ON

DECLARE bookdetail_cur CURSOR FOR 
SELECT bookkey
FROM bookdetail
WHERE (ISNULL(agehighupind,0) = 1 AND ISNULL(gradehighupind,0) <> 1)
   OR (ISNULL(agelowupind,0) = 1 AND ISNULL(gradelowupind,0) <> 1)

OPEN bookdetail_cur
FETCH bookdetail_cur INTO @v_bookkey

WHILE @@FETCH_STATUS = 0
BEGIN
  SELECT 
    @v_newvalueHigh = map.[grade to],
    @v_newvalueLow = map.[grade from],
    @v_oldvalueHigh = bd.gradehigh,
    @v_oldvalueLow = bd.gradelow
  FROM 
    bookdetail bd
  INNER JOIN HNA_ageToGradeMapping map
    ON (CASE WHEN bd.agelowupind = 1 THEN '0' ELSE bd.agelow END) = map.[age from]
    AND (CASE WHEN bd.agehighupind = 1 THEN '99' ELSE bd.agehigh END)  = map.[age to]
  WHERE
    bd.bookKey = @v_bookkey
  AND map.[active ind] = 'Y'

  --It's possible the mapping was not active so lets check
  IF (@v_newvalueHigh IS NOT NULL AND @v_newvalueLow IS NOT NULL)
  BEGIN
    UPDATE bd 
    SET  
      bd.gradeLow = (CASE WHEN @v_newvalueLow = '0' THEN NULL ELSE @v_newvalueLow END),
      bd.gradeHigh = (CASE WHEN @v_newvalueHigh = '99' THEN NULL ELSE @v_newvalueHigh END),
      bd.gradelowupind = bd.agelowupind,
      bd.gradehighupind = bd.agehighupind
    FROM
      bookdetail bd
    WHERE 
      bd.bookkey = @v_bookkey

    IF @@error <> 0
    BEGIN
      PRINT 'Error updating bookDetail grade range: bookkey=' + cast(@v_bookkey AS VARCHAR) 
      GOTO ErrorOut
    END
  END
  FETCH bookdetail_cur INTO @v_bookkey
END

ErrorOut:
CLOSE bookdetail_cur
DEALLOCATE bookdetail_cur
