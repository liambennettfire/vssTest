if exists (select * from dbo.sysobjects where id = Object_id('dbo.CoreContactInfo_Row_Refresh') and (type = 'P' or type = 'RF'))
 drop proc dbo.CoreContactInfo_Row_Refresh
GO

CREATE PROCEDURE CoreContactInfo_Row_Refresh
  @i_contactkey INT
AS

DECLARE 
  @v_displayname VARCHAR(255),
  @v_email VARCHAR(100),
  @v_phone VARCHAR(100),
  @v_keyroles VARCHAR(255),
  @v_role VARCHAR(255),
  @v_keycategories VARCHAR(2000), 
  @v_category VARCHAR(1000),
  @v_categorydesc VARCHAR(1000),
  @v_privatind INT,
  @v_owneruserkey INT,
  @v_owneruserid  VARCHAR(30),
  @v_rows INT,
  @v_contactkey INT,
  @v_contactname VARCHAR(255),
  @v_contactrelationshipcode1 INT,
  @v_contactrelationshipcode2 INT,
  @v_relatedcontactkey1 INT,
  @v_relatedcontactkey2 INT,
  @v_relatedcontactname1 VARCHAR(255),
  @v_relatedcontactname2 VARCHAR(255),
  @v_sortorder  INT,
  @v_keyind TINYINT,
  @v_searchfield VARCHAR(2000)

BEGIN

  if @i_contactkey is null begin
    return
  end

  select
      @v_displayname = displayname ,
      @v_privatind = privateind,
      @v_owneruserid = lastuserid
    from globalcontact
    where globalcontactkey=@i_contactkey 
    
  -- Default owneruserkey for the contact owner (lastuserid) to NULL
  SET @v_owneruserkey = NULL  
  
  -- If user exists and contact is private, set the owneruserkey
  SELECT @v_rows = COUNT(*)
  FROM qsiusers
  WHERE UPPER(userid) = UPPER(@v_owneruserid)
  
  IF @v_rows > 0 AND @v_privatind = 1
    SELECT @v_owneruserkey = userkey
    FROM qsiusers
    WHERE UPPER(userid) = UPPER(@v_owneruserid)


  select @v_email = gcm.contactmethodvalue
    from 
      globalcontact gc, globalcontactmethod gcm, gentables g
    where
      gc.globalcontactkey=@i_contactkey and
      gc.globalcontactkey=gcm.globalcontactkey and
      gcm.primaryind=1 and
      gcm.contactmethodcode=g.datacode and
      g.tableid=517 and
      g.datacode=3

  select @v_phone = gcm.contactmethodvalue
    from 
      globalcontact gc, globalcontactmethod gcm, gentables g
    where
      gc.globalcontactkey=@i_contactkey and
      gc.globalcontactkey=gcm.globalcontactkey and
      gcm.primaryind=1 and
      gcm.contactmethodcode=g.datacode and
      g.tableid=517 and
      g.datacode=1

    /* Get searchfield data*/
		exec qcontact_get_corecontactinfo_searchfield @i_contactkey, @v_searchfield OUTPUT

  -- *** Related contacts - Case 18340 ***
  -- Get the first Contact Relationship Code to track on coretitleinfo from clientdefaults
  SELECT @v_contactrelationshipcode1 = clientdefaultvalue
  FROM clientdefaults
  WHERE clientdefaultid = 64
  
  IF @v_contactrelationshipcode1 IS NULL
    SET @v_contactrelationshipcode1 = 0
  
  IF @v_contactrelationshipcode1 > 0
  BEGIN
    DECLARE relationships_cur CURSOR FOR
      SELECT r.globalcontactkey2, c.displayname, r.sortorder, r.keyind 
      FROM globalcontactrelationship r, globalcontact c
      WHERE r.globalcontactkey2 = c.globalcontactkey AND
        r.contactrelationshipcode1 = @v_contactrelationshipcode1 AND
        r.globalcontactkey1 = @i_contactkey 
      UNION 
      SELECT r.globalcontactkey1, c.displayname, r.sortorder, r.keyind 
      FROM globalcontactrelationship r, globalcontact c
      WHERE r.globalcontactkey1 = c.globalcontactkey AND 
        r.contactrelationshipcode2 = @v_contactrelationshipcode1 AND
        r.globalcontactkey2 = @i_contactkey 
      ORDER BY r.keyind DESC, r.sortorder ASC
    
    OPEN relationships_cur 
    
    FETCH relationships_cur INTO @v_contactkey, @v_contactname, @v_sortorder, @v_keyind

    IF @@fetch_status = 0
    BEGIN  
      SET @v_relatedcontactkey1 = @v_contactkey
      SET @v_relatedcontactname1 = @v_contactname
    END
    
    CLOSE relationships_cur 
    DEALLOCATE relationships_cur   
  END
  
  -- Get the second Contact Relationship Code to track on coretitleinfo from clientdefaults
  SELECT @v_contactrelationshipcode2 = clientdefaultvalue
  FROM clientdefaults
  WHERE clientdefaultid = 65
  
  IF @v_contactrelationshipcode2 IS NULL
    SET @v_contactrelationshipcode2 = 0
    
  IF @v_contactrelationshipcode2 > 0
  BEGIN    
    DECLARE relationships_cur CURSOR FOR
      SELECT r.globalcontactkey2, c.displayname, r.sortorder, r.keyind
      FROM globalcontactrelationship r, globalcontact c
      WHERE r.globalcontactkey2 = c.globalcontactkey AND
        r.contactrelationshipcode1 = @v_contactrelationshipcode2 AND
        r.globalcontactkey1 = @i_contactkey
      UNION 
      SELECT r.globalcontactkey1, c.displayname, r.sortorder, r.keyind 
      FROM globalcontactrelationship r, globalcontact c
      WHERE r.globalcontactkey1 = c.globalcontactkey AND 
        r.contactrelationshipcode2 = @v_contactrelationshipcode2 AND
        r.globalcontactkey2 = @i_contactkey
      ORDER BY r.keyind DESC, r.sortorder ASC
        
    OPEN relationships_cur 
    
    FETCH relationships_cur INTO @v_contactkey, @v_contactname, @v_sortorder, @v_keyind

    IF @@fetch_status = 0
    BEGIN  
      SET @v_relatedcontactkey2 = @v_contactkey
      SET @v_relatedcontactname2 = @v_contactname   
    END
    
    CLOSE relationships_cur 
    DEALLOCATE relationships_cur
  END
  
  -- rollup roles
  declare role_cur cursor for 
    select  g.datadesc
      from 
        globalcontact gc, globalcontactrole gcr, gentables g
      where
        gc.globalcontactkey=@i_contactkey and
        gc.globalcontactkey=gcr.globalcontactkey and
        gcr.rolecode=g.datacode and
        g.tableid=285 and
        gcr.keyind=1

  open role_cur 
  fetch role_cur into @v_role

  while @@fetch_status = 0
    begin
      if len(@v_keyroles)>1   
        set @v_keyroles =@v_keyroles+', '
      set @v_keyroles = ltrim(COALESCE(@v_keyroles,' ') + @v_role)
      fetch role_cur into @v_role 
    end

  close role_cur 
  deallocate role_cur 

  -- rollup categories
  declare category_cur cursor for 
    select rtrim(COALESCE(gd.tabledesclong,' '))+': ' + rtrim(COALESCE(g.datadesc,' ')), 
        rtrim(COALESCE(gcc.contactcategorydesc,' '))
      from 
        globalcontactcategory gcc, gentables g, gentablesdesc gd
      where
        g.tableid = gcc.tableid and
        g.tableid = gd.tableid and 
        gcc.globalcontactkey = @i_contactkey and
        gcc.contactcategorycode = g.datacode and
        COALESCE(gcc.contactcategorysubcode,0) = 0 and
        COALESCE(gcc.contactcategorysub2code,0) = 0 and
        gcc.keyind = 1
    UNION
      select rtrim(COALESCE(g.datadesc,' '))+': '+rtrim(COALESCE(sg.datadesc,' ')), 
        rtrim(COALESCE(gcc.contactcategorydesc,' '))
      from 
        globalcontactcategory gcc, gentables g, subgentables sg
      where
        g.tableid = gcc.tableid and
        sg.tableid = gcc.tableid and
        gcc.globalcontactkey = @i_contactkey and
        gcc.contactcategorycode = g.datacode and
        sg.datacode = g.datacode and
        sg.datasubcode = gcc.contactcategorysubcode and
        COALESCE(gcc.contactcategorysub2code,0) = 0 and
        gcc.keyind = 1
    UNION
      select rtrim(COALESCE(g.datadesc,' ')) + ': ' + rtrim(COALESCE(sg.datadesc,' ')) + ': ' + rtrim(COALESCE(sg2.datadesc,' ')), 
        rtrim(COALESCE(gcc.contactcategorydesc,' '))
      from 
        globalcontactcategory gcc, gentables g, subgentables sg, sub2gentables sg2
      where
        g.tableid = gcc.tableid and
        sg.tableid = gcc.tableid and
        sg2.tableid = gcc.tableid and
        gcc.globalcontactkey = @i_contactkey and
        gcc.contactcategorycode = g.datacode and
        sg.datacode = g.datacode and
        sg.datasubcode = gcc.contactcategorysubcode and
        sg2.datacode = gcc.contactcategorycode and
        sg2.datasubcode = gcc.contactcategorysubcode and
        sg2.datasub2code = gcc.contactcategorysub2code and
        gcc.keyind = 1

  open category_cur 
  fetch category_cur into @v_category,@v_categorydesc

  while @@fetch_status = 0
    begin
      if len(@v_keycategories)>1 and @v_keycategories is not null 
        set @v_keycategories =ltrim(@v_keycategories)+'; '
      if len(rtrim(@v_categorydesc)) > 0 and @v_categorydesc is not null
        set @v_category=@v_category+' - '+@v_categorydesc
      set @v_keycategories = ltrim(COALESCE(@v_keycategories,' ') + @v_category)
      fetch category_cur into @v_category,@v_categorydesc
    end

  close category_cur 
  deallocate category_cur 

  select @v_rows = count(*) 
    from corecontactinfo 
    where contactkey=@i_contactkey

  -- insert or update corecontactinfo row
  if @v_rows = 0 or @v_rows is null
    insert into corecontactinfo
      (contactkey, displayname, privateind, email, phone, keyroles, keycategories, refreshind, owneruserkey,
      relatedcontactkey1, relatedcontactname1, relatedcontactkey2, relatedcontactname2, lastmaintdate, searchfield)
    values
      (@i_contactkey, @v_displayname,  @v_privatind,@v_email, @v_phone, @v_keyroles, @v_keycategories, null, @v_owneruserkey,
      @v_relatedcontactkey1, @v_relatedcontactname1, @v_relatedcontactkey2, @v_relatedcontactname2, getdate(), @v_searchfield)

  if @v_rows = 1
    update corecontactinfo
       set
         contactkey = @i_contactkey,
         displayname = @v_displayname,
         privateind = @v_privatind,
         email = @v_email,
         phone = @v_phone,
         keyroles = @v_keyroles,
         keycategories = @v_keycategories,
         refreshind = null,
         owneruserkey = @v_owneruserkey,
         relatedcontactkey1 = @v_relatedcontactkey1,
         relatedcontactname1 = @v_relatedcontactname1,
         relatedcontactkey2 = @v_relatedcontactkey2,
         relatedcontactname2 = @v_relatedcontactname2,
         lastmaintdate = getdate(),
         searchfield = @v_searchfield
    where contactkey=@i_contactkey
    
    -- Also update the displayname on contact relationship columns for the contact being modified
    IF @v_contactrelationshipcode1 > 0 OR @v_contactrelationshipcode2 > 0
    BEGIN
      SELECT @v_contactname = displayname
      FROM globalcontact
      WHERE globalcontactkey = @i_contactkey
      
      IF @v_contactrelationshipcode1 > 0
        UPDATE corecontactinfo
        SET relatedcontactname1 = @v_contactname, lastmaintdate = GETDATE()
        WHERE relatedcontactkey1 = @i_contactkey
      
      IF @v_contactrelationshipcode2 > 0
        UPDATE corecontactinfo
        SET relatedcontactname2 = @v_contactname, lastmaintdate = GETDATE()
        WHERE relatedcontactkey2 = @i_contactkey 
    END   

END

GO
