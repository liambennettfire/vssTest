IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.hna_gradeRangeUpdate') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.hna_gradeRangeUpdate
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE hna_gradeRangeUpdate
(
  @i_backgroundProcessKey INT,
  @o_error_code INT OUTPUT,
  @o_standardmsgcode INT OUTPUT,
  @o_standardmsgsubcode INT OUTPUT,
  @o_error_desc VARCHAR(MAX) OUTPUT
)
AS 

/****************************************************************************************************************************
**  Name: hna_gradeRangeUpdate
**  Desc: HNA enters age range information manual via Title Management. They would like a process that automatically updates 
**       grade range based on a predetermined age range to grade range mapping table.  This procedure is called when the 
**      qutl_processbackgroundjobs runs and finds a row on  the backgroundprocess table.
**
**  Auth: Josh G
**  Date: 27 April 2017
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**   09/27/2017    Kusum           Changed the return code to 0 from -1 when data is not overwritten by this procedure
**   10/13/2017    Colman          47780 - Handle UP from and UP to age ranges
**   02/06/2018    Colman          49285 - Ignore empty age data
*****************************************************************************************************************************/
DECLARE
  @v_bookkey INT,
  @v_RowCount INT,
  @v_columnkeyHigh INT,
  @v_columnkeyLow INT,
  @v_printingkey INT,
  @v_otherinfo VARCHAR(20),
  @v_newvalueHigh VARCHAR(100),
  @v_newvalueLow VARCHAR(100),
  @v_oldvalueHigh VARCHAR(100),
  @v_oldvalueLow VARCHAR(100),
  @v_agelowupind INT,
  @v_agehighupind INT,
  @v_triggereloind TINYINT,
  @v_updateFlag INT,
  @v_lastUserID VARCHAR(30),
  @v_mostRecentUpdUser VARCHAR(30),
  @v_cantOverWriteUserData INT
BEGIN

  SET @v_lastUserID = 'GradeRangeProcess'
  SET @v_updateFlag = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SET @v_bookkey = (SELECT bp.key1 FROM dbo.backgroundprocess bp WHERE bp.backgroundprocesskey = @i_backgroundProcessKey)
  SET @v_columnkeyHigh = (SELECT t.columnKey FROM titlehistorycolumns t WHERE t.tablename = 'bookdetail' AND t.columndescription = 'Grade High')
  SET @v_columnkeyLow = (SELECT t.columnKey FROM titlehistorycolumns t WHERE t.tablename = 'bookdetail' AND t.columndescription = 'Grade Low')

  --Update if the current values are null or blank
  IF EXISTS(SELECT 1 FROM bookdetail bd WHERE bd.bookkey = @v_bookkey
        AND NULLIF(bd.gradeLow,'') IS NULL 
        AND NULLIF(bd.gradeHigh,'') IS NULL)
  BEGIN
    SET @v_updateFlag = 1
  END
  ELSE 
  BEGIN
    --Update if the most recent change to the two columns was made by this process!
    ;WITH CTE_mostRecentChange 
    AS
    (
      SELECT t.bookKey,t.lastuserid,ROW_NUMBER() OVER(PARTITION BY t.bookkey ORDER BY t.lastmaintdate DESC) rnk
      FROM titlehistory t
      WHERE t.bookkey = @v_bookkey
      AND t.columnkey IN (@v_columnkeyHigh, @v_columnkeyLow)
    )
    SELECT @v_mostRecentUpdUser = ct.lastuserid
    FROM CTE_mostRecentChange ct
    WHERE rnk = 1

    IF @v_mostRecentUpdUser = @v_lastUserID
    BEGIN
      SET @v_updateFlag = 1 
    END
    ELSE
    BEGIN
      SET @v_updateFlag = 0
      --SET @v_cantOverWriteUserData = 1
    END
  END
  --If we are allowed to update and there is age data of some kind, lets do it..
  IF @v_updateFlag = 1 
    AND EXISTS (
      SELECT 1 
      FROM bookdetail
      WHERE bookkey = @v_bookkey
        AND (ISNULL(agelow, 0) > 0
        OR ISNULL(agehigh, 0) > 0
        OR ISNULL(agelowupind, 0) > 0 
        OR ISNULL(agehighupind, 0) > 0)
    )
  BEGIN
    --Store all of these so we can use them in title history
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

    --Its possible the mapping was not active so lets check
    IF (@v_newvalueHigh IS NOT NULL AND @v_newvalueLow IS NOT NULL)
    BEGIN
      UPDATE 
        bd 
      SET  
        bd.gradeLow = (CASE WHEN @v_newvalueLow = '0' THEN NULL ELSE @v_newvalueLow END),
        bd.gradeHigh = (CASE WHEN @v_newvalueHigh = '99' THEN NULL ELSE @v_newvalueHigh END),
        bd.gradelowupind = bd.agelowupind,
        bd.gradehighupind = bd.agehighupind
      FROM
        bookdetail bd
      WHERE 
        bd.bookkey = @v_bookkey

      SELECT @o_error_code = @@error, @v_RowCount = @@rowcount

      IF @o_error_code <> 0
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Error updating bookDetail grade range (' + cast(@o_error_code AS VARCHAR) + '): bookkey=' + cast(@v_bookkey AS VARCHAR) 
        RETURN 
      END

      --Load TitleHistory
      EXEC dbo.qtitle_update_titlehistory 'bookdetail','Gradelow',@v_bookkey,1,NULL,@v_newvalueLow,'update',@v_lastUserID,1,'',@o_error_code OUTPUT, @o_error_desc OUTPUT
      IF @o_error_code <> 0
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Error updating title history (' + cast(@o_error_code AS VARCHAR) + '): bookkey=' + cast(@v_bookkey AS VARCHAR) 
        RETURN 
      END

      EXEC dbo.qtitle_update_titlehistory 'bookdetail','GradeHigh',@v_bookkey,1,NULL,@v_newvalueHigh,'update',@v_lastUserID,1,'',@o_error_code OUTPUT, @o_error_desc OUTPUT
      IF @o_error_code <> 0
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Error updating title history (' + cast(@o_error_code AS VARCHAR) + '): bookkey=' + cast(@v_bookkey AS VARCHAR) 
        RETURN 
      END

    END
    --No mapping found
    ELSE
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'No age range match: bookkey=' + cast(@v_bookkey AS VARCHAR) 
      RETURN 
    END
  END
  --ELSE 
  --BEGIN
  --  IF @v_cantOverWriteUserData = 1
  --  BEGIN
  --    SET @o_error_code = 0
  --    SET @o_error_desc = 'Grade range cannot be updated because user entered data exists (' + cast(@o_error_code AS VARCHAR) + '): bookkey=' + cast(@v_bookkey AS VARCHAR) 
  --  --RETURN 
  --  END
  --END

  SET @o_error_code = 0
  SET @o_error_desc = 'Success!(' + cast(@o_error_code AS VARCHAR) + '): bookkey=' + cast(@v_bookkey AS VARCHAR) 
END
GO

GRANT EXEC ON dbo.hna_gradeRangeUpdate TO PUBLIC
GO

