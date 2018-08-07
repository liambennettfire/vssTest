if exists (select * from dbo.sysobjects where id = Object_id('dbo.CoreProjectInfo_Row_Refresh') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.CoreProjectInfo_Row_Refresh
end

GO

CREATE PROCEDURE CoreProjectInfo_Row_Refresh
@i_projectkey int
AS

DECLARE 
  @v_rows int,
  @v_index int,
  @v_title varchar(255),
  @v_type int,
  @v_typedesc varchar(80),
  @v_status int,
  @v_statusdesc varchar(80),
  @v_series int,
  @v_seriesdesc varchar(80),
  @v_ownerkey int,
  @v_ownername varchar(80),
  @v_displayname varchar(255),
  @v_participants varchar(2000),
  @v_projecthdrlevel1 INT,
  @v_projecthdrlevel2 INT,
  @v_projecthdrkey1 INT,
  @v_projecthdrkey2 INT,
  @v_projecthdrorgdesc1 VARCHAR(40),
  @v_projecthdrorgdesc2 VARCHAR(40),
  @v_seasoncode INT,
  @v_seasondesc VARCHAR(40),
  @v_privateind TINYINT,
  @v_subsidyind TINYINT,
  @v_discounttypecode INT,
  @v_discounttypedesc VARCHAR(80),
  @v_searchitemcode INT,
  @v_usageclasscode INT,
  @v_usageclasscodedesc VARCHAR(80),
  @v_templateind TINYINT,
  @v_defaulttemplateind TINYINT  
 
BEGIN

if @i_projectkey is null begin
	return
end

  select
      @v_title = taqprojecttitle,
      @v_type = taqprojecttype,
      @v_status = taqprojectstatuscode,
      @v_series = taqprojectseriescode,
      @v_ownerkey = taqprojectownerkey,
      @v_subsidyind = subsidyind,
      @v_usageclasscode = usageclasscode,
      @v_searchitemcode = searchitemcode,
      @v_templateind = templateind,
      @v_defaulttemplateind = defaulttemplateind
    from taqproject
    where taqprojectkey=@i_projectkey 

  select @v_typedesc = datadesc
    from gentables
    where tableid=521
      and @v_type=datacode

  select @v_statusdesc = datadesc,
         @v_privateind = COALESCE(gen1ind,0)
    from gentables
    where tableid=522
      and @v_status=datacode

  select @v_seriesdesc = datadesc
    from gentables
    where tableid=327
      and @v_series=datacode

  select @v_usageclasscodedesc = datadesc
    from subgentables
    where tableid=550
      and datacode = @v_searchitemcode
      and datasubcode = @v_usageclasscode

  select @v_ownername = 
    CASE
      WHEN lastname IS NULL OR lastname='' THEN
        CASE
        WHEN firstname IS NULL OR firstname='' THEN userid
        ELSE firstname
        END
      ELSE LTRIM(firstname + ' ' + lastname)
    END    
    from qsiusers
    where userkey = @v_ownerkey

  -- rollup participants
  declare participant_cur cursor for 
  select gc.displayname
    from globalcontact gc, taqproject tp, taqprojectcontact tpc
    where tp.taqprojectkey=@i_projectkey
      and gc.globalcontactkey=tpc.globalcontactkey
      and tp.taqprojectkey=tpc.taqprojectkey
      and tpc.keyind=1
    order by tpc.sortorder

  open participant_cur 
  fetch participant_cur into @v_displayname
 
  set @v_index = 1
  while @@fetch_status = 0 and @v_index < 3
    begin
      if len(@v_participants)>1   
        set @v_participants =@v_participants+'/'
      set @v_participants = ltrim(COALESCE(@v_participants,' ') + @v_displayname)
      set @v_index = @v_index + 1
      fetch participant_cur into @v_displayname 
    end
  set @v_participants = substring(@v_participants,1,255)

  close participant_cur 
  deallocate participant_cur 


  /* Check at which organizational level this client stores Project Header Display Level 1 */
  SELECT @v_projecthdrlevel1 = filterorglevelkey
  FROM filterorglevel
  WHERE filterkey = 26	/* TAQ Project Header Level One */
  /* NOTE: not checking for errors here - TAQ Project Header1 filterorglevel record must exist */

  /* Check at which organizational level this client stores Project Header Display Level 1 */
  SELECT @v_projecthdrlevel2 = filterorglevelkey
  FROM filterorglevel
  WHERE filterkey = 27	/* TAQ Project Header Level Two */
  /* NOTE: not checking for errors here - TAQ Project Header2 filterorglevel record must exist */

  /*** Fill in TMM HEADER LEVEL 1 information ****/
  DECLARE orgentry_cur CURSOR FOR
    SELECT o.orgentrykey, o.orgentrydesc
    FROM taqprojectorgentry po, orgentry o
    WHERE po.orgentrykey = o.orgentrykey AND
        po.taqprojectkey = @i_projectkey AND
        po.orglevelkey = @v_projecthdrlevel1

  OPEN orgentry_cur
  FETCH NEXT FROM orgentry_cur INTO @v_projecthdrkey1, @v_projecthdrorgdesc1

  IF @@FETCH_STATUS<>0  /*orgentry_cur %NOTFOUND*/
  BEGIN
    SET @v_projecthdrkey1 = NULL
    SET @v_projecthdrorgdesc1 = NULL
  END

  CLOSE orgentry_cur
  DEALLOCATE orgentry_cur

  /*** Fill in Project HEADER LEVEL 2 information ****/
  IF @v_projecthdrlevel1 = @v_projecthdrlevel2
   BEGIN
    /* If Project Header Level 2 is identical to Project Header Level 1, use retrieved info above */
    SET @v_projecthdrkey2 = @v_projecthdrkey1
    SET @v_projecthdrorgdesc2 = @v_projecthdrorgdesc1
   END
  ELSE
   BEGIN
    DECLARE orgentry_cur CURSOR FOR
      SELECT o.orgentrykey, o.orgentrydesc
      FROM taqprojectorgentry po, orgentry o
      WHERE po.orgentrykey = o.orgentrykey AND
          po.taqprojectkey = @i_projectkey AND
          po.orglevelkey = @v_projecthdrlevel2

    OPEN orgentry_cur
    FETCH orgentry_cur INTO @v_projecthdrkey2, @v_projecthdrorgdesc2

    IF @@FETCH_STATUS <> 0 /*orgentry_cur %NOTFOUND*/
    BEGIN
      SET @v_projecthdrkey2 = NULL
      SET @v_projecthdrorgdesc2 = NULL
    END

    CLOSE orgentry_cur
    DEALLOCATE orgentry_cur
   END /* @v_projecthdrlevel1 <> @v_projecthdrlevel2 */
	
  -- get season and discount type from primary format
  SELECT @v_seasoncode = seasoncode, @v_discounttypecode = discountcode
  FROM taqprojecttitle
  WHERE taqprojectkey = @i_projectkey AND
      primaryformatind = 1

  IF @v_seasoncode > 0 BEGIN
    SELECT @v_seasondesc = seasondesc
    FROM season
    WHERE seasonkey = @v_seasoncode
  END
  
  IF @v_discounttypecode > 0 BEGIN
    SELECT @v_discounttypedesc = datadesc
    FROM gentables
    WHERE tableid = 459 AND
        datacode = @v_discounttypecode
  END

  -- insert or update coreprojectinfo row
  select @v_rows = count(*) 
    from coreprojectinfo 
    where projectkey=@i_projectkey

  if @v_rows = 0 or @v_rows is null
    insert into coreprojectinfo
      (projectkey,
       projecttitle,
       projecttype,
       projecttypedesc,
       projectstatus,
       projectstatusdesc,
       projectseries, 
       projectseriesdesc,
       projectparticipants,
       projectownerkey,
       projectowner,
       refreshind,
       lastmaintdate,
       projectheaderorg1key,
       projectheaderorg1desc,
       projectheaderorg2key,
       projectheaderorg2desc,
       primaryformatseason,
       primaryformatseasondesc,
       privateind,
       subsidyind,
       primaryformatdiscount,
       primaryformatdiscountdesc,
       searchitemcode,
       usageclasscode,
       usageclasscodedesc,
       templateind,
       defaulttemplateind)
      values
      (@i_Projectkey,
       @v_title,
       @v_type,
       @v_typedesc,
       @v_status,
       @v_statusdesc,
       @v_series,
       @v_seriesdesc,
       @v_participants,
       @v_ownerkey,
       @v_ownername,
       null,
       getdate(),
       @v_projecthdrkey1, 
       @v_projecthdrorgdesc1,
       @v_projecthdrkey2, 
       @v_projecthdrorgdesc2,
       @v_seasoncode,
       @v_seasondesc,
       @v_privateind,
       @v_subsidyind,
       @v_discounttypecode,
       @v_discounttypedesc,
       @v_searchitemcode,
       @v_usageclasscode,
       @v_usageclasscodedesc,
       @v_templateind,
       @v_defaulttemplateind)

  if @v_rows = 1
    update coreProjectinfo
       set
         projectkey = @i_projectkey,
         projecttitle = @v_title,
         projecttype = @v_type,
         projecttypedesc = @v_typedesc,
         projectstatus = @v_status,
         projectstatusdesc = @v_statusdesc,
         projectseries = @v_series,
         projectseriesdesc = @v_seriesdesc,
         projectownerkey = @v_ownerkey,
         projectowner = @v_ownername,
         projectparticipants = @v_participants,
         refreshind = null,
         lastmaintdate = getdate(),
         projectheaderorg1key = @v_projecthdrkey1,
         projectheaderorg1desc = @v_projecthdrorgdesc1,
         projectheaderorg2key = @v_projecthdrkey2,
         projectheaderorg2desc = @v_projecthdrorgdesc2,
         primaryformatseason = @v_seasoncode,
         primaryformatseasondesc = @v_seasondesc,
         privateind = @v_privateind,
         subsidyind = @v_subsidyind,
         primaryformatdiscount = @v_discounttypecode,
         primaryformatdiscountdesc = @v_discounttypedesc,
         searchitemcode = @v_searchitemcode,
         usageclasscode = @v_usageclasscode,
         usageclasscodedesc = @v_usageclasscodedesc,
         templateind= @v_templateind,
         defaulttemplateind = @v_defaulttemplateind
    where projectkey=@i_projectkey

END

GO
