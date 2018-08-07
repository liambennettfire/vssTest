DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowtitle = 'Purchase Order Summary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shPurchaseOrderDetails' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shPurchaseOrderDetails', null, 'Purchase Order Details - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowtitle = 'Purchase Order Summary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'KeyTasks' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'KeyTasks', null, 'Tasks - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowtitle = 'Purchase Order Summary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'ProjectParticipants' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'ProjectParticipants', null, 'Participants - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowtitle = 'Purchase Order Summary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shPODetails' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shPODetails', null, 'PO Details - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowtitle = 'Purchase Order Summary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shPOInstructions' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shPOInstructions', null, 'PO Instructions - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO