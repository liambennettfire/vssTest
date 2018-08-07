DECLARE @SummaryWindowID INT
DECLARE @availSecurityObjectsKey INT
DECLARE @sortNum INT
DECLARE @v_accessind INT

BEGIN
  SELECT @SummaryWindowID = (SELECT windowid FROM qsiwindows WHERE windowname = 'ProjectSummary')
  SELECT @sortNum = ( SELECT max(sortorder) FROM securityobjectsavailable WHERE windowid = @SummaryWindowID) 

  IF ( @sortNum is null ) SELECT @sortNum = 0

  IF NOT EXISTS ( SELECT availablesecurityobjectskey FROM securityobjectsavailable WHERE windowid = @SummaryWindowID AND availobjectid = 'shProjectClassification' ) BEGIN
    SET @sortNum = @sortNum + 10
    exec get_next_key 'qsidba', @availSecurityObjectsKey output

    INSERT INTO securityobjectsavailable 
	    (availablesecurityobjectskey, windowid, availobjectid, availobjectname, availobjectdesc, sortorder, 
		 menuitemid, menuitemname, menuitemdesc, lastuserid, lastmaintdate, availobjectcode, availobjectwholerowind,
         availobjectcodetableid, allowadmintochoosevalueind)
    VALUES 
	    (@availSecurityObjectsKey, @SummaryWindowID, 'shProjectClassification', null, 'Project Classification - ALL', @sortNum, 
		  null, null, null, 'QSIADMIN', getdate(), null, 0, 
		  null, null) 
  END
  ELSE BEGIN
    SELECT @availSecurityObjectsKey = availablesecurityobjectskey
      FROM securityobjectsavailable
     WHERE windowid = @SummaryWindowID
       AND availobjectid = 'shProjectClassification'
  END

END  
GO
