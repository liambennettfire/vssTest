DECLARE @SummaryWindowID INT
DECLARE @availSecurityObjectsKey INT
DECLARE @sortNum INT
DECLARE @v_accessind INT

BEGIN
  SELECT @SummaryWindowID = (SELECT windowid FROM qsiwindows WHERE windowname = 'PrintingSummary')
  SELECT @sortNum = ( SELECT max(sortorder) FROM securityobjectsavailable WHERE windowid = @SummaryWindowID) 

  IF ( @sortNum is null ) SELECT @sortNum = 0

  IF NOT EXISTS ( SELECT availablesecurityobjectskey FROM securityobjectsavailable WHERE windowid = @SummaryWindowID AND availobjectid = 'shPrintingDeliveryDetails' ) BEGIN
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @availSecurityObjectsKey output

    INSERT INTO securityobjectsavailable 
	    (availablesecurityobjectskey, windowid, availobjectid, availobjectname, availobjectdesc, sortorder, 
		 menuitemid, menuitemname, menuitemdesc, lastuserid, lastmaintdate, availobjectcode, availobjectwholerowind,
         availobjectcodetableid, allowadmintochoosevalueind)
    VALUES 
	    (@availSecurityObjectsKey, @SummaryWindowID, 'shPrintingDeliveryDetails', null, 'Delivery Details - ALL', @sortNum, 
		  null, null, null, 'QSIADMIN', getdate(), null, 0, 
		  null, null) 
  END
  ELSE BEGIN
    SELECT @availSecurityObjectsKey = availablesecurityobjectskey
      FROM securityobjectsavailable
     WHERE windowid = @SummaryWindowID
       AND availobjectid = 'shPrintingDeliveryDetails'
  END

END  
GO
