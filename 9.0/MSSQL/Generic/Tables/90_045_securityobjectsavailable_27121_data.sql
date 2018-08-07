DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowtitle = 'Printing Summary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shPrintingDetails' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shPrintingDetails', null, 'PrintingDetails - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowtitle = 'Printing Summary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

--if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'KeyTasks' )
--begin
--    SET @sortNum = @sortNum + 1
--    exec get_next_key 'qsidba', @nextKey output
--    insert into securityobjectsavailable values ( @nextKey, @windowID, 'KeyTasks', null, 'KeyTasks - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null) 
--end
--GO

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shTitleTasks' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shTitleTasks', null, 'Printing Tasks - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowtitle = 'Printing Summary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shKeyDates' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shKeyDates', null, 'Key Dates - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO

DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowtitle = 'Printing Summary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'ProjectParticipants' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'ProjectParticipants', null, 'PrintingParticipants - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO


DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowtitle = 'Printing Summary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'ProjectComments' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'ProjectComments', null, 'PrintingComments - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO


DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowtitle = 'Printing Summary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

--if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shProjectElements' )
--begin
--    SET @sortNum = @sortNum + 1
--    exec get_next_key 'qsidba', @nextKey output
--    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shProjectElements', null, 'PrintingElements - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null) 
--end
--GO

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shTitleElements' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shTitleElements', null, 'PrintingElements - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO


DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowtitle = 'Printing Summary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'shPrices' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'shPrices', null, 'TitlePrices - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO


DECLARE @windowID int
DECLARE @nextKey int
DECLARE @sortNum int

SELECT @windowID = (select windowid from qsiwindows where windowtitle = 'Printing Summary')
SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @windowID 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

if ( @sortNum is null ) select @sortNum = 0

if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @windowID and availobjectid = 'FileLocations' )
begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @nextKey output
    insert into securityobjectsavailable values ( @nextKey, @windowID, 'FileLocations', null, 'FileLocations - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null,null) 
end
GO


--select * from securityobjectsavailable where windowid= (select windowid from qsiwindows where windowtitle = 'Printing Summary') and availobjectid = 'KeyTasks'
--UPDATE securityobjectsavailable SET availobjectid = 'shTitleTasks', availobjectdesc =  'Printing Tasks - ALL' WHERE availablesecurityobjectskey = 3374127 (key got from above)
--select * from securityobjectsavailable where windowid= (select windowid from qsiwindows where windowtitle = 'Printing Summary') and availobjectid = 'shProjectElements'
--UPDATE securityobjectsavailable SET availobjectid = 'shTitleElements', availobjectdesc =  'PrintingElements - ALL' WHERE availablesecurityobjectskey = 3374130 (key got from above)