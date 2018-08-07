DECLARE
  @v_securitygroupkey       INT,
  @v_securityobjectkey      INT,
  @v_availsecurityobjectkey INT,
  @v_windowind              CHAR(1),
  @v_orgsecurityind         CHAR(1),
  @v_windowname             VARCHAR(40),
  @v_windowtitle            VARCHAR(80),
	@v_windowid               INT,
	@v_availobjectid          VARCHAR(50),
	@v_availobjectname        VARCHAR(50),
	@v_availobjectdesc        VARCHAR(50),
  @v_accessind              INT,
	@v_sortorder              INT,
	@v_newkey                 INT
	
DECLARE @InsertTable TABLE
(
  windowname VARCHAR(40),
  availobjectid VARCHAR(50),
  availobjectname VARCHAR(50),
  availobjectdesc VARCHAR(50)
)

-- Projects
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('ProjectSummary', 'ProjectDetails', 'ddlbInputCurrency', 'Currency')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('ProjectSummary', 'ProjectDetails', 'ddlbApprovalCurrency', 'Currency (Approval)')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('ProjectSummary', 'ProjectDetails', 'ddlbCulture', 'Culture')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('ProjectSummary', 'ProjectDetails', 'txtExchangeRate', 'Exchange Rate')

-- Journals
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('JournalSummary', 'JournalDetails', 'ddlbInputCurrency', 'Currency')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('JournalSummary', 'JournalDetails', 'ddlbApprovalCurrency', 'Currency (Approval)')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('JournalSummary', 'JournalDetails', 'ddlbCulture', 'Culture')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('JournalSummary', 'JournalDetails', 'txtExchangeRate', 'Exchange Rate')

-- Works
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('WorkSummary', 'shWorkDetails', 'ddlbInputCurrency', 'Currency')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('WorkSummary', 'shWorkDetails', 'ddlbApprovalCurrency', 'Currency (Approval)')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('WorkSummary', 'shWorkDetails', 'ddlbCulture', 'Culture')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('WorkSummary', 'shWorkDetails', 'txtExchangeRate', 'Exchange Rate')

-- Scales
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('ScaleSummary', 'ProjectDetails', 'ddlbInputCurrency', 'Currency')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('ScaleSummary', 'ProjectDetails', 'ddlbApprovalCurrency', 'Currency (Approval)')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('ScaleSummary', 'ProjectDetails', 'ddlbCulture', 'Culture')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('ScaleSummary', 'ProjectDetails', 'txtExchangeRate', 'Exchange Rate')

-- Printings
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('PrintingSummary', 'shPrintingDetails', 'ddlbInputCurrency', 'Currency')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('PrintingSummary', 'shPrintingDetails', 'ddlbApprovalCurrency', 'Currency (Approval)')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('PrintingSummary', 'shPrintingDetails', 'ddlbCulture', 'Culture')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('PrintingSummary', 'shPrintingDetails', 'txtExchangeRate', 'Exchange Rate')

-- Purchase Orders
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('POSummary', 'shPurchaseOrderDetails', 'ddlbInputCurrency', 'Currency')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('POSummary', 'shPurchaseOrderDetails', 'ddlbApprovalCurrency', 'Currency (Approval)')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('POSummary', 'shPurchaseOrderDetails', 'ddlbCulture', 'Culture')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('POSummary', 'shPurchaseOrderDetails', 'txtExchangeRate', 'Exchange Rate')
-- PO Costs
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('POSummary', 'shPLVerProductionCostsByPrtg', 'ddlbInputCurrency', 'Currency (Costs)')

-- PL Template
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('PLTemplateSummary', 'shTemplateDetails', 'ddlbInputCurrency', 'Currency')
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('PLTemplateSummary', 'shTemplateDetails', 'ddlbApprovalCurrency', 'Currency (Approval)')

-- Version costs
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('PLVersionDetails', 'shPLVerProductionCostsByPrtg', 'ddlbInputCurrency', 'Currency')

DECLARE ins_cur CURSOR FOR
SELECT windowname, availobjectid, availobjectname, availobjectdesc
FROM @InsertTable

OPEN ins_cur

FETCH ins_cur INTO
  @v_windowname, @v_availobjectid, @v_availobjectname, @v_availobjectdesc

-- For each row to insert in securityobjectsavailable...
WHILE @@FETCH_STATUS = 0
BEGIN
  SELECT @v_windowid = windowid 
  FROM qsiwindows 
  WHERE windowname = @v_windowname	
    AND applicationind = 14 -- web apps
  
  SELECT @v_sortorder = MAX(ISNULL(sortorder,0)) + 1 
  FROM securityobjectsavailable 
  WHERE windowid = @v_windowid

  IF NOT EXISTS (
    SELECT 1 FROM securityobjectsavailable 
    WHERE windowid = @v_windowid 
      AND availobjectid = @v_availobjectid 
      AND availobjectname = @v_availobjectname
  )
  BEGIN
      exec get_next_key 'qsidba', @v_availsecurityobjectkey output
      
      INSERT INTO securityobjectsavailable 
        (availablesecurityobjectskey, windowid, availobjectid, availobjectname, availobjectdesc, sortorder, 
        menuitemid, menuitemname, menuitemdesc, lastuserid, lastmaintdate, availobjectcode, availobjectwholerowind,
        availobjectcodetableid, allowadmintochoosevalueind, defaultaccesscode)
      VALUES 
        (@v_availsecurityobjectkey, @v_windowid, @v_availobjectid, @v_availobjectname, @v_availobjectdesc, @v_sortorder, 
        NULL, NULL, NULL, 'qsidba', GETDATE(), NULL, 0, 
        NULL, NULL, NULL) 

      SET @v_accessind = 1 -- Set everything to read-only
      
      DECLARE security_cur CURSOR FOR
      SELECT securitygroupkey
      FROM securitygroup

      OPEN security_cur 

      FETCH NEXT FROM security_cur INTO @v_securitygroupkey

      WHILE @@FETCH_STATUS = 0
      BEGIN
        IF NOT EXISTS (
          SELECT 1
          FROM securityobjects
          WHERE availsecurityobjectkey = @v_availsecurityobjectkey
            AND securitygroupkey = @v_securitygroupkey
        )
        BEGIN
          EXEC get_next_key 'qsidba', @v_securityobjectkey OUTPUT

          INSERT INTO securityobjects
            (securityobjectkey, availsecurityobjectkey, securitygroupkey, userkey, accessind, lastuserid, lastmaintdate)
          VALUES 
            (@v_securityobjectkey, @v_availsecurityobjectkey, @v_securitygroupkey, NULL, @v_accessind, 'qsidba', GETDATE())
        END
        
        FETCH NEXT FROM security_cur INTO @v_securitygroupkey
      END

      CLOSE security_cur 
      DEALLOCATE security_cur 
  END

  FETCH ins_cur INTO
    @v_windowname, @v_availobjectid, @v_availobjectname, @v_availobjectdesc
END

CLOSE ins_cur
DEALLOCATE ins_cur

GO