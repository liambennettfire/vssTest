IF EXISTS (
    SELECT *
    FROM dbo.sysobjects
    WHERE id = object_id(N'dbo.qproject_get_participants_by_role_fn')
      AND xtype IN (N'FN', N'IF', N'TF')
    )
  DROP FUNCTION dbo.qproject_get_participants_by_role_fn
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[qproject_get_participants_by_role_fn] (
  @i_userkey INT,
  @i_projectkey INT,
  @i_datacode INT,
  @i_itemtype INT,
  @i_usageclass INT
  )
RETURNS @ParticipantsByRole TABLE (
  taqprojectkey INT,
  taqprojectcontactkey INT,
  taqprojectcontactrolekey INT,
  displayname VARCHAR(255),
  indicator1 INT,
  rolecode INT,
  keyind INT,
  sortorder INT,
  globalcontactkey INT,
  addresskey INT,
  globalcontactrelationshipkey INT,
  taqversionformatkey INT,
  taqversionformatdesc VARCHAR(max),
  quantity INT,
  email VARCHAR(100),
  phone VARCHAR(100),
  indicator INT,
  shippingmethodcode INT,
  taqtaskkey INT,
  activedate DATETIME,
  task_contactrolekey INT,
  participantnote VARCHAR(max),
  relatedcontactkey INT,
  relateddisplayname VARCHAR(255),
  generictext VARCHAR(max),
  isprivate INT
  )
AS
/******************************************************************************
**  Name: qproject_get_participants_by_role_fn
**  Desc: Gets the Particpants by Role for the project.
**  @i_datacode = 6, for Participant by Role 1
**				= 7, for Participant By Role 2 
**				= 8, for Participant By Role 3
**
**  Moved from qproject_get_project_participant_by_role procedure for Case 51811
**
**  Auth: Colman
**  Date: 06/27/18
**
*********************************************************************************************************************
**  Change History
**********************************************************************************************************************
**  Date:      Author:   Description:
**  --------   ------    -------------------------------------------
*******************************************************************************/
BEGIN
  DECLARE @v_error_var INT,
    @v_rowcount_var INT,
    @v_itemtypecode_for_printing INT,
    @v_usageclasscode_for_printing INT,
    @v_bookkey INT,
    @v_printingkey INT,
    @v_datetypecode INT,
    @v_relateddatacode INT,
    @v_sortorder SMALLINT,
    @v_vendor_datacode INT
    
  DECLARE @TempParticipantsByRole TABLE (
    taqprojectkey INT NULL,
    indicator1 TINYINT NULL,
    taqprojectcontactkey INT NULL,
    datacode INT NULL,
    keyind TINYINT NULL,
    sortorder SMALLINT NULL,
    globalcontactkey INT NULL,
    addresskey INT NULL,
    participantnote VARCHAR(2000) NULL,
    displayname VARCHAR(255) NULL,
    email VARCHAR(100) NULL,
    phone VARCHAR(100) NULL,
    contactkey INT NULL,
    rolecode SMALLINT NULL,
    taqprojectcontactrolekey INT NULL,
    globalcontactrelationshipkey INT NULL,
    taqversionformatkey INT NULL,
    quantity INT NULL,
    shippingmethodcode INT NULL,
    indicator TINYINT NULL,
    generictext VARCHAR(50),
    taqtaskkey INT NULL,
    newsortorder SMALLINT NULL
    )

  IF @i_datacode = 6
  BEGIN
    SET @v_relateddatacode = 1
  END
  ELSE IF @i_datacode = 7
  BEGIN
    SET @v_relateddatacode = 2
  END
  ELSE IF @i_datacode = 8
  BEGIN
    SET @v_relateddatacode = 3
  END

  IF @i_itemtype IS NULL AND @i_usageclass IS NULL
    SELECT @i_itemtype = searchitemcode, @i_usageclass = usageclasscode FROM taqproject WHERE taqprojectkey = @i_projectkey

  SELECT @v_vendor_datacode = datacode
  FROM gentables
  WHERE tableid = 285
    AND qsicode = 15

  SELECT @v_itemtypecode_for_printing = datacode,
    @v_usageclasscode_for_printing = datasubcode
  FROM subgentables
  WHERE tableid = 550
    AND qsicode = 40

  SELECT @v_datetypecode = (
      SELECT TOP (1) relateddatacode
      FROM gentablesitemtype
      WHERE tableid = 636
        AND datacode = @i_datacode
        AND datasubcode = 11
        AND itemtypecode = @i_itemtype
        AND itemtypesubcode IN (0, @i_usageclass)
      ORDER BY itemtypesubcode DESC
      )

  IF @i_itemtype = @v_itemtypecode_for_printing
  BEGIN
    SELECT @v_bookkey = bookkey,
      @v_printingkey = printingkey
    FROM taqprojectprinting_view
    WHERE taqprojectkey = @i_projectkey
  END

  SET @v_error_var = 0
  SET @v_rowcount_var = 0

  --get Project Participant by Role information for the Section
  IF ISNULL(@i_projectkey, 0) > 0
    INSERT INTO @TempParticipantsByRole
    SELECT @i_projectkey AS taqprojectkey,
      COALESCE(i.indicator1, 0) AS indicator1,
      p.taqprojectcontactkey,
      g.datacode,
      p.keyind,
      p.sortorder,
      p.globalcontactkey,
      p.addresskey,
      p.participantnote,
      COALESCE(c.displayname, '') AS displayname,
      c.email,
      c.phone,
      c.contactkey,
      r.rolecode,
      r.taqprojectcontactrolekey,
      r.globalcontactrelationshipkey,
      r.taqversionformatkey,
      r.quantity,
      r.shippingmethodcode,
      COALESCE(r.indicator, 0) AS indicator,
      r.generictext,
      CASE 
        WHEN @v_itemtypecode_for_printing = @i_itemtype
          THEN dbo.qutl_get_related_taqtaskkey(@v_datetypecode, r.taqprojectcontactrolekey, p.globalcontactkey, r.rolecode, NULL, @v_bookkey, @v_printingkey)
        ELSE dbo.qutl_get_related_taqtaskkey(@v_datetypecode, r.taqprojectcontactrolekey, p.globalcontactkey, r.rolecode, @i_projectkey, NULL, NULL)
        END AS taqtaskkey,
      p.sortorder AS newsortorder
    FROM gentablesitemtype AS i
    INNER JOIN gentables AS g
      ON i.tableid = g.tableid
        AND i.datacode = g.datacode
    LEFT JOIN taqprojectcontact AS p
    INNER JOIN corecontactinfo AS c
      ON p.globalcontactkey = c.contactkey
        AND p.taqprojectkey = @i_projectkey
    INNER JOIN taqprojectcontactrole AS r
      ON p.taqprojectcontactkey = r.taqprojectcontactkey
        ON g.datacode = r.rolecode WHERE g.tableid = 285
        AND i.itemtypecode = @i_itemtype
        AND i.itemtypesubcode IN (0, @i_usageclass)
        AND UPPER(ISNULL(g.deletestatus, 'N')) <> 'Y'
        AND ISNULL(i.relateddatacode, 0) = @v_relateddatacode
        AND (
          ISNULL(p.taqprojectcontactkey, 0) > 0
          OR ISNULL(i.indicator1, 0) > 0
          )
    ORDER BY p.sortorder,
      displayname
  ELSE
    INSERT INTO @TempParticipantsByRole
    SELECT @i_projectkey AS taqprojectkey,
      ISNULL(i.indicator1, 0) AS indicator1,
      NULL,
      g.datacode,
      ISNULL(i.indicator2, 0) AS keyind,
      NULL,
      NULL,
      NULL,
      NULL,
      '' AS displayname,
      NULL,
      NULL,
      NULL,
      g.datacode,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      0 AS indicator,
      NULL,
      NULL,
      NULL AS newsortorder
    FROM gentablesitemtype AS i
    INNER JOIN gentables AS g
      ON i.tableid = g.tableid
        AND i.datacode = g.datacode
    WHERE g.tableid = 285
      AND i.itemtypecode = @i_itemtype
      AND i.itemtypesubcode IN (0, @i_usageclass)
      AND UPPER(ISNULL(g.deletestatus, 'N')) <> 'Y'
      AND ISNULL(i.relateddatacode, 0) = @v_relateddatacode
      AND ISNULL(i.indicator1, 0) > 0
    ORDER BY displayname

  SELECT @v_sortorder = MAX(COALESCE(newsortorder, 0))
  FROM @TempParticipantsByRole

  UPDATE @TempParticipantsByRole
  SET @v_sortorder = newsortorder = @v_sortorder + 1
  WHERE newsortorder IS NULL
    AND COALESCE(globalcontactkey, 0) = 0
    -- It is possible for two rows to get the same taqtaskkey.
    -- In this case, NULL out the keys that have a less precise match (e.g. role and contact over just role)
    ;

  WITH toupdate
  AS (
    SELECT p.*,
      row_number() OVER (
        PARTITION BY taqtaskkey ORDER BY ISNULL(rolecode, - 1) DESC,
          ISNULL(globalcontactkey, - 1) DESC
        ) AS seqnum
    FROM @TempParticipantsByRole p
    WHERE taqtaskkey IS NOT NULL
    )
  UPDATE toupdate
  SET taqtaskkey = NULL
  WHERE seqnum > 1;

  INSERT INTO @ParticipantsByRole (
    taqprojectkey,
    taqprojectcontactkey,
    taqprojectcontactrolekey,
    displayname,
    indicator1,
    rolecode,
    keyind,
    sortorder,
    globalcontactkey,
    addresskey,
    globalcontactrelationshipkey,
    taqversionformatkey,
    taqversionformatdesc,
    quantity,
    email,
    phone,
    indicator,
    shippingmethodcode,
    taqtaskkey,
    activedate,
    task_contactrolekey,
    participantnote,
    relatedcontactkey,
    relateddisplayname,
    generictext,
    isprivate
    )
  SELECT @i_projectkey AS taqprojectkey,
    t.taqprojectcontactkey,
    t.taqprojectcontactrolekey,
    t.displayname,
    t.indicator1,
    t.datacode AS rolecode,
    t.keyind,
    COALESCE(t.newsortorder, 0) AS sortorder,
    t.globalcontactkey,
    t.addresskey,
    t.globalcontactrelationshipkey,
    t.taqversionformatkey,
    CASE 
      WHEN COALESCE(t.taqversionformatkey, 0) > 0
        THEN (
            SELECT f.description
            FROM taqversionformat f
            WHERE f.taqprojectformatkey = t.taqversionformatkey
            )
      ELSE ''
      END AS taqversionformatdesc,
    t.quantity,
    t.email,
    t.phone,
    COALESCE(t.indicator, 0) AS indicator,
    t.shippingmethodcode,
    t.taqtaskkey,
    tpt.activedate,
    tpt.transactionkey task_contactrolekey,
    t.participantnote,
    CASE 
      WHEN COALESCE(t.globalcontactrelationshipkey, 0) > 0
        THEN (
            SELECT TOP (1) v.relatedcontactkey
            FROM globalcontactrelationshipview v
            WHERE v.globalcontactrelationshipkey = t.globalcontactrelationshipkey
              AND v.globalcontactkey = t.globalcontactkey
            )
      ELSE 0
      END AS relatedcontactkey,
    CASE 
      WHEN COALESCE(t.globalcontactrelationshipkey, 0) >= 0
        THEN (
            SELECT TOP (1) COALESCE(v.relatedcontactname, '')
            FROM globalcontactrelationshipview v
            WHERE v.globalcontactrelationshipkey = t.globalcontactrelationshipkey
              AND v.globalcontactkey = t.globalcontactkey
            )
      ELSE ''
      END AS relateddisplayname,
    t.generictext,
    dbo.qcontact_is_contact_private(t.contactkey, @i_userkey) AS isprivate
  FROM @TempParticipantsByRole t
  LEFT JOIN taqprojecttask tpt
    ON tpt.taqtaskkey = t.taqtaskkey
  ORDER BY t.newsortorder,
    t.displayname

  RETURN
END
