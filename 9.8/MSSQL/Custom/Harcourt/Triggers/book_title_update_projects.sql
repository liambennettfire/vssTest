IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.book_title_update_projects') AND type = 'TR')
	DROP TRIGGER dbo.book_title_update_projects
GO

CREATE TRIGGER dbo.book_title_update_projects ON book
FOR UPDATE AS
IF UPDATE (title)

DECLARE @v_bookkey INT,
        @v_projectkey INT,
        @v_userid VARCHAR(30),
        @v_title VARCHAR(255),
        @v_newtitle VARCHAR(255),
        @v_formatdesc VARCHAR(255),
        @v_project_itemtype INT,
        @v_project_usageclass INT,
        @v_project_typedesc VARCHAR(255),
        @o_errorcode INT,
        @o_errordesc VARCHAR(1000)

SELECT @v_bookkey = i.bookkey, @v_title = i.title, @v_userid = i.lastuserid
FROM inserted i

SET @v_formatdesc = ''

-- Loop through project types related to this title's media type through the 'Auto Project Creation: Title Format to Project Class' relationship
DECLARE projecttype_cur CURSOR FOR
SELECT code2, subcode2, sp.datadesc, sm.datadesc
FROM bookdetail d
JOIN gentablesrelationshipdetail r ON r.gentablesrelationshipkey = 34
  AND r.code1 = d.mediatypecode
  AND r.subcode1 = d.mediatypesubcode
JOIN subgentables sp ON sp.tableid = 550 
  AND sp.datacode = code2
  AND sp.datasubcode = subcode2
JOIN subgentables sm ON sm.tableid = 312 
  AND sm.datacode = d.mediatypecode
  AND sm.datasubcode = d.mediatypesubcode
WHERE d.bookkey = @v_bookkey

OPEN projecttype_cur
FETCH NEXT FROM projecttype_cur INTO @v_project_itemtype, @v_project_usageclass, @v_project_typedesc, @v_formatdesc

WHILE (@@FETCH_STATUS = 0)
BEGIN
  -- Update title of all related Projects of this type if any
  DECLARE project_cur CURSOR FOR
  SELECT pt.taqprojectkey 
  FROM taqprojecttitle pt 
    INNER JOIN taqproject p ON p.taqprojectkey = pt.taqprojectkey 
      AND p.searchitemcode = @v_project_itemtype 
      AND p.usageclasscode = @v_project_usageclass
  WHERE pt.bookkey = @v_bookkey

  OPEN project_cur
  FETCH NEXT FROM project_cur INTO @v_projectkey 

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    SET @v_newtitle = @v_title + ' - ' +  @v_project_typedesc + ' (' + @v_formatdesc + ')'
    UPDATE taqproject SET taqprojecttitle = @v_newtitle, lastuserid = @v_userid, lastmaintdate = getdate() WHERE taqprojectkey = @v_projectkey
    
    FETCH NEXT FROM project_cur INTO @v_projectkey 
  END

  CLOSE project_cur
  DEALLOCATE project_cur
  
  FETCH NEXT FROM projecttype_cur INTO @v_project_itemtype, @v_project_usageclass, @v_project_typedesc, @v_formatdesc
END

CLOSE projecttype_cur
DEALLOCATE projecttype_cur

GO
