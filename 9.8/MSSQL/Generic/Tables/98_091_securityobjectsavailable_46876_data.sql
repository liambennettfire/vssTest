DECLARE
  @v_maxid  INT

BEGIN

  -- PO Search
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
      'qsidba', 
      getdate(),   
      0,
      NULL,
      NULL,
      NULL
  FROM qsiwindows 
  WHERE LOWER(windowname) = 'POSearch'
 
END
go