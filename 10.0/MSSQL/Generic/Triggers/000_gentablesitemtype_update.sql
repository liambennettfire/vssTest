IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.gentablesitemtype_del') AND type = 'TR')
  DROP TRIGGER dbo.gentablesitemtype_del
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.gentablesitemtype_update') AND type = 'TR')
  DROP TRIGGER dbo.gentablesitemtype_update
GO

CREATE TRIGGER gentablesitemtype_update ON gentablesitemtype
FOR INSERT, UPDATE, DELETE
AS

DECLARE 
  @v_tableid INT,
  @v_tabtypecode INT,
  @v_tabgroupcode INT,
  @v_itemtypecode INT,
  @v_itemtypesubcode INT,
  @v_windowviewkey INT,
  @v_viewname VARCHAR(255),
  @v_defaultind INT,
  @v_itemtypedesc VARCHAR(255),
  @v_configobjectid VARCHAR(255),
  @v_configobjectkey INT,
  @v_configdetailkey INT,
  @v_relationshiptabconfigkey INT,
  @v_userid VARCHAR(30),
  @v_action CHAR(1)

/******************************************************************************************
**  Name: gentablesitemtype_update  
**  Desc: If item type filtering is removed for a particular Web Relationship Tab, 
**        remove it from all window views of that item type. If views are missing tabs that
**        should be available by item type, add them.
**  Case: 48944
**  Auth: Colman
**  Date: 01/22/2018
********************************************************************************************
**  Change History
********************************************************************************************
**  Date:         Author:        Description:
**  --------      --------       -----------------------------------------------------------
**    
********************************************************************************************/



SET @v_action = 'I'; -- Set Action to Insert by default.
IF EXISTS(SELECT 1 FROM deleted)
BEGIN
  SET @v_action = 
    CASE
      WHEN EXISTS(SELECT 1 FROM INSERTED) THEN 'U' -- Set Action to Updated.
      ELSE 'D' -- Set Action to Deleted.       
    END
END
ELSE 
    IF NOT EXISTS(SELECT 1 FROM inserted) RETURN; -- Nothing updated or inserted.

IF @v_action IN ('D', 'U')
BEGIN
  SELECT @v_tableid = d.tableid, @v_tabtypecode = d.datacode, @v_itemtypecode = d.itemtypecode, @v_itemtypesubcode = d.itemtypesubcode, @v_tabgroupcode = d.relateddatacode, @v_itemtypedesc = g.datadesc
  FROM deleted d
    JOIN gentables g ON g.tableid = 550 AND g.datacode = d.itemtypecode

  IF @v_tableid IN (440, 583) -- TitleRelationshiptab, WebRelationshipTab
  BEGIN
    IF @v_tableid = 440
      SET @v_configobjectid = 'TitleRelationshipsTabGroup1'
    ELSE
      SET @v_configobjectid = @v_itemtypedesc + 'Tabgroup' + CONVERT(VARCHAR, @v_tabgroupcode)
      
    SELECT @v_configobjectkey = configobjectkey FROM qsiconfigobjects WHERE configobjectid = @v_configobjectid

    --exec qutl_trace 'gentablesitemtype_update (DEL)',
    --  '@v_action', null, @v_action,
    --  '@v_configobjectid', NULL, @v_configobjectid,
    --  '@v_configobjectkey', @v_configobjectkey, NULL,
    --  '@v_tabtypecode', @v_tabtypecode, NULL,
    --  '@v_itemtypecode', @v_itemtypecode, NULL,
    --  '@v_itemtypesubcode', @v_itemtypesubcode, NULL

    IF @v_tableid = 440 
      DELETE FROM titlerelationshiptabconfig
      WHERE relationshiptabcode = @v_tabtypecode
        AND itemtypecode = @v_itemtypecode
        AND usageclass = @v_itemtypesubcode
    ELSE IF @v_tableid = 583
      DELETE FROM taqrelationshiptabconfig
      WHERE relationshiptabcode = @v_tabtypecode
        AND itemtypecode = @v_itemtypecode
        AND usageclass = @v_itemtypesubcode
    
    -- For each summary window view of this item type/class, delete any member tabs of this type from the applicable tab group
    DECLARE view_cur CURSOR FOR
      SELECT qsiwindowviewkey, qsiwindowviewname, defaultind
      FROM qsiwindowview 
      WHERE itemtypecode = @v_itemtypecode
        AND 
        (
          (
            usageclasscode = @v_itemtypesubcode
            AND NOT EXISTS (                  -- If there is a usageclass 0 row, the tab is still ok
              SELECT itemtypesubcode 
              FROM gentablesitemtype 
              WHERE tableid=@v_tableid
                AND datacode=@v_tabtypecode 
                AND itemtypecode=@v_itemtypecode 
                AND itemtypesubcode = 0)
          )
          -- If the usage class is 0 it means all classes except those that are specifically listed
          OR (@v_itemtypesubcode = 0 
             AND usageclasscode NOT IN ( 
              SELECT itemtypesubcode 
              FROM gentablesitemtype 
              WHERE tableid=@v_tableid
                AND datacode=@v_tabtypecode 
                AND itemtypecode=@v_itemtypecode 
                AND itemtypesubcode <> 0)
          )
        )
      ORDER BY defaultind DESC

    OPEN view_cur
    FETCH view_cur
    INTO @v_windowviewkey, @v_viewname, @v_defaultind

    WHILE @@FETCH_STATUS = 0
    BEGIN

      --exec qutl_trace 'gentablesitemtype_update (DEL)',
      --  '@v_viewname', NULL, @v_viewname,
      --  '@v_windowviewkey', @v_windowviewkey, NULL,
      --  '@v_defaultind', @v_defaultind, NULL

      DELETE FROM qsiconfigdetailtabs 
      WHERE configdetailkey IN (
        SELECT configdetailkey 
        FROM qsiconfigdetail 
        WHERE qsiwindowviewkey = @v_windowviewkey
          AND configobjectkey = @v_configobjectkey
          AND relationshiptabcode = @v_tabtypecode)

      FETCH view_cur
      INTO @v_windowviewkey, @v_viewname, @v_defaultind
    END

    CLOSE view_cur
    DEALLOCATE view_cur
  END
END

IF @v_action IN ('I', 'U')
BEGIN
  SELECT @v_tableid = i.tableid, @v_tabtypecode = i.datacode, @v_itemtypecode = i.itemtypecode, @v_itemtypesubcode = i.itemtypesubcode, @v_tabgroupcode = i.relateddatacode, @v_userid = i.lastuserid, @v_itemtypedesc = g.datadesc
  FROM inserted i 
    JOIN gentables g ON g.tableid = 550 AND g.datacode = i.itemtypecode

  IF @v_tableid IN (440, 583)
  BEGIN
    IF @v_tableid = 440
      SET @v_configobjectid = 'TitleRelationshipsTabGroup1'
    ELSE
      SET @v_configobjectid = @v_itemtypedesc + 'Tabgroup' + CONVERT(VARCHAR, @v_tabgroupcode)
      
    SELECT @v_configobjectkey = configobjectkey FROM qsiconfigobjects WHERE configobjectid = @v_configobjectid

    --exec qutl_trace 'gentablesitemtype_update',
    --  '@v_action', null, @v_action,
    --  '@v_configobjectid', NULL, @v_configobjectid,
    --  '@v_configobjectkey', @v_configobjectkey, NULL,
    --  '@v_tabtypecode', @v_tabtypecode, NULL,
    --  '@v_itemtypecode', @v_itemtypecode, NULL,
    --  '@v_itemtypesubcode', @v_itemtypesubcode, NULL

    IF @v_tableid = 440 AND NOT EXISTS (
      SELECT 1 FROM titlerelationshiptabconfig
      WHERE relationshiptabcode = @v_tabtypecode
        AND itemtypecode = @v_itemtypecode
        AND usageclass IN (@v_itemtypesubcode, 0)
    )
    BEGIN
      EXEC dbo.get_next_key @v_userid, @v_relationshiptabconfigkey OUT

      INSERT INTO titlerelationshiptabconfig
        (titlerelationshiptabconfigkey, relationshiptabcode, itemtypecode, usageclass)
      VALUES
        (@v_relationshiptabconfigkey, @v_tabtypecode, @v_itemtypecode, @v_itemtypesubcode)
    END

    IF @v_tableid = 583 AND NOT EXISTS (
      SELECT 1 FROM taqrelationshiptabconfig
      WHERE relationshiptabcode = @v_tabtypecode
        AND itemtypecode = @v_itemtypecode
        AND usageclass IN (@v_itemtypesubcode, 0)
    )
    BEGIN
      EXEC dbo.get_next_key @v_userid, @v_relationshiptabconfigkey OUT

      INSERT INTO taqrelationshiptabconfig
        (taqrelationshiptabconfigkey, relationshiptabcode, itemtypecode, usageclass, alloweditablefieldsind)
      VALUES
        (@v_relationshiptabconfigkey, @v_tabtypecode, @v_itemtypecode, @v_itemtypesubcode, 1)
    END

    -- For each summary window view of this item type/class
    DECLARE view_cur CURSOR FOR
      SELECT qsiwindowviewkey, qsiwindowviewname, defaultind
      FROM qsiwindowview 
      WHERE itemtypecode = @v_itemtypecode
          AND (usageclasscode = @v_itemtypesubcode OR @v_itemtypesubcode = 0)
      ORDER BY defaultind DESC

    OPEN view_cur
    FETCH view_cur
    INTO @v_windowviewkey, @v_viewname, @v_defaultind

    WHILE @@FETCH_STATUS = 0
    BEGIN

      SET @v_configdetailkey = 0

      SELECT @v_configdetailkey = ISNULL(configdetailkey, 0)
      FROM qsiconfigdetail
      WHERE qsiwindowviewkey = @v_windowviewkey
        AND configobjectkey = @v_configobjectkey

      --exec qutl_trace 'gentablesitemtype_update (INS)',
      --  '@v_viewname', NULL, @v_viewname,
      --  '@v_windowviewkey', @v_windowviewkey, NULL,
      --  '@v_configdetailkey', @v_configdetailkey, NULL

      IF @v_configdetailkey <> 0
      BEGIN
          ;WITH CTE_relationshiptab AS
          (
           SELECT DISTINCT datacode,
           CASE WHEN @v_tableid = 440 THEN 1 ELSE 0 END titletabind
           FROM gentablesitemtype
           WHERE tableid = @v_tableid
             AND itemtypecode = @v_itemtypecode
             AND itemtypesubcode IN (
               @v_itemtypesubcode
               ,0
               )
          )
          INSERT INTO qsiconfigdetailtabs (
	         configdetailkey
	         ,relationshiptabcode
	         ,sortorder
	         ,lastuserid
	         ,lastmaintdate
	         ,titletabind
	         )
          SELECT @v_configdetailkey
	         ,cte.datacode
	         ,CASE WHEN @v_defaultind = 1 THEN
              ISNULL((SELECT sortorder              -- If this is the default view, copy sortorder from gentables
               FROM gentables
               WHERE tableid = @v_tableid
                 AND datacode = cte.datacode
               ), 1)
            ELSE
              ISNULL((SELECT sortorder              -- Copy the sortorder for this tab from the default view for this class
               FROM qsiconfigdetailtabs
               WHERE configdetailkey = (
                   SELECT configdetailkey
                   FROM qsiconfigdetail
                   WHERE qsiwindowviewkey = (
                       SELECT qsiwindowviewkey
                       FROM qsiwindowview
                       WHERE defaultind = 1
                         AND itemtypecode = @v_itemtypecode
                         AND usageclasscode = @v_itemtypesubcode
                         AND qsiwindowviewkey IN (
                           SELECT qsiwindowviewkey
                           FROM qsiconfigdetail
                           WHERE configobjectkey = @v_configobjectkey
                           )
                         AND configobjectkey = @v_configobjectkey
                       )
                   )
                 AND relationshiptabcode = cte.datacode
               ), 1)
              END
             ,@v_userid
             , getdate()
             ,CASE WHEN @v_tableid = 440 THEN 1 ELSE 0 END
          FROM CTE_relationshiptab cte 
          WHERE NOT EXISTS
          (
           SELECT 1 
           FROM qsiconfigdetailtabs
           WHERE
             configdetailkey = @v_configdetailkey
             AND relationshiptabcode = cte.datacode
             --AND titletabind = cte.titletabind
          )
      END

      FETCH view_cur
      INTO @v_windowviewkey, @v_viewname, @v_defaultind
    END

    CLOSE view_cur
    DEALLOCATE view_cur
  END
END
GO
