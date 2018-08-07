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

-- Version costs
INSERT INTO @InsertTable
  (windowname, availobjectid, availobjectname, availobjectdesc)
VALUES
  ('PLVersionDetails', 'shPLVerProductionSpecs', 'Spec Item', 'Production Specifications - Detail')

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
      menuitemid, menuitemname, menuitemdesc, lastuserid, lastmaintdate, availobjectcode, 
      availobjectwholerowind, availobjectcodetableid, allowadmintochoosevalueind, defaultaccesscode)
    VALUES 
      (@v_availsecurityobjectkey, @v_windowid, @v_availobjectid, @v_availobjectname, @v_availobjectdesc, @v_sortorder, 
      NULL, NULL, NULL, 'qsidba', GETDATE(), NULL, 
      1, 616, 1, 2) 
  END

  FETCH ins_cur INTO
    @v_windowname, @v_availobjectid, @v_availobjectname, @v_availobjectdesc
END

CLOSE ins_cur
DEALLOCATE ins_cur

GO