IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[qpo_validatepo_custom]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE [dbo].[qpo_validatepo_custom]
GO

/**************************************************************************************************
**  Name: qpo_validatepo_custom
**  Desc: Procedure called when creating Final PO Report to enable custom validation.
**  Case: 50569
**
**  Auth: Colman
**  Date: 04/16/2018
***************************************************************************************************
**	Change History
***************************************************************************************************
**  Date	    Author    Description
**	--------	--------	---------------------------------------------------------------------------
***************************************************************************************************/

CREATE PROCEDURE dbo.qpo_validatepo_custom
  @i_po_projectkey    INT,
  @i_po_createclass   INT,
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
AS

BEGIN
  DECLARE @v_datetypecode INT,
          @v_pbrsection_datacode INT,
          @v_itemtype    INT,
          @v_usageclass  INT,
          @v_relateddatacode INT,
          @v_activedate DATETIME,
          @v_displayname VARCHAR(MAX),
          @v_error_desc  VARCHAR(2000)
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_error_desc = ''
  
 	SET @v_relateddatacode = 2	  -- Shipping Locations tab
  SET @v_pbrsection_datacode = 7 -- Participant by Role 2
  
  -- Only validate if we are creating a Final PO Report
  IF NOT EXISTS (
    SELECT 1 FROM subgentables
    WHERE tableid = 550
      AND qsicode = 43
      AND datasubcode = @i_po_createclass
  )
    RETURN

  SELECT @v_itemtype = searchitemcode,  @v_usageclass = usageclasscode 
  FROM taqproject
  WHERE taqprojectkey = @i_po_projectkey

  SELECT @v_datetypecode = (SELECT top(1) relateddatacode 
										FROM gentablesitemtype 
										WHERE tableid = 636 
											AND datacode = @v_pbrsection_datacode
											AND datasubcode = 11  -- Date column
											AND itemtypecode = @v_itemtype
											AND itemtypesubcode IN (0, @v_usageclass) ORDER BY itemtypesubcode desc)

DECLARE @participantcontactroleinfo TABLE (
  taqprojectcontactkey INT NULL,
  globalcontactkey INT NULL,
  rolecode INT NULL,
  displayname VARCHAR(255) NULL,
  taqtaskkey INT NULL
  )  

  INSERT INTO @participantcontactroleinfo
    SELECT 
	    p.taqprojectcontactkey,
	    p.globalcontactkey,
	    r.rolecode,
	    COALESCE(c.displayname, '') displayname,
      dbo.qutl_get_related_taqtaskkey(@v_datetypecode, r.taqprojectcontactrolekey, p.globalcontactkey, r.rolecode, @i_po_projectkey, NULL, NULL) taqtaskkey
    FROM gentablesitemtype AS i
    INNER JOIN gentables AS g ON i.tableid = g.tableid
	    AND i.datacode = g.datacode
    LEFT OUTER JOIN taqprojectcontact AS p
    INNER JOIN corecontactinfo AS c ON p.globalcontactkey = c.contactkey
	    AND p.taqprojectkey = @i_po_projectkey
    INNER JOIN taqprojectcontactrole AS r ON p.taqprojectcontactkey = r.taqprojectcontactkey ON g.datacode = r.rolecode WHERE g.tableid = 285
	    AND i.itemtypecode = @v_itemtype
	    AND i.itemtypesubcode IN (0, @v_usageclass)
	    AND UPPER(ISNULL(g.deletestatus, 'N')) <> 'Y'
	    AND ISNULL(i.relateddatacode, 0) = @v_relateddatacode
	    AND (ISNULL(p.taqprojectcontactkey, 0) > 0 OR ISNULL(i.indicator1, 0) > 0)

  -- It is possible for two rows to get the same taqtaskkey.
  -- In this case, NULL out the keys that have a less precise match (e.g. role and contact over just role)
  ;WITH toupdate
  AS (
    SELECT p.*
      ,row_number() OVER (
        PARTITION BY taqtaskkey ORDER BY ISNULL(rolecode, -1) DESC, ISNULL(globalcontactkey, -1) DESC
        ) AS seqnum
    FROM @participantcontactroleinfo p
    WHERE taqtaskkey IS NOT NULL
    )
  UPDATE toupdate
  SET taqtaskkey = NULL
  WHERE seqnum > 1;

  DECLARE participant_cur CURSOR FOR
    SELECT 
      t.displayname,
      tpt.activedate
    FROM  @participantcontactroleinfo t
      LEFT OUTER JOIN taqprojecttask tpt ON tpt.taqtaskkey = t.taqtaskkey
    ORDER BY t.displayname

    OPEN participant_cur
    FETCH participant_cur INTO @v_displayname, @v_activedate

    WHILE @@FETCH_STATUS = 0
    BEGIN
      IF @v_activedate IS NULL
      BEGIN
        SET @o_error_code = -1
        BREAK
      END
        
      FETCH participant_cur INTO @v_displayname, @v_activedate
    END

    CLOSE participant_cur
    DEALLOCATE participant_cur

    IF @o_error_code = -1
    BEGIN
      SET @o_error_desc = 'All Shipping Locations must have a shipping date before creating a Final PO Report.'
    END
END
GO

GRANT EXECUTE ON qpo_validatepo_custom TO PUBLIC
GO