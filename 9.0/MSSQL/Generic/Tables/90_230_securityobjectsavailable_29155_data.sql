-- Project Summary

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'ProjectSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole1' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole1', null, 'Participants By Role 1 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'ProjectSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole2' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole2', null, 'Participants By Role 2 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'ProjectSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole3' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole3', null, 'Participants By Role 3 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

-- Printing Summary

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'PrintingSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole1' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole1', null, 'Participants By Role 1 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'PrintingSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole2' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole2', null, 'Participants By Role 2 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'PrintingSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole3' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole3', null, 'Participants By Role 3 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

-- Contract Summary

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'ContractSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole1' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole1', null, 'Participants By Role 1 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'ContractSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole2' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole2', null, 'Participants By Role 2 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'ContractSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole3' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole3', null, 'Participants By Role 3 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO


-- Work Summary

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'WorkSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole1' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole1', null, 'Participants By Role 1 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'WorkSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole2' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole2', null, 'Participants By Role 2 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'WorkSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole3' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole3', null, 'Participants By Role 3 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

-- Scale Summary

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'ScaleSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole1' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole1', null, 'Participants By Role 1 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'ScaleSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole2' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole2', null, 'Participants By Role 2 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'ScaleSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole3' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole3', null, 'Participants By Role 3 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

-- Journal Summary

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'JournalSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole1' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole1', null, 'Participants By Role 1 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'JournalSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole2' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole2', null, 'Participants By Role 2 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'JournalSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole3' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole3', null, 'Participants By Role 3 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

-- PO Summary

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'POSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole1' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole1', null, 'Participants By Role 1 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'POSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole2' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole2', null, 'Participants By Role 2 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowname = 'POSummary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectParticipantsByRole3' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectParticipantsByRole3', null, 'Participants By Role 3 - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO