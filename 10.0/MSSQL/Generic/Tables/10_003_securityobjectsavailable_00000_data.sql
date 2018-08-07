-- Product Summary

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'ProductSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProductParticipantsByRole1' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProductParticipantsByRole1', null, 'Participants By Role 1 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'ProductSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProductParticipantsByRole2' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProductParticipantsByRole2', null, 'Participants By Role 2 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'ProductSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProductParticipantsByRole3' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProductParticipantsByRole3', null, 'Participants By Role 3 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null,null) 
end
GO