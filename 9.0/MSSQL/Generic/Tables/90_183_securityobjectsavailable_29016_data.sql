DECLARE
  @v_maxid  INT

BEGIN

  -- Printing Search
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
      'shResultsViewDetail', 
      'cbxPublicView',
      'Make View Public', 
      'Case 29016', 
      getdate(),   
      0,
      NULL,
      NULL,
      NULL
  FROM qsiwindows 
  WHERE LOWER(windowname) = 'PrintingSearch'
 
END
go