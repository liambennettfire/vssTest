IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.book_title_update_campaign_HMH') AND type = 'TR')
	DROP TRIGGER dbo.book_title_update_campaign_HMH
GO

CREATE TRIGGER dbo.book_title_update_campaign_HMH ON book
FOR UPDATE AS
IF UPDATE (title)

DECLARE @v_bookkey INT,
        @v_projectkey INT,
        @v_usageclass INT,
        @v_usageclass_datadesc VARCHAR(255),
        @v_usageclass_marketing INT,
        @v_usageclass_publicity INT,
        @v_userid VARCHAR(30),
        @v_title VARCHAR(255),
        @v_newtitle VARCHAR(255),
        @v_formatdesc VARCHAR(255),
        @o_errorcode INT,
        @o_errordesc VARCHAR(1000)

SELECT @v_bookkey = i.bookkey, @v_title = i.title, @v_userid = i.lastuserid
FROM inserted i

SET @v_formatdesc = ''
SELECT @v_usageclass_marketing = datasubcode FROM subgentables WHERE qsicode = 9
SELECT @v_usageclass_publicity = datasubcode FROM subgentables WHERE qsicode = 54

-- Update title of all related Projects of the selected types
DECLARE project_cur CURSOR FOR
SELECT pt.taqprojectkey, p.usageclasscode, g.datadesc
FROM taqprojecttitle pt 
  INNER JOIN taqproject p ON p.taqprojectkey = pt.taqprojectkey AND p.searchitemcode = 3 AND p.usageclasscode IN (@v_usageclass_marketing, @v_usageclass_publicity)
  INNER JOIN subgentables g ON g.tableid = 550 AND g.datacode = 3 AND g.datasubcode = p.usageclasscode
WHERE pt.bookkey = @v_bookkey

OPEN project_cur
FETCH NEXT FROM project_cur INTO @v_projectkey, @v_usageclass, @v_usageclass_datadesc

IF (@@FETCH_STATUS = 0)
BEGIN
  SELECT @v_formatdesc = g.datadesc
  FROM bookdetail d
    JOIN subgentables g ON g.tableid = 312 AND g.datacode = d.mediatypecode AND g.datasubcode = d.mediatypesubcode
  WHERE d.bookkey = @v_bookkey
END

WHILE (@@FETCH_STATUS = 0)
BEGIN
  SET @v_newtitle = @v_title + ' - ' + @v_usageclass_datadesc + ' (' + @v_formatdesc + ')'
  UPDATE taqproject SET taqprojecttitle = @v_newtitle, lastuserid = @v_userid, lastmaintdate = getdate() WHERE taqprojectkey = @v_projectkey
  
  FETCH NEXT FROM project_cur INTO @v_projectkey, @v_usageclass, @v_usageclass_datadesc
END

CLOSE project_cur
DEALLOCATE project_cur

GO
