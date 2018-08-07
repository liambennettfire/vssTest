-- PO Summary

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'POSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 


if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'FileLocations' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable (availablesecurityobjectskey, windowid, availobjectid , availobjectname, availobjectdesc, sortorder, menuitemid, menuitemname, menuitemdesc, lastuserid, lastmaintdate , availobjectcode , availobjectwholerowind, availobjectcodetableid, allowadmintochoosevalueind, defaultaccesscode, criteriakey) 
    values ( @nextKey, @windowID, 'FileLocations', null, 'FileLocations - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null,null) 
end