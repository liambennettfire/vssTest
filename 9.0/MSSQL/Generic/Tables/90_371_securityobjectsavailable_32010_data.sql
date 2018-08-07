-- backup security tables
select * into securitywindows_32010
from securitywindows
go
select * into qsiwindows_32010
from qsiwindows
go

DECLARE @SummaryWindowID int
DECLARE @CommentWindowID int
DECLARE @availSecurityObjectsKey int
DECLARE @sortNum int
DECLARE @userkey int
DECLARE @securitygroupkey int
DECLARE @securityobjectkey int
DECLARE @v_count int
DECLARE @v_accessind int

BEGIN
  SELECT @SummaryWindowID = (select windowid from qsiwindows where windowname = 'TitleSummary')
  SELECT @CommentWindowID = (select windowid from qsiwindows where windowname = 'TitleComments')
  SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @SummaryWindowID 
                      and availobjectname is null and availobjectdesc like '%- ALL%' ) 

  if ( @sortNum is null ) select @sortNum = 0

  if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @SummaryWindowID and availobjectid = 'shTitleComments' ) begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @availSecurityObjectsKey output
    insert into securityobjectsavailable (availablesecurityobjectskey,windowid,availobjectid,availobjectname,availobjectdesc,
                sortorder,menuitemid,menuitemname,menuitemdesc,lastuserid,lastmaintdate,availobjectcode,availobjectwholerowind,
                availobjectcodetableid,allowadmintochoosevalueind)
    values ( @availSecurityObjectsKey, @SummaryWindowID, 'shTitleComments', null, 'Title Comments - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null) 
  end
  else begin
    select @availSecurityObjectsKey = availablesecurityobjectskey
      from securityobjectsavailable
     where windowid = @SummaryWindowID
       and availobjectid = 'shTitleComments'
  end

  /*** Copy security from old comment window to new summary section ***/
  DECLARE crSecWin CURSOR FOR
  SELECT userkey,securitygroupkey,accessind
  FROM securitywindows
  WHERE windowid = @CommentWindowID
  
  OPEN crSecWin 

  FETCH NEXT FROM crSecWin INTO @userkey,@securitygroupkey,@v_accessind

  WHILE (@@FETCH_STATUS <> -1) BEGIN
    SELECT @v_count = count(*) FROM securityobjects
     WHERE availsecurityobjectkey = @availSecurityObjectsKey 
       and coalesce(userkey,-99) = coalesce(@userkey,-99)
       and coalesce(securitygroupkey,0) = coalesce(@securitygroupkey,0)
       
    if @v_count = 0 begin      
      exec get_next_key 'qsidba', @securityobjectkey output

      INSERT INTO securityobjects
      (securityobjectkey,
      availsecurityobjectkey,
      securitygroupkey,
      userkey,
      accessind,
      lastuserid,
      lastmaintdate)
      VALUES 
      (@securityobjectkey,
      @availSecurityObjectsKey,
      @securitygroupkey,
      @userkey,
      @v_accessind,
      'QSIDBA',
      getdate())
    end
    
    FETCH NEXT FROM crSecWin INTO @userkey,@securitygroupkey,@v_accessind
  END /* WHILE FECTHING */

  CLOSE crSecWin 
  DEALLOCATE crSecWin 
  
  -- remove old security rows for comment window
  DELETE FROM securitywindows
  WHERE windowid = @CommentWindowID
  
  -- remove old comment window
  DELETE FROM qsiwindows
  WHERE windowid = @CommentWindowID  
END  
GO

DECLARE @SummaryWindowID int
DECLARE @CommentWindowID int
DECLARE @availSecurityObjectsKey int
DECLARE @sortNum int
DECLARE @userkey int
DECLARE @securitygroupkey int
DECLARE @securityobjectkey int
DECLARE @v_count int
DECLARE @v_accessind int

BEGIN
  SELECT @SummaryWindowID = (select windowid from qsiwindows where windowname = 'ProjectSummary')
  SELECT @CommentWindowID = (select windowid from qsiwindows where windowname = 'ProjectComments')
  SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @SummaryWindowID 
                      and availobjectname is null and availobjectdesc like '%- ALL%' ) 

  if ( @sortNum is null ) select @sortNum = 0

  if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @SummaryWindowID and availobjectid = 'ProjectComments' ) begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @availSecurityObjectsKey output
    insert into securityobjectsavailable (availablesecurityobjectskey,windowid,availobjectid,availobjectname,availobjectdesc,
                sortorder,menuitemid,menuitemname,menuitemdesc,lastuserid,lastmaintdate,availobjectcode,availobjectwholerowind,
                availobjectcodetableid,allowadmintochoosevalueind)
    values ( @availSecurityObjectsKey, @SummaryWindowID, 'ProjectComments', null, 'Project Comments - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null) 
  end
  else begin
    select @availSecurityObjectsKey = availablesecurityobjectskey
      from securityobjectsavailable
     where windowid = @SummaryWindowID
       and availobjectid = 'ProjectComments'
  end

  /*** Copy security from old comment window to new summary section ***/
  DECLARE crSecWin CURSOR FOR
  SELECT userkey,securitygroupkey,accessind
  FROM securitywindows
  WHERE windowid = @CommentWindowID
  
  OPEN crSecWin 

  FETCH NEXT FROM crSecWin INTO @userkey,@securitygroupkey,@v_accessind

  WHILE (@@FETCH_STATUS <> -1) BEGIN
    SELECT @v_count = count(*) FROM securityobjects
     WHERE availsecurityobjectkey = @availSecurityObjectsKey 
       and coalesce(userkey,-99) = coalesce(@userkey,-99)
       and coalesce(securitygroupkey,0) = coalesce(@securitygroupkey,0)
       
    if @v_count = 0 begin      
      exec get_next_key 'qsidba', @securityobjectkey output

      INSERT INTO securityobjects
      (securityobjectkey,
      availsecurityobjectkey,
      securitygroupkey,
      userkey,
      accessind,
      lastuserid,
      lastmaintdate)
      VALUES 
      (@securityobjectkey,
      @availSecurityObjectsKey,
      @securitygroupkey,
      @userkey,
      @v_accessind,
      'QSIDBA',
      getdate())
    end
    
    FETCH NEXT FROM crSecWin INTO @userkey,@securitygroupkey,@v_accessind
  END /* WHILE FECTHING */

  CLOSE crSecWin 
  DEALLOCATE crSecWin 
  
  -- remove old security rows for comment window
  DELETE FROM securitywindows
  WHERE windowid = @CommentWindowID
  
  -- remove old comment window
  DELETE FROM qsiwindows
  WHERE windowid = @CommentWindowID  
  
END  
GO

DECLARE @SummaryWindowID int
DECLARE @CommentWindowID int
DECLARE @availSecurityObjectsKey int
DECLARE @sortNum int
DECLARE @userkey int
DECLARE @securitygroupkey int
DECLARE @securityobjectkey int
DECLARE @v_count int
DECLARE @v_accessind int

BEGIN
  SELECT @SummaryWindowID = (select windowid from qsiwindows where windowname = 'PrintingSummary')
  SELECT @CommentWindowID = (select windowid from qsiwindows where windowname = 'ProjectComments')
  SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @SummaryWindowID 
                      and availobjectname is null and availobjectdesc like '%- ALL%' ) 

  if ( @sortNum is null ) select @sortNum = 0

  if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @SummaryWindowID and availobjectid = 'ProjectComments' ) begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @availSecurityObjectsKey output
    insert into securityobjectsavailable (availablesecurityobjectskey,windowid,availobjectid,availobjectname,availobjectdesc,
                sortorder,menuitemid,menuitemname,menuitemdesc,lastuserid,lastmaintdate,availobjectcode,availobjectwholerowind,
                availobjectcodetableid,allowadmintochoosevalueind)
    values ( @availSecurityObjectsKey, @SummaryWindowID, 'ProjectComments', null, 'PrintingComments - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null) 
  end
  else begin
    select @availSecurityObjectsKey = availablesecurityobjectskey
      from securityobjectsavailable
     where windowid = @SummaryWindowID
       and availobjectid = 'ProjectComments'
  end

  /*** Copy security from old comment window to new summary section ***/
  DECLARE crSecWin CURSOR FOR
  SELECT userkey,securitygroupkey,accessind
  FROM securitywindows
  WHERE windowid = @CommentWindowID
  
  OPEN crSecWin 

  FETCH NEXT FROM crSecWin INTO @userkey,@securitygroupkey,@v_accessind

  WHILE (@@FETCH_STATUS <> -1) BEGIN
    SELECT @v_count = count(*) FROM securityobjects
     WHERE availsecurityobjectkey = @availSecurityObjectsKey 
       and coalesce(userkey,-99) = coalesce(@userkey,-99)
       and coalesce(securitygroupkey,0) = coalesce(@securitygroupkey,0)
       
    if @v_count = 0 begin      
      exec get_next_key 'qsidba', @securityobjectkey output

      INSERT INTO securityobjects
      (securityobjectkey,
      availsecurityobjectkey,
      securitygroupkey,
      userkey,
      accessind,
      lastuserid,
      lastmaintdate)
      VALUES 
      (@securityobjectkey,
      @availSecurityObjectsKey,
      @securitygroupkey,
      @userkey,
      @v_accessind,
      'QSIDBA',
      getdate())
    end
    
    FETCH NEXT FROM crSecWin INTO @userkey,@securitygroupkey,@v_accessind
  END /* WHILE FECTHING */

  CLOSE crSecWin 
  DEALLOCATE crSecWin 
 
  -- remove old security rows for comment window
  DELETE FROM securitywindows
  WHERE windowid = @CommentWindowID
  
  -- remove old comment window
  DELETE FROM qsiwindows
  WHERE windowid = @CommentWindowID  
  
END  
GO

DECLARE @SummaryWindowID int
DECLARE @CommentWindowID int
DECLARE @availSecurityObjectsKey int
DECLARE @sortNum int
DECLARE @userkey int
DECLARE @securitygroupkey int
DECLARE @securityobjectkey int
DECLARE @v_count int
DECLARE @v_accessind int

BEGIN
  SELECT @SummaryWindowID = (select windowid from qsiwindows where windowname = 'WorkSummary')
  SELECT @CommentWindowID = (select windowid from qsiwindows where windowname = 'ProjectComments')
  SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @SummaryWindowID 
                      and availobjectname is null and availobjectdesc like '%- ALL%' ) 

  if ( @sortNum is null ) select @sortNum = 0

  if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @SummaryWindowID and availobjectid = 'ProjectComments' ) begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @availSecurityObjectsKey output
    insert into securityobjectsavailable (availablesecurityobjectskey,windowid,availobjectid,availobjectname,availobjectdesc,
                sortorder,menuitemid,menuitemname,menuitemdesc,lastuserid,lastmaintdate,availobjectcode,availobjectwholerowind,
                availobjectcodetableid,allowadmintochoosevalueind)
    values ( @availSecurityObjectsKey, @SummaryWindowID, 'ProjectComments', null, 'Work Comments - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null) 
  end
  else begin
    select @availSecurityObjectsKey = availablesecurityobjectskey
      from securityobjectsavailable
     where windowid = @SummaryWindowID
       and availobjectid = 'ProjectComments'
  end

  /*** Copy security from old comment window to new summary section ***/
  DECLARE crSecWin CURSOR FOR
  SELECT userkey,securitygroupkey,accessind
  FROM securitywindows
  WHERE windowid = @CommentWindowID
  
  OPEN crSecWin 

  FETCH NEXT FROM crSecWin INTO @userkey,@securitygroupkey,@v_accessind

  WHILE (@@FETCH_STATUS <> -1) BEGIN
    SELECT @v_count = count(*) FROM securityobjects
     WHERE availsecurityobjectkey = @availSecurityObjectsKey 
       and coalesce(userkey,-99) = coalesce(@userkey,-99)
       and coalesce(securitygroupkey,0) = coalesce(@securitygroupkey,0)
       
    if @v_count = 0 begin      
      exec get_next_key 'qsidba', @securityobjectkey output

      INSERT INTO securityobjects
      (securityobjectkey,
      availsecurityobjectkey,
      securitygroupkey,
      userkey,
      accessind,
      lastuserid,
      lastmaintdate)
      VALUES 
      (@securityobjectkey,
      @availSecurityObjectsKey,
      @securitygroupkey,
      @userkey,
      @v_accessind,
      'QSIDBA',
      getdate())
    end
    
    FETCH NEXT FROM crSecWin INTO @userkey,@securitygroupkey,@v_accessind
  END /* WHILE FECTHING */

  CLOSE crSecWin 
  DEALLOCATE crSecWin 
  
  -- remove old security rows for comment window
  DELETE FROM securitywindows
  WHERE windowid = @CommentWindowID
  
  -- remove old comment window
  DELETE FROM qsiwindows
  WHERE windowid = @CommentWindowID  
  
END  
GO

DECLARE @SummaryWindowID int
DECLARE @CommentWindowID int
DECLARE @availSecurityObjectsKey int
DECLARE @sortNum int
DECLARE @userkey int
DECLARE @securitygroupkey int
DECLARE @securityobjectkey int
DECLARE @v_count int
DECLARE @v_accessind int

BEGIN
  SELECT @SummaryWindowID = (select windowid from qsiwindows where windowname = 'ContractSummary')
  SELECT @CommentWindowID = (select windowid from qsiwindows where windowname = 'ProjectComments')
  SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @SummaryWindowID 
                      and availobjectname is null and availobjectdesc like '%- ALL%' ) 

  if ( @sortNum is null ) select @sortNum = 0

  if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @SummaryWindowID and availobjectid = 'ProjectComments' ) begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @availSecurityObjectsKey output
    insert into securityobjectsavailable (availablesecurityobjectskey,windowid,availobjectid,availobjectname,availobjectdesc,
                sortorder,menuitemid,menuitemname,menuitemdesc,lastuserid,lastmaintdate,availobjectcode,availobjectwholerowind,
                availobjectcodetableid,allowadmintochoosevalueind)
    values ( @availSecurityObjectsKey, @SummaryWindowID, 'ProjectComments', null, 'Contract Comments - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null) 
  end
  else begin
    select @availSecurityObjectsKey = availablesecurityobjectskey
      from securityobjectsavailable
     where windowid = @SummaryWindowID
       and availobjectid = 'ProjectComments'
  end

  /*** Copy security from old comment window to new summary section ***/
  DECLARE crSecWin CURSOR FOR
  SELECT userkey,securitygroupkey,accessind
  FROM securitywindows
  WHERE windowid = @CommentWindowID
  
  OPEN crSecWin 

  FETCH NEXT FROM crSecWin INTO @userkey,@securitygroupkey,@v_accessind

  WHILE (@@FETCH_STATUS <> -1) BEGIN
    SELECT @v_count = count(*) FROM securityobjects
     WHERE availsecurityobjectkey = @availSecurityObjectsKey 
       and coalesce(userkey,-99) = coalesce(@userkey,-99)
       and coalesce(securitygroupkey,0) = coalesce(@securitygroupkey,0)
       
    if @v_count = 0 begin      
      exec get_next_key 'qsidba', @securityobjectkey output

      INSERT INTO securityobjects
      (securityobjectkey,
      availsecurityobjectkey,
      securitygroupkey,
      userkey,
      accessind,
      lastuserid,
      lastmaintdate)
      VALUES 
      (@securityobjectkey,
      @availSecurityObjectsKey,
      @securitygroupkey,
      @userkey,
      @v_accessind,
      'QSIDBA',
      getdate())
    end
    
    FETCH NEXT FROM crSecWin INTO @userkey,@securitygroupkey,@v_accessind
  END /* WHILE FECTHING */

  CLOSE crSecWin 
  DEALLOCATE crSecWin 
  
  -- remove old security rows for comment window
  DELETE FROM securitywindows
  WHERE windowid = @CommentWindowID
  
  -- remove old comment window
  DELETE FROM qsiwindows
  WHERE windowid = @CommentWindowID  
  
END  
GO

DECLARE @SummaryWindowID int
DECLARE @CommentWindowID int
DECLARE @availSecurityObjectsKey int
DECLARE @sortNum int
DECLARE @userkey int
DECLARE @securitygroupkey int
DECLARE @securityobjectkey int
DECLARE @v_count int
DECLARE @v_accessind int

BEGIN
  SELECT @SummaryWindowID = (select windowid from qsiwindows where windowname = 'POSummary')
  SELECT @CommentWindowID = (select windowid from qsiwindows where windowname = 'ProjectComments')
  SELECT @sortNum = ( select max(sortorder) from securityobjectsavailable where windowid = @SummaryWindowID 
                      and availobjectname is null and availobjectdesc like '%- ALL%' ) 

  if ( @sortNum is null ) select @sortNum = 0

  if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @SummaryWindowID and availobjectid = 'ProjectComments' ) begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @availSecurityObjectsKey output
    insert into securityobjectsavailable (availablesecurityobjectskey,windowid,availobjectid,availobjectname,availobjectdesc,
                sortorder,menuitemid,menuitemname,menuitemdesc,lastuserid,lastmaintdate,availobjectcode,availobjectwholerowind,
                availobjectcodetableid,allowadmintochoosevalueind)
    values ( @availSecurityObjectsKey, @SummaryWindowID, 'ProjectComments', null, 'PO Comments - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null) 
  end
  else begin
    select @availSecurityObjectsKey = availablesecurityobjectskey
      from securityobjectsavailable
     where windowid = @SummaryWindowID
       and availobjectid = 'ProjectComments'
  end

  /*** Copy security from old comment window to new summary section ***/
  DECLARE crSecWin CURSOR FOR
  SELECT userkey,securitygroupkey,accessind
  FROM securitywindows
  WHERE windowid = @CommentWindowID
  
  OPEN crSecWin 

  FETCH NEXT FROM crSecWin INTO @userkey,@securitygroupkey,@v_accessind

  WHILE (@@FETCH_STATUS <> -1) BEGIN
    SELECT @v_count = count(*) FROM securityobjects
     WHERE availsecurityobjectkey = @availSecurityObjectsKey 
       and coalesce(userkey,-99) = coalesce(@userkey,-99)
       and coalesce(securitygroupkey,0) = coalesce(@securitygroupkey,0)
       
    if @v_count = 0 begin      
      exec get_next_key 'qsidba', @securityobjectkey output

      INSERT INTO securityobjects
      (securityobjectkey,
      availsecurityobjectkey,
      securitygroupkey,
      userkey,
      accessind,
      lastuserid,
      lastmaintdate)
      VALUES 
      (@securityobjectkey,
      @availSecurityObjectsKey,
      @securitygroupkey,
      @userkey,
      @v_accessind,
      'QSIDBA',
      getdate())
    end
    
    FETCH NEXT FROM crSecWin INTO @userkey,@securitygroupkey,@v_accessind
  END /* WHILE FECTHING */

  CLOSE crSecWin 
  DEALLOCATE crSecWin 
 
  -- remove old security rows for comment window
  DELETE FROM securitywindows
  WHERE windowid = @CommentWindowID
  
  -- remove old comment window
  DELETE FROM qsiwindows
  WHERE windowid = @CommentWindowID  
  
END  
GO


DECLARE @SummaryWindowID int
DECLARE @CommentWindowID int
DECLARE @availSecurityObjectsKey int
DECLARE @sortNum int

SELECT @SummaryWindowID = (select windowid from qsiwindows where windowname = 'ProjectSummary')
SELECT @CommentWindowID = (select windowid from qsiwindows where windowname = 'ProjectComments')

update securityobjectsavailable
   set windowid = @SummaryWindowID
 where windowid = @CommentWindowID
   and availobjectid = 'ProjectCommentsByStatus' 
go