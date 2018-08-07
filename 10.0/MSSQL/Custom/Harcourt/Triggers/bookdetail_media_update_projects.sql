IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[bookdetail_media_update_projects]'))
DROP TRIGGER [dbo].[bookdetail_media_update_projects]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE TRIGGER [dbo].[bookdetail_media_update_projects] ON [dbo].[bookdetail]
FOR INSERT, UPDATE AS
IF UPDATE (mediatypecode) OR
   UPDATE (mediatypesubcode)

DECLARE
  @v_bookkey  INT,
  @v_projectkey INT,
  @v_mediatypecode  INT,
  @v_mediatypesubcode  INT,
  @v_userid VARCHAR(30),
  @v_project_itemtype INT,
  @v_project_usageclass INT,
  @v_project_typedesc VARCHAR(255),
  @v_title VARCHAR(255),
  @v_newtitle VARCHAR(255),
  @v_formatdesc VARCHAR(255)

SELECT @v_bookkey = i.bookkey, @v_mediatypecode = ISNULL(i.mediatypecode,0), @v_mediatypesubcode = i.mediatypesubcode, @v_userid = lastuserid
FROM inserted i
  
-- Loop through project types related to this title's media type through the 'Auto Project Creation: Title Format to Project Class' relationship
DECLARE projecttype_cur CURSOR FOR
SELECT code2, subcode2, sp.datadesc, sm.datadesc, b.title
FROM gentablesrelationshipdetail r
JOIN book b ON b.bookkey = @v_bookkey
JOIN subgentables sm ON sm.tableid = 312 
  AND sm.datacode = r.code1 
  AND sm.datasubcode = r.subcode1
JOIN subgentables sp ON sp.tableid = 550 
  AND sp.datacode = r.code2
  AND sp.datasubcode = r.subcode2
WHERE r.gentablesrelationshipkey = 34
  AND r.code1 = @v_mediatypecode
  AND r.subcode1 = @v_mediatypesubcode

OPEN projecttype_cur
FETCH NEXT FROM projecttype_cur INTO @v_project_itemtype, @v_project_usageclass, @v_project_typedesc, @v_formatdesc, @v_title

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

  FETCH NEXT FROM projecttype_cur INTO @v_project_itemtype, @v_project_usageclass, @v_project_typedesc, @v_formatdesc, @v_title
END

CLOSE projecttype_cur
DEALLOCATE projecttype_cur

GO
