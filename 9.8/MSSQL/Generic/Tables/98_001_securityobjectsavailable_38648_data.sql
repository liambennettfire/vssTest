-- backup security tables
select * into securitywindows_38648
from securitywindows
go
select * into qsiwindows_38648
from qsiwindows
go

DECLARE @SummaryWindowID int
DECLARE @ProductDetailWindowID int
DECLARE @availSecurityObjectsKey int
DECLARE @sortNum int
DECLARE @userkey int
DECLARE @securitygroupkey int
DECLARE @securityobjectkey int
DECLARE @v_count int
DECLARE @v_accessind int

BEGIN
  SELECT @SummaryWindowID = (select windowid from qsiwindows where windowname = 'TitleSummary')
  SELECT @ProductDetailWindowID = (select windowid from qsiwindows where windowname = 'TitleProductDetail')
  SELECT @sortNum = ( select max(COALESCE(sortorder, 0)) from securityobjectsavailable where windowid = @SummaryWindowID 
                      and availobjectname is null and availobjectdesc like '%- ALL%' ) 

  if ( @sortNum is null ) select @sortNum = 0

  if not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @SummaryWindowID and availobjectid = 'shProductDetail' ) begin
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @availSecurityObjectsKey output
    insert into securityobjectsavailable (availablesecurityobjectskey,windowid,availobjectid,availobjectname,availobjectdesc,
                sortorder,menuitemid,menuitemname,menuitemdesc,lastuserid,lastmaintdate,availobjectcode,availobjectwholerowind,
                availobjectcodetableid,allowadmintochoosevalueind)
    values ( @availSecurityObjectsKey, @SummaryWindowID, 'shProductDetail', null, 'Title Product Detail - ALL', @sortNum, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null) 
  end
  else begin
    select @availSecurityObjectsKey = availablesecurityobjectskey
      from securityobjectsavailable
     where windowid = @SummaryWindowID
       and availobjectid = 'shProductDetail'
  end

  /*** Copy security from old Product Detail window to new summary section ***/
  DECLARE crSecWin CURSOR FOR
  SELECT userkey,securitygroupkey,accessind
  FROM securitywindows
  WHERE windowid = @ProductDetailWindowID
  
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
  END /* WHILE FETCHING */

  CLOSE crSecWin 
  DEALLOCATE crSecWin 

  -- remove old security rows for Product Detail window
  DELETE FROM securitywindows
  WHERE windowid = @ProductDetailWindowID
  
  -- remove old Product Detail window
  DELETE FROM qsiwindows
  WHERE windowid = @ProductDetailWindowID  
  
END  
GO