DECLARE
  @v_maxid  INT

BEGIN
  -- Production Specs on Title Summary
  EXEC get_next_key 'QSIADMIN', @v_maxid OUTPUT

  INSERT INTO securityobjectsavailable
    ( availablesecurityobjectskey, 
      windowid, 
      availobjectid, 
      availobjectname,
      availobjectdesc, 
      lastuserid, 
      lastmaintdate, 
      availobjectwholerowind,
      availobjectcodetableid,
      allowadmintochoosevalueind,
      sortorder)
  SELECT 
      @v_maxid, 
      windowid, 
      'shProdSpecs', 
      'Spec Item',
      'Production Specs', 
      'Case 30242', 
      getdate(),   
      1,
      616,
      1,
      42
  FROM qsiwindows 
  WHERE LOWER(windowname) = 'titlesummary'
 
END
go

DECLARE
  @v_maxid  INT

BEGIN
  -- Production Specs on Printing Summary
  EXEC get_next_key 'QSIADMIN', @v_maxid OUTPUT

  INSERT INTO securityobjectsavailable
    ( availablesecurityobjectskey, 
      windowid, 
      availobjectid, 
      availobjectname,
      availobjectdesc, 
      lastuserid, 
      lastmaintdate, 
      availobjectwholerowind,
      availobjectcodetableid,
      allowadmintochoosevalueind,
      sortorder)
  SELECT 
      @v_maxid, 
      windowid, 
      'shProdSpecs', 
      'Spec Item',
      'Production Specs', 
      'Case 30242', 
      getdate(),   
      1,
      616,
      1,
      42
  FROM qsiwindows 
  WHERE LOWER(windowname) = 'printingsummary'
 
END
go

DECLARE
  @v_maxid  INT

BEGIN
  -- Production Specs on PO Summary
  EXEC get_next_key 'QSIADMIN', @v_maxid OUTPUT

  INSERT INTO securityobjectsavailable
    ( availablesecurityobjectskey, 
      windowid, 
      availobjectid, 
      availobjectname,
      availobjectdesc, 
      lastuserid, 
      lastmaintdate, 
      availobjectwholerowind,
      availobjectcodetableid,
      allowadmintochoosevalueind,
      sortorder)
  SELECT 
      @v_maxid, 
      windowid, 
      'shProdSpecs', 
      'Spec Item',
      'Production Specs', 
      'Case 30242', 
      getdate(),   
      1,
      616,
      1,
      42
  FROM qsiwindows 
  WHERE LOWER(windowname) = 'posummary'
 
END
go

DECLARE
  @v_maxid  INT

BEGIN
  -- Production Specs on Work Summary
  EXEC get_next_key 'QSIADMIN', @v_maxid OUTPUT

  INSERT INTO securityobjectsavailable
    ( availablesecurityobjectskey, 
      windowid, 
      availobjectid, 
      availobjectname,
      availobjectdesc, 
      lastuserid, 
      lastmaintdate, 
      availobjectwholerowind,
      availobjectcodetableid,
      allowadmintochoosevalueind,
      sortorder)
  SELECT 
      @v_maxid, 
      windowid, 
      'shProdSpecs', 
      'Spec Item',
      'Production Specs', 
      'Case 30242', 
      getdate(),   
      1,
      616,
      1,
      42
  FROM qsiwindows 
  WHERE LOWER(windowname) = 'worksummary'
 
END
go

DECLARE
  @v_maxid  INT

BEGIN
  -- Production Specs on Project Summary
  EXEC get_next_key 'QSIADMIN', @v_maxid OUTPUT

  INSERT INTO securityobjectsavailable
    ( availablesecurityobjectskey, 
      windowid, 
      availobjectid, 
      availobjectname,
      availobjectdesc, 
      lastuserid, 
      lastmaintdate, 
      availobjectwholerowind,
      availobjectcodetableid,
      allowadmintochoosevalueind,
      sortorder)
  SELECT 
      @v_maxid, 
      windowid, 
      'shProdSpecs', 
      'Spec Item',
      'Production Specs', 
      'Case 30242', 
      getdate(),   
      1,
      616,
      1,
      42
  FROM qsiwindows 
  WHERE LOWER(windowname) = 'projectsummary'
 
END
go
