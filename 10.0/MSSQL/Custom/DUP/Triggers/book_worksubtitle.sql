IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.book_worksubtitle') AND type = 'TR')
	DROP TRIGGER dbo.book_worksubtitle
GO

CREATE TRIGGER book_worksubtitle ON book
FOR UPDATE AS

IF UPDATE (subtitle)
BEGIN
  DECLARE
    @v_bookkey  INT,
  	@v_name_autogen TINYINT,
    @v_primaryformatind TINYINT,
    @v_projectkey INT,
    @v_work_subtitle VARCHAR(255),
    @v_userid VARCHAR(30)

  SET @v_projectkey = 0
  SET @v_name_autogen = 0
  SET @v_primaryformatind = 0
  
  SELECT @v_bookkey = i.bookkey, @v_userid = i.lastuserid
  FROM inserted i

  IF EXISTS (
    SELECT 1
	  FROM subgentables s
      INNER JOIN book b on b.usageclasscode = s.datasubcode  
	  WHERE tableid = 550 AND qsicode = 59
      AND b.bookkey = @v_bookkey
  )
  BEGIN
    RETURN
  END
  
  SELECT @v_work_subtitle = b.subtitle, @v_projectkey = p.taqprojectkey, @v_name_autogen = p.autogeneratenameind, @v_primaryformatind = t.primaryformatind
  FROM book b 
    LEFT JOIN taqproject p ON b.workkey = p.workkey
    LEFT JOIN taqprojecttitle t ON b.bookkey = t.bookkey AND p.taqprojectkey = t.taqprojectkey
  WHERE b.bookkey=@v_bookkey 

  IF    @v_name_autogen = 1 
    AND @v_primaryformatind = 1
    AND @v_work_subtitle IS NOT NULL
    AND EXISTS (
      SELECT 1
      FROM subgentables
      WHERE tableid = 550 
        AND qsicode = 28  --Work
        AND ISNULL(alternatedesc1, '') <> ''
  )
  BEGIN
    UPDATE taqproject
    SET taqprojectsubtitle = @v_work_subtitle, lastuserid = @v_userid, lastmaintdate = getdate()
    WHERE taqprojectkey = @v_projectkey
  END
END
GO	